FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
# ENV REACT_APP_BACKEND_URL=http://localhost:8080
ENV REACT_APP_BACKEND_URL=https://example-backend.com

WORKDIR /usr/src/app
COPY . .
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v && \
    npm install && \
    npm install -g serve


EXPOSE 5000

ENTRYPOINT ["sh", "-c"]
CMD ["npm run build && serve -s -l ${PORT:-5000} build"]
