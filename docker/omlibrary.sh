#!/bin/bash -xe

docker pull alpine:latest
ALPINE=alpine:latest
PREVIOUS="$ALPINE"
docker login
PREVYM=""
for VERSION in `ssh build ls /var/www/libraries | grep -v latest | cut -d _ -f2 | cut -d . -f1 | sort -h`; do
  YM=`echo $VERSION | grep -oP "^\d{6}" | grep -oP "\d{2}$" | sed s/^0//`
  # Build a clean image every 6 months
  YM=$(($YM/6))
  TAG=openmodelica/omlibrary:$VERSION
  if test "$YM" != "$PREVYM"; then
    PREVIOUS="$ALPINE"
  fi
  if ! docker image inspect $TAG > /dev/null; then
    docker build --build-arg IMAGE=$PREVIOUS --build-arg VERSION=$VERSION -t openmodelica/omlibrary:$VERSION - < Dockerfile.omlibrary
    if test "$TAG" != "$ALPINE" && test $((`docker inspect $TAG | jq '.[0]["VirtualSize"]'` - `docker inspect $PREVIOUS | jq '.[0]["VirtualSize"]'`)) -gt 15728640; then
      # The diff size if >15MB; start a new image instead
      PREVIOUS=$TAG
      docker build --build-arg IMAGE=$ALPINE --build-arg VERSION=$VERSION -t openmodelica/omlibrary:$VERSION - < Dockerfile.omlibrary
    fi
    docker push openmodelica/omlibrary:$VERSION
  fi
  if test "$YM" != "$PREVYM"; then
    PREVIOUS=$TAG
  fi
  PREVYM=$YM
done
