# Schema Version v1.0.0 Changelog

## Overview
Initial schema version for HailMary Customer Search Platform with normalized database structure.

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
- ✅ Materialized view system for performance
- ✅ Comprehensive indexing for search optimization
- ✅ Backward compatibility with existing Customer table

## Migration Notes
- This is the initial schema version
- No migration from previous version required
- All tables will be created fresh

## Client Support
- Node.js/TypeScript client generated
- Python client generated
- TypeScript type definitions included

## Performance Considerations
- Indexes on frequently queried fields
- Materialized views for complex joins
- Optimized for both OLTP and OLAP workloads
