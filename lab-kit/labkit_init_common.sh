#!/usr/bin/env bash

select_labkit_utf8_locale() {
  selected_locale=""
  for candidate in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8 ko_KR.UTF-8 ko_KR.utf8; do
    if LANG="${candidate}" LC_ALL="${candidate}" locale charmap 2>/dev/null | grep -qx 'UTF-8'; then
      selected_locale="${candidate}"
      break
    fi
  done

  [ -n "${selected_locale}" ]
}

configure_host_shell_profiles() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Base Linux UTF-8 profile configuration requires root." >&2
    return 1
  fi

  if ! select_labkit_utf8_locale; then
    echo "ERROR: no installed UTF-8 locale is available on Base Linux." >&2
    return 1
  fi

  echo "==> Base Linux: configure UTF-8 shell profiles"
  locale_begin_marker='# BEGIN GOLDENGATE LAB UTF-8'
  locale_end_marker='# END GOLDENGATE LAB UTF-8'
  prompt_begin_marker='# BEGIN GOLDENGATE LAB PROMPT'
  prompt_end_marker='# END GOLDENGATE LAB PROMPT'
  vi_begin_marker='# BEGIN GOLDENGATE LAB ROOT VI MODE'
  vi_end_marker='# END GOLDENGATE LAB ROOT VI MODE'

  update_host_profile() {
    profile="$1"
    [ -f "${profile}" ] || return 0

    sed -i "\|^${locale_begin_marker}$|,\|^${locale_end_marker}$|d" "${profile}"
    sed -i "\|^${prompt_begin_marker}$|,\|^${prompt_end_marker}$|d" "${profile}"
    sed -i '/^# OGG Lab prompt standard$/d' "${profile}"
    sed -i '\|^\[ -f /etc/profile.d/ogg-lab-prompt.sh \] && \. /etc/profile.d/ogg-lab-prompt.sh$|d' "${profile}"
    {
      printf '\n%s\n' "${locale_begin_marker}"
      printf 'export LANG=%s\n' "${selected_locale}"
      printf 'export LC_CTYPE=%s\n' "${selected_locale}"
      printf 'export LC_ALL=%s\n' "${selected_locale}"
      printf '%s\n' "${locale_end_marker}"
      printf '\n%s\n' "${prompt_begin_marker}"
      printf 'if [ -r /etc/profile.d/ogg-lab-prompt.sh ]; then\n'
      printf '  . /etc/profile.d/ogg-lab-prompt.sh\n'
      printf 'fi\n'
      printf '%s\n' "${prompt_end_marker}"
    } >> "${profile}"
  }

  mkdir -p /etc/profile.d
  {
    printf '%s\n' "${locale_begin_marker}"
    printf 'export LANG=%s\n' "${selected_locale}"
    printf 'export LC_CTYPE=%s\n' "${selected_locale}"
    printf 'export LC_ALL=%s\n' "${selected_locale}"
    printf '%s\n' "${locale_end_marker}"
  } > /etc/profile.d/goldengate-lab-utf8.sh
  chmod 644 /etc/profile.d/goldengate-lab-utf8.sh

  printf '%s\n' "export PS1='[\\u \\W]\\\$ '" > /etc/profile.d/ogg-lab-prompt.sh
  chmod 644 /etc/profile.d/ogg-lab-prompt.sh

  touch /root/.bashrc
  sed -i "\|^${vi_begin_marker}$|,\|^${vi_end_marker}$|d" /root/.bashrc
  sed -i '/^[[:space:]]*set -o vi[[:space:]]*$/d' /root/.bashrc
  {
    printf '\n%s\n' "${vi_begin_marker}"
    printf '%s\n' 'set -o vi'
    printf '%s\n' "${vi_end_marker}"
  } >> /root/.bashrc

  for profile in /root/.bashrc /root/.bash_profile /root/.profile \
                 /home/oracle/.bashrc /home/oracle/.bash_profile /home/oracle/.profile; do
    update_host_profile "${profile}"
  done

  export LANG="${selected_locale}"
  export LC_CTYPE="${selected_locale}"
  export LC_ALL="${selected_locale}"
  actual_charmap="$(locale charmap)"
  [ "${actual_charmap}" = "UTF-8" ]
  echo "OK: Base Linux UTF-8 shell locale configured as ${selected_locale}."
  echo "OK: Base Linux shell prompt configured as '[user directory]'."
  echo "OK: Base Linux root shell editing mode configured as vi."
  echo "INFO: Sign in again to apply the UTF-8 locale, standard prompt, and root vi mode to an existing shell."
}

configure_host_utf8_profiles() {
  configure_host_shell_profiles "$@"
}

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
  if LANG="${candidate}" LC_ALL="${candidate}" locale charmap 2>/dev/null | grep -qx 'UTF-8'; then
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
  profile_home=$(dirname "${profile}")
  [ -d "${profile_home}" ] || return 0

  if [ ! -e "${profile}" ]; then
    : > "${profile}"
    profile_owner=$(stat -c '%u:%g' "${profile_home}")
    chown "${profile_owner}" "${profile}"
  fi

  sed -i "\|^${begin_marker}$|,\|^${end_marker}$|d" "${profile}"
  {
    printf '\n%s\n' "${begin_marker}"
    printf 'if [ -r /etc/profile.d/goldengate-lab-utf8.sh ]; then\n'
    printf '  . /etc/profile.d/goldengate-lab-utf8.sh\n'
    printf 'fi\n'
    printf '%s\n' "${end_marker}"
  } >> "${profile}"
}

mkdir -p /etc/profile.d
{
  printf '%s\n' "${begin_marker}"
  printf 'export LANG=%s\n' "${locale_name}"
  printf 'export LC_CTYPE=%s\n' "${locale_name}"
  printf 'export LC_ALL=%s\n' "${locale_name}"
  printf '%s\n' "${end_marker}"
} > /etc/profile.d/goldengate-lab-utf8.sh
chmod 644 /etc/profile.d/goldengate-lab-utf8.sh

configured_profiles=0
for profile_home in /root /home/*; do
  [ -d "${profile_home}" ] || continue
  for profile_name in .bashrc .bash_profile .profile; do
    profile="${profile_home}/${profile_name}"
    update_profile "${profile}"
    profile_charmap=$(bash --noprofile --norc -c '. "$1"; locale charmap' _ "${profile}")
    if [ "${profile_charmap}" != "UTF-8" ]; then
      echo "ERROR: UTF-8 profile verification failed: ${profile}" >&2
      exit 1
    fi
    configured_profiles=$((configured_profiles + 1))
  done
done

actual_charmap=$(LANG="${locale_name}" LC_ALL="${locale_name}" locale charmap)
[ "${actual_charmap}" = "UTF-8" ]
echo "OK: UTF-8 shell locale configured as ${locale_name} in ${configured_profiles} profiles."
CONTAINER_SCRIPT
}
