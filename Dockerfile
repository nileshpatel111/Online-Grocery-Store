FROM ubuntu:16.04

################## NODE JS INSTALLATION ######################
ENV NODE_VERSION=12.6.0
RUN apt-get update && apt-get install -y apt-transport-https
RUN apt install curl -y
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version
RUN npm install pm2 -g
################## END INSTALLATION ######################

################## BEGIN MONGO DB INSTALLATION ######################
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 0C49F3730359A14518585931BC711F9BA15703C6 && \
gpg --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mongodb.gpg
ARG MONGO_PACKAGE=mongodb-org
ARG MONGO_REPO=repo.mongodb.org
ENV MONGO_PACKAGE=${MONGO_PACKAGE} MONGO_REPO=${MONGO_REPO}
ENV MONGO_MAJOR 3.4
ENV MONGO_VERSION 3.4.18
RUN echo "deb http://$MONGO_REPO/apt/debian jessie/${MONGO_PACKAGE%-unstable}/$MONGO_MAJOR main" | tee "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list"
RUN echo "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list"
RUN apt-get update
RUN apt-get install -y ${MONGO_PACKAGE}=$MONGO_VERSION

# Create the default data directory
RUN mkdir -p /data/db
################## END INSTALLATION ######################

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY ./package*.json ./
RUN npm install

# Bundle app source
COPY . .


EXPOSE 3000

CMD mongod --fork --syslog; pm2-runtime app.js


