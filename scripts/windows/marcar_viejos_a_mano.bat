@echo off
rem ===========================================================================
rem Marca como "llenadas a mano" las facturas pendientes de pedidos ANTERIORES
rem al lunes de esta semana: el backlog lo factura una persona en Winledger y
rem no tiene que estorbar en PENDIENTES (pedido del usuario 2026-07-28).
rem
rem Es el atajo de doble clic a:
rem     python scripts\marcar_viejos_como_a_mano.py
rem El script muestra cuantas facturas son y de que fechas, guarda un respaldo
rem en reports\ y recien ahi pide confirmacion. Marcar a mano NO cierra nada
rem para siempre: esas facturas siguen en PROCESADAS con "Llenar igual".
rem
rem Para otro corte, correr el script a mano con --antes-de AAAA-MM-DD.
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
echo  MARCAR EL BACKLOG COMO LLENADO A MANO
echo.
echo  Los pedidos anteriores al lunes de esta semana salen de PENDIENTES y
echo  pasan a PROCESADAS como "facturada a mano". Siguen disponibles ahi con
echo  "Llenar igual" por si hay que reemitir alguna.
echo.
echo  Primero se muestra cuantas son y de que fechas; nada se toca hasta que
echo  escribas SI.
echo ============================================================================
echo.

rem En la instalacion empaquetada el script viaja compilado: solo hay .pyc.
set "SCRIPT=scripts\marcar_viejos_como_a_mano.py"
if not exist "%SCRIPT%" set "SCRIPT=scripts\marcar_viejos_como_a_mano.pyc"

"%PY%" "%SCRIPT%"
echo.
pause
