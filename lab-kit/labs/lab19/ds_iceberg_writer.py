import base64
import json
import logging
import os
import socket
import struct
import time
from datetime import datetime

import pyarrow as pa
from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchNamespaceError, NoSuchTableError
from pyiceberg.partitioning import PartitionSpec
from pyiceberg.schema import Schema
from pyiceberg.types import LongType, NestedField, StringType, TimestampType

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("ds-iceberg-writer")

HOST = os.getenv("DS_HOST", "127.0.0.1")
PORT = int(os.getenv("DS_PORT", "9113"))
PATH = os.getenv("DS_PATH", "/services/v2/stream/DS_LAKE?begin=now")
USER = os.getenv("OGG_USER", "oggadmin")
PASSWORD = os.getenv("OGG_PASSWORD", "WElcome1234##")
BATCH_MAX_ROWS = int(os.getenv("BATCH_MAX_ROWS", "1000"))
BATCH_SECONDS = int(os.getenv("BATCH_SECONDS", "5"))
TABLE_NAME = os.getenv("ICEBERG_TABLE", "insurance.ds_cfund_dt_events")

CATALOG_CONFIG = {
    "type": "rest",
    "uri": os.getenv("ICEBERG_CATALOG_URI", "http://127.0.0.1:38181"),
    "s3.endpoint": os.getenv("S3_ENDPOINT", "http://127.0.0.1:38900"),
    "s3.access-key-id": os.getenv("S3_ACCESS_KEY_ID", "admin"),
    "s3.secret-access-key": os.getenv("S3_SECRET_ACCESS_KEY", "WElcome1234##"),
    "s3.path-style-access": "true",
}

SCHEMA = Schema(
    NestedField(1, "ingestion_time", TimestampType(), required=False),
    NestedField(2, "qual_table", StringType(), required=False),
    NestedField(3, "op_type", StringType(), required=False),
    NestedField(4, "op_ts", StringType(), required=False),
    NestedField(5, "pos", StringType(), required=False),
    NestedField(6, "xid", StringType(), required=False),
    NestedField(7, "cust_id", LongType(), required=False),
    NestedField(8, "keys", LongType(), required=False),
    NestedField(9, "dt", StringType(), required=False),
    NestedField(10, "op_gubun", StringType(), required=False),
    NestedField(11, "cnt", LongType(), required=False),
    NestedField(12, "before_json", StringType(), required=False),
    NestedField(13, "after_json", StringType(), required=False),
)

ARROW_SCHEMA = pa.schema([
    pa.field("ingestion_time", pa.timestamp("us")),
    pa.field("qual_table", pa.string()),
    pa.field("op_type", pa.string()),
    pa.field("op_ts", pa.string()),
    pa.field("pos", pa.string()),
    pa.field("xid", pa.string()),
    pa.field("cust_id", pa.int64()),
    pa.field("keys", pa.int64()),
    pa.field("dt", pa.string()),
    pa.field("op_gubun", pa.string()),
    pa.field("cnt", pa.int64()),
    pa.field("before_json", pa.string()),
    pa.field("after_json", pa.string()),
])


def to_int(value):
    try:
        return int(value) if value is not None else None
    except Exception:
        return None


def ensure_table():
    catalog = load_catalog("insurance", **CATALOG_CONFIG)
    ns = ("insurance",)
    try:
        catalog.list_tables(ns)
    except NoSuchNamespaceError:
        catalog.create_namespace(ns)
        log.info("created namespace insurance")
    try:
        table = catalog.load_table(TABLE_NAME)
    except NoSuchTableError:
        table = catalog.create_table(
            TABLE_NAME,
            schema=SCHEMA,
            partition_spec=PartitionSpec(),
            properties={"format-version": "2"},
        )
        log.info("created table %s", TABLE_NAME)
    return table


def send_ws_frame(sock, opcode, payload=b""):
    header = bytearray([0x80 | opcode])
    length = len(payload)
    if length < 126:
        header.append(0x80 | length)
    elif length < 65536:
        header.append(0x80 | 126)
        header.extend(struct.pack("!H", length))
    else:
        header.append(0x80 | 127)
        header.extend(struct.pack("!Q", length))
    mask = os.urandom(4)
    header.extend(mask)
    masked = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
    sock.sendall(bytes(header) + masked)


def recv_exact(sock, n):
    data = b""
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if not chunk:
            raise EOFError("socket closed")
        data += chunk
    return data


def recv_ws_message(sock):
    while True:
        b1, b2 = recv_exact(sock, 2)
        opcode = b1 & 0x0F
        length = b2 & 0x7F
        if length == 126:
            length = struct.unpack("!H", recv_exact(sock, 2))[0]
        elif length == 127:
            length = struct.unpack("!Q", recv_exact(sock, 8))[0]
        masked = b2 & 0x80
        mask = recv_exact(sock, 4) if masked else b""
        payload = recv_exact(sock, length) if length else b""
        if masked:
            payload = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
        if opcode == 0x9:
            send_ws_frame(sock, 0xA, payload)
            continue
        if opcode == 0x8:
            raise EOFError("websocket closed")
        if opcode in (0x1, 0x2):
            return payload


def connect_stream():
    key = base64.b64encode(os.urandom(16)).decode()
    auth = base64.b64encode(f"{USER}:{PASSWORD}".encode()).decode()
    req = (
        f"GET {PATH} HTTP/1.1\r\n"
        f"Host: {HOST}:{PORT}\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        f"Sec-WebSocket-Key: {key}\r\n"
        "Sec-WebSocket-Version: 13\r\n"
        f"Authorization: Basic {auth}\r\n"
        "\r\n"
    )
    sock = socket.create_connection((HOST, PORT), timeout=15)
    sock.settimeout(30)
    sock.sendall(req.encode())
    response = b""
    while b"\r\n\r\n" not in response:
        response += sock.recv(4096)
    first = response.split(b"\r\n", 1)[0].decode(errors="replace")
    if "101" not in first:
        raise RuntimeError(first + "\n" + response[:500].decode(errors="replace"))
    log.info("connected Data Streams: %s", first)
    return sock


def parse_rows(payload):
    text = payload.decode("utf-8", errors="replace")
    if not text.startswith("["):
        return []
    try:
        events = json.loads(text)
    except Exception as exc:
        log.warning("skip non-json data frame: %s", exc)
        return []
    rows = []
    now = datetime.utcnow()
    for event in events:
        after = event.get("after") or {}
        before = event.get("before") or {}
        if event.get("qual_table") != "SOE.CFUND_DT":
            continue
        rows.append({
            "ingestion_time": now,
            "qual_table": event.get("qual_table"),
            "op_type": event.get("op_type"),
            "op_ts": event.get("op_ts"),
            "pos": event.get("pos"),
            "xid": event.get("xid"),
            "cust_id": to_int(after.get("CUST_ID") or before.get("CUST_ID")),
            "keys": to_int(after.get("KEYS") or before.get("KEYS")),
            "dt": str(after.get("DT") or before.get("DT") or ""),
            "op_gubun": str(after.get("OP_GUBUN") or before.get("OP_GUBUN") or ""),
            "cnt": to_int(after.get("CNT") or before.get("CNT")),
            "before_json": json.dumps(before, ensure_ascii=False, separators=(",", ":")),
            "after_json": json.dumps(after, ensure_ascii=False, separators=(",", ":")),
        })
    return rows


def write_batch(table, rows):
    if not rows:
        return 0
    table.append(pa.Table.from_pylist(rows, schema=ARROW_SCHEMA))
    return len(rows)


def main():
    table = ensure_table()
    total = 0
    batch = []
    deadline = time.time() + BATCH_SECONDS
    while True:
        try:
            sock = connect_stream()
            while True:
                rows = parse_rows(recv_ws_message(sock))
                if rows:
                    batch.extend(rows)
                if batch and (len(batch) >= BATCH_MAX_ROWS or time.time() >= deadline):
                    written = write_batch(table, batch)
                    total += written
                    log.info("wrote %s rows to %s total=%s last_pos=%s", written, TABLE_NAME, total, batch[-1].get("pos"))
                    batch = []
                    deadline = time.time() + BATCH_SECONDS
        except Exception as exc:
            log.warning("stream loop retry after error: %s", exc)
            time.sleep(5)


if __name__ == "__main__":
    main()
