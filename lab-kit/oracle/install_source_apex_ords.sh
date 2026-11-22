#!/usr/bin/env bash
set -euo pipefail

PASSWORD="${PASSWORD:-WElcome1234##}"
PDB_NAME="${PDB_NAME:-ORCLPDB1}"
APEX_ZIP="${APEX_ZIP:-/home/oracle/pkg/apex_26.1.zip}"
ORDS_ZIP="${ORDS_ZIP:-/home/oracle/pkg/ords-latest-new.zip}"
JDK_RPM="${JDK_RPM:-/home/oracle/pkg/jdk-17.0.6_linux-x64_bin.rpm}"
APEX_HOME="${APEX_HOME:-/home/oracle/apex_install/apex}"
ORDS_HOME="${ORDS_HOME:-/home/oracle/ords}"
ORDS_CONFIG="${ORDS_CONFIG:-/home/oracle/ords_config}"
ORDS_LOG_DIR="${ORDS_LOG_DIR:-/home/oracle/ords_logs}"

mkdir -p "${ORDS_LOG_DIR}"
LOG_FILE="${ORDS_LOG_DIR}/source_apex_ords_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "==> Source APEX/ORDS install log: ${LOG_FILE}"

require_file() {
  if [ ! -f "$1" ]; then
    echo "ERROR: required file not found: $1"
    exit 1
  fi
}

sql_value() {
  sqlplus -s / as sysdba <<SQL
set heading off feedback off pages 0 verify off echo off
alter session set container=${PDB_NAME};
$1
exit
SQL
}

schema_exists() {
  schema="$1"
  count="$(sql_value "select count(*) from dba_users where username = upper('${schema}');" | tr -d '[:space:]')"
  [ "${count}" = "1" ]
}

ensure_java17() {
  if command -v java >/dev/null 2>&1 && java -version 2>&1 | awk -F'[ ".]+' '/version/ { exit !($3 >= 17) }'; then
    echo "OK: Java 17+ is already available"
    return 0
  fi

  require_file "${JDK_RPM}"
  echo "==> Install Java 17"
  rpm -Uvh "${JDK_RPM}" || true
  if ! command -v java >/dev/null 2>&1; then
    jdk_dir="$(find /usr/lib/jvm /usr/java -maxdepth 1 \( -type d -o -type l \) -name 'jdk-17*' 2>/dev/null | sort | tail -1)"
    [ -n "${jdk_dir}" ] || { echo "ERROR: Java 17 install did not create a JDK directory"; exit 1; }
    export JAVA_HOME="${jdk_dir}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
  fi
  java -version
}

ensure_apex_files() {
  if [ -f "${APEX_HOME}/apexins.sql" ] && [ -f "${APEX_HOME}/images/apex_version.txt" ]; then
    echo "OK: APEX files already extracted at ${APEX_HOME}"
    return 0
  fi

  require_file "${APEX_ZIP}"
  echo "==> Extract APEX 26.1"
  rm -rf /home/oracle/apex_install
  mkdir -p /home/oracle/apex_install
  unzip -oq "${APEX_ZIP}" -d /home/oracle/apex_install
  if [ "$(id -u)" = "0" ]; then
    chown -R oracle:oinstall /home/oracle/apex_install
  fi
}

ensure_apex_schema() {
  if schema_exists APEX_260100; then
    echo "OK: APEX_260100 schema already exists"
  else
    echo "==> Install APEX 26.1 into ${PDB_NAME}"
    cd "${APEX_HOME}"
    sqlplus / as sysdba <<SQL
alter session set container=${PDB_NAME};
@apexins.sql SYSAUX SYSAUX TEMP /i/
SQL
  fi

  echo "==> Unlock APEX_PUBLIC_USER and set password"
  sqlplus -s / as sysdba <<SQL
whenever sqlerror exit sql.sqlcode
alter session set container=${PDB_NAME};
alter user APEX_PUBLIC_USER account unlock identified by "${PASSWORD}";
begin
  execute immediate 'alter user APEX_260100 account lock';
exception
  when others then null;
end;
/
exit
SQL

  echo "==> Set APEX ADMIN password"
  cd "${APEX_HOME}"
  sqlplus / as sysdba <<SQL || true
alter session set container=${PDB_NAME};
@apxchpwd.sql
ADMIN
admin@example.com
${PASSWORD}
${PASSWORD}
SQL
}

ensure_ords_files() {
  if [ -x "${ORDS_HOME}/bin/ords" ]; then
    echo "OK: ORDS files already extracted at ${ORDS_HOME}"
    return 0
  fi

  require_file "${ORDS_ZIP}"
  echo "==> Extract ORDS"
  rm -rf "${ORDS_HOME}"
  mkdir -p "${ORDS_HOME}"
  unzip -oq "${ORDS_ZIP}" -d "${ORDS_HOME}"
  if [ "$(id -u)" = "0" ]; then
    chown -R oracle:oinstall "${ORDS_HOME}"
  fi
}

ensure_sys_password() {
  echo "==> Ensure SYS/SYSTEM lab passwords"
  sqlplus -s / as sysdba <<SQL
whenever sqlerror exit sql.sqlcode
alter user sys identified by "${PASSWORD}" container=all;
alter user system identified by "${PASSWORD}" container=all;
exit
SQL
}

ensure_ords_schema() {
  mkdir -p "${ORDS_CONFIG}"
  export JAVA_HOME="${JAVA_HOME:-$(find /usr/lib/jvm /usr/java -maxdepth 1 \( -type d -o -type l \) -name 'jdk-17*' 2>/dev/null | sort | tail -1)}"
  export PATH="${JAVA_HOME}/bin:${ORDS_HOME}/bin:${PATH}"

  if schema_exists ORDS_METADATA && schema_exists ORDS_PUBLIC_USER; then
    echo "OK: ORDS schemas already exist"
  else
    echo "==> Install ORDS database objects"
    printf '%s\n' "${PASSWORD}" > /tmp/ords-sys-password.txt
    chmod 600 /tmp/ords-sys-password.txt
    "${ORDS_HOME}/bin/ords" \
      --config "${ORDS_CONFIG}" \
      install \
      --admin-user SYS \
      --db-hostname localhost \
      --db-port 1521 \
      --db-servicename "${PDB_NAME}" \
      --db-only \
      --password-stdin < /tmp/ords-sys-password.txt
    rm -f /tmp/ords-sys-password.txt
  fi

  echo "==> Configure ORDS standalone/static settings"
  "${ORDS_HOME}/bin/ords" --config "${ORDS_CONFIG}" config set database.api.enabled true
  "${ORDS_HOME}/bin/ords" --config "${ORDS_CONFIG}" config set standalone.static.path "${APEX_HOME}/images"

  echo "==> Unlock ORDS_PUBLIC_USER"
  sqlplus -s / as sysdba <<SQL
whenever sqlerror exit sql.sqlcode
alter session set container=${PDB_NAME};
alter user ORDS_PUBLIC_USER account unlock identified by "${PASSWORD}";
exit
SQL
}

start_ords() {
  echo "==> Start ORDS"
  if [ -f /home/oracle/apex/start_ords.sh ]; then
    chmod 755 /home/oracle/apex/start_ords.sh
    ORDS_HOME="${ORDS_HOME}" ORDS_CONFIG="${ORDS_CONFIG}" /home/oracle/apex/start_ords.sh
  else
    nohup "${ORDS_HOME}/bin/ords" --config "${ORDS_CONFIG}" serve > "${ORDS_LOG_DIR}/ords-standalone.log" 2>&1 &
  fi
}

ensure_java17
ensure_apex_files
ensure_apex_schema
ensure_ords_files
ensure_sys_password
ensure_ords_schema
start_ords

echo "==> Verify ORDS/APEX endpoints"
for i in $(seq 1 60); do
  if curl -fsS --max-time 5 http://127.0.0.1:8080/ords/ >/dev/null 2>&1 &&
     curl -fsS --max-time 5 http://127.0.0.1:8080/i/apex_version.txt >/dev/null 2>&1; then
    echo "OK: Source ORDS/APEX is ready"
    exit 0
  fi
  sleep 2
done

echo "ERROR: Source ORDS/APEX did not become ready"
tail -120 "${ORDS_LOG_DIR}/ords-standalone.log" 2>/dev/null || true
exit 1
