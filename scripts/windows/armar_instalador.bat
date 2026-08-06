@echo off
rem ===========================================================================
rem Arma el instalador completo desde el clon de DISTRIBUCION del equipo admin.
rem Doble clic: usa la version 1.2. Tambien acepta otra version como argumento.
rem
rem PARA QUE SIRVE: permite compilar el instalador cuando el servicio automatico
rem no esta disponible y el equipo admin no tiene el repo fuente.
rem
rem Se puede correr con el asistente abierto: el armado no toca este clon, sino
rem que lo clona aparte dentro de build\.
rem ===========================================================================
setlocal

set "VERSION=%~1"
if not defined VERSION set "VERSION=1.2"
echo %VERSION%| findstr /r "^[0-9][0-9.]*$" >nul
if errorlevel 1 (
    echo La version "%VERSION%" no es valida. Usa solo digitos y puntos.
    pause
    exit /b 1
)

rem La carpeta de la instalacion: la de este .bat o las rutas conocidas.
set "APP=%~dp0..\.."
if not exist "%APP%\.git" set "APP=C:\Winled\Asistente\app"
if not exist "%APP%\.git" set "APP=%LOCALAPPDATA%\FDA\Asistente\app"
if not exist "%APP%\.git" (
    echo No se encontro la instalacion del asistente.
    echo Copia este archivo dentro de la carpeta app y vuelve a ejecutarlo.
    pause
    exit /b 1
)

set "PY=%APP%\..\runtime\python\python.exe"
if not exist "%PY%" (
    echo No se encontro el runtime de Python en:
    echo %PY%
    echo Este atajo solo sirve en una instalacion completa del asistente.
    pause
    exit /b 1
)
set "PATH=%APP%\..\runtime\mingit\cmd;%PATH%"

set "ISCC="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set "ISCC=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
if not defined ISCC (
    echo Inno Setup 6 no esta instalado. Se descargara ahora.
    curl -L -o "%TEMP%\innosetup_instalador.exe" https://jrsoftware.org/download.php/is.exe
    if exist "%TEMP%\innosetup_instalador.exe" "%TEMP%\innosetup_instalador.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /CURRENTUSER
    if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
    if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set "ISCC=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
)
if not defined ISCC (
    echo No se pudo instalar Inno Setup 6.
    echo Instalalo a mano desde https://jrsoftware.org/ y vuelve a ejecutar este archivo.
    pause
    exit /b 1
)

set "SUPABASE_URL="
set "SUPABASE_KEY="
for /f "usebackq tokens=1,* delims==" %%a in (`findstr /b /c:"SUPABASE_URL=" "%APP%\.env" 2^>nul`) do set "SUPABASE_URL=%%b"
for /f "usebackq tokens=1,* delims==" %%a in (`findstr /b /c:"SUPABASE_KEY=" "%APP%\.env" 2^>nul`) do set "SUPABASE_KEY=%%b"
if not defined SUPABASE_URL (
    echo Falta SUPABASE_URL en %APP%\.env. Configurala y vuelve a intentar.
    pause
    exit /b 1
)
if not defined SUPABASE_KEY (
    echo Falta SUPABASE_KEY en %APP%\.env. Configurala y vuelve a intentar.
    pause
    exit /b 1
)

cd /d "%APP%"
"%PY%" scripts\build\armar_bundle.pyc --origen-repo . --repo-distribucion . --remoto-ssh https://github.com/alejojoto/fda_intg_distribucion.git --supabase-url "%SUPABASE_URL%" --supabase-key "%SUPABASE_KEY%"
if errorlevel 1 (
    echo.
    echo No se pudo armar el bundle. Revisa la salida de arriba.
    pause
    exit /b 1
)

<nul set /p "=%VERSION%" > "build\bundle\app\VERSION_INSTALADOR.txt"

"%ISCC%" /DAppVersion=%VERSION% /DOutputBase=asistente_fda_setup_%VERSION% scripts\build\instalador.iss
if errorlevel 1 (
    echo.
    echo No se pudo compilar el instalador. Revisa la salida de arriba.
    pause
    exit /b 1
)

certutil -hashfile "build\salida\asistente_fda_setup_%VERSION%.exe" SHA256
echo.
echo El instalador quedo en build\salida\.
echo Copialo a la computadora nueva y ejecutalo alli.
start "" explorer "build\salida"
pause
