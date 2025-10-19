# Schema Version v2.0.0 Changelog

## Overview
**Major Release** - Schema version v2.0.0 represents a significant milestone in the HailMary Schema Service architecture.

## Major Changes
- 🎯 **Stable Schema Service Architecture**: Complete separation of concerns with independent versioning
- 🚀 **Improved Publishing Workflow**: GitHub Actions-based automated releases
- 📦 **Multi-language Client Generation**: Node.js, Python, and TypeScript clients
- 🔧 **Development Tools**: Separate scripts for local development vs. CI/CD
- 📋 **Comprehensive Documentation**: Complete setup and usage guides
- 🏗️ **Modular Design**: Clean separation between schema management and service integration

## Database Tables

### Customer Table (Legacy Support)
- **Purpose**: Maintains backward compatibility with existing system
- **Key Fields**: id, firstName, lastName, email, company, revenue
- **Indexes**: email, company, revenue

### Company Table (New Normalized Structure)
- **Purpose**: Stores company information separately from prospects
- **Key Fields**: id, domain (unique), name, industry, revenue
- **Relationships**: One-to-many with Prospect table

### Prospect Table (New Normalized Structure)
- **Purpose**: Stores individual prospect information
- **Key Fields**: id, firstName, lastName, email, jobTitle, companyId
- **Relationships**: Many-to-one with Company table

### Materialized View Monitoring
- **MaterializedViewLog**: Tracks materialized view refresh operations
- **MaterializedViewError**: Logs materialized view errors

## Key Features
- ✅ Dual ingestion support (Customer + Company/Prospect)
- ✅ Revenue field support with BigInt storage
- ✅ Domain extraction and company normalization

## Migration Notes
- This version is based on latest
- All existing data will be preserved
- New tables will be created alongside existing ones

## Testing
- [ ] Schema validation passed
- [ ] Client generation successful
- [ ] Migration scripts tested
- [ ] Integration tests passed
