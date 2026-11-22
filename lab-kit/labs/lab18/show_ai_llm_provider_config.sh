#!/bin/sh
set -eu

CONF_FILE="${1:-ai_llm_provider.conf}"

if [ ! -f "${CONF_FILE}" ]; then
  echo "Configuration file not found: ${CONF_FILE}" >&2
  echo "Run this command in /home/oracle/labs/lab18, or pass the config file path." >&2
  exit 1
fi

awk '
  /^[[:space:]]*#/ { next }
  /^[[:space:]]*$/ { next }
  /^AI_API_KEY=/ {
    key = substr($0, 12)
    if (length(key) <= 8 || key == "<YOUR_PROVIDER_API_KEY>") {
      print $0
    } else {
      print "AI_API_KEY=" substr(key, 1, 4) "************************************" substr(key, length(key) - 3)
    }
    next
  }
  { print }
' "${CONF_FILE}"
