$emulatorZipUrl = "https://github.com/snes9xgit/snes9x/releases/download/1.63/snes9x-1.63-win32-x64.zip"
$romZipUrl = "https://myrient.erista.me/files/No-Intro/Nintendo%20-%20Super%20Nintendo%20Entertainment%20System/NBA%20Jam%20%28USA%29.zip"

$D = "$env:TEMP\Snes9xSetup"
$emulatorZipPath = Join-Path $D "snes9x.zip"
$romZipPath = Join-Path $D "NBA_Jam.zip"
$emulatorExtractPath = Join-Path $D "Snes9x"
$romExtractPath = Join-Path $D "NBA_Jam"

if (-not (Test-Path -Path $D)) {
    New-Item -ItemType Directory -Path $D
}

Invoke-WebRequest -Uri $emulatorZipUrl -OutFile $emulatorZipPath

Invoke-WebRequest -Uri $romZipUrl -OutFile $romZipPath

if (-not (Test-Path -Path $emulatorExtractPath)) {
    New-Item -ItemType Directory -Path $emulatorExtractPath
}

if (-not (Test-Path -Path $romExtractPath)) {
    New-Item -ItemType Directory -Path $romExtractPath
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path -Path $emulatorExtractPath) {
    Remove-Item -Path $emulatorExtractPath\* -Force
}
[System.IO.Compression.ZipFile]::ExtractToDirectory($emulatorZipPath, $emulatorExtractPath)

if (Test-Path -Path $romExtractPath) {
    Remove-Item -Path $romExtractPath\* -Force
}
[System.IO.Compression.ZipFile]::ExtractToDirectory($romZipPath, $romExtractPath)

$emulatorExe = Get-ChildItem -Path $emulatorExtractPath -Filter "*.exe" -Recurse | Select-Object -First 1

$romFile = Get-ChildItem -Path $romExtractPath -Recurse | Where-Object {
    $_.Extension -eq ".smc" -or $_.Extension -eq ".sfc"
} | Select-Object -First 1

if ($emulatorExe -and $romFile) {
    Start-Process -FilePath $emulatorExe.FullName -ArgumentList "`"$($romFile.FullName)`"" -Wait

    Remove-Item -Path $emulatorZipPath -Force
    Remove-Item -Path $romZipPath -Force
    Remove-Item -Path $emulatorExtractPath -Recurse -Force
    Remove-Item -Path $romExtractPath -Recurse -Force
}

