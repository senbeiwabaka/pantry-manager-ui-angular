FROM node:18.15.0 AS node
WORKDIR /usr/src/app
RUN ls
COPY ./Angular-UI/package*.json ./
RUN ls
RUN npm install
COPY ./Angular-UI/ .
RUN npm run build

FROM nginx:1.23.4

RUN apk update && \
    apk add --no-cache openssl && \
    openssl req -x509 -nodes -days 365 \
    -subj  "/C=CA/ST=QC/O=Pantry Manager/CN=pantry-manager.com" \
    -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt;

RUN update-ca-certificates

COPY --from=node /usr/src/app/dist/pantry-manager-ui/ /usr/share/nginx/html
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
