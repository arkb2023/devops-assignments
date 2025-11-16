## Docker Security: Running Containers as Non-Root

### Backend:
```bash
# Build
docker build -f ./example-backend/Dockerfile \
    -t backend-app \
    --build-arg REQUEST_ORIGIN=http://localhost:5000 \
    ./example-backend/

# Run
docker run -d -p 8080:8080 backend-app

# Test
http GET http://localhost:8080/ping
```

### Frontend:
```bash
# Build
docker build -f ./example-frontend/Dockerfile \
    -t frontend-app \
    --build-arg REACT_APP_BACKEND_URL=http://localhost:8080 \
    ./example-frontend/

# Run
docker run -d -p 5000:5000 frontend-app

# Test
http GET http://localhost:5000
```

### Cleanup
```bash
# Stop
docker stop <container_name_or_id>

# Remove container
docker rm <container_name_or_id>

# Remove image
docker rmi <image>
```