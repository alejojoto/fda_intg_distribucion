@echo off
rem ===========================================================================
rem Saca de logs\ventana.log y logs\panel.log por que la ventana del panel no
rem floto, y lo abre en el Bloc de notas (2026-07-29).
rem
rem Es el atajo de doble clic a:
rem     python scripts\diagnostico_ventana.py
rem Arriba del recorte va un VEREDICTO: si el plantado aterrizo, si quedo sin
rem "siempre encima" o si hay otra ventana tapandola. Eso es lo unico que hay
rem que leer; el resto es para mandar.
rem
rem No borra ni modifica nada: solo lee los logs y escribe un recorte nuevo en
rem logs\diagnostico_ventana_<fecha>.txt. Se puede correr con el panel abierto.
rem
rem Para el LLENADO (lineas enviadas, grid, cierre) el atajo es el otro:
rem     scripts\windows\ver_diagnostico.bat
rem ===========================================================================
cd /d "%~dp0..\.."

rem El interprete depende de como este instalado el asistente (2026-07-29):
rem   - Instalacion empaquetada: el Python viaja en runtime\, hermano de app\,
rem     y NO hay .venv — pedir ahi que se corra instalar.bat manda al operador
rem     a un callejon sin salida (ese .bat es del flujo de clon manual).
rem   - Clon con venv (maquina de desarrollo): .venv\Scripts\python.exe.
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
set "SCRIPT=scripts\diagnostico_ventana.py"
if not exist "%SCRIPT%" set "SCRIPT=scripts\diagnostico_ventana.pyc"

"%PY%" "%SCRIPT%" %*
echo.
pause
