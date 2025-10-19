#!/bin/bash
set -e

# Git setup script for Docker container

echo "🔧 Setting up Git in Docker container..."

# Configure git user (use local config if global fails)
git config user.name "leadvantageadmin" || git config --global user.name "leadvantageadmin"
git config user.email "leadvantageadmin@users.noreply.github.com" || git config --global user.email "leadvantageadmin@users.noreply.github.com"

# Configure git to use GitHub token for authentication
if [ -n "$GITHUB_TOKEN" ]; then
    echo "🔑 Configuring Git with GitHub token..."
    
    # Set up credential helper (use local config if global fails)
    git config credential.helper store || git config --global credential.helper store
    
    # Create credential file
    echo "https://leadvantageadmin:$GITHUB_TOKEN@github.com" > ~/.git-credentials
    
    # Test git access
    echo "🧪 Testing Git access..."
    if git ls-remote origin >/dev/null 2>&1; then
        echo "✅ Git access confirmed"
    else
        echo "❌ Git access failed"
        exit 1
    fi
else
    echo "⚠️ GITHUB_TOKEN not set, skipping Git authentication setup"
fi

echo "✅ Git setup completed"
