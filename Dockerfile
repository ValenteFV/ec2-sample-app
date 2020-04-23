FROM node:14-buster
EXPOSE 80

ENV DBHOST='localhost'
ENV DBUSER='root'
ENV DBPASSWORD='pokemon'


RUN mkdir -p /home/node/app/
WORKDIR /home/node/app

COPY . .

RUN npm install

#Run node connection-test.js

CMD [ "node", "index.js" ]
