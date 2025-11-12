FROM node:20
ENV VITE_BACKEND_URL=TBD
WORKDIR /usr/src/app

COPY . .

# Change npm ci to npm install since we are going to be in development mode
RUN npm install

# npm run dev is the command to start the application in development mode
#CMD ["npm", "run", "dev", "--", "--host"]
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "3000"]

# ----------------
# ENV unset NODE_ENV
# # Change npm ci to npm install since we are going to be in development mode
# RUN npm install
# RUN ls node_modules/.bin/vite
# RUN npx vite --version

# # npm run dev is the command to start the application in development mode
# CMD ["npm", "run", "dev", "--", "--host", "--port", "3000"]

# --------------
# RUN npm ci

# RUN npm run build

# RUN npm install -g serve

# CMD ["serve", "dist"]