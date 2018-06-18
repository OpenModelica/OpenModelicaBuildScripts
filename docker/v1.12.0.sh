#!/bin/sh -xe

docker login
export IMAGE="--build-arg IMAGE=ubuntu:xenial"
export VERSION="$IMAGE --build-arg DISTRO=xenial --build-arg VERSION=v1.12.0"
docker build $VERSION --build-arg PACKAGES="omc" -t openmodelica/openmodelica:v1.12.0-minimal - < Dockerfile.omc-release
docker build $VERSION --build-arg PACKAGES="openmodelica" -t openmodelica/openmodelica:v1.12.0-gui - < Dockerfile.omc-release
#docker push openmodelica/openmodelica:v1.12.0-minimal
#docker push openmodelica/openmodelica:v1.12.0-gui
