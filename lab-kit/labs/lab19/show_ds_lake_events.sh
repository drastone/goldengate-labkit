#!/bin/bash
set -euo pipefail

MAX_EVENTS=${1:-3}
WAIT_SECONDS=${WAIT_SECONDS:-20}

docker run --rm -i --network host \
  -e MAX_EVENTS="${MAX_EVENTS}" \
  -e WAIT_SECONDS="${WAIT_SECONDS}" \
  oracle-demo_pyiceberg_writer python - <<'PY'
import base64
import json
import os
import socket
import struct
import sys
import time

HOST = os.getenv("DS_HOST", "127.0.0.1")
PORT = int(os.getenv("DS_PORT", "9113"))
PATH = os.getenv("DS_PATH", "/services/v2/stream/DS_LAKE?begin=now")
USER = os.getenv("OGG_USER", "oggadmin")
PASSWORD = os.getenv("OGG_PASSWORD", "WElcome1234##")
MAX_EVENTS = int(os.getenv("MAX_EVENTS", "3"))
WAIT_SECONDS = int(os.getenv("WAIT_SECONDS", "20"))


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
    sock.settimeout(WAIT_SECONDS)
    sock.sendall(req.encode())
    response = b""
    while b"\r\n\r\n" not in response:
        response += sock.recv(4096)
    first = response.split(b"\r\n", 1)[0].decode(errors="replace")
    if "101" not in first:
        raise RuntimeError(first + "\n" + response[:500].decode(errors="replace"))
    print(f"Connected Data Streams: {first}")
    return sock


sock = connect_stream()
seen = 0
started = time.time()
try:
    while seen < MAX_EVENTS:
        try:
            payload = recv_ws_message(sock)
        except socket.timeout:
            print(f"No event received within {WAIT_SECONDS} seconds. Run source workload and retry.")
            sys.exit(0)
        text = payload.decode("utf-8", errors="replace")
        if not text.startswith("["):
            continue
        try:
            events = json.loads(text)
        except Exception:
            continue
        for event in events:
            if event.get("qual_table") != "SOE.CFUND_DT":
                continue
            seen += 1
            print(f"\n-- event {seen} --")
            print(json.dumps(event, ensure_ascii=False, indent=2, sort_keys=True))
            if seen >= MAX_EVENTS:
                break
finally:
    sock.close()
PY
