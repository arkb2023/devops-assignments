# ---- Build stage ----
FROM node:16-slim AS builder
WORKDIR /usr/src/app
COPY package*.json ./

# Install dependencies
RUN npm install
COPY . .

# Set build-time backend URL (will be baked into the build)
ARG REACT_APP_BACKEND_URL=https://example-backend.com
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}

RUN npm run build

# ---- Runtime stage ----
FROM node:16-slim
WORKDIR /usr/src/app

# Install serve (as runtime dependency)
RUN npm install -g serve

# Copy build artifacts from builder
COPY --from=builder /usr/src/app/build ./build

# Expose desired port
EXPOSE 5000

# Start serving the static files
CMD ["serve", "-s", "build", "-l", "5000"]
