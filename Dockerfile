
# Stage 1: Build React application
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Serve using non-root Nginx
FROM nginxinc/nginx-unprivileged:stable-alpine

# Install latest available Alpine security updates
USER root
RUN apk update && apk upgrade --no-cache

COPY --from=builder --chown=101:101 /app/dist /usr/share/nginx/html

# Return to non-root Nginx user
USER 101

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
