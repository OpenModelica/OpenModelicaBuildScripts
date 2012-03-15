# Adeel Asghar [adeel.asghar@liu.se]
# 2011-jul-29 21:01:29

Name OpenModelica-1.8.1
BrandingText "$(^Name)"

# General Symbol Definitions
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION 1.8.1
!define COMPANY "Open Source Modelica Consortium (OSMC) and Linköping University (LiU)."
!define URL "http://www.openmodelica.org/"

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

; HKLM (all users) vs HKCU (current user) defines
!define ENV_HKLM 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define ENV_HKCU 'HKCU "Environment"'

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MULTIUSER_PAGE_INSTALLMODE
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
VIProductVersion 1.8.1.0
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
    File "..\..\build\bin\omc.exe"
	  File "..\..\build\bin\fmigenerator.exe"
    File "..\..\build\bin\BreakProcess.exe"
    File "..\..\build\bin\omniORB416_vc10_rt.dll"
    File "..\..\build\bin\omnithread34_vc10_rt.dll"
    File /r /x "*.svn" /x "qsvgicon4.dll" "$%OMDEV%\tools\OMTools\dll\*"
    File /r /x "*.svn" "$%OMDEV%\tools\OMTools\bin\*"
    File "..\..\OSMC-License.txt"
    File "bin\ptplot copyright.txt"
    File "bin\ptplot.jar"
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
    # Create include\omc directory and copy files in it
    SetOutPath "$INSTDIR\include\omc"
    File /r /x "*.svn" "..\..\build\include\omc\*"
    # Create lib directory and copy files in it
    SetOutPath "$INSTDIR\lib"
    File /r /x "*.svn" "..\..\build\lib\*"
    File /r /x "*.svn" "$%OMDEV%\tools\OMTools\lib\*"
    # Create MinGW directory and copy files in it
    SetOutPath "$INSTDIR\MinGW"
    File /r /x "*.svn" "..\..\build\MinGW\*"
    # Create share directory and copy files in it
    SetOutPath "$INSTDIR\share\doc\omc"
    File "..\..\build\share\doc\omc\antlr_license.txt"
    File "..\..\build\share\doc\omc\CMakeLists.txt"
    File "..\..\build\share\doc\omc\ModelicaTutorialFritzson.pdf"
    File "..\..\build\share\doc\omc\OMC_API-HowTo.pdf"
    File "..\..\build\share\doc\omc\omc_helptext.txt"
    File "..\..\doc\OpenModelica Project Online.url"
    File "..\..\build\share\doc\omc\OpenModelicaMetaProgramming.pdf"
    File "..\..\build\share\doc\omc\OpenModelicaSystem.pdf"
    File "..\..\build\share\doc\omc\OpenModelicaTemplateProgramming.pdf"
    File "..\..\build\share\doc\omc\OpenModelicaUsersGuide.pdf"
    File "..\..\build\share\doc\omc\ptplot_license.txt"
    # Create share\doc\omc\interactive-simulation directory and copy files in it
    SetOutPath "$INSTDIR\share\doc\omc\interactive-simulation"
    File "..\..\SimulationRuntime\interactive\README.txt"
    File "..\..\SimulationRuntime\interactive\SampleClient\SimulationApplicationExample_TwoTanks.zip"
    # Create share\doc\omc\testmodels directory and copy files in it
    SetOutPath "$INSTDIR\share\doc\omc\testmodels"
    File /r /x "*.svn" "..\..\Examples\*"
    File "..\..\testsuite.zip"
    # Create share\doc\omedit directory and copy files in it
    SetOutPath "$INSTDIR\share\doc\omedit"
    File "..\..\doc\OMEdit\OMEdit-UserManual.pdf"
    # Create share\doc\omoptim directory and copy files in it
    SetOutPath "$INSTDIR\share\doc\omoptim"
    File "..\..\doc\OMOptim\OMOptimUsersGuide.pdf"
    # Create share\omc\java directory and copy files in it
    SetOutPath "$INSTDIR\share\omc\java"
    File "..\..\build\share\omc\java\antlr-3.1.3.jar"
    File "..\..\build\share\omc\java\ptplot.jar"
    File "..\..\build\share\omc\java\modelica_java.jar"
    # Create share\omc\scripts directory and copy files in it
    SetOutPath "$INSTDIR\share\omc\scripts"
    File /r /x "*.svn" "..\..\build\share\omc\scripts\*"
    # Create share\omnotebook directory and copy files in it
    SetOutPath "$INSTDIR\share\omnotebook"
    File "..\..\OMNotebook\OMNotebookGUI\commands.xml"
    File "..\..\OMNotebook\OMNotebookGUI\modelicacolors.xml"
    File "..\..\OMNotebook\OMNotebookGUI\OMNotebookHelp.onb"
    File "..\..\OMNotebook\OMNotebookGUI\stylesheet.xml"
    # Create share\omnotebook\drcontrol directory and copy files in it
    SetOutPath "$INSTDIR\share\omnotebook\drcontrol"
    File /r /x "*.svn" "..\..\OMNotebook\DrControl\*"
    # Create share\omnotebook\drmodelica directory and copy files in it
    SetOutPath "$INSTDIR\share\omnotebook\drmodelica"
    File /r /x "*.svn" "..\..\OMNotebook\DrModelica\*"
    # Create share\omshell directory and copy files in it
    SetOutPath "$INSTDIR\share\omshell"
    File "..\..\OMNotebook\OMNotebookGUI\commands.xml"
    File "..\..\OMNotebook\OMNotebookGUI\modelicacolors.xml"
    File "..\..\OMNotebook\OMNotebookGUI\stylesheet.xml"
    # set the rights for all users
    AccessControl::GrantOnFile "$INSTDIR" "(BU)" "FullAccess"
    # create environment variables
    StrCmp $MultiUser.InstallMode "AllUsers" 0 +6
        WriteRegExpandStr ${ENV_HKLM} OPENMODELICAHOME "$INSTDIR\"
        WriteRegExpandStr ${ENV_HKLM} OPENMODELICALIBRARY "$INSTDIR\lib\omlibrary"
        WriteRegExpandStr ${ENV_HKLM} DRMODELICAHOME "$INSTDIR\share/omnotebook/drmodelica"
        WriteRegExpandStr ${ENV_HKLM} PTII "$INSTDIR\bin/ptplot.jar"
        Goto +5
        WriteRegExpandStr ${ENV_HKCU} OPENMODELICAHOME "$INSTDIR\"
        WriteRegExpandStr ${ENV_HKCU} OPENMODELICALIBRARY "$INSTDIR\lib\omlibrary"
        WriteRegExpandStr ${ENV_HKCU} DRMODELICAHOME "$INSTDIR\share/omnotebook/drmodelica"
        WriteRegExpandStr ${ENV_HKCU} PTII "$INSTDIR\bin/ptplot.jar"
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
    "" "$INSTDIR\icons\OMNotebook.ico"
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
    CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica Connection Editor - User Manual.pdf.lnk" "$INSTDIR\share\doc\omedit\OMEdit-UserManual.pdf" \
    "" "$INSTDIR\icons\PDF.ico"
    CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Documentation\OpenModelica Optimization Editor - Users Guide.pdf.lnk" "$INSTDIR\share\doc\omoptim\OMOptim-UsersGuide.pdf" \
    "" "$INSTDIR\icons\PDF.ico"
    !insertmacro MUI_STARTMENU_WRITE_END
    ${registerExtension} "$INSTDIR\bin\OMEdit.exe" ".mo" "OpenModelica Model" "$INSTDIR\icons\omedit.ico" "OpenModelica Connection Editor"
    ${registerExtension} "$INSTDIR\bin\OMNotebook.exe" ".onb" "OpenModelica Notebook" "$INSTDIR\icons\OMNotebook.ico" "OpenModelica Notebook"
    # make sure windows knows about the change
    !insertmacro UPDATEFILEASSOC
    WriteRegStr HKLM "SOFTWARE\OpenModelica" InstallMode $MultiUser.InstallMode
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name)"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\Uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\Uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
SectionEnd

# Uninstaller sections
Section "Uninstall"
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
    Delete /REBOOTOK $INSTDIR\Uninstall.exe
    !insertmacro MUI_STARTMENU_GETFOLDER Application $R1
    ReadRegStr $R0 HKLM "SOFTWARE\OpenModelica" InstallMode
    StrCmp $R0 "AllUsers" 0 +7
        DeleteRegValue ${ENV_HKLM} OPENMODELICAHOME
        DeleteRegValue ${ENV_HKLM} OPENMODELICALIBRARY
        DeleteRegValue ${ENV_HKLM} DRMODELICAHOME
        DeleteRegValue ${ENV_HKLM} PTII
        SetShellVarContext all
        Goto +6
        DeleteRegValue ${ENV_HKCU} OPENMODELICAHOME
        DeleteRegValue ${ENV_HKCU} OPENMODELICALIBRARY
        DeleteRegValue ${ENV_HKCU} DRMODELICAHOME
        DeleteRegValue ${ENV_HKCU} PTII
        SetShellVarContext current
    # make sure windows knows about the change i.e we created the environment variables.
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
    # delete the shortcuts and the startment folder
    Delete /REBOOTOK "$SMPROGRAMS\$R1\OpenModelica Connection Editor.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\OpenModelica Notebook.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\OpenModelica Optimization Editor.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\OpenModelica Shell.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\OpenModelica Website.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Uninstall OpenModelica.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Documentation\OpenModelica - API - HowTo.pdf.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Documentation\OpenModelica - MetaProgramming Guide.pdf.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Documentation\OpenModelica - Modelica Tutorial by Peter Fritzson.pdf.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Documentation\OpenModelica - System Guide.pdf.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Documentation\OpenModelica - Users Guide.pdf.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Documentation\OpenModelica Connection Editor - User Manual.pdf.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$R1\Documentation\OpenModelica Optimization Editor - Users Guide.pdf.lnk"
    RMDir /REBOOTOK "$SMPROGRAMS\$R1\Documentation"
    RMDir /REBOOTOK "$SMPROGRAMS\$R1"
    DeleteRegKey HKLM "SOFTWARE\OpenModelica"
    ${unregisterExtension} ".mo" "OpenModelica Model"
    ${unregisterExtension} ".onb" "OpenModelica Notebook"
    # make sure windows knows about the change
    !insertmacro UPDATEFILEASSOC
    DeleteRegValue HKLM "${REGKEY}" StartMenuGroup
    DeleteRegValue HKLM "${REGKEY}" Path
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    RmDir /r /REBOOTOK $INSTDIR
SectionEnd

# Installer functions
Function .onInit
    ; Check to see if already installed
    ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" "UninstallString"
    IfFileExists $R0 +1 NotInstalled
        MessageBox MB_OK "$(^Name) is already installed on your machine. Please uninstall it before running the installation again."
        Quit
NotInstalled:
    InitPluginsDir
    !insertmacro MULTIUSER_INIT
    StrCpy $INSTDIR "C:\OpenModelica1.8.1"
FunctionEnd

# Uninstaller functions
Function un.onInit
    !insertmacro MULTIUSER_UNINIT
FunctionEnd