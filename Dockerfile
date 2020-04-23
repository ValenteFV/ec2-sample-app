FROM node:14-buster
EXPOSE 80

ENV DBHOST='localhost'
ENV DBUSER='root'
ENV DBPASSWORD='pokemon'


RUN mkdir -p /home/node/app/
WORKDIR /home/node/app

COPY . .

RUN npm install
RUN node create-tables.js
RUN node connection-test.js

#CMD [ "node", "index.js" ]
