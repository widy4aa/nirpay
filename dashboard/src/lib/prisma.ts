/* eslint-disable @typescript-eslint/no-explicit-any */
// Prisma client singleton
// Note: This file is a placeholder. The dashboard fetches data via API, not direct Prisma.
// If you need direct DB access, generate the client first: npx prisma generate

const globalForPrisma = globalThis as unknown as {
  prisma: any;
};

export const prisma = globalForPrisma.prisma ?? null;

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
