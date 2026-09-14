import { MigrationInterface, QueryRunner } from "typeorm";

export class FarmerProfileAndFarms1789279531465 implements MigrationInterface {
    name = 'FarmerProfileAndFarms1789279531465'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE \`farmer_profiles\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`user_id\` varchar(255) NOT NULL, \`zone\` varchar(255) NULL, \`woreda\` varchar(255) NULL, \`kebele\` varchar(255) NULL, \`cooperative_name\` varchar(255) NULL, UNIQUE INDEX \`IDX_77f5f5145225ffcaa3583fb0ee\` (\`user_id\`), UNIQUE INDEX \`REL_77f5f5145225ffcaa3583fb0ee\` (\`user_id\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`CREATE TABLE \`farms\` (\`id\` varchar(36) NOT NULL, \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6), \`farmer_id\` varchar(255) NOT NULL, \`name\` varchar(255) NOT NULL, \`size_hectares\` decimal(8,2) NOT NULL, \`zone\` varchar(255) NOT NULL, \`woreda\` varchar(255) NOT NULL, \`kebele\` varchar(255) NULL, \`latitude\` decimal(9,6) NULL, \`longitude\` decimal(9,6) NULL, INDEX \`IDX_cf149d788e38bd5934645ac6ef\` (\`farmer_id\`), PRIMARY KEY (\`id\`)) ENGINE=InnoDB`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL`);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL`);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` ADD CONSTRAINT \`FK_77f5f5145225ffcaa3583fb0ee1\` FOREIGN KEY (\`user_id\`) REFERENCES \`users\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE \`farms\` ADD CONSTRAINT \`FK_cf149d788e38bd5934645ac6ef1\` FOREIGN KEY (\`farmer_id\`) REFERENCES \`users\`(\`id\`) ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE \`farms\` DROP FOREIGN KEY \`FK_cf149d788e38bd5934645ac6ef1\``);
        await queryRunner.query(`ALTER TABLE \`farmer_profiles\` DROP FOREIGN KEY \`FK_77f5f5145225ffcaa3583fb0ee1\``);
        await queryRunner.query(`ALTER TABLE \`refresh_tokens\` CHANGE \`revoked_at\` \`revoked_at\` datetime NULL DEFAULT 'NULL'`);
        await queryRunner.query(`ALTER TABLE \`users\` CHANGE \`email\` \`email\` varchar(255) NULL DEFAULT 'NULL'`);
        await queryRunner.query(`DROP INDEX \`IDX_cf149d788e38bd5934645ac6ef\` ON \`farms\``);
        await queryRunner.query(`DROP TABLE \`farms\``);
        await queryRunner.query(`DROP INDEX \`REL_77f5f5145225ffcaa3583fb0ee\` ON \`farmer_profiles\``);
        await queryRunner.query(`DROP INDEX \`IDX_77f5f5145225ffcaa3583fb0ee\` ON \`farmer_profiles\``);
        await queryRunner.query(`DROP TABLE \`farmer_profiles\``);
    }

}
