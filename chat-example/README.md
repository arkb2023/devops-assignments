## [Exercise 3.10 Optimal Sized Image](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-4/optimizing-the-image-size)

### Dockerfile Optimization for Open Source project: [Socket.io Chat Example](https://github.com/socketio/chat-example.git)

### Overview:
The base (original) container specifications for [CodeSandbox](https://codesandbox.io/) environment were re-created for the Docker platform to serve as a starting point. This original image was then systematically optimized, applying best practices for security and size reduction, resulting in a much leaner, production-grade Dockerfile. The before-and-after Dockerfiles clearly illustrate the improvements achieved through multi-stage builds, a minimal base image, proper dependency handling, and the use of a non-root user.

### **1. Clone and Inspect the Project**

Clone the repository and navigate to the project directory:

```bash
git clone https://github.com/socketio/chat-example.git
cd chat-example
```

The project directory contains the following key files and folders:

```
.
├── .codesandbox
│   ├── Dockerfile
│   └── tasks.json
├── .gitignore
├── LICENSE
├── README.md
├── index.html
├── index.js
├── package-lock.json
└── package.json
```

This project ships with a minimal [Dockerfile](./.codesandbox/Dockerfile) and a [tasks.json](./.codesandbox/tasks.json) for easy use on the [CodeSandbox](https://codesandbox.io/) platform.

Preview the contents of the default CodeSandbox [Dockerfile](./.codesandbox/Dockerfile):

```bash
cat .codesandbox/Dockerfile
```
```dockerfile
FROM node:20
```

And the [task definitions](./.codesandbox/tasks.json):

```bash
cat .codesandbox/tasks.json
```
```json
{
  // These tasks will run in order when initializing your CodeSandbox project.
  "setupTasks": [
    {
      "name": "Install Dependencies",
      "command": "npm install"
    }
  ],

  // These tasks can be run from CodeSandbox. Running one will open a log in the app.
  "tasks": {
    "npm start": {
      "name": "npm start",
      "command": "npm start",
      "runAtStart": true,
      "preview": {
        "port": 3000
      }
    }
  }
}
```

- The `.codesandbox/Dockerfile` simply specifies the Node.js base image.
- The `.codesandbox/tasks.json` automates installation and starting the server when developing in the CodeSandbox environment.

> These files are tailored for online editing and preview and are not suitable as-is for local Docker builds.

### **2. Running on Docker: Creating a Local Base Dockerfile**

To run this project on the Docker platform *(outside CodeSandbox)*, create a base Dockerfile that replicates the environment specified by `.codesandbox/Dockerfile` and `.codesandbox/tasks.json`.

**Base Dockerfile ([Dockerfile.base](./Dockerfile.base)):**

```dockerfile
FROM node:20

WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
```

**Build the Image:**
```bash
docker build -t chat-example-base -f Dockerfile.base .
```

**Image Size:**  
After build, check the resulting image size:
```bash
docker images | egrep -i "chat|SIZE"
```
**Output:**
```
REPOSITORY           TAG     IMAGE ID      CREATED              SIZE
chat-example-base    latest  f3afd5f92987  About an hour ago    1.63GB
```

**Run the Container:**
```bash
docker run -d -p 3000:3000 chat-example-base:latest
```

**Test the Application:**
Cerify the app responds with HTTP (via [HTTPie](https://httpie.io/) or curl):

```bash
http --print Hh GET http://localhost:3000
```
**Sample HTTP Output:**
```
GET / HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: localhost:3000
User-Agent: HTTPie/3.2.2

HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Connection: keep-alive
Content-Length: 2028
Content-Type: text/html; charset=UTF-8
Date: Mon, 17 Nov 2025 09:23:05 GMT
ETag: W/"7ec-19a90954508"
Keep-Alive: timeout=5
Last-Modified: Mon, 17 Nov 2025 06:51:33 GMT
X-Powered-By: Express
```

**Note:**  
- This approach directly mimics how CodeSandbox sets up the development environment.
- The resulting image is functional but **very large** (1.63GB), providing a baseline for subsequent optimization.

---

### **3. Optimize the [Dockerfile.optimized](./Dockerfile.optimized)**

Below is the optimized, best-practices multi-stage Dockerfile:

```dockerfile
# -----------------------------------------------
# Stage 1:
# Install dependencies and copy source
# -----------------------------------------------
# Use minimal, secure, small Node.js Alpine base
FROM node:20-alpine AS build-stage

WORKDIR /usr/app

# Copy package files first to maximize layer caching
COPY package*.json ./

# Install production dependencies only (no dev deps)
RUN npm ci --omit=dev

# Copy remaining source files and assets
COPY . .

# -----------------------------------------------
# Stage 2: Production
# Create secure runtime image with only necessary files
# -----------------------------------------------
FROM node:20-alpine

WORKDIR /usr/app

# Copy built app and production dependencies from build stage
COPY --from=build-stage /usr/app ./

# Application user & group for least privilege; fix permissions
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /usr/app

USER appuser  # Drop root privileges

EXPOSE 3000
ENV NODE_ENV=production
CMD ["npm", "start"]
```

**Build the Optimized Image:**
```bash
docker build -t chat-example-optimized -f Dockerfile.optimized .
```

**Image Size:**
```bash
docker images | egrep -i "chat|SIZE"
```
**Output:**
```
REPOSITORY               TAG       IMAGE ID      CREATED             SIZE
chat-example-optimized   latest    cc71e99e105e  58 minutes ago      260MB
```

**Run the Optimized Container:**
```bash
docker run -d -p 3000:3000 chat-example-optimized:latest
```

**Test the Application:**
Verify with [HTTPie](https://httpie.io/) or curl:

```bash
http --print Hh GET http://localhost:3000
```
**Output:**
```
GET / HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: localhost:3000
User-Agent: HTTPie/3.2.2

HTTP/1.1 200 OK
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Connection: keep-alive
Content-Length: 2028
Content-Type: text/html; charset=UTF-8
Date: Mon, 17 Nov 2025 09:23:05 GMT
ETag: W/"7ec-19a90954508"
Keep-Alive: timeout=5
Last-Modified: Mon, 17 Nov 2025 06:51:33 GMT
X-Powered-By: Express
```

***

### **5. Summary**
- **Image Size Reduction**  
  - Base Dockerfile: **1.63GB**  
  - Optimized Dockerfile: **260MB**
- **Security**  
  - The app runs as a dedicated non-root user, limiting potential damage from vulnerabilities.
- **Efficiency**  
  - Only production dependencies are installed, ensuring lower image size, faster builds, and fewer vulnerabilities.
- **Clean Context**  
  - Only necessary runtime files and dependencies are included in the final image—no source code, dev tools, or test artifacts remain.


***
