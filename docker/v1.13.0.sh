#!/bin/sh -xe

docker login
export VERSION="--build-arg DISTRO=bionic --build-arg VERSION=1.13.0"
docker build --build-arg IMAGE=ubuntu:bionic $VERSION --build-arg PACKAGES="omc" -t openmodelica/openmodelica:v1.13.0-minimal - < Dockerfile.omc-release
docker build --build-arg IMAGE=openmodelica/openmodelica:v1.13.0-minimal $VERSION --build-arg PACKAGES="openmodelica" -t openmodelica/openmodelica:v1.13.0-gui - < Dockerfile.omc-release
#docker push openmodelica/openmodelica:v1.12.0-minimal
#docker push openmodelica/openmodelica:v1.12.0-gui
