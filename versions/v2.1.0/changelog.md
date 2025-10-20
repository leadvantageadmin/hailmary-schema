# Schema Version v2.1.0 Changelog

## Overview
Schema version v2.1.0 based on latest.

## Changes from latest
- **Company Model**: Changed primary key from auto-generated UUID to domain-based ID
- **Prospect Model**: Changed primary key from auto-generated UUID to email-based ID  
- **Foreign Key Relationship**: Updated Prospect.companyId to reference Company.domain instead of Company.id
- **ID Generation**: Implemented meaningful ID generation logic for better data relationships

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
- **BREAKING CHANGE**: This version changes primary key generation logic
- Company records will use domain as primary key instead of auto-generated UUID
- Prospect records will use email as primary key instead of auto-generated UUID
- Foreign key constraints need to be updated to reference Company.domain
- Existing data migration required for ID updates

## Testing
- [ ] Schema validation passed
- [ ] Client generation successful
- [ ] Migration scripts tested
- [ ] Integration tests passed
