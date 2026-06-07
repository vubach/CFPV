import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddAvatarUrlToUsers1700000000010 implements MigrationInterface {
  name = 'AddAvatarUrlToUsers1700000000010';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn(
      'users',
      new TableColumn({
        name: 'avatar_url',
        type: 'varchar',
        length: '500',
        isNullable: true,
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropColumn('users', 'avatar_url');
  }
}
