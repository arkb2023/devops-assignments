# Build the image
docker build -t builder .

# Docker hub credentials
export DOCKER_USER=<username>
export DOCKER_PWD=<password>

# Run the builder
docker run -e DOCKER_USER=$DOCKER_USER -e DOCKER_PWD=$DOCKER_PWD \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder mluukkai/express_app arkb2023/testing


