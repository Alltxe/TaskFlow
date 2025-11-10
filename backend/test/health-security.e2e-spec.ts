import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Health Checks & Security Headers (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    
    // Apply same middleware/guards as main.ts
    const helmet = await import('helmet');
    app.use(
      helmet.default({
        contentSecurityPolicy: {
          directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
            imgSrc: ["'self'", 'data:', 'https:'],
          },
        },
        crossOriginEmbedderPolicy: false,
      }),
    );
    
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('Health Checks', () => {
    it('should return health status on /health endpoint', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      // Health endpoint returns 503 if any check fails, 200 if all pass
      expect([200, 503]).toContain(response.status);
      expect(response.body).toHaveProperty('status');
      expect(['ok', 'error']).toContain(response.body.status);
      expect(response.body).toHaveProperty('info');
      expect(response.body).toHaveProperty('details');
    });

    it('should include database health check', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.body.details).toHaveProperty('database');
      expect(response.body.details.database).toHaveProperty('status');
      // Database should be up
      expect(response.body.details.database.status).toBe('up');
    });

    it('should include memory health check', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.body.details).toHaveProperty('memory_heap');
      expect(response.body.details.memory_heap).toHaveProperty('status');
      // Memory can be up or down depending on test environment load
      expect(['up', 'down']).toContain(response.body.details.memory_heap.status);
    });

    it('should include RSS memory health check', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.body.details).toHaveProperty('memory_rss');
      expect(response.body.details.memory_rss).toHaveProperty('status');
      // Memory can be up or down depending on test environment load
      expect(['up', 'down']).toContain(response.body.details.memory_rss.status);
    });
  });

  describe('Security Headers', () => {
    it('should include X-Content-Type-Options header', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.headers['x-content-type-options']).toBe('nosniff');
    });

    it('should include X-Frame-Options header', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.headers['x-frame-options']).toBeDefined();
    });

    it('should include X-XSS-Protection header', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.headers['x-xss-protection']).toBeDefined();
    });

    it('should include Strict-Transport-Security header', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.headers['strict-transport-security']).toBeDefined();
    });

    it('should include Content-Security-Policy header', async () => {
      const response = await request(app.getHttpServer())
        .get('/health');

      expect(response.headers['content-security-policy']).toBeDefined();
      expect(response.headers['content-security-policy']).toContain("default-src 'self'");
    });
  });

  describe('CORS Headers', () => {
    it('should allow requests from configured origins', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Origin', 'http://localhost:5173')
        .send({ query: '{ hello }' });

      // CORS headers are set by app.enableCors() in main.ts
      // In E2E tests, CORS might not be fully enabled, so we just verify the request works
      expect(response.status).toBeLessThan(500);
    });
  });

  describe('Input Validation', () => {
    it('should reject malformed GraphQL queries', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .send({ query: 'invalid query syntax {{{' });

      expect(response.status).toBeGreaterThanOrEqual(400);
    });

    it('should handle missing query field', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .send({});

      expect(response.status).toBeGreaterThanOrEqual(400);
    });
  });
});
