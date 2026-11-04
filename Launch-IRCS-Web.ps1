# IRCS Windows Utility web launcher, pinned to release v1.6.1.
# Host this file as Launch-IRCS.ps1 in the public GitHub repository.
$ErrorActionPreference = 'Stop'
$releaseUrl = 'https://github.com/cjrich772/IRCS-Windows-Utility/releases/download/v1.6.1/IRCS-Windows-Utility-v1.6.1-Dark-Mode-Fix.zip'
$expectedSha256 = '02EF0EC05C0CDFED095373BB359CF681F936ED61B33DFC2EE6E03AA8294527B8'
$base = Join-Path $env:LOCALAPPDATA 'IRCS\WindowsUtility\v1.6.1'
$zip = Join-Path $env:TEMP 'IRCS-Windows-Utility-v1.6.1.zip'
try {
    if (-not [Environment]::Is64BitOperatingSystem) { throw 'A 64-bit Windows system is required.' }
    New-Item -ItemType Directory -Force -Path $base | Out-Null
    Write-Host 'Downloading IRCS Windows Utility v1.6.1...'
    Invoke-WebRequest -Uri $releaseUrl -OutFile $zip -UseBasicParsing
    $actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
    if ($actual -ne $expectedSha256) { throw "Checksum mismatch. Download rejected. Actual: $actual" }
    Write-Host 'Checksum verified. Extracting...'
    $stage = Join-Path $base 'staging'
    if (Test-Path $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
    New-Item -ItemType Directory -Path $stage | Out-Null
    Expand-Archive -LiteralPath $zip -DestinationPath $stage -Force
    $cmd = Join-Path $stage 'IRCS-Windows-Utility\Launch IRCS Utility.cmd'
    if (-not (Test-Path -LiteralPath $cmd)) { throw 'Expected launcher missing from verified archive.' }
    Write-Host 'Starting IRCS Windows Utility...'
    Start-Process -FilePath $cmd -WorkingDirectory (Split-Path $cmd -Parent)
} catch {
    Write-Host ('IRCS launcher error: ' + $_.Exception.Message) -ForegroundColor Red
    throw
} finally {
    Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
}
