@echo off
rem ===========================================================================
rem Devuelve este equipo admin a DESARROLLO despues de "Como operacion"
rem (2026-09-13). Esa marca no se quita desde el panel a proposito: una
rem computadora de operacion no puede volverse dev sola. Este es el camino de
rem vuelta: borra la marca y deja el canal en automatico.
rem
rem Es el atajo de doble clic a:
rem     python scripts\volver_a_dev.py
rem No toca facturas, catalogos ni la nube. Al terminar, cierra y vuelve a
rem abrir el asistente para que cargue la version de desarrollo.
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
set "SCRIPT=scripts\volver_a_dev.py"
if not exist "%SCRIPT%" set "SCRIPT=scripts\volver_a_dev.pyc"

"%PY%" "%SCRIPT%"
echo.
pause
