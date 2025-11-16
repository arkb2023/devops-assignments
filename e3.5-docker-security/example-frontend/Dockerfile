# ==============================================================================
# Dockerfile for React Frontend
# ==============================================================================
# PURPOSE: Build and serve React application with non-root user security
# BASE: Ubuntu 22.04 LTS | RUNTIME: Node.js 16.x + serve | PORT: 5000
# 
# ARCHITECTURE:
#   Section #1: Root-privileged setup and build preparation
#   Section #2: Non-root runtime execution
#
# BUILD: docker build -t frontend-app --build-arg REACT_APP_BACKEND_URL=<url> .
# RUN:   docker run -p 5000:5000 frontend-app
# ==============================================================================

FROM ubuntu:22.04

# ==============================================================================
# Section #1: Root-Privileged Setup & Build Preparation
# ==============================================================================
# Operations requiring root privileges:
#   - Install system packages (Node.js, npm, curl, ca-certificates)
#   - Install global npm package (serve)
#   - Create non-root user (appuser)
#   - Build React application
#   - Set file ownership for non-root user
# ==============================================================================

# Install Node.js 16.x and clean up to minimize image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Install serve globally (requires root) and create non-root user
RUN npm install -g serve && \
    useradd -m -s /bin/bash appuser

# Copy dependency manifests with non-root ownership and install
COPY --chown=appuser:appuser package*.json ./
RUN npm install

# Copy source code with non-root ownership
COPY --chown=appuser:appuser . .

# Configure backend URL and build the application
ARG REACT_APP_BACKEND_URL=http://localhost:8080
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}
RUN npm run build

# Ensure complete ownership transfer (safety check)
RUN chown -R appuser:appuser /usr/src/app

# Switch to non-root user for runtime
USER appuser

# ==============================================================================
# Section #2: Non-Root Runtime Execution
# ==============================================================================
# Runtime operations as appuser:
#   - Expose application port (documentation only)
#   - Serve static build files on port 5000
# ==============================================================================

EXPOSE 5000
CMD ["serve", "-s", "build", "-l", "5000"]
