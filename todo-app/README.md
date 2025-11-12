docker compose -f docker-compose.dev.yaml build
docker compose -f docker-compose.dev.yaml up -d todo-frontend-app
compose  -f docker-compose.dev.yaml run debug-helper wget -O - http://todo-frontend-app:3000
docker compose -f docker-compose.dev.yaml down --volumes  --remove-orphans

OR

docker compose -f docker-compose.dev.yaml build
docker compose -f docker-compose.dev.yaml up -d
docker container ls
http GET http://localhost:8080
docker exec -it reverse-proxy bash
curl http://localhost:80
docker compose -f docker-compose.dev.yaml down --volumes  --remove-orphans

next assignment - build a containerized development environment for a React/Node Single page web app
Put the Nginx server in front of both todo-frontend and todo-backend.
1) Create todo-app/docker-compose.dev.yml
2) Create todo-app/nginx.dev.conf
3) Create todo-frontend/dev.Dockerfile
3) Add the services Nginx and the todo-frontend built with todo-app/todo-frontend/dev.Dockerfile into the todo-app/docker-compose.dev.yml.

review the progress so far:
todo-app [main]$ pwd

/home/arkane/workspace/uh-cs/e2.11/part12-containers-applications/todo-app
todo-app [main]$ tree
.
├── README.md
├── docker-compose.dev.yaml
├── nginx.dev.conf
├── todo-backend
│   ├── app.js
│   ├── docker-compose.dev.yaml
│   ├── docker-compose.yaml
│   ├── mongo
│   ├── <<-- snip-->>
│   ├── node_modules
└── todo-frontend
    ├── README.md
    ├── dev.Dockerfile
    ├── index.html
    ├── package-lock.json
    ├── package.json
    ├── <<-- snip-->>
    └── vite.config.js

todo-app [main]$ cat docker-compose.dev.yaml
services:
  todo-frontend-app:
    image: todo-frontend-dev
    build:
      context: ./todo-frontend # The context will pick this directory as the "build context"
      dockerfile: dev.Dockerfile # This will simply tell which dockerfile to read
    volumes:
      - ./todo-frontend:/usr/src/app # The path can be relative, so ./ is enough to say "the same location as the docker-compose.yml"
    ports:
      - 5173:5173
    container_name: todo-frontend-dev # This will name the container hello-front-dev
  debug-helper:
    image: busybox

  nginx:
    image: nginx:1.20.1
    volumes:
      - ./nginx.dev.conf:/etc/nginx/nginx.conf:ro
    ports:
      - 8080:80
    container_name: reverse-proxy
    depends_on:
      - todo-frontend-app # wait for the frontend container to be started
todo-app [main]$ cat nginx.dev.conf
# events is required, but defaults are ok
events { }

# A http server, listening at port 80
http {
  server {
    listen 80;

    # Requests starting with root (/) are handled
    location / {
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection 'upgrade';
      
      proxy_pass http://todo-frontend-app:5173;
    }
  }
}
todo-app [main]$
todo-app [main]$ cat todo-frontend/dev.Dockerfile
FROM node:20
ENV VITE_BACKEND_URL=TBD
WORKDIR /usr/src/app

COPY . .

# Change npm ci to npm install since we are going to be in development mode
RUN npm install

# npm run dev is the command to start the application in development mode
CMD ["npm", "run", "dev", "--", "--host"]

# --

todo-app [main]$ cat todo-frontend/vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Allow the 'app' hostname from Docker network
    allowedHosts: ['app', 'localhost', 'todo-frontend-app']
  }
})


# Execution logs
todo-app [main]$ docker compose -f docker-compose.dev.yaml down --volumes  --remove-orphans
[+] Running 4/4
 ✔ Container reverse-proxy            Removed                                                                                                          0.7s
 ✔ Container todo-app-debug-helper-1  Removed                                                                                                          0.0s
 ✔ Container todo-frontend-dev        Removed                                                                                                          1.0s
 ✔ Network todo-app_default           Removed                                                                                                          0.5s
todo-app [main]$ docker compose -f docker-compose.dev.yaml build
[+] Building 3.7s (11/11) FINISHED
 => [internal] load local bake definitions                                                                                                             0.0s
 => => reading from stdin 670B                                                                                                                         0.0s
 => [internal] load build definition from dev.Dockerfile                                                                                               0.0s
 => => transferring dockerfile: 759B                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/node:20                                                                                             2.1s
 => [internal] load .dockerignore                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                        0.0s
 => [1/4] FROM docker.io/library/node:20@sha256:47dacd49500971c0fbe602323b2d04f6df40a933b123889636fc1f76bf69f58a                                       0.0s
 => => resolve docker.io/library/node:20@sha256:47dacd49500971c0fbe602323b2d04f6df40a933b123889636fc1f76bf69f58a                                       0.0s
 => [internal] load build context                                                                                                                      0.2s
 => => transferring context: 562.83kB                                                                                                                  0.2s
 => CACHED [2/4] WORKDIR /usr/src/app                                                                                                                  0.0s
 => CACHED [3/4] COPY . .                                                                                                                              0.0s
 => CACHED [4/4] RUN npm install                                                                                                                       0.0s
 => exporting to image                                                                                                                                 0.1s
 => => exporting layers                                                                                                                                0.0s
 => => exporting manifest sha256:c8cf06571cf211d83ed6fc7dd7086c0eb113e124d8e8243963dca98392524dc1                                                      0.0s
 => => exporting config sha256:3f879c21c1482a84fc17c91b3dd5f597f119fbde100e328621856f1c7af5ef0c                                                        0.0s
 => => exporting attestation manifest sha256:410b78614d90afab74602714dbe64f93d6404bda2525e9a7db390d48ced1fa06                                          0.0s
 => => exporting manifest list sha256:1178199a145c1e2b610b434ca11f685588fa21c49961c389c59261fa734e44f0                                                 0.0s
 => => naming to docker.io/library/todo-frontend-dev:latest                                                                                            0.0s
 => => unpacking to docker.io/library/todo-frontend-dev:latest                                                                                         0.0s
 => resolving provenance for metadata file                                                                                                             0.0s
[+] Building 1/1
 ✔ todo-frontend-dev  Built                                                                                                                            0.0s
todo-app [main]$ docker compose -f docker-compose.dev.yaml ps -a
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
todo-app [main]$ docker compose -f docker-compose.dev.yaml up -d
[+] Running 4/4
 ✔ Network todo-app_default           Created                                                                                                          0.1s
 ✔ Container todo-frontend-dev        Started                                                                                                          1.4s
 ✔ Container todo-app-debug-helper-1  Started                                                                                                          1.4s
 ✔ Container reverse-proxy            Started                                                                                                          1.6s
todo-app [main]$ docker compose -f docker-compose.dev.yaml ps -a
NAME                      IMAGE               COMMAND                  SERVICE             CREATED         STATUS                     PORTS
reverse-proxy             nginx:1.20.1        "/docker-entrypoint.…"   nginx               4 seconds ago   Up 2 seconds               0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
todo-app-debug-helper-1   busybox             "sh"                     debug-helper        4 seconds ago   Exited (0) 3 seconds ago
todo-frontend-dev         todo-frontend-dev   "docker-entrypoint.s…"   todo-frontend-app   4 seconds ago   Up 3 seconds               0.0.0.0:5173->5173/tcp, [::]:5173->5173/tcp
todo-app [main]$ http GET http://localhost:8080
HTTP/1.1 200 OK
Cache-Control: no-cache
Connection: keep-alive
Content-Length: 674
Content-Type: text/html
Date: Tue, 11 Nov 2025 09:50:16 GMT
Etag: W/"2a2-+TF4QPANxd7MncWl2uJwo2VI3UI"
Server: nginx/1.20.1
Vary: Origin

<!doctype html>
<html lang="en">
  <head>
    <script type="module">
import RefreshRuntime from "/@react-refresh"
RefreshRuntime.injectIntoGlobalHook(window)
window.$RefreshReg$ = () => {}
window.$RefreshSig$ = () => (type) => type
window.__vite_plugin_react_preamble_installed__ = true
</script>

    <script type="module" src="/@vite/client"></script>

    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + React</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>


todo-app [main]$

===================================xxx================================

So this part works.
However the assignment requirements is to make it work with port 3000.
(http://todo-frontend-app:3000)

what do we need to change to make it work?

Probably the following is to be changed, review it
1) todo-frontend/vite.config.js > defineConfig > port 3000 has to be allowed ?

2) todo-app/nginx.dev.conf has to be changed:
FROM:
proxy_pass http://todo-frontend-app:5173;
TO:
proxy_pass http://todo-frontend-app:3000;

3) todo-app/docker-compose.dev.yaml has to be changed:
services:
  todo-frontend-app:
    # FROM:
    ports:
      - 5173:5173
    # TO:
    ports:
      - 3000:3000
    # <rest unchanged>      

4) change todo-frontend/dev.Dockerfile
FROM:
CMD ["npm", "run", "dev", "--", "--host"]
TO:
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "3000"]



# execution logs
todo-app [main]$ docker compose -f docker-compose.dev.yaml build
[+] Building 27.0s (11/11) FINISHED
 => [internal] load local bake definitions                                                                                                             0.0s
 => => reading from stdin 670B                                                                                                                         0.0s
 => [internal] load build definition from dev.Dockerfile                                                                                               0.0s
 => => transferring dockerfile: 831B                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/node:20                                                                                             2.0s
 => [internal] load .dockerignore                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                        0.0s
 => [1/4] FROM docker.io/library/node:20@sha256:47dacd49500971c0fbe602323b2d04f6df40a933b123889636fc1f76bf69f58a                                       0.0s
 => => resolve docker.io/library/node:20@sha256:47dacd49500971c0fbe602323b2d04f6df40a933b123889636fc1f76bf69f58a                                       0.0s
 => [internal] load build context                                                                                                                      0.5s
 => => transferring context: 562.90kB                                                                                                                  0.5s
 => CACHED [2/4] WORKDIR /usr/src/app                                                                                                                  0.0s
 => [3/4] COPY . .                                                                                                                                     1.8s
 => [4/4] RUN npm install                                                                                                                             19.1s
 => exporting to image                                                                                                                                 3.1s
 => => exporting layers                                                                                                                                2.0s
 => => exporting manifest sha256:66d4261cc0a04a38512c9acca7a2b337e94fa2ef68edc33b68615f68319984c0                                                      0.0s
 => => exporting config sha256:99ae979cfe60740e336bc29de3ee35fd22933e41351a47efe7edfe5ae17775b4                                                        0.0s
 => => exporting attestation manifest sha256:9d5b81722bd0ffde3aa0debfd7a847b079fc74db0c27841610cf914fdafc06e4                                          0.0s
 => => exporting manifest list sha256:ca6db906449a3dc7a16a9d5847c3760560eb66da8f28788020b6d17f182ee7bc                                                 0.0s
 => => naming to docker.io/library/todo-frontend-dev:latest                                                                                            0.0s
 => => unpacking to docker.io/library/todo-frontend-dev:latest                                                                                         1.0s
 => resolving provenance for metadata file                                                                                                             0.0s
[+] Building 1/1
 ✔ todo-frontend-dev  Built                                                                                                                            0.0s
todo-app [main]$ docker compose -f docker-compose.dev.yaml up -d
[+] Running 4/4
 ✔ Network todo-app_default           Created                                                                                                          0.1s
 ✔ Container todo-app-debug-helper-1  Started                                                                                                          0.9s
 ✔ Container todo-frontend-dev        Started                                                                                                          0.9s
 ✔ Container reverse-proxy            Started                                                                                                          1.0s
todo-app [main]$ docker compose -f docker-compose.dev.yaml ps -a
NAME                      IMAGE               COMMAND                  SERVICE             CREATED          STATUS                     PORTS
reverse-proxy             nginx:1.20.1        "/docker-entrypoint.…"   nginx               10 seconds ago   Up 8 seconds               0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
todo-app-debug-helper-1   busybox             "sh"                     debug-helper        10 seconds ago   Exited (0) 8 seconds ago
todo-frontend-dev         todo-frontend-dev   "docker-entrypoint.s…"   todo-frontend-app   10 seconds ago   Up 9 seconds               0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp

todo-app [main]$ docker logs todo-frontend-dev

> todo-frontend@0.0.0 dev
> vite --host 0.0.0.0 --port 3000


  VITE v5.4.21  ready in 197 ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: http://172.18.0.2:3000/
todo-app [main]$

todo-app [main]$ http GET http://localhost:8080
HTTP/1.1 200 OK
Cache-Control: no-cache
Connection: keep-alive
Content-Length: 674
Content-Type: text/html
Date: Tue, 11 Nov 2025 10:07:21 GMT
Etag: W/"2a2-+TF4QPANxd7MncWl2uJwo2VI3UI"
Server: nginx/1.20.1
Vary: Origin

<!doctype html>
<html lang="en">
  <head>
    <script type="module">
import RefreshRuntime from "/@react-refresh"
RefreshRuntime.injectIntoGlobalHook(window)
window.$RefreshReg$ = () => {}
window.$RefreshSig$ = () => (type) => type
window.__vite_plugin_react_preamble_installed__ = true
</script>

    <script type="module" src="/@vite/client"></script>

    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + React</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>


todo-app [main]$