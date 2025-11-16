### Frontend
```bash
$ docker images |egrep "frontend|SIZE"
REPOSITORY                      TAG           IMAGE ID       CREATED             SIZE
frontend-app-preinstalled       latest        9b09fe8ac4b6   18 minutes ago      667MB
frontend-app-optimized          latest        bccda88a7ae0   About an hour ago   995MB
frontend-app-unoptimized        latest        3a3e4f8ad7e0   About an hour ago   1.23GB
```

| Dockerfile                  | FROM              | Size   | Comment                                                        |
|-----------------------------|-------------------|--------|----------------------------------------------------------------|
| [Dockerfile.preinstalled.frontend](./Dockerfile.preinstalled.frontend) | node:16-alpine      | 667MB  | Alpine base with preinstalled Node; moderate size improvement. |
| [Dockerfile.optimized.frontend](../e3.6-docker-optimized-images/Dockerfile.optimized.frontend)    | ubuntu:24.04        | 995MB  | Optimized for fewer layers, cleaned up after build, but Ubuntu base and node_modules retained.            |
| [Dockerfile.unoptimized.frontend](../e3.6-docker-optimized-images/Dockerfile.unoptimized.frontend)  | ubuntu:24.04        | 1.23GB | Many layers, no cleanup, large due to dev dependencies and intermediate files.                            |

***


### Backend

```bash
$ docker images |egrep "backend|SIZE"
REPOSITORY                      TAG           IMAGE ID       CREATED             SIZE
backend-app-preinstalled        latest        0a6e9825cc8b   3 minutes ago       934MB
backend-app-optimized           latest        1d799cbd64d6   7 hours ago         877MB
backend-app-unoptimized         latest        340d935488fd   8 hours ago         1.69GB
```

| Dockerfile                      | FROM              | Size   | Comment                                                        |
|----------------------------------|-------------------|--------|----------------------------------------------------------------|
| Dockerfile.preinstalled.backend  | golang:1.16-alpine | 934MB  | Alpine base with preinstalled Go; still includes source code, Go toolchain, and build artifacts. |
| Dockerfile.optimized.backend     | ubuntu:24.04        | 877MB  | Optimized for fewer layers and some cleanup, but Ubuntu base and build chain retained.            |
| Dockerfile.unoptimized.backend   | ubuntu:24.04        | 1.69GB | Many layers, little or no cleanup, largest due to source code, dev files, and full toolchain.     |

***
