## [Exercise: 3.8. Multi-stage frontend](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-4/optimizing-the-image-size)
Do now a multi-stage build for the example [frontend](https://github.com/docker-hy/material-applications/tree/main/example-frontend).  

Even though multi-stage builds are designed mostly for binaries in mind, we can leverage the benefits with our frontend project as having original source code with the final assets makes little sense. Build it with the instructions in README and the built assets should be in build folder.  

You can still use the serve to serve the static files or try out something else.  

---

### [Multi stage Dockerfile](./Dockerfile)
```Dockerfile
FROM node:16-alpine AS build-stage
WORKDIR /usr/app

# Copy package files and install ALL dependencies
COPY package*.json ./
RUN npm install

# Copy source
COPY . .

# Configure backend URL and build
ARG REACT_APP_BACKEND_URL=/api
ENV REACT_APP_BACKEND_URL=${REACT_APP_BACKEND_URL}
RUN npm run build

FROM nginx:1.19-alpine

COPY --from=build-stage /usr/app/build /usr/share/nginx/html

EXPOSE 80
```

### Build, Run & Test

**Build**
```bash
docker build --no-cache -t e3.8-frontend-multistage -f ./Dockerfile ../cloud-container-deploy/example-frontend/
```
```output
[+] Building 63.8s (14/14) FINISHED                                                                                                                                                                                          docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                                                   0.0s
 => => transferring dockerfile: 438B                                                                                                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/nginx:1.19-alpine                                                                                                                                                                   0.1s
 => [internal] load metadata for docker.io/library/node:16-alpine                                                                                                                                                                      0.1s
 => [internal] load .dockerignore                                                                                                                                                                                                      0.0s
 => => transferring context: 125B                                                                                                                                                                                                      0.0s
 => [build-stage 1/6] FROM docker.io/library/node:16-alpine@sha256:a1f9d027912b58a7c75be7716c97cfbc6d3099f3a97ed84aa490be9dee20e787                                                                                                    0.0s
 => => resolve docker.io/library/node:16-alpine@sha256:a1f9d027912b58a7c75be7716c97cfbc6d3099f3a97ed84aa490be9dee20e787                                                                                                                0.0s
 => CACHED [stage-1 1/2] FROM docker.io/library/nginx:1.19-alpine@sha256:07ab71a2c8e4ecb19a5a5abcfb3a4f175946c001c8af288b1aa766d67b0d05d2                                                                                              0.0s
 => => resolve docker.io/library/nginx:1.19-alpine@sha256:07ab71a2c8e4ecb19a5a5abcfb3a4f175946c001c8af288b1aa766d67b0d05d2                                                                                                             0.0s
 => [internal] load build context                                                                                                                                                                                                      0.0s
 => => transferring context: 1.18kB                                                                                                                                                                                                    0.0s
 => CACHED [build-stage 2/6] WORKDIR /usr/app                                                                                                                                                                                          0.0s
 => [build-stage 3/6] COPY package*.json ./                                                                                                                                                                                            0.0s
 => [build-stage 4/6] RUN npm install                                                                                                                                                                                                 49.2s
 => [build-stage 5/6] COPY . .                                                                                                                                                                                                         0.4s
 => [build-stage 6/6] RUN npm run build                                                                                                                                                                                               12.6s
 => [stage-1 2/2] COPY --from=build-stage /usr/app/build /usr/share/nginx/html                                                                                                                                                         0.0s
 => exporting to image                                                                                                                                                                                                                 0.4s
 => => exporting layers                                                                                                                                                                                                                0.2s
 => => exporting manifest sha256:afb1bbe944af42142bc6e3268a9ac1787a195aca0be51cefbc7020e3523fdad4                                                                                                                                      0.0s
 => => exporting config sha256:b691825a14dc9925f95eab0f32e8f13979c8944949ee8b41bba593668ed08c29                                                                                                                                        0.0s
 => => exporting attestation manifest sha256:cd764b593346afda20f8629a3c102a8deab21d7a9ba8a847f7476440c8aa54df                                                                                                                          0.0s
 => => exporting manifest list sha256:5d63c1f456764f25281ff9caa56b00692da835d74170ad61b0286756284aa1ab                                                                                                                                 0.0s
 => => naming to docker.io/library/e3.8-frontend-multistage:latest                                                                                                                                                                     0.0s
 => => unpacking to docker.io/library/e3.8-frontend-multistage:latest                                                                                                                                                                  0.0s
```


**Image Size: 38.5MB**
```bash
docker images | egrep -i -e "e3.8|size"
```
```output
REPOSITORY                      TAG           IMAGE ID       CREATED             SIZE
e3.8-frontend-multistage        latest        5d63c1f45676   15 minutes ago      38.5MB
```

**RUN**
```bash
docker run -p 8080:80 e3.8-frontend-multistage
```
```output
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up

172.17.0.1 - - [17/Nov/2025:05:15:19 +0000] "GET / HTTP/1.1" 200 549 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" "-"
172.17.0.1 - - [17/Nov/2025:05:15:19 +0000] "GET /static/css/main.af76d4ff.css HTTP/1.1" 200 278 "http://localhost:8080/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" "-"
172.17.0.1 - - [17/Nov/2025:05:15:19 +0000] "GET /static/js/main.9fc22b95.js HTTP/1.1" 200 272281 "http://localhost:8080/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" "-"
172.17.0.1 - - [17/Nov/2025:05:15:19 +0000] "GET /static/media/toskalogo.c0f35cf0bd44ed3ddbe502161f173ded.svg HTTP/1.1" 200 3269 "http://localhost:8080/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" "-"
172.17.0.1 - - [17/Nov/2025:05:15:19 +0000] "GET /manifest.json HTTP/1.1" 200 204 "http://localhost:8080/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" "-"
```

**Test**
```bash
http GET :8080
```
```output
HTTP/1.1 200 OK
Accept-Ranges: bytes
Connection: keep-alive
Content-Length: 549
Content-Type: text/html
Date: Mon, 17 Nov 2025 05:21:56 GMT
ETag: "691aaec0-225"
Last-Modified: Mon, 17 Nov 2025 05:12:32 GMT
Server: nginx/1.19.10

<!doctype html><html lang="en"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/><meta name="theme-color" content="#000000"/><meta name="description" content="Frontend for docker course"/><link rel="manifest" href="/manifest.json"/><title>Docker frontend</title><script defer="defer" src="/static/js/main.9fc22b95.js"></script><link href="/static/css/main.af76d4ff.css" rel="stylesheet"></head><body><noscript>You need to enable JavaScript to run this app.</noscript><div id="root"></div></body></html>
```
