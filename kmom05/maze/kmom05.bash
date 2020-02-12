sudo docker network create dbwebb

sudo docker run -d --rm --net dbwebb -p 1337:1337 --name mazeserver blixter/vlinux-mazeserver:latest

sudo docker run -it --rm --net dbwebb --link mazeserver:server --name mazeclient blixter/vlinux-mazeclient:latest /bin/bash

sudo docker stop mazeserver

sudo docker network rm dbwebb