#!/bin/sh -xe

docker login docker.openmodelica.org

TAG=docker.openmodelica.org/wine-rtest:v2.0
docker build --pull -t "$TAG" wine-rtest
docker push "$TAG"
