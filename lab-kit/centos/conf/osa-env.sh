#!/bin/bash

export JAVA_HOME="${JAVA_HOME:-/usr/java/jdk-21}"
export SPARK_HOME="${SPARK_HOME:-/home/oracle/spark}"
export KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"

if [ -z "${JAVA_HOME}" ]; then
    echo "JAVA_HOME is not set. Set JAVA_HOME and restart the script."
    exit 1
else
    echo "JAVA_HOME: ${JAVA_HOME}"
fi

if [ -z "${SPARK_HOME}" ]; then
    echo "SPARK_HOME is not set. Set SPARK_HOME and restart the script."
    exit 1
else
    echo "SPARK_HOME: ${SPARK_HOME}"
fi

if [ ! -x "${JAVA_HOME}/bin/java" ]; then
    echo "Cannot find java executable: ${JAVA_HOME}/bin/java"
    exit 1
fi

if [ ! -f "${SPARK_HOME}/RELEASE" ]; then
   echo "Cannot find the RELEASE file: ${SPARK_HOME}/RELEASE"
   exit 1
fi

JAVA_VERSION="$("${JAVA_HOME}/bin/java" -version 2>&1 | awk -F\" '/version/ {print $2}')"
SPARK_VERSION="$(head -1 "${SPARK_HOME}/RELEASE")"

echo "JAVA_VERSION: ${JAVA_VERSION}"
echo "SPARK_VERSION: ${SPARK_VERSION}"
