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
