import { NotFoundException } from '@nestjs/common';
import { FarmsService } from '../farms.service';

describe('FarmsService', () => {
  let repo: any;
  let service: FarmsService;

  const ownerFarm = {
    id: 'farm-1',
    farmerId: 'farmer-1',
    name: 'North plot',
    sizeHectares: '2.50',
    zone: 'Jimma',
    woreda: 'Manna',
    kebele: null,
    latitude: null,
    longitude: null,
  };

  beforeEach(() => {
    repo = {
      create: jest.fn((x) => x),
      save: jest.fn((x) => Promise.resolve({ ...x, id: x.id ?? 'new-id' })),
      find: jest.fn(),
      findOne: jest.fn(),
      remove: jest.fn().mockResolvedValue(undefined),
    };
    service = new FarmsService(repo);
  });

  describe('create', () => {
    it('stores decimal fields as fixed-precision strings, not raw floats', async () => {
      await service.create('farmer-1', {
        name: 'Test farm',
        sizeHectares: 3.456,
        zone: 'Jimma',
        woreda: 'Manna',
        latitude: 7.6789012,
        longitude: 36.8312345,
      } as any);

      const saved = repo.save.mock.calls[0][0];
      expect(saved.sizeHectares).toBe('3.46'); // rounded to 2dp, as a string
      expect(saved.latitude).toBe('7.678901'); // 6dp
      expect(saved.longitude).toBe('36.831235'); // 6dp, rounded
      expect(saved.farmerId).toBe('farmer-1');
    });

    it('stores null for omitted optional GPS coordinates rather than 0', async () => {
      await service.create('farmer-1', {
        name: 'Test farm',
        sizeHectares: 1,
        zone: 'Jimma',
        woreda: 'Manna',
      } as any);

      const saved = repo.save.mock.calls[0][0];
      expect(saved.latitude).toBeNull();
      expect(saved.longitude).toBeNull();
    });
  });

  describe('findOneOwnedBy — the ownership boundary', () => {
    it('returns the farm when it belongs to the requester', async () => {
      repo.findOne.mockResolvedValue(ownerFarm);
      const result = await service.findOneOwnedBy('farm-1', 'farmer-1');
      expect(result).toBe(ownerFarm);
    });

    it('throws NotFoundException (not ForbiddenException) when the farm belongs to someone else', async () => {
      repo.findOne.mockResolvedValue(ownerFarm); // owned by farmer-1
      await expect(
        service.findOneOwnedBy('farm-1', 'someone-else'),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws the exact same error for "belongs to someone else" as for "does not exist" (no enumeration)', async () => {
      repo.findOne.mockResolvedValueOnce(ownerFarm);
      let ownedByOtherError: any;
      try {
        await service.findOneOwnedBy('farm-1', 'someone-else');
      } catch (e) {
        ownedByOtherError = e;
      }

      repo.findOne.mockResolvedValueOnce(null);
      let notFoundError: any;
      try {
        await service.findOneOwnedBy('does-not-exist', 'someone-else');
      } catch (e) {
        notFoundError = e;
      }

      expect(ownedByOtherError.message).toEqual(notFoundError.message);
      expect(ownedByOtherError.status).toEqual(notFoundError.status);
    });
  });

  describe('update', () => {
    it('rejects updating a farm owned by another farmer', async () => {
      repo.findOne.mockResolvedValue(ownerFarm);
      await expect(
        service.update('farm-1', 'someone-else', { name: 'Hijacked' }),
      ).rejects.toThrow(NotFoundException);
      expect(repo.save).not.toHaveBeenCalled();
    });

    it('only changes fields present in the DTO, leaving others untouched', async () => {
      repo.findOne.mockResolvedValue({ ...ownerFarm });
      const result = await service.update('farm-1', 'farmer-1', { name: 'Renamed' });
      expect(result.name).toBe('Renamed');
      expect(result.zone).toBe('Jimma'); // untouched
    });
  });

  describe('remove', () => {
    it('rejects deleting a farm owned by another farmer', async () => {
      repo.findOne.mockResolvedValue(ownerFarm);
      await expect(service.remove('farm-1', 'someone-else')).rejects.toThrow(
        NotFoundException,
      );
      expect(repo.remove).not.toHaveBeenCalled();
    });

    it('deletes when the requester is the owner', async () => {
      repo.findOne.mockResolvedValue(ownerFarm);
      await service.remove('farm-1', 'farmer-1');
      expect(repo.remove).toHaveBeenCalledWith(ownerFarm);
    });
  });
});
