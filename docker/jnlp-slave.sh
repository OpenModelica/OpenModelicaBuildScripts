#!/bin/sh -xe

docker login docker.openmodelica.org

TAG=docker.openmodelica.org/jnlp-slave:20190412
docker build --pull -t "$TAG" jnlp-slave
docker push "$TAG"
