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