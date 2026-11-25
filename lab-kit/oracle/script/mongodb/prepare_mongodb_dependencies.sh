#!/usr/bin/env bash
set -Eeuo pipefail

CONTAINER=demo_oggbd_23ai
LIB_DIR=/u02/Deployment/etc/conf/ogg/mongodb/lib

if [ "$(docker inspect -f '{{.State.Running}}' "${CONTAINER}" 2>/dev/null || true)" != true ]; then
  echo "ERROR: required container is not running: ${CONTAINER}" >&2
  exit 1
fi

if docker exec "${CONTAINER}" test -f "${LIB_DIR}/mongodb-driver-reactivestreams-5.0.1.jar" \
   && docker exec "${CONTAINER}" test -f "${LIB_DIR}/mongodb-driver-sync-5.0.1.jar"; then
  echo "OK: MongoDB GoldenGate dependencies are already prepared."
  exit 0
fi

echo "Resolve pinned MongoDB 5.0.1 client dependencies."
docker exec -u ogg "${CONTAINER}" bash -lc '
  set -e
  cd /u01/ogg/opt/DependencyDownloader
  test -d ./dependencies/mongodb_capture_5.0.1 || ./mongodb_capture.sh 5.0.1
  test -d ./dependencies/mongodb_5.0.1 || ./mongodb.sh 5.0.1
'

docker exec -u 0 "${CONTAINER}" bash -lc '
  set -e
  dst=/u02/Deployment/etc/conf/ogg/mongodb/lib
  mkdir -p "$dst"
  find /u01/ogg/opt/DependencyDownloader/dependencies/mongodb_capture_5.0.1 \
       /u01/ogg/opt/DependencyDownloader/dependencies/mongodb_5.0.1 \
       -type f -name "*.jar" -exec cp -f {} "$dst" \;
  cp -f /u01/ogg/ggjava/resources/lib/ggmongodbcapture-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/ggmongodb-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/ggcapturecommon-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/ggdbutil-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/ggutil-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/commons-lang3-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/jackson-annotations-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/jackson-core-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/jackson-databind-*.jar "$dst"/
  cp -f /u01/ogg/ggjava/resources/lib/slf4j-api-*.jar "$dst"/
  chown -R ogg:ogg /u02/Deployment/etc/conf/ogg/mongodb
  chmod 644 "$dst"/*.jar
'

docker exec "${CONTAINER}" test -f "${LIB_DIR}/mongodb-driver-reactivestreams-5.0.1.jar"
docker exec "${CONTAINER}" test -f "${LIB_DIR}/mongodb-driver-sync-5.0.1.jar"
echo "OK: MongoDB GoldenGate dependencies are prepared."
