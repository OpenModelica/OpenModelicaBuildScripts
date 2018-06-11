# moparser depends on libstdc++ and GNU libc
ARG DISTRO=debian:9.4-slim
FROM ${DISTRO}
MAINTAINER Martin Sjölund <martin.sjolund@liu.se>
ENV DEBIAN_FRONTEND noninteractive

COPY ./moparser /usr/local/bin/moparser
RUN chmod +x /usr/local/bin/moparser && /usr/local/bin/moparser

WORKDIR /data
VOLUME ["/data"]
