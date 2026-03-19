import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { RotationService } from './rotation.service';
import { RotationType, TaskPriority } from '@prisma/client';
import { RRule, RRuleSet, rrulestr } from 'rrule';

/**
 * Интерфейс для правила повторения задачи
 * Поддерживает два формата:
 * 1. Упрощенный: "DAILY" | "WEEKLY:1,3,5" | "MONTHLY:1,15"
 * 2. RFC 5545 (iCalendar): "FREQ=WEEKLY;BYDAY=MO,WE,FR;BYHOUR=18;BYMINUTE=30"
 */
export interface RecurrenceRuleParser {
  type: 'DAILY' | 'WEEKLY' | 'MONTHLY' | 'RRULE';
  values?: number[]; // День недели (1-7) или день месяца (1-31)
  rrule?: RRule; // RFC 5545 правило
}

@Injectable()
export class RecurringTaskService {
  private readonly logger = new Logger(RecurringTaskService.name);

  constructor(
    private prisma: PrismaService,
    private rotationService: RotationService,
  ) {}

  /**
   * CRON задача: проверяет необходимость генерации новых задач из шаблонов
   * Выполняется каждый час согласно PRD 3.3.3 (генерация за 24 часа до deadline)
   */
  @Cron(CronExpression.EVERY_HOUR)
  async generateRecurringTasks() {
    await this.runRecurringGenerationCycle('hourly');
  }

  /**
   * Временный тестовый запуск каждую минуту.
   * Включается только при ENABLE_RECURRING_TEST_CRON=true.
   */
  @Cron(CronExpression.EVERY_MINUTE)
  async generateRecurringTasksForTesting() {
    if (process.env.ENABLE_RECURRING_TEST_CRON !== 'true') {
      return;
    }

    await this.runRecurringGenerationCycle('minutely-test');
  }

  private async runRecurringGenerationCycle(mode: 'hourly' | 'minutely-test') {
    this.logger.log('Starting recurring task generation check...');

    try {
      // Находим все активные повторяющиеся задачи (шаблоны)
      const recurringTasks = await this.prisma.task.findMany({
        where: {
          isRecurring: true,
          recurrenceRule: { not: null },
          // Только COMPLETED или PENDING задачи могут быть шаблонами
          status: { in: ['COMPLETED', 'PENDING'] },
        },
        include: {
          group: {
            select: {
              id: true,
              rotationType: true,
              name: true,
            },
          },
          childTasks: {
            orderBy: { createdAt: 'desc' },
            take: 1,
          },
        },
      });

      this.logger.log(
        `Found ${recurringTasks.length} recurring task templates (${mode})`,
      );

      for (const template of recurringTasks) {
        try {
          await this.processRecurringTask(template);
        } catch (error) {
          this.logger.error(
            `Failed to process recurring task ${template.id}: ${error.message}`,
            error.stack,
          );
        }
      }

      this.logger.log('Recurring task generation check completed');
    } catch (error) {
      this.logger.error(
        `Failed to generate recurring tasks: ${error.message}`,
        error.stack,
      );
    }
  }

  /**
   * Обрабатывает одну повторяющуюся задачу и генерирует новую при необходимости
   * @param template - шаблон повторяющейся задачи
   */
  private async processRecurringTask(template: any) {
    const lastChild = template.childTasks[0];
    const now = new Date();

    // Первый экземпляр должен соответствовать якорному deadline шаблона.
    // Далее используем deadline последнего дочернего инстанса.
    let nextDeadline = lastChild
      ? this.calculateNextDeadline(template.recurrenceRule, lastChild.deadline)
      : this.calculateFirstDeadline(template.recurrenceRule, template.deadline);

    if (!nextDeadline) {
      this.logger.warn(
        `Could not calculate next deadline for task ${template.id}`,
      );
      return;
    }

    // Если scheduler пропустил окно, двигаемся к ближайшему будущему вхождению,
    // чтобы не генерировать просроченные задачи.
    if (nextDeadline.getTime() <= now.getTime()) {
      nextDeadline = this.calculateNextUpcomingDeadline(
        template.recurrenceRule,
        nextDeadline,
        now,
      );

      if (!nextDeadline) {
        this.logger.debug(
          `No upcoming occurrences left for recurring template ${template.id}`,
        );
        return;
      }
    }

    // Проверяем, пора ли создавать новую задачу (за 24 часа до deadline - PRD 3.3.3)
    const timeUntilDeadline = nextDeadline.getTime() - now.getTime();
    const hoursUntilDeadline = timeUntilDeadline / (1000 * 60 * 60);

    if (hoursUntilDeadline > 24) {
      // Слишком рано, ждем
      return;
    }

    // Проверяем, не создана ли уже задача с таким deadline
    const existingChild = await this.prisma.task.findFirst({
      where: {
        parentTaskId: template.id,
        deadline: nextDeadline,
      },
    });

    if (existingChild) {
      this.logger.debug(
        `Task already exists for deadline ${nextDeadline.toISOString()}`,
      );
      return;
    }

    // Создаем новую задачу из шаблона
    await this.createTaskFromTemplate(template, nextDeadline);
  }

  private calculateFirstDeadline(
    recurrenceRule: string,
    templateDeadline: Date,
  ): Date | null {
    try {
      // Для RFC 5545 можно включить текущую дату, чтобы не пропускать 1-е вхождение.
      if (recurrenceRule.includes('FREQ=')) {
        const rule = this.parseRecurrenceRule(recurrenceRule, templateDeadline);
        if (rule.type === 'RRULE' && rule.rrule) {
          return rule.rrule.after(templateDeadline, true);
        }
      }

      // Для legacy-форматов считаем якорную дату первым дедлайном.
      return templateDeadline;
    } catch {
      return null;
    }
  }

  private calculateNextUpcomingDeadline(
    recurrenceRule: string,
    fromDeadline: Date,
    now: Date,
  ): Date | null {
    let candidate = fromDeadline;
    const maxIterations = 1000;

    for (let i = 0; i < maxIterations; i += 1) {
      if (candidate.getTime() > now.getTime()) {
        return candidate;
      }

      const next = this.calculateNextDeadline(recurrenceRule, candidate);
      if (!next) {
        return null;
      }

      candidate = next;
    }

    this.logger.warn(
      `Exceeded max iterations while calculating next upcoming deadline for rule: ${recurrenceRule}`,
    );
    return null;
  }

  /**
   * Создает новую задачу на основе шаблона
   * @param template - родительская задача-шаблон
   * @param deadline - срок выполнения новой задачи
   */
  private async createTaskFromTemplate(template: any, deadline: Date) {
    // Определяем assignee согласно PRD 3.3.3:
    // - Fixed Executor: rotationType = null (берем assigneeId из шаблона)
    // - Automatic Rotation: rotationType указан (используем алгоритм ротации)
    let assigneeId: string | null = template.assigneeId;

    if (template.rotationType && template.rotationType !== 'DISABLED') {
      // Автоматическая ротация
      assigneeId = await this.rotationService.selectAssignee(
        template.groupId,
        template.rotationType as RotationType,
        template.weight || 1,
      );
    } else if (!template.rotationType && !template.assigneeId) {
      // Нет ни фиксированного исполнителя, ни ротации - используем ротацию группы
      const groupRotationType =
        template.group.rotationType || ('ROUND_ROBIN' as RotationType);
      if (groupRotationType !== 'DISABLED') {
        assigneeId = await this.rotationService.selectAssignee(
          template.groupId,
          groupRotationType,
          template.weight || 1,
        );
      }
    }

    const newTask = await this.prisma.task.create({
      data: {
        title: template.title,
        description: template.description,
        deadline,
        priority: template.priority as TaskPriority,
        points: template.points,
        requiresApproval: template.requiresApproval,
        weight: template.weight,
        groupId: template.groupId,
        createdById: template.createdById,
        assigneeId,
        parentTaskId: template.id,
        // Дочерняя задача НЕ является recurring шаблоном
        isRecurring: false,
        recurrenceRule: null,
        rotationType: template.rotationType,
        status: 'PENDING',
      },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            email: true,
            avatarUrl: true,
            isAway: true,
            awayUntil: true,
            createdAt: true,
          },
        },
        assignee: {
          select: {
            id: true,
            username: true,
            email: true,
            avatarUrl: true,
            isAway: true,
            awayUntil: true,
            createdAt: true,
          },
        },
      },
    });

    this.logger.log(
      `Generated new task ${newTask.id} from template ${template.id} with deadline ${deadline.toISOString()}`,
    );

    return newTask;
  }

  /**
   * Вычисляет следующий deadline на основе правила повторения
   * Поддерживает два формата:
   * 1. Упрощенный: "DAILY" | "WEEKLY:1,3,5" | "MONTHLY:1,15"
   * 2. RFC 5545: "FREQ=WEEKLY;BYDAY=MO,WE,FR" (iCalendar формат)
   * @param recurrenceRule - правило повторения
   * @param currentDeadline - текущий deadline
   * @returns следующий deadline или null
   */
  calculateNextDeadline(
    recurrenceRule: string,
    currentDeadline: Date,
  ): Date | null {
    try {
      const rule = this.parseRecurrenceRule(recurrenceRule, currentDeadline);
      
      // Если это RFC 5545 правило, используем rrule библиотеку
      if (rule.type === 'RRULE' && rule.rrule) {
        // after() возвращает следующее вхождение ПОСЛЕ указанной даты
        // inc=false означает "не включать текущую дату", т.е. строго после
        const nextOccurrence = rule.rrule.after(currentDeadline, false);
        return nextOccurrence;
      }

      // Упрощенный формат
      const nextDeadline = new Date(currentDeadline);

      switch (rule.type) {
        case 'DAILY':
          // Каждый день
          nextDeadline.setDate(nextDeadline.getDate() + 1);
          break;

        case 'WEEKLY':
          // Еженедельно в определенные дни (1-7, где 1=Понедельник, 7=Воскресенье)
          if (!rule.values || rule.values.length === 0) {
            // Если дни не указаны, берем тот же день следующей недели
            nextDeadline.setDate(nextDeadline.getDate() + 7);
          } else {
            // Находим следующий подходящий день недели
            const currentDay = nextDeadline.getDay() || 7; // 0 (воскресенье) -> 7
            const sortedDays = rule.values.sort((a, b) => a - b);

            let nextDay = sortedDays.find((day) => day > currentDay);
            if (!nextDay) {
              // Переходим на следующую неделю
              nextDay = sortedDays[0];
              nextDeadline.setDate(nextDeadline.getDate() + 7);
            }

            const daysToAdd = nextDay - currentDay;
            nextDeadline.setDate(nextDeadline.getDate() + daysToAdd);
          }
          break;

        case 'MONTHLY':
          // Ежемесячно в определенные дни (1-31)
          if (!rule.values || rule.values.length === 0) {
            // Если дни не указаны, берем тот же день следующего месяца
            nextDeadline.setMonth(nextDeadline.getMonth() + 1);
          } else {
            const currentDayOfMonth = nextDeadline.getDate();
            const sortedDays = rule.values.sort((a, b) => a - b);

            let nextDayOfMonth = sortedDays.find(
              (day) => day > currentDayOfMonth,
            );
            if (!nextDayOfMonth) {
              // Переходим на следующий месяц
              nextDayOfMonth = sortedDays[0];
              nextDeadline.setMonth(nextDeadline.getMonth() + 1);
            }

            nextDeadline.setDate(nextDayOfMonth);
          }
          break;

        default:
          this.logger.warn(`Unknown recurrence type: ${rule.type}`);
          return null;
      }

      return nextDeadline;
    } catch (error) {
      this.logger.error(
        `Failed to calculate next deadline: ${error.message}`,
        error.stack,
      );
      return null;
    }
  }

  /**
   * Валидация правила повторения при создании/редактировании шаблона.
   */
  validateRecurrenceRule(recurrenceRule: string, templateDeadline: Date): void {
    const firstDeadline = this.calculateFirstDeadline(
      recurrenceRule,
      templateDeadline,
    );

    if (!firstDeadline) {
      throw new Error('Invalid recurrence rule');
    }
  }

  /**
   * Парсит строку правила повторения
   * Поддерживает два формата:
   * 
   * 1. Упрощенный формат:
   *    - "DAILY"
   *    - "WEEKLY:1,3,5" (понедельник, среда, пятница)
   *    - "MONTHLY:1,15" (1-е и 15-е число месяца)
   * 
   * 2. RFC 5545 (iCalendar) формат:
   *    - "FREQ=DAILY"
   *    - "FREQ=WEEKLY;BYDAY=MO,WE,FR"
   *    - "FREQ=WEEKLY;BYDAY=MO,WE,FR;BYHOUR=18;BYMINUTE=30"
   *    - "FREQ=MONTHLY;BYMONTHDAY=1,15"
   */
  private parseRecurrenceRule(rule: string, dtstartDate?: Date): RecurrenceRuleParser {
    // Проверяем, является ли это RFC 5545 правилом
    if (rule.includes('FREQ=')) {
      try {
        // Добавляем DTSTART если его нет (используем переданную дату или текущую)
        let rruleString = rule;
        if (!rruleString.includes('DTSTART')) {
          const startDate = dtstartDate || new Date();
          // Используем UTC формат для DTSTART
          const year = startDate.getUTCFullYear();
          const month = String(startDate.getUTCMonth() + 1).padStart(2, '0');
          const day = String(startDate.getUTCDate()).padStart(2, '0');
          const hours = String(startDate.getUTCHours()).padStart(2, '0');
          const minutes = String(startDate.getUTCMinutes()).padStart(2, '0');
          const seconds = String(startDate.getUTCSeconds()).padStart(2, '0');
          const dtstart = `${year}${month}${day}T${hours}${minutes}${seconds}Z`;
          rruleString = `DTSTART:${dtstart}\nRRULE:${rule}`;
        } else if (!rruleString.includes('RRULE:')) {
          rruleString = `RRULE:${rule}`;
        }
        
        const rrule = rrulestr(rruleString);
        
        // Проверяем валидность правила - пробуем получить хотя бы одно вхождение
        const testDate = rrule.after(new Date(0), false);
        if (!testDate) {
          throw new Error('No valid occurrences found');
        }
        
        return {
          type: 'RRULE',
          rrule,
        };
      } catch (error) {
        this.logger.error(`Failed to parse RFC 5545 rule: ${error.message}`);
        throw new Error(`Invalid RFC 5545 recurrence rule: ${rule}`);
      }
    }

    // Упрощенный формат
    const [type, values] = rule.split(':');

    const parsedRule: RecurrenceRuleParser = {
      type: type as RecurrenceRuleParser['type'],
    };

    if (values) {
      parsedRule.values = values.split(',').map((v) => parseInt(v.trim()));
    }

    return parsedRule;
  }

  /**
   * Ручное создание повторяющейся задачи (для тестирования или форс-генерации)
   * @param taskId - ID шаблона задачи
   */
  async forceGenerateNextTask(taskId: string) {
    const template = await this.prisma.task.findUnique({
      where: { id: taskId },
      include: {
        group: {
          select: {
            id: true,
            rotationType: true,
            name: true,
          },
        },
        childTasks: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
        createdBy: {
          select: {
            id: true,
            username: true,
            email: true,
            avatarUrl: true,
            isAway: true,
            awayUntil: true,
            createdAt: true,
          },
        },
      },
    });

    if (!template || !template.isRecurring) {
      throw new Error('Task is not a recurring template');
    }

    const lastChild = template.childTasks[0];
    const nextDeadline = lastChild
      ? this.calculateNextDeadline(template.recurrenceRule!, lastChild.deadline)
      : this.calculateFirstDeadline(template.recurrenceRule!, template.deadline);

    if (!nextDeadline) {
      throw new Error('Could not calculate next deadline');
    }

    return await this.createTaskFromTemplate(template, nextDeadline);
  }
}
