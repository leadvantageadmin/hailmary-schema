#!/bin/bash
set -e

# Client generation script
VERSION=${1:-"latest"}
LANGUAGE=${2:-"all"}

echo "🔧 Generating clients for schema version $VERSION..."

# Determine version path
if [ "$VERSION" = "latest" ]; then
    VERSION_PATH="./versions/latest"
else
    VERSION_PATH="./versions/$VERSION"
fi

# Check if version exists
if [ ! -d "$VERSION_PATH" ]; then
    echo "❌ Schema version $VERSION not found at $VERSION_PATH"
    exit 1
fi

# Create clients directory
mkdir -p "$VERSION_PATH/clients"

# Generate Node.js/TypeScript client
if [ "$LANGUAGE" = "node" ] || [ "$LANGUAGE" = "all" ]; then
    echo "📦 Generating Node.js/TypeScript client..."
    
    # Create node client directory
    mkdir -p "$VERSION_PATH/clients/node"
    
    # Copy schema to temp location for generation
    TEMP_DIR=$(mktemp -d)
    cp "$VERSION_PATH/schema.prisma" "$TEMP_DIR/"
    
    cd "$TEMP_DIR"
    
    # Create basic Node.js client structure
    cat > "/app/$VERSION_PATH/clients/node/index.js" << 'EOF'
/**
 * HailMary Prisma Client for Node.js
 * Generated client for database operations
 */

const { PrismaClient } = require('@prisma/client');

class HailMaryClient {
  constructor(options = {}) {
    this.prisma = new PrismaClient(options);
  }

  async connect() {
    await this.prisma.$connect();
  }

  async disconnect() {
    await this.prisma.$disconnect();
  }

  // Customer operations
  async findManyCustomers(where = {}) {
    return this.prisma.customer.findMany({ where });
  }

  async findCustomerById(id) {
    return this.prisma.customer.findUnique({ where: { id } });
  }

  async createCustomer(data) {
    return this.prisma.customer.create({ data });
  }

  async updateCustomer(id, data) {
    return this.prisma.customer.update({ where: { id }, data });
  }

  async deleteCustomer(id) {
    return this.prisma.customer.delete({ where: { id } });
  }

  // Company operations
  async findManyCompanies(where = {}) {
    return this.prisma.company.findMany({ where });
  }

  async findCompanyById(id) {
    return this.prisma.company.findUnique({ where: { id } });
  }

  async findCompanyByDomain(domain) {
    return this.prisma.company.findUnique({ where: { domain } });
  }

  async createCompany(data) {
    return this.prisma.company.create({ data });
  }

  async updateCompany(id, data) {
    return this.prisma.company.update({ where: { id }, data });
  }

  // Prospect operations
  async findManyProspects(where = {}) {
    return this.prisma.prospect.findMany({ where });
  }

  async findProspectById(id) {
    return this.prisma.prospect.findUnique({ where: { id } });
  }

  async findProspectsByCompany(companyId) {
    return this.prisma.prospect.findMany({ where: { companyId } });
  }

  async createProspect(data) {
    return this.prisma.prospect.create({ data });
  }

  async updateProspect(id, data) {
    return this.prisma.prospect.update({ where: { id }, data });
  }

  // Raw query support
  async rawQuery(query, params = []) {
    return this.prisma.$queryRawUnsafe(query, ...params);
  }

  // Transaction support
  async transaction(callback) {
    return this.prisma.$transaction(callback);
  }
}

module.exports = { HailMaryClient, PrismaClient };
EOF

    cat > "/app/$VERSION_PATH/clients/node/package.json" << 'EOF'
{
  "name": "hailmary-prisma-client",
  "version": "1.0.0",
  "description": "HailMary Prisma Client for Node.js",
  "main": "index.js",
  "dependencies": {
    "@prisma/client": "^5.0.0"
  },
  "devDependencies": {
    "prisma": "^5.0.0"
  },
  "keywords": ["prisma", "database", "hailmary"],
  "author": "HailMary Team",
  "license": "MIT"
}
EOF

    echo "✅ Node.js client generated successfully"
    
    cd - >/dev/null
    rm -rf "$TEMP_DIR"
fi

# Generate Python client
if [ "$LANGUAGE" = "python" ] || [ "$LANGUAGE" = "all" ]; then
    echo "🐍 Generating Python client..."
    
    # Create python client directory
    mkdir -p "/app/$VERSION_PATH/clients/python"
    
    # Create basic Python client structure
    cat > "/app/$VERSION_PATH/clients/python/__init__.py" << 'EOF'
"""
HailMary Prisma Client for Python
Generated client for database operations
"""

from .client import PrismaClient
from .types import *

__all__ = ['PrismaClient']
EOF

    cat > "/app/$VERSION_PATH/clients/python/client.py" << 'EOF'
"""
Prisma Client for Python
"""

import os
import psycopg
from typing import List, Dict, Any, Optional

class PrismaClient:
    def __init__(self, database_url: str = None):
        self.database_url = database_url or os.getenv("DATABASE_URL")
        if not self.database_url:
            raise ValueError("DATABASE_URL environment variable is required")
    
    def connect(self):
        """Create database connection"""
        return psycopg.connect(self.database_url)
    
    def find_many_customers(self, **filters) -> List[Dict[str, Any]]:
        """Find multiple customers with optional filters"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                query = "SELECT * FROM \"Customer\""
                params = []
                
                if filters:
                    conditions = []
                    for key, value in filters.items():
                        if value is not None:
                            conditions.append(f'"{key}" = %s')
                            params.append(value)
                    
                    if conditions:
                        query += " WHERE " + " AND ".join(conditions)
                
                cur.execute(query, params)
                columns = [desc[0] for desc in cur.description]
                return [dict(zip(columns, row)) for row in cur.fetchall()]
    
    def find_many_companies(self, **filters) -> List[Dict[str, Any]]:
        """Find multiple companies with optional filters"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                query = "SELECT * FROM \"Company\""
                params = []
                
                if filters:
                    conditions = []
                    for key, value in filters.items():
                        if value is not None:
                            conditions.append(f'"{key}" = %s')
                            params.append(value)
                    
                    if conditions:
                        query += " WHERE " + " AND ".join(conditions)
                
                cur.execute(query, params)
                columns = [desc[0] for desc in cur.description]
                return [dict(zip(columns, row)) for row in cur.fetchall()]
    
    def find_many_prospects(self, **filters) -> List[Dict[str, Any]]:
        """Find multiple prospects with optional filters"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                query = "SELECT * FROM \"Prospect\""
                params = []
                
                if filters:
                    conditions = []
                    for key, value in filters.items():
                        if value is not None:
                            conditions.append(f'"{key}" = %s')
                            params.append(value)
                    
                    if conditions:
                        query += " WHERE " + " AND ".join(conditions)
                
                cur.execute(query, params)
                columns = [desc[0] for desc in cur.description]
                return [dict(zip(columns, row)) for row in cur.fetchall()]
    
    def create_customer(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new customer"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                columns = list(data.keys())
                placeholders = ["%s"] * len(columns)
                values = list(data.values())
                
                query = f"""
                    INSERT INTO "Customer" ({', '.join(f'"{col}"' for col in columns)})
                    VALUES ({', '.join(placeholders)})
                    RETURNING *
                """
                
                cur.execute(query, values)
                columns = [desc[0] for desc in cur.description]
                result = dict(zip(columns, cur.fetchone()))
                conn.commit()
                return result
    
    def create_company(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new company"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                columns = list(data.keys())
                placeholders = ["%s"] * len(columns)
                values = list(data.values())
                
                query = f"""
                    INSERT INTO "Company" ({', '.join(f'"{col}"' for col in columns)})
                    VALUES ({', '.join(placeholders)})
                    RETURNING *
                """
                
                cur.execute(query, values)
                columns = [desc[0] for desc in cur.description]
                result = dict(zip(columns, cur.fetchone()))
                conn.commit()
                return result
    
    def create_prospect(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new prospect"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                columns = list(data.keys())
                placeholders = ["%s"] * len(columns)
                values = list(data.values())
                
                query = f"""
                    INSERT INTO "Prospect" ({', '.join(f'"{col}"' for col in columns)})
                    VALUES ({', '.join(placeholders)})
                    RETURNING *
                """
                
                cur.execute(query, values)
                columns = [desc[0] for desc in cur.description]
                result = dict(zip(columns, cur.fetchone()))
                conn.commit()
                return result
EOF

    cat > "/app/$VERSION_PATH/clients/python/types.py" << 'EOF'
"""
Type definitions for HailMary Prisma Client
"""

from typing import Optional
from datetime import datetime

class Customer:
    def __init__(self, **kwargs):
        self.id: str = kwargs.get('id')
        self.salutation: Optional[str] = kwargs.get('salutation')
        self.firstName: Optional[str] = kwargs.get('firstName')
        self.lastName: Optional[str] = kwargs.get('lastName')
        self.email: Optional[str] = kwargs.get('email')
        self.company: Optional[str] = kwargs.get('company')
        self.address: Optional[str] = kwargs.get('address')
        self.city: Optional[str] = kwargs.get('city')
        self.state: Optional[str] = kwargs.get('state')
        self.country: Optional[str] = kwargs.get('country')
        self.zipCode: Optional[str] = kwargs.get('zipCode')
        self.phone: Optional[str] = kwargs.get('phone')
        self.mobilePhone: Optional[str] = kwargs.get('mobilePhone')
        self.industry: Optional[str] = kwargs.get('industry')
        self.jobTitleLevel: Optional[str] = kwargs.get('jobTitleLevel')
        self.jobTitle: Optional[str] = kwargs.get('jobTitle')
        self.department: Optional[str] = kwargs.get('department')
        self.minEmployeeSize: Optional[int] = kwargs.get('minEmployeeSize')
        self.maxEmployeeSize: Optional[int] = kwargs.get('maxEmployeeSize')
        self.jobTitleLink: Optional[str] = kwargs.get('jobTitleLink')
        self.employeeSizeLink: Optional[str] = kwargs.get('employeeSizeLink')
        self.revenue: Optional[int] = kwargs.get('revenue')
        self.externalSource: str = kwargs.get('externalSource')
        self.externalId: str = kwargs.get('externalId')
        self.createdAt: datetime = kwargs.get('createdAt')
        self.updatedAt: datetime = kwargs.get('updatedAt')

class Company:
    def __init__(self, **kwargs):
        self.id: str = kwargs.get('id')
        self.domain: str = kwargs.get('domain')
        self.name: Optional[str] = kwargs.get('name')
        self.industry: Optional[str] = kwargs.get('industry')
        self.minEmployeeSize: Optional[int] = kwargs.get('minEmployeeSize')
        self.maxEmployeeSize: Optional[int] = kwargs.get('maxEmployeeSize')
        self.employeeSizeLink: Optional[str] = kwargs.get('employeeSizeLink')
        self.revenue: Optional[int] = kwargs.get('revenue')
        self.address: Optional[str] = kwargs.get('address')
        self.city: Optional[str] = kwargs.get('city')
        self.state: Optional[str] = kwargs.get('state')
        self.country: Optional[str] = kwargs.get('country')
        self.zipCode: Optional[str] = kwargs.get('zipCode')
        self.phone: Optional[str] = kwargs.get('phone')
        self.mobilePhone: Optional[str] = kwargs.get('mobilePhone')
        self.externalSource: str = kwargs.get('externalSource')
        self.externalId: str = kwargs.get('externalId')
        self.createdAt: datetime = kwargs.get('createdAt')
        self.updatedAt: datetime = kwargs.get('updatedAt')

class Prospect:
    def __init__(self, **kwargs):
        self.id: str = kwargs.get('id')
        self.salutation: Optional[str] = kwargs.get('salutation')
        self.firstName: Optional[str] = kwargs.get('firstName')
        self.lastName: Optional[str] = kwargs.get('lastName')
        self.email: Optional[str] = kwargs.get('email')
        self.jobTitle: Optional[str] = kwargs.get('jobTitle')
        self.jobTitleLevel: Optional[str] = kwargs.get('jobTitleLevel')
        self.department: Optional[str] = kwargs.get('department')
        self.jobTitleLink: Optional[str] = kwargs.get('jobTitleLink')
        self.address: Optional[str] = kwargs.get('address')
        self.city: Optional[str] = kwargs.get('city')
        self.state: Optional[str] = kwargs.get('state')
        self.country: Optional[str] = kwargs.get('country')
        self.zipCode: Optional[str] = kwargs.get('zipCode')
        self.phone: Optional[str] = kwargs.get('phone')
        self.mobilePhone: Optional[str] = kwargs.get('mobilePhone')
        self.companyId: str = kwargs.get('companyId')
        self.externalSource: str = kwargs.get('externalSource')
        self.externalId: str = kwargs.get('externalId')
        self.createdAt: datetime = kwargs.get('createdAt')
        self.updatedAt: datetime = kwargs.get('updatedAt')
EOF

    echo "✅ Python client generated successfully"
fi

# Generate TypeScript types
if [ "$LANGUAGE" = "typescript" ] || [ "$LANGUAGE" = "all" ]; then
    echo "📝 Generating TypeScript types..."
    
    # Create typescript client directory
    mkdir -p "/app/$VERSION_PATH/clients/typescript"
    
    cat > "/app/$VERSION_PATH/clients/typescript/types.ts" << 'EOF'
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
EOF

    cat > "/app/$VERSION_PATH/clients/typescript/index.ts" << 'EOF'
/**
 * HailMary Prisma Client - TypeScript
 */

export * from './types';

// Re-export Prisma client types if available
export type { PrismaClient } from '@prisma/client';
export type { Customer, Company, Prospect, MaterializedViewLog, MaterializedViewError } from './types';
EOF

    echo "✅ TypeScript types generated successfully"
fi

echo "✅ Client generation completed for schema version $VERSION"
