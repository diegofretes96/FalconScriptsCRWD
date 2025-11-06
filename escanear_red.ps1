# Configura la dirección de red y la máscara de subred
$networkIP = "192.168.1"  # Cambia esto según tu red
$subnetMask = 24          # Cambia esto según tu máscara de subred

# Nombre del archivo de salida en formato CSV
$outputFile = "equipos_red.csv"

# Encabezados del archivo CSV
$csvHeader = "IP,Hostname"
$csvHeader | Out-File -FilePath $outputFile

# Función para calcular el rango de IPs en la subred
function Get-SubnetRange {
    param (
        [string]$networkIP,
        [int]$subnetMask
    )
    $ipBytes = ($networkIP -split '\.') | ForEach-Object { [byte]$_ }
    $hostBits = 32 - $subnetMask
    $numHosts = [math]::Pow(2, $hostBits) - 2
    $startIP = ($ipBytes[0] -shl 24) + ($ipBytes[1] -shl 16) + ($ipBytes[2] -shl 8) + $ipBytes[3]
    $startIP++  # Ignorar la dirección de red
    $endIP = $startIP + $numHosts - 1

    for ($i = $startIP; $i -le $endIP; $i++) {
        $ip = [System.Net.IPAddress]::Parse($i).ToString()
        $ip
    }
}

# Obtiene el rango de IPs en la subred
$ipRange = Get-SubnetRange -networkIP $networkIP -subnetMask $subnetMask

# Realiza ping a cada IP en el rango y obtiene el hostname
foreach ($ip in $ipRange) {
    Write-Host "Probando IP: $ip"
    $respuesta = Test-Connection -ComputerName $ip -Count 1 -ErrorAction SilentlyContinue
    if ($respuesta -and $respuesta.StatusCode -eq 0) {
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        } catch {
            $hostname = "Desconocido"
        }
        # Guarda la IP y el hostname en el archivo CSV
        "$ip,$hostname" | Out-File -FilePath $outputFile -Append
        Write-Host "Equipo encontrado: $ip -> $hostname"
    }
}

Write-Host "El escaneo ha finalizado. Los resultados se han guardado en $outputFile"