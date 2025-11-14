FROM ubuntu:24.04

ENV PATH="/usr/local/go/bin:${PATH}"
# ENV REQUEST_ORIGIN=http://localhost:5000
ENV REQUEST_ORIGIN=https://example-frontend-wbzs.onrender.com/

WORKDIR /usr/src/app
COPY . .

RUN apt-get update && \
    apt-get install -y curl build-essential && \
    cd /tmp && \
    curl -LO https://go.dev/dl/go1.16.15.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.16.15.linux-amd64.tar.gz && \
    cd /usr/src/app && \
    go build
    

# Server accepts `PORT` env var to choose which port for the application. Default: 8080
ENV PORT=8080

# Expose container port for external communication
EXPOSE 8080

# Default app
ENTRYPOINT ["./server"]
