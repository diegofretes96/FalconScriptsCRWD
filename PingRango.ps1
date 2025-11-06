<#
.SYNOPSIS
    Realiza ping a un rango de direcciones IP predefinido en el script y guarda los resultados.
.DESCRIPTION
    Este script realiza ping a todas las direcciones IP en el rango especificado dentro del código
    y registra el nombre y la IP de los equipos que responden al ping en un archivo de texto.
.NOTES
    Modifica las variables $StartIP y $EndIP dentro del script para cambiar el rango a escanear.
.EXAMPLE
    .\ping_equipos_editabledirecto.ps1
#>

# ===== CONFIGURACIÓN EDITABLE =====
$StartIP = "192.168.0.1"   # Cambia esta IP por la inicial de tu rango
$EndIP = "192.168.0.254"   # Cambia esta IP por la final de tu rango
$OutputFile = "equipos_activos.txt"  # Puedes cambiar el nombre del archivo de salida
$PingTimeout = 100         # Tiempo de espera del ping en milisegundos (opcional)
# ===== FIN DE CONFIGURACIÓN =====

function ConvertIP-ToInt64 ($ip) {
    $octets = $ip -split '\.'
    return [int64]([int64]$octets[0] * 16777216 + [int64]$octets[1] * 65536 + [int64]$octets[2] * 256 + [int64]$octets[3])
}

function ConvertInt64-ToIP ([int64]$int) {
    return "$(($int -band 0xFF000000) -shr 24).$(($int -band 0x00FF0000) -shr 16).$(($int -band 0x0000FF00) -shr 8).$(($int -band 0x000000FF))"
}

function Get-HostnameFromIP ($ip) {
    try {
        $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        return $hostname
    } catch {
        return "No disponible"
    }
}

# Convertir las IPs a números enteros
$startInt = ConvertIP-ToInt64 $StartIP
$endInt = ConvertIP-ToInt64 $EndIP

# Verificar que el rango sea válido
if ($startInt -gt $endInt) {
    Write-Host "Error: La dirección IP inicial debe ser menor que la dirección IP final." -ForegroundColor Red
    exit
}

# Mostrar configuración que se usará
Write-Host "`nConfiguración del escaneo:" -ForegroundColor Yellow
Write-Host " - Rango de IPs: $StartIP a $EndIP"
Write-Host " - Archivo de salida: $OutputFile"
Write-Host " - Timeout de ping: $PingTimeout ms`n"

# Crear o sobrescribir el archivo de salida
"Listado de equipos activos - $(Get-Date)" | Out-File -FilePath $OutputFile
"====================================" | Out-File -FilePath $OutputFile -Append
"IP`t`tNombre del equipo" | Out-File -FilePath $OutputFile -Append
"------------------------------------" | Out-File -FilePath $OutputFile -Append

$totalIPs = $endInt - $startInt + 1
$current = 0

# Recorrer el rango de IPs
for ($i = $startInt; $i -le $endInt; $i++) {
    $current++
    $ip = ConvertInt64-ToIP $i
    $progress = ($current / $totalIPs) * 100
    Write-Progress -Activity "Escaneando red" -Status "Procesando $ip" -PercentComplete $progress
    
    # Realizar ping con el timeout configurado
    $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutMilliseconds $PingTimeout -ErrorAction SilentlyContinue
    
    if ($ping) {
        $hostname = Get-HostnameFromIP $ip
        "$ip`t$hostname" | Out-File -FilePath $OutputFile -Append
        Write-Host "Equipo activo encontrado: $ip ($hostname)" -ForegroundColor Green
    }
}

Write-Host "`nEscaneo completado. Resultados guardados en $OutputFile" -ForegroundColor Cyan