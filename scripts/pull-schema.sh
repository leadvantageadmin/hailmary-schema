#!/bin/bash
set -e

# Schema pulling script for services
VERSION=${1:-"latest"}
LANGUAGE=${2:-"all"}
TARGET_DIR=${3:-"./schema"}
GITHUB_REPO=${4:-"leadvantageadmin/hailmary-schema"}

echo "📥 Pulling schema version $VERSION for language $LANGUAGE..."

# Create target directory
mkdir -p "$TARGET_DIR"

# Determine download URL
if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/latest/download/schema-latest.tar.gz"
    VERSION_FILE="latest"
else
    DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/schema-v$VERSION/schema-v$VERSION.tar.gz"
    VERSION_FILE="v$VERSION"
fi

# Download and extract schema
echo "🔽 Downloading schema from GitHub..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if curl -L -o schema.tar.gz "$DOWNLOAD_URL"; then
    echo "✅ Schema downloaded successfully"
    
    # Extract schema
    tar -xzf schema.tar.gz
    
    # Copy to target directory
    if [ -d "versions/$VERSION_FILE" ]; then
        cp -r "versions/$VERSION_FILE"/* "$TARGET_DIR/"
        echo "✅ Schema extracted to $TARGET_DIR"
    else
        echo "❌ Schema version $VERSION_FILE not found in download"
        exit 1
    fi
else
    echo "❌ Failed to download schema from GitHub"
    echo "📋 Available versions:"
    curl -s "https://api.github.com/repos/$GITHUB_REPO/releases" | grep '"tag_name"' | head -5
    exit 1
fi

# Clean up
cd - >/dev/null
rm -rf "$TEMP_DIR"

# Download specific client if requested
if [ "$LANGUAGE" != "all" ]; then
    echo "📦 Downloading $LANGUAGE client..."
    CLIENT_URL="https://github.com/$GITHUB_REPO/releases/download/schema-v$VERSION/client-$VERSION-$LANGUAGE.tar.gz"
    
    if curl -L -o client.tar.gz "$CLIENT_URL"; then
        tar -xzf client.tar.gz -C "$TARGET_DIR/clients/$LANGUAGE/"
        echo "✅ $LANGUAGE client downloaded"
        rm -f client.tar.gz
    else
        echo "⚠️ Failed to download $LANGUAGE client, but schema is available"
    fi
fi

echo "✅ Schema version $VERSION pulled successfully to $TARGET_DIR"
echo ""
echo "📋 What was downloaded:"
echo "   • Schema version: $VERSION"
echo "   • Target directory: $TARGET_DIR"
echo "   • Client language: $LANGUAGE"
echo ""
echo "🚀 Usage:"
echo "   • Schema file: $TARGET_DIR/schema.prisma"
echo "   • Metadata: $TARGET_DIR/metadata.json"
echo "   • Clients: $TARGET_DIR/clients/"
echo "   • Migrations: $TARGET_DIR/migrations/"
