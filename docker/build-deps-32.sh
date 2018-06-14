#!/bin/sh -xe

sh -c 'sudo docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
if true; then
  ARGS="--build-arg REPO=i386/ubuntu --build-arg DISTRO=bionic"
fi

TAG=docker.openmodelica.org/build-deps:v1.13-i386
sudo docker build $ARGS -t "$TAG" - < Dockerfile.build-deps-i386
sudo docker push "$TAG"
