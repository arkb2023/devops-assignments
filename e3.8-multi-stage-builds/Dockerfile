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


