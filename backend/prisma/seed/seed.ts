import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';
import 'dotenv/config';

const prisma = new PrismaClient({});

async function main() {
  console.log('🌱 Starting seed...');

  // Create Super Admin User
  const adminEmail = 'admin@nirpay.com';
  
  const existingAdmin = await prisma.user.findUnique({
    where: { email: adminEmail },
  });

  if (!existingAdmin) {
    const pinHash = await argon2.hash('123456', {
      type: argon2.argon2id,
    });

    const admin = await prisma.user.create({
      data: {
        email: adminEmail,
        phoneNumber: '0000000000',
        username: 'superadmin',
        fullName: 'Super Admin',
        passwordHash: pinHash, // Assuming standard password field
        pinHash: pinHash,      // Nirpay PIN
        publicKeyB64: 'admin_public_key_mock',
        role: 'SUPER_ADMIN',
        isActive: true,
        kycStatus: 'APPROVED',
      },
    });

    await prisma.walletBalance.create({
      data: {
        userId: admin.id,
        amountCent: BigInt(100000000), // 1 million logic representation
      },
    });

    console.log(`✅ Super Admin created with email: ${adminEmail}`);
  } else {
    console.log(`⚠️ Super Admin with email ${adminEmail} already exists. Skipping.`);
  }

  console.log('🌱 Seeding finished.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
