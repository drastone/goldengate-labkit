#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash cleanup_docker_build_cache.sh [--check]

Without an option, the script shows Docker disk usage and asks for explicit
confirmation before removing unused Docker build cache. It does not remove
images, containers, volumes, or networks.

Options:
  --check  Show Docker and host storage usage without deleting build cache.
  -h, --help  Show this help.
EOF
}

show_usage() {
  printf '%s\n' '==> Docker disk usage'
  docker system df

  if [ -d /mnt/d ]; then
    printf '%s\n' '==> Windows D drive usage'
    df -h /mnt/d
  else
    docker_root="$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || true)"
    if [ -n "${docker_root}" ] && [ -e "${docker_root}" ]; then
      printf '%s\n' '==> Docker filesystem usage'
      df -h "${docker_root}"
    fi
  fi
}

case "${1:-}" in
  '') ;;
  --check)
    check_only=Y
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    printf 'ERROR: unknown option: %s\n' "$1" >&2
    usage >&2
    exit 2
    ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' 'ERROR: docker command was not found.' >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  printf '%s\n' 'ERROR: Docker daemon is not reachable.' >&2
  exit 1
fi

show_usage

if [ "${check_only:-N}" = Y ]; then
  printf '%s\n' 'OK: check completed; no Docker data was deleted.'
  exit 0
fi

cat <<'EOF'

This removes all unused Docker build cache.
It does not remove images, containers, volumes, or networks.
Future image builds may take longer because the cache must be rebuilt.
EOF

printf 'Remove unused Docker build cache? [Y/N]: '
IFS= read -r answer
case "${answer}" in
  Y|y|YES|Yes|yes)
    ;;
  *)
    printf '%s\n' 'INFO: canceled; no Docker data was deleted.'
    exit 0
    ;;
esac

printf '%s\n' '==> Remove unused Docker build cache'
docker builder prune --all --force

printf '\n%s\n' '==> Usage after cleanup'
show_usage

cat <<'EOF'
OK: unused Docker build cache cleanup completed.
INFO: WSL filesystem space is now reusable inside Linux.
INFO: the Windows ext4.vhdx file may not shrink immediately.
INFO: if Windows drive usage stays high, stop WSL and follow the current
INFO: Microsoft WSL disk-space guidance before compacting the VHDX.
EOF
