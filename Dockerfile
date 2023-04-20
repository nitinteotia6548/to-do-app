##BUILD STAGE
FROM node:19-alpine as build
WORKDIR /app
COPY package.json /app/package.json
RUN yarn install
COPY . .
RUN yarn build

##RUN STAGE
FROM nginx:1.21.0-alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]