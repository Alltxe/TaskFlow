# TaskFlow Backend - Deployment Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Variables](#environment-variables)
3. [Local Development](#local-development)
4. [Production Deployment](#production-deployment)
5. [Database Migrations](#database-migrations)
6. [Backup & Restore](#backup--restore)
7. [Monitoring & Logging](#monitoring--logging)
8. [Troubleshooting](#troubleshooting)
9. [Security Checklist](#security-checklist)

---

## Prerequisites

### System Requirements

- **Node.js**: v18.x or higher (LTS recommended)
- **npm**: v9.x or higher
- **PostgreSQL**: v14.x or higher
- **Redis**: v6.x or higher (optional, for production caching)
- **Git**: For version control

### Development Tools (Optional)

- **Docker**: v20.x+ (for containerized deployment)
- **Docker Compose**: v2.x+ (for local multi-container setup)
- **Postman/Insomnia**: For API testing

---

## Environment Variables

### Required Variables

Create a `.env` file in the project root:

```bash
# ============================================
# APPLICATION
# ============================================
NODE_ENV=development                    # development | production | test
PORT=3000                              # Application port

# ============================================
# DATABASE
# ============================================
DATABASE_URL="postgresql://username:password@localhost:5432/taskflow?schema=public"

# ============================================
# JWT AUTHENTICATION
# ============================================
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
JWT_EXPIRES_IN=15m                     # Access token expiration
JWT_REFRESH_EXPIRES_IN=7d              # Refresh token expiration

# ============================================
# CORS
# ============================================
CORS_ORIGIN="http://localhost:3001,http://localhost:5173"  # Comma-separated allowed origins

# ============================================
# SECURITY & RATE LIMITING
# ============================================
THROTTLE_TTL=60000                     # Rate limit window (ms)
THROTTLE_LIMIT=100                     # General API requests per window
THROTTLE_AUTH_LIMIT=5                  # Auth requests per window

# ============================================
# CACHING (Optional - Redis for production)
# ============================================
REDIS_URL="redis://localhost:6379"    # Optional: Redis connection string
                                        # If not set, uses in-memory cache

# ============================================
# FIREBASE CLOUD MESSAGING (Push Notifications)
# ============================================
FIREBASE_PROJECT_ID="your-firebase-project-id"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Private-Key-Here\n-----END PRIVATE KEY-----"

# ============================================
# LOGGING
# ============================================
LOG_LEVEL=info                         # error | warn | info | debug
LOG_DIR=logs                           # Log file directory
```

### Environment-Specific Configuration

#### Development (.env.development)

```bash
NODE_ENV=development
DATABASE_URL="postgresql://dev:dev@localhost:5432/taskflow_dev?schema=public"
JWT_SECRET="dev-secret-key"
CORS_ORIGIN="http://localhost:3001"
LOG_LEVEL=debug
```

#### Production (.env.production)

```bash
NODE_ENV=production
DATABASE_URL="postgresql://prod_user:strong_password@prod-db-host:5432/taskflow_prod?schema=public&sslmode=require"
JWT_SECRET="CHANGE-THIS-TO-RANDOM-256-BIT-KEY"
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
CORS_ORIGIN="https://yourdomain.com,https://app.yourdomain.com"
REDIS_URL="redis://prod-redis-host:6379"
FIREBASE_PROJECT_ID="your-prod-firebase-project"
FIREBASE_CLIENT_EMAIL="your-prod-service-account@firebase.com"
FIREBASE_PRIVATE_KEY="your-production-private-key"
LOG_LEVEL=warn
THROTTLE_LIMIT=100
THROTTLE_AUTH_LIMIT=5
```

### Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use environment-specific secrets** (different keys for dev/staging/prod)
3. **Rotate JWT secrets** periodically
4. **Use strong database passwords** (min 16 characters, mixed case, numbers, symbols)
5. **Enable SSL/TLS** for database connections in production
6. **Store Firebase private key securely** (use secrets manager in cloud environments)

---

## Local Development

### 1. Clone Repository

```bash
git clone https://github.com/your-org/taskflow-backend.git
cd taskflow-backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Set Up Database

#### Option A: Local PostgreSQL

```bash
# Install PostgreSQL
# macOS: brew install postgresql@14
# Ubuntu: sudo apt install postgresql-14
# Windows: Download from https://www.postgresql.org/download/

# Start PostgreSQL service
# macOS: brew services start postgresql@14
# Ubuntu: sudo systemctl start postgresql
# Windows: Use Services app

# Create database
psql -U postgres
CREATE DATABASE taskflow_dev;
CREATE USER taskflow_user WITH PASSWORD 'dev_password';
GRANT ALL PRIVILEGES ON DATABASE taskflow_dev TO taskflow_user;
\q
```

#### Option B: Docker Compose

```bash
# Create docker-compose.yml
cat > docker-compose.dev.yml <<EOF
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    container_name: taskflow-db
    environment:
      POSTGRES_USER: taskflow
      POSTGRES_PASSWORD: dev_password
      POSTGRES_DB: taskflow_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    container_name: taskflow-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
EOF

# Start services
docker-compose -f docker-compose.dev.yml up -d
```

### 4. Run Migrations

```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate deploy

# (Optional) Seed database with test data
npx prisma db seed
```

### 5. Start Development Server

```bash
npm run dev
```

**Access**:
- API: http://localhost:3000/graphql
- Health Check: http://localhost:3000/health

---

## Production Deployment

### Option 1: Traditional Server (PM2)

#### 1. Install PM2

```bash
npm install -g pm2
```

#### 2. Build Application

```bash
npm run build
```

#### 3. Create PM2 Ecosystem File

```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'taskflow-backend',
    script: './dist/main.js',
    instances: 'max',         // Use all CPU cores
    exec_mode: 'cluster',     // Enable clustering
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000,
    },
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    max_memory_restart: '1G',
    watch: false,
  }],
};
```

#### 4. Start with PM2

```bash
pm2 start ecosystem.config.js --env production
pm2 save                      # Save process list
pm2 startup                   # Enable auto-start on boot
```

#### 5. Monitor

```bash
pm2 status                    # Check status
pm2 logs taskflow-backend     # View logs
pm2 monit                     # Real-time monitoring
```

---

### Option 2: Docker Container

#### 1. Create Dockerfile

```dockerfile
# Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Build application
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package*.json ./

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD node -e "require('http').get('http://localhost:3000/health/live', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "dist/main.js"]
```

#### 2. Create .dockerignore

```
node_modules
npm-debug.log
.env
.env.*
dist
coverage
logs
*.log
.git
.gitignore
README.md
.vscode
.idea
```

#### 3. Build and Run

```bash
# Build image
docker build -t taskflow-backend:latest .

# Run container
docker run -d \
  --name taskflow-backend \
  -p 3000:3000 \
  --env-file .env.production \
  --restart unless-stopped \
  taskflow-backend:latest
```

#### 4. Docker Compose (Full Stack)

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: taskflow-backend
    restart: unless-stopped
    ports:
      - "3000:3000"
    env_file:
      - .env.production
    depends_on:
      - postgres
      - redis
    networks:
      - taskflow-network

  postgres:
    image: postgres:14-alpine
    container_name: taskflow-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: taskflow_prod
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - taskflow-network

  redis:
    image: redis:7-alpine
    container_name: taskflow-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - taskflow-network

volumes:
  postgres_data:
  redis_data:

networks:
  taskflow-network:
    driver: bridge
```

```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

### Option 3: Kubernetes (Cloud-Native)

#### 1. Create Kubernetes Manifests

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taskflow-backend
  labels:
    app: taskflow-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: taskflow-backend
  template:
    metadata:
      labels:
        app: taskflow-backend
    spec:
      containers:
      - name: taskflow-backend
        image: your-registry/taskflow-backend:latest
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: taskflow-config
        - secretRef:
            name: taskflow-secrets
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: taskflow-backend-service
spec:
  selector:
    app: taskflow-backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

#### 2. Apply Manifests

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Database Migrations

### Running Migrations

#### Development

```bash
# Create migration from schema changes
npx prisma migrate dev --name add_feature_name

# Apply migrations
npx prisma migrate deploy
```

#### Production

```bash
# IMPORTANT: Always backup database first!

# Apply migrations
npx prisma migrate deploy

# Verify migration status
npx prisma migrate status
```

### Migration Best Practices

1. **Always backup** before running migrations in production
2. **Test migrations** in staging environment first
3. **Review generated SQL** before applying
4. **Use transactions** for multi-step migrations
5. **Plan rollback strategy** before deployment

### Rollback Migration

If a migration fails:

```bash
# Revert to previous migration
npx prisma migrate resolve --rolled-back migration_name

# Fix issues and create new migration
npx prisma migrate dev --name fix_migration
```

### Migration Troubleshooting

#### Issue: Migration fails due to data conflicts

```sql
-- Add temporary column, migrate data, then drop old column
ALTER TABLE "Task" ADD COLUMN "newDeadline" TIMESTAMP;
UPDATE "Task" SET "newDeadline" = "deadline"::TIMESTAMP WHERE "deadline" IS NOT NULL;
ALTER TABLE "Task" DROP COLUMN "deadline";
ALTER TABLE "Task" RENAME COLUMN "newDeadline" TO "deadline";
```

#### Issue: Prisma schema out of sync

```bash
# Pull current database schema
npx prisma db pull

# Generate Prisma client
npx prisma generate
```

---

## Backup & Restore

### PostgreSQL Backup

#### Full Database Backup

```bash
# Backup
pg_dump -U taskflow_user -h localhost -d taskflow_prod -F c -b -v -f taskflow_backup_$(date +%Y%m%d_%H%M%S).dump

# Compressed backup
pg_dump -U taskflow_user -h localhost -d taskflow_prod | gzip > taskflow_backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

#### Automated Backup Script

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/var/backups/taskflow"
DB_NAME="taskflow_prod"
DB_USER="taskflow_user"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/taskflow_$TIMESTAMP.dump"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup
pg_dump -U $DB_USER -d $DB_NAME -F c -b -v -f $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Delete backups older than 30 days
find $BACKUP_DIR -name "taskflow_*.dump.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE.gz"
```

#### Schedule Daily Backups (Cron)

```bash
# Add to crontab
crontab -e

# Run backup daily at 2 AM
0 2 * * * /path/to/backup.sh >> /var/log/taskflow_backup.log 2>&1
```

### Restore Database

```bash
# From custom format
pg_restore -U taskflow_user -d taskflow_prod -v taskflow_backup.dump

# From compressed SQL
gunzip -c taskflow_backup.sql.gz | psql -U taskflow_user -d taskflow_prod

# Clean restore (drop existing data)
pg_restore -U taskflow_user -d taskflow_prod -c -v taskflow_backup.dump
```

### Redis Backup

Redis automatically saves data to disk (`dump.rdb` file).

```bash
# Manual backup
redis-cli SAVE
cp /var/lib/redis/dump.rdb /backups/redis_$(date +%Y%m%d).rdb

# Restore
service redis stop
cp /backups/redis_backup.rdb /var/lib/redis/dump.rdb
service redis start
```

---

## Monitoring & Logging

### Health Checks

```bash
# Liveness probe (is app running?)
curl http://localhost:3000/health/live

# Readiness probe (is app ready?)
curl http://localhost:3000/health/ready

# Detailed health status
curl http://localhost:3000/health
```

### Application Logs

#### Winston Logs (File-based)

Logs are written to `./logs/` directory:

- **error.log**: Error-level logs only
- **combined.log**: All log levels

#### View Logs

```bash
# Tail error logs
tail -f logs/error.log

# Tail all logs
tail -f logs/combined.log

# Search logs
grep "TASK_COMPLETED" logs/combined.log

# View last 100 lines with context
tail -n 100 logs/combined.log
```

### Performance Monitoring

#### PM2 Monitoring

```bash
pm2 monit                    # Real-time CPU/memory usage
pm2 status                   # Process status
pm2 logs --lines 100         # View logs
```

#### Docker Monitoring

```bash
docker stats taskflow-backend               # Real-time stats
docker logs -f taskflow-backend             # View logs
docker logs --tail 100 taskflow-backend     # Last 100 lines
```

### Database Monitoring

```sql
-- Active queries
SELECT pid, age(clock_timestamp(), query_start), usename, query 
FROM pg_stat_activity 
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' 
ORDER BY query_start DESC;

-- Database size
SELECT pg_size_pretty(pg_database_size('taskflow_prod'));

-- Table sizes
SELECT relname AS "table_name", 
       pg_size_pretty(pg_total_relation_size(relid)) AS "size"
FROM pg_catalog.pg_statio_user_tables 
ORDER BY pg_total_relation_size(relid) DESC;

-- Slow queries (requires pg_stat_statements extension)
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

---

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Error**: `P1001: Can't reach database server`

**Solutions**:
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Verify DATABASE_URL is correct
echo $DATABASE_URL

# Test connection
psql $DATABASE_URL

# Check firewall rules
sudo ufw status
```

#### 2. Port Already in Use

**Error**: `Error: listen EADDRINUSE: address already in use :::3000`

**Solutions**:
```bash
# Find process using port 3000
lsof -i :3000
# or
netstat -tuln | grep 3000

# Kill process
kill -9 <PID>

# Use different port
PORT=3001 npm run dev
```

#### 3. Prisma Client Not Generated

**Error**: `Cannot find module '@prisma/client'`

**Solution**:
```bash
npx prisma generate
npm run build
```

#### 4. JWT Token Invalid

**Error**: `UNAUTHENTICATED: Invalid token`

**Solutions**:
- Verify `JWT_SECRET` matches between environments
- Check token hasn't expired (access: 15min, refresh: 7 days)
- Ensure `Authorization: Bearer <token>` header format
- Clear refresh tokens and re-login

#### 5. Rate Limit Exceeded

**Error**: `TOO_MANY_REQUESTS: Rate limit exceeded`

**Solutions**:
- Wait for rate limit window to reset (1 minute)
- Implement client-side throttling
- Use batch queries for multiple operations
- Contact admin to increase limits if legitimate use case

---

## Security Checklist

### Pre-Deployment

- [ ] Update all dependencies: `npm audit fix`
- [ ] Generate strong JWT secret: `openssl rand -base64 32`
- [ ] Enable HTTPS/TLS in production
- [ ] Configure CORS for allowed origins only
- [ ] Set `NODE_ENV=production`
- [ ] Disable GraphQL playground in production
- [ ] Enable Helmet security headers
- [ ] Configure rate limiting
- [ ] Set up database SSL connections
- [ ] Secure Redis with password
- [ ] Use environment variables for secrets
- [ ] Implement database connection pooling
- [ ] Set up automated backups
- [ ] Configure monitoring and alerts
- [ ] Review and update firewall rules
- [ ] Enable audit logging
- [ ] Rotate credentials regularly
- [ ] Implement IP whitelisting (if applicable)
- [ ] Set up DDoS protection
- [ ] Review and test disaster recovery plan

### Post-Deployment

- [ ] Verify health checks pass
- [ ] Test authentication flow
- [ ] Confirm rate limiting works
- [ ] Check logs for errors
- [ ] Monitor performance metrics
- [ ] Verify backups are running
- [ ] Test database migrations
- [ ] Review security headers (SecurityHeaders.com)
- [ ] Perform penetration testing
- [ ] Set up uptime monitoring
- [ ] Configure alerts for critical errors
- [ ] Document incident response procedures

---

## Support

**Documentation**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)  
**Architecture**: [ARCHITECTURE.md](./ARCHITECTURE.md)  
**Roadmap**: [DEVELOPMENT_ROADMAP.md](./DEVELOPMENT_ROADMAP.md)

For issues and feature requests, please create a GitHub issue.

---

**Last Updated**: November 10, 2025  
**Version**: 1.0.0
