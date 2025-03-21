#!/usr/bin/env bash

# Script to run the ws-screenshot.slim image in a docker container
# docker run --rm -p 3000:3000 -it ia-test/ws-screenshot.slim

IMG_VER=1.2.2
DOCKER_REPO=artifactory.dsto.defence.gov.au
GROUP=ia-test

docker run --rm -p 3000:3000 -it ${DOCKER_REPO}/${GROUP}/ws-screenshot.slim:${IMG_VER}

