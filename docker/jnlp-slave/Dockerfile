FROM jenkins/slave:alpine

USER root
RUN apk update && apk add docker sudo shadow && rm -rf /var/cache/apk/*
COPY jenkins-and-docker jenkins-slave fix-docker.sh /usr/local/bin/
COPY sudoers /etc/sudoers
RUN chmod ugo+rx /usr/local/bin/jenkins-slave /usr/local/bin/jenkins-and-docker /usr/local/bin/fix-docker.sh && chmod 440 /etc/sudoers
USER jenkins

ENTRYPOINT ["jenkins-and-docker"]
