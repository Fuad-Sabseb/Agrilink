import { NotFoundException } from '@nestjs/common';
import { BuyerProfileService } from '../buyer-profile.service';
import { BuyerTier, VerificationStatus } from '../entities/buyer-profile.entity';

describe('BuyerProfileService', () => {
  let repo: any;
  let service: BuyerProfileService;

  const baseProfile = {
    id: 'profile-1',
    userId: 'user-1',
    businessName: 'Jimma Grain Traders',
    tier: BuyerTier.CITY_MERCHANT,
    zone: 'Jimma Zone',
    woreda: 'Manna',
    kebele: null,
    verificationStatus: VerificationStatus.UNVERIFIED,
    disclosedFeeBasisPoints: null,
    completedDealsCount: 0,
    noShowCount: 0,
  };

  beforeEach(() => {
    repo = {
      create: jest.fn((x) => x),
      save: jest.fn((x) => Promise.resolve(x)),
      find: jest.fn().mockResolvedValue([]),
      findOne: jest.fn(),
    };
    service = new BuyerProfileService(repo);
  });

  describe('computeReliability', () => {
    it('returns null (unknown), NOT 100%, for a buyer with no history at all', () => {
      // The distinction that matters: a brand-new buyer is unproven, not
      // perfect. Showing "100% reliable" for zero deals would actively
      // mislead the farmer deciding whether to wait for them.
      const result = service.computeReliability({ ...baseProfile } as any);
      expect(result.onTimeRate).toBeNull();
      expect(result.completedDeals).toBe(0);
      expect(result.noShows).toBe(0);
    });

    it('computes an on-time rate from completed deals versus no-shows', () => {
      const result = service.computeReliability({
        ...baseProfile,
        completedDealsCount: 9,
        noShowCount: 1,
      } as any);
      expect(result.onTimeRate).toBe(90);
    });

    it('reports 0% for a buyer who has only ever failed to show', () => {
      const result = service.computeReliability({
        ...baseProfile,
        completedDealsCount: 0,
        noShowCount: 3,
      } as any);
      expect(result.onTimeRate).toBe(0);
    });

    it('rounds to one decimal place rather than emitting a long float', () => {
      // 2/3 = 66.666... — must not surface as 66.66666666666667
      const result = service.computeReliability({
        ...baseProfile,
        completedDealsCount: 2,
        noShowCount: 1,
      } as any);
      expect(result.onTimeRate).toBe(66.7);
    });
  });

  describe('updateOwnProfile', () => {
    it('withdraws VERIFIED status when the buyer changes their tier', async () => {
      // Verification was granted on the basis of being one kind of
      // business. Silently keeping the badge across a tier change would
      // let a buyer verified as a cooperative re-present as a collector
      // while still showing the badge a farmer is trusting.
      repo.findOne.mockResolvedValue({
        ...baseProfile,
        verificationStatus: VerificationStatus.VERIFIED,
      });

      const result = await service.updateOwnProfile('user-1', {
        tier: BuyerTier.LOCAL_COLLECTOR,
      } as any);

      expect(result.tier).toBe(BuyerTier.LOCAL_COLLECTOR);
      expect(result.verificationStatus).toBe(VerificationStatus.PENDING);
    });

    it('leaves verification untouched when the tier is set to its existing value', async () => {
      repo.findOne.mockResolvedValue({
        ...baseProfile,
        verificationStatus: VerificationStatus.VERIFIED,
      });

      const result = await service.updateOwnProfile('user-1', {
        tier: BuyerTier.CITY_MERCHANT, // same as current
        businessName: 'Renamed Traders',
      } as any);

      expect(result.verificationStatus).toBe(VerificationStatus.VERIFIED);
      expect(result.businessName).toBe('Renamed Traders');
    });

    it('does not "downgrade" an unverified buyer to pending on a tier change', async () => {
      repo.findOne.mockResolvedValue({ ...baseProfile });

      const result = await service.updateOwnProfile('user-1', {
        tier: BuyerTier.LOCAL_COLLECTOR,
      } as any);

      expect(result.verificationStatus).toBe(VerificationStatus.UNVERIFIED);
    });

    it('throws NotFoundException when the user has no buyer profile', async () => {
      repo.findOne.mockResolvedValue(null);
      await expect(
        service.updateOwnProfile('nobody', { businessName: 'X' } as any),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('setVerificationStatus', () => {
    it('sets the status on an existing profile', async () => {
      repo.findOne.mockResolvedValue({ ...baseProfile });
      const result = await service.setVerificationStatus(
        'profile-1',
        VerificationStatus.VERIFIED,
      );
      expect(result.verificationStatus).toBe(VerificationStatus.VERIFIED);
    });

    it('throws for a nonexistent profile rather than silently no-opping', async () => {
      repo.findOne.mockResolvedValue(null);
      await expect(
        service.setVerificationStatus('missing', VerificationStatus.VERIFIED),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
