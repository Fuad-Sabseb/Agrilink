import { MigrationInterface, QueryRunner } from "typeorm";

export class BuyerProfilesAndDemands1789558538981 implements MigrationInterface {
    name = 'BuyerProfilesAndDemands1789558538981'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE \`buyer_profiles\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`user_id\` varchar(255) NOT NULL, \`business_name\` varchar(255) NULL, \`tier\` enum ('local_collector', 'city_merchant', 'cooperative') NOT NULL DEFAULT 'city_merchant', \`zone\` varchar(255) NULL, \`woreda\` varchar(255) NULL, \`kebele\` varchar(255) NULL, \`verification_status\` enum ('unverified', 'pending', 'verified', 'rejected') NOT NULL DEFAULT 'unverified', \`disclosed_fee_basis_points\` int NULL, \`completed_deals_count\` int NOT NULL DEFAULT '0', \`no_show_count\` int NOT NULL DEFAULT '0', UNIQUE INDEX \`IDX_8ef06dd95facdc3db875b449ba\` (\`user_id\`), UNIQUE INDEX \`REL_8ef06dd95facdc3db875b449ba\` (\`user_id\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`buyer_demands\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`buyer_profile_id\` varchar(255) NOT NULL, \`crop_id\` varchar(255) NOT NULL, \`quantity_kg\` decimal(12,2) NOT NULL, \`offer_price_per_kg_cents\` int NULL, \`grade\` varchar(30) NOT NULL DEFAULT 'standard', \`delivery_zone\` varchar(255) NULL, \`delivery_woreda\` varchar(255) NULL, \`status\` enum ('draft', 'buying_now', 'paused', 'closed') NOT NULL DEFAULT 'draft', \`needed_by\` date NULL, \`notes\` text NULL, INDEX \`IDX_dce5a1e8e5ca760ba7b2076339\` (\`buyer_profile_id\`), INDEX \`IDX_dda770f320bd4fbe4677cc869d\` (\`crop_id\`), INDEX \`IDX_f3942d232fef6cbd28426ab134\` (\`status\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
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
        await queryRunner.query(`ALTER TABLE \`buyer_profiles\` ADD CONSTRAINT \`FK_8ef06dd95facdc3db875b449baf\` FOREIGN KEY (\`user_id\`) REFERENCES \`users\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE \`buyer_demands\` ADD CONSTRAINT \`FK_dce5a1e8e5ca760ba7b2076339e\` FOREIGN KEY (\`buyer_profile_id\`) REFERENCES \`buyer_profiles\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE \`buyer_demands\` ADD CONSTRAINT \`FK_dda770f320bd4fbe4677cc869db\` FOREIGN KEY (\`crop_id\`) REFERENCES \`crops\`(\`id\`) ON DELETE RESTRICT ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE \`buyer_demands\` DROP FOREIGN KEY \`FK_dda770f320bd4fbe4677cc869db\``);
        await queryRunner.query(`ALTER TABLE \`buyer_demands\` DROP FOREIGN KEY \`FK_dce5a1e8e5ca760ba7b2076339e\``);
        await queryRunner.query(`ALTER TABLE \`buyer_profiles\` DROP FOREIGN KEY \`FK_8ef06dd95facdc3db875b449baf\``);
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
        await queryRunner.query(`DROP INDEX \`IDX_f3942d232fef6cbd28426ab134\` ON \`buyer_demands\``);
        await queryRunner.query(`DROP INDEX \`IDX_dda770f320bd4fbe4677cc869d\` ON \`buyer_demands\``);
        await queryRunner.query(`DROP INDEX \`IDX_dce5a1e8e5ca760ba7b2076339\` ON \`buyer_demands\``);
        await queryRunner.query(`DROP TABLE \`buyer_demands\``);
        await queryRunner.query(`DROP INDEX \`REL_8ef06dd95facdc3db875b449ba\` ON \`buyer_profiles\``);
        await queryRunner.query(`DROP INDEX \`IDX_8ef06dd95facdc3db875b449ba\` ON \`buyer_profiles\``);
        await queryRunner.query(`DROP TABLE \`buyer_profiles\``);
    }

}
