#!/bin/sh

export DOCKER_HOST=tcp://5.198.141.210:2375
export TARGET=http://andypowe11.net
docker build -t andypowe11/locustio .
docker push andypowe11/locustio
docker run -d --name master -p 80:8089 andypowe11/locustio --host=${TARGET} --master
docker run -d --name slave --link master andypowe11/locustio --host=${TARGET} --slave --master-host=master
docker ps
