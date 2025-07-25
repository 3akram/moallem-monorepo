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
