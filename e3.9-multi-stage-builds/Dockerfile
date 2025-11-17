FROM golang:1.16-alpine AS build-stage

WORKDIR /usr/app

# Copy and build dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build statically linked binary for Linux (no dependencies)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o server .

# Start from scratch
FROM scratch

WORKDIR /usr/app

# Copy only built binary from previous stage
COPY --from=build-stage /usr/app/server .

# Expose app port
EXPOSE 8080

# Run binary
CMD ["./server"]
