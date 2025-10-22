# Schema Version v3.0.0 Changelog

## Overview
Schema version v3.0.0 based on latest.

## Changes from latest
- ✅ Added User authentication system
- ✅ Added UserRole enum (ADMIN, USER)
- ✅ Added User table with proper indexes
- ✅ Added migration script for User authentication tables

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

### User Table (Authentication System)
- **Purpose**: Stores user authentication and authorization data
- **Key Fields**: id, email (unique), password (hashed), firstName, lastName, role, isActive
- **Relationships**: Standalone table for user management
- **Indexes**: email (unique), role

### Materialized View Monitoring
- **MaterializedViewLog**: Tracks materialized view refresh operations
- **MaterializedViewError**: Logs materialized view errors

## Key Features
- ✅ Dual ingestion support (Customer + Company/Prospect)
- ✅ User authentication and authorization system
- ✅ UserRole enum with ADMIN and USER roles
- ✅ Revenue field support with BigInt storage
- ✅ Domain extraction and company normalization

## Migration Notes
- This version is based on latest
- All existing data will be preserved
- New User table and UserRole enum will be created
- User authentication system is now available
- Backward compatibility maintained for all existing tables

## Testing
- [ ] Schema validation passed
- [ ] Client generation successful
- [ ] Migration scripts tested
- [ ] Integration tests passed
