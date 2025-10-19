#!/bin/bash
set -e

# Script to create a new schema version
# Usage: ./scripts/create-version.sh [major|minor|patch] [base_version]
# Usage: ./scripts/create-version.sh <specific_version> [base_version]

BUMP_TYPE=${1:-"minor"}
BASE_VERSION=${2:-"latest"}

# Function to get the latest version number
get_latest_version() {
    local latest_dir=""
    local latest_version=""
    
    # Find the latest version directory (excluding 'latest' symlink)
    for dir in versions/*/; do
        if [ -d "$dir" ] && [ "$(basename "$dir")" != "latest" ]; then
            local version_name=$(basename "$dir")
            if [ -z "$latest_dir" ] || [[ "$version_name" > "$latest_dir" ]]; then
                latest_dir="$version_name"
            fi
        fi
    done
    
    if [ -z "$latest_dir" ]; then
        echo "v1.0.0"  # Default first version
    else
        # Check if the directory name already has 'v' prefix
        if [[ "$latest_dir" =~ ^v[0-9] ]]; then
            echo "$latest_dir"
        else
            echo "v$latest_dir"
        fi
    fi
}

# Function to bump version
bump_version() {
    local current_version="$1"
    local bump_type="$2"
    
    # Remove 'v' prefix
    local version=$(echo "$current_version" | sed 's/^v//')
    
    # Split version into parts
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)
    local patch=$(echo "$version" | cut -d. -f3)
    
    case "$bump_type" in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            echo "❌ Invalid bump type: $bump_type"
            echo "Valid types: major, minor, patch"
            exit 1
            ;;
    esac
    
    echo "v$major.$minor.$patch"
}

# Determine the version to create
if [[ "$BUMP_TYPE" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Specific version provided
    VERSION="$BUMP_TYPE"
    echo "🎯 Creating specific version: $VERSION"
else
    # Bump type provided, get latest version and bump it
    LATEST_VERSION=$(get_latest_version)
    VERSION=$(bump_version "$LATEST_VERSION" "$BUMP_TYPE")
    echo "📈 Creating $BUMP_TYPE version bump: $LATEST_VERSION → $VERSION"
fi

# For directory names, we want to keep the 'v' prefix
VERSION_DIR="$VERSION"
BASE_VERSION_DIR="$BASE_VERSION"

# Ensure we use the correct base version directory
if [ "$BASE_VERSION" = "latest" ]; then
    # Find the actual latest version directory
    BASE_VERSION_DIR=$(ls -1 versions/ | grep -v latest | sort -V | tail -1)
    if [ -z "$BASE_VERSION_DIR" ]; then
        echo "❌ No base version found for 'latest'"
        exit 1
    fi
    echo "🔗 Using latest version: $BASE_VERSION_DIR"
fi

VERSION_PATH="./versions/$VERSION_DIR"
BASE_VERSION_PATH="./versions/$BASE_VERSION_DIR"

echo "🚀 Creating new schema version $VERSION..."

# Check if version already exists
if [ -d "$VERSION_PATH" ]; then
    echo "❌ Version $VERSION already exists at $VERSION_PATH"
    exit 1
fi

# Check if base version exists
if [ ! -d "$BASE_VERSION_PATH" ]; then
    echo "❌ Base version $BASE_VERSION not found at $BASE_VERSION_PATH"
    echo "Available versions:"
    ls -1 versions/ | grep -v latest | sed 's/^/  - /'
    exit 1
fi

# Create version directory
echo "📁 Creating version directory: $VERSION_PATH"
mkdir -p "$VERSION_PATH"

# Copy base version files
echo "📋 Copying files from base version $BASE_VERSION..."
cp -r "$BASE_VERSION_PATH"/* "$VERSION_PATH/"

# Update metadata.json
echo "📝 Updating metadata.json..."
cat > "$VERSION_PATH/metadata.json" << EOF
{
  "version": "$VERSION",
  "author": "HailMary Team",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "baseVersion": "$BASE_VERSION",
  "description": "Schema version $VERSION based on $BASE_VERSION",
  "changelog": "changelog.md",
  "schemaFile": "schema.prisma",
  "migrationScripts": [
    "migrations/001_initial_schema.sql",
    "migrations/002_materialized_views.sql"
  ],
  "compatibility": {
    "minPrismaVersion": "5.0.0",
    "testedWith": ["5.0.0", "5.1.0"]
  },
  "features": [
    "Customer table (legacy support)",
    "Company table (normalized)",
    "Prospect table (normalized)",
    "Materialized view monitoring",
    "Revenue field support",
    "Domain extraction"
  ],
  "dependencies": {
    "prisma": "^5.0.0",
    "@prisma/client": "^5.0.0"
  }
}
EOF

# Create changelog.md
echo "📝 Creating changelog.md..."
cat > "$VERSION_PATH/changelog.md" << EOF
# Schema Version $VERSION Changelog

## Overview
Schema version $VERSION based on $BASE_VERSION.

## Changes from $BASE_VERSION
- [ ] Add your changes here

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
- This version is based on $BASE_VERSION
- All existing data will be preserved
- New tables will be created alongside existing ones

## Testing
- [ ] Schema validation passed
- [ ] Client generation successful
- [ ] Migration scripts tested
- [ ] Integration tests passed
EOF

# Create migration directory if it doesn't exist
if [ ! -d "migrations/$VERSION_DIR" ]; then
    echo "📁 Creating migration directory: migrations/$VERSION_DIR"
    mkdir -p "migrations/$VERSION_DIR"
    
    # Copy base migrations if they exist
    if [ -d "migrations/$BASE_VERSION_DIR" ]; then
        echo "📋 Copying migration scripts from base version..."
        cp -r "migrations/$BASE_VERSION_DIR"/* "migrations/$VERSION_DIR/"
    else
        echo "📝 Creating default migration scripts..."
        # Create initial migration
        cat > "migrations/$VERSION_DIR/001_initial_schema.sql" << 'EOF'
-- Migration: Initial schema setup
-- Version: v1.0.0
-- Description: Creates initial database schema

-- This migration is handled by Prisma
-- Run: npx prisma db push
EOF

        # Create materialized view migration
        cat > "migrations/$VERSION_DIR/002_materialized_views.sql" << 'EOF'
-- Migration: Materialized views setup
-- Version: v1.0.0
-- Description: Creates materialized views and monitoring tables

-- Create materialized view for company-prospect joins
CREATE MATERIALIZED VIEW IF NOT EXISTS company_prospect_view AS
SELECT
    c.id AS company_id,
    c.domain,
    c.name AS company_name,
    c.industry,
    c.revenue,
    p.id AS prospect_id,
    p."firstName",
    p."lastName",
    p.email,
    p."jobTitle"
FROM "Company" c
JOIN "Prospect" p ON c.id = p."companyId";

-- Create index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_company_prospect_view_prospect_id 
ON company_prospect_view (prospect_id);

-- Create refresh function
CREATE OR REPLACE FUNCTION refresh_materialized_views_safe()
RETURNS VOID AS $$
DECLARE
    start_time timestamptz;
    end_time timestamptz;
    duration_ms int;
    view_name text;
    error_message text;
BEGIN
    view_name := 'company_prospect_view';
    start_time := clock_timestamp();
    
    BEGIN
        REFRESH MATERIALIZED VIEW CONCURRENTLY company_prospect_view;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        
        INSERT INTO materialized_view_log ("view_name", "refresh_type", "refreshed_at", "duration_ms")
        VALUES (view_name, 'manual', NOW(), duration_ms);
        
        RAISE NOTICE 'Materialized view % refreshed successfully in % ms', view_name, duration_ms;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            INSERT INTO materialized_view_errors ("view_name", "error_message", "occurred_at")
            VALUES (view_name, error_message, NOW());
            RAISE WARNING 'Failed to refresh materialized view %: %', view_name, error_message;
    END;
END;
$$ LANGUAGE plpgsql;
EOF
    fi
fi

# Update the latest symlink to point to the new version
echo "🔗 Updating latest symlink..."
if [ -L "versions/latest" ]; then
    rm "versions/latest"
fi
ln -s "$VERSION_DIR" "versions/latest"
echo "✅ Latest symlink updated to point to $VERSION_DIR"

echo "✅ Schema version $VERSION created successfully!"
echo ""
echo "📋 What was created:"
echo "   • Version directory: $VERSION_PATH"
echo "   • Schema file: $VERSION_PATH/schema.prisma"
echo "   • Metadata: $VERSION_PATH/metadata.json"
echo "   • Changelog: $VERSION_PATH/changelog.md"
echo "   • Migration scripts: migrations/$VERSION_DIR/"
echo "   • Latest symlink: versions/latest -> $VERSION_DIR"
echo ""
echo "🚀 Next steps:"
echo "   1. Edit $VERSION_PATH/schema.prisma if needed"
echo "   2. Update $VERSION_PATH/changelog.md with your changes"
echo "   3. Test the schema: ./scripts/validate-schema.sh $VERSION"
echo "   4. Generate clients: ./scripts/generate-clients.sh $VERSION all"
echo "   5. Publish: ./scripts/publish.sh $VERSION"
echo ""
echo "💡 Usage examples:"
echo "   # Create minor version bump (default)"
echo "   ./scripts/create-version.sh"
echo ""
echo "   # Create major version bump"
echo "   ./scripts/create-version.sh major"
echo ""
echo "   # Create patch version bump"
echo "   ./scripts/create-version.sh patch"
echo ""
echo "   # Create specific version"
echo "   ./scripts/create-version.sh v2.0.0"
echo ""
echo "💡 To edit the schema:"
echo "   nano $VERSION_PATH/schema.prisma"
echo ""
echo "💡 To edit the changelog:"
echo "   nano $VERSION_PATH/changelog.md"
