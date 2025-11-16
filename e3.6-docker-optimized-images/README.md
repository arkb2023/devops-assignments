### **Overview**  
This report demonstrates Docker container image optimization by consolidating instruction layers and performing cleanup operations.

#### **Approach**  
For both [frontend](https://github.com/docker-hy/material-applications/tree/main/example-frontend) and [backend](https://github.com/docker-hy/material-applications/tree/main/example-backend) projects, we created two variants of Dockerfiles: an **unoptimized** version and an **optimized** version.

- In the **unoptimized Dockerfiles**, multiple `RUN` instructions were used to install dependencies and perform build operations.  
- In the **optimized Dockerfiles**, installation, build, and cleanup steps were consolidated into a **single `RUN` instruction** using logical chaining (`&&`).

Each `RUN` instruction in a Dockerfile creates a separate image layer. When fragmented, these layers retain caches and intermediate artifacts, inflating the total image size and leaving redundant files in the final container. This not only increases the image size but also slows container startup and image transfer.  
By removing unnecessary packages and cleaning up caches and temporary files within the same layer, the optimized Dockerfiles produce a much leaner, more deployable image.

***

#### **Frontend Dockerfiles**

- **Unoptimized** [`Dockerfile.unoptimized.frontend`](./Dockerfile.unoptimized.frontend)
    ```Dockerfile
    RUN apt-get update  
    RUN apt-get install -y curl  
    RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -  
    RUN apt-get install -y nodejs  
    RUN node -v  
    RUN npm -v  
    RUN npm install  
    RUN npm run build  
    RUN npm install -g serve  
    ```

- **Optimized** [`Dockerfile.optimized.frontend`](./Dockerfile.optimized.frontend)
    ```Dockerfile
    RUN apt-get update && \
        apt-get install -y --no-install-recommends curl && \
        curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
        apt-get install -y --no-install-recommends nodejs npm && \
        node -v && npm -v && \
        npm install && \
        npm run build && \
        npm install -g serve && \
        apt-get purge -y --auto-remove curl && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /root/.npm
    ```

#### **Backend Dockerfiles**

- **Unoptimized** [`Dockerfile.unoptimized.backend`](./Dockerfile.unoptimized.backend)
    ```Dockerfile
    RUN apt-get update 
    RUN apt-get install -y curl build-essential
    RUN cd /tmp 
    RUN curl -LO https://go.dev/dl/go1.16.15.linux-amd64.tar.gz
    RUN tar -C /usr/local -xzf go1.16.15.linux-amd64.tar.gz
    RUN cd /usr/src/app
    RUN go build
    ```
- **Optimized** [`Dockerfile.optimized.backend`](./Dockerfile.optimized.backend)
    ```Dockerfile
    RUN apt-get update && \
        apt-get install -y --no-install-recommends curl build-essential ca-certificates && \
        update-ca-certificates && \
        cd /tmp && \
        curl -LO https://go.dev/dl/go1.16.15.linux-amd64.tar.gz && \
        tar -C /usr/local -xzf go1.16.15.linux-amd64.tar.gz && \
        rm go1.16.15.linux-amd64.tar.gz && \
        cd /usr/src/app && \
        go build && \
        apt-get purge -y --auto-remove curl build-essential && \
        rm -rf /var/lib/apt/lists/* /tmp/*
    ```

***

#### 1) **Frontend**: Build and check image sizes

- Build using `unoptimized` dockerfile  

    ```bash
    $ docker build -f ./Dockerfile.unoptimized.frontend \
        -t frontend-app-unoptimized \
        --build-arg REACT_APP_BACKEND_URL=http://localhost:8080  \
        ../cloud-container-deploy/example-frontend/
    ```

- Build using `optimized` dockerfile  
    ```bash
    docker build -f ./Dockerfile.optimized.frontend \
        -t frontend-app-optimized \
        --build-arg REACT_APP_BACKEND_URL=http://localhost:8080  \
        ../cloud-container-deploy/example-frontend/
    ```

- Check the Layers and sizes

    *Unoptimized image layers*
    ```bash
    $ docker image history frontend-app-unoptimized
    IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
    f23f91d6251b   2 hours ago    CMD ["-s" "-l" "5000" "build"]                  0B        buildkit.dockerfile.v0
    <missing>      2 hours ago    ENTRYPOINT ["serve"]                            0B        buildkit.dockerfile.v0
    <missing>      2 hours ago    EXPOSE &{[{{20 0} {20 0}}] 0xc0017aeb80}        0B        buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c npm install -g serve # buildk…   11.6MB    buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c npm run build # buildkit         7.99MB    buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c npm install # buildkit           678MB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c npm -v # buildkit                20.5kB    buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c node -v # buildkit               4.1kB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c apt-get install -y nodejs # b…   107MB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c curl -fsSL https://deb.nodeso…   8.25MB    buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c apt-get install -y curl # bui…   10.9MB    buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c apt-get update # buildkit        56.3MB    buildkit.dockerfile.v0
    <missing>      2 hours ago    COPY . . # buildkit                             131kB     buildkit.dockerfile.v0
    <missing>      43 hours ago   WORKDIR /usr/src/app                            16.4kB    buildkit.dockerfile.v0
    <missing>      43 hours ago   ENV REACT_APP_BACKEND_URL=https://example-ba…   0B        buildkit.dockerfile.v0
    <missing>      43 hours ago   ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC   0B        buildkit.dockerfile.v0
    <missing>      4 weeks ago    /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
    <missing>      4 weeks ago    /bin/sh -c #(nop) ADD file:ddf1aa62235de6657…   87.6MB
    <missing>      4 weeks ago    /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago    /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago    /bin/sh -c #(nop)  ARG LAUNCHPAD_BUILD_ARCH     0B
    <missing>      4 weeks ago    /bin/sh -c #(nop)  ARG RELEASE                  0B
    ```
    
    *Optimized image layers*
    ```bash
    $ docker image history frontend-app-optimized
    IMAGE          CREATED              CREATED BY                                      SIZE      COMMENT
    556f369805ef   About a minute ago   CMD ["-s" "-l" "5000" "build"]                  0B        buildkit.dockerfile.v0
    <missing>      About a minute ago   ENTRYPOINT ["serve"]                            0B        buildkit.dockerfile.v0
    <missing>      About a minute ago   EXPOSE &{[{{21 0} {21 0}}] 0xc0022f6100}        0B        buildkit.dockerfile.v0
    <missing>      About a minute ago   RUN /bin/sh -c apt-get update &&     apt-get…   764MB     buildkit.dockerfile.v0
    <missing>      2 hours ago          COPY . . # buildkit                             131kB     buildkit.dockerfile.v0
    <missing>      43 hours ago         WORKDIR /usr/src/app                            16.4kB    buildkit.dockerfile.v0
    <missing>      43 hours ago         ENV REACT_APP_BACKEND_URL=https://example-ba…   0B        buildkit.dockerfile.v0
    <missing>      43 hours ago         ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC   0B        buildkit.dockerfile.v0
    <missing>      4 weeks ago          /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
    <missing>      4 weeks ago          /bin/sh -c #(nop) ADD file:ddf1aa62235de6657…   87.6MB
    <missing>      4 weeks ago          /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago          /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago          /bin/sh -c #(nop)  ARG LAUNCHPAD_BUILD_ARCH     0B
    <missing>      4 weeks ago          /bin/sh -c #(nop)  ARG RELEASE                  0B
    e3.6-docker-optimized-images [main]$
    ```

- Check image sizes
    ```bash
    $ docker images | grep frontend-app
    frontend-app-optimized          latest        556f369805ef   About a minute ago   995MB
    frontend-app-unoptimized        latest        f23f91d6251b   2 hours ago          1.23GB
    ```

- Observation:
  The unoptimized image, with its many separate RUN instructions, results in multiple layers that individually retain build artifacts, caches, and intermediate files—leading to a final size of `1.23GB`. In contrast, the optimized image consolidates install, build, and cleanup operations within a single RUN statement, reducing redundant layers and minimizing residual files. This yields a final image size of `995MB`, a `reduction of 21%`.

---

#### 2) **Backend**: Build and check image sizes

- Build using `unoptimized` dockerfile  

    ```bash
    docker build -f ./Dockerfile.unoptimized.backend \
        -t backend-app-unoptimized \
        --build-arg REQUEST_ORIGIN=http://localhost:5000  \
        ../cloud-container-deploy/example-backend/
    ```

- Build using `optimized` dockerfile  

    ```bash
    docker build -f ./Dockerfile.optimized.backend \
        -t backend-app-optimized \
        --build-arg REQUEST_ORIGIN=http://localhost:5000  \
        ../cloud-container-deploy/example-backend/
    ```

- Check the Layers and sizes

    *Unoptimized image layers*
    ```bash
    $ docker image history backend-app-unoptimized
    IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
    340d935488fd   2 hours ago    ENTRYPOINT ["./server"]                         0B        buildkit.dockerfile.v0
    <missing>      2 hours ago    EXPOSE &{[{{23 0} {23 0}}] 0xc001c23540}        0B        buildkit.dockerfile.v0
    <missing>      2 hours ago    ENV PORT=8080                                   0B        buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c go build # buildkit              163MB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c cd /usr/src/app # buildkit       4.1kB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c tar -C /usr/local -xzf go1.16…   419MB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c curl -LO https://go.dev/dl/go…   129MB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c cd /tmp # buildkit               4.1kB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c apt-get install -y curl build…   347MB     buildkit.dockerfile.v0
    <missing>      2 hours ago    RUN /bin/sh -c apt-get update # buildkit        56.3MB    buildkit.dockerfile.v0
    <missing>      2 hours ago    COPY . . # buildkit                             102kB     buildkit.dockerfile.v0
    <missing>      43 hours ago   WORKDIR /usr/src/app                            16.4kB    buildkit.dockerfile.v0
    <missing>      43 hours ago   ENV REQUEST_ORIGIN=https://example-frontend-…   0B        buildkit.dockerfile.v0
    <missing>      43 hours ago   ENV PATH=/usr/local/go/bin:/usr/local/sbin:/…   0B        buildkit.dockerfile.v0
    <missing>      4 weeks ago    /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
    <missing>      4 weeks ago    /bin/sh -c #(nop) ADD file:ddf1aa62235de6657…   87.6MB
    <missing>      4 weeks ago    /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago    /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago    /bin/sh -c #(nop)  ARG LAUNCHPAD_BUILD_ARCH     0B
    <missing>      4 weeks ago    /bin/sh -c #(nop)  ARG RELEASE                  0B
    ```

    *Optimized image layers*
    ```bash
    $ docker image history backend-app-optimized
    IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
    1d799cbd64d6   32 minutes ago   ENTRYPOINT ["./server"]                         0B        buildkit.dockerfile.v0
    <missing>      32 minutes ago   EXPOSE &{[{{27 0} {27 0}}] 0xc002af3300}        0B        buildkit.dockerfile.v0
    <missing>      32 minutes ago   ENV PORT=8080                                   0B        buildkit.dockerfile.v0
    <missing>      32 minutes ago   RUN /bin/sh -c apt-get update &&     apt-get…   586MB     buildkit.dockerfile.v0
    <missing>      2 hours ago      COPY . . # buildkit                             102kB     buildkit.dockerfile.v0
    <missing>      43 hours ago     WORKDIR /usr/src/app                            16.4kB    buildkit.dockerfile.v0
    <missing>      43 hours ago     ENV REQUEST_ORIGIN=https://example-frontend-…   0B        buildkit.dockerfile.v0
    <missing>      43 hours ago     ENV PATH=/usr/local/go/bin:/usr/local/sbin:/…   0B        buildkit.dockerfile.v0
    <missing>      4 weeks ago      /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
    <missing>      4 weeks ago      /bin/sh -c #(nop) ADD file:ddf1aa62235de6657…   87.6MB
    <missing>      4 weeks ago      /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago      /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
    <missing>      4 weeks ago      /bin/sh -c #(nop)  ARG LAUNCHPAD_BUILD_ARCH     0B
    <missing>      4 weeks ago      /bin/sh -c #(nop)  ARG RELEASE                  0B
    ```

- Check image sizes
    ```bash
    $ docker images | grep backend-app
    backend-app-optimized           latest        1d799cbd64d6   33 minutes ago   877MB
    backend-app-unoptimized         latest        340d935488fd   2 hours ago      1.69GB
    ```

- Observation:
  The backend unoptimized image, with numerous RUN instructions, contains several large layers—curl, build-essential, Go download/extract, and the build itself—causing a bloated image of `1.69GB`. The optimized image consolidates all of these into a single RUN step followed by explicit cleanup, resulting in a much slimmer image of `877MB`.
  This represents a `48%` reduction in image size. 
---