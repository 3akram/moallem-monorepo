#!/bin/bash

set -e

echo "🚀 Setting up Moallem development environment..."

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm is not installed. Please install pnpm first:"
    echo "   npm install -g pnpm@8.14.0"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version must be 18 or higher. Current version: $(node -v)"
    exit 1
fi

echo "✅ Prerequisites checked"

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

# Setup environment files
echo "🔧 Setting up environment files..."
node scripts/env-setup.js

# Build packages
echo "🏗️  Building packages..."
pnpm build

# Database setup (optional)
read -p "Do you want to set up the local database? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🐘 Starting PostgreSQL and Redis..."
    pnpm docker:up
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to be ready..."
    sleep 10
    
    echo "✅ Database services are running"
fi

echo "🎉 Setup complete! You can now run:"
echo "   pnpm dev    - Start development servers"
echo "   pnpm test   - Run tests"
echo "   pnpm lint   - Run linting"
