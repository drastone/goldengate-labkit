#!/bin/sh
set -eu

cd "$(dirname "$0")"

if ! command -v bash >/dev/null 2>&1; then
  echo "ERROR: required command not found: bash"
  exit 1
fi

echo "==> Validate shell script syntax"
shell_syntax_failures=0
for script in $(find . -type f \( -name '*.sh' -o -name '*.bash' \) -print); do
  if ! bash -n "$script"; then
    echo "ERROR: invalid bash syntax: $script"
    shell_syntax_failures=$((shell_syntax_failures + 1))
  fi
done
for script in $(find labs -type f -name 'lab*_init.sh' -print); do
  if ! sh -n "$script"; then
    echo "ERROR: $script cannot be entered with the documented sh command."
    shell_syntax_failures=$((shell_syntax_failures + 1))
    continue
  fi
  if ! head -n 24 "$script" | grep -q 'exec bash'; then
    echo "ERROR: init script lacks the documented sh-to-bash handoff: $script"
    shell_syntax_failures=$((shell_syntax_failures + 1))
  fi
done
if [ "$shell_syntax_failures" -ne 0 ]; then
  echo "ERROR: shell syntax validation failed with $shell_syntax_failures issue(s)."
  exit 1
fi
echo "OK: reader-facing shell scripts passed syntax validation."

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: required command not found: docker"
  echo "Install Docker Engine and Docker Compose plugin before running the Lab Kit."
  exit 1
fi

build_context_failures=0

check_build_context_path() {
  path="$1"

  if [ -e "$path" ]; then
    echo "OK: $path"
    return 0
  fi

  echo "ERROR: missing build context path: $path"
  build_context_failures=$((build_context_failures + 1))
}

check_build_context_executable() {
  path="$1"

  if [ -x "$path" ]; then
    echo "OK: executable $path"
    return 0
  fi

  echo "ERROR: build context file is not executable: $path"
  build_context_failures=$((build_context_failures + 1))
}

echo "==> Validate Docker build context"
check_build_context_path "build_base_images.sh"
check_build_context_path "labs/lab05/lab05_commands.txt"
check_build_context_executable "startDocker.sh"
check_build_context_executable "labs/lab09/lab09_init.sh"
check_build_context_executable "troubleshooting/scripts/ensure_apex_static_path.sh"
check_build_context_executable "troubleshooting/scripts/refresh_apex_demo_accounts.sh"
check_build_context_path "labs/lab12/lab12_commands.txt"
check_build_context_executable "labs/lab12/lab12_init.sh"
check_build_context_executable "labs/lab12/lab12_common.sh"
check_build_context_executable "labs/lab12/lab12_setup_db.sh"
check_build_context_executable "labs/lab12/lab12_configure_source_apps.sh"
check_build_context_executable "labs/lab12/lab12_prepare_media.sh"
check_build_context_executable "labs/lab12/lab12_install_apex.sh"
check_build_context_executable "labs/lab12/lab12_install_ords.sh"
check_build_context_executable "labs/lab12/check_lab12.sh"
check_build_context_executable "labs/lab12/remove_apex.sh"
check_build_context_executable "labs/lab12/remove_ords.sh"
check_build_context_executable "labs/lab12/lab12_reset.sh"
check_build_context_executable "labs/lab13/lab13_init.sh"
check_build_context_executable "labs/lab18/lab18_init.sh"
check_build_context_executable "labs/lab18/lab18_init.bash"
check_build_context_executable "labs/lab20/lab20_init.sh"
check_build_context_path "labs/lab12/apps/f100.sql"
check_build_context_path "labs/lab12/apps/f102.sql"
check_build_context_path "labs/lab12/apps/f110.sql"
check_build_context_path "labs/lab12/apps/f120.sql"
check_build_context_path "labs/lab12/apps/f130.sql"
check_build_context_path "labs/lab12/apps/f140.sql"
check_build_context_path "labs/lab12/apps/repair_subscribed_theme.sql"
check_build_context_path "oracle/.bash_profile"
check_build_context_path "oracle/setMSAEnv.sh"
check_build_context_path "oracle/msa"
check_build_context_path "oracle/script"
check_build_context_path "oracle/pkg"
check_build_context_path "oracle/ogg_api_server.py"
check_build_context_path "oracle/fabric_apply_service.py"
check_build_context_path "oracle/98_start_fabric_apply_service.sh"
check_build_context_path "oracle/99_start_ogg_api_ogghub.sh"
check_build_context_path "oracle/99_start_ogg_api_oggbd.sh"
check_build_context_path "oracle/script/ogg"
check_build_context_path "oracle/script/ogg/obey"
check_build_context_path "oracle/script/ogg/obey/add_dpkaf01.oby"
check_build_context_path "oracle/script/ogg/params/d01.prm"
check_build_context_path "centos/script"
check_build_context_executable "centos/script/reset_osa_kafka_topics.sh"
check_build_context_path "centos/conf"
check_build_context_path "centos/initSSH.sh"
check_build_context_path "centos/zookeeper.service"
check_build_context_path "centos/kafka.service"
check_build_context_path "centos/setOggBD.sh"
check_build_context_path "centos/server.properties"
check_build_context_executable "oracle/ogg_api_server.py"
check_build_context_executable "build_base_images.sh"
check_build_context_executable "oracle/fabric_apply_service.py"
check_build_context_executable "oracle/98_start_fabric_apply_service.sh"
check_build_context_executable "oracle/99_start_ogg_api_ogghub.sh"
check_build_context_executable "oracle/99_start_ogg_api_oggbd.sh"

if [ "$build_context_failures" -ne 0 ]; then
  echo "ERROR: Docker build context preflight failed with $build_context_failures issue(s)."
  echo "Download and apply the latest complete Lab Kit release before running create_docker.sh."
  exit 1
fi
echo "OK: Docker build context is complete."

echo "==> Validate reader port bindings"
if grep -q '127\.0\.0\.1:' docker-compose.yml; then
  echo "OK: local-only reader services use explicit 127.0.0.1 bindings."
else
  echo "INFO: no published ports are restricted to 127.0.0.1."
fi

echo "==> Validate docker-compose.yml"
if ! docker compose config --services >/dev/null; then
  echo "ERROR: docker-compose.yml is not valid or Docker Compose is not available."
  echo "Check Docker Compose installation and the latest Lab Kit docker-compose.yml in the GitHub online appendix."
  exit 1
fi
echo "OK: docker-compose.yml is valid."

echo "==> Pull external container images"
if ! docker compose pull --ignore-buildable --policy missing; then
  echo "ERROR: Failed to pull one or more external container images."
  echo "Check the GitHub online appendix and apply the latest Lab Kit docker-compose.yml, Dockerfile, and script files."
  exit 1
fi
echo "OK: external container images are ready."

echo "==> Check build-time download URLs and local product media"
if ! sh ./preflight_downloads.sh; then
  echo "ERROR: Lab Kit download/media preflight failed."
  echo "Fix the ERROR lines above, apply the latest GitHub Lab Kit files if needed, then run sh check_labkit.sh again."
  exit 1
fi

echo "OK: Lab Kit preflight checks passed."
