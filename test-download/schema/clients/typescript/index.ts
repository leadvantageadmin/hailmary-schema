/**
 * HailMary Prisma Client - TypeScript
 */

export * from './types';

// Re-export Prisma client types if available
export type { PrismaClient } from '@prisma/client';
export type { Customer, Company, Prospect, MaterializedViewLog, MaterializedViewError } from './types';
