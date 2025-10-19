#!/bin/bash
set -e

# Schema validation script
VERSION=${1:-"latest"}

echo "🔍 Validating schema version $VERSION..."

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

# Check if schema.prisma exists
if [ ! -f "$VERSION_PATH/schema.prisma" ]; then
    echo "❌ schema.prisma not found in $VERSION_PATH"
    exit 1
fi

# Check if metadata.json exists
if [ ! -f "$VERSION_PATH/metadata.json" ]; then
    echo "❌ metadata.json not found in $VERSION_PATH"
    exit 1
fi

# Validate Prisma schema syntax
echo "📋 Validating Prisma schema syntax..."
if command -v npx >/dev/null 2>&1; then
    cd "$VERSION_PATH"
    # Set a dummy DATABASE_URL for validation
    export DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
    if npx prisma validate --schema=schema.prisma; then
        echo "✅ Prisma schema syntax is valid"
    else
        echo "❌ Prisma schema syntax validation failed"
        exit 1
    fi
    cd - >/dev/null
else
    echo "⚠️ npx not found, skipping Prisma validation"
fi

# Validate metadata.json
echo "📋 Validating metadata.json..."
if command -v jq >/dev/null 2>&1; then
    if jq empty "$VERSION_PATH/metadata.json" 2>/dev/null; then
        echo "✅ metadata.json is valid JSON"
        
        # Check required fields
        REQUIRED_FIELDS=("version" "createdAt" "author" "description" "dependencies")
        for field in "${REQUIRED_FIELDS[@]}"; do
            if ! jq -e ".$field" "$VERSION_PATH/metadata.json" >/dev/null 2>&1; then
                echo "❌ Required field '$field' missing in metadata.json"
                exit 1
            fi
        done
        echo "✅ All required metadata fields present"
    else
        echo "❌ metadata.json is not valid JSON"
        exit 1
    fi
else
    echo "⚠️ jq not found, skipping metadata validation"
fi

# Check for changelog
if [ -f "$VERSION_PATH/changelog.md" ]; then
    echo "✅ Changelog found"
else
    echo "⚠️ Changelog not found (optional)"
fi

echo "✅ Schema version $VERSION validation completed successfully"
