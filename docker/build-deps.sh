#!/bin/sh -xe

docker login docker.openmodelica.org

if false; then
  ARGS="--build-arg REPO=ubuntu:bionic"
fi

LATEST=docker.openmodelica.org/build-deps:latest
TAG=docker.openmodelica.org/build-deps:v1.16
docker build --pull $ARGS -t "$TAG" - < Dockerfile.build-deps
docker tag "$TAG" "$LATEST"
docker push "$TAG"
docker push "$LATEST"
