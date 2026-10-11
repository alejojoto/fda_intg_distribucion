@echo off
rem ===========================================================================
rem Arma el instalador completo desde el clon de DISTRIBUCION del equipo admin.
rem Doble clic: usa la version 1.1.3. Tambien acepta otra version como argumento.
rem
rem PARA QUE SIRVE: permite compilar el instalador cuando el servicio automatico
rem no esta disponible y el equipo admin no tiene el repo fuente.
rem
rem Se puede correr con el asistente abierto: el armado no toca este clon, sino
rem que lo clona aparte dentro de build\.
rem ===========================================================================
setlocal

set "VERSION=%~1"
if not defined VERSION set "VERSION=1.1.3"
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

rem El parentesis de ProgramFiles(x86) rompe los bloques if(...) de cmd: se
rem guarda aparte para poder usarlo dentro de ellos.
set "PF86=%ProgramFiles(x86)%"
rem Descarga DIRECTA del release en GitHub. La pagina de descargas de
rem jrsoftware.org (download.php/is.exe) devuelve HTML, no el programa: el
rem archivo bajaba con 10 KB y Windows respondia "no puede ejecutar el
rem programa especificado" (visto 2026-08-06 en el equipo admin).
set "URL_INNO=https://github.com/jrsoftware/issrc/releases/download/is-6_7_3/innosetup-6.7.3.exe"
set "INNO_EXE=%TEMP%\innosetup_6_7_3.exe"

call :buscar_iscc
if defined ISCC goto :iscc_listo

echo Inno Setup 6 no esta instalado. Se descargara ahora (unos 10 MB).
curl -L --fail -o "%INNO_EXE%" "%URL_INNO%"
if not exist "%INNO_EXE%" (
    echo No se pudo descargar Inno Setup 6 desde:
    echo %URL_INNO%
    echo Bajalo a mano en un navegador, instalalo, y vuelve a ejecutar este archivo.
    pause
    exit /b 1
)
rem Que el archivo exista no basta: si el servidor devuelve una pagina de
rem error queda un .exe de unos pocos KB que Windows no puede ejecutar.
for %%A in ("%INNO_EXE%") do set "TAM_INNO=%%~zA"
if %TAM_INNO% LSS 1000000 (
    echo Lo que se descargo no es el instalador de Inno Setup ^(%TAM_INNO% bytes^).
    echo Bajalo a mano desde https://jrsoftware.org/isdl.php, instalalo, y
    echo vuelve a ejecutar este archivo.
    del "%INNO_EXE%" >nul 2>&1
    pause
    exit /b 1
)
"%INNO_EXE%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /CURRENTUSER
call :buscar_iscc
if not defined ISCC (
    echo Inno Setup se descargo bien pero no quedo instalado donde se esperaba.
    echo Instalalo a mano desde https://jrsoftware.org/isdl.php y vuelve a
    echo ejecutar este archivo.
    pause
    exit /b 1
)

:iscc_listo
echo Inno Setup encontrado en: %ISCC%

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
exit /b 0

rem ---------------------------------------------------------------------------
rem Deja ISCC apuntando al compilador de Inno Setup 6, o sin definir si no
rem esta. Las dos rutas son las que usa su instalador: para todos los usuarios
rem y solo para el actual.
rem ---------------------------------------------------------------------------
:buscar_iscc
set "ISCC="
if exist "%PF86%\Inno Setup 6\ISCC.exe" set "ISCC=%PF86%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" set "ISCC=%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe"
goto :eof
