#!/bin/sh
set -eu

LAB_HOME="${LAB_HOME:-$(CDPATH= cd "$(dirname "$0")" && pwd)}"
failures=0

require_command() {
  name="$1"

  if command -v "$name" >/dev/null 2>&1; then
    return 0
  fi

  echo "ERROR: required command not found: $name"
  failures=$((failures + 1))
}

check_url() {
  name="$1"
  url="$2"

  echo "==> URL: $name"

  if curl -fsSLI --connect-timeout 10 --max-time 30 "$url" >/dev/null 2>&1; then
    echo "OK: $url"
    return 0
  fi

  if curl -fsSL --range 0-0 --connect-timeout 10 --max-time 30 \
    -o /dev/null "$url" >/dev/null 2>&1; then
    echo "OK: $url"
    return 0
  fi

  echo "ERROR: cannot access $url"
  failures=$((failures + 1))
}

check_file() {
  path="$1"

  if [ -f "$path" ]; then
    echo "OK: $path"
    return 0
  fi

  echo "ERROR: missing $path"
  failures=$((failures + 1))
}

check_checksum() {
  algorithm="$1"
  expected="$2"
  path="$3"

  if [ ! -f "$path" ]; then
    return 0
  fi

  actual="$($algorithm "$path" | awk '{print $1}')"
  if [ "$actual" = "$expected" ]; then
    echo "OK: $algorithm $path"
    return 0
  fi

  echo "ERROR: checksum mismatch: $path"
  echo "Expected: $expected"
  echo "Actual:   $actual"
  failures=$((failures + 1))
}

check_image() {
  image="$1"

  if docker image inspect "$image" >/dev/null 2>&1; then
    echo "OK: $image"
    return 0
  fi

  echo "ERROR: missing local image $image"
  failures=$((failures + 1))
}

require_command curl
require_command docker
require_command sha256sum
require_command sha1sum
require_command awk

if [ "$failures" -eq 0 ]; then
  echo "==> Check build-time download URLs"
  check_url "Apache ZooKeeper 3.7.2" "https://archive.apache.org/dist/zookeeper/zookeeper-3.7.2/apache-zookeeper-3.7.2-bin.tar.gz"
  check_url "Apache Spark 4.0.1" "https://archive.apache.org/dist/spark/spark-4.0.1/spark-4.0.1-bin-hadoop3.tgz"
  check_url "Apache Kafka 3.9.0" "https://archive.apache.org/dist/kafka/3.9.0/kafka_2.13-3.9.0.tgz"
fi

echo "==> Check local product media"
check_file "$LAB_HOME/centos/pkg/V1054826-01.zip"
check_file "$LAB_HOME/centos/pkg/jdk-21_linux-x64_bin.rpm"
check_file "$LAB_HOME/oracle/pkg/apex_26.1.zip"
check_file "$LAB_HOME/oracle/pkg/ords-26.2.3.237.1104.zip"

check_checksum sha256sum "06df14e7c8465747ee45c36c5a0b09821bf2b244db0e201d3cc44abb0403f023" \
  "$LAB_HOME/oracle/pkg/apex_26.1.zip"
check_checksum sha1sum "290626c955d153602d7e9fe5c78978a86051b414" \
  "$LAB_HOME/oracle/pkg/ords-26.2.3.237.1104.zip"

if command -v docker >/dev/null 2>&1; then
  echo "==> Check local base images"
  check_image "oracle/database:23.26.0-ee"
  check_image "oracle/goldengate:23.26.1-oracle"
  check_image "oracle/oggforbigdata:23.26.1-daa"
fi

if [ "$failures" -ne 0 ]; then
  echo "ERROR: preflight failed with $failures issue(s)."
  echo "Check the online appendix for updated URLs, package names, and Lab Kit files."
  exit 1
fi

echo "OK: build-time download URLs, local product media, and base images are ready."
