# Ruta predefinida de la carpeta AppData
$folderPath = "$env:USERPROFILE\AppData"

# Credenciales del administrador local
$adminUsername = "AdministradorLocal"  # Reemplaza con el usuario administrador local
$adminPassword = ConvertTo-SecureString "ContraseñaDelAdmin" -AsPlainText -Force  # Reemplaza con la contraseña del administrador local
$adminCredential = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)

# Función para detener procesos que bloquean archivos o carpetas
function Stop-LockingProcesses {
    param (
        [string]$Path
    )
    
    try {
        # Obtener procesos que bloquean la ruta (requiere Handle.exe de Sysinternals)
        $handles = &"C:\Path\To\Handle.exe" $Path 2>&1 | Where-Object { $_ -match 'pid:' }
        
        foreach ($handle in $handles) {
            # Extraer el PID del proceso
            if ($handle -match 'pid: (\d+)') {
                $pid = $matches[1]
                # Detener el proceso
                Start-Process -Credential $adminCredential powershell -ArgumentList "Stop-Process -Id $pid -Force" -NoNewWindow -Wait
                Write-Host "Se detuvo el proceso con PID: $pid" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "No se pudieron identificar procesos que bloqueen: $_" -ForegroundColor Red
    }
}

# Mostrar la ruta de la carpeta
Write-Host "La carpeta predefinida es: $folderPath"

# Verificar si la carpeta existe
if (Test-Path -Path $folderPath) {
    Write-Host "La carpeta existe: $folderPath. Intentando eliminar..."
    
    try {
        # Intentar eliminar la carpeta completa con privilegios elevados
        Start-Process -Credential $adminCredential powershell -ArgumentList "Remove-Item -Path `"$folderPath`" -Recurse -Force" -NoNewWindow -Wait
        Write-Host "La carpeta AppData y su contenido han sido eliminados exitosamente." -ForegroundColor Green
    } catch {
        Write-Host "No se pudo eliminar la carpeta completa. Deteniendo procesos que puedan bloquearla..." -ForegroundColor Yellow
        
        # Llamar a la función para detener procesos bloqueantes
        Stop-LockingProcesses -Path $folderPath

        # Intentar eliminar de nuevo
        try {
            Start-Process -Credential $adminCredential powershell -ArgumentList "Remove-Item -Path `"$folderPath`" -Recurse -Force" -NoNewWindow -Wait
            Write-Host "La carpeta AppData y su contenido han sido eliminados exitosamente." -ForegroundColor Green
        } catch {
            Write-Host "No se pudo eliminar la carpeta después de detener procesos: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "La carpeta no existe: $folderPath" -ForegroundColor Red
}
