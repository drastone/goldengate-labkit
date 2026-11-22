#!/bin/sh
set -eu

LAB_HOME="${LAB_HOME:-$(CDPATH= cd "$(dirname "$0")" && pwd)}"
DOCKER_IMAGES_DIR="${DOCKER_IMAGES_DIR:-$LAB_HOME/docker-images}"
DOCKER_IMAGES_URL="https://github.com/oracle/docker-images.git"
DOCKER_IMAGES_COMMIT="39593868e0ecc4f78528bea39a0da1556e6d03c3"
LOG_DIR="${LOG_DIR:-$LAB_HOME/logs}"
MIN_FREE_GB="${MIN_FREE_GB:-40}"

DB_MEDIA="$LAB_HOME/oracle/pkg/V1054592-01.zip"
OGG_MEDIA="$LAB_HOME/oracle/pkg/V1054774-01.zip"
DAA_MEDIA="$LAB_HOME/oracle/pkg/V1054834-01.zip"

DB_SHA256="2a5d2583df076209e624dff750829f9a562473c27c8f926d546cf9ad2a1a2efd"
OGG_SHA256="cd9220e74c7e3afe73bd00c40778faf8bee6cb0fb18140eee0e0ad9d4d140f96"
DAA_SHA256="8971fdfeb734a30df09b486f3c49a99ff4335a0daced21a8f70783d783413c45"

DB_IMAGE="oracle/database:23.26.0-ee"
OGG_IMAGE="oracle/goldengate:23.26.1-oracle"
DAA_IMAGE="oracle/oggforbigdata:23.26.1-daa"

STAGED_SOURCE=""
STAGED_TARGET=""
LOG_PIPE=""
TEE_PID=""
CHECK_ONLY=0
START_EPOCH=""

case "${1:-}" in
  "") ;;
  --check-only) CHECK_ONLY=1 ;;
  *)
    echo "Usage: sh $0 [--check-only]"
    exit 2
    ;;
esac

if [ "$CHECK_ONLY" -eq 1 ]; then
  RUN_MODE="precheck"
else
  RUN_MODE="build"
fi

LOG_FILE="${BUILD_BASE_IMAGES_LOG_FILE:-$LOG_DIR/build_base_images_${RUN_MODE}_$(date +%Y%m%d_%H%M%S).log}"

require_command() {
  name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $name"
    exit 1
  fi
}

require_file() {
  path="$1"
  if [ ! -f "$path" ]; then
    echo "ERROR: required product media not found: $path"
    exit 1
  fi
}

verify_sha256() {
  path="$1"
  expected="$2"
  actual="$(sha256sum "$path" | awk '{print $1}')"

  if [ "$actual" != "$expected" ]; then
    echo "ERROR: SHA-256 mismatch: $path"
    echo "Expected: $expected"
    echo "Actual:   $actual"
    exit 1
  fi

  echo "OK: SHA-256 $path"
}

start_logging() {
  mkdir -p "$LOG_DIR"
  LOG_PIPE="${TMPDIR:-/tmp}/build_base_images_log.$$"
  mkfifo "$LOG_PIPE"
  tee -a "$LOG_FILE" <"$LOG_PIPE" &
  TEE_PID="$!"
  exec 3>&1 4>&2
  exec >"$LOG_PIPE" 2>&1
  rm -f "$LOG_PIPE"
  LOG_PIPE=""
  echo "Log file: $LOG_FILE"
  echo "Started at: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  START_EPOCH="$(date +%s)"
}

check_free_space() {
  path="$1"
  label="$2"
  available_kb="$(df -Pk "$path" | awk 'NR == 2 { print $4 }')"
  required_kb="$((MIN_FREE_GB * 1024 * 1024))"

  if [ -z "$available_kb" ]; then
    echo "ERROR: could not determine free space for $path"
    exit 1
  fi
  if [ "$available_kb" -lt "$required_kb" ]; then
    available_gb="$((available_kb / 1024 / 1024))"
    echo "ERROR: $label requires at least ${MIN_FREE_GB} GB free; ${available_gb} GB is available at $path"
    exit 1
  fi

  available_gb="$((available_kb / 1024 / 1024))"
  echo "OK: $label free space ${available_gb} GB (minimum ${MIN_FREE_GB} GB)"
}

check_unexpected_media() {
  path="$1"
  if [ -e "$path" ]; then
    echo "ERROR: product media is outside oracle/pkg: $path"
    echo "Move it back to $LAB_HOME/oracle/pkg before continuing."
    exit 1
  fi
}

restore_staged_media() {
  if [ -z "$STAGED_SOURCE" ] || [ -z "$STAGED_TARGET" ]; then
    return 0
  fi

  if [ -f "$STAGED_TARGET" ]; then
    if [ -e "$STAGED_SOURCE" ]; then
      echo "ERROR: cannot restore $STAGED_TARGET because $STAGED_SOURCE already exists"
      return 1
    fi
    mv "$STAGED_TARGET" "$STAGED_SOURCE"
    echo "OK: restored $STAGED_SOURCE"
  fi

  STAGED_SOURCE=""
  STAGED_TARGET=""
}

cleanup() {
  status="$?"
  trap - 0
  if ! restore_staged_media; then
    status=1
  fi
  if [ -n "$TEE_PID" ]; then
    end_epoch="$(date +%s)"
    elapsed="$((end_epoch - START_EPOCH))"
    hours="$((elapsed / 3600))"
    minutes="$(((elapsed % 3600) / 60))"
    seconds="$((elapsed % 60))"
    echo "Finished at: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf 'Elapsed time: %02d:%02d:%02d\n' "$hours" "$minutes" "$seconds"
    if [ "$status" -eq 0 ]; then
      echo "Result: SUCCESS"
    else
      echo "Result: FAILED (exit code $status)"
    fi
    echo "Log saved: $LOG_FILE"
    exec 1>&3 2>&4
    exec 3>&- 4>&-
    if ! wait "$TEE_PID"; then
      status=1
    fi
  fi
  if [ -n "$LOG_PIPE" ]; then
    rm -f "$LOG_PIPE"
  fi
  exit "$status"
}

stage_media() {
  source_path="$1"
  target_dir="$2"
  target_path="$target_dir/$(basename "$source_path")"

  if [ -e "$target_path" ]; then
    echo "ERROR: build directory already contains product media: $target_path"
    exit 1
  fi

  STAGED_SOURCE="$source_path"
  STAGED_TARGET="$target_path"
  mv "$STAGED_SOURCE" "$STAGED_TARGET"
  echo "OK: staged $STAGED_TARGET"
}

image_exists() {
  docker image inspect "$1" >/dev/null 2>&1
}

trap cleanup 0
trap 'exit 130' HUP INT TERM

require_command awk
require_command date
require_command df
require_command docker
require_command git
require_command mkdir
require_command mkfifo
require_command sha256sum
require_command tee

start_logging

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker Engine is not available."
  exit 1
fi
DOCKER_ROOT="$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || true)"

echo "==> Verify Oracle product media"
require_file "$DB_MEDIA"
require_file "$OGG_MEDIA"
require_file "$DAA_MEDIA"
verify_sha256 "$DB_MEDIA" "$DB_SHA256"
verify_sha256 "$OGG_MEDIA" "$OGG_SHA256"
verify_sha256 "$DAA_MEDIA" "$DAA_SHA256"

echo "==> Check build prerequisites"
check_free_space "$LAB_HOME" "Lab Kit build"
if [ -n "$DOCKER_ROOT" ] && [ -d "$DOCKER_ROOT" ]; then
  check_free_space "$DOCKER_ROOT" "Docker data-root"
fi
if [ -e "$DOCKER_IMAGES_DIR" ] && [ ! -d "$DOCKER_IMAGES_DIR/.git" ]; then
  echo "ERROR: path exists but is not a Git repository: $DOCKER_IMAGES_DIR"
  exit 1
fi
if [ -d "$DOCKER_IMAGES_DIR/.git" ]; then
  check_unexpected_media "$DOCKER_IMAGES_DIR/OracleDatabase/SingleInstance/dockerfiles/23.26.0/$(basename "$DB_MEDIA")"
  check_unexpected_media "$DOCKER_IMAGES_DIR/OracleGoldenGate/23/$(basename "$OGG_MEDIA")"
  check_unexpected_media "$DOCKER_IMAGES_DIR/OracleGoldenGate/23/$(basename "$DAA_MEDIA")"
  if [ -n "$(git -C "$DOCKER_IMAGES_DIR" status --porcelain)" ]; then
    echo "ERROR: uncommitted files exist in $DOCKER_IMAGES_DIR"
    echo "Restore or move those files before continuing."
    exit 1
  fi
fi

if [ "$CHECK_ONLY" -eq 1 ]; then
  echo "OK: base image precheck passed."
  exit 0
fi

echo "==> Prepare Oracle docker-images source"
if [ ! -d "$DOCKER_IMAGES_DIR/.git" ]; then
  if [ -e "$DOCKER_IMAGES_DIR" ]; then
    echo "ERROR: path exists but is not a Git repository: $DOCKER_IMAGES_DIR"
    exit 1
  fi
  git clone "$DOCKER_IMAGES_URL" "$DOCKER_IMAGES_DIR"
fi

if ! git -C "$DOCKER_IMAGES_DIR" cat-file -e "$DOCKER_IMAGES_COMMIT^{commit}" 2>/dev/null; then
  git -C "$DOCKER_IMAGES_DIR" fetch origin "$DOCKER_IMAGES_COMMIT"
fi
git -C "$DOCKER_IMAGES_DIR" checkout --detach "$DOCKER_IMAGES_COMMIT"
echo "OK: validated docker-images commit $DOCKER_IMAGES_COMMIT"

DB_DOCKERFILES="$DOCKER_IMAGES_DIR/OracleDatabase/SingleInstance/dockerfiles"
DB_CONTEXT="$DB_DOCKERFILES/23.26.0"
OGG_CONTEXT="$DOCKER_IMAGES_DIR/OracleGoldenGate/23"

if [ ! -x "$DB_DOCKERFILES/buildContainerImage.sh" ]; then
  echo "ERROR: Database build script not found: $DB_DOCKERFILES/buildContainerImage.sh"
  exit 1
fi
if [ ! -f "$OGG_CONTEXT/Dockerfile" ]; then
  echo "ERROR: GoldenGate Dockerfile not found: $OGG_CONTEXT/Dockerfile"
  exit 1
fi

echo "==> Build $DB_IMAGE"
if image_exists "$DB_IMAGE"; then
  echo "OK: image already exists; skipped $DB_IMAGE"
else
  stage_media "$DB_MEDIA" "$DB_CONTEXT"
  (
    cd "$DB_DOCKERFILES"
    ./buildContainerImage.sh -i -v 23.26.0 -e \
      -t "$DB_IMAGE" \
      -o "--build-arg INSTALL_FILE_1=V1054592-01.zip --progress=plain"
  )
  restore_staged_media
  image_exists "$DB_IMAGE" || {
    echo "ERROR: image was not created: $DB_IMAGE"
    exit 1
  }
fi

echo "==> Build $OGG_IMAGE"
if image_exists "$OGG_IMAGE"; then
  echo "OK: image already exists; skipped $OGG_IMAGE"
else
  stage_media "$OGG_MEDIA" "$OGG_CONTEXT"
  (
    cd "$OGG_CONTEXT"
    docker build -t "$OGG_IMAGE" --build-arg INSTALLER=V1054774-01.zip .
  )
  restore_staged_media
  image_exists "$OGG_IMAGE" || {
    echo "ERROR: image was not created: $OGG_IMAGE"
    exit 1
  }
fi

echo "==> Build $DAA_IMAGE"
if image_exists "$DAA_IMAGE"; then
  echo "OK: image already exists; skipped $DAA_IMAGE"
else
  stage_media "$DAA_MEDIA" "$OGG_CONTEXT"
  (
    cd "$OGG_CONTEXT"
    docker build -t "$DAA_IMAGE" --build-arg INSTALLER=V1054834-01.zip .
  )
  restore_staged_media
  image_exists "$DAA_IMAGE" || {
    echo "ERROR: image was not created: $DAA_IMAGE"
    exit 1
  }
fi

echo "==> Verify base images"
docker image inspect "$DB_IMAGE" "$OGG_IMAGE" "$DAA_IMAGE" >/dev/null
docker image ls --format '{{.Repository}}:{{.Tag}}\t{{.Size}}' | \
  awk '/^oracle\/(database|goldengate|oggforbigdata):/'
echo "OK: Oracle base image build completed."
