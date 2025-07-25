#!/bin/bash

# Setup and commit script for Moallem monorepo
# This script creates the entire project structure and makes the initial commit

set -e

echo "🚀 Setting up Moallem monorepo..."

# Initialize git if not already
if [ ! -d .git ]; then
    git init
    echo "✅ Initialized git repository"
fi

# Create branch for Linear ticket
git checkout -b makram2122/mo-5-bootstrap-moallem-monorepo

# Create project structure
echo "📁 Creating project structure..."

# Create directories
mkdir -p apps/{mobile,api}/src \
  packages/{ui,types,config}/src \
  infrastructure/{terraform/{environments/{dev,staging,prod},modules/{ecs,rds,vpc,s3,cloudfront},shared},docker} \
  scripts \
  .github/workflows \
  apps/api/src/{services/{auth,user,course,gateway},shared/{database,cache,queue,utils},config}

# Create root package.json
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

# Create pnpm-workspace.yaml
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

# Create turbo.json
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

# Create .gitignore
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

# Create .env.example
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

# Create docker-compose.yml
mkdir -p infrastructure/docker
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

# Create API Dockerfile
cat > infrastructure/docker/api.Dockerfile << 'EOF'
# Build stage
FROM node:20-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@8.14.0 --activate

WORKDIR /app

# Copy workspace files
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml turbo.json ./
COPY packages ./packages
COPY apps/api ./apps/api

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the application
RUN pnpm --filter @moallem/api... build

# Production stage
FROM node:20-alpine AS runner

# Install pnpm
RUN corepack enable && corepack prepare pnpm@8.14.0 --activate

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy built application
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/packages ./packages
COPY --from=builder --chown=nodejs:nodejs /app/apps/api ./apps/api
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./package.json
COPY --from=builder --chown=nodejs:nodejs /app/pnpm-workspace.yaml ./pnpm-workspace.yaml

USER nodejs

EXPOSE 3000

CMD ["node", "apps/api/dist/index.js"]
EOF

# Create app package.json files
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

# Create package.json files for shared packages
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

# Create GitHub Actions CI workflow
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
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8.14.0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run linter
        run: pnpm lint

      - name: Run type check
        run: pnpm turbo run type-check

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
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8.14.0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run tests
        run: pnpm test
        env:
          NODE_ENV: test
          DATABASE_URL: postgresql://moallem:password@localhost:5432/moallem_test
          REDIS_URL: redis://localhost:6379

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8.14.0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build packages
        run: pnpm build

      - name: Build Docker images
        run: |
          docker build -f infrastructure/docker/api.Dockerfile -t moallem-api:ci .
EOF

# Create Terraform main.tf
cat > infrastructure/terraform/main.tf << 'EOF'
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Configure backend in environment-specific files
  }
}

# Main VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id              = module.vpc.vpc_id
  database_subnet_ids = module.vpc.private_subnet_ids
  
  engine_version      = var.rds_engine_version
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  
  database_name       = var.database_name
  master_username     = var.database_username
  
  backup_retention_period = var.rds_backup_retention_period
  backup_window          = var.rds_backup_window
  maintenance_window     = var.rds_maintenance_window
  
  allowed_security_groups = [module.ecs.service_security_group_id]
  
  tags = local.common_tags
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  
  # Service configurations
  services = {
    gateway = {
      cpu                = 512
      memory             = 1024
      desired_count      = 2
      port              = 3000
      health_check_path = "/health"
      priority          = 100
    }
    auth = {
      cpu                = 256
      memory             = 512
      desired_count      = 2
      port              = 3001
      health_check_path = "/health"
      priority          = 200
    }
  }
  
  tags = local.common_tags
}

# Locals
locals {
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
EOF

# Create comprehensive README
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
   git clone https://github.com/your-org/moallem-monorepo.git
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

Start specific apps:
```bash
# API only
pnpm --filter @moallem/api dev

# Mobile only
pnpm --filter @moallem/mobile dev
```

## 📱 Mobile Development

### iOS
```bash
cd apps/mobile
pnpm ios
```

### Android
```bash
cd apps/mobile
pnpm android
```

## 🔧 Backend Development

The API uses a microservices architecture with the following services:
- **Gateway**: API gateway and request routing
- **Auth**: Authentication and authorization
- **User**: User management
- **Course**: Course content and management

## 🧪 Testing

Run all tests:
```bash
pnpm test
```

Run tests for specific package:
```bash
pnpm --filter @moallem/api test
```

## 📊 CI/CD

The project uses GitHub Actions for:
- **CI**: Linting, testing, and building on every push
- **CD**: Automated deployment to AWS on merge to main

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

---

Built with ❤️ by the Moallem Team
EOF

# Create basic tsconfig files
cat > apps/api/tsconfig.json << 'EOF'
{
  "extends": "@moallem/config/typescript/base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
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

# Create placeholder index files
mkdir -p apps/api/src
cat > apps/api/src/index.ts << 'EOF'
// Placeholder for API entry point
console.log("Moallem API starting...");
EOF

mkdir -p packages/ui/src
cat > packages/ui/src/index.ts << 'EOF'
// UI components exports
export {};
EOF

mkdir -p packages/types/src
cat > packages/types/src/index.ts << 'EOF'
// Shared types exports
export {};
EOF

echo "✅ All files created!"
echo ""
echo "📝 Creating git commit with Linear ticket reference..."

# Stage all files
git add .

# Create commit with Linear ticket reference
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

echo "✅ Commit created with Linear ticket reference!"
echo ""
echo "📤 Now push to GitHub:"
echo ""
echo "1. Add the remote repository:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/moallem-monorepo.git"
echo ""
echo "2. Push the branch:"
echo "   git push -u origin makram2122/mo-5-bootstrap-moallem-monorepo"
echo ""
echo "3. The Linear ticket will automatically update when you push!"
echo ""
echo "4. Create a PR to main branch to complete the workflow"
