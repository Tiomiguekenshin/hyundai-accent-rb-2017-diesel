# Respaldo de inventario K2001N (solo lectura)
# Requiere Windows PowerShell y Android Platform Tools (adb) instalado.
# No modifica firmware, MCU, CANBUS, HOME ni particiones.

$ErrorActionPreference = "Stop"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$out = Join-Path (Get-Location) "K2001N-backup-$stamp"
New-Item -ItemType Directory -Path $out | Out-Null

function Save-AdbOutput($remoteCommand, $fileName) {
    & adb shell $remoteCommand 2>&1 | Out-File -FilePath (Join-Path $out $fileName) -Encoding utf8
}

Write-Host "Comprobando ADB..."
$devices = & adb devices
$devices | Out-File (Join-Path $out "adb-devices.txt") -Encoding utf8
if (-not ($devices | Select-String "\tdevice$")) {
    throw "No hay dispositivo ADB autorizado. Revisa Depuracion USB y acepta la huella RSA en la radio."
}

Save-AdbOutput "getprop" "getprop.txt"
Save-AdbOutput "wm size" "display-size.txt"
Save-AdbOutput "wm density" "display-density.txt"
Save-AdbOutput "cat /proc/cpuinfo" "cpuinfo.txt"
Save-AdbOutput "df -h" "storage.txt"
Save-AdbOutput "pm list packages -3" "third-party-packages.txt"
Save-AdbOutput "pm list packages -s" "system-packages.txt"
Save-AdbOutput "dumpsys package" "package-dump.txt"
Save-AdbOutput "dumpsys activity activities" "activities.txt"
Save-AdbOutput "dumpsys window" "window.txt"
Save-AdbOutput "settings get secure enabled_accessibility_services" "accessibility-services.txt"

$homeOutput = & adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME 2>&1
$homeOutput | Out-File (Join-Path $out "current-home.txt") -Encoding utf8
$component = $homeOutput | Select-String "/" | Select-Object -Last 1
if ($component) {
    $packageName = ($component.Line.Trim() -split "/")[0]
    "HOME package: $packageName" | Out-File (Join-Path $out "home-package.txt") -Encoding utf8
    $apkPaths = & adb shell pm path $packageName 2>&1
    $apkPaths | Out-File (Join-Path $out "home-apk-paths.txt") -Encoding utf8
    foreach ($line in $apkPaths) {
        if ($line -match "^package:(.+)$") {
            $remotePath = $Matches[1].Trim()
            & adb pull $remotePath $out
        }
    }
} else {
    "No se pudo resolver automáticamente el launcher HOME. Consultar current-home.txt." |
        Out-File (Join-Path $out "home-apk-note.txt") -Encoding utf8
}

Get-ChildItem $out -File | Get-FileHash -Algorithm SHA256 |
    Format-Table -AutoSize | Out-File (Join-Path $out "SHA256SUMS.txt") -Encoding utf8

Write-Host ""
Write-Host "Inventario guardado en: $out"
Write-Host "IMPORTANTE: esto no es una imagen completa del firmware ni respalda datos privados de apps."
Write-Host "No cambies HOME ni instales el launcher hasta revisar este respaldo."
