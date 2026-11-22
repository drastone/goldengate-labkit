#!/bin/bash
set -euo pipefail

echo "Show Bronze CDC events"
printf "Host: "; uname -n
printf "Bronze table: insurance.ds_cfund_dt_events\n\n"

docker run --rm -i --network host oracle-demo_pyiceberg_writer python - <<'PY'
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
    table = catalog.load_table("insurance.ds_cfund_dt_events")
except NoSuchTableError:
    print("Bronze table does not exist. Run the Data Streams writer first.")
    raise SystemExit(0)

rows = table.scan(
    selected_fields=("cust_id", "dt", "op_gubun", "cnt", "op_type", "op_ts", "pos"),
    limit=8,
).to_arrow().to_pylist()

print("Sample Bronze CDC event rows:")
print("CUST_ID  DATE      OP  OP_TYPE  CNT  OP_TS                         POS_PREFIX")
for row in rows:
    pos = str(row.get("pos") or "")
    print(
        f"{row.get('cust_id') or 0:7d}  {str(row.get('dt') or ''):<8}  {str(row.get('op_gubun') or ''):<2}  "
        f"{str(row.get('op_type') or ''):<7}  {row.get('cnt') or 0:3d}  "
        f"{str(row.get('op_ts') or ''):<27}  {pos[:24]}..."
    )
PY
