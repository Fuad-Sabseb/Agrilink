import { MigrationInterface, QueryRunner } from "typeorm";

export class CropsAndFarmCropRecords1789300774899 implements MigrationInterface {
    name = 'CropsAndFarmCropRecords1789300774899'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE \`crops\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`slug\` varchar(50) NOT NULL, \`name\` varchar(100) NOT NULL, \`is_perishable\` tinyint NOT NULL DEFAULT 0, \`is_active\` tinyint NOT NULL DEFAULT 1, UNIQUE INDEX \`IDX_944136fc2f96bbc5b2ff8197ed\` (\`slug\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`farm_crop_records\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`farm_id\` varchar(255) NOT NULL, \`crop_id\` varchar(255) NOT NULL, \`area_hectares\` decimal(8,2) NOT NULL, \`expected_yield_kg\` decimal(10,2) NULL, \`harvest_start\` date NULL, \`harvest_end\` date NULL, INDEX \`IDX_bbc194fe04b2e28f45c15beaa4\` (\`farm_id\`), INDEX \`IDX_a5a05fbc9853a023facb1ef0a1\` (\`crop_id\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`zone\` \`zone\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`woreda\` \`woreda\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`cooperative_name\` \`cooperative_name\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` ADD CONSTRAINT \`FK_bbc194fe04b2e28f45c15beaa48\` FOREIGN KEY (\`farm_id\`) REFERENCES \`farms\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` ADD CONSTRAINT \`FK_a5a05fbc9853a023facb1ef0a16\` FOREIGN KEY (\`crop_id\`) REFERENCES \`crops\`(\`id\`) ON DELETE RESTRICT ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` DROP FOREIGN KEY \`FK_a5a05fbc9853a023facb1ef0a16\``);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` DROP FOREIGN KEY \`FK_bbc194fe04b2e28f45c15beaa48\``);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`cooperative_name\` \`cooperative_name\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`woreda\` \`woreda\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`zone\` \`zone\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`DROP INDEX \`IDX_a5a05fbc9853a023facb1ef0a1\` ON \`farm_crop_records\``);
        await queryRunner.query(`DROP INDEX \`IDX_bbc194fe04b2e28f45c15beaa4\` ON \`farm_crop_records\``);
        await queryRunner.query(`DROP TABLE \`farm_crop_records\``);
        await queryRunner.query(`DROP INDEX \`IDX_944136fc2f96bbc5b2ff8197ed\` ON \`crops\``);
        await queryRunner.query(`DROP TABLE \`crops\``);
    }

}
