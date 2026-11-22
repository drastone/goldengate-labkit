#!/bin/sh
set -eu

cd "$(dirname "$0")"

if [ "${LABKIT_LOG_ACTIVE:-}" != "1" ]; then
  mkdir -p logs
  ts="$(date +%Y%m%d_%H%M%S)"
  log_file="$PWD/logs/create_docker_${ts}.log"
  status_file="$PWD/logs/.create_docker_${ts}_$$.status"

  echo "==> Lab Kit create log: ${log_file}"
  (
    set +e
    LABKIT_LOG_ACTIVE=1 LABKIT_LOG_FILE="$log_file" sh "$0" "$@"
    child_rc="$?"
    printf "%s\n" "$child_rc" > "$status_file"
    exit "$child_rc"
  ) 2>&1 | tee "$log_file"

  if [ -f "$status_file" ]; then
    rc="$(cat "$status_file")"
    rm -f "$status_file"
  else
    rc=1
  fi

  exit "$rc"
fi

format_elapsed() {
  total_seconds="$1"
  hours=$((total_seconds / 3600))
  minutes=$(((total_seconds % 3600) / 60))
  seconds=$((total_seconds % 60))
  printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds"
}

finish() {
  rc="$?"
  end_epoch="$(date +%s)"
  elapsed=$((end_epoch - start_epoch))

  if [ "$rc" -eq 0 ]; then
    echo "OK: Lab Kit create completed at $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "OK: Lab Kit create elapsed time: $(format_elapsed "$elapsed") (${elapsed}s)"
    echo "OK: Lab Kit create log file: ${LABKIT_LOG_FILE:-}"
  else
    echo "ERROR: Lab Kit create failed at $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "ERROR: Lab Kit create elapsed time: $(format_elapsed "$elapsed") (${elapsed}s)"
    echo "ERROR: Lab Kit create log file: ${LABKIT_LOG_FILE:-}"
    echo "Check the first ERROR or FATAL line above. If the log mentions buildkitsandbox, apply the latest GitHub Lab Kit files and rerun."
  fi
}

start_epoch="$(date +%s)"
trap finish EXIT

echo "==> Lab Kit create started at $(date '+%Y-%m-%d %H:%M:%S %Z')"

LABKIT_INIT_COMMON="${LABKIT_INIT_COMMON:-./labkit_init_common.sh}"
if [ ! -f "${LABKIT_INIT_COMMON}" ]; then
  echo "ERROR: Lab Kit init helper not found: ${LABKIT_INIT_COMMON}" >&2
  exit 1
fi
. "${LABKIT_INIT_COMMON}"
configure_host_shell_profiles

LABKIT_CORE_SERVICES="oracle_src_23ai oracle_trg_23ai oracle_ogg_23ai oracle_oggbd_23ai oracle_centos"
LABKIT_REQUESTED_SERVICES="${LABKIT_SERVICES:-$*}"
if [ -n "$LABKIT_REQUESTED_SERVICES" ]; then
  LABKIT_SERVICES="$LABKIT_REQUESTED_SERVICES"
  LABKIT_DEFAULT_CREATE=N
else
  LABKIT_SERVICES="$LABKIT_CORE_SERVICES"
  LABKIT_DEFAULT_CREATE=Y
fi
LABKIT_LAKEHOUSE_CREATE_SERVICES="${LABKIT_LAKEHOUSE_CREATE_SERVICES:-demo_minio demo_iceberg_catalog}"
LABKIT_PRECREATE_LAKEHOUSE="${LABKIT_PRECREATE_LAKEHOUSE:-Y}"
LABKIT_LAKEHOUSE_WRITER_IMAGE_HELPER="${LABKIT_LAKEHOUSE_WRITER_IMAGE_HELPER:-./iceberg/pywriter/ensure_image.sh}"
LABKIT_SKIP_PREFLIGHT="${LABKIT_SKIP_PREFLIGHT:-N}"
LABKIT_SKIP_ORACLE_INIT="${LABKIT_SKIP_ORACLE_INIT:-N}"
LABKIT_SKIP_CENTOS_INIT="${LABKIT_SKIP_CENTOS_INIT:-N}"

has_service() {
  expected="$1"

  for service in $LABKIT_SERVICES; do
    if [ "$service" = "$expected" ]; then
      return 0
    fi
  done

  return 1
}

run_oracle_init() {
  if [ -z "$LABKIT_SERVICES" ]; then
    return 0
  fi

  has_service oracle_src_23ai || \
    has_service oracle_trg_23ai || \
    has_service oracle_ogg_23ai || \
    has_service oracle_oggbd_23ai
}

run_centos_init() {
  if [ -z "$LABKIT_SERVICES" ]; then
    return 0
  fi

  has_service oracle_centos
}

verify_service_running() {
  service="$1"
  container_id="$(docker compose ps -a -q "$service" 2>/dev/null || true)"

  if [ -z "$container_id" ]; then
    echo "ERROR: compose service did not create a container: $service"
    return 1
  fi

  status="$(docker inspect -f '{{.State.Status}}' "$container_id" 2>/dev/null || true)"
  if [ "$status" = "running" ]; then
    echo "OK: $service container is running."
    return 0
  fi

  echo "ERROR: $service container is not running (status: ${status:-unknown})."
  echo "==> Recent container log: $service"
  docker logs --tail 100 "$container_id" 2>&1 || true
  return 1
}

verify_service_created() {
  service="$1"
  container_id="$(docker compose ps -a -q "$service" 2>/dev/null || true)"

  if [ -z "$container_id" ]; then
    echo "ERROR: optional compose service did not create a container: $service"
    return 1
  fi

  status="$(docker inspect -f '{{.State.Status}}' "$container_id" 2>/dev/null || true)"
  case "$status" in
    created|exited)
      echo "OK: $service container is prepared and not running (status: $status)."
      ;;
    running)
      echo "INFO: $service container already exists and is running."
      ;;
    *)
      echo "ERROR: $service container has an unexpected status: ${status:-unknown}."
      return 1
      ;;
  esac
}

echo "==> Requested compose service(s): $LABKIT_SERVICES"

if [ "$LABKIT_SKIP_PREFLIGHT" = "Y" ]; then
  echo "==> Skip Lab Kit preflight checks"
else
  echo "==> Run Lab Kit preflight checks"
  sh ./check_labkit.sh
fi

echo "==> Build and start Lab Kit containers"
export DOCKER_BUILDKIT="${DOCKER_BUILDKIT:-0}"
export COMPOSE_DOCKER_CLI_BUILD="${COMPOSE_DOCKER_CLI_BUILD:-0}"
echo "==> Docker build mode: DOCKER_BUILDKIT=${DOCKER_BUILDKIT}, COMPOSE_DOCKER_CLI_BUILD=${COMPOSE_DOCKER_CLI_BUILD}"
if [ -n "$LABKIT_SERVICES" ]; then
  docker compose up -d --build $LABKIT_SERVICES
else
  docker compose up -d --build
fi

echo "==> Verify requested containers are running"
service_failures=0
for service in $LABKIT_SERVICES; do
  if ! verify_service_running "$service"; then
    service_failures=$((service_failures + 1))
  fi
done
if [ "$service_failures" -ne 0 ]; then
  echo "ERROR: $service_failures requested container(s) failed to stay running."
  docker compose ps -a || true
  exit 1
fi

if [ "$LABKIT_SKIP_ORACLE_INIT" = "Y" ]; then
  echo "==> Skip Oracle initialization"
elif run_oracle_init; then
  echo "==> Run Oracle initialization"
  sh ./oracle/init.sh
else
  echo "==> Skip Oracle initialization for selected service(s)"
fi

if [ "$LABKIT_SKIP_CENTOS_INIT" = "Y" ]; then
  echo "==> Skip Big Data/analytics initialization"
elif run_centos_init; then
  echo "==> Run Big Data/analytics initialization"
  sh ./centos/init.sh
else
  echo "==> Skip Big Data/analytics initialization for selected service(s)"
fi

if [ "$LABKIT_DEFAULT_CREATE" = "Y" ] && [ "$LABKIT_PRECREATE_LAKEHOUSE" = "Y" ]; then
  echo "==> Prepare the optional Chapter 19 PyIceberg writer image"
  if [ ! -f "$LABKIT_LAKEHOUSE_WRITER_IMAGE_HELPER" ]; then
    echo "ERROR: Chapter 19 writer image helper not found: $LABKIT_LAKEHOUSE_WRITER_IMAGE_HELPER"
    exit 1
  fi
  sh "$LABKIT_LAKEHOUSE_WRITER_IMAGE_HELPER"

  echo "==> Prepare optional Chapter 19 Lakehouse containers without starting them"
  docker compose create $LABKIT_LAKEHOUSE_CREATE_SERVICES

  lakehouse_failures=0
  for service in $LABKIT_LAKEHOUSE_CREATE_SERVICES; do
    if ! verify_service_created "$service"; then
      lakehouse_failures=$((lakehouse_failures + 1))
    fi
  done
  if [ "$lakehouse_failures" -ne 0 ]; then
    echo "ERROR: $lakehouse_failures optional Lakehouse container(s) were not prepared."
    docker compose ps -a || true
    exit 1
  fi
  echo "INFO: Chapter 19 starts these containers later with start_lab19_lakehouse.sh."
elif [ "$LABKIT_DEFAULT_CREATE" != "Y" ]; then
  echo "INFO: Selected-service create; skip optional Chapter 19 Lakehouse container preparation."
else
  echo "INFO: LABKIT_PRECREATE_LAKEHOUSE=$LABKIT_PRECREATE_LAKEHOUSE; skip optional Chapter 19 Lakehouse container preparation."
fi
