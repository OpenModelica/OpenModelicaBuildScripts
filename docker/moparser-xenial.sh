#!/bin/sh -xe

sh -c 'sudo docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
sudo docker build --build-arg DISTRO=ubuntu:xenial -t openmodelica/moparser:xenial - < Dockerfile.moparser
sudo docker push openmodelica/moparser:xenial
