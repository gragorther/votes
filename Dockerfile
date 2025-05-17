FROM node:20-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS prod

COPY pnpm-lock.yaml /app/
WORKDIR /app
RUN pnpm fetch --prod

COPY . /app
RUN apt-get update -y \
 && apt-get install -y openssl libssl-dev \
 && rm -rf /var/lib/apt/lists/*
RUN pnpm install
RUN pnpm prisma generate
RUN pnpm run build

FROM base
COPY --from=prod /app/build /app/
EXPOSE 3000
CMD [ "node", "/app/index.js" ]