#!/bin/sh -xe

sh -c 'sudo docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
cp ../debian/control .
sudo docker build -t openmodelica/build-deps:latest - < Dockerfile.build-deps
sudo docker push openmodelica/build-deps:latest
