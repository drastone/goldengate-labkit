#!/usr/bin/env bash
set -u

ORACLE_LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_CONTAINERS="${DB_CONTAINERS-demo_osrc_23ai demo_otrg_23ai}"
SOURCE_DB_CONTAINER="${SOURCE_DB_CONTAINER:-demo_osrc_23ai}"
OGG_CONTAINER="${OGG_CONTAINER:-demo_ogg_23ai}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"
ORACLE_HOME_OVERRIDE="${ORACLE_HOME:-}"
ORACLE_SID_OVERRIDE="${ORACLE_SID:-}"
ORACLE_SCRIPT_SOURCE="${ORACLE_SCRIPT_SOURCE:-${ORACLE_LAB_DIR}/script}"
LABKIT_INIT_COMMON="${LABKIT_INIT_COMMON:-${ORACLE_LAB_DIR}/../labkit_init_common.sh}"
DB_SCRIPT_TARGET="${DB_SCRIPT_TARGET:-/home/oracle/script}"
SOURCE_APEX_ORDS_INSTALLER_SOURCE="${SOURCE_APEX_ORDS_INSTALLER_SOURCE:-${ORACLE_LAB_DIR}/install_source_apex_ords.sh}"
SOURCE_APEX_ORDS_INSTALLER_TARGET="${SOURCE_APEX_ORDS_INSTALLER_TARGET:-/home/oracle/install_source_apex_ords.sh}"
OGG_FIELD_KIT_SOURCE="${OGG_FIELD_KIT_SOURCE:-${ORACLE_LAB_DIR}/script/ogg}"
OGG_FIELD_KIT_TARGET="${OGG_FIELD_KIT_TARGET:-/u01/ogg/scripts/field-kit}"
OGG_OBEY_SOURCE="${OGG_OBEY_SOURCE:-${ORACLE_LAB_DIR}/script/ogg/obey}"
OGG_OBEY_TARGET="${OGG_OBEY_TARGET:-/u01/ogg/scripts/obey}"
OGGBD_KAFKA_SOURCE="${OGGBD_KAFKA_SOURCE:-${ORACLE_LAB_DIR}/script/oggbd/kafka}"
OGGBD_KAFKA_TARGET="${OGGBD_KAFKA_TARGET:-/u02/Deployment/etc/conf/ogg}"
KAFKA_CLIENT_LIB_SOURCE="${KAFKA_CLIENT_LIB_SOURCE:-/usr/local/kafka/libs}"
OGGBD_KAFKA_LIB_TARGET="${OGGBD_KAFKA_LIB_TARGET:-/u01/ogg/thirdparty/kafka}"

if [ ! -f "${LABKIT_INIT_COMMON}" ]; then
  echo "ERROR: Lab Kit init helper not found: ${LABKIT_INIT_COMMON}" >&2
  exit 1
fi
. "${LABKIT_INIT_COMMON}"

container_exists() {
  docker inspect "$1" >/dev/null 2>&1
}

copy_dir_to_container() {
  source_dir="$1"
  container="$2"
  target_dir="$3"
  owner="$4"
  label="$5"

  if ! container_exists "${container}"; then
    echo "WARN: ${label}: container not found: ${container}"
    return 0
  fi

  if [ ! -d "${source_dir}" ]; then
    echo "WARN: ${label}: source directory not found: ${source_dir}"
    return 0
  fi

  echo "==> ${container}: provision ${label}"
  docker exec -u root "${container}" mkdir -p "${target_dir}" || {
    echo "WARN: ${label}: cannot create ${target_dir} in ${container}"
    return 0
  }
  docker cp "${source_dir}/." "${container}:${target_dir}/" || {
    echo "WARN: ${label}: docker cp failed"
    return 0
  }
  docker exec -u root "${container}" bash -lc \
    "chown -R '${owner}' '${target_dir}' 2>/dev/null || true; \
     find '${target_dir}' -type f -name '*.sh' -exec chmod 755 {} + 2>/dev/null || true; \
     find '${target_dir}' -type f -name '*.py' -exec chmod 755 {} + 2>/dev/null || true; \
     find '${target_dir}' -type f -name '*.oby' -exec chmod 644 {} + 2>/dev/null || true; \
     find '${target_dir}' -type f -name '*.properties' -exec chmod 644 {} + 2>/dev/null || true; \
     find '${target_dir}' -type f -name '*.prm' -exec chmod 644 {} + 2>/dev/null || true" || {
      echo "WARN: ${label}: permission repair failed"
    }
}

copy_file_to_container() {
  source_file="$1"
  container="$2"
  target_file="$3"
  owner="$4"
  mode="$5"
  label="$6"

  if ! container_exists "${container}"; then
    echo "WARN: ${label}: container not found: ${container}"
    return 0
  fi

  if [ ! -f "${source_file}" ]; then
    echo "WARN: ${label}: source file not found: ${source_file}"
    return 0
  fi

  echo "==> ${container}: provision ${label}"
  docker exec -u root "${container}" mkdir -p "$(dirname "${target_file}")" || {
    echo "WARN: ${label}: cannot create target directory in ${container}"
    return 0
  }
  docker cp "${source_file}" "${container}:${target_file}" || {
    echo "WARN: ${label}: docker cp failed"
    return 0
  }
  docker exec -u root "${container}" chown "${owner}" "${target_file}" || true
  docker exec -u root "${container}" chmod "${mode}" "${target_file}" || {
    echo "WARN: ${label}: permission repair failed"
  }
}

copy_kafka_client_libs() {
  source_container="$1"
  target_container="$2"
  source_dir="$3"
  target_dir="$4"

  if ! container_exists "${source_container}"; then
    echo "WARN: Kafka client libs: source container not found: ${source_container}"
    return 0
  fi

  if ! container_exists "${target_container}"; then
    echo "WARN: Kafka client libs: target container not found: ${target_container}"
    return 0
  fi

  if ! docker exec "${source_container}" test -d "${source_dir}" >/dev/null 2>&1; then
    echo "WARN: Kafka client libs source directory not found: ${source_container}:${source_dir}"
    return 0
  fi

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ogg-kafka-libs.XXXXXX")"
  echo "==> ${target_container}: provision Kafka client libraries from ${source_container}:${source_dir}"

  docker cp "${source_container}:${source_dir}/." "${temp_dir}/" || {
    echo "WARN: Kafka client libs: docker cp from ${source_container} failed"
    rm -rf "${temp_dir}"
    return 0
  }

  docker exec -u root "${target_container}" mkdir -p "${target_dir}" || {
    echo "WARN: Kafka client libs: cannot create ${target_dir} in ${target_container}"
    rm -rf "${temp_dir}"
    return 0
  }

  docker cp "${temp_dir}/." "${target_container}:${target_dir}/" || {
    echo "WARN: Kafka client libs: docker cp to ${target_container} failed"
    rm -rf "${temp_dir}"
    return 0
  }

  rm -rf "${temp_dir}"

  docker exec -u root "${target_container}" bash -lc \
    "chown -R ogg:ogg '${target_dir}' 2>/dev/null || true; \
     find '${target_dir}' -type f -name '*.jar' -exec chmod 644 {} + 2>/dev/null || true" || {
      echo "WARN: Kafka client libs: permission repair failed"
    }
}

repair_listener() {
  container="$1"

  echo "==> ${container}: repair and start DB listener"
  docker exec -u oracle \
    -e ORACLE_HOME_OVERRIDE="${ORACLE_HOME_OVERRIDE}" \
    -e ORACLE_SID_OVERRIDE="${ORACLE_SID_OVERRIDE}" \
    "${container}" bash -lc '
      if [ -n "${ORACLE_HOME_OVERRIDE:-}" ]; then
        export ORACLE_HOME="${ORACLE_HOME_OVERRIDE}"
      fi
      if [ -z "${ORACLE_HOME:-}" ] || [ ! -x "${ORACLE_HOME}/bin/sqlplus" ]; then
        for candidate in /opt/oracle/product/*/dbhome* /opt/oracle/product/*/db_1; do
          if [ -x "${candidate}/bin/sqlplus" ]; then
            export ORACLE_HOME="${candidate}"
            break
          fi
        done
      fi
      if [ -n "${ORACLE_SID_OVERRIDE:-}" ]; then
        export ORACLE_SID="${ORACLE_SID_OVERRIDE}"
      fi
      export PATH="${ORACLE_HOME}/bin:${PATH}"
      listener_file="${ORACLE_HOME}/network/admin/listener.ora"
      if [ -f "${listener_file}" ]; then
        cp -p "${listener_file}" "${listener_file}.bak_ogg_lab" 2>/dev/null || true
        sed -i -E "s/\(HOST[[:space:]]*=[[:space:]]*[^)]+\)/(HOST = 0.0.0.0)/g" "${listener_file}"
      fi
      lsnrctl start || true
      printf "alter system register;\nexit\n" | sqlplus -s / as sysdba
    ' || {
       echo "WARN: ${container}: listener repair/start failed"
     }
}

for container in ${DB_CONTAINERS}; do
  if ! container_exists "${container}"; then
    echo "WARN: container not found: ${container}"
    continue
  fi

  copy_dir_to_container "${ORACLE_SCRIPT_SOURCE}" "${container}" "${DB_SCRIPT_TARGET}" "oracle:oinstall" "Oracle lab scripts"

  echo "==> ${container}: install base packages"
  docker exec -u root "${container}" yum install -y wget vi
  docker exec -u root "${container}" yum install -y langpacks-ko libnsl.x86_64

  echo "INFO: ${container}: ORDS uses the canonical JDK 21 installed by the Chapter 12 setup."

  echo "==> ${container}: set ownership"
  docker exec -u root "${container}" chown -R oracle:oinstall /home/oracle/pkg /home/oracle/msa /home/oracle/script

  repair_listener "${container}"
done

for container in ${DB_CONTAINERS} "${OGG_CONTAINER}" "${OGGBD_CONTAINER}"; do
  configure_container_utf8_profiles "${container}"
done

copy_file_to_container \
  "${SOURCE_APEX_ORDS_INSTALLER_SOURCE}" \
  "${SOURCE_DB_CONTAINER}" \
  "${SOURCE_APEX_ORDS_INSTALLER_TARGET}" \
  "oracle:oinstall" \
  "755" \
  "Source APEX/ORDS installer"

copy_dir_to_container "${OGG_FIELD_KIT_SOURCE}" "${OGG_CONTAINER}" "${OGG_FIELD_KIT_TARGET}" "ogg:ogg" "OGG field kit"
copy_dir_to_container "${OGG_OBEY_SOURCE}" "${OGG_CONTAINER}" "${OGG_OBEY_TARGET}" "ogg:ogg" "OGG Admin Client OBEY files"
copy_dir_to_container "${OGGBD_KAFKA_SOURCE}" "${OGGBD_CONTAINER}" "${OGGBD_KAFKA_TARGET}" "ogg:ogg" "OGG Big Data Kafka deployment files"
copy_kafka_client_libs "${BIGDATA_CONTAINER}" "${OGGBD_CONTAINER}" "${KAFKA_CLIENT_LIB_SOURCE}" "${OGGBD_KAFKA_LIB_TARGET}"
