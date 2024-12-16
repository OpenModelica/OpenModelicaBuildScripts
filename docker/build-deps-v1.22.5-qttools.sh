export TAG=v1.22.5-qttools
export REGISTRY=docker.openmodelica.org
docker build --pull --no-cache --tag build-deps:$TAG - < Dockerfile.build-deps-v1.22.5-qttools
docker login
docker image tag build-deps:$TAG $REGISTRY/build-deps:$TAG
docker push $REGISTRY/build-deps:$TAG
