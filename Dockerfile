##BUILD STAGE
FROM node:19-alpine as build
WORKDIR /app
COPY package.json /app/package.json
RUN yarn install
COPY . /app
RUN yarn build
COPY . /app

##RUN STAGE
FROM node:19-alpine
COPY --from=build /app/build .
RUN yarn add serve
EXPOSE 3000
CMD ["serve","-s build"]