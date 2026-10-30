$ErrorActionPreference = "Stop"
$url = "https://raw.githubusercontent.com/drastone/goldengate-labkit/main/wsl-compatibility.json"
$info = Invoke-RestMethod $url
$distro = [string]$info.distribution

if ($info.status -ne "supported" -or $distro -notmatch '^OracleLinux_[0-9]+_[0-9]+$') {
    throw "No validated WSL distribution is available."
}

Write-Host "Validated distribution: $distro"
Write-Host "Validated OS version: $($info.osVersion)"
Write-Host "Command to run: wsl.exe --install -d $distro"
if ((Read-Host "Run this command? [Y/N]") -notmatch '^(Y|YES)$') {
    Write-Host "Installation canceled."
    exit 0
}

wsl.exe --install -d $distro
if ($LASTEXITCODE -ne 0) {
    throw "WSL rejected the installation request with exit code $LASTEXITCODE."
}
