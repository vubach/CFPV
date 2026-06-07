import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';

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

    console.log('✅ Seed data inserted successfully');
    console.log('📱 Test accounts:');
    console.log('   Customer: 0987654321 / 12345678');
    console.log('   Admin:    0987654320 / 12345678');
    console.log('   Staff:    0987654319 / 12345678');
    console.log('🔐 Hardcoded OTP: 131017');
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

seed();
