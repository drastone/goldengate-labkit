#!/usr/bin/env bash

configure_container_utf8_profiles() {
  container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "WARN: UTF-8 profile: container not found: ${container}"
    return 0
  fi

  echo "==> ${container}: configure UTF-8 shell profiles"
  docker exec -i -u root "${container}" bash -s <<'CONTAINER_SCRIPT'
set -eu

locale_name=""
for candidate in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8 ko_KR.UTF-8 ko_KR.utf8; do
  if LANG="${candidate}" LC_CTYPE="${candidate}" locale charmap 2>/dev/null | grep -qx 'UTF-8'; then
    locale_name="${candidate}"
    break
  fi
done

if [ -z "${locale_name}" ]; then
  echo "ERROR: no installed UTF-8 locale is available."
  exit 1
fi

begin_marker='# BEGIN GOLDENGATE LAB UTF-8'
end_marker='# END GOLDENGATE LAB UTF-8'

update_profile() {
  profile="$1"
  [ -f "${profile}" ] || return 0

  sed -i "\|^${begin_marker}$|,\|^${end_marker}$|d" "${profile}"
  {
    printf '\n%s\n' "${begin_marker}"
    printf 'export LANG=%s\n' "${locale_name}"
    printf 'export LC_CTYPE=%s\n' "${locale_name}"
    printf '%s\n' "${end_marker}"
  } >> "${profile}"
}

mkdir -p /etc/profile.d
{
  printf '%s\n' "${begin_marker}"
  printf 'export LANG=%s\n' "${locale_name}"
  printf 'export LC_CTYPE=%s\n' "${locale_name}"
  printf '%s\n' "${end_marker}"
} > /etc/profile.d/goldengate-lab-utf8.sh
chmod 644 /etc/profile.d/goldengate-lab-utf8.sh

for profile in /root/.bashrc /root/.bash_profile /root/.profile \
               /home/*/.bashrc /home/*/.bash_profile /home/*/.profile; do
  update_profile "${profile}"
done

actual_charmap=$(LANG="${locale_name}" LC_CTYPE="${locale_name}" locale charmap)
[ "${actual_charmap}" = "UTF-8" ]
echo "OK: UTF-8 shell locale configured as ${locale_name}."
CONTAINER_SCRIPT
}
