FROM debian:buster-slim

RUN apt-get update && \
apt-get install -y curl && \
apt-get install -y jq

WORKDIR /client

COPY . /client

RUN chmod +x bthloggen.bash

ENTRYPOINT /bin/bash