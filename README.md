# 🗄️ HailMary Schema Service

[![GitHub release](https://img.shields.io/github/release/leadvantageadmin/hailmary-schema.svg)](https://github.com/leadvantageadmin/hailmary-schema/releases)
[![GitHub license](https://img.shields.io/github/license/leadvantageadmin/hailmary-schema.svg)](https://github.com/leadvantageadmin/hailmary-schema/blob/main/LICENSE)

Independent, versioned Prisma schema management service for the HailMary Customer Search Platform.

## 🚀 Quick Start

### For Service Integration

```bash
# Download latest schema version
curl -L https://github.com/leadvantageadmin/hailmary-schema/releases/latest/download/schema-latest.tar.gz | tar -xz

# Download specific version
curl -L https://github.com/leadvantageadmin/hailmary-schema/releases/download/schema-v1.0.0/schema-v1.0.0.tar.gz | tar -xz
```

### For Development

```bash
# Clone the repository
git clone https://github.com/leadvantageadmin/hailmary-schema.git
cd hailmary-schema

# Validate schema
./scripts/validate-schema.sh v1.0.0

# Generate clients
./scripts/generate-clients.sh v1.0.0 all

# Start API server
docker compose up -d schema-api
```

## Overview

This service provides:
- **Versioned Schema Management**: Multiple schema versions with metadata
- **Migration Management**: Database migration scripts for each version
- **GitHub Integration**: Automated publishing and distribution
- **API Access**: REST API for schema access

## Directory Structure

```
services/schema/
├── versions/                    # Versioned schema files
│   ├── v1.0.0/                 # Schema version 1.0.0
│   │   ├── schema.prisma       # Prisma schema definition
│   │   ├── metadata.json       # Version metadata
│   │   └── changelog.md        # Version changelog
│   └── latest -> v1.0.0/       # Symlink to latest version
├── migrations/                 # Database migrations
│   └── v1.0.0/                # Migrations for version 1.0.0
│       ├── 001_initial.sql    # Initial schema
│       └── 002_materialized_views.sql
├── scripts/                    # Management scripts
│   ├── validate-schema.sh     # Validate schema syntax
│   ├── publish.sh             # Publish to GitHub
│   └── schema-api.js          # REST API server
├── config/                     # Configuration files
├── .github/workflows/          # GitHub Actions
└── docker-compose.yml          # Service configuration (use 'docker compose' commands)
```

## Quick Start

### 1. Validate Schema
```bash
# Validate latest schema
./scripts/validate-schema.sh latest

# Validate specific version
./scripts/validate-schema.sh v1.0.0
```

### 2. Client Generation (Removed)
Client generation support has been removed. The service now focuses on schema and migration management only.

### 3. Publish Schema

#### For Local Development
```bash
# Publish for local development (includes Git operations)
export GITHUB_TOKEN=your_token_here
./scripts/publish-dev.sh v1.0.0
```

#### For GitHub Actions (Automated)
```bash
# Publish via GitHub Actions (no Git operations)
# This script is designed to run in CI/CD pipelines
./scripts/publish.sh v1.0.0
```

## Schema Versions

### Current Version: v1.0.0

**Features:**
- Customer table (legacy support)
- Company table (normalized structure)
- Prospect table (normalized structure)
- Revenue field support
- Materialized view system
- Comprehensive indexing

**Tables:**
- `Customer`: Legacy customer data
- `Company`: Normalized company information
- `Prospect`: Normalized prospect information
- `MaterializedViewLog`: View refresh tracking
- `MaterializedViewError`: Error logging

## Client Generation (Removed)

Client generation support has been removed from this service. Services should use the schema files directly with their preferred Prisma client generation tools.

## Migration Management

### Running Migrations
```bash
# Run migrations for specific version
psql $DATABASE_URL -f migrations/v1.0.0/001_initial.sql
psql $DATABASE_URL -f migrations/v1.0.0/002_materialized_views.sql
```

### Migration Scripts
- `001_initial.sql`: Creates all tables and indexes
- `002_materialized_views.sql`: Sets up materialized views and functions

## API Access

### Start API Server
```bash
# Start schema API
node scripts/schema-api.js

# Or using Docker
docker compose up schema-api
```

### API Endpoints
```bash
# Get schema version
GET /api/schema/version/v1.0.0

# List available versions
GET /api/schema/versions

# Get latest version
GET /api/schema/latest

# Get migrations for version
GET /api/schema/migrations/v1.0.0

# Health check
GET /health
```

## GitHub Integration

### Automated Publishing
The service includes GitHub Actions for automated publishing:

```yaml
# Triggers on tag push: schema-v*
# Automatically:
# 1. Validates schema
# 2. Creates GitHub release
# 3. Uploads schema assets
```

### Publishing Workflow
```bash
# 1. Create and tag new version
git tag schema-v1.1.0
git push origin schema-v1.1.0

# 2. GitHub Actions automatically:
#    - Validates schema
#    - Creates release
#    - Uploads schema assets
```

## Service Integration

### Docker Compose
```yaml
services:
  schema-service:
    build: .
    environment:
      - SCHEMA_VERSION=latest
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    volumes:
      - ./versions:/app/versions
      - ./migrations:/app/migrations
```

### Environment Variables
- `SCHEMA_VERSION`: Schema version to use (default: latest)
- `GITHUB_TOKEN`: GitHub token for publishing

## Development

### Adding New Schema Version
```bash
# 1. Create new version directory
mkdir -p versions/v1.1.0

# 2. Copy and modify schema
cp versions/v1.0.0/schema.prisma versions/v1.1.0/

# 3. Update metadata
vim versions/v1.1.0/metadata.json

# 4. Create changelog
vim versions/v1.1.0/changelog.md

# 5. Validate and publish
./scripts/validate-schema.sh v1.1.0
./scripts/publish.sh v1.1.0
```

### Client Generation (Removed)
Client generation support has been removed. Services should generate their own Prisma clients using the schema files.

## Best Practices

### Schema Versioning
- Use semantic versioning (v1.0.0, v1.1.0, v2.0.0)
- Document breaking changes in metadata
- Provide migration scripts for all versions
- Test migrations before publishing

### Schema Distribution
- Include schema.prisma, migrations, changelog.md, and metadata.json in releases
- Test schema with sample data
- Document schema changes in changelog

### Migration Management
- Create atomic migration scripts
- Test migrations on sample data
- Provide rollback scripts when possible
- Document migration requirements

## Troubleshooting

### Common Issues

**Schema validation fails:**
```bash
# Check Prisma syntax
npx prisma validate --schema=versions/v1.0.0/schema.prisma
```

**Schema validation fails:**
```bash
# Check Prisma installation
npx prisma --version
```

**Publishing fails:**
```bash
# Check GitHub token
echo $GITHUB_TOKEN

# Check repository access
gh auth status
```

### Logs and Debugging
```bash
# Enable debug mode
export DEBUG=1

# Check service logs
docker-compose logs schema-service

# Check API logs
docker-compose logs schema-api
```

## Contributing

1. Create feature branch
2. Make changes to schema or scripts
3. Test with validation scripts
4. Update documentation
5. Submit pull request

## License

Part of the HailMary Customer Search Platform.
