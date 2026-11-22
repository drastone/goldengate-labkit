#!/bin/bash
set -euo pipefail

LAB_DIR=/home/oracle/labs/lab19
OGG_USER=${OGG_USER:-oggadmin}
OGG_PASSWORD=${OGG_PASSWORD:-WElcome1234##}
STREAM_URL=${STREAM_URL:-http://localhost:9113/services/v2/stream/DS_LAKE}

printf "Reset Chapter 19 Lakehouse objects\n"
printf "Host      : "; uname -n
printf "Lab dir   : %s\n" "$LAB_DIR"
printf "Stream    : DS_LAKE\n"
printf "Iceberg   : insurance.ds_cfund_dt_events\n\n"

docker rm -f demo_iceberg_writer >/dev/null 2>&1 || true
printf "Writer container removed if it existed.\n"

curl -sS --max-time 10 -u "${OGG_USER}:${OGG_PASSWORD}" -X DELETE "$STREAM_URL" >/dev/null 2>&1 || true
printf "Data Stream DS_LAKE removed if it existed.\n"

docker run --rm -i --network host oracle-demo_pyiceberg_writer python - <<PY
from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchTableError
catalog = load_catalog(
    "insurance",
    type="rest",
    uri="http://127.0.0.1:38181",
    **{
        "s3.endpoint": "http://127.0.0.1:38900",
        "s3.access-key-id": "admin",
        "s3.secret-access-key": "WElcome1234##",
        "s3.path-style-access": "true",
    },
)
try:
    catalog.drop_table("insurance.ds_cfund_dt_events")
    print("Iceberg table dropped: insurance.ds_cfund_dt_events")
except NoSuchTableError:
    print("Iceberg table did not exist: insurance.ds_cfund_dt_events")
PY

printf "\nChapter 19 Lakehouse reset completed.\n"
