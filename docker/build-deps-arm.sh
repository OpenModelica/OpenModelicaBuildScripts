#!/bin/sh -xe

docker login docker.openmodelica.org
if true; then
  ARGS="--build-arg REPO=arm32v7/ubuntu --build-arg DISTRO=bionic"
fi

TAG=docker.openmodelica.org/build-deps:v1.13-arm32
docker build $ARGS -t "$TAG" - < Dockerfile.build-deps-arm
docker push "$TAG"
