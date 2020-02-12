FROM debian:stretch-slim

WORKDIR kmom03

COPY commands.bash /kmom03/

RUN apt-get update && \
    apt-get -y install bsdmainutils


RUN chmod +x /kmom03/*.bash


CMD ./commands.bash all

