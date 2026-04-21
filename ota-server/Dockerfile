FROM node:20-bookworm-slim AS base

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY package.json package.json
COPY package-lock.json package-lock.json
COPY tsconfig.json tsconfig.json
COPY tsconfig.build.json tsconfig.build.json
COPY nest-cli.json nest-cli.json
COPY prisma prisma
COPY public public
COPY src src

RUN npm ci
RUN npx prisma generate
RUN npm run build

EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]
