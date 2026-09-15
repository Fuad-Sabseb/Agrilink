import { MigrationInterface, QueryRunner } from "typeorm";

export class TransportCostRules1789451497133 implements MigrationInterface {
    name = 'TransportCostRules1789451497133'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE \`transport_cost_rules\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`origin_zone\` varchar(100) NOT NULL, \`market_id\` varchar(255) NOT NULL, \`distance_km\` decimal(8,2) NOT NULL, \`rate_per_kg_per_km\` decimal(10,4) NOT NULL, \`transit_fee_cents\` int NOT NULL DEFAULT '0', \`is_active\` tinyint NOT NULL DEFAULT 1, UNIQUE INDEX \`IDX_df0ea86e0a3ea4e0e8917fa58e\` (\`origin_zone\`, \`market_id\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`markets\` CHANGE \`kebele\` \`kebele\` varchar(100) NULL`);
        await queryRunner.query(`ALTER TABLE \`markets\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`markets\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`zone\` \`zone\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`woreda\` \`woreda\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`cooperative_name\` \`cooperative_name\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`expected_yield_kg\` \`expected_yield_kg\` decimal(10,2) NULL`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_start\` \`harvest_start\` date NULL`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_end\` \`harvest_end\` date NULL`);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL`);
        await queryRunner.query(`ALTER TABLE \`transport_cost_rules\` ADD CONSTRAINT \`FK_da2440922ff7d27a737ce1584d9\` FOREIGN KEY (\`market_id\`) REFERENCES \`markets\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE \`transport_cost_rules\` DROP FOREIGN KEY \`FK_da2440922ff7d27a737ce1584d9\``);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_end\` \`harvest_end\` date NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_start\` \`harvest_start\` date NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`expected_yield_kg\` \`expected_yield_kg\` decimal(10,2) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`cooperative_name\` \`cooperative_name\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`woreda\` \`woreda\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`zone\` \`zone\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`markets\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`markets\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`markets\` CHANGE \`kebele\` \`kebele\` varchar(100) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`DROP INDEX \`IDX_df0ea86e0a3ea4e0e8917fa58e\` ON \`transport_cost_rules\``);
        await queryRunner.query(`DROP TABLE \`transport_cost_rules\``);
    }

}
