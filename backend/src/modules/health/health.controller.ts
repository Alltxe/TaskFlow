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

/**
 * Health check controller for readiness/liveness probes
 * Implements PRD 4.3 monitoring requirements
 */
@Controller('health')
export class HealthController {
  // Пороги настраиваются через env, чтобы readiness не падал на слабом VPS.
  private readonly heapLimit =
    this.envInt('HEALTH_MEMORY_HEAP_MB', 300) * 1024 * 1024;
  private readonly rssLimit =
    this.envInt('HEALTH_MEMORY_RSS_MB', 500) * 1024 * 1024;
  private readonly diskPath = process.env.HEALTH_DISK_PATH || '/';
  private readonly diskThreshold = this.envFloat(
    'HEALTH_DISK_THRESHOLD_PERCENT',
    0.9,
  );

  constructor(
    private health: HealthCheckService,
    private prismaHealth: PrismaHealthIndicator,
    private memory: MemoryHealthIndicator,
    private disk: DiskHealthIndicator,
    private prisma: PrismaService,
  ) {}

  private envInt(name: string, fallback: number): number {
    const value = Number.parseInt(process.env[name] ?? '', 10);
    return Number.isFinite(value) && value > 0 ? value : fallback;
  }

  private envFloat(name: string, fallback: number): number {
    const value = Number.parseFloat(process.env[name] ?? '');
    return Number.isFinite(value) && value > 0 ? value : fallback;
  }

  /**
   * Liveness probe - checks if the application is alive
   * Returns 200 if app is running
   */
  @Get('live')
  @HealthCheck()
  checkLiveness() {
    return this.health.check([
      () => this.memory.checkHeap('memory_heap', this.heapLimit),
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
      () => this.prismaHealth.pingCheck('database', this.prisma),
      () => this.memory.checkRSS('memory_rss', this.rssLimit),
      () =>
        this.disk.checkStorage('storage', {
          path: this.diskPath,
          thresholdPercent: this.diskThreshold,
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
      () => this.memory.checkHeap('memory_heap', this.heapLimit),
      () => this.memory.checkRSS('memory_rss', this.rssLimit),
    ]);
  }
}
