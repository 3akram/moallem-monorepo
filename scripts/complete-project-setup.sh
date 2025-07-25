#!/bin/bash

# Complete Moallem Project Setup Script
# This script creates the GitHub repo and sets up everything end-to-end

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USERNAME=""
REPO_NAME="moallem-monorepo"
REPO_DESCRIPTION="Educational app monorepo"

echo -e "${GREEN}🚀 Moallem Complete Project Setup${NC}"
echo ""

# Check prerequisites
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed. Please install it first.${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
check_command git
check_command gh
check_command node
check_command pnpm

# Check if GitHub CLI is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI is not authenticated.${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

# Get GitHub username if not set
if [ -z "$GITHUB_USERNAME" ]; then
    GITHUB_USERNAME=$(gh api user -q .login)
    echo -e "${GREEN}✅ GitHub username: $GITHUB_USERNAME${NC}"
fi

# Step 1: Create GitHub repository
echo ""
echo -e "${YELLOW}📦 Creating GitHub repository...${NC}"

# Check if repo already exists
if gh repo view "$GITHUB_USERNAME/$REPO_NAME" &> /dev/null; then
    echo -e "${YELLOW}⚠️  Repository already exists. Using existing repository.${NC}"
else
    gh repo create "$REPO_NAME" --public --description "$REPO_DESCRIPTION" --clone=false
    echo -e "${GREEN}✅ Repository created: https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
fi

# Step 2: Initialize local repository
echo ""
echo -e "${YELLOW}📁 Setting up local repository...${NC}"

# Create and enter directory
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# Initialize git
if [ ! -d .git ]; then
    git init
    echo -e "${GREEN}✅ Git repository initialized${NC}"
fi

# Add remote
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo -e "${GREEN}✅ Remote origin added${NC}"

# Step 3: Create branch for Linear ticket
echo ""
echo -e "${YELLOW}🌿 Creating feature branch...${NC}"
git checkout -b makram2122/mo-5-bootstrap-moallem-monorepo

# Step 4: Create project structure
echo ""
echo -e "${YELLOW}🏗️  Creating project structure...${NC}"

# Create all directories
mkdir -p apps/{mobile,api}/src \
  packages/{ui,types,config}/src \
  infrastructure/{terraform/{environments/{dev,staging,prod},modules/{ecs,rds,vpc,s3,cloudfront},shared},docker} \
  scripts \
  .github/workflows \
  apps/api/src/{services/{auth,user,course,gateway},shared/{database,cache,queue,utils},config} \
  apps/mobile/{assets,components,screens,hooks,services,navigation}

# Step 5: Create all configuration files
echo -e "${YELLOW}📝 Creating configuration files...${NC}"

# Root package.json
cat > package.json << 'EOF'
{
  "name": "moallem",
  "version": "1.0.0",
  "private": true,
  "description": "Production-ready educational app monorepo",
  "author": "Moallem Team",
  "license": "MIT",
  "engines": {
    "node": ">=18.0.0",
    "pnpm": ">=8.0.0"
  },
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "test": "turbo run test",
    "lint": "turbo run lint",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "clean": "turbo run clean && rm -rf node_modules",
    "prepare": "husky install",
    "docker:up": "docker-compose -f infrastructure/docker/docker-compose.yml up",
    "docker:down": "docker-compose -f infrastructure/docker/docker-compose.yml down",
    "setup": "pnpm install && pnpm run setup:env",
    "setup:env": "node scripts/env-setup.js"
  },
  "devDependencies": {
    "@changesets/cli": "^2.27.1",
    "@types/node": "^20.11.0",
    "eslint": "^8.56.0",
    "husky": "^8.0.3",
    "lint-staged": "^15.2.0",
    "prettier": "^3.2.4",
    "turbo": "^1.12.0",
    "typescript": "^5.3.3"
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,yml}": [
      "prettier --write"
    ]
  },
  "packageManager": "pnpm@8.14.0"
}
EOF

# pnpm-workspace.yaml
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

# turbo.json
cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**", "build/**"],
      "env": ["NODE_ENV", "API_URL", "DATABASE_URL"]
    },
    "dev": {
      "cache": false,
      "persistent": true,
      "env": ["NODE_ENV", "API_URL", "DATABASE_URL", "REDIS_URL"]
    },
    "lint": {
      "dependsOn": ["^lint"]
    },
    "test": {
      "dependsOn": ["build"],
      "env": ["NODE_ENV"],
      "outputs": ["coverage/**"]
    },
    "clean": {
      "cache": false
    },
    "type-check": {
      "dependsOn": ["^type-check"]
    }
  }
}
EOF

# .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
.nyc_output/

# Production
dist/
build/
*.log

# Environment files
.env
.env.local
.env.*.local
!.env.example

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Turborepo
.turbo/

# Mobile
apps/mobile/.expo/
apps/mobile/.expo-shared/
apps/mobile/dist/
apps/mobile/*.jks
apps/mobile/*.p8
apps/mobile/*.p12
apps/mobile/*.key
apps/mobile/*.mobileprovision
apps/mobile/*.orig.*
apps/mobile/web-build/

# Terraform
infrastructure/terraform/**/.terraform/
infrastructure/terraform/**/*.tfstate
infrastructure/terraform/**/*.tfstate.*
infrastructure/terraform/**/*.tfvars
!infrastructure/terraform/**/*.tfvars.example
infrastructure/terraform/**/.terraform.lock.hcl

# Docker
infrastructure/docker/data/

# Misc
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.npm
.eslintcache
.cache/
tmp/
temp/
EOF

# .env.example
cat > .env.example << 'EOF'
# Environment
NODE_ENV=development

# API Configuration
API_PORT=3000
API_HOST=localhost
API_BASE_URL=http://localhost:3000

# Database
DATABASE_URL=postgresql://moallem:password@localhost:5432/moallem_dev
DB_HOST=localhost
DB_PORT=5432
DB_NAME=moallem_dev
DB_USER=moallem
DB_PASSWORD=password
DB_SSL=false

# Redis
REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# S3 Bucket
S3_BUCKET_NAME=moallem-assets-dev
S3_BUCKET_REGION=us-east-1

# CloudFront
CLOUDFRONT_DISTRIBUTION_ID=
CLOUDFRONT_DOMAIN=

# Authentication
JWT_SECRET=your-super-secret-jwt-key-change-this
JWT_EXPIRY=7d
REFRESH_TOKEN_SECRET=your-refresh-token-secret-change-this
REFRESH_TOKEN_EXPIRY=30d

# Email (AWS SES)
SES_FROM_EMAIL=noreply@moallem.app
SES_REGION=us-east-1

# Mobile App
EXPO_PUBLIC_API_URL=http://localhost:3000
EXPO_PUBLIC_ENVIRONMENT=development

# Monitoring
SENTRY_DSN=
LOG_LEVEL=debug

# Feature Flags
ENABLE_PUSH_NOTIFICATIONS=false
ENABLE_ANALYTICS=false
EOF

# Docker Compose
cat > infrastructure/docker/docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: moallem
      POSTGRES_PASSWORD: password
      POSTGRES_DB: moallem_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - moallem-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U moallem"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - moallem-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  localstack:
    image: localstack/localstack:latest
    environment:
      - SERVICES=s3,ses,cloudfront
      - DEBUG=0
      - DATA_DIR=/tmp/localstack/data
      - DOCKER_HOST=unix:///var/run/docker.sock
    ports:
      - "4566:4566"
    volumes:
      - "${TMPDIR:-/tmp}/localstack:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    networks:
      - moallem-network

volumes:
  postgres_data:
  redis_data:

networks:
  moallem-network:
    driver: bridge
EOF

# API Dockerfile
cat > infrastructure/docker/api.Dockerfile << 'EOF'
FROM node:20-alpine AS builder
RUN corepack enable && corepack prepare pnpm@8.14.0 --activate
WORKDIR /app
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml turbo.json ./
COPY packages ./packages
COPY apps/api ./apps/api
RUN pnpm install --frozen-lockfile
RUN pnpm --filter @moallem/api... build

FROM node:20-alpine AS runner
RUN corepack enable && corepack prepare pnpm@8.14.0 --activate
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/packages ./packages
COPY --from=builder --chown=nodejs:nodejs /app/apps/api ./apps/api
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./package.json
COPY --from=builder --chown=nodejs:nodejs /app/pnpm-workspace.yaml ./pnpm-workspace.yaml
USER nodejs
EXPOSE 3000
CMD ["node", "apps/api/dist/index.js"]
EOF

# Create package.json files for all packages
# API package.json
cat > apps/api/package.json << 'EOF'
{
  "name": "@moallem/api",
  "version": "1.0.0",
  "private": true,
  "description": "Moallem API microservices backend",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "lint": "eslint src --ext .ts",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist coverage"
  },
  "dependencies": {
    "@moallem/types": "workspace:*",
    "@trpc/server": "^10.45.0",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "dotenv": "^16.3.1",
    "zod": "^3.22.4",
    "winston": "^3.11.0",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "ioredis": "^5.3.2",
    "pg": "^8.11.3",
    "drizzle-orm": "^0.29.3",
    "drizzle-kit": "^0.20.13",
    "@aws-sdk/client-s3": "^3.490.0",
    "@aws-sdk/client-ses": "^3.490.0",
    "@aws-sdk/s3-request-presigner": "^3.490.0",
    "bullmq": "^5.1.0",
    "rate-limiter-flexible": "^3.0.6"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/compression": "^1.7.5",
    "@types/bcryptjs": "^2.4.6",
    "@types/jsonwebtoken": "^9.0.5",
    "tsx": "^4.7.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.11",
    "ts-jest": "^29.1.1",
    "@moallem/config": "workspace:*"
  }
}
EOF

# Mobile package.json
cat > apps/mobile/package.json << 'EOF'
{
  "name": "@moallem/mobile",
  "version": "1.0.0",
  "private": true,
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "dev": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "test": "jest",
    "lint": "eslint src --ext .ts,.tsx",
    "type-check": "tsc --noEmit",
    "build:ios": "eas build --platform ios",
    "build:android": "eas build --platform android",
    "build": "eas build --platform all"
  },
  "dependencies": {
    "@moallem/ui": "workspace:*",
    "@moallem/types": "workspace:*",
    "expo": "~50.0.0",
    "expo-status-bar": "~1.11.1",
    "react": "18.2.0",
    "react-native": "0.73.2",
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/native-stack": "^6.9.17",
    "@react-navigation/bottom-tabs": "^6.5.11",
    "react-native-screens": "~3.29.0",
    "react-native-safe-area-context": "4.8.2",
    "@tanstack/react-query": "^5.17.0",
    "@trpc/client": "^10.45.0",
    "@trpc/react-query": "^10.45.0",
    "expo-secure-store": "~12.8.1",
    "expo-constants": "~15.4.5",
    "expo-device": "~5.9.3",
    "expo-notifications": "~0.27.6",
    "expo-localization": "~14.8.3",
    "react-native-reanimated": "~3.6.1",
    "react-native-gesture-handler": "~2.14.0",
    "zustand": "^4.4.7"
  },
  "devDependencies": {
    "@babel/core": "^7.23.7",
    "@types/react": "~18.2.45",
    "@types/react-native": "~0.73.0",
    "typescript": "^5.3.3",
    "jest": "^29.7.0",
    "jest-expo": "~50.0.1",
    "@testing-library/react-native": "^12.4.3",
    "@moallem/config": "workspace:*"
  }
}
EOF

# UI package.json
cat > packages/ui/package.json << 'EOF'
{
  "name": "@moallem/ui",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "type-check": "tsc --noEmit",
    "lint": "eslint src --ext .ts,.tsx",
    "test": "jest"
  },
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.73.2",
    "react-native-svg": "14.1.0",
    "@shopify/restyle": "^2.4.2"
  },
  "devDependencies": {
    "@types/react": "~18.2.45",
    "@types/react-native": "~0.73.0",
    "typescript": "^5.3.3",
    "jest": "^29.7.0",
    "@testing-library/react-native": "^12.4.3",
    "@moallem/config": "workspace:*"
  },
  "peerDependencies": {
    "react": "*",
    "react-native": "*"
  }
}
EOF

# Types package.json
cat > packages/types/package.json << 'EOF'
{
  "name": "@moallem/types",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "type-check": "tsc --noEmit",
    "lint": "eslint src --ext .ts"
  },
  "dependencies": {
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@moallem/config": "workspace:*"
  }
}
EOF

# Config package.json
cat > packages/config/package.json << 'EOF'
{
  "name": "@moallem/config",
  "version": "1.0.0",
  "private": true,
  "main": "index.js",
  "files": [
    "eslint",
    "typescript"
  ]
}
EOF

# GitHub Actions workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 8.14.0
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint

  test:
    name: Test
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: moallem
          POSTGRES_PASSWORD: password
          POSTGRES_DB: moallem_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 8.14.0
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm test
        env:
          NODE_ENV: test
          DATABASE_URL: postgresql://moallem:password@localhost:5432/moallem_test
          REDIS_URL: redis://localhost:6379

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 8.14.0
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
      - run: docker build -f infrastructure/docker/api.Dockerfile -t moallem-api:ci .
EOF

# Terraform files
cat > infrastructure/terraform/main.tf << 'EOF'
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Module definitions will go here
EOF

# Create README
cat > README.md << 'EOF'
# Moallem - Educational Platform

A production-ready educational platform built with modern technologies and best practices.

## 🏗 Architecture

This monorepo contains:
- **Mobile App**: Cross-platform iOS/Android app built with Expo
- **API**: Microservices backend with TypeScript
- **Shared Packages**: UI components, types, and configurations

## 🛠 Tech Stack

- **Frontend**: React Native (Expo)
- **Backend**: Node.js, Express/tRPC, TypeScript
- **Database**: PostgreSQL with Drizzle ORM
- **Cache**: Redis
- **Infrastructure**: AWS (ECS, RDS, S3, CloudFront)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions
- **Development**: Docker, Turborepo, pnpm

## 📁 Project Structure

```
moallem/
├── apps/
│   ├── mobile/     # Expo mobile application
│   └── api/        # Backend microservices
├── packages/
│   ├── ui/         # Shared UI components
│   ├── types/      # TypeScript type definitions
│   └── config/     # Shared configurations
├── infrastructure/
│   ├── terraform/  # Infrastructure as Code
│   └── docker/     # Docker configurations
└── scripts/        # Build and utility scripts
```

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18
- pnpm >= 8.0.0
- Docker & Docker Compose
- AWS CLI (for deployment)
- Terraform (for infrastructure)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/${GITHUB_USERNAME}/moallem-monorepo.git
   cd moallem-monorepo
   ```

2. Install dependencies:
   ```bash
   pnpm install
   ```

3. Copy environment variables:
   ```bash
   cp .env.example .env
   ```

4. Start Docker services:
   ```bash
   pnpm docker:up
   ```

### Development

Start all services:
```bash
pnpm dev
```

## 📄 License

This project is licensed under the MIT License.

---

Built with ❤️ by the Moallem Team
EOF

# Create TypeScript configs
cat > apps/api/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "allowJs": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > apps/mobile/tsconfig.json << 'EOF'
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "jsx": "react-native",
    "strict": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
EOF

# Create placeholder source files
echo "// API entry point" > apps/api/src/index.ts
echo "// UI components" > packages/ui/src/index.ts
echo "// Shared types" > packages/types/src/index.ts

# Create app.json for mobile
cat > apps/mobile/app.json << 'EOF'
{
  "expo": {
    "name": "Moallem",
    "slug": "moallem",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "light",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": [
      "**/*"
    ],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.moallem.app"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.moallem.app"
    },
    "web": {
      "favicon": "./assets/favicon.png"
    }
  }
}
EOF

echo -e "${GREEN}✅ All files created!${NC}"

# Step 6: Commit with Linear reference
echo ""
echo -e "${YELLOW}📝 Creating commit with Linear reference...${NC}"

git add .
git commit -m "feat: Bootstrap Moallem monorepo structure [MO-5]

- Initialize Turborepo monorepo with pnpm
- Set up apps structure (mobile with Expo, API with Express/tRPC)
- Create shared packages (ui, types, config)
- Add Docker configuration for local development
- Configure Terraform infrastructure scaffolding
- Set up GitHub Actions CI pipeline
- Add comprehensive documentation

This commit establishes the foundation for the Moallem educational platform
with a scalable microservices architecture and modern development practices.

Linear: MO-5
"

echo -e "${GREEN}✅ Commit created!${NC}"

# Step 7: Push to GitHub
echo ""
echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"

git push -u origin makram2122/mo-5-bootstrap-moallem-monorepo

echo -e "${GREEN}✅ Code pushed to GitHub!${NC}"

# Step 8: Create Pull Request
echo ""
echo -e "${YELLOW}🔄 Creating Pull Request...${NC}"

PR_URL=$(gh pr create \
  --title "feat: Bootstrap Moallem monorepo [MO-5]" \
  --body "## Summary
Bootstrap the Moallem monorepo with complete project structure

## Linear Issue
Closes MO-5

## Changes
- Initialize Turborepo monorepo with pnpm
- Set up apps structure (mobile with Expo, API with Express/tRPC)
- Create shared packages (ui, types, config)
- Add Docker configuration for local development
- Configure Terraform infrastructure scaffolding
- Set up GitHub Actions CI pipeline
- Add comprehensive documentation

## Testing
- [ ] Run \`pnpm install\` successfully
- [ ] Docker services start with \`pnpm docker:up\`
- [ ] TypeScript compiles without errors
- [ ] CI workflow passes

## Next Steps
After merging this PR, we can proceed with:
- MO-6: Setup Expo Mobile App
- MO-7: Create Authentication Microservice
- MO-8: Setup Terraform AWS Infrastructure" \
  --base main \
  --head makram2122/mo-5-bootstrap-moallem-monorepo)

echo -e "${GREEN}✅ Pull Request created: $PR_URL${NC}"

# Step 9: Summary
echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo ""
echo "✅ GitHub repository created: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "✅ Code pushed to branch: makram2122/mo-5-bootstrap-moallem-monorepo"
echo "✅ Pull Request created: $PR_URL"
echo ""
echo "📋 Linear Integration:"
echo "- The PR is now linked to Linear ticket MO-5"
echo "- When you merge the PR, the ticket will move to 'Done'"
echo ""
echo "🚀 Next Steps:"
echo "1. Review and merge the PR"
echo "2. Install dependencies: cd $REPO_NAME && pnpm install"
echo "3. Start development: pnpm dev"
echo ""
echo -e "${YELLOW}Happy coding! 🚀${NC}"
