#!/usr/bin/env bash
set -eu

CENTOS_LAB_DIR="${CENTOS_LAB_DIR:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"
BIGDATA_SCRIPT_SOURCE="${BIGDATA_SCRIPT_SOURCE:-${CENTOS_LAB_DIR}/script}"
BIGDATA_SCRIPT_TARGET="${BIGDATA_SCRIPT_TARGET:-/u01}"

systemctl_available() {
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc 'systemctl list-unit-files >/dev/null 2>&1'
}

wait_for_listener() {
  port="$1"
  label="$2"

  echo "==> ${BIGDATA_CONTAINER}: wait for ${label} listener"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc "for i in \$(seq 1 30); do if netstat -ltn | grep -q ':${port} '; then exit 0; fi; sleep 2; done; echo 'ERROR: ${label} listener did not open on port ${port}'; exit 1"
}

ensure_kafka_uses_local_zookeeper() {
  echo "==> ${BIGDATA_CONTAINER}: ensure Kafka points to local ZooKeeper"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    conf=/usr/local/kafka/config/server.properties
    [ -f "${conf}" ] || exit 0
    if ! grep -q "^zookeeper.connect=127.0.0.1:2181" "${conf}"; then
      cp -p "${conf}" "${conf}.bak_ogg_lab" 2>/dev/null || true
      if grep -q "^zookeeper.connect=" "${conf}"; then
        sed -i "s|^zookeeper.connect=.*|zookeeper.connect=127.0.0.1:2181|" "${conf}"
      else
        printf "\nzookeeper.connect=127.0.0.1:2181\n" >> "${conf}"
      fi
    fi
  '
}

repair_stale_kafka_broker_znode() {
  echo "==> ${BIGDATA_CONTAINER}: repair stale Kafka broker znode"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    if pgrep -f "[k]afka.Kafka" >/dev/null || netstat -ltn | grep -q ":9092 "; then
      exit 0
    fi

    broker_id=$(awk -F= "/^broker.id=/ { print \$2; exit }" /usr/local/kafka/config/server.properties 2>/dev/null)
    broker_id=${broker_id:-1}
    log_file="/tmp/ogg_lab_kafka_znode_delete_${broker_id}.log"

    printf "delete /brokers/ids/%s\nquit\n" "${broker_id}" | \
      /usr/local/zookeeper/bin/zkCli.sh -server 127.0.0.1:2181 >"${log_file}" 2>&1 || true
  '
}

kafka_logs_show_cluster_id_mismatch() {
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    grep -Rqs "Invalid cluster.id" /usr/local/kafka/logs/server.log /usr/local/kafka/logs/kafka-startup.out 2>/dev/null
  '
}

reset_kafka_cluster_state() {
  echo "==> ${BIGDATA_CONTAINER}: reset Kafka/ZooKeeper lab state after cluster.id mismatch"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    set -eu
    ts=$(date +%Y%m%d_%H%M%S)
    backup_dir=/root/kafka-reset-backup
    mkdir -p "${backup_dir}"

    for port in 9092 2181; do
      pids=$(ss -ltnp 2>/dev/null | awk -v port=":${port}" "
        index(\$0, port) && match(\$0, /pid=[0-9]+/) {
          print substr(\$0, RSTART + 4, RLENGTH - 4)
        }" | sort -u)
      [ -z "${pids}" ] || kill ${pids} 2>/dev/null || true
    done
    sleep 3
    for port in 9092 2181; do
      pids=$(ss -ltnp 2>/dev/null | awk -v port=":${port}" "
        index(\$0, port) && match(\$0, /pid=[0-9]+/) {
          print substr(\$0, RSTART + 4, RLENGTH - 4)
        }" | sort -u)
      [ -z "${pids}" ] || kill -9 ${pids} 2>/dev/null || true
    done

    [ -e /usr/local/kafka/logs ] && mv /usr/local/kafka/logs "${backup_dir}/kafka-logs-${ts}"
    [ -e /usr/local/zookeeper/data/version-2 ] && mv /usr/local/zookeeper/data/version-2 "${backup_dir}/zookeeper-version-2-${ts}"
    mkdir -p /usr/local/kafka/logs /usr/local/zookeeper/data
    echo 1 > /usr/local/zookeeper/data/myid
  '
}

start_kafka_direct() {
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    if pgrep -f "[k]afka.Kafka" >/dev/null; then
      exit 0
    fi
    mkdir -p /usr/local/kafka/logs
    cd /usr/local/kafka
    nohup env KAFKA_HEAP_OPTS="-Xms256m -Xmx512m" \
      /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties \
      >> /usr/local/kafka/logs/kafka-startup.out 2>&1 </dev/null &
  '
}

install_stream_analytics_runtime() {
  echo "==> ${BIGDATA_CONTAINER}: install Stream Analytics runtime files"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    set -eu

    require_file() {
      if [ ! -f "$1" ]; then
        echo "ERROR: missing required media: $1"
        exit 1
      fi
    }

    require_executable() {
      if [ ! -x "$1" ]; then
        echo "ERROR: required runtime is missing from the image: $1"
        echo "ERROR: rebuild demo_centos with the latest centos/Dockerfile."
        exit 1
      fi
    }

    require_file /home/oracle/pkg/jdk-21_linux-x64_bin.rpm
    require_file /home/oracle/pkg/V1054826-01.zip
    require_executable /usr/local/zookeeper/bin/zkServer.sh
    require_executable /usr/local/kafka/bin/kafka-server-start.sh
    require_executable /home/oracle/spark/bin/spark-submit

    if [ ! -x /usr/java/jdk-21/bin/java ]; then
      rpm -Uvh /home/oracle/pkg/jdk-21_linux-x64_bin.rpm
    fi
    if [ ! -x /usr/java/jdk-21/bin/java ]; then
      jdk_dir=$(find /usr/lib/jvm /usr/java -maxdepth 1 \( -type d -o -type l \) -name "jdk-21*" 2>/dev/null | sort | tail -1)
      ln -sfn "${jdk_dir}" /usr/java/jdk-21
    fi

    mkdir -p /usr/local/zookeeper/data
    echo 1 > /usr/local/zookeeper/data/myid
    cd /usr/local/zookeeper/conf
    if [ ! -f zoo.cfg ]; then
      cp zoo_sample.cfg zoo.cfg
    fi
    sed -i "s|/tmp/zookeeper|/usr/local/zookeeper/data|g" zoo.cfg
    grep -q "^admin.serverPort=8888" zoo.cfg || printf "\nadmin.serverPort=8888\n" >> zoo.cfg
    grep -q "^server.1=172.28.0.11:2888:3888" zoo.cfg || printf "server.1=172.28.0.11:2888:3888\n" >> zoo.cfg

    cp /home/oracle/conf/spark-env.sh /home/oracle/spark/conf/
    cp /home/oracle/conf/spark-defaults.conf /home/oracle/spark/conf/

    mkdir -p /usr/local/kafka/config /usr/local/kafka/logs
    cp /home/oracle/conf/server.properties /usr/local/kafka/config/server.properties

    if [ ! -d /home/oracle/osa ]; then
      cd /home/oracle
      unzip -d /home/oracle -oq /home/oracle/pkg/V1054826-01.zip
      osa_dir=$(find /home/oracle -maxdepth 1 -type d -name "OSA-*" | sort | tail -1)
      chown -R oracle:oinstall "${osa_dir}"
      ln -sfn "${osa_dir##*/}" /home/oracle/osa
    fi
    cp /home/oracle/conf/osa-env.sh /home/oracle/osa/osa-base/etc/
    cp /home/oracle/conf/jetty-osa-datasource.xml /home/oracle/osa/osa-base/etc/

    chown -R oracle:oinstall /home/oracle/osa* /u01 2>/dev/null || true
  '
}

if ! docker inspect "${BIGDATA_CONTAINER}" >/dev/null 2>&1; then
  echo "WARN: container not found: ${BIGDATA_CONTAINER}"
  exit 0
fi

install_stream_analytics_runtime

if [ -d "${BIGDATA_SCRIPT_SOURCE}" ]; then
  echo "==> ${BIGDATA_CONTAINER}: sync Big Data helper scripts"
  docker cp "${BIGDATA_SCRIPT_SOURCE}/." "${BIGDATA_CONTAINER}:${BIGDATA_SCRIPT_TARGET}/"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc "chmod 755 '${BIGDATA_SCRIPT_TARGET}'/*.sh 2>/dev/null || true"
else
  echo "INFO: Big Data helper script source not found: ${BIGDATA_SCRIPT_SOURCE}"
fi

echo "==> ${BIGDATA_CONTAINER}: remove nologin flag"
docker exec -u root "${BIGDATA_CONTAINER}" /rmlogin.sh

echo "==> ${BIGDATA_CONTAINER}: start sshd"
if systemctl_available; then
  docker exec -u root "${BIGDATA_CONTAINER}" systemctl start sshd || \
    docker exec -u root "${BIGDATA_CONTAINER}" bash -lc 'mkdir -p /var/run/sshd; ssh-keygen -A; pgrep -x sshd >/dev/null || /usr/sbin/sshd'
else
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc 'mkdir -p /var/run/sshd; ssh-keygen -A; pgrep -x sshd >/dev/null || /usr/sbin/sshd'
fi

echo "==> ${BIGDATA_CONTAINER}: initialize passwordless SSH"
docker exec -u oracle "${BIGDATA_CONTAINER}" bash /home/oracle/initSSH.sh

echo "==> ${BIGDATA_CONTAINER}: start ZooKeeper"
if systemctl_available; then
  docker exec -u root "${BIGDATA_CONTAINER}" systemctl start zookeeper
else
  echo "WARN: ${BIGDATA_CONTAINER}: systemctl is unavailable; start ZooKeeper directly"
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    if pgrep -f "[o]rg.apache.zookeeper.server.quorum.QuorumPeerMain" >/dev/null; then
      exit 0
    fi
    rm -f /usr/local/zookeeper/data/zookeeper_server.pid
    mkdir -p /usr/local/zookeeper/logs
    cd /usr/local/zookeeper
    nohup env ZOO_LOG_DIR=/usr/local/zookeeper/logs ZOO_LOG4J_PROP=INFO,ROLLINGFILE \
      /usr/local/zookeeper/bin/zkServer.sh start-foreground /usr/local/zookeeper/conf/zoo.cfg \
      >> /usr/local/zookeeper/logs/zookeeper-startup.out 2>&1 </dev/null &
  '
fi
wait_for_listener 2181 "ZooKeeper"
ensure_kafka_uses_local_zookeeper
repair_stale_kafka_broker_znode

echo "==> ${BIGDATA_CONTAINER}: start Kafka"
if systemctl_available; then
  docker exec -u root "${BIGDATA_CONTAINER}" systemctl reset-failed kafka >/dev/null 2>&1 || true
  docker exec -u root "${BIGDATA_CONTAINER}" systemctl start kafka
else
  echo "WARN: ${BIGDATA_CONTAINER}: systemctl is unavailable; start Kafka directly"
  start_kafka_direct
fi
wait_for_listener 9092 "Kafka" || {
  echo "WARN: ${BIGDATA_CONTAINER}: Kafka listener did not open; retry after stale broker znode repair"
  repair_stale_kafka_broker_znode
  start_kafka_direct
  wait_for_listener 9092 "Kafka" || {
    if kafka_logs_show_cluster_id_mismatch; then
      echo "WARN: ${BIGDATA_CONTAINER}: Kafka cluster.id mismatch detected; reset lab Kafka state"
      reset_kafka_cluster_state
      echo "==> ${BIGDATA_CONTAINER}: restart ZooKeeper after Kafka cluster reset"
      docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
        cd /usr/local/zookeeper
        nohup env ZOO_LOG_DIR=/usr/local/zookeeper/logs ZOO_LOG4J_PROP=INFO,ROLLINGFILE \
          /usr/local/zookeeper/bin/zkServer.sh start-foreground /usr/local/zookeeper/conf/zoo.cfg \
          >> /usr/local/zookeeper/logs/zookeeper-startup.out 2>&1 </dev/null &
      '
      wait_for_listener 2181 "ZooKeeper"
      start_kafka_direct
    fi
    wait_for_listener 9092 "Kafka"
  }
}
