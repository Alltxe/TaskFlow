import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/**
 * RotationService implements executor selection strategies.
 * PRD Sections: 3.4.1 (Round Robin), 7.1.2 (Weighted Random), 3.4.3 & 7.1.3 (Load Balancing).
 */
@Injectable()
export class RotationService {
  private static readonly IMBALANCE_THRESHOLD_RATIO = 2; // 2x per PRD example

  constructor(private prisma: PrismaService) {}

  async selectAssignee(
    groupId: string,
    rotationType: string,
    taskWeight: number,
  ): Promise<string | null> {
    const members = await this.prisma.groupMember.findMany({
      where: {
        groupId,
        user: { isAway: false },
      },
      include: { user: true },
      orderBy: { joinedAt: 'asc' },
    });

    if (members.length === 0) return null;

    switch (rotationType) {
      case 'ROUND_ROBIN':
        return this.roundRobinSelection(groupId, members);
      case 'RANDOM':
        return this.randomSelection(members);
      case 'WEIGHTED_RANDOM':
        return this.weightedRandomSelection(groupId, members);
      case 'LOAD_BALANCING':
        return this.loadBalancingSelection(groupId, members, taskWeight);
      case 'DISABLED':
        return null; // Up-for-Grabs
      default:
        return this.roundRobinSelection(groupId, members);
    }
  }

  /** Round Robin - next after last assignee */
  private async roundRobinSelection(groupId: string, members: any[]): Promise<string> {
    const lastTask = await this.prisma.task.findFirst({
      where: { groupId, assigneeId: { not: null } },
      orderBy: { createdAt: 'desc' },
      select: { assigneeId: true },
    });

    if (!lastTask || !lastTask.assigneeId) {
      return members[0].userId;
    }

    const lastIndex = members.findIndex((m) => m.userId === lastTask.assigneeId);
    const nextIndex = (lastIndex + 1) % members.length;
    return members[nextIndex].userId;
  }

  /** Pure random selection */
  private randomSelection(members: any[]): string {
    const idx = Math.floor(Math.random() * members.length);
    return members[idx].userId;
  }

  /** Weighted Random (inverse of active task count) */
  private async weightedRandomSelection(groupId: string, members: any[]): Promise<string> {
    const weights = await Promise.all(
      members.map(async (m) => {
        const activeCount = await this.prisma.task.count({
          where: {
            groupId,
            assigneeId: m.userId,
            status: { in: ['PENDING', 'IN_PROGRESS'] },
          },
        });
        return { userId: m.userId, weight: Math.max(1, 10 - activeCount) };
      }),
    );
    const total = weights.reduce((s, w) => s + w.weight, 0);
    let r = Math.random() * total;
    for (const w of weights) {
      r -= w.weight;
      if (r <= 0) return w.userId;
    }
    return weights[0].userId;
  }

  /** Load Balancing: choose lowest accumulated completed weight if imbalance >= 2x else fallback RR */
  private async loadBalancingSelection(
    groupId: string,
    members: any[],
    incomingTaskWeight: number,
  ): Promise<string> {
    // Sum weights of COMPLETED tasks per user (accumulated load)
    const completions = await this.prisma.taskCompletionHistory.findMany({
      where: { task: { groupId } },
      include: { task: { select: { weight: true, assigneeId: true } } },
    });

    const loadMap = new Map<string, number>();
    members.forEach((m) => loadMap.set(m.userId, 0));
    completions.forEach((c) => {
      if (c.task.assigneeId) {
        loadMap.set(
          c.task.assigneeId,
          (loadMap.get(c.task.assigneeId) || 0) + c.task.weight,
        );
      }
    });

    const loads = members.map((m) => ({ userId: m.userId, load: loadMap.get(m.userId) || 0 }));
    loads.sort((a, b) => a.load - b.load);
    const minLoad = loads[0].load;
    const maxLoad = loads[loads.length - 1].load;

    // Imbalance check: max >= 2 * min (PRD example). Use ratio threshold.
    const imbalance = minLoad === 0 ? maxLoad >= incomingTaskWeight * RotationService.IMBALANCE_THRESHOLD_RATIO : maxLoad / Math.max(1, minLoad) >= RotationService.IMBALANCE_THRESHOLD_RATIO;

    if (imbalance) {
      return loads[0].userId; // lowest load gets task
    }

    // Fallback to Round Robin normal flow
    return this.roundRobinSelection(groupId, members);
  }
}