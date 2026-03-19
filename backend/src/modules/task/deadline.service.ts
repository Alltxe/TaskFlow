import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationService } from '../notification/notification.service';
import { NotificationType as NotificationTypeEnum } from '@prisma/client';

/**
 * Deadline Monitoring Service (PRD 3.6.3)
 * Автоматически обновляет статус задач на OVERDUE при истечении срока
 */
@Injectable()
export class DeadlineService {
  private readonly logger = new Logger(DeadlineService.name);

  constructor(private prisma: PrismaService, private notifications: NotificationService) {}

  /**
   * Проверка просроченных задач (запускается каждый час)
   * PRD 3.6.3: If task is overdue and not completed, system must automatically 
   * change status to "Overdue", blocking full point award
   */
  @Cron(CronExpression.EVERY_HOUR)
  async checkOverdueTasks() {
    this.logger.log('Running overdue task check...');

    const now = new Date();

    try {
      // Находим все задачи с истекшим сроком и статусом не COMPLETED/OVERDUE/CANCELLED
      const overdueTasks = await this.prisma.task.findMany({
        where: {
          isRecurring: false,
          deadline: {
            lt: now,
          },
          status: {
            notIn: ['COMPLETED', 'OVERDUE', 'CANCELLED'],
          },
        },
      });

      if (overdueTasks.length === 0) {
        this.logger.log('No overdue tasks found');
        return;
      }

      this.logger.log(`Found ${overdueTasks.length} overdue tasks`);

      // Обновляем статус на OVERDUE
      const result = await this.prisma.task.updateMany({
        where: {
          id: {
            in: overdueTasks.map((task) => task.id),
          },
        },
        data: {
          status: 'OVERDUE',
        },
      });

      this.logger.log(`Updated ${result.count} tasks to OVERDUE status`);
    } catch (error) {
      this.logger.error('Error checking overdue tasks:', error);
    }
  }

  /**
   * Проверка дедлайнов вручную (для тестирования и инициализации)
   */
  async checkOverdueTasksManually() {
    await this.checkOverdueTasks();
  }

  /**
   * Отправка напоминаний о приближающихся дедлайнах
   * PRD 3.6.3: Deadline approaching (24 hours, 1 hour)
   * TODO: Интеграция с Notification Service (Phase 8)
   */
  @Cron(CronExpression.EVERY_30_MINUTES)
  async sendDeadlineReminders() {
    this.logger.log('Checking for deadline reminders...');

    const now = new Date();
    const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const in1Hour = new Date(now.getTime() + 60 * 60 * 1000);

    try {
      // Задачи с дедлайном через 24 часа
      const tasks24h = await this.prisma.task.findMany({
        where: {
          isRecurring: false,
          deadline: {
            gte: now,
            lte: in24Hours,
          },
          status: {
            in: ['PENDING', 'IN_PROGRESS'],
          },
        },
        include: {
          assignee: true,
          group: true,
        },
      });

      // Задачи с дедлайном через 1 час
      const tasks1h = await this.prisma.task.findMany({
        where: {
          isRecurring: false,
          deadline: {
            gte: now,
            lte: in1Hour,
          },
          status: {
            in: ['PENDING', 'IN_PROGRESS'],
          },
        },
        include: {
          assignee: true,
          group: true,
        },
      });

      this.logger.log(
        `Found ${tasks24h.length} tasks due in 24h, ${tasks1h.length} tasks due in 1h`,
      );

      // Send notifications via Notification Service (Phase 8)
      for (const task of tasks24h) {
        if (task.assignee) {
          await this.notifications.notify({
            userId: task.assignee.id,
            title: 'Task due in 24h',
            message: `"${task.title}" is due in 24 hours`,
            type: NotificationTypeEnum.SYSTEM,
            relatedEntityType: 'Task',
            relatedEntityId: task.id,
          });
        }
      }

      for (const task of tasks1h) {
        if (task.assignee) {
          await this.notifications.notify({
            userId: task.assignee.id,
            title: 'Task due in 1h',
            message: `"${task.title}" is due in 1 hour`,
            type: NotificationTypeEnum.SYSTEM,
            relatedEntityType: 'Task',
            relatedEntityId: task.id,
          });
        }
      }
    } catch (error) {
      this.logger.error('Error sending deadline reminders:', error);
    }
  }
}
