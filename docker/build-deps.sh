#!/bin/sh -xe

sh -c 'sudo docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
if false; then
  ARGS="--build-arg REPO=ubuntu --build-arg DISTRO=bionic"
fi

LATEST=docker.openmodelica.org/build-deps:latest
TAG=docker.openmodelica.org/build-deps:v1.13
docker build $ARGS -t "$TAG" - < Dockerfile.build-deps
docker tag "$TAG" "$LATEST"
docker push "$TAG"
docker push "$LATEST"
