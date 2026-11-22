#!/bin/sh
set -eu

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "$0")" && pwd)}"
OSA_ROOT="${OSA_ROOT:-${LAB_HOME}/oracle/script/osa}"
OSA_CONTAINERS="${OSA_CONTAINERS:-demo_osrc_23ai demo_otrg_23ai}"

cleanup_host_files() {
  [ -d "${OSA_ROOT}" ] || return 0

  file_count="$(find "${OSA_ROOT}" -maxdepth 1 -type f | wc -l)"
  if [ "${file_count}" -eq 0 ]; then
    echo "OK: OSA scripts are already isolated under ${OSA_ROOT}/23ai."
    return 0
  fi

  timestamp="$(date +%Y%m%d_%H%M%S)"
  backup_dir="${LAB_HOME}/backup/legacy-osa-root-${timestamp}"
  mkdir -p "${backup_dir}"
  (
    cd "${OSA_ROOT}"
    find . -maxdepth 1 -type f -printf '%P\n' | sort > "${backup_dir}/files.txt"
    tar -czf "${backup_dir}/files.tar.gz" -T "${backup_dir}/files.txt"
    find . -maxdepth 1 -type f -delete
  )
  echo "OK: Removed ${file_count} legacy OSA root files after backup: ${backup_dir}"
}

cleanup_retired_23ai_files() {
  retired_root="${OSA_ROOT}/23ai"
  retired_files="prepare_ai_26ai_objects.sh prepare_ai_26ai_objects.sql show_ai_26ai_care_detail.sql"
  existing_files=""

  [ -d "${retired_root}" ] || return 0
  for file_name in ${retired_files}; do
    if [ -f "${retired_root}/${file_name}" ]; then
      existing_files="${existing_files} ${file_name}"
    fi
  done
  [ -n "${existing_files}" ] || {
    echo "OK: retired Source-side 26ai helpers are absent."
    return 0
  }

  timestamp="$(date +%Y%m%d_%H%M%S)"
  backup_dir="${LAB_HOME}/backup/retired-osa-23ai-${timestamp}"
  mkdir -p "${backup_dir}"
  (
    cd "${retired_root}"
    tar -czf "${backup_dir}/files.tar.gz" ${existing_files}
    rm -f ${existing_files}
  )
  echo "OK: removed retired Source-side 26ai helpers after backup: ${backup_dir}"
}

cleanup_container_files() {
  command -v docker >/dev/null 2>&1 || return 0

  for container in ${OSA_CONTAINERS}; do
    [ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null || true)" = "true" ] || continue
    removed="$(docker exec "${container}" sh -lc '
      root=/home/oracle/script/osa
      [ -d "${root}" ] || { echo 0; exit 0; }
      count=$(find "${root}" -maxdepth 1 -type f | wc -l)
      find "${root}" -maxdepth 1 -type f -delete
      rm -f \
        "${root}/23ai/prepare_ai_26ai_objects.sh" \
        "${root}/23ai/prepare_ai_26ai_objects.sql" \
        "${root}/23ai/show_ai_26ai_care_detail.sql"
      echo "${count}"
    ')"
    echo "OK: ${container}: removed ${removed} legacy OSA root files."
  done
}

cleanup_host_files
cleanup_retired_23ai_files
cleanup_container_files
