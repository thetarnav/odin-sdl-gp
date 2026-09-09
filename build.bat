@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT_DIR=%~dp0"
set "HEADER=%ROOT_DIR%SDL_gp\SDL_gp.h"
set "INCLUDE_DIR=%ROOT_DIR%include"
set "LIB_DIR=%ROOT_DIR%lib"
set "BUILD_DIR=%ROOT_DIR%.build"

if not exist "%HEADER%" (
	echo error: SDL_gp header not found:
	echo %HEADER%
	exit /b 1
)

if "%CC%"=="" set "CC=clang"
if "%AR%"=="" set "AR=llvm-lib"

mkdir "%INCLUDE_DIR%" 2>nul
mkdir "%LIB_DIR%" 2>nul
mkdir "%BUILD_DIR%" 2>nul

set "SDL3_CFLAGS="

if not "%SDL3_DIR%"=="" (
	set "SDL3_CFLAGS=/I"%SDL3_DIR%\include""
) else if not "%SDL3_ROOT%"=="" (
	set "SDL3_CFLAGS=/I"%SDL3_ROOT%\include""
)

echo CC:     %CC%
echo AR:     %AR%
echo Header: %HEADER%

%CC% ^
	-std=c11 ^
	-O2 ^
	-I"%ROOT_DIR%SDL_gp" ^
	%SDL3_CFLAGS% ^
	-DSDL_GP_IMPLEMENTATION ^
	-x c ^
	-c "%HEADER%" ^
	-o "%BUILD_DIR%\SDL_gp.obj"

if errorlevel 1 exit /b %errorlevel%

%AR% ^
	/out:"%LIB_DIR%\SDL3_gp.lib" ^
	"%BUILD_DIR%\SDL_gp.obj"

if errorlevel 1 exit /b %errorlevel%

copy /Y "%HEADER%" "%INCLUDE_DIR%\SDL_gp.h" >nul

echo Built %LIB_DIR%\SDL3_gp.lib
