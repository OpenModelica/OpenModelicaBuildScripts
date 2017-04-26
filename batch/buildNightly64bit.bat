REM @echo off 
REM @echo off & setlocal enableextensions
REM Task to automatically build the Windows nigthly-build for OpenModelica
REM Adrian.Pop@liu.se
REM 2012-10-08
REM last change: 2015-05-08

if not exist "c:\OMDev\" (
  echo Checkout c:\OMDev\
  cd c:\
  svn co https://openmodelica.org/svn/OpenModelicaExternal/trunk/tools/windows/OMDev OMDev
  set OMDEV=c:\OMDev
)

if not exist "c:\dev\" (
  echo Creating c:\dev
  md c:\dev\
)

if not exist "c:\dev\TLMPlugin\" (
  echo Checkout c:\dev\TLMPlugin
  cd c:\dev\
  git clone https://github.com/OpenModelica/OMTLMSimulator TLMPlugin
)

if not exist "c:\dev\OpenModelica_releases" (
 echo Creating c:\dev\OpenModelica_releases
 md c:\dev\OpenModelica_releases
)
  
if not exist "c:\dev\OpenModelica64bit\" (
  echo Checkout c:\dev\OpenModelica64bit
  cd c:\dev\
  git clone --recursive https://github.com/OpenModelica/OpenModelica.git OpenModelica64bit
  cd OpenModelica64bit
)

if not exist "c:\dev\OpenModelica64bit\OpenModelicaSetup\" (
  echo Checkout c:\dev\OpenModelica64bit\OpenModelicaSetup
  cd c:\dev\OpenModelica64bit\
  svn co https://openmodelica.org/svn/OpenModelica/installers/windows/OpenModelicaSetup OpenModelicaSetup
)

REM update the build script first!
cd c:\dev\OpenModelica64bit\OpenModelicaSetup
svn up . --accept theirs-full

REM update OMDev
cd C:\OMDev
svn up . --accept theirs-full

REM run the Msys script to build the release
cd c:\dev\OpenModelica_releases\
set MSYSTEM=MINGW64
%OMDEV%\tools\msys\usr\bin\sh --login -i -c "time /c/dev/OpenModelica64bit/OpenModelicaSetup/BuildWindowsRelease.sh adrpo -j3 64bit %1%"
