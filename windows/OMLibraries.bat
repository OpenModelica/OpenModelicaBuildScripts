@echo off
REM 1 Libraries directory

cd %1
echo SectionGroup "Open-Source Modelica Libraries" SectionGroup2
setlocal disableDelayedExpansion
:: Load the file path "array"
for /f "tokens=1* delims=:" %%A in ('dir /b^|findstr /n "^"') do (
  set "file.%%A=%%B"
  set "file.count=%%A"
  set "file.extension.%%A=%%~xB"
)

:: Access the values
setlocal enableDelayedExpansion
for /l %%N in (1 1 %file.count%) do (
  set LIBRARY=!file.%%N!
  set VALIDLIBRARY=
  :: check if folder
  if exist !LIBRARY!\NUL set VALIDLIBRARY=1
  :: check if .mo file
  if /i "!file.extension.%%N!" == ".mo" set VALIDLIBRARY=1
  :: Skip the default libraries
  if /i "!file.%%N!" == "Complex 3.2.1.mo" set VALIDLIBRARY=
  if /i "!file.%%N!" == "Modelica 3.2.1" set VALIDLIBRARY=
  if /i "!file.%%N!" == "ModelicaTest 3.2.1" set VALIDLIBRARY=
  if /i "!file.%%N!" == "ModelicaServices 3.2.1" set VALIDLIBRARY=
  if /i "!file.%%N!" == "Complex 3.2.2.mo" set VALIDLIBRARY=
  if /i "!file.%%N!" == "Modelica 3.2.2" set VALIDLIBRARY=
  if /i "!file.%%N!" == "ModelicaTest 3.2.2" set VALIDLIBRARY=
  if /i "!file.%%N!" == "ModelicaReference" set VALIDLIBRARY=
  if /i "!file.%%N!" == "ModelicaServices 3.2.2" set VALIDLIBRARY=
  if /i "!file.%%N!" == "Modelica_DeviceDrivers 1.5.0" set VALIDLIBRARY=
  if /i "!file.%%N!" == "Modelica_Synchronous 0.92.1" set VALIDLIBRARY=
  :: if everything is ok then create a section for the library
  if defined VALIDLIBRARY (
    echo Section "!LIBRARY!"
    echo   SetOutPath "$INSTDIR\lib\omlibrary"
    echo   File /r /x "*.svn" /x "*.git" "..\build\lib\omlibrary\!LIBRARY!"
    echo SectionEnd
  )
)
echo SectionGroupEnd
echo LangString DESC_SectionGroup2 ${LANG_ENGLISH} "Installs the Open-Source Modelica Libraries."
:EOF
