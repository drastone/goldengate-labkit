$ErrorActionPreference = "Stop"
$url = "https://raw.githubusercontent.com/drastone/goldengate-labkit/main/wsl-compatibility.json"
$info = Invoke-RestMethod $url
$distro = [string]$info.distribution

if ($info.status -ne "supported" -or $distro -notmatch '^OracleLinux_[0-9]+_[0-9]+$') {
    throw "No validated WSL distribution is available."
}

Write-Host "Validated distribution: $distro"
$catalog = wsl.exe --list --online
if ($LASTEXITCODE -ne 0 -or -not ($catalog | Select-String -SimpleMatch $distro -Quiet)) {
    throw "$distro is not available in the Microsoft WSL catalog."
}

Write-Host "Microsoft WSL catalog check: OK"
Write-Host "Command to run: wsl.exe --install -d $distro"
if ((Read-Host "Run this command? [Y/N]") -notmatch '^(Y|YES)$') {
    Write-Host "Installation canceled."
    exit 0
}

wsl.exe --install -d $distro
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
