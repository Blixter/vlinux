FROM debian:buster-slim

RUN apt-get update && \
apt-get install -y curl

WORKDIR /client

COPY . ./

ENTRYPOINT ./mazerunner.bash loop && /bin/bash