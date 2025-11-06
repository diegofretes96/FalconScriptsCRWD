# Ruta predefinida de la carpeta a gestionar (modifícala según sea necesario)
$folderPath = "C:\RUTA\DE\LA\CARPETA"

# Mostrar la ruta de la carpeta
Write-Host "La carpeta predefinida es: $folderPath"

# Verificar si la carpeta existe
if (Test-Path -Path $folderPath) {
    Write-Host "La carpeta existe: $folderPath. Intentando eliminar..."

    try {
        # Intentar eliminar la carpeta completa
        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
        Write-Host "La carpeta y su contenido han sido eliminados exitosamente." -ForegroundColor Green
    } catch {
        # Si no se puede eliminar la carpeta, eliminar solo su contenido
        Write-Host "No se pudo eliminar la carpeta completa. Eliminando su contenido..." -ForegroundColor Yellow

        try {
            Get-ChildItem -Path $folderPath -Recurse | Remove-Item -Recurse -Force
            Write-Host "El contenido de la carpeta ha sido eliminado exitosamente." -ForegroundColor Green
        } catch {
            Write-Host "Ocurrió un error al intentar eliminar el contenido de la carpeta: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "La carpeta no existe: $folderPath" -ForegroundColor Red
}
