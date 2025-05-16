# --- base stage ---
FROM node:latest AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# --- builder stage ---
FROM base AS builder
WORKDIR /app

# 1) Copy manifests & prisma schema
COPY package.json pnpm-lock.yaml ./
COPY prisma ./prisma

# 2) Install deps & generate Prisma client
RUN pnpm install --frozen-lockfile
RUN pnpm prisma generate

# 3) Copy source & sync SvelteKit types
COPY . .
RUN pnpm svelte-kit sync

# 4) Build the app
RUN pnpm run build

# --- production stage ---
FROM node:20-slim AS production
WORKDIR /app

# Only prod deps & built files
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build        ./build

EXPOSE 8000
CMD ["node", "build/index.js"]
