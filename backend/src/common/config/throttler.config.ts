// src/common/config/throttler.config.ts
import { ThrottlerModuleOptions } from '@nestjs/throttler';

/**
 * Rate Limiting Configuration (PRD 4.3)
 * 
 * ARCHITECTURE: User-Based Rate Limiting
 * - Authenticated requests: Rate limited per user ID (from JWT token)
 * - Unauthenticated requests: Rate limited per IP address (login, register)
 * 
 * WHY: Frontend-to-backend architecture means all requests come from the same
 * frontend server IP. IP-based limiting would apply limits to ALL users together.
 * User-based limiting ensures each user has their own rate limit bucket.
 * 
 * IMPORTANT: Rate limiting is DISABLED in development and test environments
 * to avoid issues with E2E tests and local development.
 * 
 * In production, the following limits apply:
 * - General API (per user): 100 requests per minute
 * - Auth endpoints (per IP): 5 requests per minute (prevents brute force)
 * 
 * To test rate limiting:
 * 1. Set NODE_ENV=production
 * 2. Use Postman collection or curl to send repeated requests
 * 3. Verify 429 status code after exceeding limits
 */
export const throttlerConfig: ThrottlerModuleOptions = {
  // Disable throttling in development/test by setting extremely high limits
  skipIf: () => process.env.NODE_ENV === 'development' || process.env.NODE_ENV === 'test',
  throttlers: [
    {
      name: 'default',
      ttl: 60000, // 1 minute in milliseconds
      limit: 100, // 100 requests per minute (general API - PRD 4.3)
    },
    {
      name: 'auth',
      ttl: 60000, // 1 minute in milliseconds
      limit: 5, // 5 requests per minute for auth endpoints (PRD 4.3)
    },
  ],
};
