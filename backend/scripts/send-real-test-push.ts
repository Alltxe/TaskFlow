import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { NotificationService } from '../src/modules/notification/notification.service';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { FirebaseService } from '../src/modules/firebase/firebase.service';

async function main() {
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn', 'log'],
  });

  try {
    const notificationService = app.get(NotificationService);
    const prisma = app.get(PrismaService);
    const firebaseService = app.get(FirebaseService);

    const deviceToken = await prisma.deviceToken.findFirst({
      select: { userId: true },
    });

    if (!deviceToken) {
      console.log(JSON.stringify({ success: false, reason: 'no_device_tokens' }, null, 2));
      return;
    }

    const user = await prisma.user.findUnique({
      where: { id: deviceToken.userId },
      select: { id: true, email: true, username: true },
    });

    const tokenCount = await prisma.deviceToken.count({
      where: { userId: deviceToken.userId },
    });

    const firebaseReady = firebaseService.isInitialized();
    const title = 'TaskFlow: тестовое уведомление';
    const body = `Проверка реальной отправки push (${new Date().toLocaleString('ru-RU')})`;

    const results = await notificationService.testPushToUser(
      deviceToken.userId,
      title,
      body,
      { type: 'SYSTEM', source: 'send-real-test-push-script' },
    );

    const successCount = results.filter((result) => result.success).length;
    const failureCount = results.length - successCount;

    console.log(
      JSON.stringify(
        {
          success: successCount > 0,
          firebaseReady,
          user,
          deviceTokenCount: tokenCount,
          sent: results.length,
          successCount,
          failureCount,
          results: results.map((result) => ({
            success: result.success,
            messageId: result.messageId ?? null,
            error: result.error ?? null,
          })),
        },
        null,
        2,
      ),
    );

    if (results.length === 0) {
      process.exitCode = 1;
    } else if (successCount === 0) {
      process.exitCode = 1;
    }
  } finally {
    await app.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
