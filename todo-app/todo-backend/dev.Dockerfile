FROM node:20

WORKDIR /usr/src/app

COPY --chown=node:node . .
#RUN npm ci --omit=dev
ENV DEBUG=todo-backend:*

#USER node

# PROD
CMD npm start
# DEV
#CMD npm run dev


# docker build -t express-server . && docker run -p 3123:3000 express-server

# docker build -f ./dev.Dockerfile -t todo-backend-dev .
# todo-backend [main]$ docker run -p 3123:3000 todo-backend-dev
# > todo-backend@0.0.0 start
# > node ./bin/www

