import { BadRequestException, NotFoundException } from '@nestjs/common';
import { FarmCropsService } from '../farm-crops.service';

describe('FarmCropsService', () => {
  let repo: any;
  let farmsService: any;
  let cropsService: any;
  let service: FarmCropsService;

  const farm = { id: 'farm-1', farmerId: 'farmer-1', sizeHectares: '10.00' };
  const crop = { id: 'crop-1', name: 'Maize', isActive: true };

  const existingRecord = {
    id: 'record-1',
    farmId: 'farm-1',
    cropId: 'crop-1',
    areaHectares: '4.00',
    expectedYieldKg: null,
    harvestStart: null,
    harvestEnd: null,
    crop,
  };

  beforeEach(() => {
    repo = {
      create: jest.fn((x) => x),
      save: jest.fn((x) => Promise.resolve({ ...x, id: x.id ?? 'new-record-id' })),
      find: jest.fn().mockResolvedValue([]),
      findOne: jest.fn(),
      findOneOrFail: jest.fn(),
      remove: jest.fn().mockResolvedValue(undefined),
    };
    farmsService = {
      findOneOwnedBy: jest.fn().mockResolvedValue(farm),
      findAllForFarmer: jest.fn(),
    };
    cropsService = {
      getActiveOrThrow: jest.fn().mockResolvedValue(crop),
    };
    service = new FarmCropsService(repo, farmsService, cropsService);
  });

  describe('create', () => {
    it('rejects a crop record for a farm the caller does not own', async () => {
      farmsService.findOneOwnedBy.mockRejectedValue(new NotFoundException('Farm not found'));

      await expect(
        service.create('farm-1', 'not-the-owner', {
          cropId: 'crop-1',
          areaHectares: 2,
        } as any),
      ).rejects.toThrow(NotFoundException);
      expect(cropsService.getActiveOrThrow).not.toHaveBeenCalled();
    });

    it('rejects a crop that does not exist or is inactive', async () => {
      cropsService.getActiveOrThrow.mockRejectedValue(
        new NotFoundException('Crop not found or not currently available'),
      );

      await expect(
        service.create('farm-1', 'farmer-1', { cropId: 'bad-crop', areaHectares: 2 } as any),
      ).rejects.toThrow(NotFoundException);
    });

    it('rejects when the requested area alone exceeds the farm size', async () => {
      repo.find.mockResolvedValue([]); // nothing committed yet
      await expect(
        service.create('farm-1', 'farmer-1', { cropId: 'crop-1', areaHectares: 15 } as any),
      ).rejects.toThrow(BadRequestException);
      expect(repo.save).not.toHaveBeenCalled();
    });

    it('rejects when the requested area, combined with existing records, exceeds the farm size', async () => {
      repo.find.mockResolvedValue([existingRecord]); // 4 ha already committed
      await expect(
        // 4 (existing) + 7 (new) = 11 > 10 ha farm
        service.create('farm-1', 'farmer-1', { cropId: 'crop-1', areaHectares: 7 } as any),
      ).rejects.toThrow(BadRequestException);
    });

    it('allows the area right up to exactly the farm size', async () => {
      repo.find.mockResolvedValue([existingRecord]); // 4 ha already committed
      repo.findOneOrFail.mockResolvedValue({ ...existingRecord, id: 'new-record-id' });
      // 4 (existing) + 6 (new) = 10, exactly the farm's size — should pass
      const result = await service.create('farm-1', 'farmer-1', {
        cropId: 'crop-1',
        areaHectares: 6,
      } as any);
      expect(result).toBeDefined();
      expect(repo.save).toHaveBeenCalled();
    });

    it('rejects a harvest window where the end date precedes the start date', async () => {
      await expect(
        service.create('farm-1', 'farmer-1', {
          cropId: 'crop-1',
          areaHectares: 1,
          harvestStart: '2026-12-01',
          harvestEnd: '2026-01-01',
        } as any),
      ).rejects.toThrow(BadRequestException);
    });

    it('stores null (not zero) for an omitted expected yield', async () => {
      repo.findOneOrFail.mockResolvedValue({ ...existingRecord, id: 'new-record-id' });
      await service.create('farm-1', 'farmer-1', { cropId: 'crop-1', areaHectares: 1 } as any);
      const saved = repo.create.mock.calls[0][0];
      expect(saved.expectedYieldKg).toBeNull();
    });
  });

  describe('findOneOwnedBy — ownership chained through the farm', () => {
    it('throws NotFoundException when the record belongs to a different farm', async () => {
      repo.findOne.mockResolvedValue({ ...existingRecord, farmId: 'some-other-farm' });
      await expect(
        service.findOneOwnedBy('farm-1', 'record-1', 'farmer-1'),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws NotFoundException (propagated) when the farm itself is not owned by the caller', async () => {
      farmsService.findOneOwnedBy.mockRejectedValue(new NotFoundException('Farm not found'));
      await expect(
        service.findOneOwnedBy('farm-1', 'record-1', 'someone-else'),
      ).rejects.toThrow(NotFoundException);
    });

    it('returns the record when it belongs to the caller\u2019s farm', async () => {
      repo.findOne.mockResolvedValue(existingRecord);
      const result = await service.findOneOwnedBy('farm-1', 'record-1', 'farmer-1');
      expect(result).toBe(existingRecord);
    });
  });

  describe('update', () => {
    it('excludes the record being edited from its own area-budget check', async () => {
      repo.findOne.mockResolvedValue(existingRecord); // this record already uses 4 ha
      repo.find.mockResolvedValue([existingRecord]); // only record on the farm
      repo.findOneOrFail.mockResolvedValue({ ...existingRecord, areaHectares: '10.00' });

      // Growing this exact record from 4 ha to 10 ha should be fine — it's
      // the farm's entire size, and the only other "existing" area is
      // itself, which must be excluded or this would wrongly compute
      // 4 (self, counted twice) + 10 = 14 > 10 and reject.
      const result = await service.update('farm-1', 'record-1', 'farmer-1', {
        areaHectares: 10,
      } as any);
      expect(result).toBeDefined();
    });

    it('rejects growing a record beyond what the farm can accommodate alongside other records', async () => {
      const otherRecord = { ...existingRecord, id: 'record-2', areaHectares: '5.00' };
      repo.findOne.mockResolvedValue(existingRecord); // editing record-1 (4 ha)
      repo.find.mockResolvedValue([existingRecord, otherRecord]); // 4 + 5 = 9 ha total

      // record-2's 5 ha excluded-self-check: growing record-1 to 7 ha would
      // make 5 (other) + 7 (this, grown) = 12 > 10 ha farm — reject.
      await expect(
        service.update('farm-1', 'record-1', 'farmer-1', { areaHectares: 7 } as any),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('remove', () => {
    it('rejects deleting a record on a farm the caller does not own', async () => {
      farmsService.findOneOwnedBy.mockRejectedValue(new NotFoundException('Farm not found'));
      await expect(service.remove('farm-1', 'record-1', 'someone-else')).rejects.toThrow(
        NotFoundException,
      );
      expect(repo.remove).not.toHaveBeenCalled();
    });

    it('deletes when the caller owns the farm', async () => {
      repo.findOne.mockResolvedValue(existingRecord);
      await service.remove('farm-1', 'record-1', 'farmer-1');
      expect(repo.remove).toHaveBeenCalledWith(existingRecord);
    });
  });
});
