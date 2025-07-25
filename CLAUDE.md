# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Moallem is a production-ready educational app monorepo using pnpm workspaces and Turborepo. The project consists of:

- **API service** (`apps/api/`) - Backend services with microservice architecture
- **Mobile app** (`apps/mobile/`) - React Native mobile application
- **Shared packages** (`packages/`) - Common configurations, types, and UI components
- **Infrastructure** (`infrastructure/`) - Docker and Terraform configurations for deployment

## Development Commands

### Core Commands
```bash
# Install dependencies
pnpm install

# Development mode (runs all apps)
pnpm dev

# Build all packages
pnpm build

# Run tests
pnpm test

# Lint code
pnpm lint

# Format code
pnpm format

# Type checking
pnpm turbo run type-check

# Clean build artifacts
pnpm clean
```

### Docker Commands
```bash
# Start local development environment
pnpm docker:up

# Stop local development environment
pnpm docker:down
```

### Initial Setup
```bash
# Complete setup including environment
pnpm setup

# Just setup environment variables
pnpm setup:env
```

## Architecture

### Monorepo Structure
- Uses **pnpm workspaces** with packages in `apps/*` and `packages/*`
- **Turborepo** manages build pipeline with proper dependency ordering
- Shared dependencies and configurations across packages

### Backend Architecture (`apps/api/`)
- **Microservice-based** with services for auth, user, course, and gateway
- **Shared infrastructure** includes cache, database, queue, and utilities
- Uses PostgreSQL for database and Redis for caching
- AWS services integration (S3, CloudFront, SES)

### Infrastructure
- **Docker Compose** for local development environment
- **Terraform modules** for AWS deployment:
  - VPC, ECS, RDS, S3, CloudFront
  - Separate configurations for dev, staging, and production

### Key Technologies
- Node.js (>=18.0.0) and pnpm (>=8.0.0)
- TypeScript across all packages
- PostgreSQL and Redis for data storage
- AWS services for cloud infrastructure
- Husky and lint-staged for pre-commit hooks

## Environment Configuration

Copy `.env.sample` to `.env` and configure:
- Database credentials (PostgreSQL)
- Redis connection
- AWS credentials and services
- JWT secrets for authentication
- API and mobile app URLs