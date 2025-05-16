import pkg from '@prisma/client';
const { PrismaClient } = pkg;
export const db = new PrismaClient();