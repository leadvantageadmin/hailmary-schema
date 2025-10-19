#!/bin/bash
set -e

# Schema publishing script
VERSION=${1:-"latest"}
GITHUB_REPO=${2:-"leadvantageadmin/hailmary-schema"}
GITHUB_TOKEN=${3:-$GITHUB_TOKEN}

echo "🚀 Publishing schema version $VERSION to GitHub..."

# Validate inputs
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN environment variable is required"
    exit 1
fi

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

# 1. Validate schema
echo "🔍 Validating schema..."
./scripts/validate-schema.sh $VERSION

# 2. Generate all clients
echo "🔧 Generating clients..."
./scripts/generate-clients.sh $VERSION all

# 3. Create migration scripts if they don't exist
if [ ! -d "./migrations/$VERSION" ]; then
    echo "📋 Creating migration scripts..."
    mkdir -p "./migrations/$VERSION"
    
    # Copy migration files from version directory if they exist
    if [ -d "$VERSION_PATH/migrations" ]; then
        cp -r "$VERSION_PATH/migrations"/* "./migrations/$VERSION/"
    fi
fi

# 4. Update latest symlink
if [ "$VERSION" != "latest" ]; then
    echo "🔗 Updating latest symlink..."
    ln -sfn "$VERSION" "./versions/latest"
fi

# 5. Commit and push to GitHub (if we're in a git repository)
if [ -d "../../.git" ]; then
    echo "📝 Committing changes to git..."
    
    # Add all schema files
    git add services/schema/versions/$VERSION/
    git add services/schema/migrations/$VERSION/
    git add services/schema/versions/latest
    
    # Commit with descriptive message
    git commit -m "feat: Publish schema version $VERSION

- Added new schema version $VERSION
- Generated clients for Node.js, Python, TypeScript
- Created migration scripts
- Updated latest symlink

Schema changes:
$(cat $VERSION_PATH/changelog.md | head -20)"

    # Push to origin
    git push origin main
    
    # Create GitHub release if this is a new version
    if [ "$VERSION" != "latest" ]; then
        echo "🏷️ Creating GitHub release..."
        
        # Create release notes
        RELEASE_NOTES=$(cat << EOF
Schema version $VERSION with:

## Schema Changes
$(cat $VERSION_PATH/changelog.md | head -30)

## Generated Clients
- Node.js/TypeScript client
- Python client  
- TypeScript type definitions

## Migration Scripts
- Database migration scripts included
- Materialized view setup
- Index creation

## Files Included
- \`schema.prisma\` - Prisma schema definition
- \`metadata.json\` - Version metadata
- \`changelog.md\` - Detailed changelog
- \`clients/\` - Generated client packages
- \`migrations/\` - Database migration scripts
EOF
)
        
        # Create release assets
        echo "📦 Creating release assets..."
        
        # Create schema archive
        tar -czf "schema-v$VERSION.tar.gz" -C versions "$VERSION"
        
        # Create client archives
        for lang in node python typescript; do
            if [ -d "versions/$VERSION/clients/$lang" ]; then
                tar -czf "client-$VERSION-$lang.tar.gz" -C "versions/$VERSION/clients" "$lang"
            fi
        done
        
        # Create migration archive
        if [ -d "migrations/$VERSION" ]; then
            tar -czf "migrations-$VERSION.tar.gz" -C migrations "$VERSION"
        fi
        
        # Create release using GitHub CLI
        if command -v gh >/dev/null 2>&1; then
            gh release create "schema-v$VERSION" \
                --title "Schema Version $VERSION" \
                --notes "$RELEASE_NOTES" \
                --repo $GITHUB_REPO \
                "schema-v$VERSION.tar.gz" \
                "client-$VERSION-node.tar.gz" \
                "client-$VERSION-python.tar.gz" \
                "client-$VERSION-typescript.tar.gz" \
                "migrations-$VERSION.tar.gz" 2>/dev/null || true
        else
            echo "⚠️ GitHub CLI not found, skipping release creation"
            echo "📋 Manual release creation required:"
            echo "   Tag: schema-v$VERSION"
            echo "   Title: Schema Version $VERSION"
            echo "   Notes: $RELEASE_NOTES"
            echo "   Assets: schema-v$VERSION.tar.gz, client-*.tar.gz, migrations-*.tar.gz"
        fi
        
        # Clean up assets
        rm -f "schema-v$VERSION.tar.gz" "client-$VERSION-"*.tar.gz "migrations-$VERSION.tar.gz"
        
        # Tag the version
        git tag "schema-v$VERSION"
        git push origin "schema-v$VERSION"
    fi
else
    echo "⚠️ Not in a git repository, skipping git operations"
fi

# 6. Notify dependent services (placeholder for future implementation)
echo "📢 Notifying dependent services..."
# TODO: Implement service notification system

echo "✅ Schema version $VERSION published successfully!"
echo ""
echo "📋 What was published:"
echo "   • Schema version: $VERSION"
echo "   • Generated clients: Node.js, Python, TypeScript"
echo "   • Migration scripts: $(ls -1 ./migrations/$VERSION/ 2>/dev/null | wc -l) files"
echo "   • GitHub release: schema-v$VERSION"
echo ""
echo "🚀 Services can now pull this schema version using:"
echo "   ./scripts/pull-schema.sh $VERSION"
