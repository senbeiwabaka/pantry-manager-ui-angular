FROM node:18.15.0 as node
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:1.23.4
COPY --from=node /usr/src/app/dist/pantry-manager-ui/ /usr/share/nginx/html
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
