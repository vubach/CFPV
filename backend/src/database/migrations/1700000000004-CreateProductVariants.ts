import { MigrationInterface, QueryRunner, Table, TableIndex, TableForeignKey } from 'typeorm';

export class CreateProductVariants1700000000004 implements MigrationInterface {
  name = 'CreateProductVariants1700000000004';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'product_variants',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'gen_random_uuid()',
          },
          {
            name: 'product_id',
            type: 'uuid',
          },
          {
            name: 'name',
            type: 'varchar',
            length: '50',
          },
          {
            name: 'size_ml',
            type: 'int',
            isNullable: true,
          },
          {
            name: 'price_modifier',
            type: 'decimal',
            precision: 10,
            scale: 2,
            default: 0,
          },
          {
            name: 'is_default',
            type: 'boolean',
            default: false,
          },
          {
            name: 'sort_order',
            type: 'int',
            default: 0,
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
      'product_variants',
      new TableIndex({
        name: 'idx_variants_product',
        columnNames: ['product_id'],
      }),
    );

    await queryRunner.createForeignKey(
      'product_variants',
      new TableForeignKey({
        name: 'fk_variants_product',
        columnNames: ['product_id'],
        referencedTableName: 'products',
        referencedColumnNames: ['id'],
        onDelete: 'CASCADE',
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropForeignKey('product_variants', 'fk_variants_product');
    await queryRunner.dropTable('product_variants');
  }
}
