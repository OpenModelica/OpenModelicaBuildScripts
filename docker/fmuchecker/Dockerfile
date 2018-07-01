FROM ubuntu:bionic

RUN pwd && dpkg --add-architecture i386 && export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get upgrade -qy && apt-get dist-upgrade -qy \
 && apt-get install -qy wget ca-certificates software-properties-common unzip wine64 wine-stable \
 && wget https://svn.fmi-standard.org/fmi/branches/public/Test_FMUs/Compliance-Checker/FMUChecker-2.0.4-win64.zip \
 && unzip -j FMUChecker-2.0.4-win64.zip FMUChecker-2.0.4-win64/fmuCheck.win64.exe \
 && wget https://svn.fmi-standard.org/fmi/branches/public/Test_FMUs/Compliance-Checker/FMUChecker-2.0.4-win32.zip \
 && unzip -j FMUChecker-2.0.4-win32.zip FMUChecker-2.0.4-win32/fmuCheck.win32.exe \
 && wget https://svn.fmi-standard.org/fmi/branches/public/Test_FMUs/Compliance-Checker/FMUChecker-2.0.4-linux64.zip \
 && unzip -j FMUChecker-2.0.4-linux64.zip FMUChecker-2.0.4-linux64/fmuCheck.linux64 \
 && wget https://svn.fmi-standard.org/fmi/branches/public/Test_FMUs/Compliance-Checker/FMUChecker-2.0.4-linux32.zip \
 && unzip -j FMUChecker-2.0.4-linux32.zip FMUChecker-2.0.4-linux32/fmuCheck.linux32 \
 && chmod +x fmuCheck* \
 && mv fmuCheck.win64.exe fmuCheck.win32.exe fmuCheck.linux64 fmuCheck.linux32 /usr/local/bin/ \
 && wine /usr/local/bin/fmuCheck.win32.exe -v \
 && wine64 /usr/local/bin/fmuCheck.win64.exe -v \
 && rm -rf *.zip /var/lib/apt/lists/* ~/.wine*
