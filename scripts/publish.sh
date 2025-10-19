#!/bin/bash
set -e

# GitHub Actions publishing script
# This script is designed to run in GitHub Actions and only creates release assets
# For local development, use publish-dev.sh instead

VERSION=${1:-"latest"}
GITHUB_REPO=${GITHUB_REPO:-"leadvantageadmin/hailmary-schema"}

echo "🚀 Publishing schema version $VERSION to GitHub..."

# 1. Validate schema
echo "🔍 Validating schema..."
./scripts/validate-schema.sh "$VERSION"

# 2. Generate clients
echo "🔧 Generating clients..."
./scripts/generate-clients.sh "$VERSION" all

# 3. Create release assets
echo "📦 Creating release assets..."

# Define the output directory as the mounted volume
OUTPUT_DIR="/app"

# Create schema archive
tar -czf "$OUTPUT_DIR/schema-$VERSION.tar.gz" -C versions "$VERSION"

# Create client archives
for lang in node python typescript; do
    if [ -d "versions/$VERSION/clients/$lang" ]; then
        tar -czf "$OUTPUT_DIR/client-$VERSION-$lang.tar.gz" -C "versions/$VERSION/clients" "$lang"
    fi
done

# Create migration archive
if [ -d "migrations/$VERSION" ]; then
    tar -czf "$OUTPUT_DIR/migrations-$VERSION.tar.gz" -C migrations "$VERSION"
fi

# 4. Prepare release assets (GitHub Actions will handle release creation)
echo "📦 Release assets prepared:"
echo "   • schema-$VERSION.tar.gz"
echo "   • client-$VERSION-node.tar.gz"
echo "   • client-$VERSION-python.tar.gz"
echo "   • client-$VERSION-typescript.tar.gz"
echo "   • migrations-$VERSION.tar.gz"
echo ""
echo "ℹ️  GitHub Actions will create the release with these assets"

echo "✅ Schema version $VERSION published successfully!"
echo ""
echo "📋 What was published:"
echo "   • Schema version: $VERSION"
echo "   • Generated clients: Node.js, Python, TypeScript"
echo "   • Migration scripts: $(ls -1 ./migrations/$VERSION/ 2>/dev/null | wc -l) files"
echo "   • GitHub release: schema-$VERSION"
echo ""
echo "🚀 Services can now pull this schema version using:"
echo "   ./scripts/pull-schema.sh $VERSION"