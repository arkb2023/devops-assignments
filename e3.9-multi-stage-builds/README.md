## [Exercise: 3.9. Multi-stage backend](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-4/optimizing-the-image-size)

Let us do a multi-stage build for the [backend](https://github.com/docker-hy/material-applications/tree/main/example-backend) project since we have come so far with the application.

The project is in Golang and building a binary that runs in a container, while straightforward, isn't exactly trivial. Use resources that you have available (Google, example projects) to build the binary and run it inside a container that uses FROM scratch.

To successfully complete the exercise, the image must be smaller than 35MB.

---

### [Multi stage Dockerfile](./Dockerfile)
```Dockerfile
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
```

### Build, Run & Test

**Build**
```bash
docker build --no-cache -t e3.9-backend-multistage -f ./Dockerfile ../cloud-container-deploy/example-backend/
```
```output
[+] Building 21.5s (14/14) FINISHED                                                                                                                                                                                          docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                                   0.0s
 => => transferring dockerfile: 615B                                                                                                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/golang:1.16-alpine                                                                                                                                                                  1.9s
 => [auth] library/golang:pull token for registry-1.docker.io                                                                                                                                                                          0.0s
 => [internal] load .dockerignore                                                                                                                                                                                                      0.0s
 => => transferring context: 89B                                                                                                                                                                                                       0.0s
 => [internal] load build context                                                                                                                                                                                                      0.0s
 => => transferring context: 560B                                                                                                                                                                                                      0.0s
 => [stage-1 1/2] WORKDIR /usr/app                                                                                                                                                                                                     0.1s
 => CACHED [build-stage 1/6] FROM docker.io/library/golang:1.16-alpine@sha256:5616dca835fa90ef13a843824ba58394dad356b7d56198fb7c93cbe76d7d67fe                                                                                         0.0s
 => => resolve docker.io/library/golang:1.16-alpine@sha256:5616dca835fa90ef13a843824ba58394dad356b7d56198fb7c93cbe76d7d67fe                                                                                                            0.0s
 => [build-stage 2/6] WORKDIR /usr/app                                                                                                                                                                                                 0.1s
 => [build-stage 3/6] COPY go.mod go.sum ./                                                                                                                                                                                            0.1s
 => [build-stage 4/6] RUN go mod download                                                                                                                                                                                             14.5s
 => [build-stage 5/6] COPY . .                                                                                                                                                                                                         0.1s
 => [build-stage 6/6] RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o server .                                                                                                                                  3.8s
 => [stage-1 2/2] COPY --from=build-stage /usr/app/server .                                                                                                                                                                            0.1s
 => exporting to image                                                                                                                                                                                                                 0.8s
 => => exporting layers                                                                                                                                                                                                                0.5s
 => => exporting manifest sha256:53c42e6d118de086db359c5443fbf6933d1c6575b444fc4aed375a5d8ceb4e07                                                                                                                                      0.0s
 => => exporting config sha256:65235751cdf5c82d7372b96563ba5a446b50b5f3483d23ed26536aa1d8507ce2                                                                                                                                        0.0s
 => => exporting attestation manifest sha256:83ccfbb450906d4d8fa8bba7c4f88a2002485d2acabf4b6df63273d359b27c86                                                                                                                          0.0s
 => => exporting manifest list sha256:43c1a1fd59665ec418b82604208f6cae9aec46238e32525429fcd416c17e5643                                                                                                                                 0.0s
 => => naming to docker.io/library/e3.9-backend-multistage:latest                                                                                                                                                                      0.0s
 => => unpacking to docker.io/library/e3.9-backend-multistage:latest
```


**Image Size: 17.8MB**
```bash
docker images | egrep -i -e "e3.9|size"
```
```output
REPOSITORY                      TAG           IMAGE ID       CREATED              SIZE
e3.9-backend-multistage         latest        43c1a1fd5966   About a minute ago   17.8MB
```

**RUN**
```bash
docker run -p 8080:8080 e3.9-backend-multistage
```
```output
[Ex 2.4+] REDIS_HOST env was not passed so redis connection is not initialized
[Ex 2.6+] POSTGRES_HOST env was not passed so postgres connection is not initialized
[GIN-debug] [WARNING] Creating an Engine instance with the Logger and Recovery middleware already attached.

[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:   export GIN_MODE=release
 - using code:  gin.SetMode(gin.ReleaseMode)

[GIN-debug] GET    /ping                     --> server/router.pingpong (4 handlers)
[GIN-debug] GET    /messages                 --> server/controller.GetMessages (4 handlers)
[GIN-debug] POST   /messages                 --> server/controller.CreateMessage (4 handlers)
[GIN-debug] Listening and serving HTTP on :8080
[GIN] 2025/11/17 - 05:53:04 | 404 |     407.949µs |      172.17.0.1 | GET      "/"
[GIN] 2025/11/17 - 05:53:08 | 200 |       80.55µs |      172.17.0.1 | GET      "/ping"
```

**Test**
```bash
http GET :8080/ping
```
```output
HTTP/1.1 200 OK
Content-Length: 4
Content-Type: text/plain; charset=utf-8
Date: Mon, 17 Nov 2025 05:53:08 GMT

pong

```
