import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Starting database seed...');

  // Создаем тестового пользователя для тестов
  const testUserEmail = 'user@example.com';
  const testUserPassword = 'password123';

  // Проверяем, существует ли пользователь
  const existingUser = await prisma.user.findUnique({
    where: { email: testUserEmail },
  });

  if (!existingUser) {
    const passwordHash = await bcrypt.hash(testUserPassword, 10);

    const user = await prisma.user.create({
      data: {
        email: testUserEmail,
        username: 'testuser',
        passwordHash,
      },
    });

    console.log('Test user created:', {
      id: user.id,
      email: user.email,
      username: user.username,
    });
  } else {
    console.log('Test user already exists:', {
      id: existingUser.id,
      email: existingUser.email,
    });
  }

  console.log('Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('Error during seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
