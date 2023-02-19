@echo off


:: BatchGotAdmin
:-------------------------------------

REM  --> Check for permissions
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
	>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/k ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------


SETLOCAL EnableDelayedExpansion


choco -? >nul 2>&1 || (
    echo Installing Chocolatey...
	powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
)

choco install youtube-dl yt-dlp ffmpeg atomicparsley aria2 wget openssl -y


REM ===============================================================================

>nul reg delete "HKEY_CLASSES_ROOT\Directory\background\shell\youtube" /F
reg add "HKEY_CLASSES_ROOT\Directory\background\shell\youtube" /D "youtube-dl" /F
reg add "HKEY_CLASSES_ROOT\Directory\background\shell\youtube" /V "Icon" /D "C:\Windows\system32\cmd.exe,0" /F
::reg add "HKEY_CLASSES_ROOT\Directory\background\shell\youtube" /v Extended /f
reg add "HKEY_CLASSES_ROOT\Directory\background\shell\youtube\command" /D "\"%~dp0\y.bat\" \"%%v\"" /F

REM ===============================================================================