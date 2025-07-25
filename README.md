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
