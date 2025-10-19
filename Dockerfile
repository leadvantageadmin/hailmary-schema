FROM node:18-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Prisma CLI
RUN npm install -g prisma@latest

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy schema files
COPY versions/ ./versions/
COPY scripts/ ./scripts/

# Make scripts executable
RUN chmod +x scripts/*.sh

# Set default environment variables
ENV SCHEMA_VERSION=latest
ENV CLIENT_LANGUAGES=node,python,typescript

# Expose port for schema API (if implemented)
EXPOSE 3001

# Set default command
CMD ["node", "-e", "console.log('Schema service ready. Use scripts to manage schema versions.')"]
