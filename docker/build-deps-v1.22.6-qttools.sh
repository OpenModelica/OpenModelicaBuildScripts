export TAG=v1.22.6-qttools
export REGISTRY=docker.openmodelica.org
docker build --pull --no-cache --tag build-deps:$TAG - < Dockerfile.$TAG
docker login
docker image tag build-deps:$TAG $REGISTRY/build-deps:$TAG
docker push $REGISTRY/build-deps:$TAG
