@echo off
rem OSM Tile Cache Installer
rem Copyright (c) 2026 John Rokicki KC1VMZ
rem 
rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem 
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem 
rem You should have received a copy of the GNU General Public License
rem along with this program.  If not, see <https://www.gnu.org/licenses/>.
rem
rem http://www.kc1vmz.com
rem 

setlocal enabledelayedexpansion

echo Welcome to the OSM Tile Cache installer for Microsoft Windows.
echo Copyright (c) 2026 John Rokicki KC1VMZ - Licensed under GPL v3
echo https://www.kc1vmz.com
echo.
echo This installer expects pre-requisite software to be installed - Java 21+
echo Please install these pre-requisites prior to installation.
echo Java can be found at https://www.java.com/en/download/manual.jsp
echo.
pause
SET OSMTC_INSTALL_DIR=%USERPROFILE%\OSMTileCache
SET OSMTC_TEMP_DIR=%TEMP%\OSMTileCache
SET OSMTC_DB_DIR=%OSMTC_TEMP_DIR%\db
SET OSMTC_TILES_DIR=%OSMTC_TEMP_DIR%\tiles
SET OSMTC_VERSION=1.0.0
SET OSMTC_PORT=8888
SET OSMTC_TILE_SERVER=tile.openstreetmap.org

REM Prompt the user for input
SET /P "OSMTC_VERSION=What version of OSM Tile Cache? (Default: %OSMTC_VERSION%): "
SET /P "OSMTC_INSTALL_DIR=Where should OSM Tile Cache be installed? (Default: %OSMTC_INSTALL_DIR%): "
SET /P "OSMTC_DB_DIR=Where should OSM Tile Cache database space be located? (Default: %OSMTC_DB_DIR%): "
SET /P "OSMTC_TEMP_DIR=Where should OSM Tile Cache temp space be located? (Default: %OSMTC_TEMP_DIR%): "
SET /P "OSMTC_TILES_DIR=Where should OSM Tile Cache tile space be located? (Default: %OSMTC_TILES_DIR%): "
SET /P "OSMTC_PORT=What port should the HTTP service listen on? (Default: %OSMTC_PORT%): "
SET /P "OSMTC_CONFIG=What operation mode (proxy, cache, proxycache - default: %OSMTC_CONFIG%): "
SET /P "OSMTC_TILE_SERVER=Tile server address (Default: %OSMTC_TILE_SERVER%): "


pushd .

echo Checking for pre-requisite - Java 21
rem Step 1: Check if Java is installed at all
where java >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed or not added to your system PATH.
    goto done
)
rem Step 2: Extract the major version number
rem This runs 'java -version', grabs the first line, and parses the version string.
for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set "java_version=%%g"
)
rem Remove surrounding quotes from the version string (e.g., "17.0.1" -> 17.0.1)
set "java_version=%java_version:"=%"
rem Extract the main major version number before the first dot
for /f "delims=." %%v in ("!java_version!") do (
    set "major_version=%%v"
)
rem Handle legacy naming convention (e.g., Java 8 outputs "1.8", so major is 1)
if "!major_version!"=="1" (
    for /f "tokens=2 delims=." %%v in ("!java_version!") do (
        set "major_version=%%v"
    )
)
rem Step 3: Validate if version is 21 or greater
if !major_version! lss 21 (
    echo [ERROR] Java version is too old. Required: 21 or greater.
    goto done
)

echo Starting installation

echo Creating directories
mkdir %OSMTC_INSTALL_DIR%
mkdir %OSMTC_TEMP_DIR%
mkdir %OSMTC_DB_DIR%
mkdir %OSMTC_TILES_DIR%

cd %OSMTC_INSTALL_DIR%

echo Downloading built components for version %OSMTC_VERSION% from Github
SET OSMTC_SRC_URL_ROOT=https://github.com/kc1vmz/osmtilecache/releases/download/v%OSMTC_VERSION%
curl -L -o osmtilecache-%OSMTC_VERSION%.jar %OSMTC_SRC_URL_ROOT%\osmtilecache-%OSMTC_VERSION%.jar
SET OSMTC_SRC_URL_ROOT=

echo Creating startup script
echo @ECHO OFF>> osmtc_start.bat
echo pushd .>> osmtc_start.bat
echo cd %OSMTC_INSTALL_DIR%>> osmtc_start.bat
echo REM Set Environment Variables>> osmtc_start.bat
echo SET OSMTC_DB_DIR=%OSMTC_DB_DIR%>> osmtc_start.bat
echo SET OSMTC_TEMP_DIR=%OSMTC_TEMP_DIR%>> osmtc_start.bat
echo SET OSMTC_TILES_DIR=%OSMTC_TILES_DIR%>> osmtc_start.bat
echo SET SERVER_PORT=%OSMTC_PORT%>> osmtc_start.bat
echo SET OSMTC_INSTALL_DIR=%OSMTC_INSTALL_DIR%>> osmtc_start.bat
echo SET OSMTC_CONFIG=%OSMTC_CONFIG%>> osmtc_start.bat
echo SET OSMTC_TILE_SERVER=%OSMTC_TILE_SERVER%>> osmtc_start.bat
echo REM Start Processes>> osmtc_start.bat
echo start java -jar osmtilecache-%OSMTC_VERSION%.jar>> osmtc_start.bat
echo echo OSM Tile Cache started>> osmtc_start.bat
echo popd>> osmtc_start.bat

echo Finishing up
popd

SET OSMTC_INSTALL_DIR=
SET OSMTC_TEMP_DIR=
SET OSMTC_VERSION=
SET OSMTC_TEMP_DIR=
SET OSMTC_TILES_DIR=
SET OSMTC_CONFIG=
SET OSMTC_TILE_SERVER=

echo.
echo Installation complete.
echo.
echo Run 'osmtc_start.bat' to start OSM Tile Cache.
exit /b 0

:done
exit /b 1