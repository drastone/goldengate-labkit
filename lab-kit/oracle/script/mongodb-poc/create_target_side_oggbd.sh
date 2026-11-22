#!/bin/bash
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

test "$(cat /etc/hostname)" = "DESKTOP-NAFTHH1"

CONTAINER=demo_oggbd_mongo_trg
IMAGE=oracle-oracle_oggbd_23ai
DEPLOYMENT=OGGBDTRG
NETWORK=oracle_ogg_network

if docker container inspect "$CONTAINER" >/dev/null 2>&1; then
  actual_image=$(docker inspect -f '{{.Config.Image}}' "$CONTAINER")
  if test "$actual_image" != "$IMAGE"; then
    echo "ERROR: $CONTAINER exists with image $actual_image; refusing to replace it." >&2
    exit 1
  fi
  echo "INFO: reuse existing $CONTAINER"
  docker start "$CONTAINER" >/dev/null
else
  echo "==> Create isolated target-side OGGBD deployment: $DEPLOYMENT"
  docker run -d \
    --name "$CONTAINER" \
    --hostname oggbd-mongo-trg \
    --network "$NETWORK" \
    --memory 2g \
    --label goldengate.lab.role=mongodb-target-side-remote-capture \
    -e OGG_ADMIN=oggadmin \
    -e 'OGG_ADMIN_PWD=WElcome1234##' \
    -e OGG_DEPLOYMENT="$DEPLOYMENT" \
    "$IMAGE" >/dev/null
fi

echo '==> Wait for target-side OGGBD readiness'
ready=N
for attempt in $(seq 1 90); do
  state=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' \
    "$CONTAINER" 2>/dev/null || true)
  if test "$state" = healthy; then
    ready=Y
    break
  fi
  if test "$state" = exited || test "$state" = dead; then
    docker logs --tail 120 "$CONTAINER"
    exit 1
  fi
  sleep 2
done
if test "$ready" != Y; then
  docker logs --tail 120 "$CONTAINER"
  echo "ERROR: $CONTAINER did not become healthy." >&2
  exit 1
fi

echo '==> Resolve MongoDB Java dependencies with the bundled downloader'
docker exec -u ogg "$CONTAINER" bash -lc '
  set -e
  cd /u01/ogg/opt/DependencyDownloader
  if test ! -d ./dependencies/mongodb_capture_5.0.1; then
    ./mongodb_capture.sh 5.0.1
  fi
  if test ! -d ./dependencies/mongodb_5.0.1; then
    ./mongodb.sh 5.0.1
  fi
'

echo '==> Publish capture dependencies into this deployment'
docker exec -u 0 "$CONTAINER" bash -lc '
  set -e
  dst=/u02/Deployment/etc/conf/ogg/mongodb/lib
  mkdir -p "$dst"
  find /u01/ogg/opt/DependencyDownloader/dependencies/mongodb_capture_5.0.1 \
       /u01/ogg/opt/DependencyDownloader/dependencies/mongodb_5.0.1 \
       -type f -name "*.jar" -exec cp -f {} "$dst" \;
  cp -f /u01/ogg/ggjava/resources/lib/ggmongodbcapture-*.jar "$dst"/
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

echo '==> Verify required capture libraries'
docker exec "$CONTAINER" bash -lc '
  set -e
  lib=/u02/Deployment/etc/conf/ogg/mongodb/lib
  test -n "$(find "$lib" -maxdepth 1 -name "ggmongodbcapture-*.jar" -print -quit)"
  test -n "$(find "$lib" -maxdepth 1 -name "mongodb-driver-reactivestreams-5.0.1.jar" -print -quit)"
  test -n "$(find "$lib" -maxdepth 1 -name "reactive-streams-*.jar" -print -quit)"
  test -n "$(find "$lib" -maxdepth 1 -name "reactor-core-*.jar" -print -quit)"
  find "$lib" -maxdepth 1 -type f -name "*.jar" -printf "%f\n" | sort
'

test -z "$(docker port "$CONTAINER")"
echo "OK: $CONTAINER is healthy with no host-published ports."
