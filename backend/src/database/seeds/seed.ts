import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';
import { categorySeeds } from './seed-categories';
import { productSeeds } from './seed-products';

dotenv.config({ path: `.env.${process.env.NODE_ENV ?? 'development'}` });

async function seed() {
  const dataSource = new DataSource({
    type: 'postgres',
    url: process.env.DATABASE_URL,
    entities: ['dist/**/*.entity.js'],
    logging: true,
  });

  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();

  try {
    const passwordHash = await bcrypt.hash('12345678', 12);

    // ── Insert test users ─────────────────────────
    await queryRunner.query(`
      INSERT INTO users (id, full_name, phone, email, password_hash, role, is_active)
      VALUES
        (gen_random_uuid(), 'Test Customer', '0987654321', 'customer@cfpv.com', '${passwordHash}', 'customer', true),
        (gen_random_uuid(), 'Test Admin', '0987654320', 'admin@cfpv.com', '${passwordHash}', 'admin', true),
        (gen_random_uuid(), 'Test Staff', '0987654319', 'staff@cfpv.com', '${passwordHash}', 'staff', true)
      ON CONFLICT (phone) DO NOTHING;
    `);

    // ── Insert categories ─────────────────────────
    for (const cat of categorySeeds) {
      await queryRunner.query(
        `INSERT INTO categories (id, name, slug, description, sort_order)
         VALUES (gen_random_uuid(), $1, $2, $3, $4)
         ON CONFLICT (slug) DO NOTHING`,
        [cat.name, cat.slug, cat.description, cat.sortOrder],
      );
    }

    // ── Insert products & variants ─────────────────
    for (const prod of productSeeds) {
      // Get category id
      const catResult = await queryRunner.query(
        `SELECT id FROM categories WHERE slug = $1`,
        [prod.categorySlug],
      );
      if (catResult.length === 0) {
        console.warn(`⚠️  Category not found for slug: ${prod.categorySlug}, skipping ${prod.name}`);
        continue;
      }
      const categoryId = catResult[0].id;

      // Insert product
      const prodResult = await queryRunner.query(
        `INSERT INTO products (id, category_id, name, slug, description, price, is_featured, sort_order, calories, sugar, fat, protein, caffeine, ingredients, image_url)
         VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
         ON CONFLICT (slug) DO NOTHING
         RETURNING id`,
        [
          categoryId,
          prod.name,
          prod.slug,
          prod.description,
          prod.price,
          prod.isFeatured,
          prod.sortOrder,
          prod.calories ?? null,
          prod.sugar ?? null,
          prod.fat ?? null,
          prod.protein ?? null,
          prod.caffeine ?? null,
          prod.ingredients ?? null,
          prod.imageUrl ?? null,
        ],
      );

      if (prodResult.length === 0) {
        console.warn(`⚠️  Product already exists: ${prod.slug}`);
        continue;
      }

      const productId = prodResult[0].id;

      // Insert variants
      for (const variant of prod.variants) {
        await queryRunner.query(
          `INSERT INTO product_variants (id, product_id, name, size_ml, price_modifier, is_default, sort_order)
           VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6)
           ON CONFLICT DO NOTHING`,
          [productId, variant.name, variant.sizeMl, variant.priceModifier, variant.isDefault, variant.sortOrder],
        );
      }
    }

    console.log('✅ Seed data inserted successfully');
    console.log('📱 Test accounts:');
    console.log('   Customer: 0987654321 / 12345678');
    console.log('   Admin:    0987654320 / 12345678');
    console.log('   Staff:    0987654319 / 12345678');
    console.log('🔐 Hardcoded OTP: 131017');
    console.log('📦 Categories:', categorySeeds.length);
    console.log('📦 Products:', productSeeds.length);
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

seed();
