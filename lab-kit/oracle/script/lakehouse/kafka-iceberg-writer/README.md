# Kafka to Iceberg Writer

This directory starts the book's Kafka downstream lakehouse implementation.
It consumes GoldenGate Kafka JSON events and appends them to an Iceberg raw CDC
event-history table.

```text
Oracle Source -> GoldenGate -> GoldenGate for Big Data/DAA -> Kafka
  -> kafka-iceberg-writer -> Iceberg -> Trino/Query API -> APEX
```

## Scope

The first implementation stores a CDC event-history table. It is enough to
prove that Kafka is not only feeding OSA/GGSA; the same CDC topic can also be
consumed by a separate lakehouse writer and queried through Trino.

Current-state merge semantics are deliberately left for the next pass. For
update/delete-heavy tables, the final book should compare this event-history
writer with GoldenGate DAA's native Iceberg handler or a dedicated merge job
that uses Iceberg equality deletes.

## Default Mapping

| Source | Target |
|---|---|
| Kafka topic | `SOE.EMPLOYEE` |
| Consumer group | `iceberg-writer-soe-employee` |
| Iceberg table | `insurance.soe_employee_cdc_raw` |
| Partition field | `op_type` |

The default `raw` mode stores the full GoldenGate Kafka JSON payload together
with Kafka offset and GoldenGate trail position metadata. This keeps the first
lakehouse step independent of a specific business table schema.

```json
{
  "TABLE_NAME": "SOE.EMPLOYEE",
  "OP_TYPE": "I",
  "OP_TS": "2026-09-21 03:30:06.019502",
  "CURRENT_TS": "2026-09-21 03:52:06.103000",
  "POS": "00000000040000003865",
  "ID": 901,
  "DESIGNATION": "After PK Update",
  "CREATED": "2026-09-21 03:30:06"
}
```

The writer treats these uppercase names as the canonical GoldenGate event
contract. It also accepts the former lowercase metadata names so an existing
topic can be drained safely while the lab is upgraded.

The writer also keeps the older normalized `cfund` mode in code for the
insurance event scenario, but the compose default follows the Kafka chapter's
`SOE.EMPLOYEE` raw CDC flow.

## Configuration

| Environment variable | Default | Purpose |
|---|---|---|
| `WRITER_MODE` | `raw` | `raw` stores full CDC payload; `cfund` stores normalized insurance rows |
| `KAFKA_BOOTSTRAP` | `demo_centos:9092` | Kafka broker reachable from the Docker network |
| `KAFKA_TOPIC` | `SOE.EMPLOYEE` | GoldenGate Kafka topic |
| `KAFKA_GROUP_ID` | `iceberg-writer-soe-employee` | Independent lakehouse consumer group |
| `ICEBERG_CATALOG_URI` | `http://demo_iceberg_catalog:8181` | Iceberg REST Catalog endpoint |
| `ICEBERG_TABLE` | `insurance.soe_employee_cdc_raw` | Target Iceberg table |
| `ICEBERG_S3_ENDPOINT` | `http://demo_minio:9000` | S3-compatible object storage endpoint |
| `ICEBERG_S3_ACCESS_KEY_ID` | none | Local lab access key, set in `.env` |
| `ICEBERG_S3_SECRET_ACCESS_KEY` | none | Local lab secret key, set in `.env` |
| `WRITER_MAX_BATCHES` | `0` | `0` means run continuously |
| `WRITER_MAX_MESSAGES` | `0` | Optional bounded verification run |
| `DRY_RUN` | `false` | Parse events without appending to Iceberg |
| `COMMIT_OFFSETS_DRY_RUN` | `false` | Commit Kafka offsets during dry-run only when explicitly enabled |

Docker container names that include underscores, such as `demo_minio`, can be
resolved by Docker DNS but rejected by PyArrow's S3 client as URI host names.
The writer resolves that endpoint to its Docker network IP before opening S3
files, so the compose defaults can still be used in the local lab.

## Run With Docker Compose

Create a local `.env` file first. Do not commit real credentials.

```bash
cp .env.example .env
vi .env
```

Start the Iceberg stack and Kafka before the writer. In the existing lab this
means `demo_centos`, `demo_minio`, `demo_iceberg_catalog`, and `demo_trino`
should be running on `u01_ogg_network`.

Run the writer:

```bash
docker compose -f docker-compose.kafka-iceberg-writer.yml up -d --build
docker logs -f demo_kafka_iceberg_writer
```

For a bounded verification run, override the batch/message limits:

```bash
WRITER_MAX_BATCHES=1 WRITER_MAX_MESSAGES=100 \
docker compose -f docker-compose.kafka-iceberg-writer.yml up --build
```

## Verify From Trino

After source DML produces Kafka events, check the Iceberg table through Trino:

```sql
SELECT count(*) AS row_count
FROM iceberg.insurance.soe_employee_cdc_raw;

SELECT op_type, source_table, trail_pos, kafka_key, kafka_offset, ingestion_time
FROM iceberg.insurance.soe_employee_cdc_raw
ORDER BY ingestion_time DESC
LIMIT 20;

SELECT committed_at, snapshot_id, operation
FROM iceberg.insurance."soe_employee_cdc_raw$snapshots"
ORDER BY committed_at DESC
LIMIT 10;
```

The APEX Query API in `../query-api` reads this same table and exposes selected
results as JSON for APEX REST Data Sources.
