#!/bin/bash
set -euo pipefail

echo "Build Silver customer fund activity"
printf "Host: "; uname -n
printf "Bronze table: insurance.ds_cfund_dt_events\n"
printf "Silver table: insurance.silver_customer_fund_activity\n\n"

docker run --rm -i --network host oracle-demo_pyiceberg_writer python - <<'PY'
from collections import defaultdict
from datetime import datetime

import pyarrow as pa
from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchTableError
from pyiceberg.partitioning import PartitionSpec
from pyiceberg.schema import Schema
from pyiceberg.types import LongType, NestedField, StringType, TimestampType

CATALOG_CONFIG = {
    "type": "rest",
    "uri": "http://127.0.0.1:38181",
    "s3.endpoint": "http://127.0.0.1:38900",
    "s3.access-key-id": "admin",
    "s3.secret-access-key": "WElcome1234##",
    "s3.path-style-access": "true",
}
BRONZE = "insurance.ds_cfund_dt_events"
SILVER = "insurance.silver_customer_fund_activity"

OP_GUBUN_NAME = {
    "1": "납입",
    "2": "펀드변경",
    "3": "해약/환급",
    "4": "추가납입",
    "5": "상담/기타",
}

schema = Schema(
    NestedField(1, "build_time", TimestampType(), required=False),
    NestedField(2, "cust_id", LongType(), required=False),
    NestedField(3, "activity_date", StringType(), required=False),
    NestedField(4, "op_gubun", StringType(), required=False),
    NestedField(5, "op_gubun_name", StringType(), required=False),
    NestedField(6, "event_count", LongType(), required=False),
    NestedField(7, "total_cnt", LongType(), required=False),
    NestedField(8, "insert_count", LongType(), required=False),
    NestedField(9, "update_count", LongType(), required=False),
    NestedField(10, "delete_count", LongType(), required=False),
    NestedField(11, "first_op_ts", StringType(), required=False),
    NestedField(12, "last_op_ts", StringType(), required=False),
    NestedField(13, "last_pos", StringType(), required=False),
)
arrow_schema = pa.schema([
    pa.field("build_time", pa.timestamp("us")),
    pa.field("cust_id", pa.int64()),
    pa.field("activity_date", pa.string()),
    pa.field("op_gubun", pa.string()),
    pa.field("op_gubun_name", pa.string()),
    pa.field("event_count", pa.int64()),
    pa.field("total_cnt", pa.int64()),
    pa.field("insert_count", pa.int64()),
    pa.field("update_count", pa.int64()),
    pa.field("delete_count", pa.int64()),
    pa.field("first_op_ts", pa.string()),
    pa.field("last_op_ts", pa.string()),
    pa.field("last_pos", pa.string()),
])

catalog = load_catalog("insurance", **CATALOG_CONFIG)
bronze = catalog.load_table(BRONZE)
rows = bronze.scan(
    selected_fields=("cust_id", "dt", "op_gubun", "cnt", "op_type", "op_ts", "pos")
).to_arrow().to_pylist()

agg = defaultdict(lambda: {
    "event_count": 0,
    "total_cnt": 0,
    "insert_count": 0,
    "update_count": 0,
    "delete_count": 0,
    "first_op_ts": None,
    "last_op_ts": None,
    "last_pos": None,
})

for row in rows:
    cust_id = row.get("cust_id")
    activity_date = row.get("dt")
    op_gubun = row.get("op_gubun")
    if cust_id is None or not activity_date or not op_gubun:
        continue
    key = (cust_id, activity_date, op_gubun)
    item = agg[key]
    item["event_count"] += 1
    item["total_cnt"] += int(row.get("cnt") or 0)
    op_type = str(row.get("op_type") or "").upper()
    if op_type == "INSERT":
        item["insert_count"] += 1
    elif op_type == "UPDATE":
        item["update_count"] += 1
    elif op_type == "DELETE":
        item["delete_count"] += 1
    op_ts = row.get("op_ts")
    if op_ts:
        if item["first_op_ts"] is None or op_ts < item["first_op_ts"]:
            item["first_op_ts"] = op_ts
        if item["last_op_ts"] is None or op_ts >= item["last_op_ts"]:
            item["last_op_ts"] = op_ts
            item["last_pos"] = row.get("pos")

build_time = datetime.utcnow()
silver_rows = []
for (cust_id, activity_date, op_gubun), item in agg.items():
    silver_rows.append({
        "build_time": build_time,
        "cust_id": int(cust_id),
        "activity_date": str(activity_date),
        "op_gubun": str(op_gubun),
        "op_gubun_name": OP_GUBUN_NAME.get(str(op_gubun), "기타"),
        **item,
    })

silver_rows.sort(key=lambda r: (r["activity_date"], r["cust_id"], r["op_gubun"]))

try:
    catalog.drop_table(SILVER)
except NoSuchTableError:
    pass

table = catalog.create_table(
    SILVER,
    schema=schema,
    partition_spec=PartitionSpec(),
    properties={"format-version": "2"},
)
if silver_rows:
    table.append(pa.Table.from_pylist(silver_rows, schema=arrow_schema))

print(f"Bronze rows read : {len(rows)}")
print(f"Silver rows built: {len(silver_rows)}")
print(f"Silver table     : {SILVER}")
PY
