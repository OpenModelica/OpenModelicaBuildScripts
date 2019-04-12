#!/bin/sh

if ! test -e /var/run/docker.sock; then
  echo "/var/run/docker.sock does not exist"
  exit 1
fi
GROUP="`stat -c '%g' /var/run/docker.sock`"
if test "UNKNOWN" = "$GROUP"; then
  addgroup --gid "`stat -c '%g' /var/run/docker.sock`" dockersock
  usermod -a -G dockersock jenkins
else
  usermod -a -G "$GROUP" jenkins
fi
touch /tmp/dockersock.test
chmod 440 /tmp/dockersock.test
chown root:dockersock /tmp/dockersock.test
mkdir -p /jenkins-ws /home/jenkins/ws
chmod ugo+rwx /jenkins-ws
mount -o bind -t none /jenkins-ws /home/jenkins/ws
hostname >> /jenkins-ws/local-workspace.txt
