import { MigrationInterface, QueryRunner } from 'typeorm';
import { randomUUID } from 'crypto';

/**
 * Adds historical demo price points (14/28/42/56/70 days before the
 * Day 6 seed's "today" observations) so Phase 14's history/trend endpoint
 * has something real to chart. Without this, GET /market-prices/history
 * would always return a single point and every trend would report
 * "insufficient_data" — correct behavior, but nothing to demonstrate the
 * feature with.
 *
 * All rows are source = 'demo' — same rule as the Day 6 seed (proposal
 * rule 4: never present fabricated numbers as real observed prices). The
 * per-point variation factors are a fixed, deterministic small wobble
 * around the Day 6 "today" price, not a claim about real historical
 * market movements in Jimma Zone.
 */
export class SeedHistoricalPrices1789400000000 implements MigrationInterface {
  name = 'SeedHistoricalPrices1789400000000';

  private readonly marketNames = ['Jimma Town Market', 'Nekemte Market', 'Agaro Market'];

  // Same "today" ETB/kg figures as the Day 6 seed (SeedMarketsAndPrices),
  // duplicated here rather than imported — migrations are meant to be
  // read and run standalone, years after the code that generated them
  // might have changed; importing another migration's private data would
  // couple two files that should each be a frozen, self-contained record
  // of what they did.
  private readonly currentPrices: Record<string, [number, number, number]> = {
    potato: [25, 28, 26],
    maize: [12, 13.5, 12.5],
    teff: [55, 58, 54],
    wheat: [22, 24, 21.5],
    coffee: [180, 175, 185],
  };

  // Index 0 = 14 days ago (closest to "today"), index 4 = 70 days ago.
  // A small, deterministic wobble — not random, so this migration
  // produces the same data every time it's read even though it only ever
  // runs once against a given database.
  private readonly historicalFactors = [0.97, 1.03, 0.95, 1.05, 0.98];

  public async up(queryRunner: QueryRunner): Promise<void> {
    const markets: { id: string; name: string }[] = await queryRunner.query(
      `SELECT id, name FROM markets WHERE name IN (?, ?, ?)`,
      this.marketNames,
    );
    const marketIdByName = new Map(markets.map((m) => [m.name, m.id]));

    const crops: { id: string; slug: string }[] = await queryRunner.query(
      `SELECT id, slug FROM crops WHERE slug IN (?, ?, ?, ?, ?)`,
      Object.keys(this.currentPrices),
    );

    for (const crop of crops) {
      const currentByMarketIndex = this.currentPrices[crop.slug];
      for (let m = 0; m < this.marketNames.length; m++) {
        const marketId = marketIdByName.get(this.marketNames[m]);
        if (!marketId) continue;
        const basePrice = currentByMarketIndex[m];

        for (let i = 0; i < this.historicalFactors.length; i++) {
          const daysAgo = 14 * (i + 1);
          const date = new Date();
          date.setDate(date.getDate() - daysAgo);
          const observationDate = date.toISOString().slice(0, 10);
          const price = Math.round(basePrice * this.historicalFactors[i] * 100) / 100;

          await queryRunner.query(
            `INSERT INTO \`market_prices\`
               (\`id\`, \`market_id\`, \`crop_id\`, \`price_per_kg_cents\`, \`grade\`, \`observation_date\`, \`source\`)
             VALUES (?, ?, ?, ?, 'standard', ?, 'demo')`,
            [randomUUID(), marketId, crop.id, Math.round(price * 100), observationDate],
          );
        }
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Scoped deletion: only demo rows that are NOT today's date, so this
    // rollback can't accidentally remove the Day 6 seed's "current price"
    // rows (which share the same source='demo' tag but a different date).
    await queryRunner.query(
      `DELETE FROM \`market_prices\` WHERE \`source\` = 'demo' AND \`observation_date\` <> CURDATE()`,
    );
  }
}
