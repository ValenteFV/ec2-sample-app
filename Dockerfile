FROM node:14-buster
EXPOSE 80


ARG DBHOST

ENV DBHOST=$DBHOST
ENV DBUSER='root'
ENV DBPASSWORD='pokemon'


RUN mkdir -p /home/node/app/
WORKDIR /home/node/app

COPY . .

RUN npm install

#ßRUN node connection-test.js

CMD [ "node", "index.js" ]
