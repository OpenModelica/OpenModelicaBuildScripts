#!/bin/sh -xe

sh -c 'sudo docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
sudo docker build -t openmodelica/moparser - < Dockerfile.moparser
sudo docker push openmodelica/moparser
