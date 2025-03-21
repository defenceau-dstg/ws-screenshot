#!/usr/bin/env bash

# Script to push docker image

IMG_VER=1.2.2
DOCKER_REPO=artifactory.dsto.defence.gov.au
GROUP=ia-test


# docker push elestio/ws-screenshot.slim:latest
docker push ${DOCKER_REPO}/${GROUP}/ws-screenshot.slim:${IMG_VER}

