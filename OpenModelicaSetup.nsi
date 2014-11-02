# Adeel Asghar [adeel.asghar@liu.se]
# 2011-jul-29 21:01:29
# Adrian.Pop@liu.se 2013-01-30 (beta2 -> beta4)
# Adrian.Pop@liu.se 2013-10-09 (beta4 -> release)
# Adrian.Pop@liu.se 2013-10-16 (1.9.0 -> 1.9.1)
# Adrian.Pop@liu.se 2014-02-02 (1.9.1 -> 1.9.1Beta1)
# Adrian.Pop@liu.se 2014-03-08 (1.9.1 -> 1.9.1Beta2)
# Adrian.Pop@liu.se 2014-10-06 (1.9.1 -> 1.9.1Beta3)
# Adrian.Pop@liu.se 2014-10-07 (1.9.1 -> 1.9.1Beta4)
# Adrian.Pop@liu.se 2014-10-25 (1.9.1 -> 1.9.1)
# Adrian.Pop@liu.se 2014-10-25 (1.9.1 -> 1.9.2Nightly)

Name OpenModelica1.9.2Nightly

# General Symbol Definitions
!define REGKEY "SOFTWARE\OpenModelica"
!define VERSION 1.9.2Nightly
!define COMPANY "Open Source Modelica Consortium (OSMC) and Linköping University (LiU)."
!define URL "http://www.openmodelica.org/"
BrandingText "Copyright $2 OpenModelica"  ; The $2 variable is filled in the Function .onInit after calling GetLocalTime function.

# MultiUser Symbol Definitions
!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_DEFAULT_CURRENTUSER
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${REGKEY}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME MultiUserInstallMode
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "${REGKEY}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUE "Path"

# MUI Symbol Definitions
!define MUI_ICON "icons\OpenModelica.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_WELCOMEFINISHPAGE_BITMAP "images\openmodelica.bmp"
!define MUI_WELCOMEPAGE_TITLE_3LINES
!define MUI_WELCOMEPAGE_TEXT "The installer will guide you through the steps required to install $(^Name) on your computer.$\r$\n$\r$\n$\r$\nThe packge includes OpenModelica, a Modelica modeling, compilation and simulation environment based on free software."
!define MUI_DIRECTORYPAGE_TEXT_TOP "Please do not install OpenModelica in a directory that contains spaces for example $\"C:\Program Files\OpenModelica$\". Keep if possible the default directory suggested by the installer."
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY ${REGKEY}
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "OpenModelica"
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_UNICON "icons\Uninstall.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "images\openmodelica.bmp"

; !defines for use with SHChangeNotify
!ifdef SHCNE_ASSOCCHANGED
!undef SHCNE_ASSOCCHANGED
!endif
!define SHCNE_ASSOCCHANGED 0x08000000
!ifdef SHCNF_FLUSH
!undef SHCNF_FLUSH
!endif
!define SHCNF_FLUSH        0x1000
 
!macro UPDATEFILEASSOC
; Using the system.dll plugin to call the SHChangeNotify Win32 API function so we
; can update the shell.
  System::Call "shell32::SHChangeNotify(i,i,i,i) (${SHCNE_ASSOCCHANGED}, ${SHCNF_FLUSH}, 0, 0)"
!macroend

# Included files
!include MultiUser.nsh
!include Sections.nsh
!include MUI2.nsh
# Include for some of the windows messages defines
!include "winmessages.nsh"
!include "FileAssociation.nsh"
!include "CustomFunctions.nsh"

; HKLM (all users) vs HKCU (current user) defines
!define ENV_HKLM 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define ENV_HKCU 'HKCU "Environment"'

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE "DirectoryLeave"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile "OpenModelica.exe"
CRCCheck on
XPStyle on
ShowInstDetails hide
VIProductVersion 1.9.1.0
VIAddVersionKey ProductName "OpenModelica"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails hide

# Installer sections
Section -Main SEC0000
  SetOverwrite on
  # Create bin directory and copy files in it
  SetOutPath "$INSTDIR\bin"
  File "..\..\build\bin\*"
  File /r /x "*.svn" /x "qsvgicon4.dll" "$%OMDEV%\tools\OMTools\dll\*"
  File "$%OMDEV%\lib\omniORB-4.1.6-mingw\bin\x86_win32\omniORB416_rt.dll"
  File "$%OMDEV%\lib\omniORB-4.1.6-mingw\bin\x86_win32\omniDynamic416_rt.dll"
  File "$%OMDEV%\lib\omniORB-4.1.6-mingw\bin\x86_win32\omnithread34_rt.dll"
  File "..\..\OSMC-License.txt"
  # Copy the openssl binaries
  File "bin\libeay32.dll"
  File "bin\libssl32.dll"
  File "bin\ssleay32.dll"
  # Create bin\iconengines directory and copy files in it
  SetOutPath "$INSTDIR\bin\iconengines"
  File "$%OMDEV%\tools\OMTools\dll\qsvgicon4.dll"
  # Create icons directory and copy files in it
  SetOutPath "$INSTDIR\icons"
  File /r /x "*.svn" "icons\*"
  File "..\..\OMEdit\OMEditGUI\Resources\icons\omedit.ico"
  File "..\..\OMOptim\GUI\Resources\omoptim.ico"
  File "..\..\OMPlot\OMPlotGUI\Resources\icons\omplot.ico"
  File "..\..\OMShell\OMShellGUI\Resources\omshell.ico"
  File "..\..\OMNotebook\OMNotebookGUI\Resources\OMNotebook_icon.ico"
  File "..\..\OMVisualize\OMVisualizeGUI\Resources\icons\omvisualize.ico"
  # Create include\omc directory and copy files in it
  SetOutPath "$INSTDIR\include\omc"
  File /r /x "*.svn" "..\..\build\include\omc\*"
  # Create lib directory and copy files in it
  SetOutPath "$INSTDIR\lib"
  File /r /x "*.svn" "..\..\build\lib\*"
  # Create MinGW directory and copy files in it
  SetOutPath "$INSTDIR\MinGW"
  File /r /x "*.svn" "$%OMDEV%\tools\MinGW\*"
  # Create share directory and copy files in it
  SetOutPath "$INSTDIR\share"
  File /r /x "*.svn" /x "*.git" "..\..\build\share\*"
  # Copy the OpenModelica webpage url shortcut
  SetOutPath "$INSTDIR\share\doc\omc"
  File "..\..\doc\OpenModelica Project Online.url"
  # set the rights for all users
  AccessControl::GrantOnFile "$INSTDIR" "(BU)" "FullAccess"
  # create environment variables
  StrCmp $MultiUser.InstallMode "AllUsers" 0 +4
    WriteRegExpandStr ${ENV_HKLM} OPENMODELICAHOME "$INSTDIR\"
    WriteRegExpandStr ${ENV_HKLM} OPENMODELICALIBRARY "$INSTDIR\lib\omlibrary"
    Goto +3
    WriteRegExpandStr ${ENV_HKCU} OPENMODELICAHOME "$INSTDIR\"
    WriteRegExpandStr ${ENV_HKCU} OPENMODELICALIBRARY "$INSTDIR\lib\omlibrary"
  # make sure windows knows about the change i.e we created the environment variables.
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  WriteRegStr HKLM "${REGKEY}\Components" Main 1
SectionEnd

Section -post SEC0001
  WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
  WriteUninstaller $INSTDIR\Uninstall.exe
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  # set the output path to temp directory which is used as a start in option for shortcuts.
  SetOutPath "$TEMP"
  # create shortcuts
  CreateDirectory "$SMPROGRAMS\$StartMenuGroup"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Connection Editor.lnk" "$INSTDIR\bin\OMEdit.exe" \
  "" "$INSTDIR\icons\omedit.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Notebook.lnk" "$INSTDIR\bin\OMNotebook.exe" \
  "" "$INSTDIR\icons\OMNotebook_icon.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Optimization Editor.lnk" "$INSTDIR\bin\OMOptim.exe" \
  "" "$INSTDIR\icons\omoptim.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Shell.lnk" "$INSTDIR\bin\OMShell.exe" \
  "" "$INSTDIR\icons\omshell.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\OpenModelica Website.lnk" "$INSTDIR\share\doc\omc\OpenModelica Project Online.url" \
  "" "$INSTDIR\icons\IExplorer.ico"
  SetOutPath "$INSTDIR\"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Uninstall OpenModelica.lnk" "$INSTDIR\Uninstall.exe" \
  "" "$INSTDIR\icons\Uninstall.ico"
  CreateDirectory "$SMPROGRAMS\$StartMenuGroup\Documentation"
  SetOutPath ""
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - API - HowTo.pdf.lnk" "$INSTDIR\share\doc\omc\OMC_API-HowTo.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - MetaProgramming Guide.pdf.lnk" "$INSTDIR\share\doc\omc\OpenModelicaMetaProgramming.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Modelica Tutorial by Peter Fritzson.pdf.lnk" "$INSTDIR\share\doc\omc\ModelicaTutorialFritzson.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - System Guide.pdf.lnk" "$INSTDIR\share\doc\omc\OpenModelicaSystem.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica - Users Guide.pdf.lnk" "$INSTDIR\share\doc\omc\OpenModelicaUsersGuide.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica Optimization Editor - Users Guide.pdf.lnk" "$INSTDIR\share\doc\omoptim\OMOptim-UsersGuide.pdf" \
  "" "$INSTDIR\icons\PDF.ico"
  CreateDirectory "$SMPROGRAMS\$StartMenuGroup\PySimulator"
  SetOutPath ""
  CreateShortCut "$SMPROGRAMS\$StartMenuGroup\PySimulator\README.lnk" "$INSTDIR\share\omc\scripts\PythonInterface\PySimulator\README.md"
  !insertmacro MUI_STARTMENU_WRITE_END
  ${registerExtension} "$INSTDIR\bin\OMEdit.exe" ".mo" "OpenModelica Connection Editor"
  ${registerExtension} "$INSTDIR\bin\OMNotebook.exe" ".onb" "OpenModelica Notebook"
  # make sure windows knows about the change
  !insertmacro UPDATEFILEASSOC
  WriteRegStr HKLM "SOFTWARE\OpenModelica" InstallMode $MultiUser.InstallMode
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" DisplayName "$(^Name)"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" DisplayVersion "${VERSION}"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" Publisher "${COMPANY}"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" URLInfoAbout "${URL}"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" DisplayIcon $INSTDIR\Uninstall.exe
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" UninstallString $INSTDIR\Uninstall.exe
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" NoModify 1
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" NoRepair 1
SectionEnd

# Uninstaller sections
Section "Uninstall"
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica"
  Delete $INSTDIR\Uninstall.exe
  !insertmacro MUI_STARTMENU_GETFOLDER Application $R1
  ReadRegStr $R0 HKLM "SOFTWARE\OpenModelica" InstallMode
  StrCmp $R0 "AllUsers" 0 +5
    DeleteRegValue ${ENV_HKLM} OPENMODELICAHOME
    DeleteRegValue ${ENV_HKLM} OPENMODELICALIBRARY
    SetShellVarContext all
    Goto +4
    DeleteRegValue ${ENV_HKCU} OPENMODELICAHOME
    DeleteRegValue ${ENV_HKCU} OPENMODELICALIBRARY
    SetShellVarContext current
  # make sure windows knows about the change i.e we created the environment variables.
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
  # delete the shortcuts and the startment folder
  Delete "$SMPROGRAMS\$R1\OpenModelica Connection Editor.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Notebook.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Optimization Editor.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Shell.lnk"
  Delete "$SMPROGRAMS\$R1\OpenModelica Website.lnk"
  Delete "$SMPROGRAMS\$R1\Uninstall OpenModelica.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - API - HowTo.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - MetaProgramming Guide.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - Modelica Tutorial by Peter Fritzson.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - System Guide.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica - Users Guide.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica Connection Editor - User Manual.pdf.lnk"
  Delete "$SMPROGRAMS\$R1\Documentation\OpenModelica Optimization Editor - Users Guide.pdf.lnk"
  RMDir "$SMPROGRAMS\$R1\Documentation"
  Delete "$SMPROGRAMS\$R1\PySimulator\README.lnk"
  RMDir "$SMPROGRAMS\$R1\PySimulator"
  RMDir "$SMPROGRAMS\$R1"
  DeleteRegKey HKLM "SOFTWARE\OpenModelica"
  ${unregisterExtension} ".mo" "OpenModelica Connection Editor"
  ${unregisterExtension} ".onb" "OpenModelica Notebook"
  # make sure windows knows about the change
  !insertmacro UPDATEFILEASSOC
  DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
  DeleteRegValue HKLM "${REGKEY}" Path
  DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
  DeleteRegKey /IfEmpty HKLM "${REGKEY}"
  RmDir /r $INSTDIR
SectionEnd

# Installer functions
Function .onInit
  # Read the current local time of the system and then extract the year from it. This value is then used in Branding Text.
  Call GetLocalTime
  Pop $0  ; Day
  Pop $1  ; Month
  Pop $2  ; Year
  ; Check to see if already installed
  ReadRegStr $R2 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica" "UninstallString"
  IfFileExists $R2 +1 NotInstalled
    IfSilent uninst ; if silent install mode is enabled then also uninstall silently.
      MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
      "OpenModelica is already installed on your machine. $\n$\nClick `OK` to uninstall and install again. \
      $\nClick `Cancel` to quit the setup." \
      IDOK uninst
      Quit
uninst:
  Push "\Uninstall.exe" ; divider str
  Push $R2 ; input string
  Call GetLastPart
  Pop $R1 ; last part
  Pop $R0 ; first part
  IfSilent +1 +3 ; if silent install mode is enabled then also uninstall silently.
    ExecWait "$R2 /S _?=$R0" ; _? switch blocks until the uninstall is done.
    Goto +2
  ExecWait "$R2 _?=$R0" ; _? switch blocks until the uninstall is done.
  RmDir /r $INSTDIR ; since we are running the Uninstall.exe so it was not deleted in the uninstallation process. Makesure we remove the $INSTDIR.
NotInstalled:
  InitPluginsDir
  !insertmacro MULTIUSER_INIT
  ${GetDrives} "HDD" "HardDiskDrives"
  # after calling GetDrives $R0 will contain the first available drive letter e.g "C:\"
  StrCpy $INSTDIR $R0
  StrCpy $INSTDIR "$R0$(^Name)"
  IfSilent +1 +3 ; in silent install mode set multiuser to AllUsers.
    StrCpy $MultiUser.InstallMode "AllUsers"
    Goto +2
  StrCpy $MultiUser.InstallMode "CurrentUser"
FunctionEnd

# Uninstaller functions
Function un.onInit
  # Read the current local time of the system and then extract the year from it. This value is then used in Branding Text.
  Call un.GetLocalTime
  Pop $0  ; Day
  Pop $1  ; Month
  Pop $2  ; Year
  !insertmacro MULTIUSER_UNINIT
FunctionEnd