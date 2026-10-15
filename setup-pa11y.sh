#!/usr/bin/env bash

PROJECT_DIR="pa11y-dashboard"
CONFIG_DIR="$HOME/.config/$PROJECT_DIR"
WEB_PORT="8310"
API_PORT="3000"
MONGO_PORT="27017"

echo "🚀 Setting up Pa11y Dashboard local instance in ${CONFIG_DIR}..."

if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker/OrbStack is not running."
    exit 1
fi

mkdir -p "$CONFIG_DIR/data"
cd "$CONFIG_DIR" || exit

# 1. Create production.json
cat << EOF > production.json
{
  "port": ${WEB_PORT},
  "noindex": true,
  "readonly": false,

  "webservice": {
    "database": "mongodb://mongo:${MONGO_PORT}/pa11y-webservice",
    "host": "0.0.0.0",
    "port": ${API_PORT},
    "cron": "0 30 0 * * *",
    "chromeLaunchConfig": {
       "executablePath": "/usr/bin/chromium",
       "args": [
         "--no-sandbox",
         "--disable-dev-shm-usage"
       ]
    }
  }
}
EOF
echo "✅ Generated production.json"

# 2. Create Dockerfile (Updated to bookworm to fix Debian bullseye-security 404s)
cat << 'EOF' > Dockerfile
FROM node:18-bookworm

# Install chromium and essential dependencies, skipping recommended but unnecessary packages
RUN apt-get update -y && apt-get install -y \
    chromium \
    ca-certificates \
    wget \
    git \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production

# Prevent Puppeteer from downloading an incompatible x86 version of Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Clone the dashboard, install dependencies, and force nanoid downgrade to a CommonJS-compatible version
RUN git clone https://github.com/pa11y/dashboard.git && \
    cd dashboard && \
    npm install && \
    npm install nanoid@3.3.4

EXPOSE 8310
EXPOSE 3000

COPY production.json /dashboard/config/production.json
WORKDIR /dashboard

CMD ["node", "."]
EOF
echo "✅ Generated Dockerfile"

# 3. Create docker-compose.yml (with restart set to "no" to disable auto-start)
cat << EOF > docker-compose.yml
# pa11y-dashboard
services:
  web:
    container_name: pa11y-dashboard
    restart: "no"
    build:
      context: .
      pull: true
      no_cache: true
    ports:
      - "${WEB_PORT}:8310"
    depends_on:
      - mongo
  mongo:
    container_name: mongo
    image: mongo:latest
    restart: "no"
    volumes:
      - ./data:/data/db
    ports:
      - "${MONGO_PORT}:27017"
EOF
echo "✅ Generated docker-compose.yml (auto-start disabled)"

echo "⏳ Building Pa11y Dashboard and starting containers..."
docker compose up -d --build --force-recreate

echo ""
echo "🎉 Setup Complete!"
echo "📂 Project files are located at: ${CONFIG_DIR}"
echo "🌐 Web Interface: http://localhost:${WEB_PORT}/"
echo "🗄️  MongoDB Port:  localhost:${MONGO_PORT}"