FROM node:18-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Prisma CLI
RUN npm install -g prisma@latest

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy schema files
COPY versions/ ./versions/
COPY migrations/ ./migrations/
COPY scripts/ ./scripts/
COPY config/ ./config/

# Make scripts executable
RUN chmod +x scripts/*.sh

# Set default environment variables
ENV SCHEMA_VERSION=latest
ENV CLIENT_LANGUAGES=node,python,typescript

# Expose port for schema API (if implemented)
EXPOSE 3001

# Set default command
CMD ["node", "-e", "console.log('Schema service ready. Use scripts to manage schema versions.')"]
