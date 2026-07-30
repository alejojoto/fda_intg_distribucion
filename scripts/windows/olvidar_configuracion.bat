@echo off
rem ===========================================================================
rem Olvida el nombre, el vendedor, la serie y el dia de despacho de ESTA
rem computadora, para volver a ver la pantalla de configuracion obligatoria de
rem una instalacion nueva (2026-07-29; serie y dia se sumaron el 2026-07-30).
rem
rem Es el atajo de doble clic a:
rem     python scripts\olvidar_configuracion_maquina.py --si
rem Cierra el panel el mismo (cooperativo: con un llenado en curso aborta sin
rem borrar). Los catalogos, las tasas y el registro de facturas NO se tocan.
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
echo  OLVIDAR LA CONFIGURACION DE ESTA COMPUTADORA
echo.
echo  Se borran el nombre con el que aparece en el historial y el vendedor
echo  con el que factura. Al abrir el panel de nuevo, saldra la pantalla de
echo  configuracion como en una instalacion nueva.
echo.
echo  Si el panel esta abierto, se cierra solo. Al terminar, abrelo de nuevo.
echo ============================================================================
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
rem En la instalacion empaquetada el script viaja compilado: solo hay .pyc.
set "SCRIPT=scripts\olvidar_configuracion_maquina.py"
if not exist "%SCRIPT%" set "SCRIPT=scripts\olvidar_configuracion_maquina.pyc"

"%PY%" "%SCRIPT%" --si
echo.
pause
