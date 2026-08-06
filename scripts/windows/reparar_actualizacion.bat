@echo off
rem ===========================================================================
rem Deja el clon de esta instalacion apuntando al repo de distribucion PUBLICO
rem por HTTPS (2026-08-06). Doble clic, sin teclear nada.
rem
rem PARA QUE SIRVE: los instaladores anteriores al 2026-08-06 dejan el clon
rem apuntando por SSH, que exigia una llave de despliegue por maquina. Esa
rem llave salio del esquema (el repo es publico y se lee sin credencial), pero
rem una instalacion hecha con un instalador viejo sigue con el remoto SSH y
rem entonces NO puede bajar ninguna actualizacion — ni la que arregla esto.
rem Este archivo rompe ese circulo.
rem
rem Es seguro correrlo varias veces y sobre una instalacion que ya este bien:
rem si el remoto ya es HTTPS, no toca nada.
rem ===========================================================================
setlocal

set "REPO=https://github.com/alejojoto/fda_intg_distribucion.git"

rem La carpeta de la instalacion: la de este .bat (scripts\windows\ dentro de
rem app\) o, si se copio suelto, las rutas conocidas.
set "APP=%~dp0..\.."
if not exist "%APP%\.git" set "APP=C:\Winled\Asistente\app"
if not exist "%APP%\.git" set "APP=%LOCALAPPDATA%\FDA\Asistente\app"
if not exist "%APP%\.git" (
    echo No se encontro la instalacion del asistente.
    echo Se busco en:
    echo    %~dp0..\..
    echo    C:\Winled\Asistente\app
    echo    %LOCALAPPDATA%\FDA\Asistente\app
    echo.
    echo Copia este archivo dentro de la carpeta "app" de la instalacion y
    echo vuelve a ejecutarlo.
    pause
    exit /b 1
)

set "GIT=%APP%\..\runtime\mingit\cmd\git.exe"
if not exist "%GIT%" set "GIT=git"

echo Instalacion encontrada: %APP%
for /f "delims=" %%u in ('"%GIT%" -C "%APP%" remote get-url origin 2^>nul') do set "ACTUAL=%%u"
echo Remoto actual: %ACTUAL%

echo %ACTUAL% | findstr /b /c:"https://" >nul
if not errorlevel 1 (
    echo.
    echo El remoto ya es HTTPS: no hay nada que reparar.
    echo Cierra el asistente desde la bandeja y vuelve a abrirlo para que
    echo busque actualizaciones.
    pause
    exit /b 0
)

"%GIT%" -C "%APP%" remote set-url origin "%REPO%"
if errorlevel 1 (
    echo.
    echo No se pudo cambiar el remoto. Anota lo que dice arriba y avisa.
    pause
    exit /b 1
)

for /f "delims=" %%u in ('"%GIT%" -C "%APP%" remote get-url origin 2^>nul') do set "NUEVO=%%u"
echo Remoto nuevo:  %NUEVO%
echo.
echo Listo. Ahora cierra el asistente DESDE LA BANDEJA (el icono junto al
echo reloj, no solo la ventana) y vuelve a abrirlo: al arrancar bajara la
echo version nueva y se pondra al dia solo.
pause
