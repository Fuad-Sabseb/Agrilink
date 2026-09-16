import { RecommendationService } from '../recommendation.service';

describe('RecommendationService', () => {
  let farmsService: any;
  let cropsService: any;
  let marketPricesService: any;
  let transportCostRulesService: any;
  let service: RecommendationService;

  const farm = { id: 'farm-1', name: 'North plot', zone: 'Jimma Zone' };
  const crop = { id: 'crop-1', name: 'Potato' };

  const jimmaMarket = { id: 'market-jimma', name: 'Jimma Town Market' };
  const nekemteMarket = { id: 'market-nekemte', name: 'Nekemte Market' };
  const agaroMarket = { id: 'market-agaro', name: 'Agaro Market' };

  beforeEach(() => {
    farmsService = { findOneOwnedBy: jest.fn().mockResolvedValue(farm) };
    cropsService = { getActiveOrThrow: jest.fn().mockResolvedValue(crop) };
    marketPricesService = { findLatestPerMarket: jest.fn() };
    transportCostRulesService = { findActiveForZone: jest.fn() };
    service = new RecommendationService(
      farmsService,
      cropsService,
      marketPricesService,
      transportCostRulesService,
    );
  });

  it("reproduces the proposal's own §8 worked example for 5,000 kg of potatoes (Jimma vs Nekemte)", async () => {
    // Proposal Table 2: Jimma 25 ETB/kg, 20km, transport 3,000 ETB, net 122,000 ETB
    //                   Nekemte 28 ETB/kg, 150km, transport 12,000 ETB, net 128,000 ETB
    // Seeded rate/fee (0.0138 ETB/kg/km, 1,620 ETB flat) reproduces Jimma's
    // transport cost exactly and Nekemte's within the documented ~30 ETB
    // rounding tolerance — asserted here against that same tolerance, not
    // exact equality, so this test reflects the real seeded data rather
    // than silently re-deriving numbers that happen to make it pass.
    marketPricesService.findLatestPerMarket.mockResolvedValue([
      { market: jimmaMarket, pricePerKg: '25.00', freshness: 'demo', source: 'demo', observationDate: '2026-09-01' },
      { market: nekemteMarket, pricePerKg: '28.00', freshness: 'demo', source: 'demo', observationDate: '2026-09-01' },
    ]);
    transportCostRulesService.findActiveForZone.mockResolvedValue([
      { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.0138', transitFeeCents: 162000 },
      { marketId: 'market-nekemte', market: nekemteMarket, distanceKm: '150.00', ratePerKgPerKm: '0.0138', transitFeeCents: 162000 },
    ]);

    const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 5000);

    const jimma = result.candidates.find((c) => c.market.id === 'market-jimma')!;
    const nekemte = result.candidates.find((c) => c.market.id === 'market-nekemte')!;

    expect(jimma.grossRevenue).toBe('125000.00'); // 25 * 5000
    // The proposal's single "Est. Transport Cost" column (3,000 ETB) is
    // this build's transportCost + transitFee combined (totalCost) — the
    // proposal doesn't split those two components, this build does, for
    // explainability (proposal rule 11). transportCost alone (the
    // distance × rate × quantity component, before the flat transit fee)
    // is correctly a smaller number, 1,380 ETB, not the proposal figure.
    expect(jimma.transportCost).toBe('1380.00'); // distance-based component only
    expect(jimma.totalCost).toBe('3000.00'); // matches the proposal's Table 2 exactly
    expect(jimma.netRevenue).toBe('122000.00'); // matches proposal exactly

    expect(nekemte.grossRevenue).toBe('140000.00'); // 28 * 5000
    expect(Number(nekemte.totalCost)).toBeCloseTo(11970, 0); // proposal: 12000
    expect(Number(nekemte.netRevenue)).toBeCloseTo(128030, 0); // proposal: 128000

    // The core point of the flagship feature: Nekemte's lower headline
    // price still wins on net revenue once transport is subtracted.
    expect(nekemte.netRevenue > jimma.netRevenue).toBe(true);
    expect(nekemte.isRecommended).toBe(true);
    expect(jimma.isRecommended).toBe(false);
  });

  it('ranks candidates by net revenue descending, not by price or by input order', async () => {
    marketPricesService.findLatestPerMarket.mockResolvedValue([
      { market: jimmaMarket, pricePerKg: '20.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      { market: nekemteMarket, pricePerKg: '30.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      { market: agaroMarket, pricePerKg: '22.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
    ]);
    transportCostRulesService.findActiveForZone.mockResolvedValue([
      { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '5.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
      // Nekemte has the highest price but a huge transport cost, so it
      // should NOT win despite having the highest gross revenue.
      { marketId: 'market-nekemte', market: nekemteMarket, distanceKm: '300.00', ratePerKgPerKm: '0.05', transitFeeCents: 500000 },
      { marketId: 'market-agaro', market: agaroMarket, distanceKm: '50.00', ratePerKgPerKm: '0.01', transitFeeCents: 20000 },
    ]);

    const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 1000);

    expect(result.candidates.map((c) => c.market.id)).toEqual([
      'market-agaro', // best net despite not having the highest price
      'market-jimma',
      'market-nekemte', // highest price, worst net
    ]);
    expect(result.candidates[0].isRecommended).toBe(true);
  });

  it('excludes a market with a price but no configured transport route, with the correct reason', async () => {
    marketPricesService.findLatestPerMarket.mockResolvedValue([
      { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      { market: agaroMarket, pricePerKg: '24.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
    ]);
    // Only a route to Jimma is configured — Agaro has a price but no route.
    transportCostRulesService.findActiveForZone.mockResolvedValue([
      { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
    ]);

    const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);

    expect(result.candidates).toHaveLength(1);
    expect(result.candidates[0].market.id).toBe('market-jimma');
    expect(result.excluded).toEqual([
      { market: agaroMarket, reason: 'no_transport_route_configured' },
    ]);
  });

  it('excludes a market with a configured route but no price data, with the correct reason', async () => {
    // Only Jimma has a price at all; Nekemte has a route configured but
    // no price observation was ever recorded for this crop there.
    marketPricesService.findLatestPerMarket.mockResolvedValue([
      { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
    ]);
    transportCostRulesService.findActiveForZone.mockResolvedValue([
      { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
      { marketId: 'market-nekemte', market: nekemteMarket, distanceKm: '150.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
    ]);

    const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);

    expect(result.candidates).toHaveLength(1);
    expect(result.excluded).toEqual([{ market: nekemteMarket, reason: 'no_price_data' }]);
  });

  it('returns an empty candidate list (not an error) when no market has both price and route', async () => {
    marketPricesService.findLatestPerMarket.mockResolvedValue([
      { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
    ]);
    transportCostRulesService.findActiveForZone.mockResolvedValue([]); // no routes at all

    const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);

    expect(result.candidates).toEqual([]);
    expect(result.excluded).toEqual([
      { market: jimmaMarket, reason: 'no_transport_route_configured' },
    ]);
  });

  it('flags a candidate as a loss when transport cost exceeds gross revenue', async () => {
    marketPricesService.findLatestPerMarket.mockResolvedValue([
      { market: jimmaMarket, pricePerKg: '5.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
    ]);
    transportCostRulesService.findActiveForZone.mockResolvedValue([
      // Deliberately expensive relative to a tiny quantity/price, so
      // transport cost alone exceeds gross revenue.
      { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '500.00', ratePerKgPerKm: '0.5', transitFeeCents: 1000000 },
    ]);

    const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 10);

    expect(result.candidates[0].isLoss).toBe(true);
    expect(Number(result.candidates[0].netRevenue)).toBeLessThan(0);
  });

  it('propagates a NotFoundException when the farm is not owned by the caller', async () => {
    farmsService.findOneOwnedBy.mockRejectedValue(new Error('Farm not found'));
    await expect(
      service.getRecommendation('someone-else', 'farm-1', 'crop-1', 100),
    ).rejects.toThrow('Farm not found');
    expect(cropsService.getActiveOrThrow).not.toHaveBeenCalled();
  });

  it('propagates rejection for an inactive or nonexistent crop', async () => {
    cropsService.getActiveOrThrow.mockRejectedValue(new Error('Crop not found'));
    await expect(
      service.getRecommendation('farmer-1', 'farm-1', 'bad-crop', 100),
    ).rejects.toThrow('Crop not found');
  });

  // ---- Phase 17 additions ----

  describe('tie handling', () => {
    it('flags two markets with identical net revenue as tied, rather than implying one beat the other', async () => {
      // Two markets engineered to produce exactly the same net revenue:
      // same price, same distance, same rate, same fee.
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
        { market: agaroMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
        { marketId: 'market-agaro', market: agaroMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 1000);

      expect(result.candidates).toHaveLength(2);
      expect(result.candidates[0].netRevenue).toBe(result.candidates[1].netRevenue);
      // Exactly one is still marked recommended (the UI needs a primary),
      // but BOTH are flagged as tied so it can say so honestly.
      expect(result.candidates.filter((c) => c.isRecommended)).toHaveLength(1);
      expect(result.candidates[0].isTiedWithBest).toBe(true);
      expect(result.candidates[1].isTiedWithBest).toBe(true);
    });

    it('does not flag a clearly-better market as tied', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
        { market: agaroMarket, pricePerKg: '15.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
        { marketId: 'market-agaro', market: agaroMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 10000 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 1000);

      expect(result.candidates[0].isTiedWithBest).toBe(true); // the best always ties itself
      expect(result.candidates[1].isTiedWithBest).toBe(false);
    });
  });

  describe('margin over runner-up', () => {
    it('reports how much better each candidate is than the next one down, and null for the last', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '30.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
        { market: agaroMarket, pricePerKg: '20.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '10.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
        { marketId: 'market-agaro', market: agaroMarket, distanceKm: '10.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);

      // Both have identical transport cost, so the gap is purely the
      // price difference: (30 - 20) * 100 kg = 1000 ETB.
      expect(result.candidates[0].advantageOverNext).toBe('1000.00');
      expect(result.candidates[1].advantageOverNext).toBeNull();
    });
  });

  describe('per-kg economics', () => {
    it('reports net revenue per kg so results are comparable across quantities', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '100.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 1000);

      // gross = 25 * 1000 = 25,000; transport = 100 * 0.01 * 1000 = 1,000
      // net = 24,000 over 1,000 kg = 24.00/kg
      expect(result.candidates[0].netRevenue).toBe('24000.00');
      expect(result.candidates[0].netRevenuePerKg).toBe('24.00');
    });
  });

  describe('data-quality warnings', () => {
    it('warns when any price used is stale', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'stale', source: 'admin_manual', observationDate: '2026-01-01' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);
      expect(result.warnings).toContain('stale_prices_used');
    });

    it('warns when demo data is used, so a result is never mistaken for real market intelligence', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'demo', source: 'demo', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);
      expect(result.warnings).toContain('demo_prices_used');
    });

    it('warns when EVERY available market would lose money, not just the top one', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '1.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
        { market: agaroMarket, pricePerKg: '1.50', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '100.00', ratePerKgPerKm: '0.5', transitFeeCents: 500000 },
        { marketId: 'market-agaro', market: agaroMarket, distanceKm: '100.00', ratePerKgPerKm: '0.5', transitFeeCents: 500000 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 10);

      expect(result.candidates.every((c) => c.isLoss)).toBe(true);
      expect(result.warnings).toContain('all_markets_are_loss');
    });

    it('does NOT warn all_markets_are_loss when at least one market is profitable', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
        { market: agaroMarket, pricePerKg: '1.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '10.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
        { marketId: 'market-agaro', market: agaroMarket, distanceKm: '100.00', ratePerKgPerKm: '0.5', transitFeeCents: 500000 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);
      expect(result.warnings).not.toContain('all_markets_are_loss');
    });

    it('flags a close call when the winner barely beats the runner-up', async () => {
      // ~0.4% of gross revenue apart — a real but thin margin.
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
        { market: agaroMarket, pricePerKg: '24.90', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '10.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
        { marketId: 'market-agaro', market: agaroMarket, distanceKm: '10.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 1000);
      expect(result.warnings).toContain('close_call');
    });

    it('does not double up close_call on top of a tie — a tie is already its own signal', async () => {
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        { market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
        { market: agaroMarket, pricePerKg: '25.00', freshness: 'verified', source: 'admin_manual', observationDate: '2026-09-10' },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '10.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
        { marketId: 'market-agaro', market: agaroMarket, distanceKm: '10.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 1000);
      expect(result.candidates[1].isTiedWithBest).toBe(true);
      expect(result.warnings).not.toContain('close_call');
    });
  });

  describe('source and timestamp transparency', () => {
    it('stamps the calculation time and each price observation age in days', async () => {
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
      marketPricesService.findLatestPerMarket.mockResolvedValue([
        {
          market: jimmaMarket, pricePerKg: '25.00', freshness: 'verified',
          source: 'admin_manual', observationDate: threeDaysAgo.toISOString().slice(0, 10),
        },
      ]);
      transportCostRulesService.findActiveForZone.mockResolvedValue([
        { marketId: 'market-jimma', market: jimmaMarket, distanceKm: '20.00', ratePerKgPerKm: '0.01', transitFeeCents: 0 },
      ]);

      const result = await service.getRecommendation('farmer-1', 'farm-1', 'crop-1', 100);

      expect(result.calculatedAt).toBeDefined();
      expect(new Date(result.calculatedAt).getTime()).toBeLessThanOrEqual(Date.now());
      expect(result.candidates[0].priceAgeDays).toBe(3);
      expect(result.candidates[0].priceSource).toBe('admin_manual');
    });
  });
});
