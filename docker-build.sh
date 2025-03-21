#!/usr/bin/env bash

# Script to build and tag the docker image

IMG_VER=1.2.2
DOCKER_REPO=artifactory.dsto.defence.gov.au
GROUP=ia-test

# docker build -t elestio/ws-screenshot.slim .
echo docker build -t ${DOCKER_REPO}/${GROUP}/ws-screenshot.slim:${IMG_VER} .
docker build -t ${DOCKER_REPO}/${GROUP}/ws-screenshot.slim:${IMG_VER} .

