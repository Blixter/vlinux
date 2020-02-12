FROM debian:buster-slim

RUN apt-get update && \
apt-get install -y curl

WORKDIR /client

COPY . ./

CMD ["executable","param1","param2"]