#!/bin/bash
set -e

# Environment setup script for HailMary Schema Service

echo "🔧 Setting up HailMary Schema Service environment..."

# Check if GitHub CLI is installed
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "📋 Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "📋 Please run: gh auth login"
    exit 1
fi

# Get GitHub token
echo "🔑 Getting GitHub token..."
GITHUB_TOKEN=$(gh auth token)

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Failed to get GitHub token"
    exit 1
fi

echo "✅ GitHub token obtained"

# Create .env file
echo "📝 Creating .env file..."
cat > .env << EOF
# HailMary Schema Service Environment Configuration
# Generated on $(date)

# GitHub Configuration
GITHUB_TOKEN=$GITHUB_TOKEN
GITHUB_REPO=leadvantageadmin/hailmary-schema

# Schema Configuration
SCHEMA_VERSION=latest
CLIENT_LANGUAGES=node,python,typescript

# API Configuration
PORT=3001
NODE_ENV=development

# Docker Configuration
DOCKER_REGISTRY=ghcr.io/leadvantageadmin
DOCKER_IMAGE_NAME=hailmary-schema
EOF

echo "✅ .env file created"

# Set environment variables for current session
export GITHUB_TOKEN
export GITHUB_REPO=leadvantageadmin/hailmary-schema
export SCHEMA_VERSION=latest
export CLIENT_LANGUAGES=node,python,typescript

echo "✅ Environment variables set for current session"

# Test GitHub access
echo "🧪 Testing GitHub access..."
if gh api user >/dev/null 2>&1; then
    echo "✅ GitHub access confirmed"
else
    echo "❌ GitHub access failed"
    exit 1
fi

# Test repository access
echo "🧪 Testing repository access..."
if gh repo view leadvantageadmin/hailmary-schema >/dev/null 2>&1; then
    echo "✅ Repository access confirmed"
else
    echo "❌ Repository access failed"
    exit 1
fi

echo ""
echo "🎉 Environment setup completed successfully!"
echo ""
echo "📋 What was configured:"
echo "   • GitHub token: ${GITHUB_TOKEN:0:20}..."
echo "   • Repository: leadvantageadmin/hailmary-schema"
echo "   • Environment file: .env"
echo "   • Current session variables: Set"
echo ""
echo "🚀 You can now run:"
echo "   • ./scripts/validate-schema.sh v1.0.0"
echo "   • ./scripts/generate-clients.sh v1.0.0 all"
echo "   • ./scripts/publish.sh v1.0.0"
echo "   • docker-compose up -d schema-api"
