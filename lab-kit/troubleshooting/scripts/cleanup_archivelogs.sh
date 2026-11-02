#!/usr/bin/env bash
set -u

RETENTION_DAYS="${RETENTION_DAYS:-3}"
ORACLE_SID="${ORACLE_SID:-ORCLCDB}"
PROTECT_GOLDENGATE_CAPTURE="${PROTECT_GOLDENGATE_CAPTURE:-Y}"
ARCHIVE_PREFIX="${ARCHIVE_PREFIX:-}"

if [ -z "${ORACLE_HOME:-}" ]; then
  ORACLE_HOME="$(find /opt/oracle/product -maxdepth 5 -type f -path '*/bin/rman' 2>/dev/null \
    | sed 's#/bin/rman$##' | sort | tail -1)"
fi

export ORACLE_HOME
export ORACLE_SID
export PATH="${ORACLE_HOME}/bin:${PATH}"

if [ -z "${ARCHIVE_PREFIX}" ]; then
  ARCHIVE_PREFIX="${ORACLE_HOME}/dbs/arch"
fi

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [ -z "${ORACLE_HOME}" ] || [ ! -x "${ORACLE_HOME}/bin/rman" ]; then
  log "ERROR: required RMAN executable not found. ORACLE_HOME=${ORACLE_HOME:-}"
  exit 1
fi

case "${RETENTION_DAYS}" in
  ''|*[!0-9]*)
    log "ERROR: RETENTION_DAYS must be a non-negative integer: ${RETENTION_DAYS}"
    exit 1
    ;;
esac

if [ ! -x "${ORACLE_HOME}/bin/sqlplus" ]; then
  log "ERROR: SQL*Plus is required to verify ARCHIVELOG mode and the GoldenGate capture checkpoint"
  exit 1
fi

database_log_mode="$(${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' <<SQL
set heading off feedback off pages 0 verify off echo off
select log_mode from v\$database;
exit
SQL
)"
database_log_mode="$(printf '%s' "${database_log_mode}" | tr -d '[:space:]')"

case "${database_log_mode}" in
  ARCHIVELOG)
    log "OK: database is in ARCHIVELOG mode"
    ;;
  NOARCHIVELOG)
    log "INFO: database is in NOARCHIVELOG mode; archive log cleanup is not applicable yet"
    log "OK: archive log cleanup skipped; no action is required at this stage"
    exit 0
    ;;
  *)
    log "ERROR: could not determine database log mode; current value=${database_log_mode:-unknown}"
    exit 1
    ;;
esac

# Integrated Extract registration normally lets RMAN retain logs needed by its
# upstream capture. Verify the registered capture checkpoint explicitly as an
# additional fail-closed guard before requesting time-based deletion.
if [ "${PROTECT_GOLDENGATE_CAPTURE}" = "Y" ]; then
  protected_capture_count="$(${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' <<SQL
set heading off feedback off pages 0 verify off echo off
select count(*)
  from cdb_capture c
 where c.required_checkpoint_scn is not null
   and c.required_checkpoint_scn <= nvl(
         (select max(a.next_change#)
            from v\$archived_log a
           where a.deleted = 'NO'
             and a.name is not null
             and a.completion_time < sysdate-${RETENTION_DAYS}),
         0);
exit
SQL
)"
  protected_capture_count="$(printf '%s' "${protected_capture_count}" | tr -d '[:space:]')"

  case "${protected_capture_count}" in
    ''|*[!0-9]*)
      log "ERROR: could not verify GoldenGate capture checkpoint"
      exit 1
      ;;
  esac

  if [ "${protected_capture_count}" -gt 0 ]; then
    log "WARN: ${protected_capture_count} GoldenGate capture(s) still need the archive deletion range"
    log "WARN: advance or repair the capture checkpoint before archive cleanup"
    exit 0
  fi
fi

log "INFO: archive log cleanup start. ORACLE_SID=${ORACLE_SID}, RETENTION_DAYS=${RETENTION_DAYS}"

rman_log="$(mktemp)"
trap 'rm -f "${rman_log}"' EXIT

rman target / <<RMAN | tee "${rman_log}"
CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
DELETE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-${RETENTION_DAYS}';
EXIT;
RMAN

rman_rc="${PIPESTATUS[0]}"
if [ "${rman_rc}" -ne 0 ] || \
   grep -Eq 'RMAN-(00569|03002|06403|01009)|ORA-[0-9]{5}' "${rman_log}"; then
  log "ERROR: archive log cleanup failed"
  exit 1
fi

# A reused lab container can contain archive files whose control-file records
# have aged out. RMAN cannot delete those orphan files by completion time. Once
# the capture guard above has passed, remove only files older than the same
# retention window and reconcile RMAN metadata again.
archive_dir="$(readlink -f "${ARCHIVE_PREFIX%/*}")"
retention_minutes="$((RETENTION_DAYS * 1440))"
orphan_count="$(find "${archive_dir}" -maxdepth 1 -type f -name 'arch*.dbf' \
  -mmin "+${retention_minutes}" -print 2>/dev/null | wc -l)"

if [ "${orphan_count}" -gt 0 ]; then
  log "INFO: remove ${orphan_count} orphan archive file(s) older than ${RETENTION_DAYS} day(s)"
  find "${archive_dir}" -maxdepth 1 -type f -name 'arch*.dbf' \
    -mmin "+${retention_minutes}" -delete

  rman target / <<RMAN | tee -a "${rman_log}"
CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
EXIT;
RMAN
  rman_rc="${PIPESTATUS[0]}"
  if [ "${rman_rc}" -ne 0 ] || \
     grep -Eq 'RMAN-(00569|03002|06403|01009)|ORA-[0-9]{5}' "${rman_log}"; then
    log "ERROR: archive log metadata reconciliation failed"
    exit 1
  fi
fi

rm -f "${rman_log}"
trap - EXIT
log "INFO: archive log cleanup complete"
