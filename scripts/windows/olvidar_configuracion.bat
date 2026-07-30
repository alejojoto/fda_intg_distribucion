@echo off
rem ===========================================================================
rem Configuracion obligatoria de ESTA computadora (nombre, vendedor, serie y
rem dia de despacho): dos opciones para no confundir "ver la pantalla" con
rem "borrar de verdad" (2026-07-29; serie y dia se sumaron el 2026-07-30;
rem opcion de solo ver, 2026-07-31).
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

rem En la instalacion empaquetada el script viaja compilado: solo hay .pyc.
set "SCRIPT=scripts\olvidar_configuracion_maquina.py"
if not exist "%SCRIPT%" set "SCRIPT=scripts\olvidar_configuracion_maquina.pyc"

echo ============================================================================
echo  CONFIGURACION OBLIGATORIA DE ESTA COMPUTADORA
echo.
echo  1) Solo ver la pantalla (no borra nada; sale ya llena con lo que hay
echo     guardado aqui). El panel tiene que estar abierto.
echo  2) Borrar de verdad el nombre, el vendedor, la serie y el dia de
echo     despacho, para ver la pantalla en blanco como en una instalacion
echo     nueva. Si el panel esta abierto, se cierra solo.
echo ============================================================================
echo.
set "OPCION="
set /p "OPCION=Elige 1 o 2 y pulsa Enter (cualquier otra cosa cancela): "

if "%OPCION%"=="1" goto :vista_previa
if "%OPCION%"=="2" goto :borrado_real
echo.
echo Cancelado: no se hizo nada.
pause
exit /b 0

:vista_previa
echo.
"%PY%" "%SCRIPT%" --ver
echo.
pause
exit /b 0

:borrado_real
echo.
set "RESPUESTA="
set /p "RESPUESTA=Escribe SI y pulsa Enter para continuar (cualquier otra cosa cancela): "
if /i not "%RESPUESTA%"=="SI" (
    echo.
    echo Cancelado: no se borro nada.
    pause
    exit /b 0
)

echo.
"%PY%" "%SCRIPT%" --si
echo.
pause
