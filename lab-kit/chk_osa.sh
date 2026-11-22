#!/usr/bin/env bash
set -u

BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"
SOURCE_DB_CONTAINER="${SOURCE_DB_CONTAINER:-demo_osrc_23ai}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
OSA_BASE="${OSA_BASE:-/home/oracle/osa/osa-base}"
SPARK_HOME="${SPARK_HOME:-/home/oracle/spark}"
KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
KAFKA_BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVER:-localhost:9092}"
KAFKA_REPLICAT_NAME="${KAFKA_REPLICAT_NAME:-KAF01}"
KAFKA_QUERY_TIMEOUT="${KAFKA_QUERY_TIMEOUT:-15}"
SOURCE_OSA_LOG_DIR="${SOURCE_OSA_LOG_DIR:-/home/oracle/script/osa/23ai/logs}"

TOPICS="${TOPICS:-SOE.CFUND_DT sx_KafkaPipeLine_CustomFundStatus_public sx_KafkaPipeLine_OpGubunStatus_public sx_KafkaPipeLine_TotalAmtByGubunStatus_public sx_KafkaPipeLine_CancelCustInfo_public sx_KafkaPipeLine_WarnCancelStatus_public}"

rc=0

ok() { echo "OK: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }
error() { echo "ERROR: $*"; rc=1; }

container_state() {
  docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || echo "missing"
}

container_running() {
  [ "$(container_state "$1")" = "running" ]
}

run_bigdata() {
  docker exec "${BIGDATA_CONTAINER}" bash -lc "$*"
}

check_container() {
  name="$1"
  required="${2:-Y}"
  state="$(container_state "${name}")"
  if [ "${state}" = "running" ]; then
    ok "${name} is running"
  elif [ "${required}" = "Y" ]; then
    error "${name} is ${state}"
  else
    info "${name} is ${state}"
  fi
}

check_port() {
  port="$1"
  label="$2"
  if ! container_running "${BIGDATA_CONTAINER}"; then
    error "${label} cannot be checked because ${BIGDATA_CONTAINER} is not running"
    return
  fi

  if run_bigdata "ss -ltn 2>/dev/null | grep -q ':${port} '" >/dev/null 2>&1; then
    ok "${label} listener is open on ${BIGDATA_CONTAINER}:${port}"
  else
    error "${label} listener is not open on ${BIGDATA_CONTAINER}:${port}"
  fi
}

show_spark_config() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    return
  fi

  echo "==> Spark resource configuration"
  run_bigdata "
    if [ -f '${SPARK_HOME}/conf/spark-env.sh' ]; then
      grep -E '^(SPARK_WORKER_INSTANCES|SPARK_WORKER_CORES|SPARK_WORKER_MEMORY)=' '${SPARK_HOME}/conf/spark-env.sh' || true
    else
      echo 'WARN: spark-env.sh not found'
    fi
    worker_count=\$(ps -eo args= | grep 'org.apache.spark.deploy.worker.Worker' | grep -v grep | wc -l)
    app_count=\$(ps -eo args= | grep 'CoarseGrainedExecutorBackend' | grep -v grep | wc -l)
    echo \"INFO: Spark worker processes=\${worker_count}, executor backend processes=\${app_count}\"
  " || warn "Spark configuration check failed"
}

show_osa_datasource() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    return
  fi

  echo "==> OSA metadata datasource"
  run_bigdata "
    f='${OSA_BASE}/etc/osa-datasource.xml'
    if [ -f \"\${f}\" ]; then
      grep -Eo 'jdbc:oracle:thin:@[^<]+' \"\${f}\" | sed 's/^/INFO: /'
    else
      echo 'WARN: osa-datasource.xml not found'
    fi
  " || warn "OSA datasource check failed"
}

show_kafka_topics() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    return
  fi

  echo "==> Kafka topic end offsets"
  run_bigdata "
    set +e
    for topic in ${TOPICS}; do
      if timeout '${KAFKA_QUERY_TIMEOUT}' '${KAFKA_HOME}/bin/kafka-topics.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' --describe --topic \"\${topic}\" >/tmp/chk-osa-topic.out 2>&1; then
        if timeout '${KAFKA_QUERY_TIMEOUT}' '${KAFKA_HOME}/bin/kafka-get-offsets.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' --topic \"\${topic}\" --time -1 >/tmp/chk-osa-offsets.out 2>&1; then
          offsets=\$(paste -sd, - </tmp/chk-osa-offsets.out)
          [ -n \"\${offsets}\" ] || offsets='no offsets'
        else
          offsets='offset query timed out or failed'
        fi
        echo \"INFO: \${topic}: \${offsets}\"
      else
        echo \"WARN: \${topic}: topic not found or describe timed out\"
      fi
    done
  " || warn "Kafka topic check failed"
}

show_reader_next_steps() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    return
  fi

  echo "==> Reader next step"
  run_bigdata "
    src=\$(timeout '${KAFKA_QUERY_TIMEOUT}' '${KAFKA_HOME}/bin/kafka-get-offsets.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' --topic SOE.CFUND_DT --time -1 2>/dev/null | awk -F: '{sum += \$3} END {print sum + 0}')
    out=\$(timeout '${KAFKA_QUERY_TIMEOUT}' '${KAFKA_HOME}/bin/kafka-get-offsets.sh' --bootstrap-server '${KAFKA_BOOTSTRAP_SERVER}' --topic sx_KafkaPipeLine_CustomFundStatus_public --time -1 2>/dev/null | awk -F: '{sum += \$3} END {print sum + 0}')
    if [ \"\${src}\" -gt 0 ] && [ \"\${out}\" -eq 0 ]; then
      echo 'WARN: Source Kafka topic has data, but OSA output topics are empty.'
      echo 'WARN: Run: sh recover_osa_demo.sh'
    elif [ \"\${src}\" -gt 0 ] && [ \"\${out}\" -gt 0 ]; then
      echo 'OK: Source and OSA output topics both have data.'
    else
      echo 'INFO: Source Kafka topic is empty or not ready yet.'
      echo 'INFO: Run the data generator after OSA pipeline is published.'
    fi
  " || warn "Reader next-step check failed"
}

show_kafka_replicat() {
  echo "==> GoldenGate Kafka Replicat"
  if ! container_running "${OGGBD_CONTAINER}"; then
    warn "${OGGBD_CONTAINER} is not running"
    return
  fi

  docker exec -u ogg "${OGGBD_CONTAINER}" bash -lc "
    timeout 15 curl -fsS 'http://127.0.0.1:8765/api/adminclient?cmd=info%20${KAFKA_REPLICAT_NAME}' 2>/dev/null \
      | sed -n '1,20p' || true
  " | sed 's/^/INFO: /'
}

check_latest_generator_logs() {
  if ! container_running "${SOURCE_DB_CONTAINER}"; then
    return
  fi

  echo "==> Latest OSA workload generator logs"
  generator_output="$(docker exec "${SOURCE_DB_CONTAINER}" bash -lc "
    log_dir='${SOURCE_OSA_LOG_DIR}'
    if [ ! -d \"\${log_dir}\" ]; then
      echo 'STATUS=NO_LOG_DIR'
      exit 0
    fi

    latest=\$(find \"\${log_dir}\" -maxdepth 1 -type f -name 'gen_init_*.log' -printf '%f\n' 2>/dev/null | sort | tail -1)
    if [ -z \"\${latest}\" ]; then
      echo 'STATUS=NO_RUN'
      exit 0
    fi

    run_ts=\${latest#gen_init_}
    run_ts=\${run_ts%.log}
    echo \"RUN_TS=\${run_ts}\"
    matches=\$(grep -HnEi 'ORA-[0-9]+|SP2-[0-9]+|ERROR at line|(^|[[:space:]])(FATAL|ABEND)([[:space:]:]|$)|Exception|No such file|not found' \"\${log_dir}\"/*_\"\${run_ts}\".log 2>/dev/null | tail -20 || true)
    if [ -n \"\${matches}\" ]; then
      echo 'STATUS=ERROR'
      printf '%s\n' \"\${matches}\"
    else
      echo 'STATUS=OK'
    fi
  " 2>&1)" || {
    warn "Could not inspect Source workload generator logs."
    return
  }

  generator_run="$(printf '%s\n' "${generator_output}" | sed -n 's/^RUN_TS=//p' | tail -1)"
  generator_status="$(printf '%s\n' "${generator_output}" | sed -n 's/^STATUS=//p' | tail -1)"
  case "${generator_status}" in
    OK)
      ok "OSA workload generator run ${generator_run} has no SQL or runtime errors."
      ;;
    ERROR)
      error "OSA workload generator run ${generator_run} contains SQL or runtime errors."
      printf '%s\n' "${generator_output}" | grep -vE '^(RUN_TS|STATUS)=' | sed 's/^/INFO: /'
      ;;
    NO_LOG_DIR|NO_RUN)
      info "No OSA workload generator run is available yet."
      ;;
    *)
      warn "Could not classify the latest OSA workload generator logs."
      printf '%s\n' "${generator_output}" | sed 's/^/INFO: /'
      ;;
  esac
}

show_recent_osa_errors() {
  if ! container_running "${BIGDATA_CONTAINER}"; then
    return
  fi

  echo "==> Recent OSA/Spark diagnostics"
  run_bigdata "
    matches=\$(mktemp /tmp/chk-osa-matches.XXXXXX)
    trap 'rm -f \"\${matches}\"' EXIT
    find '${OSA_BASE}/logs' '${SPARK_HOME}/work' -type f -mmin -180 -print0 2>/dev/null \
      | xargs -0 grep -hEi 'event timestamp is out of order|invalid data source|UnableToExecuteDML|SparkException|ERROR|Exception' 2>/dev/null \
      > \"\${matches}\" || true

    submission_count=\$(grep -c 'unexpected type SubmissionStatusResponse' \"\${matches}\" || true)
    certificate_count=\$(grep -Ec 'password.*is null|Error while validating SSL certificate' \"\${matches}\" || true)
    stop_helper_count=\$(grep -Ec 'logError: command not found|Failed to kill PID [0-9]+\. Manual intervention needed\.|Failed to stop the running process\. Aborting\.' \"\${matches}\" || true)

    [ \"\${submission_count}\" -eq 0 ] || echo \"INFO: known OSA/Spark status-polling compatibility messages: \${submission_count} (runtime health is checked separately)\"
    [ \"\${certificate_count}\" -eq 0 ] || echo \"INFO: known non-blocking OSA startup certificate messages: \${certificate_count}\"
    [ \"\${stop_helper_count}\" -eq 0 ] || echo \"INFO: known OSA vendor stop-helper messages: \${stop_helper_count}\"

    actionable=\$(grep -vE 'unexpected type SubmissionStatusResponse|password.*is null|Error while validating SSL certificate|logError: command not found|Failed to kill PID [0-9]+\. Manual intervention needed\.|Failed to stop the running process\. Aborting\.|errorMessage=<null>|Deregistered CQLEngine.*Stopped by driver|USING SparkClientConfig:|JAVA_PROPERTIES[[:space:]]*=|classpath[[:space:]]*:|Launch Command:' \"\${matches}\" | tail -20 || true)
    if [ -n \"\${actionable}\" ]; then
      echo 'WARN: additional OSA/Spark diagnostic messages were found:'
      printf '%s\n' \"\${actionable}\"
    else
      echo 'OK: no additional OSA/Spark diagnostic messages were found.'
    fi
  " | sed '/^\(INFO\|WARN\|OK\): /! s/^/INFO: /'
}

echo "==> Container state"
check_container "${SOURCE_DB_CONTAINER}" Y
check_container "${OGGBD_CONTAINER}" Y
check_container "${BIGDATA_CONTAINER}" Y
check_container "${TARGET_DB_CONTAINER}" N

echo "==> Runtime listeners"
check_port 2181 "ZooKeeper"
check_port 9092 "Kafka"
check_port 7077 "Spark master"
check_port 9443 "OSA HTTPS"

show_spark_config
show_osa_datasource
show_kafka_replicat
show_kafka_topics
check_latest_generator_logs
show_recent_osa_errors
show_reader_next_steps

exit "${rc}"
