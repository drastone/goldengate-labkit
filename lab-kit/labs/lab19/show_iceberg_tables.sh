#!/bin/bash
set -euo pipefail

docker run --rm -i --network host oracle-demo_pyiceberg_writer python - <<'PY'
from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchNamespaceError, NoSuchTableError

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
    tables = catalog.list_tables(("insurance",))
except NoSuchNamespaceError:
    print("namespace insurance does not exist")
    raise SystemExit(0)

print("Iceberg namespace: insurance")
print("Tables:")
for table_id in tables:
    print(f"  - {'.'.join(table_id)}")

try:
    table = catalog.load_table("insurance.ds_cfund_dt_events")
except NoSuchTableError:
    print("\nBronze table insurance.ds_cfund_dt_events does not exist")
    raise SystemExit(0)

snapshot = table.current_snapshot()
if snapshot is None:
    print("\nBronze table: insurance.ds_cfund_dt_events")
    print("Current snapshot: none")
    print("Rows written: 0")
    raise SystemExit(0)

row_count = 0
file_count = 0
for manifest in snapshot.manifests(table.io):
    for entry in manifest.fetch_manifest_entry(table.io, discard_deleted=True):
        row_count += entry.data_file.record_count or 0
        file_count += 1

print("\nBronze table: insurance.ds_cfund_dt_events")
print(f"Current snapshot: {snapshot.snapshot_id}")
print(f"Data files: {file_count}")
print(f"Rows written: {row_count}")
PY
