// src/common/guards/auth-throttler.guard.ts
import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

/**
 * Custom throttler guard for auth endpoints
 * Applies stricter rate limiting (5 req/min) per PRD 4.3
 */
@Injectable()
export class AuthThrottlerGuard extends ThrottlerGuard {
  protected async getTracker(req: Record<string, any>): Promise<string> {
    // Use IP address as tracker
    return req.ip || req.connection.remoteAddress || 'unknown';
  }

  protected async getThrottlerName(): Promise<string> {
    return 'auth';
  }
}
