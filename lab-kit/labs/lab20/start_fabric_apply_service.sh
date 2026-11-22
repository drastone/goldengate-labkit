#!/bin/bash
set -euo pipefail

# Start an internal helper service inside demo_ogg_23ai.
#
# The APEX Data Fabric Wizard calls this service from demo_otrg_23ai to apply a
# TABLE add/remove change immediately. The service is not published to the host;
# it listens only inside the Docker network on demo_ogg_23ai:18091.

OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
SERVICE_PORT="${SERVICE_PORT:-18091}"
FABRIC_APPLY_TOKEN="${FABRIC_APPLY_TOKEN:-lab20-fabric-apply-token}"
SERVICE_FILE="/tmp/fabric_apply_service.py"

printf "Start Data Fabric apply helper\n"
printf "Host  : "; uname -n
printf "OGG   : %s\n" "${OGGHUB_CONTAINER}"
printf "Port  : %s\n" "${SERVICE_PORT}"
printf "Token : %s\n\n" "${FABRIC_APPLY_TOKEN}"

docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "cat > ${SERVICE_FILE}" <<'PY'
import json
import os
import re
import shutil
import subprocess
import time
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("FABRIC_APPLY_PORT", "18091"))
TOKEN = os.environ.get("FABRIC_APPLY_TOKEN", "lab20-fabric-apply-token")
BASE = "/u02/Deployment/etc/conf/ogg"
PRM = {
    "C01": ("EXTRACT", f"{BASE}/c01.prm"),
    "FC01": ("EXTRACT", f"{BASE}/fc01.prm"),
    "FC02": ("EXTRACT", f"{BASE}/fc02.prm"),
    "FD01": ("REPLICAT", f"{BASE}/fd01.prm"),
    "FD02": ("REPLICAT", f"{BASE}/fd02.prm"),
    "FD03": ("REPLICAT", f"{BASE}/fd03.prm"),
}

def run_admin(cmd):
    url = "http://localhost:8765/api/adminclient?cmd=" + urllib.parse.quote(cmd)
    with urllib.request.urlopen(url, timeout=60) as resp:
        return resp.read().decode()

def process_ref(value):
    return (value or "").strip().split()[-1].upper()

def table_ref(value):
    return (value or "").strip().rstrip(";").upper()

def read_lines(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read().splitlines()

def write_lines(path, lines):
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines).rstrip() + "\n")
    try:
        shutil.chown(path, user="ogg", group="ogg")
    except Exception:
        pass

def current_entries(lines, keyword):
    out = []
    for line in lines:
        if keyword == "MAP":
            m = re.match(r"^\s*MAP\s+([^,;]+)", line, flags=re.I)
        else:
            m = re.match(r"^\s*TABLE\s+([^;]+);", line, flags=re.I)
        if m:
            out.append(m.group(1).strip().upper())
    return out

def apply_change(payload):
    proc = process_ref(payload.get("process_name"))
    src = table_ref(payload.get("source_table"))
    sql = (payload.get("change_sql") or "").strip().upper()
    if proc not in PRM:
        raise ValueError(f"unsupported process: {proc}")
    if not src.startswith("SOE."):
        raise ValueError(f"unsupported table: {src}")

    if sql.startswith("MOVE TABLE ") or sql.startswith("MOVE MAP "):
        target_proc = process_ref(payload.get("target_process"))
        if target_proc not in PRM:
            raise ValueError(f"unsupported target process: {target_proc}")
        if PRM[target_proc][0] != PRM[proc][0]:
            raise ValueError("source and target process types must match")
        keyword = "MAP" if PRM[proc][0] == "REPLICAT" else "TABLE"
        remove_payload = dict(payload)
        remove_payload["change_sql"] = f"REMOVE {keyword} {src};"
        add_payload = dict(payload)
        add_payload["process_name"] = target_proc
        add_payload["change_sql"] = f"TABLE {src};" if keyword == "TABLE" else f"MAP {src}, TARGET {src};"
        source_result = apply_change(remove_payload)
        target_result = apply_change(add_payload)
        return {
            "move": True,
            "process": source_result["process"],
            "target_process": target_result["process"],
            "process_type": source_result["process_type"],
            "action": "MOVE",
            "keyword": keyword,
            "table": src,
            "backup": source_result["backup"] + " | " + target_result["backup"],
            "tables": source_result["tables"],
            "target_tables": target_result["tables"],
            "source": source_result,
            "target": target_result,
        }

    action = "REMOVE" if sql.startswith("REMOVE TABLE ") or sql.startswith("REMOVE MAP ") else "ADD"
    proc_type, path = PRM[proc]
    keyword = "MAP" if sql.startswith("MAP ") or sql.startswith("REMOVE MAP ") or proc_type == "REPLICAT" else "TABLE"
    backup = f"{path}.bak_{time.strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(path, backup)

    lines = read_lines(path)
    if keyword == "MAP":
        pattern = re.compile(r"^\s*MAP\s+" + re.escape(src) + r"(\s*,|;).*$", flags=re.I)
        add_line = (payload.get("change_sql") or "").strip()
        if add_line.upper().startswith("REMOVE MAP "):
            add_line = f"MAP {src}, TARGET {src};"
    else:
        pattern = re.compile(r"^\s*TABLE\s+" + re.escape(src) + r";\s*$", flags=re.I)
        add_line = f"TABLE {src};"

    if action == "REMOVE":
        new_lines = [line for line in lines if not pattern.match(line)]
        changed = len(new_lines) != len(lines)
        lines = new_lines
    else:
        changed = not any(pattern.match(line) for line in lines)
        if changed:
            lines.append(add_line.rstrip(";") + ";")

    if changed:
        write_lines(path, lines)

    stop_reply = run_admin(f"stop {proc}!")
    start_reply = run_admin(f"start {proc}")
    time.sleep(3)
    info_reply = run_admin(f"info {proc_type.lower()} {proc}")

    return {
        "process": proc,
        "process_type": proc_type,
        "action": action,
        "keyword": keyword,
        "table": src,
        "changed": changed,
        "backup": backup,
        "parameter_file": path,
        "tables": current_entries(lines, keyword),
        "stop": stop_reply,
        "start": start_reply,
        "info": info_reply,
    }

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/health":
            self.send_error(404)
            return
        self._json({"status": "ok"})

    def do_POST(self):
        if self.path != "/apply":
            self.send_error(404)
            return
        if self.headers.get("X-Fabric-Token") != TOKEN:
            self.send_response(403)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "invalid fabric apply token"}).encode())
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            payload = json.loads(self.rfile.read(length).decode() or "{}")
            self._json(apply_change(payload))
        except Exception as exc:
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(exc)}).encode())

    def log_message(self, fmt, *args):
        return

    def _json(self, payload):
        body = json.dumps(payload).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
PY

docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "
if [ -f /tmp/fabric_apply_service.pid ]; then
  old_pid=\$(cat /tmp/fabric_apply_service.pid 2>/dev/null || true)
  if [ -n \"\${old_pid}\" ] && kill -0 \"\${old_pid}\" >/dev/null 2>&1; then
    kill \"\${old_pid}\" >/dev/null 2>&1 || true
  fi
fi
FABRIC_APPLY_PORT=${SERVICE_PORT} FABRIC_APPLY_TOKEN='${FABRIC_APPLY_TOKEN}' nohup python3 ${SERVICE_FILE} >/tmp/fabric_apply_service.log 2>&1 &
echo \$! >/tmp/fabric_apply_service.pid
sleep 1
python3 - <<'PY'
import urllib.request
print(urllib.request.urlopen('http://localhost:${SERVICE_PORT}/health', timeout=5).read().decode())
PY
"

printf "\nApply helper is ready at http://%s:%s/apply inside the Docker network.\n" "${OGGHUB_CONTAINER}" "${SERVICE_PORT}"
