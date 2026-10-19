import { MigrationInterface, QueryRunner } from "typeorm";

export class MarketsAndPrices1789325632057 implements MigrationInterface {
    name = 'MarketsAndPrices1789325632057'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE \`markets\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`name\` varchar(150) NOT NULL, \`zone\` varchar(100) NOT NULL, \`woreda\` varchar(100) NOT NULL, \`kebele\` varchar(100) NULL, \`latitude\` decimal(9,6) NULL, \`longitude\` decimal(9,6) NULL, \`is_active\` tinyint NOT NULL DEFAULT 1, PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`market_prices\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`market_id\` varchar(255) NOT NULL, \`crop_id\` varchar(255) NOT NULL, \`price_per_kg_cents\` int NOT NULL, \`grade\` varchar(30) NOT NULL DEFAULT 'standard', \`observation_date\` date NOT NULL, \`source\` enum ('admin_manual', 'demo') NOT NULL DEFAULT 'admin_manual', INDEX \`IDX_94bd73e76c3493d0d2709071e6\` (\`market_id\`), INDEX \`IDX_c9d72defda50e215db6b3e241e\` (\`crop_id\`), INDEX \`IDX_e799fce9effc787e262ad1fd6c\` (\`observation_date\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`zone\` \`zone\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`woreda\` \`woreda\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`cooperative_name\` \`cooperative_name\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`expected_yield_kg\` \`expected_yield_kg\` decimal(10,2) NULL`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_start\` \`harvest_start\` date NULL`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_end\` \`harvest_end\` date NULL`);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL`);
        await queryRunner.query(`ALTER TABLE \`market_prices\` ADD CONSTRAINT \`FK_94bd73e76c3493d0d2709071e65\` FOREIGN KEY (\`market_id\`) REFERENCES \`markets\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE \`market_prices\` ADD CONSTRAINT \`FK_c9d72defda50e215db6b3e241ec\` FOREIGN KEY (\`crop_id\`) REFERENCES \`crops\`(\`id\`) ON DELETE RESTRICT ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE \`market_prices\` DROP FOREIGN KEY \`FK_c9d72defda50e215db6b3e241ec\``);
        await queryRunner.query(`ALTER TABLE \`market_prices\` DROP FOREIGN KEY \`FK_94bd73e76c3493d0d2709071e65\``);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_end\` \`harvest_end\` date NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`harvest_start\` \`harvest_start\` date NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farm_crop_records\` CHANGE \`expected_yield_kg\` \`expected_yield_kg\` decimal(10,2) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`cooperative_name\` \`cooperative_name\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`woreda\` \`woreda\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` CHANGE \`zone\` \`zone\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`longitude\` \`longitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`latitude\` \`latitude\` decimal(9,6) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`farms\` CHANGE \`kebele\` \`kebele\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`DROP INDEX \`IDX_e799fce9effc787e262ad1fd6c\` ON \`market_prices\``);
        await queryRunner.query(`DROP INDEX \`IDX_c9d72defda50e215db6b3e241e\` ON \`market_prices\``);
        await queryRunner.query(`DROP INDEX \`IDX_94bd73e76c3493d0d2709071e6\` ON \`market_prices\``);
        await queryRunner.query(`DROP TABLE \`market_prices\``);
        await queryRunner.query(`DROP TABLE \`markets\``);
    }

}
