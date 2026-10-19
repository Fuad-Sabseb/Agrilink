import { MigrationInterface, QueryRunner } from 'typeorm';
import { randomUUID } from 'crypto';

/**
 * Seeds transport cost rules from "Jimma Zone" (the origin every seeded
 * farmer profile/farm uses so far) to each of the 3 seeded markets, so
 * the recommendation engine (Phase 16) has real routes to compute against
 * out of the box.
 *
 * The rate (0.0138 ETB/kg/km) and flat transit fee (1,620 ETB) are
 * DERIVED, not arbitrary: solving transportCost = distance × rate ×
 * quantity + fee for the two data points the proposal's own §8 worked
 * example gives —
 *   Jimma:   20 km, 5,000 kg → 3,000 ETB transport cost
 *   Nekemte: 150 km, 5,000 kg → 12,000 ETB transport cost
 * — as two equations in two unknowns reproduces the proposal's Jimma
 * figure exactly and its Nekemte figure within 30 ETB (a rounding
 * artifact of picking clean-ish seed constants, not a calculation error).
 * Agaro has no proposal figure to match; 50 km is an approximate
 * real-world road distance from Jimma to Agaro, and the same rate/fee
 * formula is applied to it for consistency — a plausible reference
 * figure, not a verified one, same as every other piece of demo data
 * seeded in this build (proposal rule 5: demo data must be clearly
 * distinguished — there is no `source` column on this table the way
 * there is on MarketPrice, so this is disclosed here in the migration
 * itself and in PROGRESS.md rather than in the data).
 */
export class SeedTransportCostRules1789451600000 implements MigrationInterface {
  name = 'SeedTransportCostRules1789451600000';

  private readonly originZone = 'Jimma Zone';
  private readonly rateEtbPerKgPerKm = 0.0138;
  private readonly transitFeeEtb = 1620;

  private readonly routes: { marketName: string; distanceKm: number }[] = [
    { marketName: 'Jimma Town Market', distanceKm: 20 },
    { marketName: 'Nekemte Market', distanceKm: 150 },
    { marketName: 'Agaro Market', distanceKm: 50 },
  ];

  public async up(queryRunner: QueryRunner): Promise<void> {
    for (const route of this.routes) {
      const [market] = await queryRunner.query(
        `SELECT id FROM markets WHERE name = ? LIMIT 1`,
        [route.marketName],
      );
      if (!market) continue;

      await queryRunner.query(
        `INSERT INTO \`transport_cost_rules\`
           (\`id\`, \`origin_zone\`, \`market_id\`, \`distance_km\`, \`rate_per_kg_per_km\`, \`transit_fee_cents\`, \`is_active\`)
         VALUES (?, ?, ?, ?, ?, ?, 1)`,
        [
          randomUUID(),
          this.originZone,
          market.id,
          route.distanceKm.toFixed(2),
          this.rateEtbPerKgPerKm.toFixed(4),
          Math.round(this.transitFeeEtb * 100),
        ],
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DELETE FROM \`transport_cost_rules\` WHERE \`origin_zone\` = ?`,
      [this.originZone],
    );
  }
}
