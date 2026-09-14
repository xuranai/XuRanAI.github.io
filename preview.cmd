@echo off
setlocal
cd /d "%~dp0"
title Local preview - close this window to stop

rem ===========================================================
rem  Personal academic homepage - local preview launcher
rem
rem  Double-click this file. It starts a small local web server
rem  and opens the browser for you.
rem
rem  Why a server is needed: index.html loads content.md with
rem  fetch(), and browsers refuse to let a file:// page read
rem  local files, so the page must be served over http.
rem
rem  This file is ASCII-only on purpose: cmd.exe parses .cmd
rem  files using the ANSI code page, and with UTF-8 text a
rem  multi-byte character right before a line break can swallow
rem  the line break and merge the next line into the current one.
rem ===========================================================

rem ---- 1. Locate a usable Python ----
set "PY="
for /f "delims=" %%P in ('where python 2^>nul ^| findstr /v /i "WindowsApps"') do if not defined PY set "PY=%%P"
for /f "delims=" %%P in ('where python3 2^>nul ^| findstr /v /i "WindowsApps"') do if not defined PY set "PY=%%P"
for /f "delims=" %%P in ('where py 2^>nul') do if not defined PY set "PY=%%P"
if not defined PY if exist "%USERPROFILE%\miniconda3\python.exe" set "PY=%USERPROFILE%\miniconda3\python.exe"
if not defined PY if exist "%USERPROFILE%\anaconda3\python.exe" set "PY=%USERPROFILE%\anaconda3\python.exe"
if not defined PY if exist "%LOCALAPPDATA%\Programs\Python\Python313\python.exe" set "PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
if not defined PY if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PY=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"

if not defined PY goto nopython

rem ---- 2. Find a port we are actually allowed to bind ----
rem  A plain "is anything listening" check is not enough: Windows
rem  reserves some port ranges for itself (netsh int ipv4 show
rem  excludedportrange protocol=tcp), and binding to a reserved
rem  port fails with WinError 10013 even though nothing is
rem  listening on it. So ask Python to really try the bind.
rem  Reserved blocks are usually ~100 ports wide, hence the step.
set /a PORT=8000
:findport
"%PY%" -c "import socket,sys;s=socket.socket();s.bind(('127.0.0.1',int(sys.argv[1])))" %PORT% >nul 2>nul
if not errorlevel 1 goto portok
set /a PORT=PORT+100
if %PORT% gtr 9000 goto noport
goto findport
:portok

rem ---- 3. Open the browser and serve this folder ----
echo.
echo   ============================================================
echo     Local preview is running
echo.
echo     Open:   http://127.0.0.1:%PORT%/
echo   ============================================================
echo.
echo     Edit content.md, then just refresh the browser.
echo     Close this window to stop the server.
echo.
start "" "http://127.0.0.1:%PORT%/"
"%PY%" -m http.server %PORT% --bind 127.0.0.1

echo.
echo   Server stopped.
pause
exit /b 0

:nopython
echo.
echo   [X] Python not found, so the local preview cannot start.
echo.
echo       1. Install Python 3 from https://www.python.org/downloads/
echo          and tick "Add python.exe to PATH" during setup.
echo       2. Or deploy to GitHub Pages - the online page has no such limit.
echo.
pause
exit /b 1

:noport
echo.
echo   [X] No usable port found in the 8000-9000 range. Windows may have
echo       reserved all of them. Try again, or start the server by hand:
echo       python -m http.server 8123
echo.
pause
exit /b 1
