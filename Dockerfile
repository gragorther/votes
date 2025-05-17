FROM node:20-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN apt-get update -y \
 && apt-get install -y openssl libssl-dev \
 && rm -rf /var/lib/apt/lists/*

FROM base AS prod

COPY pnpm-lock.yaml /app/
WORKDIR /app
RUN pnpm fetch --prod

COPY . /app

RUN pnpm install --prod
RUN pnpm prisma generate

FROM prod AS build
RUN pnpm install
RUN pnpm run build


FROM base
WORKDIR /app
COPY --from=build /app/build /app/
COPY --from=prod /app/node_modules /app/node_modules
EXPOSE 3000
CMD [ "node", "index.js" ]