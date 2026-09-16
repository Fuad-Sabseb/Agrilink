import { BadRequestException, NotFoundException } from '@nestjs/common';
import { BuyerDemandService } from '../buyer-demand.service';
import { DemandStatus } from '../entities/buyer-demand.entity';
import { BuyerTier, VerificationStatus } from '../entities/buyer-profile.entity';

function futureDate(daysAhead = 30): string {
  const d = new Date();
  d.setDate(d.getDate() + daysAhead);
  return d.toISOString().slice(0, 10);
}

function pastDate(daysBack = 5): string {
  const d = new Date();
  d.setDate(d.getDate() - daysBack);
  return d.toISOString().slice(0, 10);
}

describe('BuyerDemandService', () => {
  let repo: any;
  let buyerProfileService: any;
  let cropsService: any;
  let service: BuyerDemandService;

  const profile = {
    id: 'profile-1',
    userId: 'user-1',
    businessName: 'Jimma Grain Traders',
    tier: BuyerTier.CITY_MERCHANT,
    zone: 'Jimma Zone',
    woreda: 'Manna',
    verificationStatus: VerificationStatus.VERIFIED,
    disclosedFeeBasisPoints: null,
    completedDealsCount: 4,
    noShowCount: 1,
  };

  const crop = { id: 'crop-1', slug: 'maize', name: 'Maize', isActive: true };

  const savedDemand = {
    id: 'demand-1',
    buyerProfileId: 'profile-1',
    buyerProfile: profile,
    cropId: 'crop-1',
    crop,
    quantityKg: '3000.00',
    offerPricePerKgCents: 1250,
    grade: 'standard',
    deliveryZone: 'Jimma Zone',
    deliveryWoreda: null,
    status: DemandStatus.BUYING_NOW,
    neededBy: null,
    notes: null,
    createdAt: new Date(),
  };

  beforeEach(() => {
    repo = {
      create: jest.fn((x) => x),
      save: jest.fn((x) => Promise.resolve({ ...x, id: x.id ?? 'demand-1' })),
      find: jest.fn().mockResolvedValue([]),
      findOne: jest.fn(),
      findOneOrFail: jest.fn().mockResolvedValue(savedDemand),
      createQueryBuilder: jest.fn(),
    };
    buyerProfileService = {
      findByUserId: jest.fn().mockResolvedValue(profile),
      computeReliability: jest.fn().mockReturnValue({
        completedDeals: 4,
        noShows: 1,
        onTimeRate: 80,
      }),
    };
    cropsService = { getActiveOrThrow: jest.fn().mockResolvedValue(crop) };
    service = new BuyerDemandService(repo, buyerProfileService, cropsService);
  });

  describe('create', () => {
    it('converts the ETB offer price to integer cents for storage', async () => {
      await service.create('user-1', {
        cropId: 'crop-1',
        quantityKg: 3000,
        offerPricePerKg: 12.5,
      } as any);

      expect(repo.create.mock.calls[0][0].offerPricePerKgCents).toBe(1250);
    });

    it('stores null (not zero) when no offer price is given, since §7.3 allows negotiation', async () => {
      await service.create('user-1', { cropId: 'crop-1', quantityKg: 3000 } as any);
      expect(repo.create.mock.calls[0][0].offerPricePerKgCents).toBeNull();
    });

    it('defaults to DRAFT so a posting is not accidentally made live', async () => {
      await service.create('user-1', { cropId: 'crop-1', quantityKg: 3000 } as any);
      expect(repo.create.mock.calls[0][0].status).toBe(DemandStatus.DRAFT);
    });

    it('allows posting straight to BUYING_NOW without a pointless draft step', async () => {
      await service.create('user-1', {
        cropId: 'crop-1',
        quantityKg: 3000,
        status: DemandStatus.BUYING_NOW,
      } as any);
      expect(repo.create.mock.calls[0][0].status).toBe(DemandStatus.BUYING_NOW);
    });

    it('rejects creating a demand that is already closed', async () => {
      await expect(
        service.create('user-1', {
          cropId: 'crop-1',
          quantityKg: 3000,
          status: DemandStatus.CLOSED,
        } as any),
      ).rejects.toThrow(BadRequestException);
      expect(repo.save).not.toHaveBeenCalled();
    });

    it('rejects a needed-by date in the past', async () => {
      await expect(
        service.create('user-1', {
          cropId: 'crop-1',
          quantityKg: 3000,
          neededBy: pastDate(),
        } as any),
      ).rejects.toThrow(BadRequestException);
    });

    it('accepts a future needed-by date', async () => {
      await service.create('user-1', {
        cropId: 'crop-1',
        quantityKg: 3000,
        neededBy: futureDate(),
      } as any);
      expect(repo.save).toHaveBeenCalled();
    });

    it('rejects an inactive or nonexistent crop', async () => {
      cropsService.getActiveOrThrow.mockRejectedValue(new NotFoundException('Crop not found'));
      await expect(
        service.create('user-1', { cropId: 'bad-crop', quantityKg: 3000 } as any),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('ownership', () => {
    it('returns the same 404 for another buyer\u2019s demand as for one that does not exist', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand, buyerProfileId: 'someone-else' });
      let othersError: any;
      try {
        await service.findOneOwnedBy('demand-1', 'user-1');
      } catch (e) {
        othersError = e;
      }

      repo.findOne.mockResolvedValue(null);
      let missingError: any;
      try {
        await service.findOneOwnedBy('nonexistent', 'user-1');
      } catch (e) {
        missingError = e;
      }

      expect(othersError).toBeInstanceOf(NotFoundException);
      expect(missingError).toBeInstanceOf(NotFoundException);
      expect(othersError.message).toEqual(missingError.message);
    });
  });

  describe('update', () => {
    it('refuses to edit a closed demand', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand, status: DemandStatus.CLOSED });
      await expect(
        service.update('demand-1', 'user-1', { quantityKg: 100 } as any),
      ).rejects.toThrow(BadRequestException);
    });

    it('changes only the fields present in the DTO', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand });
      await service.update('demand-1', 'user-1', { quantityKg: 5000 } as any);

      const saved = repo.save.mock.calls[0][0];
      expect(saved.quantityKg).toBe('5000.00'); // changed
      expect(saved.grade).toBe('standard'); // untouched
      expect(saved.offerPricePerKgCents).toBe(1250); // untouched
    });

    it('validates a newly-supplied crop before accepting it', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand });
      cropsService.getActiveOrThrow.mockRejectedValue(new NotFoundException('Crop not found'));
      await expect(
        service.update('demand-1', 'user-1', { cropId: 'bad-crop' } as any),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('close', () => {
    it('sets the demand to CLOSED', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand });
      await service.close('demand-1', 'user-1');
      expect(repo.save.mock.calls[0][0].status).toBe(DemandStatus.CLOSED);
    });
  });

  describe('getPublicDemand', () => {
    it('hides a DRAFT demand from farmers, even by direct id', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand, status: DemandStatus.DRAFT });
      await expect(service.getPublicDemand('demand-1')).rejects.toThrow(NotFoundException);
    });

    it('hides a PAUSED demand — "not buying today" is the whole point of the live status', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand, status: DemandStatus.PAUSED });
      await expect(service.getPublicDemand('demand-1')).rejects.toThrow(NotFoundException);
    });

    it('returns a BUYING_NOW demand as a farmer-facing view', async () => {
      repo.findOne.mockResolvedValue({ ...savedDemand });
      const result = await service.getPublicDemand('demand-1');

      expect(result.status).toBe(DemandStatus.BUYING_NOW);
      expect(result.offerPricePerKg).toBe('12.50'); // cents converted back to ETB
      expect(result.buyer.reliability.onTimeRate).toBe(80);
      // The buyer's raw internal counters must not leak into the view.
      expect(result.buyer).not.toHaveProperty('completedDealsCount');
      expect(result.buyer).not.toHaveProperty('noShowCount');
    });

    it('exposes a collector\u2019s disclosed fee as a percentage (§7.4 transparency)', async () => {
      repo.findOne.mockResolvedValue({
        ...savedDemand,
        buyerProfile: {
          ...profile,
          tier: BuyerTier.LOCAL_COLLECTOR,
          disclosedFeeBasisPoints: 750, // 7.5%
        },
      });
      const result = await service.getPublicDemand('demand-1');
      expect(result.buyer.disclosedFeePercent).toBe(7.5);
    });
  });

  describe('searchForFarmers', () => {
    function mockQueryBuilder(results: any[]) {
      const qb: any = {
        leftJoinAndSelect: jest.fn(() => qb),
        where: jest.fn(() => qb),
        andWhere: jest.fn(() => qb),
        orderBy: jest.fn(() => qb),
        addOrderBy: jest.fn(() => qb),
        getMany: jest.fn().mockResolvedValue(results),
      };
      repo.createQueryBuilder.mockReturnValue(qb);
      return qb;
    }

    it('only ever returns BUYING_NOW demands — never drafts or paused postings', async () => {
      const qb = mockQueryBuilder([savedDemand]);
      await service.searchForFarmers({});

      expect(qb.where).toHaveBeenCalledWith('demand.status = :status', {
        status: DemandStatus.BUYING_NOW,
      });
    });

    it('applies a crop filter when given', async () => {
      const qb = mockQueryBuilder([]);
      await service.searchForFarmers({ cropId: 'crop-1' });
      expect(qb.andWhere).toHaveBeenCalledWith('demand.cropId = :cropId', {
        cropId: 'crop-1',
      });
    });

    it('matches a zone against either the delivery zone or the buyer\u2019s own location', async () => {
      const qb = mockQueryBuilder([]);
      await service.searchForFarmers({ zone: 'Jimma Zone' });
      expect(qb.andWhere).toHaveBeenCalledWith(
        '(demand.deliveryZone = :zone OR buyerProfile.zone = :zone)',
        { zone: 'Jimma Zone' },
      );
    });

    it('restricts to verified buyers only when asked', async () => {
      const qb = mockQueryBuilder([]);
      await service.searchForFarmers({ verifiedOnly: true });
      expect(qb.andWhere).toHaveBeenCalledWith('buyerProfile.verificationStatus = :verified', {
        verified: VerificationStatus.VERIFIED,
      });
    });

    it('does NOT restrict to verified buyers when the filter is absent', async () => {
      const qb = mockQueryBuilder([]);
      await service.searchForFarmers({});
      const verifiedCalls = qb.andWhere.mock.calls.filter((c: any[]) =>
        String(c[0]).includes('verificationStatus'),
      );
      expect(verifiedCalls).toHaveLength(0);
    });
  });
});
