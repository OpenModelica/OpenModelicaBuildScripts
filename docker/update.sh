#!/bin/sh -xe

sh -c 'sudo docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
sudo docker build -t openmodelica/openmodelica:nightly - < Dockerfile.nightly
sudo docker push openmodelica/openmodelica:nightly
