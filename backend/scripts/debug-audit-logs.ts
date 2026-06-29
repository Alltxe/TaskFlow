import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const all = await prisma.auditLog.findMany({
    include: { user: { select: { email: true } } },
    orderBy: { performedAt: 'desc' },
  });
  console.log('all logs:', all.length);
  for (const l of all) {
    console.log(
      l.action,
      l.entityType,
      'userId=',
      l.userId,
      l.user?.email,
      'newValues=',
      JSON.stringify(l.newValues),
    );
  }

  const groupId = process.argv[2];
  const userId = process.argv[3];

  if (groupId) {
    const groupTasks = await prisma.task.findMany({
      where: { groupId },
      select: { id: true },
    });
    const taskIds = groupTasks.map((task) => task.id);

    const groupLogs = await prisma.auditLog.findMany({
      where: {
        OR: [
          { entityType: 'Group', entityId: groupId },
          { entityType: 'GroupMember', entityId: { startsWith: `${groupId}-` } },
          {
            entityType: 'PointTransaction',
            newValues: { path: ['groupId'], equals: groupId },
          },
          {
            entityType: 'Task',
            newValues: { path: ['groupId'], equals: groupId },
          },
          ...(taskIds.length > 0
            ? [
                { entityType: 'Task', entityId: { in: taskIds } },
                { entityType: 'PointTransaction', entityId: { in: taskIds } },
              ]
            : []),
        ],
      },
    });
    console.log('expanded group query:', groupLogs.length, groupLogs.map((l) => l.action));
  }

  if (userId) {
    const userLogs = await prisma.auditLog.findMany({ where: { userId } });
    console.log('user logs:', userLogs.length, userLogs.map((l) => l.action));
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
