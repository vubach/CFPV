import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { DataSource } from 'typeorm';
import { AppModule } from '../src/app.module';
import { ResponseInterceptor } from '../src/common/interceptors/response.interceptor';

// ── Helpers ─────────────────────────────────────────
const hardcodedOtp = '131017';

/**
 * Generate a unique phone number per test run so tests
 * never conflict with seed data or parallel runs.
 */
function uniquePhone(): string {
  const ts = Date.now().toString().slice(-8);
  return `99${ts}`; // 10 digits, starts with 99
}

// ── Module Setup ────────────────────────────────────
describe('Auth (e2e) — /api/v1/auth', () => {
  let app: INestApplication;
  let httpServer: any;

  // Unique test user data for this run
  const testUser = {
    fullName: 'E2E Test User',
    phone: uniquePhone(),
    password: 'e2eTestPass123',
  };

  // Tokens obtained during the flow (shared between tests)
  let accessToken: string;
  let refreshToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
      // Do NOT override any providers — use the real ones
    }).compile();

    app = moduleFixture.createNestApplication();

    // Apply the same global configuration as main.ts
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        transformOptions: {
          enableImplicitConversion: true,
        },
      }),
    );
    app.useGlobalInterceptors(new ResponseInterceptor());
    await app.init();
    httpServer = app.getHttpServer();
  }, 30_000); // 30s timeout for DB connection + module compilation

  afterAll(async () => {
    // Clean up: delete the test user from the database
    if (httpServer) {
      try {
        const dataSource = app.get(DataSource);
        await dataSource.query('DELETE FROM device_tokens WHERE user_id IN (SELECT id FROM users WHERE phone = $1)', [testUser.phone]);
        await dataSource.query('DELETE FROM users WHERE phone = $1', [testUser.phone]);
      } catch {
        // Best-effort cleanup — don't fail if already cleaned
      }
    }
    await app.close();
  });

  // ────────────────────────────────────────────────────
  //  POST /api/v1/auth/register
  // ────────────────────────────────────────────────────
  describe('POST /api/v1/auth/register', () => {
    const endpoint = '/api/v1/auth/register';

    it('should register a new user (201)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send(testUser)
        .expect(201);

      expect(res.body.success).toBe(true);
      expect(res.body.data).toEqual({ message: 'OTP sent to your phone' });
      expect(res.body.timestamp).toBeDefined();
    });

    it('should reject duplicate phone number (409)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send(testUser)
        .expect(409);

      expect(res.body.success).toBe(false);
      expect(res.body.message).toContain('already registered');
    });

    it('should reject missing required fields (400)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ phone: '12345' }) // missing fullName + password
        .expect(400);

      expect(res.body.success).toBe(false);
      expect(res.body.statusCode).toBe(400);
    });

    it('should reject short password (400)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({
          fullName: 'Weak Password',
          phone: uniquePhone(),
          password: 'short',
        })
        .expect(400);

      expect(res.body.success).toBe(false);
    });
  });

  // ────────────────────────────────────────────────────
  //  POST /api/v1/auth/verify-otp
  // ────────────────────────────────────────────────────
  describe('POST /api/v1/auth/verify-otp', () => {
    const endpoint = '/api/v1/auth/verify-otp';

    it('should verify OTP and return tokens (200)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ phone: testUser.phone, otp: hardcodedOtp })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.accessToken).toBeDefined();
      expect(typeof res.body.data.accessToken).toBe('string');
      expect(res.body.data.refreshToken).toBeDefined();
      expect(typeof res.body.data.refreshToken).toBe('string');
      expect(res.body.data.user).toBeDefined();
      expect(res.body.data.user.phone).toBe(testUser.phone);
      expect(res.body.data.user.fullName).toBe(testUser.fullName);

      // Store tokens for subsequent tests
      accessToken = res.body.data.accessToken;
      refreshToken = res.body.data.refreshToken;
    });

    it('should reject invalid OTP (400)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ phone: testUser.phone, otp: '000000' })
        .expect(400);

      expect(res.body.success).toBe(false);
      expect(res.body.message).toContain('Invalid verification code');
    });

    it('should reject non-existent phone (401)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ phone: '0000000000', otp: hardcodedOtp })
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.message).toContain('User not found');
    });

    it('should reject malformed request body (400)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({}) // missing phone + otp
        .expect(400);

      expect(res.body.success).toBe(false);
    });
  });

  // ────────────────────────────────────────────────────
  //  POST /api/v1/auth/login
  // ────────────────────────────────────────────────────
  describe('POST /api/v1/auth/login', () => {
    const endpoint = '/api/v1/auth/login';

    it('should login with phone and return tokens (200)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ login: testUser.phone, password: testUser.password })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
      expect(res.body.data.user.phone).toBe(testUser.phone);

      // Login issues new tokens — update for subsequent tests
      accessToken = res.body.data.accessToken;
      refreshToken = res.body.data.refreshToken;
    });

    it('should reject wrong password (401)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ login: testUser.phone, password: 'wrongPassword!' })
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.message).toContain('Invalid credentials');
    });

    it('should reject non-existent login (401)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ login: '0000000000', password: 'anyPassword123' })
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.message).toContain('Invalid credentials');
    });

    it('should reject missing password (400)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ login: testUser.phone })
        .expect(400);

      expect(res.body.success).toBe(false);
    });
  });

  // ────────────────────────────────────────────────────
  //  POST /api/v1/auth/refresh
  // ────────────────────────────────────────────────────
  describe('POST /api/v1/auth/refresh', () => {
    const endpoint = '/api/v1/auth/refresh';

    it('should refresh tokens with valid refresh token (200)', async () => {
      // refreshToken was obtained from verifyOtp
      expect(refreshToken).toBeDefined();

      const res = await request(httpServer)
        .post(endpoint)
        .send({ refreshToken })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
      expect(res.body.data.refreshToken).not.toBe(refreshToken); // rotated

      // Update for potential follow-up tests
      refreshToken = res.body.data.refreshToken;
      accessToken = res.body.data.accessToken;
    });

    it('should reject expired/invalid refresh token (401)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({ refreshToken: 'eyJhbGciOiJIUzI1NiJ9.invalid-token.abc123' })
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.message).toContain('Invalid or expired refresh token');
    });

    it('should reject empty token (400)', async () => {
      const res = await request(httpServer)
        .post(endpoint)
        .send({}) // missing refreshToken
        .expect(400);

      expect(res.body.success).toBe(false);
    });
  });

  // ────────────────────────────────────────────────────
  //  GET /api/v1/users/me (authenticated)
  // ────────────────────────────────────────────────────
  describe('GET /api/v1/users/me (authenticated)', () => {
    const endpoint = '/api/v1/users/me';

    it('should return user profile with valid access token (200)', async () => {
      expect(accessToken).toBeDefined();

      const res = await request(httpServer)
        .get(endpoint)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBeDefined();
      expect(res.body.data.phone).toBe(testUser.phone);
      expect(res.body.data.fullName).toBe(testUser.fullName);
    });

    it('should reject request without token (401)', async () => {
      const res = await request(httpServer)
        .get(endpoint)
        .expect(401);

      expect(res.body.success).toBe(false);
    });

    it('should reject request with invalid token (401)', async () => {
      const res = await request(httpServer)
        .get(endpoint)
        .set('Authorization', 'Bearer invalid-jwt-token')
        .expect(401);

      expect(res.body.success).toBe(false);
    });
  });
});
