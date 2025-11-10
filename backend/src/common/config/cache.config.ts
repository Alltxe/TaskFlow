// src/common/config/cache.config.ts
import { CacheModuleOptions } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-yet';

export async function getCacheConfig(): Promise<CacheModuleOptions> {
  const redisUrl = process.env.REDIS_URL;

  // If Redis URL is provided, use Redis. Otherwise, fallback to memory cache (dev mode)
  if (redisUrl) {
    try {
      return {
        store: await redisStore({
          url: redisUrl,
          ttl: 300 * 1000, // 5 minutes in milliseconds
        }),
        max: 100,
      };
    } catch (error) {
      console.warn('Redis connection failed, falling back to memory cache:', error.message);
      return {
        ttl: 300, // 5 minutes in seconds for memory store
        max: 100,
      };
    }
  }

  // Development mode: use memory cache
  return {
    ttl: 300, // 5 minutes in seconds
    max: 100,
  };
}
