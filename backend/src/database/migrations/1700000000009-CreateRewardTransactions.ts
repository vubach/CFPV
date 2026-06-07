import { MigrationInterface, QueryRunner, Table, TableIndex, TableForeignKey } from 'typeorm';

export class CreateRewardTransactions1700000000009 implements MigrationInterface {
  name = 'CreateRewardTransactions1700000000009';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'reward_transactions',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'gen_random_uuid()',
          },
          {
            name: 'user_id',
            type: 'uuid',
          },
          {
            name: 'order_id',
            type: 'uuid',
            isNullable: true,
          },
          {
            name: 'description',
            type: 'varchar',
            length: '500',
          },
          {
            name: 'points',
            type: 'int',
          },
          {
            name: 'type',
            type: 'enum',
            enum: ['earned', 'redeemed'],
          },
          {
            name: 'created_at',
            type: 'timestamp',
            default: 'now()',
          },
        ],
      }),
      true,
    );

    await queryRunner.createIndex(
      'reward_transactions',
      new TableIndex({
        name: 'idx_reward_tx_user',
        columnNames: ['user_id'],
      }),
    );

    await queryRunner.createForeignKey(
      'reward_transactions',
      new TableForeignKey({
        name: 'fk_reward_tx_user',
        columnNames: ['user_id'],
        referencedTableName: 'users',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'reward_transactions',
      new TableForeignKey({
        name: 'fk_reward_tx_order',
        columnNames: ['order_id'],
        referencedTableName: 'orders',
        referencedColumnNames: ['id'],
        onDelete: 'SET NULL',
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropForeignKey('reward_transactions', 'fk_reward_tx_user');
    await queryRunner.dropForeignKey('reward_transactions', 'fk_reward_tx_order');
    await queryRunner.dropTable('reward_transactions');
  }
}
