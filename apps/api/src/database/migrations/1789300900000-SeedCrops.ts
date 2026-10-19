import { MigrationInterface, QueryRunner } from 'typeorm';
import { randomUUID } from 'crypto';

/**
 * Seeds the crop catalog. Kept as its own migration, separate from the
 * schema migration that creates the `crops` table — schema and reference
 * data are different kinds of change (one is structural, one is content),
 * and separating them means a future re-seed or data fix doesn't need to
 * touch the table definition.
 *
 * Crop list and the active/inactive split: see the doc comment on
 * Crop entity (crops/entities/crop.entity.ts) — the proposal's own §9
 * text is internally inconsistent about whether Stage 1 has five or seven
 * crops. Five storable crops ship active; tomato and carrot are seeded
 * present-but-inactive, matching the proposal's own hedge that they're
 * "provisional" pending field validation the proposal describes as
 * happening in Phase 0 (a real-world research activity, not something a
 * schema decision can substitute for).
 */
export class SeedCrops1789300900000 implements MigrationInterface {
  name = 'SeedCrops1789300900000';

  private readonly crops: {
    slug: string;
    name: string;
    isPerishable: boolean;
    isActive: boolean;
  }[] = [
    { slug: 'maize', name: 'Maize', isPerishable: false, isActive: true },
    { slug: 'teff', name: 'Teff', isPerishable: false, isActive: true },
    { slug: 'wheat', name: 'Wheat', isPerishable: false, isActive: true },
    { slug: 'potato', name: 'Potato', isPerishable: false, isActive: true },
    { slug: 'coffee', name: 'Coffee', isPerishable: false, isActive: true },
    { slug: 'tomato', name: 'Tomato', isPerishable: true, isActive: false },
    { slug: 'carrot', name: 'Carrot', isPerishable: true, isActive: false },
  ];

  public async up(queryRunner: QueryRunner): Promise<void> {
    for (const crop of this.crops) {
      await queryRunner.query(
        `INSERT INTO \`crops\` (\`id\`, \`slug\`, \`name\`, \`is_perishable\`, \`is_active\`)
         VALUES (?, ?, ?, ?, ?)`,
        [randomUUID(), crop.slug, crop.name, crop.isPerishable, crop.isActive],
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DELETE FROM \`crops\` WHERE \`slug\` IN (?, ?, ?, ?, ?, ?, ?)`,
      this.crops.map((c) => c.slug),
    );
  }
}
