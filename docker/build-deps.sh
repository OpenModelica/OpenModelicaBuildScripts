#!/bin/sh -xe

sh -c 'sudo docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
if false; then
  ARGS="--build-arg REPO=ubuntu --build-arg DISTRO=bionic"
fi
sudo docker build $ARGS -t openmodelica/build-deps:latest - < Dockerfile.build-deps
sudo docker push openmodelica/build-deps:latest
