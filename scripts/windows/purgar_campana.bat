@echo off
rem ===========================================================================
rem Busca y purga campanas de descuento que reaparecen entre maquinas.
rem
rem Primero muestra donde esta la campana, y despues pide confirmacion para
rem borrarla de verdad. Si otra maquina la sigue conservando, su subida diaria
rem la volvera a poner en la nube y de ahi volvera a bajar a todas.
rem ===========================================================================
cd /d "%~dp0..\.."

set "PY=.venv\Scripts\python.exe"
if not exist "%PY%" set "PY=..\runtime\python\python.exe"
if not exist "%PY%" (
    echo ERROR: no se encontro el Python del asistente. Se busco en:
    echo    .venv\Scripts\python.exe          ^(clon con entorno propio^)
    echo    ..\runtime\python\python.exe      ^(instalacion empaquetada^)
    pause
    exit /b 1
)

echo ============================================================================
echo  PURGAR CAMPANA
echo.
echo  La campana puede existir en este equipo, en la papelera local o en la
echo  nube. Primero se muestra donde esta. Si confirmas con SI, se borra de
echo  verdad.
echo ============================================================================
echo.
set "NOMBRE="
set /p "NOMBRE=Escribe el nombre de la campana y pulsa Enter: "
if "%NOMBRE%"=="" (
    echo.
    echo Cancelado: no se borro nada.
    pause
    exit /b 0
)

rem En la instalacion empaquetada el script viaja compilado: solo hay .pyc.
set "SCRIPT=scripts\purgar_campana.py"
if not exist "%SCRIPT%" set "SCRIPT=scripts\purgar_campana.pyc"

"%PY%" "%SCRIPT%" --nombre "%NOMBRE%"
if errorlevel 1 (
    echo.
    pause
    exit /b 1
)

echo.
set "RESPUESTA="
set /p "RESPUESTA=Escribe SI y pulsa Enter para borrar de verdad (cualquier otra cosa cancela): "
if /i not "%RESPUESTA%"=="SI" (
    echo.
    echo Cancelado: no se borro nada.
    pause
    exit /b 0
)

echo.
"%PY%" "%SCRIPT%" --nombre "%NOMBRE%" --si
echo.
pause
