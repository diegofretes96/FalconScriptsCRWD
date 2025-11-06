# Configura la dirección de broadcast en esta variable
$broadcastIP = "192.168.220.255"

# Nombre del archivo de salida
$outputFile = "respuestas_ping.txt"

# Realiza el ping a la dirección de broadcast
$respuestas = Test-Connection -ComputerName $broadcastIP -Count 1 -ErrorAction SilentlyContinue

# Filtra las IPs que respondieron y las guarda en un archivo
$respuestas | ForEach-Object {
    if ($_.StatusCode -eq 0) {
        $_.Address | Out-File -FilePath $outputFile -Append
    }
}

Write-Host "Las IPs que respondieron se han guardado en $outputFile"