@echo off
setlocal

REM ==== Montar unidad de red ====
net use Z: "\\Carpeta\carpeta\FALCON" /user:UsuarioContraseña P@ssw0rd
if errorlevel 1 (
    echo Error: No se pudo conectar al recurso compartido.
    pause
    exit /b
)

REM ==== Crear carpeta destino local ====
if not exist "C:\CrowdStrike" mkdir "C:\CrowdStrike"

REM ==== Copiar instalador ====
copy "Z:\FalconSensor_Windows_XXXXXXXXXXXXXXXX2.exe" "C:\CrowdStrike\" /Y
if errorlevel 1 (
    echo Error copiando el instalador.
    net use Z: /delete
    pause
    exit /b
)

REM ==== Ejecutar instalador ====
"C:\CrowdStrike\FalconSensor_Windows_xxxxxxxxxxxxxxx-22.exe" /install /quiet /norestart ProvNoWait=1
if errorlevel 1 (
    echo Error en la instalación.
    net use Z: /delete
    pause
    exit /b
)

REM ==== Desmontar unidad de red ====
net use Z: /delete

echo Instalación completada correctamente.
pause
