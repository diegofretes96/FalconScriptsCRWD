# Define la ruta del registro donde se encuentran las entradas de los programas instalados
$uninstallPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\"
$uninstallPath32 = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"

# Inicializa una lista para almacenar los resultados
$programsList = @()

# Función para obtener los programas de una ruta de registro específica
function Get-ProgramsFromRegistry($registryPath) {
    Get-ChildItem -Path $registryPath | ForEach-Object {
        $program = Get-ItemProperty $_.PSPath
        if ($program.DisplayName) {
            $programInfo = [PSCustomObject]@{
                Name = $program.DisplayName
                UninstallID = $program.PSChildName
            }
            $programsList += $programInfo
        }
    }
}

# Obtener los programas de ambas rutas de registro (64 bits y 32 bits)
Get-ProgramsFromRegistry $uninstallPath
Get-ProgramsFromRegistry $uninstallPath32

# Mostrar la lista de programas con sus IDs de desinstalación
$programsList | Format-Table -AutoSize

# Opcional: Exportar la lista a un archivo CSV
$programsList | Export-Csv -Path "ProgramsList.csv" -NoTypeInformation

Write-Host "La lista de programas se ha exportado a 'ProgramsList.csv'"