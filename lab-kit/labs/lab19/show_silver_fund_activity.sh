#!/bin/bash
set -euo pipefail

echo "Show Silver customer fund activity"
printf "Host: "; uname -n
printf "Silver table: insurance.silver_customer_fund_activity\n\n"

docker run --rm -i --network host oracle-demo_pyiceberg_writer python - <<'PY'
from collections import defaultdict
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
    table = catalog.load_table("insurance.silver_customer_fund_activity")
except NoSuchTableError:
    print("Silver table does not exist. Run build_silver_fund_activity.sh first.")
    raise SystemExit(0)

rows = table.scan().to_arrow().to_pylist()
print(f"Rows: {len(rows)}")

summary = defaultdict(lambda: {"groups": 0, "events": 0, "total_cnt": 0, "customers": set()})
for row in rows:
    key = (str(row.get("op_gubun") or ""), str(row.get("op_gubun_name") or ""))
    summary[key]["groups"] += 1
    summary[key]["events"] += int(row.get("event_count") or 0)
    summary[key]["total_cnt"] += int(row.get("total_cnt") or 0)
    if row.get("cust_id") is not None:
        summary[key]["customers"].add(row.get("cust_id"))

print("\nBusiness activity summary by OP_GUBUN:")
print("OP  OP_NAME       GROUPS    EVENTS    CUSTOMERS  TOTAL_CNT")
for (op, name), item in sorted(summary.items(), key=lambda kv: (kv[0][0], kv[0][1])):
    print(
        f"{op:<2}  {name:<12}  {item['groups']:7d}  {item['events']:8d}  "
        f"{len(item['customers']):9d}  {item['total_cnt']:9d}"
    )

print("\nRepresentative customer activities:")
print("CUST_ID  DATE      OP_NAME       EVENTS  FIRST_OP_TS                 LAST_OP_TS")
seen_ops = set()
for row in sorted(rows, key=lambda r: (str(r.get("op_gubun") or ""), -(r.get("event_count") or 0), r.get("cust_id") or 0)):
    op = str(row.get("op_gubun") or "")
    if op in seen_ops:
        continue
    seen_ops.add(op)
    print(
        f"{row['cust_id']:7d}  {row['activity_date']:<8}  {row['op_gubun_name']:<12}  "
        f"{row['event_count']:6d}  {str(row.get('first_op_ts') or ''):<27}  {str(row.get('last_op_ts') or '')}"
    )
PY
