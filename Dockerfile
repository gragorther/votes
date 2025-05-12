# --- base stage (shared) ----------------------------
    FROM node:20-slim AS base
    ENV PNPM_HOME="/pnpm"
    ENV PATH="$PNPM_HOME:$PATH"
    RUN corepack enable
    
    # --- builder stage (install & build) ----------------
    FROM base AS builder
    WORKDIR /app
    
    # 1) Copy lock & manifest to leverage cache
    COPY package.json pnpm-lock.yaml ./
    
    # 2) Install all deps (prod + dev) for build
    RUN pnpm install --frozen-lockfile  
    
    # 3) Copy source & build
    COPY . .
    RUN pnpm run build                   
    
# --- production stage ---
    FROM node:20-slim AS production
    WORKDIR /app
    
    # Copy only prod deps & built files
    COPY --from=builder /app/node_modules ./node_modules
    COPY --from=builder /app/build        ./build
    
    EXPOSE 8000
    CMD ["node", "build/index.js"]