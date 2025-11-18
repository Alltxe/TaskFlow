import { PrismaClient } from '@prisma/client';

// Hold a single client reference to ensure proper shutdown
let prisma: PrismaClient | null = null;

async function ensureDisconnect() {
  try {
    if (!prisma) {
      prisma = new PrismaClient();
    }
    await prisma.$disconnect();
  } catch {
    // ignore
  }
}

module.exports = async () => {
  await ensureDisconnect();
  // Give event loop a brief tick to settle pending timers/listeners
  await new Promise((resolve) => setTimeout(resolve, 25));
};
