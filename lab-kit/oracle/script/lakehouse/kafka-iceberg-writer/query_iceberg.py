"""Read the Lab Kit raw CDC Iceberg table without starting Trino."""

import json
from datetime import date, datetime
from typing import Any

from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchTableError

from writer import (
    ICEBERG_CATALOG_NAME,
    ICEBERG_TABLE,
    catalog_config,
)


def json_default(value: Any) -> str:
    if isinstance(value, (date, datetime)):
        return value.isoformat()
    return str(value)


def payload_fields(payload_json: Any) -> dict[str, Any]:
    if not payload_json:
        return {}
    try:
        payload = json.loads(payload_json)
    except (TypeError, json.JSONDecodeError):
        return {}
    return {
        "id": payload.get("ID"),
        "name": payload.get("NAME"),
        "designation": payload.get("DESIGNATION"),
    }


def main() -> int:
    catalog = load_catalog(ICEBERG_CATALOG_NAME, **catalog_config())
    try:
        table = catalog.load_table(ICEBERG_TABLE)
    except NoSuchTableError:
        print(f"ERROR: Iceberg table not found: {ICEBERG_TABLE}")
        print("Start the writer and generate a new Source DML event first.")
        return 2

    snapshot = table.current_snapshot()
    total_records = 0
    if snapshot is not None:
        total_records = int(snapshot.summary.get("total-records", "0"))

    print(f"TABLE: {ICEBERG_TABLE}")
    print(f"TOTAL_RECORDS: {total_records}")
    print("RECENT_ROWS:")

    rows = table.scan(limit=10).to_arrow().to_pylist()
    for row in rows:
        display = {
            "op_type": row.get("op_type"),
            "source_table": row.get("source_table"),
            "kafka_key": row.get("kafka_key"),
            "trail_pos": row.get("trail_pos"),
            **payload_fields(row.get("payload_json")),
            "ingestion_time": row.get("ingestion_time"),
        }
        print(json.dumps(display, ensure_ascii=False, default=json_default))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
