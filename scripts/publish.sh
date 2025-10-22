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

# 2. Skip client generation (removed support)
echo "⏭️ Skipping client generation (support removed)"

# 3. Create release assets
echo "📦 Creating release assets..."

# Define the output directory as the mounted volume
OUTPUT_DIR="/app"

# Create schema archive
tar -czf "$OUTPUT_DIR/schema-$VERSION.tar.gz" -C versions "$VERSION"

# Skip client archives (support removed)
echo "⏭️ Skipping client archive creation (support removed)"

# Note: Migration files are included in the schema archive
# No separate migration archive needed since schema archive contains everything

# 4. Prepare release assets (GitHub Actions will handle release creation)
echo "📦 Release assets prepared:"
echo "   • schema-$VERSION.tar.gz (complete package with migrations, changelog, and metadata)"
echo ""
echo "ℹ️  GitHub Actions will create the release with these assets"

echo "✅ Schema version $VERSION published successfully!"
echo ""
echo "📋 What was published:"
echo "   • Schema version: $VERSION"
echo "   • Schema file: schema.prisma"
echo "   • Migration scripts: $(ls -1 ./versions/$VERSION/migrations/ 2>/dev/null | wc -l) files"
echo "   • Changelog: changelog.md"
echo "   • Metadata: metadata.json"
echo "   • GitHub release: schema-$VERSION"
echo ""
echo "🚀 Services can now pull this schema version using:"
echo "   ./scripts/pull-schema.sh $VERSION"