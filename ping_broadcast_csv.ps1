# Configura la dirección de broadcast en esta variable
$broadcastIP = "192.168.1.255"

# Nombre del archivo de salida en formato CSV
$outputFile = "respuestas_ping.csv"

# Encabezados del archivo CSV
$csvHeader = "IP,Hostname"
$csvHeader | Out-File -FilePath $outputFile

# Realiza el ping a la dirección de broadcast
$respuestas = Test-Connection -ComputerName $broadcastIP -Count 1 -ErrorAction SilentlyContinue

# Procesa las respuestas
$respuestas | ForEach-Object {
    if ($_.StatusCode -eq 0) {
        $ip = $_.Address
        # Obtiene el nombre del equipo (hostname) a partir de la IP
        $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        # Guarda la IP y el hostname en el archivo CSV
        "$ip,$hostname" | Out-File -FilePath $outputFile -Append
    }
}

Write-Host "Las IPs y nombres de equipo que respondieron se han guardado en $outputFile"