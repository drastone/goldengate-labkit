#!/bin/bash
set -euo pipefail

echo "Show Gold channel action data product"
printf "Host: "; uname -n
printf "Gold table: insurance.gold_channel_action_candidate\n\n"

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
    table = catalog.load_table("insurance.gold_channel_action_candidate")
except NoSuchTableError:
    print("Gold table does not exist. Run build_gold_channel_action.sh first.")
    raise SystemExit(0)

rows = table.scan().to_arrow().to_pylist()
priority_rank = {"HIGH": 0, "MEDIUM": 1, "LOW": 2}
print(f"Rows: {len(rows)}")

channel_summary = defaultdict(int)
for row in rows:
    channel_summary[(row.get("priority"), row.get("channel"))] += 1

print("\nChannel workload summary:")
print("PRIORITY  CHANNEL  CANDIDATES")
for (priority, channel), count in sorted(channel_summary.items(), key=lambda kv: (priority_rank.get(kv[0][0], 9), kv[0][1] or "")):
    print(f"{priority:<8}  {channel:<7}  {count:10d}")

action_groups = defaultdict(list)
for row in rows:
    action_groups[row.get("action_type")].append(row)

print("\nGold data product by action type:")
print("ACTION_TYPE       PRIORITY  CHANNEL  CANDIDATES  EXAMPLE_CUST  REASON")
for action_type, items in sorted(
    action_groups.items(),
    key=lambda kv: (priority_rank.get(kv[1][0].get("priority"), 9), kv[0] or ""),
):
    items = sorted(items, key=lambda r: (-int(r.get("event_count") or 0), r.get("cust_id") or 0))
    example = items[0]
    reason = str(example.get("reason") or "")
    if len(reason) > 34:
        reason = reason[:31] + "..."
    print(
        f"{action_type:<16}  {example['priority']:<8}  {example['channel']:<7}  "
        f"{len(items):10d}  {example['cust_id']:12d}  {reason}"
    )
PY
