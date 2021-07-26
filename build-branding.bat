@echo off
setlocal EnableDelayedExpansion
cls

set BRANDING_VALUE=%~1
call "%~dp0/build.bat" Release