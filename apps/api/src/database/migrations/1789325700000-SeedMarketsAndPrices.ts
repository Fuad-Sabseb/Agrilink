import { MigrationInterface, QueryRunner } from 'typeorm';
import { randomUUID } from 'crypto';

/**
 * Seeds the Stage-1 market list (proposal §9: "Jimma town plus 2–4 nearby
 * major secondary markets (e.g., Nekemte and Agaro as reference points,
 * to be confirmed in Phase 0 field research)") and a small set of demo
 * price observations so Phase 12's endpoints have something to return.
 *
 * Every price row here uses source = 'demo' — never presented as real
 * observed pricing (proposal rule 4: "do not fabricate market prices").
 * Potato figures reuse the proposal's own worked example (§8: Jimma 25,
 * Nekemte 28 ETB/kg) rather than inventing new numbers for the one crop
 * the proposal already gives concrete figures for. Every other
 * crop/market combination is a plausible round demo number, not a claim
 * about real prices anywhere.
 */
export class SeedMarketsAndPrices1789325700000 implements MigrationInterface {
  name = 'SeedMarketsAndPrices1789325700000';

  private readonly markets = [
    { name: 'Jimma Town Market', zone: 'Jimma Zone', woreda: 'Jimma Town', lat: 7.673, lng: 36.834 },
    { name: 'Nekemte Market', zone: 'East Wollega Zone', woreda: 'Nekemte Town', lat: 9.088, lng: 36.53 },
    { name: 'Agaro Market', zone: 'Jimma Zone', woreda: 'Agaro Town', lat: 7.85, lng: 36.583 },
  ];

  // ETB/kg, demo only. potato figures match the proposal's own §8 worked
  // example for Jimma/Nekemte; Agaro and every other crop are plausible
  // round demo numbers, not sourced from the proposal.
  private readonly demoPrices: Record<string, [number, number, number]> = {
    // [Jimma, Nekemte, Agaro]
    potato: [25, 28, 26],
    maize: [12, 13.5, 12.5],
    teff: [55, 58, 54],
    wheat: [22, 24, 21.5],
    coffee: [180, 175, 185],
  };

  public async up(queryRunner: QueryRunner): Promise<void> {
    const marketIds: string[] = [];
    for (const market of this.markets) {
      const id = randomUUID();
      marketIds.push(id);
      await queryRunner.query(
        `INSERT INTO \`markets\` (\`id\`, \`name\`, \`zone\`, \`woreda\`, \`latitude\`, \`longitude\`, \`is_active\`)
         VALUES (?, ?, ?, ?, ?, ?, 1)`,
        [id, market.name, market.zone, market.woreda, market.lat, market.lng],
      );
    }

    const cropRows: { id: string; slug: string }[] = await queryRunner.query(
      `SELECT id, slug FROM crops WHERE slug IN (?, ?, ?, ?, ?)`,
      Object.keys(this.demoPrices),
    );

    const today = new Date().toISOString().slice(0, 10);

    for (const cropRow of cropRows) {
      const prices = this.demoPrices[cropRow.slug];
      for (let i = 0; i < this.markets.length; i++) {
        await queryRunner.query(
          `INSERT INTO \`market_prices\`
             (\`id\`, \`market_id\`, \`crop_id\`, \`price_per_kg_cents\`, \`grade\`, \`observation_date\`, \`source\`)
           VALUES (?, ?, ?, ?, 'standard', ?, 'demo')`,
          [randomUUID(), marketIds[i], cropRow.id, Math.round(prices[i] * 100), today],
        );
      }
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DELETE FROM \`market_prices\` WHERE \`source\` = 'demo'`);
    await queryRunner.query(
      `DELETE FROM \`markets\` WHERE \`name\` IN (?, ?, ?)`,
      this.markets.map((m) => m.name),
    );
  }
}
