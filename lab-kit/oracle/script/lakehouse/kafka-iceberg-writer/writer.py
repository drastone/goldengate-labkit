"""Kafka to Iceberg micro-batch writer for GoldenGate CDC events.

This writer consumes GoldenGate Kafka JSON events and appends normalized event
rows into an Iceberg table. It is intentionally append-oriented: it proves the
Kafka downstream data-product path first, while current-state merge/update
semantics can be handled later by GoldenGate DAA's native Iceberg handler or by
a dedicated merge job.
"""

import json
import logging
import os
import socket
import time
from datetime import datetime
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple
from urllib.parse import urlparse, urlunparse

import pyarrow as pa
from kafka import KafkaConsumer
from kafka.errors import NoBrokersAvailable
from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchNamespaceError, NoSuchTableError
from pyiceberg.partitioning import PartitionField, PartitionSpec
from pyiceberg.schema import Schema
from pyiceberg.transforms import IdentityTransform
from pyiceberg.types import LongType, NestedField, StringType, TimestampType


LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger("kafka-iceberg-writer")


KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP", "demo_centos:9092")
WRITER_MODE = os.getenv("WRITER_MODE", "raw").lower()
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "SOE.EMPLOYEE")
KAFKA_GROUP_ID = os.getenv("KAFKA_GROUP_ID", "iceberg-writer-soe-employee")
AUTO_OFFSET_RESET = os.getenv("AUTO_OFFSET_RESET", "latest")

BATCH_INTERVAL_SEC = float(os.getenv("BATCH_INTERVAL_SEC", "30"))
BATCH_MAX_ROWS = int(os.getenv("BATCH_MAX_ROWS", "5000"))
POLL_TIMEOUT_MS = int(os.getenv("POLL_TIMEOUT_MS", "1000"))
POLL_MAX_RECORDS = int(os.getenv("POLL_MAX_RECORDS", "500"))
CONNECT_RETRIES = int(os.getenv("CONNECT_RETRIES", "30"))
CONNECT_RETRY_DELAY_SEC = float(os.getenv("CONNECT_RETRY_DELAY_SEC", "5"))

WRITER_MAX_BATCHES = int(os.getenv("WRITER_MAX_BATCHES", "0"))
WRITER_MAX_MESSAGES = int(os.getenv("WRITER_MAX_MESSAGES", "0"))
DRY_RUN = os.getenv("DRY_RUN", "false").lower() in ("1", "true", "yes", "y")
COMMIT_OFFSETS_DRY_RUN = os.getenv("COMMIT_OFFSETS_DRY_RUN", "false").lower() in ("1", "true", "yes", "y")

ICEBERG_CATALOG_NAME = os.getenv("ICEBERG_CATALOG_NAME", "insurance")
ICEBERG_CATALOG_TYPE = os.getenv("ICEBERG_CATALOG_TYPE", "rest")
ICEBERG_CATALOG_URI = os.getenv("ICEBERG_CATALOG_URI", "http://demo_iceberg_catalog:8181")
ICEBERG_TABLE = os.getenv("ICEBERG_TABLE", "insurance.soe_employee_cdc_raw")
ICEBERG_CREATE_TABLE_IF_MISSING = os.getenv("ICEBERG_CREATE_TABLE_IF_MISSING", "true").lower() in (
    "1",
    "true",
    "yes",
    "y",
)
ICEBERG_FILE_FORMAT = os.getenv("ICEBERG_FILE_FORMAT", "parquet")
ICEBERG_TARGET_FILE_SIZE_BYTES = os.getenv("ICEBERG_TARGET_FILE_SIZE_BYTES", "67108864")

S3_ENDPOINT = os.getenv("ICEBERG_S3_ENDPOINT", "http://demo_minio:9000")
S3_ACCESS_KEY_ID = os.getenv("ICEBERG_S3_ACCESS_KEY_ID")
S3_SECRET_ACCESS_KEY = os.getenv("ICEBERG_S3_SECRET_ACCESS_KEY")
S3_REGION = os.getenv("ICEBERG_S3_REGION")
S3_PATH_STYLE_ACCESS = os.getenv("ICEBERG_S3_PATH_STYLE_ACCESS", "true")


OP_LABELS = {
    "1": "정기납입",
    "2": "추가납입",
    "3": "중도인출",
    "4": "펀드변경",
    "5": "해약",
    "6": "신계약",
}


ICEBERG_SCHEMA = Schema(
    NestedField(1, "ingestion_time", TimestampType(), required=False),
    NestedField(2, "op_type", StringType(), required=False),
    NestedField(3, "op_ts", StringType(), required=False),
    NestedField(4, "cust_id", LongType(), required=False),
    NestedField(5, "fund_code", StringType(), required=False),
    NestedField(6, "fund_name", StringType(), required=False),
    NestedField(7, "fund_amt", LongType(), required=False),
    NestedField(8, "op_gubun", StringType(), required=False),
    NestedField(9, "op_label", StringType(), required=False),
    NestedField(10, "op_gubun2", StringType(), required=False),
    NestedField(11, "dt", StringType(), required=False),
)

PARTITION_SPEC = PartitionSpec(
    PartitionField(
        source_id=8,
        field_id=1000,
        transform=IdentityTransform(),
        name="op_gubun",
    )
)

ARROW_SCHEMA = pa.schema(
    [
        pa.field("ingestion_time", pa.timestamp("us")),
        pa.field("op_type", pa.string()),
        pa.field("op_ts", pa.string()),
        pa.field("cust_id", pa.int64()),
        pa.field("fund_code", pa.string()),
        pa.field("fund_name", pa.string()),
        pa.field("fund_amt", pa.int64()),
        pa.field("op_gubun", pa.string()),
        pa.field("op_label", pa.string()),
        pa.field("op_gubun2", pa.string()),
        pa.field("dt", pa.string()),
    ]
)

RAW_ICEBERG_SCHEMA = Schema(
    NestedField(1, "ingestion_time", TimestampType(), required=False),
    NestedField(2, "source_table", StringType(), required=False),
    NestedField(3, "op_type", StringType(), required=False),
    NestedField(4, "op_ts", StringType(), required=False),
    NestedField(5, "current_ts", StringType(), required=False),
    NestedField(6, "trail_pos", StringType(), required=False),
    NestedField(7, "kafka_topic", StringType(), required=False),
    NestedField(8, "kafka_partition", LongType(), required=False),
    NestedField(9, "kafka_offset", LongType(), required=False),
    NestedField(10, "kafka_key", StringType(), required=False),
    NestedField(11, "payload_json", StringType(), required=False),
)

RAW_PARTITION_SPEC = PartitionSpec(
    PartitionField(
        source_id=3,
        field_id=1001,
        transform=IdentityTransform(),
        name="op_type",
    )
)

RAW_ARROW_SCHEMA = pa.schema(
    [
        pa.field("ingestion_time", pa.timestamp("us")),
        pa.field("source_table", pa.string()),
        pa.field("op_type", pa.string()),
        pa.field("op_ts", pa.string()),
        pa.field("current_ts", pa.string()),
        pa.field("trail_pos", pa.string()),
        pa.field("kafka_topic", pa.string()),
        pa.field("kafka_partition", pa.int64()),
        pa.field("kafka_offset", pa.int64()),
        pa.field("kafka_key", pa.string()),
        pa.field("payload_json", pa.string()),
    ]
)


def active_iceberg_schema() -> Schema:
    if WRITER_MODE == "raw":
        return RAW_ICEBERG_SCHEMA
    return ICEBERG_SCHEMA


def active_partition_spec() -> PartitionSpec:
    if WRITER_MODE == "raw":
        return RAW_PARTITION_SPEC
    return PARTITION_SPEC


def active_arrow_schema() -> pa.Schema:
    if WRITER_MODE == "raw":
        return RAW_ARROW_SCHEMA
    return ARROW_SCHEMA


def env_summary() -> Dict[str, Any]:
    return {
        "kafka_bootstrap": KAFKA_BOOTSTRAP,
        "writer_mode": WRITER_MODE,
        "topic": KAFKA_TOPIC,
        "group_id": KAFKA_GROUP_ID,
        "auto_offset_reset": AUTO_OFFSET_RESET,
        "iceberg_catalog": ICEBERG_CATALOG_URI,
        "iceberg_table": ICEBERG_TABLE,
        "batch_interval_sec": BATCH_INTERVAL_SEC,
        "batch_max_rows": BATCH_MAX_ROWS,
        "dry_run": DRY_RUN,
    }


def catalog_config() -> Dict[str, str]:
    config = {
        "type": ICEBERG_CATALOG_TYPE,
        "uri": ICEBERG_CATALOG_URI,
        "s3.endpoint": normalize_s3_endpoint(S3_ENDPOINT),
        "s3.path-style-access": S3_PATH_STYLE_ACCESS,
    }
    if S3_ACCESS_KEY_ID:
        config["s3.access-key-id"] = S3_ACCESS_KEY_ID
    if S3_SECRET_ACCESS_KEY:
        config["s3.secret-access-key"] = S3_SECRET_ACCESS_KEY
    if S3_REGION:
        config["s3.region"] = S3_REGION
    return config


def normalize_s3_endpoint(endpoint: str) -> str:
    """PyArrow rejects underscores in URI host names; Docker container names often have them."""
    parsed = urlparse(endpoint)
    hostname = parsed.hostname
    if not hostname or "_" not in hostname:
        return endpoint

    try:
        resolved_host = socket.gethostbyname(hostname)
    except OSError as exc:
        raise RuntimeError(f"Failed to resolve S3 endpoint hostname {hostname!r}: {exc}") from exc

    netloc = resolved_host
    if parsed.port:
        netloc = f"{resolved_host}:{parsed.port}"
    normalized = urlunparse(parsed._replace(netloc=netloc))
    logger.info("Resolved S3 endpoint for PyArrow compatibility: %s -> %s", endpoint, normalized)
    return normalized


def parse_table_identifier(identifier: str) -> Tuple[Tuple[str, ...], str]:
    parts = [part.strip() for part in identifier.split(".") if part.strip()]
    if len(parts) < 2:
        raise ValueError("ICEBERG_TABLE must include namespace and table, for example insurance.cfund_transactions")
    return tuple(parts[:-1]), ".".join(parts)


def normalize_payload(value: Any) -> Dict[str, Any]:
    if isinstance(value, bytes):
        value = value.decode("utf-8")
    if isinstance(value, str):
        value = json.loads(value)
    if not isinstance(value, dict):
        raise ValueError(f"Expected JSON object, got {type(value).__name__}")
    return value


def upper_keys(row: Optional[Dict[str, Any]]) -> Dict[str, Any]:
    if not isinstance(row, dict):
        return {}
    return {str(key).upper(): value for key, value in row.items()}


def value_as_int(value: Any) -> Optional[int]:
    if value is None or value == "":
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        try:
            return int(float(str(value).replace(",", "")))
        except (TypeError, ValueError):
            return None


def value_as_str(value: Any) -> Optional[str]:
    if value is None:
        return None
    return str(value)


def op_type_of(payload: Dict[str, Any]) -> str:
    return str(
        payload.get("OP_TYPE")
        or payload.get("op_type")
        or payload.get("opType")
        or payload.get("op")
        or payload.get("operation")
        or ""
    ).upper()


def image_for_event(payload: Dict[str, Any]) -> Dict[str, Any]:
    op_type = op_type_of(payload)
    after = upper_keys(payload.get("after") or payload.get("after_image") or payload.get("afterImage"))
    before = upper_keys(payload.get("before") or payload.get("before_image") or payload.get("beforeImage"))
    if op_type == "D" and before:
        return before
    return after or before


def parse_event(
    payload_value: Any,
    topic: str,
    partition: int,
    offset: int,
    key: Any = None,
) -> Optional[Dict[str, Any]]:
    payload = normalize_payload(payload_value)
    if WRITER_MODE == "raw":
        return {
            "ingestion_time": datetime.utcnow(),
            "source_table": value_as_str(
                payload.get("TABLE_NAME")
                or payload.get("table")
                or payload.get("objectname")
                or payload.get("object")
            ),
            "op_type": op_type_of(payload),
            "op_ts": value_as_str(payload.get("OP_TS") or payload.get("op_ts") or payload.get("opTs")),
            "current_ts": value_as_str(
                payload.get("CURRENT_TS") or payload.get("current_ts") or payload.get("currentTs")
            ),
            "trail_pos": value_as_str(payload.get("POS") or payload.get("pos") or payload.get("position")),
            "kafka_topic": topic,
            "kafka_partition": partition,
            "kafka_offset": offset,
            "kafka_key": value_as_str(key),
            "payload_json": json.dumps(payload, ensure_ascii=False, sort_keys=True),
        }

    image = image_for_event(payload)
    if not image:
        return None

    op_gubun = value_as_str(image.get("OP_GUBUN"))
    return {
        "ingestion_time": datetime.utcnow(),
        "op_type": op_type_of(payload),
        "op_ts": value_as_str(payload.get("OP_TS") or payload.get("op_ts") or payload.get("opTs")),
        "cust_id": value_as_int(image.get("CUST_ID")),
        "fund_code": value_as_str(image.get("FUND_CODE")),
        "fund_name": value_as_str(image.get("FUND_NAME")),
        "fund_amt": value_as_int(image.get("FUND_AMT")),
        "op_gubun": op_gubun,
        "op_label": OP_LABELS.get(op_gubun or "", f"etc-{op_gubun}") if op_gubun else None,
        "op_gubun2": value_as_str(image.get("OP_GUBUN2")),
        "dt": value_as_str(image.get("DT")),
    }


def wait_for_kafka() -> bool:
    for attempt in range(1, CONNECT_RETRIES + 1):
        try:
            consumer = KafkaConsumer(bootstrap_servers=KAFKA_BOOTSTRAP, request_timeout_ms=10000)
            consumer.close()
            logger.info("Kafka connection OK: %s", KAFKA_BOOTSTRAP)
            return True
        except NoBrokersAvailable:
            logger.info("Waiting for Kafka... (%s/%s)", attempt, CONNECT_RETRIES)
            time.sleep(CONNECT_RETRY_DELAY_SEC)
    return False


def wait_for_catalog():
    if DRY_RUN:
        logger.info("DRY_RUN=true, skipping Iceberg catalog connection")
        return None

    for attempt in range(1, CONNECT_RETRIES + 1):
        try:
            catalog = load_catalog(ICEBERG_CATALOG_NAME, **catalog_config())
            catalog.list_namespaces()
            logger.info("Iceberg REST Catalog connection OK: %s", ICEBERG_CATALOG_URI)
            return catalog
        except Exception as exc:
            logger.info("Waiting for Iceberg catalog... (%s/%s): %s", attempt, CONNECT_RETRIES, exc)
            time.sleep(CONNECT_RETRY_DELAY_SEC)
    return None


def ensure_table(catalog):
    namespace, identifier = parse_table_identifier(ICEBERG_TABLE)
    try:
        catalog.list_tables(namespace)
    except NoSuchNamespaceError:
        if not ICEBERG_CREATE_TABLE_IF_MISSING:
            raise
        catalog.create_namespace(namespace)
        logger.info("Created Iceberg namespace: %s", ".".join(namespace))

    try:
        return catalog.load_table(identifier)
    except NoSuchTableError:
        if not ICEBERG_CREATE_TABLE_IF_MISSING:
            raise
        table = catalog.create_table(
            identifier,
            schema=active_iceberg_schema(),
            partition_spec=active_partition_spec(),
            properties={
                "format-version": "2",
                "write.format.default": ICEBERG_FILE_FORMAT,
                "write.target-file-size-bytes": ICEBERG_TARGET_FILE_SIZE_BYTES,
            },
        )
        logger.info("Created Iceberg table: %s", identifier)
        return table


def write_batch(table, rows: Sequence[Dict[str, Any]]) -> int:
    if not rows:
        return 0
    arrow_table = pa.Table.from_pylist(list(rows), schema=active_arrow_schema())
    if DRY_RUN:
        logger.info("DRY_RUN batch preview: %s", rows[:3])
        return len(rows)
    table.append(arrow_table)
    return len(rows)


def create_consumer() -> KafkaConsumer:
    return KafkaConsumer(
        KAFKA_TOPIC,
        bootstrap_servers=KAFKA_BOOTSTRAP,
        group_id=KAFKA_GROUP_ID,
        value_deserializer=lambda raw: json.loads(raw.decode("utf-8")),
        key_deserializer=lambda raw: raw.decode("utf-8") if raw is not None else None,
        auto_offset_reset=AUTO_OFFSET_RESET,
        enable_auto_commit=False,
        consumer_timeout_ms=1000,
    )


def iter_polled_records(consumer: KafkaConsumer) -> Iterable[Any]:
    records = consumer.poll(timeout_ms=POLL_TIMEOUT_MS, max_records=POLL_MAX_RECORDS)
    for partition_records in records.values():
        for record in partition_records:
            yield record


def main() -> int:
    logger.info("Starting Kafka -> Iceberg writer")
    logger.info("Config: %s", json.dumps(env_summary(), ensure_ascii=False))

    if not wait_for_kafka():
        logger.error("Kafka connection failed: %s", KAFKA_BOOTSTRAP)
        return 2

    catalog = wait_for_catalog()
    if not DRY_RUN and catalog is None:
        logger.error("Iceberg catalog connection failed: %s", ICEBERG_CATALOG_URI)
        return 3

    table = None if DRY_RUN else ensure_table(catalog)
    if table is not None:
        logger.info("Iceberg table ready: %s", table.identifier)

    consumer = create_consumer()
    total_written = 0
    total_seen = 0
    batch_count = 0

    try:
        while True:
            rows: List[Dict[str, Any]] = []
            seen_in_batch = 0
            deadline = time.time() + BATCH_INTERVAL_SEC

            while time.time() < deadline and len(rows) < BATCH_MAX_ROWS:
                for record in iter_polled_records(consumer):
                    seen_in_batch += 1
                    total_seen += 1
                    row = parse_event(record.value, record.topic, record.partition, record.offset, record.key)
                    if row:
                        rows.append(row)
                    if WRITER_MAX_MESSAGES and total_seen >= WRITER_MAX_MESSAGES:
                        break
                if WRITER_MAX_MESSAGES and total_seen >= WRITER_MAX_MESSAGES:
                    break

            if rows:
                written = write_batch(table, rows)
                total_written += written
                if not DRY_RUN or COMMIT_OFFSETS_DRY_RUN:
                    consumer.commit()
                logger.info("Iceberg append complete: batch=%s total=%s seen=%s", written, total_written, total_seen)
                batch_count += 1
            elif seen_in_batch:
                if not DRY_RUN or COMMIT_OFFSETS_DRY_RUN:
                    consumer.commit()
                    logger.info("Committed offsets for %s non-writable CDC events", seen_in_batch)
                else:
                    logger.info("Skipped offset commit for %s dry-run records", seen_in_batch)
                batch_count += 1
            else:
                logger.info("No Kafka records in this interval")

            if WRITER_MAX_BATCHES and batch_count >= WRITER_MAX_BATCHES:
                logger.info("WRITER_MAX_BATCHES reached: %s", WRITER_MAX_BATCHES)
                break
            if WRITER_MAX_MESSAGES and total_seen >= WRITER_MAX_MESSAGES:
                logger.info("WRITER_MAX_MESSAGES reached: %s", WRITER_MAX_MESSAGES)
                break

    finally:
        consumer.close()

    logger.info("Writer stopped: total_written=%s total_seen=%s", total_written, total_seen)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
