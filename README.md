# OpenModelicaBuildScripts


A collection of scripts that can build OpenModelica packages on miscellaneous platforms


## Docker Images

Docker images are hosted on [docker.openmodelica.org](docker.openmodelica.org) and need to
be uploaded manually.

### Example

To add a new image to [docker.openmodelica.org](docker.openmodelica.org)
the image needs to be build, tagged correctly and then pushed to the server.

For example for [Dockerfile.build-deps-cmake-1.16.3](./docker/Dockerfile.build-deps-cmake-1.16.3)
one would run:

```bash
docker build --tag build-deps-cmake:v1.16.3 -f Dockerfile.build-deps-cmake-1.16.3 .
docker tag build-deps-cmake:v1.16.3 docker.openmodelica.org/build-deps-cmake:v1.16.3
docker push docker.openmodelica.org/build-deps-cmake:v1.16.3
```
