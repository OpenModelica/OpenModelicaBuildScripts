#!/bin/sh -xe

docker login docker.openmodelica.org
if false; then
  ARGS="--build-arg REPO=i386/ubuntu --build-arg DISTRO=bionic"
fi

TAG=docker.openmodelica.org/build-deps:v1.13-i386
docker build $ARGS -t "$TAG" - < Dockerfile.build-deps-i386
docker push "$TAG"
