/**
 * Type definitions for HailMary Prisma Client
 */

export interface Customer {
  id: string;
  salutation?: string | null;
  firstName?: string | null;
  lastName?: string | null;
  email?: string | null;
  company?: string | null;
  address?: string | null;
  city?: string | null;
  state?: string | null;
  country?: string | null;
  zipCode?: string | null;
  phone?: string | null;
  mobilePhone?: string | null;
  industry?: string | null;
  jobTitleLevel?: string | null;
  jobTitle?: string | null;
  department?: string | null;
  minEmployeeSize?: number | null;
  maxEmployeeSize?: number | null;
  jobTitleLink?: string | null;
  employeeSizeLink?: string | null;
  revenue?: bigint | null;
  externalSource: string;
  externalId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Company {
  id: string;
  domain: string;
  name?: string | null;
  industry?: string | null;
  minEmployeeSize?: number | null;
  maxEmployeeSize?: number | null;
  employeeSizeLink?: string | null;
  revenue?: bigint | null;
  address?: string | null;
  city?: string | null;
  state?: string | null;
  country?: string | null;
  zipCode?: string | null;
  phone?: string | null;
  mobilePhone?: string | null;
  externalSource: string;
  externalId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Prospect {
  id: string;
  salutation?: string | null;
  firstName?: string | null;
  lastName?: string | null;
  email?: string | null;
  jobTitle?: string | null;
  jobTitleLevel?: string | null;
  department?: string | null;
  jobTitleLink?: string | null;
  address?: string | null;
  city?: string | null;
  state?: string | null;
  country?: string | null;
  zipCode?: string | null;
  phone?: string | null;
  mobilePhone?: string | null;
  companyId: string;
  externalSource: string;
  externalId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface MaterializedViewLog {
  id: number;
  viewName: string;
  refreshType: string;
  refreshedAt: Date;
  durationMs?: number | null;
  recordsProcessed?: number | null;
}

export interface MaterializedViewError {
  id: number;
  viewName?: string | null;
  errorMessage?: string | null;
  occurredAt: Date;
}
