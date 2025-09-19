# Use Node.js 18 LTS as base image (using full image for better compatibility)
FROM node:18-slim

# Set working directory
WORKDIR /app

# Install system dependencies for native modules and git
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    curl \
    build-essential \
    libcairo2-dev \
    libjpeg-dev \
    libpango1.0-dev \
    libgif-dev \
    librsvg2-dev \
    libpixman-1-dev \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install dependencies with git configuration
RUN npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-retries 5 && \
    npm install --no-optional

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p sessions media meta-media

# Set proper permissions
RUN chown -R node:node /app
USER node

# Expose port
EXPOSE 3010

# Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD node -e "require('http').get('http://localhost:3010/api/web', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["node", "server.js"]
