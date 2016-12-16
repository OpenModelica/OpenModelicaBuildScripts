#!/bin/sh -x
# script to build the OpenModelica nightly-build
# Adrian Pop [adrian.pop@liu.se]
# 2013-10-03
#
# expects to have these things installed:
#  nsis installer
#  TortoiseSVN command line tools
#  jdk
#  git command line clients (PUT IT LAST IN THE PATH!) http://git-scm.com/downloads
#  OMDev in c:\OMDev
#

# get the ssh password via command line
export SSHUSER=$1
export MAKETHREADS=$2
export PLATFORM=$3 # 32bit or 64bit
export GIT_BRANCH=$4

# set the path to our tools
export PATH=$PATH:/c/Program\ Files/TortoiseSVN/bin/:/c/bin/jdk/bin:/c/bin/nsis/:/c/bin/git/bin

# don't exit on error
set +e
# make sure we use the windows temp directory and not the msys/tmp one!
rm -rf ${TMP}/*
rm -rf ${TEMP}/*
export TMP=$tmp TEMP=$temp
rm -rf ${TMP}/*
rm -rf ${TEMP}/*

# set the OPENMODELICAHOME and OPENMODELICALIBRARY
export OPENMODELICAHOME="c:/dev/OpenModelica${PLATFORM}/build"
export OPENMODELICALIBRARY="c:/dev/OpenModelica${PLATFORM}/build/lib/omlibrary"

# have OMDEV in Msys version
export OMDEV=/c/OMDev/

# update OMDev
cd /c/OMDev/
svn up . --accept theirs-full

# update OpenModelica
cd /c/dev/OpenModelica${PLATFORM}
# delete the build directory
rm -rf build
git reset --hard origin/master && git checkout master && git pull --recurse-submodules && git fetch --tags || exit 1
git submodule update --init --recursive || exit 1
git submodule foreach --recursive  "git fetch --tags && git clean -fdxq -e /git -e /svn" || true
git clean -fdxq -e OpenModelicaSetup || true
# This needs more work, redo!
# git checkout $GIT_BRANCH
# cd OMCompiler
# git checkout $GIT_BRANCH
# cd ..
git submodule status --recursive
# get the revision
cd OMCompiler
export REVISION=`git describe --match "v*.*" --always`
cd ..
# Directory prefix
export OMC_INSTALL_PREFIX="/c/dev/OpenModelica_releases/${REVISION}/"
# make the file prefix
export OMC_INSTALL_FILE_PREFIX="${OMC_INSTALL_PREFIX}OpenModelica-${REVISION}-${PLATFORM}"

# test if exists and exit if it does
if [ -f "${OMC_INSTALL_FILE_PREFIX}.exe" ]; then
	echo "Revision ${OMC_INSTALL_FILE_PREFIX}.exe already exists! Exiting ..."
	exit 0
fi

# create the revision directory
mkdir -p ${OMC_INSTALL_PREFIX}

# update OpenModelicaSetup
cd /c/dev/OpenModelica${PLATFORM}/OpenModelicaSetup
svn up . --accept theirs-full

# build OpenModelica
cd /c/dev/OpenModelica${PLATFORM}
echo "Cleaning OpenModelica"
rm -rf build/
mkdir -p build/
make -f 'Makefile.omdev.mingw' ${MAKETHREADS} gitclean || make -f 'Makefile.omdev.mingw' ${MAKETHREADS} gitclean || true
make -f 'Makefile.omdev.mingw' ${MAKETHREADS} clean
cd /c/dev/OpenModelica${PLATFORM}
echo "Building OpenModelica and OpenModelica libraries"
# make sure we break on error!
set -e
make -f 'Makefile.omdev.mingw' ${MAKETHREADS} omc omc-diff omlibrary-all qtclients
cd /c/dev/OpenModelica${PLATFORM}
echo "Installing Python scripting"
rm -rf OMPython
git clone https://github.com/OpenModelica/OMPython -q -b master /c/dev/OpenModelica${PLATFORM}/OMPython
# build OMPython
make -k -f 'Makefile.omdev.mingw' ${MAKETHREADS} install-python
cd /c/dev/OpenModelica${PLATFORM}
echo "Building MSVC compiled runtime"
make -f 'Makefile.omdev.mingw' ${MAKETHREADS} BuildType=Release VSVERSION=2013 simulationruntimecmsvc
echo "Building MSVC CPP runtime"
make -f 'Makefile.omdev.mingw' ${MAKETHREADS} BuildType=Release VSVERSION=2013 runtimeCPPmsvcinstall
echo "Building CPP runtime"
make -f 'Makefile.omdev.mingw' ${MAKETHREADS} BuildType=Release runtimeCPPinstall

# wget the html & pdf versions of OpenModelica users guide
cd /c/dev/OpenModelica${PLATFORM}/build/share/doc/omc
wget --no-check-certificate https://openmodelica.org/doc/openmodelica-doc-latest.tar.xz
tar -xJf openmodelica-doc-latest.tar.xz --strip-components=2
rm openmodelica-doc-latest.tar.xz
wget --no-check-certificate https://openmodelica.org/doc/OpenModelicaUsersGuide/OpenModelicaUsersGuide-latest.pdf

# get PySimulator
# for now get the master from github since OpenModelica plugin is still not part of tagged release. This should be updated once PySimulator outs a new release.
git clone https://github.com/PySimulator/PySimulator -q -b master /c/dev/OpenModelica${PLATFORM}/build/share/omc/scripts/PythonInterface/PySimulator

# get Figaro
cd /c/dev/OpenModelica${PLATFORM}/build/share
# do not get it from sourceforge as it fails sometimes!
#wget --no-check-certificate -O jEdit4.5_VisualFigaro.zip https://sourceforge.net/p/visualfigaro/code/HEAD/tree/Trunk/Package/4_Packages_livrables/jEdit4.5_VisualFigaro.zip?format=raw
wget --no-check-certificate -O jEdit4.5_VisualFigaro.zip https://build.openmodelica.org/omc/figaro/v1.12/jEdit4.5_VisualFigaro.zip
unzip jEdit4.5_VisualFigaro.zip
rm jEdit4.5_VisualFigaro.zip

# build the installer
cd /c/dev/OpenModelica${PLATFORM}/OpenModelicaSetup
makensis //DPLATFORMVERSION="${PLATFORM::-3}" OpenModelicaSetup.nsi > trace.txt 2>&1
cat trace.txt
# move the installer
mv OpenModelica.exe ${OMC_INSTALL_FILE_PREFIX}.exe

# gather the svn log
cd /c/dev/OpenModelica${PLATFORM}
git log --name-status --graph --submodule > ${OMC_INSTALL_FILE_PREFIX}-ChangeLog.txt

# make the readme
export DATESTR=`date +"%Y-%m-%d_%H-%M"`
echo "Automatic build of OpenModelica by testwin.openmodelica.org at date: ${DATESTR} from revision: ${REVISION}" >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo " " >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo "Read OpenModelica-${REVISION}-ChangeLog.txt for more info on changes." >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo " " >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo "See also (match revision ${REVISION} to build jobs):" >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo "  https://test.openmodelica.org/hudson/" >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo "  http://test.openmodelica.org/~marsj/MSL32/BuildModelRecursive.html" >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo " " >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
cat >> ${OMC_INSTALL_FILE_PREFIX}-README.txt <<DELIMITER
*Instructions to prepare test information if you find a bug:*
 
generate a .mos script file loading all libraries and files your model need call simulate.
// start .mos script
loadModel(Modelica);
loadFile("yourfile.mo");
simulate(YourModel);
// end .mos script

Start this .mos script in a shell with omc and use the debug flags
+d=dumpdaelow,optdaedump,bltdump,dumpindxdae,backenddaeinfo.
Redirect the output stream in file ( > log.txt)

A series of commands to run via cmd.exe
is given below. Note that z: is the drive
where your .mos script is:
c:\> z:
z:\> cd \path\to\script(.mos)\file\
z:\path\to\script(.mos)\file\> \path\to\OpenModelica\bin\omc.exe
+d=dumpdaelow,optdaedump,bltdump,dumpindxdae,backenddaeinfo 
YourScriptFile.mos > log.txt 2>&1

Either send the log.txt file alongwith your bug 
description to OpenModelica@ida.liu.se or file a
bug in our bug tracker:
  https://trac.openmodelica.org/OpenModelica

Happy testing!
DELIMITER
echo " " >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo "Read more about OpenModelica at https://openmodelica.org" >> ${OMC_INSTALL_FILE_PREFIX}-README.txt
echo "Contact us at OpenModelica@ida.liu.se for further issues or questions." >> ${OMC_INSTALL_FILE_PREFIX}-README.txt

# make the testsuite-trace
#cd /c/dev/OpenModelica${PLATFORM}
#echo "Running testsuite trace"
#make -f 'Makefile.omdev.mingw' ${MAKETHREADS} testlogwindows > tmpTime.log 2>&1

echo "Check HUDSON testserver for the testsuite trace here (match revision ${REVISION} to build jobs): " >> ${OMC_INSTALL_FILE_PREFIX}-testsuite-trace.txt
echo "  https://test.openmodelica.org/hudson/" >> ${OMC_INSTALL_FILE_PREFIX}-testsuite-trace.txt
echo "  https://test.openmodelica.org/hudson/job/OM_Win/lastBuild/console" >> ${OMC_INSTALL_FILE_PREFIX}-testsuite-trace.txt
#cat tmpTime.log >> ${OMC_INSTALL_FILE_PREFIX}-testsuite-trace.txt
#rm -f tmpTime.log

ls -lah ${OMC_INSTALL_PREFIX}

cd ${OMC_INSTALL_PREFIX}
# move the last nightly build to the older location
ssh ${SSHUSER}@build.openmodelica.org <<ENDSSH
#commands to run on remote host
cd public_html/omc/builds/windows/nightly-builds/${PLATFORM}/
mv -f OpenModelica* older/ || true
ENDSSH
scp OpenModelica*${PLATFORM}* ${SSHUSER}@build.openmodelica.org:public_html/omc/builds/windows/nightly-builds/${PLATFORM}/
echo "All done!"
