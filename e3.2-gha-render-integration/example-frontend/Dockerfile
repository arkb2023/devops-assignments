FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
# ENV REACT_APP_BACKEND_URL=http://localhost:8080
ENV REACT_APP_BACKEND_URL=https://example-backend-jkvr.onrender.com

WORKDIR /usr/src/app
COPY . .
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v && \
    npm install && \
    npm run build && \
    npm install -g serve


EXPOSE 5000

# Default app
ENTRYPOINT ["serve"]

# Default arguments
CMD ["-s", "-l", "5000", "build"]
