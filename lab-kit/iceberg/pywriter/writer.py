"""
Kafka → PyIceberg → MinIO(S3) 마이크로배치 Writer
GoldenGate CFUND_DT 데이터를 30초마다 Iceberg에 적재
"""
import json
import logging
import time
from datetime import datetime, timezone
from kafka import KafkaConsumer
from kafka.errors import NoBrokersAvailable
import pyarrow as pa
from pyiceberg.catalog import load_catalog
from pyiceberg.schema import Schema
from pyiceberg.types import (
    NestedField, TimestampType, StringType, LongType
)
from pyiceberg.partitioning import PartitionSpec, PartitionField
from pyiceberg.transforms import IdentityTransform
from pyiceberg.exceptions import NoSuchTableError, NoSuchNamespaceError

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)

KAFKA_BOOTSTRAP = '172.28.0.11:9092'
KAFKA_TOPIC     = 'FREEPDB1.SOE.CFUND_DT'
BATCH_INTERVAL  = 30  # 초마다 Iceberg에 적재
BATCH_MAX_ROWS  = 5000

OP_LABELS = {
    '1':'정기납입','2':'추가납입','3':'중도인출',
    '4':'펀드변경','5':'해약','6':'신계약'
}

CATALOG_CONFIG = {
    "type": "rest",
    "uri": "http://172.28.0.36:8181",
    "s3.endpoint": "http://172.28.0.38:9000",
    "s3.access-key-id": "admin",
    "s3.secret-access-key": "WElcome1234##",
    "s3.path-style-access": "true",
}

ICEBERG_SCHEMA = Schema(
    NestedField(1,  "ingestion_time", TimestampType(), required=False),
    NestedField(2,  "op_type",        StringType(),    required=False),
    NestedField(3,  "op_ts",          StringType(),    required=False),
    NestedField(4,  "cust_id",        LongType(),      required=False),
    NestedField(5,  "fund_code",      StringType(),    required=False),
    NestedField(6,  "fund_name",      StringType(),    required=False),
    NestedField(7,  "fund_amt",       LongType(),      required=False),
    NestedField(8,  "op_gubun",       StringType(),    required=False),
    NestedField(9,  "op_label",       StringType(),    required=False),
    NestedField(10, "op_gubun2",      StringType(),    required=False),
    NestedField(11, "dt",             StringType(),    required=False),
)

PARTITION_SPEC = PartitionSpec(
    PartitionField(
        source_id=8, field_id=1000,
        transform=IdentityTransform(), name="op_gubun"
    )
)


def wait_for_kafka(retries=30, delay=5):
    for i in range(retries):
        try:
            c = KafkaConsumer(bootstrap_servers=KAFKA_BOOTSTRAP)
            c.close()
            logger.info("Kafka 연결 성공")
            return True
        except NoBrokersAvailable:
            logger.info(f"Kafka 대기 중... ({i+1}/{retries})")
            time.sleep(delay)
    return False


def wait_for_catalog(retries=20, delay=5):
    for i in range(retries):
        try:
            catalog = load_catalog("insurance", **CATALOG_CONFIG)
            catalog.list_namespaces()
            logger.info("Iceberg REST Catalog 연결 성공")
            return catalog
        except Exception as e:
            logger.info(f"Catalog 대기 중... ({i+1}/{retries}): {e}")
            time.sleep(delay)
    return None


def ensure_table(catalog):
    ns = ("insurance",)
    try:
        catalog.list_tables(ns)
    except NoSuchNamespaceError:
        catalog.create_namespace(ns)
        logger.info("Namespace 'insurance' 생성")

    try:
        return catalog.load_table("insurance.cfund_transactions")
    except NoSuchTableError:
        table = catalog.create_table(
            "insurance.cfund_transactions",
            schema=ICEBERG_SCHEMA,
            partition_spec=PARTITION_SPEC,
            properties={"format-version": "2", "write.target-file-size-bytes": "67108864"}
        )
        logger.info("Iceberg 테이블 'insurance.cfund_transactions' 생성")
        return table


def parse_message(msg):
    try:
        raw = msg.value
        after = raw.get("after", {})
        if not after or raw.get("op_type") != "I":
            return None
        op_gubun = str(after.get("OP_GUBUN", ""))
        return {
            "ingestion_time": datetime.utcnow(),
            "op_type":   str(raw.get("op_type", "")),
            "op_ts":     str(raw.get("op_ts", "")),
            "cust_id":   int(after.get("CUST_ID") or 0),
            "fund_code": str(after.get("FUND_CODE", "")),
            "fund_name": str(after.get("FUND_NAME", "")),
            "fund_amt":  int(after.get("FUND_AMT") or 0),
            "op_gubun":  op_gubun,
            "op_label":  OP_LABELS.get(op_gubun, f"기타({op_gubun})"),
            "op_gubun2": str(after.get("OP_GUBUN2", "")),
            "dt":        str(after.get("DT", "")),
        }
    except Exception:
        return None


def write_batch(table, rows):
    if not rows:
        return 0
    arrow_table = pa.Table.from_pylist(rows, schema=pa.schema([
        pa.field("ingestion_time", pa.timestamp("us")),
        pa.field("op_type",   pa.string()),
        pa.field("op_ts",     pa.string()),
        pa.field("cust_id",   pa.int64()),
        pa.field("fund_code", pa.string()),
        pa.field("fund_name", pa.string()),
        pa.field("fund_amt",  pa.int64()),
        pa.field("op_gubun",  pa.string()),
        pa.field("op_label",  pa.string()),
        pa.field("op_gubun2", pa.string()),
        pa.field("dt",        pa.string()),
    ]))
    table.append(arrow_table)
    return len(rows)


def main():
    logger.info("=== PyIceberg Writer 시작 (마이크로배치 30초) ===")
    if not wait_for_kafka():
        logger.error("Kafka 연결 실패"); return

    catalog = wait_for_catalog()
    if not catalog:
        logger.error("Iceberg Catalog 연결 실패"); return

    table = ensure_table(catalog)
    logger.info(f"Iceberg 테이블 준비 완료: {table.identifier}")

    consumer = KafkaConsumer(
        KAFKA_TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP,
        group_id='pyiceberg-writer',
        value_deserializer=lambda m: json.loads(m.decode('utf-8')),
        auto_offset_reset='latest',
    )

    total = 0
    while True:
        batch = []
        deadline = time.time() + BATCH_INTERVAL
        while time.time() < deadline and len(batch) < BATCH_MAX_ROWS:
            records = consumer.poll(timeout_ms=1000, max_records=500)
            for tp_msgs in records.values():
                for msg in tp_msgs:
                    row = parse_message(msg)
                    if row:
                        batch.append(row)

        if batch:
            written = write_batch(table, batch)
            total += written
            logger.info(f"[Iceberg] {written}건 적재 완료 (누적: {total:,}건)")
        else:
            logger.info("[Iceberg] 이번 배치 데이터 없음, 대기 중...")


if __name__ == '__main__':
    main()
