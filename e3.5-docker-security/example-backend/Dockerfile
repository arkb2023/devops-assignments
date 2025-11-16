# ==============================================================================
# Dockerfile for Go Backend API
# ==============================================================================
# PURPOSE: Build and run Go backend API with non-root user security
# BASE: Alpine Linux 3.18 | RUNTIME: Go 1.16.15 | PORT: 8080
# 
# ARCHITECTURE:
#   Section #1: Root-privileged setup and build preparation
#   Section #2: Non-root runtime execution
#
# BUILD: docker build -t backend-app --build-arg REQUEST_ORIGIN=<url> .
# RUN:   docker run -p 8080:8080 backend-app
# ==============================================================================

FROM alpine:3.18

# ==============================================================================
# Section #1: Root-Privileged Setup & Build Preparation
# ==============================================================================
# Operations requiring root privileges:
#   - Install Go compiler and build tools
#   - Build Go application binary
#   - Create non-root user (appuser)
#   - Set file ownership for non-root user
# ==============================================================================

# Set Go binary path for build process
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /usr/src/app

# Install Go and build dependencies
# Note: Alpine uses 'adduser' instead of 'useradd'
RUN apk add --no-cache go && \
    adduser -D -s /bin/sh appuser

# Copy source code with non-root ownership
COPY --chown=appuser:appuser . .

# Build the Go application
RUN go build && \
    chown appuser:appuser /usr/src/app/server

# Switch to non-root user for runtime
USER appuser

# ==============================================================================
# Section #2: Non-Root Runtime Execution
# ==============================================================================
# Runtime operations as appuser:
#   - Configure CORS origin for frontend communication
#   - Set application port (customizable via environment)
#   - Expose port for external access
#   - Execute the Go server binary
# ==============================================================================

# Configure allowed CORS origin (customizable at build/run time)
ARG REQUEST_ORIGIN=http://localhost:5000
ENV REQUEST_ORIGIN=${REQUEST_ORIGIN}

# Application port configuration (customizable at runtime)
ENV PORT=8080

# Expose application port (documentation only)
EXPOSE 8080

# Start the Go server as non-root user
ENTRYPOINT ["./server"]