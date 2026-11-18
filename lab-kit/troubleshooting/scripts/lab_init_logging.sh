#!/usr/bin/env bash

# Shared runtime logging for reader-facing lab initialization entry points.

lab_init_log_timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

lab_init_log_elapsed() {
  local seconds=$(( $(date +%s) - LAB_INIT_LOG_STARTED_AT ))
  printf '%02d:%02d:%02d' $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
}

lab_init_log() {
  printf '[%s] %s\n' "$(lab_init_log_timestamp)" "$*"
}

lab_init_log_on_exit() {
  local rc="$1"

  trap - EXIT ERR HUP INT TERM
  if [ "${LAB_INIT_LOG_COMPLETED:-N}" != "Y" ] && [ "${LAB_INIT_LOG_SIGNALLED:-N}" != "Y" ]; then
    lab_init_log "ERROR: ${LAB_INIT_LOG_STAGE} stopped with exit code ${rc}."
    lab_init_log "ERROR: elapsed time: $(lab_init_log_elapsed)"
    lab_init_log "ERROR: review log: ${LAB_INIT_LOG_FILE}"
  fi
}

lab_init_log_on_signal() {
  local signal_name="$1"
  local rc="$2"

  LAB_INIT_LOG_SIGNALLED=Y
  trap - EXIT ERR HUP INT TERM
  lab_init_log "ERROR: ${LAB_INIT_LOG_STAGE} was interrupted by ${signal_name}."
  lab_init_log "ERROR: elapsed time: $(lab_init_log_elapsed)"
  lab_init_log "ERROR: review log: ${LAB_INIT_LOG_FILE}"
  exit "${rc}"
}

lab_init_log_begin() {
  local lab_name="$1"
  local stage_name="$2"
  local lab_home="${LAB_HOME:-/home/oracle}"

  LAB_INIT_LOG_STAGE="${stage_name}"
  LAB_INIT_LOG_STARTED_AT="$(date +%s)"
  LAB_INIT_LOG_COMPLETED=N
  LAB_INIT_LOG_SIGNALLED=N
  LAB_INIT_LOG_DIR="${LAB_INIT_LOG_DIR:-${lab_home}/logs/${lab_name}}"
  LAB_INIT_LOG_FILE="${LAB_INIT_LOG_FILE:-${LAB_INIT_LOG_DIR}/$(date '+%Y%m%d-%H%M%S')-${stage_name}.log}"

  mkdir -p "${LAB_INIT_LOG_DIR}"
  ln -sfn "$(basename "${LAB_INIT_LOG_FILE}")" "${LAB_INIT_LOG_DIR}/latest.log"
  exec > >(tee -a "${LAB_INIT_LOG_FILE}") 2>&1

  trap 'lab_init_log_on_exit $?' EXIT
  trap 'lab_init_log_on_signal SIGHUP 129' HUP
  trap 'lab_init_log_on_signal SIGINT 130' INT
  trap 'lab_init_log_on_signal SIGTERM 143' TERM

  lab_init_log "==> START: ${LAB_INIT_LOG_STAGE}"
  lab_init_log "INFO: log file: ${LAB_INIT_LOG_FILE}"
}

lab_init_log_finish() {
  LAB_INIT_LOG_COMPLETED=Y
  trap - EXIT ERR HUP INT TERM
  lab_init_log "OK: ${LAB_INIT_LOG_STAGE} completed."
  lab_init_log "OK: elapsed time: $(lab_init_log_elapsed)"
  lab_init_log "OK: log file: ${LAB_INIT_LOG_FILE}"
}
