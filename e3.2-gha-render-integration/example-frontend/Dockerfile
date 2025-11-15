# ---- Build stage ----
FROM node:16-slim AS builder

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first for layer caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the app code
COPY . .

# Set build-time backend URL (will be baked into the build)
ARG REACT_APP_BACKEND_URL=https://example-backend.com
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}

# Build React app with the configured backend URL
RUN npm run build

# ---- Runtime stage ----
FROM node:16-slim

WORKDIR /usr/src/app

# Install serve (as runtime dependency)
RUN npm install -g serve

# Copy build artifacts from builder
COPY --from=builder /usr/src/app/build ./build

# Expose desired port (matches your workflow and serve config)
EXPOSE 5000

# Start serving the static files
CMD ["serve", "-s", "build", "-l", "5000"]


# FROM ubuntu:24.04

# ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
# # ENV REACT_APP_BACKEND_URL=http://localhost:8080
# ENV REACT_APP_BACKEND_URL=https://example-backend.com

# WORKDIR /usr/src/app
# COPY . .
# RUN apt-get update && \
#     apt-get install -y curl && \
#     curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
#     apt-get install -y nodejs && \
#     node -v && npm -v && \
#     npm install && \
#     npm install -g serve


# EXPOSE 5000

# ENTRYPOINT ["sh", "-c"]
# CMD ["npm run build && serve -s -l ${PORT:-5000} build"]


