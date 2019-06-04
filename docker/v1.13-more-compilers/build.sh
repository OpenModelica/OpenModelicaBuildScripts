for f in jessie stretch disco; do
  sudo docker build -t docker.openmodelica.org/build-deps:v1.13-$f - < Dockerfile.$f
  sudo docker push docker.openmodelica.org/build-deps:v1.13-$f
done
