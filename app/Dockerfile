# ── Stage 1: Install production dependencies ───────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Copy manifests first — layer cache avoids re-installing on every code change
COPY package.json package-lock.json ./

RUN npm ci --only=production

# ── Stage 2: Runtime — lean image with app source + production deps ────────────
FROM node:18-alpine

WORKDIR /app

# Create a non-root user — containers should never run as root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1

CMD ["node", "src/server.js"]
