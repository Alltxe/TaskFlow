// src/modules/health/health.controller.ts
import { Controller, Get } from '@nestjs/common';
import {
  HealthCheckService,
  HealthCheck,
  PrismaHealthIndicator,
  MemoryHealthIndicator,
  DiskHealthIndicator,
} from '@nestjs/terminus';
import { PrismaService } from '../prisma/prisma.service';
import { SkipThrottle } from '@nestjs/throttler';

/**
 * Health check controller for readiness/liveness probes
 * Implements PRD 4.3 monitoring requirements
 */
@Controller('health')
@SkipThrottle() // Health checks should not be rate limited
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private prismaHealth: PrismaHealthIndicator,
    private memory: MemoryHealthIndicator,
    private disk: DiskHealthIndicator,
    private prisma: PrismaService,
  ) {}

  /**
   * Liveness probe - checks if the application is alive
   * Returns 200 if app is running
   */
  @Get('live')
  @HealthCheck()
  checkLiveness() {
    return this.health.check([
      // Memory heap should not exceed 150MB
      () => this.memory.checkHeap('memory_heap', 150 * 1024 * 1024),
    ]);
  }

  /**
   * Readiness probe - checks if the application is ready to serve requests
   * Checks database connection and critical resources
   */
  @Get('ready')
  @HealthCheck()
  checkReadiness() {
    return this.health.check([
      // Database connection
      () => this.prismaHealth.pingCheck('database', this.prisma),
      // Memory RSS should not exceed 300MB
      () => this.memory.checkRSS('memory_rss', 300 * 1024 * 1024),
      // Storage should have at least 10% free space
      () =>
        this.disk.checkStorage('storage', {
          path: '/',
          thresholdPercent: 0.9,
        }),
    ]);
  }

  /**
   * Combined health check
   * Returns overall system health status
   */
  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.prismaHealth.pingCheck('database', this.prisma),
      () => this.memory.checkHeap('memory_heap', 150 * 1024 * 1024),
      () => this.memory.checkRSS('memory_rss', 300 * 1024 * 1024),
    ]);
  }
}
