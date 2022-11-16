FROM node:19-buster

USER root

WORKDIR /code

COPY ./scripts/*.sh /code/scripts
COPY ./sql /code/sql
COPY ./package*.json /code
COPY ./requirements.txt /code

RUN apt update && apt-get install -y curl p7zip-full python3 python3-pip sqlite3 libsqlite3-dev

RUN npm install

RUN pip3 install -r requirements.txt

ENTRYPOINT ["tail", "-f", "/dev/null"]