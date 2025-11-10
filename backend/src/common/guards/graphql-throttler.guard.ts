import { ExecutionContext, Injectable } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { ThrottlerGuard, ThrottlerLimitDetail } from '@nestjs/throttler';
import { ThrottlerException } from '../exceptions/throttler.exception';

/**
 * Custom ThrottlerGuard for GraphQL requests
 * 
 * Fixes issue where req.ip is undefined in GraphQL context
 * by properly extracting the request object from GraphQL context
 * 
 * Also ensures GraphQL error code is "TOO_MANY_REQUESTS" instead of "INTERNAL_SERVER_ERROR"
 */
@Injectable()
export class GraphqlThrottlerGuard extends ThrottlerGuard {
  /**
   * Override throwThrottlingException to use custom exception
   * This ensures GraphQL error code is TOO_MANY_REQUESTS (not INTERNAL_SERVER_ERROR)
   */
  protected async throwThrottlingException(
    context: ExecutionContext,
    throttlerLimitDetail: ThrottlerLimitDetail,
  ): Promise<void> {
    throw new ThrottlerException();
  }
  /**
   * Override getRequestResponse to handle both HTTP and GraphQL contexts
   */
  protected getRequestResponse(context: ExecutionContext) {
    const gqlCtx = GqlExecutionContext.create(context);
    const ctx = gqlCtx.getContext();
    
    // For GraphQL requests, extract req/res from context
    if (ctx && ctx.req && ctx.res) {
      return { req: ctx.req, res: ctx.res };
    }
    
    // Fallback to HTTP context for non-GraphQL requests
    return super.getRequestResponse(context);
  }

  /**
   * Override getTracker to use authenticated user ID instead of IP
   * 
   * CRITICAL: For frontend-to-backend architecture, IP-based rate limiting
   * doesn't work because all requests come from the same frontend server IP.
   * 
   * Solution: Use user ID from JWT token for authenticated requests,
   * fallback to IP for unauthenticated requests (login, register).
   */
  protected async getTracker(req: Record<string, any>): Promise<string> {
    // For authenticated requests: use user ID from JWT token
    // This ensures each user has their own rate limit bucket
    if (req.user && req.user.id) {
      return `user:${req.user.id}`;
    }
    
    // For unauthenticated requests (login, register): use IP address
    // This prevents brute force attacks on auth endpoints
    const ip = 
      req.ip || 
      req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
      req.headers['x-real-ip'] ||
      req.connection?.remoteAddress ||
      req.socket?.remoteAddress ||
      '127.0.0.1'; // Fallback to localhost
    
    return `ip:${ip}`;
  }
}
