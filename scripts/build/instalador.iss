; Instalador de Windows del Asistente FDA (Inno Setup 6).
;
; Empaqueta el bundle ya armado por scripts/build/armar_bundle.py en
; build/bundle/ (runtime de Python, MinGit, el clon de la app y el .bat de
; arranque) dentro de un instalador de un solo .exe, pensado para que un
; operador SIN conocimientos tecnicos lo corra sin ayuda: sin privilegios de
; administrador, wizard en espanol, y con las llaves (.env, credenciales)
; cargadas en el mismo paso si el zip de llaves esta al lado del instalador.
;
; Este .iss NO compila en el Mac (falta ISCC): la compilacion real y su
; verificacion viven en .github/workflows/instalador.yml, corriendo en
; windows-latest.
;
; Version y nombre de archivo de salida son parametrizables desde la linea
; de comandos de ISCC con /DAppVersion=... /DOutputBase=... (los usa el
; workflow para versionar por numero de corrida); si se compila a mano sin
; esos parametros, se usan los valores por defecto de abajo.
#ifndef AppVersion
  #define AppVersion "0.0-local"
#endif
#ifndef OutputBase
  #define OutputBase "asistente_fda_setup_local"
#endif

[Setup]
; GUID fijo e inventado para este producto (NO cambiar entre versiones: es
; lo que le permite a Windows reconocer una reinstalacion/actualizacion en
; vez de tratarla como un programa distinto).
AppId={{EFD97979-0057-44F7-8668-64ADC52073E7}
AppName=Asistente FDA
AppVersion={#AppVersion}
; Sin privilegios de administrador (decision del usuario): el operador no
; tiene por que tener ni pedir permisos elevados para instalar su propio
; asistente de trabajo. Por eso el destino vive bajo su perfil, no en
; Archivos de programa.
PrivilegesRequired=lowest
DefaultDirName={localappdata}\FDA\Asistente
DisableProgramGroupPage=yes
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
OutputDir=..\..\build\salida
OutputBaseFilename={#OutputBase}
; Icono del asistente (arbol fractal verde, assets\icono.ico del repo): lo
; usa el propio instalador y la entrada de Programas y caracteristicas.
SetupIconFile=..\..\assets\icono.ico
UninstallDisplayIcon={app}\app\assets\icono.ico
; Sin el cierre de aplicaciones de Windows (Restart Manager): el panel y la
; ventana propia son pythonw sin ventana que responda a esos mensajes, asi
; que el dialogo "cerrar aplicaciones" se quedaba intentando un rato largo
; sin lograr nada (reportado por el usuario 2026-08-06). El cierre real lo
; hace PrepareToInstall: apagado cooperativo y remate por ruta.
CloseApplications=no

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
; Todo el bundle armado por armar_bundle.py, tal cual, sin reorganizar
; nada: runtime\, app\ (el clon con .env/credenciales/data/logs
; gitignoreados) e iniciar_asistente.bat.
Source: "..\..\build\bundle\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion; Excludes: "app\.env"

; El .env va aparte y SOLO si no existe: al reinstalar sobre una instalacion
; que ya trabaja, pisarlo le borraria lo que se le agrego despues (las
; variables de la hoja que baja la activacion, y en el equipo admin la clave
; de servicio de la bandeja de tickets).
Source: "..\..\build\bundle\app\.env"; DestDir: "{app}\app"; Flags: onlyifdoesntexist skipifsourcedoesntexist

; AppUserModelID: ata la ventana propia del panel (src/ventana_app.py) a su
; acceso directo, para que Windows le ponga el icono del asistente en la
; barra de tareas y, si esta anclado, pulsarlo traiga la ventana que ya esta
; abierta en vez de lanzar otra. Tiene que quedar identico a
; APP_USER_MODEL_ID en ventana_app.py.
;
; SOLO las entradas "Asistente FDA" llevan ese id (2026-07-30). El nombre que
; la barra de tareas muestra sobre el boton no sale del titulo de la ventana:
; sale del acceso directo que declara el mismo AppUserModelID. Con el icono de
; diagnostico compartiendolo, Windows podia elegirlo a el y el operador leia
; "Asistente (diagnostico con consola)" aunque hubiera abierto por el acceso
; directo normal. Por eso el de diagnostico tiene id propio.
[Icons]
; Acceso directo principal: el modo normal de uso, sin consola. IconFilename
; apunta al .ico del repo ya instalado ({app}\app\assets\icono.ico): sin el,
; el acceso directo mostraria el icono generico de pythonw.exe.
Name: "{autodesktop}\Asistente FDA"; Filename: "{app}\runtime\python\pythonw.exe"; Parameters: "-m src.lanzador"; WorkingDir: "{app}\app"; IconFilename: "{app}\app\assets\icono.ico"; AppUserModelID: "FDA.Asistente.Panel"
Name: "{autoprograms}\Asistente FDA"; Filename: "{app}\runtime\python\pythonw.exe"; Parameters: "-m src.lanzador"; WorkingDir: "{app}\app"; IconFilename: "{app}\app\assets\icono.ico"; AppUserModelID: "FDA.Asistente.Panel"
; Segundo icono, solo en el menu de inicio, para diagnostico: misma
; entrada pero con python.exe (con consola) en vez de pythonw.exe, para
; ver mensajes de arranque/errores sin tener que abrir el log a mano.
Name: "{autoprograms}\Asistente FDA (diagnóstico con consola)"; Filename: "{app}\runtime\python\python.exe"; Parameters: "-m src.lanzador"; WorkingDir: "{app}\app"; IconFilename: "{app}\app\assets\icono.ico"; AppUserModelID: "FDA.Asistente.Diagnostico"

; Renombre de los accesos directos (2026-07-28): antes se llamaban "Asistente
; de facturas". Sin borrar los viejos, una actualizacion dejaria DOS iconos con
; el mismo destino en el escritorio. El anclaje a la barra de tareas no se
; pierde: Windows lo guarda como copia aparte, y la ventana se ata a el por el
; AppUserModelID, no por el nombre.
[InstallDelete]
Type: files; Name: "{autodesktop}\Asistente de facturas.lnk"
Type: files; Name: "{autoprograms}\Asistente de facturas.lnk"
; El de diagnostico se llamaba "Asistente (diagnóstico con consola)" hasta el
; 2026-07-30. Borrarlo no es cosmetico: mientras exista sigue declarando
; "FDA.Asistente.Panel" y Windows puede volver a tomar SU nombre para el boton
; de la barra de tareas, que es justo lo que se venia a arreglar.
Type: files; Name: "{autoprograms}\Asistente (diagnóstico con consola).lnk"

; Limpieza del codigo viejo antes de copiar (2026-07-28). Hasta esa fecha la
; instalacion traia el repo FUENTE: el arbol .py, el .git con todo el
; historial y la documentacion de diseno. Una actualizacion encima no alcanza
; para sacarlos — Inno copia lo nuevo pero no borra lo que ya no existe en el
; bundle — y ademas quedarian conviviendo: ante src\panel\app.py y
; src\panel\app.pyc, Python importa el .py, o sea que la maquina seguiria
; corriendo el codigo viejo indefinidamente.
;
; Se borran SOLO las carpetas de codigo, historial y documentacion. Lo del
; operador vive fuera de ellas y no se toca: .env, credenciales\, data\ (con
; estado.db) y logs\.
Type: filesandordirs; Name: "{app}\app\src"
Type: filesandordirs; Name: "{app}\app\scripts"
Type: filesandordirs; Name: "{app}\app\docs"
Type: filesandordirs; Name: "{app}\app\.git"
Type: filesandordirs; Name: "{app}\app\.vscode"
Type: files; Name: "{app}\app\CLAUDE.md"
Type: files; Name: "{app}\app\CONTRATOS.md"
Type: files; Name: "{app}\app\PLAN.md"
Type: files; Name: "{app}\app\.env.example"

[Run]
; Runtime de WebView2, el motor de la ventana propia del panel
; (src/ventana_app.py): en Windows Server no viene con el sistema. Se corre
; en silencio SOLO si falta (WebView2Ausente lee el registro); sin permisos
; de administrador el bootstrapper instala por usuario. Si fallara, no rompe
; la instalacion: el panel abre igual con Edge (la cadena de respaldo).
Filename: "{app}\webview2\MicrosoftEdgeWebView2Setup.exe"; Parameters: "/silent /install"; StatusMsg: "Instalando WebView2 (motor de la ventana del panel)..."; Check: WebView2Ausente; Flags: waituntilterminated skipifdoesntexist
Filename: "{app}\runtime\python\pythonw.exe"; Parameters: "-m src.lanzador"; WorkingDir: "{app}\app"; Description: "Iniciar el asistente ahora"; Flags: postinstall nowait skipifsilent

[Code]
var
  // Migracion opcional desde una instalacion anterior en esta misma
  // maquina: una casilla (desmarcada por defecto) y, solo si se marca, la
  // pagina de eleccion de carpeta. Se crean en InitializeWizard() y se
  // leen en CurStepChanged(ssPostInstall).
  PaginaPreguntaMigracion: TInputOptionWizardPage;
  PaginaMigracion: TInputDirWizardPage;
  // Ruta al zip de llaves a instalar (llaves_fda.zip). Vacio si el
  // operador confirmo explicitamente que quiere continuar sin llaves.
  ZipLlavesPath: String;

// True si el runtime de WebView2 NO esta instalado ni por maquina ni por
// usuario (claves de registro documentadas por Microsoft: el valor pv de
// EdgeUpdate\Clients\{GUID del runtime}). Solo entonces el [Run] de arriba
// corre el bootstrapper — reinstalar sobre una maquina que ya lo tiene no
// vuelve a bajar nada.
function WebView2Ausente(): Boolean;
var
  Version: String;
begin
  Result := True;
  if RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) and (Version <> '') and (Version <> '0.0.0.0') then
    Result := False
  else if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) and (Version <> '') and (Version <> '0.0.0.0') then
    Result := False
  else if RegQueryStringValue(HKCU, 'Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) and (Version <> '') and (Version <> '0.0.0.0') then
    Result := False;
end;

// Busca llaves_fda.zip junto al instalador. Desde 2026-08-05 el zip es
// OPCIONAL y solo existe para instalaciones antiguas: el instalador ya trae
// la conexion publicable y el resto de las llaves las baja la computadora
// sola, despues de que un administrador la active (CONTRATOS.md 4.7). Por eso
// no encontrarlo NO pregunta nada ni advierte nada: es el camino normal.
procedure BuscarZipLlaves();
var
  RutaJuntoAlSetup: String;
begin
  RutaJuntoAlSetup := AddBackslash(ExpandConstant('{src}')) + 'llaves_fda.zip';
  if FileExists(RutaJuntoAlSetup) then
  begin
    ZipLlavesPath := RutaJuntoAlSetup;
    Log('Zip de llaves encontrado junto al instalador: ' + ZipLlavesPath);
    Exit;
  end;

  ZipLlavesPath := '';
  Log('No hay llaves_fda.zip junto al instalador: se continua sin el. '
      + 'Esta computadora pedira su activacion al abrir el asistente.');
end;

procedure InitializeWizard();
begin
  // Dos paginas y no una: TInputDirWizardPage EXIGE una ruta no vacia al
  // dar Siguiente (validacion propia de Inno), asi que "dejar en blanco
  // para omitir" atascaria al operador justo en el caso comun (laptop
  // nueva, sin nada que migrar). La casilla, desmarcada por defecto, deja
  // pasar de largo; la pagina de carpeta solo aparece si se marca.
  PaginaPreguntaMigracion := CreateInputOptionPage(wpSelectDir,
    '¿Migrar de una instalación anterior?',
    'Solo aplica si esta máquina ya usaba el asistente.',
    'Si en esta máquina ya usabas el asistente (la carpeta con git de antes) y quieres traer sus llaves y su estado, marca la casilla. Si es tu primera instalación, continúa sin marcar nada.',
    False, False);
  PaginaPreguntaMigracion.Add('Traer llaves y estado de una instalación anterior');
  PaginaPreguntaMigracion.Values[0] := False;

  PaginaMigracion := CreateInputDirPage(PaginaPreguntaMigracion.ID,
    'Carpeta de la instalación anterior',
    'Elige la carpeta donde vivía el asistente.',
    'Selecciona la carpeta de la instalación anterior (la que tiene el archivo .env y la carpeta credenciales).',
    False, '');
  PaginaMigracion.Add('Carpeta de la instalación anterior:');
  // Preseleccion editable (pedido del usuario 2026-07-30, hecho 2026-08-05):
  // en blanco, el operador tenia que ubicar a mano una carpeta que casi
  // siempre es la misma (el destino por defecto de todas las instalaciones)
  // — el propio usuario se topo con esa friccion y no la encontro. Se
  // precarga la ruta normal y queda editable para quien de verdad migre
  // desde otro lugar. Es \app y no la carpeta padre porque ahi es donde
  // viven .env y credenciales\, que es lo que migrar_instalacion.py busca.
  PaginaMigracion.Values[0] := ExpandConstant('{localappdata}\FDA\Asistente\app');

  BuscarZipLlaves();
end;

// La pagina de carpeta solo aparece si el operador marco la casilla.
function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := (PaginaMigracion <> nil) and (PageID = PaginaMigracion.ID)
    and not PaginaPreguntaMigracion.Values[0];
end;

// Unica validacion propia: si el operador escribio/eligio una carpeta de
// migracion, que exista de verdad. Vacio es valido (se omite la
// migracion) — el resto de las paginas estandar de Inno se validan solas,
// esta funcion no las toca.
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (PaginaMigracion <> nil) and (CurPageID = PaginaMigracion.ID) then
  begin
    if (PaginaMigracion.Values[0] <> '') and not DirExists(PaginaMigracion.Values[0]) then
    begin
      MsgBox('La carpeta elegida no existe:' + #13#10 + PaginaMigracion.Values[0] + #13#10#13#10 + 'Elige una carpeta válida, o vuelve atrás y desmarca la migración.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;

// Remate por RUTA: mata todo proceso cuyo ejecutable viva bajo la carpeta de
// instalacion. Existe porque el apagado cooperativo solo alcanza al panel: la
// ventana propia (pythonw -m src.ventana_app) es un proceso aparte que
// sobrevive a la muerte del panel y tiene cargados los DLL del runtime — con
// ella viva, reemplazar o borrar runtime\python\* falla con acceso denegado
// (codigo 5, reportado por el usuario 2026-08-06). Ni el instalador ni el
// desinstalador ejecutan desde {app} (el desinstalador corre desde una copia
// en %TEMP%), asi que el filtro por ruta no puede matarse a si mismo.
// Best-effort: si powershell fallara, la instalacion sigue y Windows
// reportara el archivo en uso como hasta ahora.
procedure MatarProcesosBajoApp(Contexto: String);
var
  RutaApp: String;
  Comando: String;
  ResultCode: Integer;
begin
  RutaApp := ExpandConstant('{app}');
  // La ruta va entre comillas simples de PowerShell: si el nombre de usuario
  // trajera un apostrofe, se escapa duplicandolo.
  StringChangeEx(RutaApp, '''', '''''', True);
  Comando := '-NoProfile -Command "'
    + '$p = Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -like ''' + RutaApp + '\*'' }; '
    + '$p | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; '
    + '$p | ForEach-Object { Wait-Process -Id $_.ProcessId -Timeout 10 -ErrorAction SilentlyContinue }"';
  if Exec('powershell.exe', Comando, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    Log(Contexto + ': remate por ruta terminado (codigo ' + IntToStr(ResultCode) + ').')
  else
    Log(Contexto + ': no se pudo correr powershell para el remate por ruta — se sigue igual (best effort).');
end;

// Apagado cooperativo de la instalacion existente (python -m src.lanzador
// --detener). Devuelve True SOLO si el panel contesto "llenado en curso"
// (codigo de salida 3, contrato en src\lanzador.py): en ese caso NADIE debe
// matar nada — un kill dejaria un documento a medias en el programa de
// facturacion. Cualquier otro desenlace (apagado, sin panel, sin archivos
// para intentarlo, --detener viejo que siempre sale 0) devuelve False y el
// llamador sigue con el remate por ruta.
function ApagadoCooperativoDiceLlenado(Contexto: String): Boolean;
var
  RutaLanzadorViejo: String;
  RutaPythonViejo: String;
  ResultCode: Integer;
begin
  Result := False;
  // Se miran las DOS formas a proposito: las instalaciones anteriores a
  // 2026-07-28 traian el codigo fuente (src\lanzador.py) y las nuevas traen
  // solo bytecode (src\lanzador.pyc, ver scripts\build\armar_distribucion.py).
  RutaLanzadorViejo := ExpandConstant('{app}\app\src\lanzador.pyc');
  if not FileExists(RutaLanzadorViejo) then
    RutaLanzadorViejo := ExpandConstant('{app}\app\src\lanzador.py');
  RutaPythonViejo := ExpandConstant('{app}\runtime\python\python.exe');

  if not FileExists(RutaLanzadorViejo) or not FileExists(RutaPythonViejo) then
  begin
    // Pasa en la primera instalacion y tambien tras una desinstalacion a
    // medias (el codigo ya no esta pero el runtime quedo bloqueado por un
    // proceso vivo): sin con que preguntar, se sigue al remate por ruta.
    Log(Contexto + ': sin instalacion completa en ' + ExpandConstant('{app}') + ' — no hay a quien pedirle el apagado cooperativo.');
    Exit;
  end;

  Log(Contexto + ': instalacion anterior detectada — apagado cooperativo (--detener).');
  if Exec(RutaPythonViejo, '-m src.lanzador --detener', ExpandConstant('{app}\app'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    Log(Contexto + ': --detener termino con codigo ' + IntToStr(ResultCode) + '.');
    Result := (ResultCode = 3);
  end
  else
    Log(Contexto + ': no se pudo ejecutar --detener — se sigue con el remate por ruta.');
end;

// Antes de copiar archivos: apagar TODO lo que corra desde la instalacion
// existente — primero por las buenas (--detener, que respeta un llenado en
// curso) y despues por ruta (la ventana propia y cualquier zombi que el
// cooperativo no alcanza). Sin esto, [Files] falla al pisar un .dll en uso.
function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  if ApagadoCooperativoDiceLlenado('PrepareToInstall') then
  begin
    Result := 'El asistente está a mitad de un llenado en el programa de facturación y no se puede cerrar ahora. Espera a que ese documento termine y vuelve a ejecutar el instalador.';
    Exit;
  end;
  MatarProcesosBajoApp('PrepareToInstall');
end;

// Al desinstalar, el mismo cierre que al instalar. Sin esto, desinstalar con
// el asistente abierto dejaba runtime\python\* bloqueado (carpetas que "no se
// dejan borrar") y ademas el panel seguia corriendo en memoria ya sin
// archivos, que es justo el estado que despues hacia fallar la reinstalacion.
function InitializeUninstall(): Boolean;
begin
  Result := True;
  if ApagadoCooperativoDiceLlenado('Desinstalacion') then
  begin
    MsgBox('El asistente está a mitad de un llenado en el programa de facturación y no se puede cerrar ahora.' + #13#10#13#10 + 'Espera a que ese documento termine y vuelve a desinstalar.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  MatarProcesosBajoApp('Desinstalacion');
end;

// Corre migracion (si se eligio carpeta) y luego llaves (si hubo zip),
// EN ESE ORDEN: la migracion puede traer un .env/estado viejo que las
// llaves nuevas deben poder pisar despues si corresponde. Cualquier fallo
// se avisa con un MsgBox accionable — nunca en silencio, porque el
// operador no tiene forma de saber que algo quedo a medias si no se le
// dice.
procedure CorrerPasoPostInstalacion(RutaPython, Parametros, NombrePaso, RutaLog: String);
var
  ResultCode: Integer;
begin
  Log('Post-instalacion: ' + NombrePaso + ' -> ' + RutaPython + ' ' + Parametros);
  if not Exec(RutaPython, Parametros, ExpandConstant('{app}\app'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    MsgBox('No se pudo iniciar el paso "' + NombrePaso + '" de la instalación.' + #13#10#13#10 + 'Revisa el log en:' + #13#10 + RutaLog, mbError, MB_OK);
    Exit;
  end;
  if ResultCode <> 0 then
  begin
    MsgBox('El paso "' + NombrePaso + '" de la instalación falló (código ' + IntToStr(ResultCode) + ').' + #13#10#13#10 + 'Revisa el log en:' + #13#10 + RutaLog, mbError, MB_OK);
    Exit;
  end;
  Log('Post-instalacion: ' + NombrePaso + ' termino OK.');
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  RutaPython: String;
  RutaLog: String;
  RutaOrigenMigracion: String;
  Parametros: String;
begin
  if CurStep <> ssPostInstall then
    Exit;

  RutaPython := ExpandConstant('{app}\runtime\python\python.exe');
  RutaLog := ExpandConstant('{app}\app\logs\instalacion.log');

  // 1) Migracion de una instalacion anterior, si el operador la marco y
  // eligio carpeta.
  RutaOrigenMigracion := '';
  if PaginaPreguntaMigracion.Values[0] then
    RutaOrigenMigracion := PaginaMigracion.Values[0];
  // Origen = destino: pasa cuando se reinstala sobre la carpeta de siempre y
  // el operador deja la preseleccion marcada. No hay nada que migrar (esos
  // archivos ya estan donde deben, y [InstallDelete] no los toca) y copiarlos
  // sobre si mismos abortaria el paso con un error que no significa nada.
  if (RutaOrigenMigracion <> '')
     and (CompareText(RemoveBackslashUnlessRoot(RutaOrigenMigracion),
                      RemoveBackslashUnlessRoot(ExpandConstant('{app}\app'))) = 0) then
  begin
    Log('Post-instalacion: la carpeta de migracion es la misma que se acaba de instalar — no hay nada que traer, se omite.');
    RutaOrigenMigracion := '';
  end;
  if RutaOrigenMigracion <> '' then
  begin
    Parametros := 'scripts\build\migrar_instalacion.pyc --origen "' + RutaOrigenMigracion + '" --app "' + ExpandConstant('{app}\app') + '"';
    CorrerPasoPostInstalacion(RutaPython, Parametros, 'migrar instalación anterior', RutaLog);
  end
  else
    Log('Post-instalacion: sin carpeta de migracion elegida — se omite ese paso.');

  // 2) Llaves, si hubo zip (encontrado junto al instalador, elegido a
  // mano, o ninguno si el operador confirmo continuar sin llaves).
  if ZipLlavesPath <> '' then
  begin
    Parametros := 'scripts\build\instalar_llaves.pyc --zip "' + ZipLlavesPath + '" --app "' + ExpandConstant('{app}\app') + '"';
    CorrerPasoPostInstalacion(RutaPython, Parametros, 'instalar llaves', RutaLog);
  end
  else
    Log('Post-instalacion: sin zip de llaves — se omite ese paso (el operador confirmo continuar sin llaves).');
end;
