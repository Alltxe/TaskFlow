# syntax=docker/dockerfile:1

# ============================================================
# TaskFlow backend — multi-stage build
# Образ собирается ЛОКАЛЬНО, на VPS уезжает уже готовый.
# Для сборки под amd64 VPS с Windows/ARM:
#   docker build --platform linux/amd64 -t taskflow-backend:latest .
# ============================================================

# ---------- Stage 1: build (компиляция TS + prisma generate) ----------
FROM node:20-slim AS builder

# openssl нужен prisma; build-essential/python3 — для нативных модулей (bcrypt)
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl python3 make g++ ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY prisma ./prisma
RUN npx prisma generate

COPY . .
RUN npm run build

# ---------- Stage 2: production dependencies ----------
FROM node:20-slim AS deps

RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl python3 make g++ ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
# Только prod-зависимости + prisma CLI (нужен для `migrate deploy` на старте)
RUN npm ci --omit=dev \
  && npm install prisma@6.16.3 --no-save \
  && npm cache clean --force

COPY prisma ./prisma
RUN npx prisma generate

# ---------- Stage 3: runtime (минимальный образ) ----------
FROM node:20-slim AS runtime

RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY package*.json ./

# GraphQL autoSchemaFile пишет в src/schema.gql относительно cwd; logs/ для Winston.
# Создаём каталоги и отдаём их пользователю node.
RUN mkdir -p /app/src /app/logs \
  && chown -R node:node /app/src /app/logs

USER node

EXPOSE 3100

# На старте применяем миграции, затем запускаем приложение.
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]
