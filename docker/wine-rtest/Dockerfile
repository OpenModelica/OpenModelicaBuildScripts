FROM docker.openmodelica.org/msyscross-omsimulator:v2.0

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get upgrade -qy && apt-get dist-upgrade -qy \
 && apt-get install -qy wget ca-certificates software-properties-common zip unzip wine64 wine-stable perl libmldbm-perl make flex gcc \
 && /opt/pacman/bin/pacman -Sy --noconfirm python \
 && rm -rf /var/lib/apt/lists/*
