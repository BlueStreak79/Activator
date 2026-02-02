@set masver=3.10
@echo off



::============================================================================
::
::   Homepage: m{}assgrave{dot}dev
::
::============================================================================



::  To activate, run the script with "/HWID" parameter or change 0 to 1 in below line
set _act=1

::  To disable changing edition if current edition doesn't support HWID activation, change the value to 1 from 0 or run the script with "/HWID-NoEditionChange" parameter
set _NoEditionChange=0

::  To run the script in debug mode, change 0 to "/HWID" in below line
set "_debug=0"

::  If value is changed in above lines or parameter is used then script will run in unattended mode



::========================================================================================================================================

::  Set environment variables, it helps if they are misconfigured in the system

setlocal EnableExtensions
setlocal DisableDelayedExpansion

set "PathExt=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC"

set "SysPath=%SystemRoot%\System32"
set "Path=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "SysPath=%SystemRoot%\Sysnative"
set "Path=%SystemRoot%\Sysnative;%SystemRoot%;%SystemRoot%\Sysnative\Wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%Path%"
)

set "ComSpec=%SysPath%\cmd.exe"
set "PSModulePath=%ProgramFiles%\WindowsPowerShell\Modules;%SysPath%\WindowsPowerShell\v1.0\Modules"

set re1=
set re2=
set "_cmdf=%~f0"
for %%# in (%*) do (
if /i "%%#"=="re1" set re1=1
if /i "%%#"=="re2" set re2=1
if /i "%%#"=="-qedit" (set re1=1&set re2=1)
)

:: Re-launch the script with x64 process if it was initiated by x86 process on x64 bit Windows
:: or with ARM64 process if it was initiated by x86/ARM32 process on ARM64 Windows

if exist %SystemRoot%\Sysnative\cmd.exe if not defined re1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* re1"
exit /b
)

:: Re-launch the script with ARM32 process if it was initiated by x64 process on ARM64 Windows

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined re2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* re2"
exit /b
)

::========================================================================================================================================

::  Debug code

if "%_debug%" EQU "0" (
set "nul1=1>nul"
set "nul2=2>nul"
set "nul6=2^>nul"
set "nul=>nul 2>&1"
goto :_debug
)

set "nul1="
set "nul2="
set "nul6="
set "nul="

@echo on
@prompt $G
@call :_debug "%_debug%" >"%~dp0_tmp.log" 2>&1
@cmd /u /c type "%~dp0_tmp.log">"%~dp0_Debug.log"
@del "%~dp0_tmp.log"
@echo off
@exit /b

:_debug

::========================================================================================================================================

set "blank="
set "mas=ht%blank%tps%blank%://m%blank%ass%blank%grave.dev/"
set "github=ht%blank%tps%blank%://github.com/m%blank%assgra%blank%vel/Micro%blank%soft-Acti%blank%vation-Scripts"
set "selfgit=ht%blank%tps%blank%://git.acti%blank%vated.win/Micr%blank%osoft-Act%blank%ivation-Scripts"

::  Check if Null service is working, it's important for the batch script

sc query Null | find /i "RUNNING"
if %errorlevel% NEQ 0 (
echo:
echo Null service is not running, script may crash...
echo:
echo:
echo Check this webpage for help - %mas%fix_service
echo:
echo:
ping 127.0.0.1 -n 20
)
cls

::  Check LF line ending

pushd "%~dp0"
>nul findstr /v "$" "%~nx0" && (
echo:
echo Error - Script either has LF line ending issue or an empty line at the end of the script is missing.
echo:
echo:
echo Check this webpage for help - %mas%troubleshoot
echo:
echo:
ping 127.0.0.1 -n 20 >nul
popd
exit /b
)
popd

::========================================================================================================================================

cls
color 07
title  HWID Activation %masver%

set _args=
set _elev=
set _unattended=0

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args set _args=%_args:re1=%
if defined _args set _args=%_args:re2=%
if defined _args (
for %%A in (%_args%) do (
if /i "%%A"=="/HWID"                  set _act=1
if /i "%%A"=="/HWID-NoEditionChange"  set _NoEditionChange=1
if /i "%%A"=="-el"                    set _elev=1
)
)

for %%A in (%_act% %_NoEditionChange%) do (if "%%A"=="1" set _unattended=1)

::========================================================================================================================================

call :dk_setvar

if %winbuild% EQU 1 (
%eline%
echo Failed to detect Windows build number.
echo:
setlocal EnableDelayedExpansion
set fixes=%fixes% %mas%troubleshoot
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%troubleshoot"
goto dk_done
)

if exist "%Systemdrive%\Users\WDAGUtilityAccount" (
sc query gcs | find /i "RUNNING" %nul% && (
%eline%
echo Windows Sandbox detected; activation is not supported.
echo The script cannot run due to missing licensing components. Aborting...
echo:
goto dk_done
)
)

if %winbuild% LSS 10240 (
%eline%
echo Unsupported OS version detected [%winbuild%].
echo HWID Activation is only supported on Windows 10/11.
call :dk_color %Blue% "Use TSforge activation option from the main menu."
goto dk_done
)

if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-Server*Edition~*.mum" (
%eline%
echo HWID Activation is not supported on Windows Server.
call :dk_color %Blue% "Use TSforge activation option from the main menu."
goto dk_done
)

::========================================================================================================================================

::  Fix special character limitations in path name

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set _PSarg="""%~f0""" -el %_args%
set _PSarg=%_PSarg:'=''%

set "_ttemp=%userprofile%\AppData\Local\Temp"

setlocal EnableDelayedExpansion

::========================================================================================================================================

echo "!_batf!" | find /i "!_ttemp!" %nul1% && (
if /i not "!_work!"=="!_ttemp!" (
%eline%
echo The script was launched from the temp folder.
echo You are most likely running the script directly from the archive file.
echo:
echo Extract the archive file and launch the script from the extracted folder.
goto dk_done
)
)

::========================================================================================================================================

::  Elevate script as admin and pass arguments and preventing loop

%nul1% fltmc || (
if not defined _elev %psc% "start cmd.exe -arg '/c \"!_PSarg!\"' -verb runas" && exit /b
%eline%
echo This script needs admin rights.
echo Right click on this script and select 'Run as administrator'.
goto dk_done
)

::========================================================================================================================================

::  Check PowerShell

::pstst $ExecutionContext.SessionState.LanguageMode :pstst

for /f "delims=" %%a in ('%psc% "if ($PSVersionTable.PSEdition -ne 'Core') {$f=[System.IO.File]::ReadAllText('!_batp!') -split ':pstst';. ([scriptblock]::Create($f[1]))}" %nul6%') do (set tstresult=%%a)

if /i not "%tstresult%"=="FullLanguage" (
%eline%
for /f "delims=" %%a in ('%psc% "$ExecutionContext.SessionState.LanguageMode" %nul6%') do (set tstresult2=%%a)
echo Test 1 - %tstresult%
echo Test 2 - !tstresult2!
echo:

REM check LanguageMode

echo: !tstresult2! | findstr /i "ConstrainedLanguage RestrictedLanguage NoLanguage" %nul1% && (
echo FullLanguage mode not found in PowerShell. Aborting...
echo If you have applied restrictions on Powershell then undo those changes.
set fixes=%fixes% %mas%fix_powershell
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%fix_powershell"
goto dk_done
)

REM check Powershell core version

cmd /c "%psc% "$PSVersionTable.PSEdition"" | find /i "Core" %nul1% && (
echo Windows Powershell is needed for MAS but it seems to be replaced with Powershell core. Aborting...
set fixes=%fixes% %mas%in-place_repair_upgrade
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%in-place_repair_upgrade"
goto dk_done
)

REM check for Mal-ware that may cause issues with Powershell

for /r "%ProgramFiles%\" %%f in (secureboot.exe) do if exist "%%f" (
echo "%%f"
echo Mal%blank%ware found, PowerShell is not working properly.
set fixes=%fixes% %mas%remove_mal%w%ware
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%remove_mal%w%ware"
goto dk_done
)

REM check if .NET is working properly

if /i "!tstresult2!"=="FullLanguage" (
cmd /c "%psc% ""try {[System.AppDomain]::CurrentDomain.GetAssemblies(); [System.Math]::Sqrt(144)} catch {Exit 3}""" %nul%
if !errorlevel!==3 (
echo Windows Powershell failed to load .NET command. Aborting...
set fixes=%fixes% %mas%in-place_repair_upgrade
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%in-place_repair_upgrade"
goto dk_done
)
)

REM check antivirus and other errors

echo PowerShell is not working properly. Aborting...

if /i "!tstresult2!"=="FullLanguage" (
echo:
echo Your antivirus software might be blocking the script.
echo:
sc query sense | find /i "RUNNING" %nul% && (
echo Installed Antivirus - Microsoft Defender for Endpoint
)
cmd /c "%psc% ""$av = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct; $n = @(); foreach ($i in $av) { $n += $i.displayName }; if ($n) { Write-Host ('Installed Antivirus - ' + ($n -join ', '))}"""
)

set fixes=%fixes% %mas%troubleshoot
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%troubleshoot"
goto dk_done
)

::========================================================================================================================================

::  Disable QuickEdit and launch from conhost.exe to avoid Terminal app

if %winbuild% GEQ 17763 (
set terminal=1
) else (
set terminal=
)

::  Check if script is running in Terminal app

if defined terminal (
set lines=0
for /f "skip=3 tokens=* delims=" %%A in ('mode con') do if "!lines!"=="0" (
for %%B in (%%A) do set lines=%%B
)
if !lines! GEQ 100 set terminal=
)

if %_unattended%==1 goto :skipQE
for %%# in (%_args%) do (if /i "%%#"=="-qedit" goto :skipQE)

::  Relaunch to disable QuickEdit in the current session and use conhost.exe instead of the Terminal app
::  This code disables QuickEdit for the current cmd.exe session without making permanent registry changes
::  It is included because clicking on the script window can pause execution, causing confusion that the script has stopped due to an error

set resetQE=1
reg query HKCU\Console /v QuickEdit %nul2% | find /i "0x0" %nul1% && set resetQE=0
reg add HKCU\Console /v QuickEdit /t REG_DWORD /d 0 /f %nul1%

if defined terminal (
start conhost.exe "!_batf!" %_args% -qedit
start reg add HKCU\Console /v QuickEdit /t REG_DWORD /d %resetQE% /f %nul1%
exit /b
) else if %resetQE% EQU 1 (
start cmd.exe /c ""!_batf!" %_args% -qedit"
start reg add HKCU\Console /v QuickEdit /t REG_DWORD /d %resetQE% /f %nul1%
exit /b
)

:skipQE

::========================================================================================================================================

::  Check for updates

set -=
set old=
set pingp=
set upver=%masver:.=%

for %%A in (
activ%-%ated.win
mass%-%grave.dev
) do if not defined pingp (
for /f "delims=[] tokens=2" %%B in ('ping -n 1 %%A') do (
if not "%%B"=="" (set old=1& set pingp=1)
for /f "delims=[] tokens=2" %%C in ('ping -n 1 updatecheck%upver%.%%A') do (
if not "%%C"=="" set old=
)
)
)

if defined old (
echo ________________________________________________
%eline%
echo Your version of MAS [%masver%] is outdated.
echo ________________________________________________
echo:
if not %_unattended%==1 (
echo [1] Get Latest MAS
echo [0] Continue Anyway
echo:
call :dk_color %_Green% "Choose a menu option using your keyboard [1,0] :"
choice /C:10 /N
if !errorlevel!==2 rem
if !errorlevel!==1 (start %selfgit% & start %github% & start %mas% & exit /b)
)
)

::========================================================================================================================================

cls
if not defined terminal (
mode 110, 34
if exist "%SysPath%\spp\store_test\" mode 134, 34
)
title  HWID Activation %masver%

echo:
echo Initializing...
call :dk_chkmal

for %%# in (
sppsvc.exe
ClipUp.exe
) do (
if not exist %SysPath%\%%# (
%eline%
echo [%SysPath%\%%#] file is missing, aborting...
echo:
if not defined results (
call :dk_color %Blue% "Go back to Main Menu, select Troubleshoot and run DISM Restore and SFC Scan options."
call :dk_color %Blue% "After that, restart system and try activation again."
set fixes=%fixes% %mas%in-place_repair_upgrade
call :dk_color2 %Blue% "If it still shows the same error, do this - " %_Yellow% " %mas%in-place_repair_upgrade"
)
goto dk_done
)
)

::========================================================================================================================================

set spp=SoftwareLicensingProduct
set sps=SoftwareLicensingService

call :dk_ckeckwmic
call :dk_checksku
call :dk_product
call :dk_sppissue

::========================================================================================================================================

::  Check if system is permanently activated or not

call :dk_checkperm
if defined _perm (
cls
echo ___________________________________________________________________________________________
echo:
call :dk_color2 %_White% "     " %Green% "%winos% is already permanently activated."
echo ___________________________________________________________________________________________
if %_unattended%==1 goto dk_done
echo:
choice /C:10 /N /M ">    [1] Activate Anyway [0] %_exitmsg% : "
if errorlevel 2 exit /b
)
cls

::========================================================================================================================================

::  Check Evaluation version

if exist "%SystemRoot%\Servicing\Packages\Microsoft-Windows-*EvalEdition~*.mum" (
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID %nul2% | find /i "Eval" %nul1% && (
%eline%
echo [%winos% ^| %winbuild%]
echo:
echo Evaluation editions cannot be activated outside of their evaluation period.
call :dk_color %Blue% "Use TSforge activation option from the main menu to reset evaluation period."
set fixes=%fixes% %mas%evaluation_editions
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%evaluation_editions"
goto dk_done
)
)

::========================================================================================================================================

set error=

cls
echo:
call :dk_showosinfo

::  Check Internet connection

set _int=
for %%a in (l.root-servers.net resolver1.opendns.com download.windowsupdate.com google.com) do if not defined _int (
for /f "delims=[] tokens=2" %%# in ('ping -n 1 %%a') do (if not "%%#"=="" set _int=1)
)

if not defined _int (
%psc% "If([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet){Exit 0}Else{Exit 1}"
if !errorlevel!==0 (set _int=1&set ping_f= But Ping Failed)
)

if defined _int (
echo Checking Internet Connection            [Connected%ping_f%]
) else (
set error=1
call :dk_color %Red% "Checking Internet Connection            [Not Connected]"
call :dk_color %Blue% "Internet is required for HWID activation."
)

::========================================================================================================================================

echo Initiating Diagnostic Tests...

set "_serv=ClipSVC wlidsvc sppsvc KeyIso LicenseManager Winmgmt"

::  Client License Service (ClipSVC)
::  Microsoft Account Sign-in Assistant
::  Software Protection
::  CNG Key Isolation
::  Windows License Manager Service
::  Windows Management Instrumentation

call :dk_errorcheck

::========================================================================================================================================

::  Detect Key

set key=
set altkey=
set changekey=
set altapplist=
set altedition=
set notworking=

call :dk_actids 55c92734-d682-4d71-983e-d6ec3f16059f
if defined allapps call :hwiddata key
if not defined key (
for /f "delims=" %%a in ('%psc% "$f=[System.IO.File]::ReadAllText('!_batp!') -split ':getactivationid\:.*';. ([scriptblock]::Create($f[1]))"') do (set altapplist=%%a)
if defined altapplist call :hwiddata key
)

if defined notworking call :hwidfallback
if not defined key call :hwidfallback

if defined altkey (set key=%altkey%&set changekey=1&set notworking=)

if defined notworking if defined notfoundaltactID (
call :dk_color %Red% "Checking Alternate Edition For HWID     [%altedition% Activation ID Not Found]"
)

if not defined key (
%eline%
echo [%winos% ^| %winbuild% ^| SKU:%osSKU%]
if not defined skunotfound (
echo This product does not support HWID activation.
echo Make sure you are using the latest version of the script.
echo If you are, then try TSforge activation option from the main menu.
set fixes=%fixes% %mas%
echo %mas%
) else (
echo Required license files not found in %SysPath%\spp\tokens\skus\
set fixes=%fixes% %mas%troubleshoot
call :dk_color2 %Blue% "Check this webpage for help - " %_Yellow% " %mas%troubleshoot"
)
echo:
goto dk_done
)

if defined notworking set error=1

::========================================================================================================================================

::  Install key

echo:
if defined changekey (
call :dk_color %Blue% "[%altedition%] edition product key will be used to enable HWID activation."
echo:
)

if defined winsub (
call :dk_color %Blue% "Windows Subscription [SKU ID-%slcSKU%] detected. Script will activate base edition [SKU ID-%regSKU%]."
echo:
)

set generickey=1
call :dk_inskey "[%key%]"

::========================================================================================================================================

::  Change Windows region to USA to avoid activation issues as Windows store license is not available in many countries 

for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Control Panel\International\Geo" /v Name %nul6%') do set "name=%%b"
for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Control Panel\International\Geo" /v Nation %nul6%') do set "nation=%%b"

::  Skip changing region in top countries

set regionchange=1
for %%# in (US CN IN BR DE JP GB FR MX ID IT PK TR KR CA ES AU NG VN PL PH NL EG AR TH CO SA TW MY CL) do if /i "%name%"=="%%#" set regionchange=

if defined regionchange (
%psc% "Set-WinHomeLocation -GeoId 244" %nul%
if !errorlevel! EQU 0 (
echo Changing Windows Region To USA          [Successful] [Script will change it back]
) else (
call :dk_color %Red% "Changing Windows Region To USA          [Failed]"
)
)

::==========================================================================================================================================

::  Generate GenuineTicket.xml and apply
::  In some cases clipup -v -o method fails and in some cases service resta