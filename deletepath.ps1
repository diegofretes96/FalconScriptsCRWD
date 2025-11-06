# Ruta predefinida de la carpeta a eliminar (modifícala según sea necesario)
$folderPath = "C:\RUTA\DE\LA\CARPETA"

# Mostrar la ruta de la carpeta a eliminar
Write-Host "La carpeta predefinida es: $folderPath"

# Verificar si la carpeta existe
if (Test-Path -Path $folderPath) {
    Write-Host "La carpeta existe: $folderPath"
    
    # Confirmación antes de eliminar
    $confirm = Read-Host "¿Está seguro de que desea eliminar esta carpeta? (S/N)"
    
    if ($confirm -eq "S" -or $confirm -eq "s") {
        try {
            # Eliminar la carpeta y su contenido
            Remove-Item -Path $folderPath -Recurse -Force
            Write-Host "La carpeta ha sido eliminada exitosamente." -ForegroundColor Green
        } catch {
            Write-Host "Ocurrió un error al intentar eliminar la carpeta: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Operación cancelada por el usuario." -ForegroundColor Yellow
    }
} else {
    Write-Host "La carpeta no existe: $folderPath" -ForegroundColor Red
}
