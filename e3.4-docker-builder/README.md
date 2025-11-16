# Docker Builder

A containerized tool that automates the process of cloning a GitHub repository, building a Docker image, and publishing it to Docker Hub.

> **Course Assignment**: This project is part of [Exercise 3.4: Building images from inside a container](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-4/deployment-pipelines) from the [DevOps with Docker](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker) course.

## Features

- Clone any public GitHub repository
- Automatically find and build Dockerfile in repo root or subdirectory
- Tag images with both `latest` and git commit hash
- Push to Docker Hub with automatic authentication

## Prerequisites

- Docker installed and running
- Docker Hub account
- Access to `/var/run/docker.sock` (for Docker-in-Docker)

## Project Structure

```
.
├── Dockerfile          # Container definition
├── builder.sh          # Main builder script
├── entrypoint.sh       # Container entrypoint
└── README.md          # This file
```


## How It Works

1. **Container starts** with Docker socket mounted from host
2. **Entrypoint validates** environment variables and arguments
3. **Authenticates** to Docker Hub using provided credentials
4. **Builder script**:
   - Clones GitHub repository to temporary directory
   - Locates Dockerfile in specified location
   - Builds Docker image with proper tags
   - Pushes image to Docker Hub
   - Cleans up temporary files


## Quick Start

### 1. Build the Builder Image

```bash
docker build -t builder .
```

### 2. Run the Builder

```bash
export DOCKER_USER=<username> # Set Docker Hub username
export DOCKER_PWD=<password>  # Set Docker Hub password or access token

docker run -e DOCKER_USER=$DOCKER_USER \
  -e DOCKER_PWD=$DOCKER_PWD \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder <github-repo> <dockerhub-repo>
```

**Arguments**

| Argument | Required | Description |
|----------|----------|-------------|
| `github-repo` | Yes | GitHub repository in format `owner/repo` |
| `dockerhub-repo` | Yes | Docker Hub repository in format `username/image` |
| `project-dir` | No | Subdirectory containing the Dockerfile |

## Output

The builder will:
1. Clone the specified GitHub repository
2. Locate the Dockerfile
3. Build the Docker image
4. Tag with `latest` and git commit hash
5. Push to Docker Hub
6. Display the Docker Hub URL

---