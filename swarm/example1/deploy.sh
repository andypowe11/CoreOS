#!/bin/sh

docker pull redis
docker run -d --name redis -p 6379:6379 redis
docker build -t andypowe11/node node
docker run -d --name node1 -p 8080 --link redis andypowe11/node
docker run -d --name node2 -p 8080 --link redis andypowe11/node
docker run -d --name node3 -p 8080 --link redis andypowe11/node
docker build -t andypowe11/nginx nginx
docker run -d --name nginx -p 80:80 --link node1 --link node2 --link node3 andypowe11/nginx
