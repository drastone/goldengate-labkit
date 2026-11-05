#!/usr/bin/env bash

set -Eeuo pipefail

SOURCE_FILE="${SOURCE_FILE:-/home/oracle/oracle/pkg/f101_ogg_console.sql}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [ ! -f "${SOURCE_FILE}" ]; then
  log "ERROR: App 101 export file was not found: ${SOURCE_FILE}"
  exit 1
fi

POWERSHELL_EXE="$(command -v powershell.exe 2>/dev/null || true)"
if [ -z "${POWERSHELL_EXE}" ] && [ -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]; then
  POWERSHELL_EXE=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
fi

if [ -z "${POWERSHELL_EXE}" ] || ! command -v wslpath >/dev/null 2>&1; then
  log "ERROR: Windows interop commands PowerShell and wslpath are required."
  log "ERROR: run this script from the reader WSL Base Linux environment."
  exit 1
fi

windows_downloads="$("${POWERSHELL_EXE}" -NoProfile -Command \
  "(New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path" \
  2>/dev/null | tr -d '\r' | sed -n '/./{p;q;}' || true)"

if [ -z "${windows_downloads}" ]; then
  windows_profile="$("${POWERSHELL_EXE}" -NoProfile -Command \
    "[Environment]::GetFolderPath('UserProfile')" \
    | tr -d '\r' | sed -n '/./{p;q;}')"
  windows_downloads="${windows_profile}\\Downloads"
fi

downloads_dir="$(wslpath -u "${windows_downloads}")"
if [ ! -d "${downloads_dir}" ]; then
  log "ERROR: Windows Downloads directory was not found: ${downloads_dir}"
  exit 1
fi

target_file="${downloads_dir}/$(basename "${SOURCE_FILE}")"
cp -f "${SOURCE_FILE}" "${target_file}"

log "OK: App 101 export copied to Windows Downloads."
log "OK: ${target_file}"
ls -lh "${target_file}"
