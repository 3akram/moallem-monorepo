# Moallem - Educational Platform

A production-ready educational application built with modern technologies and best practices.

## 🏗 Architecture

Moallem is a monorepo-based application using:

- **Frontend**: React Native (Expo) for cross-platform mobile app
- **Backend**: Node.js microservices with tRPC
- **Infrastructure**: Docker, Terraform, AWS
- **Database**: PostgreSQL with Drizzle ORM
- **Cache**: Redis
- **Package Manager**: pnpm with workspaces
- **Build System**: Turborepo

## 📁 Project Structure

```
moallem/
├── apps/
│   ├── mobile/          # React Native mobile app
│   └── api/            # Backend API services
├── packages/
│   ├── ui/             # Shared UI components
│   ├── types/          # Shared TypeScript types
│   └── config/         # Shared configurations
├── infrastructure/
│   ├── docker/         # Docker configurations
│   └── terraform/      # Infrastructure as Code
└── scripts/            # Development scripts
```

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18
- pnpm >= 8.14.0
- Docker and Docker Compose
- iOS Simulator (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/moallem.git
cd moallem
```

2. Run the setup script:
```bash
./scripts/setup.sh
```

This will:
- Install all dependencies
- Set up environment files
- Build shared packages
- Optionally start local database services

3. Update the `.env` file with your configuration

### Development

Start all services in development mode:
```bash
pnpm dev
```

Or run individual apps:
```bash
# API server
pnpm --filter @moallem/api dev

# Mobile app
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

## 🧪 Testing

Run all tests:
```bash
pnpm test
```

Run tests for a specific package:
```bash
pnpm --filter @moallem/api test
```

## 📦 Building

Build all packages:
```bash
pnpm build
```

Build for production:
```bash
NODE_ENV=production pnpm build
```

## 🚢 Deployment

### API Deployment

The API is containerized and can be deployed to any container orchestration platform:

```bash
docker build -f infrastructure/docker/api.Dockerfile -t moallem-api .
```

### Mobile Deployment

Using Expo EAS:
```bash
cd apps/mobile
eas build --platform all
```

## 🛠 Available Scripts

- `pnpm dev` - Start development servers
- `pnpm build` - Build all packages
- `pnpm test` - Run tests
- `pnpm lint` - Lint code
- `pnpm format` - Format code with Prettier
- `pnpm clean` - Clean build artifacts
- `pnpm docker:up` - Start Docker services
- `pnpm docker:down` - Stop Docker services

## 🏛 Infrastructure

### Local Development

Uses Docker Compose for:
- PostgreSQL database
- Redis cache

### Production

Infrastructure is managed with Terraform:
- AWS ECS for container orchestration
- RDS for PostgreSQL
- ElastiCache for Redis
- S3 for file storage
- CloudFront for CDN

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## 📄 License

MIT
