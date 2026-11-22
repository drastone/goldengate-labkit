#!/usr/bin/env bash
set -eu

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
  ssh-keygen -b 2048 -t rsa -f "${HOME}/.ssh/id_rsa" -q -N ""
fi

touch "${HOME}/.ssh/authorized_keys"
if ! grep -qxF "$(cat "${HOME}/.ssh/id_rsa.pub")" "${HOME}/.ssh/authorized_keys"; then
  cat "${HOME}/.ssh/id_rsa.pub" >> "${HOME}/.ssh/authorized_keys"
fi
chmod 600 "${HOME}/.ssh/authorized_keys"

ssh -o BatchMode=yes -o StrictHostKeyChecking=no localhost true
