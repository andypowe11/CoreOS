#!/bin/sh

export DOCKER_HOST=tcp://5.198.141.210:2375
docker rm -f slave
docker rm -f master
