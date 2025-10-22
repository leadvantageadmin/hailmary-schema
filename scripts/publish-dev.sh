#!/bin/bash
set -e

# Development publishing script for local use
# This script includes Git operations and is meant for local development/testing

VERSION=${1:-"latest"}
GITHUB_REPO=${GITHUB_REPO:-"leadvantageadmin/hailmary-schema"}

echo "🚀 Publishing schema version $VERSION for development..."

# 1. Validate schema
echo "🔍 Validating schema..."
./scripts/validate-schema.sh "$VERSION"

# 2. Skip client generation (removed support)
echo "⏭️ Skipping client generation (support removed)"

# 3. Update latest symlink
echo "🔗 Updating latest symlink..."
if [ "$VERSION" != "latest" ]; then
    if [ -L "versions/latest" ]; then
        rm "versions/latest"
    fi
    ln -s "$VERSION" "versions/latest"
    echo "✅ Latest symlink updated to point to $VERSION"
fi

# 4. Setup Git (for local development)
echo "🔧 Setting up Git..."
./scripts/setup-git.sh

# 5. Create release assets
echo "📦 Creating release assets..."

# Create schema archive
tar -czf "schema-$VERSION.tar.gz" -C versions "$VERSION"

# Skip client archives (support removed)
echo "⏭️ Skipping client archive creation (support removed)"

# Create migration archive
if [ -d "migrations/$VERSION" ]; then
    tar -czf "migrations-$VERSION.tar.gz" -C migrations "$VERSION"
fi

# 6. Create GitHub release (if GitHub CLI is available)
if command -v gh >/dev/null 2>&1; then
    echo "📤 Creating GitHub release..."
    
    # Generate release notes
    RELEASE_NOTES="Schema version $VERSION

## What's included:
- Schema file: schema.prisma
- Generated clients: Node.js, Python, TypeScript
- Migration scripts: $(ls -1 ./migrations/$VERSION/ 2>/dev/null | wc -l) files

## Usage:
\`\`\`bash
# Download latest version
curl -L https://github.com/$GITHUB_REPO/releases/latest/download/schema-latest.tar.gz | tar -xz

# Download specific version
curl -L https://github.com/$GITHUB_REPO/releases/download/schema-$VERSION/schema-$VERSION.tar.gz | tar -xz
\`\`\`"

    # Create release using GitHub CLI
    gh release create "schema-$VERSION" \
        --title "Schema Version $VERSION" \
        --notes "$RELEASE_NOTES" \
        --repo $GITHUB_REPO \
        "schema-$VERSION.tar.gz" \
        "migrations-$VERSION.tar.gz" 2>/dev/null || true
else
    echo "⚠️ GitHub CLI not found, skipping release creation"
    echo "📋 Manual release creation required:"
    echo "   Tag: schema-$VERSION"
    echo "   Title: Schema Version $VERSION"
    echo "   Assets: schema-$VERSION.tar.gz, migrations-*.tar.gz"
fi

# 7. Git operations (for local development)
if [ -d ".git" ]; then
    echo "🔧 Performing Git operations..."
    
    # Add and commit changes
    git add .
    git commit -m "feat: Publish schema version $VERSION

- Add schema version $VERSION
- Update latest symlink
- Include migration scripts, changelog, and metadata" || echo "⚠️ No changes to commit"
    
    # Tag the version
    git tag "schema-$VERSION" || echo "⚠️ Tag already exists"
    git push origin "schema-$VERSION" || echo "⚠️ Failed to push tag"
    git push origin main || echo "⚠️ Failed to push main"
else
    echo "⚠️ Not in a git repository, skipping git operations"
fi

# Clean up assets
rm -f "schema-$VERSION.tar.gz" "migrations-$VERSION.tar.gz"

echo "✅ Schema version $VERSION published successfully for development!"
echo ""
echo "📋 What was published:"
echo "   • Schema version: $VERSION"
echo "   • Schema file: schema.prisma"
echo "   • Migration scripts: $(ls -1 ./migrations/$VERSION/ 2>/dev/null | wc -l) files"
echo "   • Changelog: changelog.md"
echo "   • Metadata: metadata.json"
echo "   • GitHub release: schema-$VERSION"
echo ""
echo "🚀 Services can now pull this schema version using:"
echo "   ./scripts/pull-schema.sh $VERSION"
