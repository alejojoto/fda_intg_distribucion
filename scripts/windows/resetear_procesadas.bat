@echo off
rem ===========================================================================
rem Vacia el registro de facturas PROCESADAS de esta maquina y el compartido,
rem para volver a tener PENDIENTES con que probar en serie (2026-07-26).
rem
rem Es el atajo de doble clic a:
rem     python scripts\limpiar_procesadas.py --si --espejo
rem El script hace copia de seguridad de estado.db antes de tocar nada, y
rem cierra el panel el mismo (cooperativo: si hay un llenado en curso, aborta
rem sin borrar). Los catalogos, tasas y configuracion NO se tocan.
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
echo  RESETEAR PROCESADAS
echo.
echo  Las facturas ya procesadas vuelven a estar PENDIENTES: se borra el
echo  registro de esta maquina Y el compartido que ven las demas laptops.
echo  El historial de que se lleno y cuando se pierde (queda una copia de
echo  seguridad de la base local, por si acaso).
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
set "SCRIPT=scripts\limpiar_procesadas.py"
if not exist "%SCRIPT%" set "SCRIPT=scripts\limpiar_procesadas.pyc"

"%PY%" "%SCRIPT%" --si --espejo
echo.
pause
