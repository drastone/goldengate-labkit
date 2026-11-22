#!/usr/bin/env python3
"""
Small Lab Kit HTTP helper for GoldenGate Admin Client and Logdump.

The service is intentionally local to the Docker lab network. APEX/ORDS calls it
from the database container through authenticated APEX Ajax callbacks.
"""
from collections import deque
import glob
import json
import os
import re
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

OGG_HOME = os.environ.get("OGG_HOME", "/u01/ogg")
OGG_BIN = os.environ.get("OGG_ADMINCLIENT", os.path.join(OGG_HOME, "bin", "adminclient"))
LOGDUMP_BIN = os.environ.get("OGG_LOGDUMP", os.path.join(OGG_HOME, "bin", "logdump"))
FIELD_KIT_DIR = os.environ.get("OGG_FIELD_KIT_DIR", "/u01/ogg/scripts/field-kit")
TRAIL_PARSE_BIN = os.environ.get("OGG_TRAIL_PARSE", os.path.join(FIELD_KIT_DIR, "ogg_trail_parse.sh"))
OGG_URL = os.environ.get("OGG_URL", "http://localhost:9012")
OGG_DEPLOY = os.environ.get("OGG_DEPLOYMENT", "OGGHUB")
OGG_USER = os.environ.get("OGG_USER") or os.environ.get("OGG_ADMIN") or "oggadmin"
OGG_PASS = os.environ.get("OGG_PASS") or os.environ.get("OGG_ADMIN_PWD") or ""
TRAIL_DIRS = [
    item
    for item in os.environ.get(
        "OGG_TRAIL_DIRS",
        "/u02/Deployment/var/lib/data,/u01/ogg/var/lib/data,/u01/ogg/dirdat",
    ).split(",")
    if item
]
OGG_LOG_DIR = os.environ.get("OGG_LOG_DIR", "/u02/Deployment/var/log")
OGG_REPORT_DIRS = [
    item
    for item in os.environ.get(
        "OGG_REPORT_DIRS",
        "/u02/Deployment/var/lib/report,/u01/ogg/var/lib/report,/u01/ogg/dirrpt",
    ).split(",")
    if item
]

CONNECT_CMD = "connect {0} deployment {1} user {2} password {3}".format(
    OGG_URL, OGG_DEPLOY, OGG_USER, OGG_PASS
)

PROMPT_RE = re.compile(r"^OGG \(.*?\) \d+>\s*")
LOGDUMP_PROMPT_RE = re.compile(r"Logdump\s+\d+\s*>")
LOGDUMP_RECORD_RE = re.compile(
    r"^(\d{4}/\d{2}/\d{2}\s+\d{2}:\d{2}:\d{2}\.\d+\.\d+)\s+"
    r"(.+?)\s+Len\s+(\d+)\s+RBA\s+(\d+)\s*$"
)
LOGDUMP_HEADER_LEN_RE = re.compile(r"Record Header\s+Info\s+x[0-9A-Fa-f]+\s+Length\s+(\d+)")
SAFE_TRAIL_NAME_RE = re.compile(r"^[A-Za-z][A-Za-z0-9._-]{0,63}$")
SAFE_PROC_NAME_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_#$.-]{0,127}$")
DENIED_LOGDUMP_CMD_RE = re.compile(r"^\s*(?:!|shell\b|sh\b|host\b|obey\b)", re.IGNORECASE)


def run_adminclient(cmd):
    script = "{0}\n{1}\nexit\n".format(CONNECT_CMD, cmd)
    try:
        proc = subprocess.run(
            [OGG_BIN],
            input=script,
            capture_output=True,
            text=True,
            timeout=30,
            env={**os.environ, "OGG_HOME": OGG_HOME},
        )
        raw = proc.stdout
    except subprocess.TimeoutExpired:
        return {"error": "adminclient timed out"}
    except Exception as exc:
        return {"error": str(exc)}

    lines = raw.split("\n")
    out_lines = []
    phase = 0
    for line in lines:
        match = PROMPT_RE.match(line)
        if match:
            rest = line[match.end() :].strip().lower()
            if phase == 0 and rest.startswith("connect "):
                phase = 1
            elif phase == 1:
                phase = 2
            elif phase == 2:
                break
            continue
        if phase == 2:
            out_lines.append(line)

    while out_lines and not out_lines[-1].strip():
        out_lines.pop()

    output = "\n".join(out_lines)
    return {"output": output, "response": {"reply": output}, "deployment": OGG_DEPLOY}


def run_adminclient_sequence(pre_cmds, cmd):
    script = CONNECT_CMD + "\n" + "\n".join(pre_cmds) + "\n" + cmd + "\nexit\n"
    try:
        proc = subprocess.run(
            [OGG_BIN],
            input=script,
            capture_output=True,
            text=True,
            timeout=30,
            env={**os.environ, "OGG_HOME": OGG_HOME},
        )
        raw = proc.stdout
    except subprocess.TimeoutExpired:
        return {"error": "adminclient timed out"}
    except Exception as exc:
        return {"error": str(exc)}

    lines = raw.split("\n")
    out_lines = []
    target_prompt = len(pre_cmds) + 2
    prompt_seen = 0
    capturing = False

    for line in lines:
        match = PROMPT_RE.match(line)
        if match:
            prompt_seen += 1
            if prompt_seen == target_prompt:
                capturing = True
            elif capturing:
                break
            continue
        if capturing:
            out_lines.append(line)

    while out_lines and not out_lines[-1].strip():
        out_lines.pop()

    output = "\n".join(out_lines)
    return {"output": output, "response": {"reply": output}, "deployment": OGG_DEPLOY}


def get_heartbeattable(alias="src2"):
    return run_adminclient_sequence(
        ["dblogin useridalias {0} domain OracleGoldenGate".format(alias)],
        "info heartbeattable",
    )


def parse_dml_stats(proc_name):
    result = run_adminclient("stats {0}".format(proc_name))
    if "error" in result:
        return result

    output = result.get("output", "")
    total_ins = total_upd = total_del = 0
    in_total = False

    for line in output.split("\n"):
        if "*** Total statistics" in line:
            in_total = True
        elif line.strip().startswith("***") and in_total:
            in_total = False
        elif in_total:
            stripped = line.strip()
            try:
                value = float(stripped.split()[-1].replace(",", ""))
            except (ValueError, IndexError):
                continue
            if stripped.startswith("Total inserts"):
                total_ins += value
            elif stripped.startswith("Total updates"):
                total_upd += value
            elif stripped.startswith("Total deletes"):
                total_del += value

    return {
        "process": proc_name,
        "inserts": int(total_ins),
        "updates": int(total_upd),
        "deletes": int(total_del),
        "deployment": OGG_DEPLOY,
    }


def safe_realpath(path):
    try:
        return os.path.realpath(path)
    except Exception:
        return ""


def allowed_trail_roots():
    return [safe_realpath(path) for path in TRAIL_DIRS if os.path.isdir(path)]


def allowed_report_roots():
    return [safe_realpath(path) for path in OGG_REPORT_DIRS if os.path.isdir(path)]


def safe_child_path(root, child):
    root_real = safe_realpath(root)
    child_real = safe_realpath(os.path.join(root_real, child))
    if child_real == root_real or child_real.startswith(root_real + os.path.sep):
        return child_real
    raise ValueError("path is outside allowed directory")


def parse_line_count(qs, default=20, limit=200):
    try:
        return max(1, min(limit, int(qs.get("lines", [str(default)])[0])))
    except ValueError:
        return default


def tail_matching_lines(path, lines, needle=None):
    if not os.path.isfile(path):
        return "file not found: {0}\n".format(path)

    needle_upper = needle.upper() if needle else None
    rows = deque(maxlen=lines)
    with open(path, "r", encoding="utf-8", errors="replace") as handle:
        for line in handle:
            if needle_upper and needle_upper not in line.upper():
                continue
            rows.append(line.rstrip("\n"))

    if not rows:
        if needle:
            return "no matching lines for {0} in {1}\n".format(needle, path)
        return ""
    return "\n".join(rows) + "\n"


def read_ggserr(qs):
    lines = parse_line_count(qs)
    proc = qs.get("proc", [""])[0].strip().upper()
    if proc and not SAFE_PROC_NAME_RE.match(proc):
        raise ValueError("invalid proc parameter")
    path = safe_child_path(OGG_LOG_DIR, "ggserr.log")
    return tail_matching_lines(path, lines, proc or None)


def read_report(qs):
    lines = parse_line_count(qs)
    proc = qs.get("proc", [""])[0].strip().upper()
    if not proc:
        raise ValueError("proc parameter required")
    if not SAFE_PROC_NAME_RE.match(proc):
        raise ValueError("invalid proc parameter")

    for root in allowed_report_roots():
        for name in ("{0}.rpt".format(proc), "{0}.RPT".format(proc), "{0}.rpt".format(proc.lower())):
            path = safe_child_path(root, name)
            if os.path.isfile(path):
                return tail_matching_lines(path, lines)
    return "report file not found for {0}\n".format(proc)


def resolve_trail_path(value):
    value = (value or "").strip()
    if not value:
        raise ValueError("trail parameter required")

    roots = allowed_trail_roots()
    candidates = []
    if os.path.isabs(value):
        candidates.append(value)
    elif SAFE_TRAIL_NAME_RE.match(value):
        for root in roots:
            candidates.append(os.path.join(root, value))
    else:
        raise ValueError("invalid trail path")

    for candidate in candidates:
        real = safe_realpath(candidate)
        if any(real == root or real.startswith(root + os.path.sep) for root in roots):
            if os.path.isfile(real):
                return real
    raise ValueError("trail file not found or outside allowed directories")


def list_trail_files():
    rows = []
    seen = set()
    for root in allowed_trail_roots():
        for path in glob.glob(os.path.join(root, "*")):
            real = safe_realpath(path)
            name = os.path.basename(real)
            if real in seen or not os.path.isfile(real):
                continue
            if not re.match(r"^[A-Za-z]{2}[0-9]{9}$", name):
                continue
            try:
                stat = os.stat(real)
            except OSError:
                continue
            seen.add(real)
            rows.append(
                {
                    "name": name,
                    "path": real,
                    "size": stat.st_size,
                    "mtime": int(stat.st_mtime),
                }
            )
    rows.sort(key=lambda row: (row["name"], row["path"]))
    return {"trails": rows, "deployment": OGG_DEPLOY}


def option_commands(opts):
    enabled = {item.strip().lower() for item in (opts or "").split(",") if item.strip()}
    commands = []
    commands.append("ghdr {0}".format("on" if "ghdr" in enabled else "off"))
    commands.append("detail data {0}".format("on" if "detail" in enabled else "off"))
    commands.append("usertoken detail {0}".format("on" if "usertoken" in enabled else "off"))
    commands.append("headertoken detail {0}".format("on" if "headertoken" in enabled else "off"))
    commands.append("ggstoken detail {0}".format("on" if "ggstoken" in enabled else "off"))
    return commands


def run_logdump(commands, timeout=30):
    script = "\n".join(commands) + "\nexit\n"
    try:
        proc = subprocess.run(
            [LOGDUMP_BIN],
            input=script,
            capture_output=True,
            text=True,
            timeout=timeout,
            env={**os.environ, "OGG_HOME": OGG_HOME},
        )
    except subprocess.TimeoutExpired:
        return {"error": "logdump timed out"}
    except Exception as exc:
        return {"error": str(exc)}
    output = LOGDUMP_PROMPT_RE.sub("\n", proc.stdout)
    output = output.replace("\r\n", "\n")
    return {"output": output, "returncode": proc.returncode}


def parse_logdump_records(output):
    records = []
    current = None
    pending = []
    last_header_len = None

    def finish():
        nonlocal current
        if current is not None:
            current["raw"] = "\n".join(current.pop("_raw_lines")).strip()
            records.append(current)
            current = None

    for raw_line in output.splitlines():
        line = raw_line.rstrip()
        if not line:
            if current is not None:
                current["_raw_lines"].append(line)
            continue
        if line.startswith("Oracle GoldenGate Log File Dump Utility") or line.startswith("Copyright "):
            continue

        header_match = LOGDUMP_HEADER_LEN_RE.search(line)
        if header_match:
            finish()
            last_header_len = int(header_match.group(1))
            pending = [line]
            continue

        rec_match = LOGDUMP_RECORD_RE.match(line)
        if rec_match:
            current = {
                "timestamp": rec_match.group(1),
                "operation": rec_match.group(2).strip(),
                "length": int(rec_match.group(3)),
                "rba": int(rec_match.group(4)),
                "record_length": last_header_len,
                "_raw_lines": pending + [line],
            }
            pending = []
            continue

        if current is not None:
            current["_raw_lines"].append(line)
            if line.startswith("Name:"):
                current["table"] = line.split(":", 1)[1].strip()
        elif pending:
            pending.append(line)

    finish()
    return records


def read_logdump_records(qs):
    trail = resolve_trail_path(qs.get("trail", [""])[0])
    pos = qs.get("pos", ["0"])[0]
    opts = qs.get("opts", [""])[0]
    try:
        pos_int = max(0, int(pos))
    except ValueError:
        pos_int = 0
    try:
        count = max(1, min(25, int(qs.get("count", ["5"])[0])))
    except ValueError:
        count = 5

    commands = option_commands(opts) + [
        "open {0}".format(trail),
        "pos {0}".format(pos_int),
    ]
    commands.extend(["n"] * count)
    result = run_logdump(commands)
    if "error" in result:
        return result
    records = parse_logdump_records(result.get("output", ""))
    next_rba = pos_int
    if records:
        last = records[-1]
        next_rba = int(last.get("rba", next_rba)) + int(
            last.get("record_length") or last.get("length") or 0
        )
    return {
        "records": records,
        "next_rba": next_rba,
        "eof": len(records) < count,
        "trail": trail,
    }


def exec_logdump(qs):
    trail = resolve_trail_path(qs.get("trail", [""])[0])
    cmd = qs.get("cmd", [""])[0].strip()
    if not cmd:
        return {"error": "cmd parameter required"}
    if DENIED_LOGDUMP_CMD_RE.match(cmd):
        return {"error": "command is not allowed in the web logdump terminal"}
    pos = qs.get("pos", ["0"])[0]
    opts = qs.get("opts", [""])[0]
    try:
        pos_int = max(0, int(pos))
    except ValueError:
        pos_int = 0
    result = run_logdump(option_commands(opts) + ["open {0}".format(trail), "pos {0}".format(pos_int), cmd])
    if "error" in result:
        return result
    return {"output": result.get("output", "").strip(), "trail": trail}


def parse_trail_13_columns(qs):
    trail = resolve_trail_path(qs.get("trail", [""])[0])
    limit = qs.get("limit", [""])[0].strip()
    timeout = 120
    args = [TRAIL_PARSE_BIN, "-T"]
    if limit:
        try:
            limit_int = max(1, min(1000000, int(limit)))
        except ValueError:
            raise ValueError("limit must be numeric")
        args.extend(["-n", str(limit_int)])
        timeout = max(timeout, min(600, 30 + limit_int // 50))
    args.append(trail)

    if not os.path.isfile(TRAIL_PARSE_BIN) or not os.access(TRAIL_PARSE_BIN, os.X_OK):
        return {"error": "trail parser not executable: {0}".format(TRAIL_PARSE_BIN)}

    try:
        proc = subprocess.run(
            args,
            capture_output=True,
            text=True,
            timeout=timeout,
            env={**os.environ, "LOGDUMP": LOGDUMP_BIN, "OGG_TRAIL_DIR": os.path.dirname(trail)},
        )
    except subprocess.TimeoutExpired:
        return {"error": "trail parser timed out"}
    except Exception as exc:
        return {"error": str(exc)}

    if proc.returncode != 0:
        return {
            "error": "trail parser failed",
            "returncode": proc.returncode,
            "stderr": proc.stderr[-4000:],
        }

    rows = []
    for line in proc.stdout.splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        cols = line.rstrip("\n").split("|")
        while len(cols) < 13:
            cols.append("")
        rows.append(cols[:13])

    return {"trail": trail, "rows": rows, "row_count": len(rows), "stderr": proc.stderr[-4000:]}


def requested_trail_names(qs):
    prefix = qs.get("prefix", [""])[0].strip()
    start = qs.get("start", [""])[0].strip()
    end = qs.get("end", [""])[0].strip()
    if prefix or start or end:
        if not SAFE_TRAIL_NAME_RE.match(prefix):
            raise ValueError("prefix parameter is invalid")
        try:
            start_int = int(start)
            end_int = int(end)
        except ValueError:
            raise ValueError("start/end parameters must be numeric")
        if start_int < 0 or end_int < start_int:
            raise ValueError("invalid trail sequence range")
        if end_int - start_int > 999:
            raise ValueError("trail sequence range is too large")
        return ["{0}{1:09d}".format(prefix, seq) for seq in range(start_int, end_int + 1)]

    names = []
    for item in qs.get("trail", []):
        names.extend([part.strip() for part in item.split(",") if part.strip()])
    for item in qs.get("trails", []):
        names.extend([part.strip() for part in item.split(",") if part.strip()])
    if not names:
        raise ValueError("trail or prefix/start/end parameters are required")
    return names


def parse_trail_13_dat_lines(qs):
    if not os.path.isfile(TRAIL_PARSE_BIN) or not os.access(TRAIL_PARSE_BIN, os.X_OK):
        raise ValueError("trail parser not executable: {0}".format(TRAIL_PARSE_BIN))

    limit = qs.get("limit", [""])[0].strip()
    parser_args = [TRAIL_PARSE_BIN, "-T"]
    if limit:
        try:
            limit_int = max(1, min(1000000, int(limit)))
        except ValueError:
            raise ValueError("limit must be numeric")
        parser_args.extend(["-n", str(limit_int)])

    trails = [resolve_trail_path(name) for name in requested_trail_names(qs)]
    for idx, trail in enumerate(trails, start=1):
        base = os.path.basename(trail)
        proc = subprocess.Popen(
            parser_args + [trail],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env={**os.environ, "LOGDUMP": LOGDUMP_BIN, "OGG_TRAIL_DIR": os.path.dirname(trail)},
        )
        assert proc.stdout is not None
        for line in proc.stdout:
            if not line.strip() or line.startswith("#"):
                continue
            cols = line.rstrip("\n").split("|")
            while len(cols) < 13:
                cols.append("")
            yield "{0}|{1}|{2}\n".format(idx, base, "|".join(cols[:13]))
        stderr = proc.stderr.read() if proc.stderr is not None else ""
        rc = proc.wait()
        if rc != 0:
            raise RuntimeError("trail parser failed for {0}: {1}".format(base, stderr[-1000:]))


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write("[ogg-api:{0}] {1}\n".format(OGG_DEPLOY, fmt % args))

    def send_json(self, data, status=200):
        body = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def send_text(self, data, status=200):
        body = str(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def send_dat(self, qs):
        # Validate before sending headers so user-facing errors can still be JSON.
        names = requested_trail_names(qs)
        for name in names:
            resolve_trail_path(name)
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Disposition", "attachment; filename=lgd.dat")
        self.end_headers()
        for line in parse_trail_13_dat_lines(qs):
            self.wfile.write(line.encode("utf-8"))

    def do_GET(self):
        parsed = urlparse(self.path)
        qs = parse_qs(parsed.query)
        path = parsed.path

        try:
            if path == "/api/adminclient":
                cmd = qs.get("cmd", [""])[0].strip()
                if not cmd:
                    self.send_json({"error": "cmd parameter required"}, 400)
                    return
                self.send_json(run_adminclient(cmd))
            elif path == "/api/dmlstats":
                proc = qs.get("proc", ["D01"])[0].strip().upper()
                self.send_json(parse_dml_stats(proc))
            elif path == "/api/heartbeattable":
                alias = qs.get("alias", ["src2"])[0].strip()
                self.send_json(get_heartbeattable(alias))
            elif path == "/api/trails":
                self.send_json(list_trail_files())
            elif path == "/api/read":
                self.send_json(read_logdump_records(qs))
            elif path == "/api/exec":
                self.send_json(exec_logdump(qs))
            elif path == "/api/parse13":
                self.send_json(parse_trail_13_columns(qs))
            elif path == "/api/parse13dat":
                self.send_dat(qs)
            elif path == "/api/ggserr":
                self.send_text(read_ggserr(qs))
            elif path == "/api/report":
                self.send_text(read_report(qs))
            elif path == "/api/health":
                self.send_json(
                    {
                        "status": "ok",
                        "deployment": OGG_DEPLOY,
                        "ogg_url": OGG_URL,
                        "trail_dirs": TRAIL_DIRS,
                    }
                )
            else:
                self.send_json({"error": "unknown path: {0}".format(path)}, 404)
        except ValueError as exc:
            self.send_json({"error": str(exc)}, 400)
        except Exception as exc:
            self.send_json({"error": str(exc)}, 500)


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    server = HTTPServer(("0.0.0.0", port), Handler)
    sys.stderr.write("[ogg-api] {0} @ {1} listening on :{2}\n".format(OGG_DEPLOY, OGG_URL, port))
    sys.stderr.flush()
    server.serve_forever()
