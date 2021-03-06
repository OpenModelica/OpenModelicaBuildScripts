#!/bin/sh -xe

cd moparser
sh -c 'docker login -u openmodelica -p=`cat ~/.docker/openmodelica.password`'
wget https://github.com/modelica-tools/ModelicaSyntaxChecker/raw/e759da7cdea44391ec84c663275f03a6771381cc/Linux64/moparser -O moparser
chmod +x moparser
docker build -t openmodelica/moparser:3.4 .
docker tag openmodelica/moparser:3.4 openmodelica/moparser:latest
docker push openmodelica/moparser:latest
docker push openmodelica/moparser:3.4
