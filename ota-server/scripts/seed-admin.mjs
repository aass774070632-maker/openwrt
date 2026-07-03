import * as argon2 from 'argon2';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const email = (process.env.ADMIN_EMAIL || 'admin@example.com').toLowerCase();
  const password = process.env.ADMIN_PASSWORD || 'CHANGE_ME';
  const passwordHash = await argon2.hash(password);

  const admin = await prisma.adminUser.upsert({
    where: { email },
    update: {
      passwordHash,
      role: 'admin',
    },
    create: {
      email,
      passwordHash,
      role: 'admin',
    },
  });

  console.log(JSON.stringify({ id: admin.id, email: admin.email, role: admin.role }, null, 2));
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
