#!/bin/sh -xe

docker login docker.openmodelica.org

TAG=docker.openmodelica.org/jnlp-slave:default
docker build --pull -t "$TAG" jnlp-slave
docker push "$TAG"
