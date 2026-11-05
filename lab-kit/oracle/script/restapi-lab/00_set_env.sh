#!/bin/bash
source ./env.sh

if [ -z "${OGG_PASS:-}" ]; then
  read -rsp "OGG Password: " OGG_PASS
  echo
fi

export OGG_PASS

echo "OGG_BASE_URL=${OGG_BASE_URL}"
echo "OGG_USER=${OGG_USER}"
echo "OGG_PASS is set for this shell."
