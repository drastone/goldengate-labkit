#!/bin/bash
set -euo pipefail

echo "Build Gold channel action candidates"
printf "Host: "; uname -n
printf "Silver table: insurance.silver_customer_fund_activity\n"
printf "Gold table  : insurance.gold_channel_action_candidate\n\n"

docker run --rm -i --network host oracle-demo_pyiceberg_writer python - <<'PY'
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
SILVER = "insurance.silver_customer_fund_activity"
GOLD = "insurance.gold_channel_action_candidate"

schema = Schema(
    NestedField(1, "build_time", TimestampType(), required=False),
    NestedField(2, "cust_id", LongType(), required=False),
    NestedField(3, "activity_date", StringType(), required=False),
    NestedField(4, "action_type", StringType(), required=False),
    NestedField(5, "channel", StringType(), required=False),
    NestedField(6, "priority", StringType(), required=False),
    NestedField(7, "reason", StringType(), required=False),
    NestedField(8, "evidence", StringType(), required=False),
    NestedField(9, "source_op_gubun", StringType(), required=False),
    NestedField(10, "source_op_name", StringType(), required=False),
    NestedField(11, "event_count", LongType(), required=False),
    NestedField(12, "last_op_ts", StringType(), required=False),
    NestedField(13, "last_pos", StringType(), required=False),
)
arrow_schema = pa.schema([
    pa.field("build_time", pa.timestamp("us")),
    pa.field("cust_id", pa.int64()),
    pa.field("activity_date", pa.string()),
    pa.field("action_type", pa.string()),
    pa.field("channel", pa.string()),
    pa.field("priority", pa.string()),
    pa.field("reason", pa.string()),
    pa.field("evidence", pa.string()),
    pa.field("source_op_gubun", pa.string()),
    pa.field("source_op_name", pa.string()),
    pa.field("event_count", pa.int64()),
    pa.field("last_op_ts", pa.string()),
    pa.field("last_pos", pa.string()),
])


def classify(row):
    op = str(row.get("op_gubun") or "")
    events = int(row.get("event_count") or 0)
    name = str(row.get("op_gubun_name") or "")
    if op == "3":
        if events >= 5:
            return "CHURN_CARE", "CALL", "HIGH", "해약/환급 활동이 반복되어 담당 FP의 즉시 상담이 필요"
        return "CHURN_WATCH", "SMS", "MEDIUM", "해약/환급 신호가 있어 고객 안내 메시지 발송 대상"
    if op == "2":
        if events >= 20:
            return "FUND_REBALANCE", "CALL", "HIGH", "펀드변경 활동이 짧은 기간에 집중되어 포트폴리오 점검 필요"
        if events >= 5:
            return "FUND_GUIDE", "EMAIL", "MEDIUM", "펀드변경 활동이 증가하여 상품 안내와 리밸런싱 가이드 발송 대상"
    if op == "4":
        return "UPSELL_CARE", "EMAIL", "MEDIUM", "추가납입 활동이 있어 보장 확대나 상품 안내 후보"
    if op == "5":
        return "SERVICE_FOLLOWUP", "CALL", "MEDIUM", "상담/기타 활동이 있어 후속 연락 필요"
    if op == "1" and events >= 4:
        return "PAYMENT_STATUS", "SMS", "LOW", "납입 활동이 확인되어 납입 상태 알림 후보"
    if op == "0":
        return "MANUAL_REVIEW", "REVIEW", "LOW", "업무구분이 기타로 분류되어 운영자 확인 필요"
    return None

catalog = load_catalog("insurance", **CATALOG_CONFIG)
silver = catalog.load_table(SILVER)
rows = silver.scan().to_arrow().to_pylist()

candidates = []
build_time = datetime.utcnow()
for row in rows:
    decision = classify(row)
    if not decision:
        continue
    action_type, channel, priority, reason = decision
    events = int(row.get("event_count") or 0)
    evidence = (
        f"{row.get('op_gubun_name')} {events}건, "
        f"고객 {row.get('cust_id')}, 활동일 {row.get('activity_date')}, "
        f"마지막 변경 {row.get('last_op_ts')}"
    )
    candidates.append({
        "build_time": build_time,
        "cust_id": int(row.get("cust_id") or 0),
        "activity_date": str(row.get("activity_date") or ""),
        "action_type": action_type,
        "channel": channel,
        "priority": priority,
        "reason": reason,
        "evidence": evidence,
        "source_op_gubun": str(row.get("op_gubun") or ""),
        "source_op_name": str(row.get("op_gubun_name") or ""),
        "event_count": events,
        "last_op_ts": str(row.get("last_op_ts") or ""),
        "last_pos": str(row.get("last_pos") or ""),
    })

priority_rank = {"HIGH": 0, "MEDIUM": 1, "LOW": 2}
candidates.sort(key=lambda r: (priority_rank.get(r["priority"], 9), -r["event_count"], r["cust_id"]))

try:
    catalog.drop_table(GOLD)
except NoSuchTableError:
    pass

table = catalog.create_table(
    GOLD,
    schema=schema,
    partition_spec=PartitionSpec(),
    properties={"format-version": "2"},
)
if candidates:
    table.append(pa.Table.from_pylist(candidates, schema=arrow_schema))

counts = {}
for row in candidates:
    key = (row["priority"], row["channel"])
    counts[key] = counts.get(key, 0) + 1

print(f"Silver rows read : {len(rows)}")
print(f"Gold candidates  : {len(candidates)}")
print(f"Gold table       : {GOLD}")
print("\nCandidate summary by priority/channel:")
print("PRIORITY  CHANNEL  CANDIDATES")
for (priority, channel), count in sorted(counts.items(), key=lambda kv: (priority_rank.get(kv[0][0], 9), kv[0][1])):
    print(f"{priority:<8}  {channel:<7}  {count:10d}")
PY
