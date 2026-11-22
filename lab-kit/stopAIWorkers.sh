#!/usr/bin/env bash
set -eu

# Stop optional OCI AI/APEX worker timers after the OCI AI labs, or before
# ordinary GoldenGate, Kafka, and OSA labs.

AI_WORKER_UNITS="${AI_WORKER_UNITS:-claims-aidp-worker.timer new-business-aidp-worker.timer call-center-oci-speech-worker.timer}"

if ! command -v systemctl >/dev/null 2>&1; then
  echo "ERROR: systemctl not found. AI workers are managed by systemd timers."
  exit 1
fi

existing_units=()
for unit in ${AI_WORKER_UNITS}; do
  if systemctl cat "${unit}" >/dev/null 2>&1; then
    existing_units+=("${unit}")
  else
    echo "INFO: optional AI worker timer not installed: ${unit}"
  fi
done

if [ "${#existing_units[@]}" -eq 0 ]; then
  echo "INFO: no optional AI worker timers are installed."
  exit 0
fi

echo "Stop optional OCI AI worker timers"
printf '  %s\n' "${existing_units[@]}"

sudo systemctl disable --now "${existing_units[@]}"
systemctl list-timers "${existing_units[@]}" --all --no-pager || true

