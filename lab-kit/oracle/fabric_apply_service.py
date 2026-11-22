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

def process_name(value):
    name = (value or "").strip().upper()
    if not re.match(r"^[A-Z][A-Z0-9_]{0,7}$", name):
        raise ValueError("process name must be 1-8 characters and start with A-Z")
    return name

def trail_name(value):
    name = (value or "").strip()
    if not re.match(r"^[A-Za-z][A-Za-z0-9]$", name):
        raise ValueError("trail prefix must be exactly 2 alphanumeric characters and start with a letter")
    return name

def userid_alias(value, default):
    alias = (value or default).strip()
    if not re.match(r"^[A-Za-z0-9_]+$", alias):
        raise ValueError("USERIDALIAS must contain only letters, numbers, and underscore")
    return alias

def replicat_mode(value):
    mode = (value or "classic").strip().lower().replace("_", "-")
    allowed = {
        "classic",
        "integrated",
        "coordinated",
        "parallel-non-integrated",
        "parallel-integrated",
    }
    if mode not in allowed:
        raise ValueError(f"unsupported replicat mode: {mode}")
    return mode

def positive_int(value, default, minimum=1, maximum=1024):
    try:
        number = int(value)
    except Exception:
        number = default
    return max(minimum, min(maximum, number))

def parse_table_list(value):
    tables = []
    for part in re.split(r"[\n,]+", value or ""):
        table = table_ref(part)
        if not table:
            continue
        if not re.match(r"^SOE\.([A-Z0-9_]+|\*)$", table):
            raise ValueError(f"unsupported table: {table}")
        if table not in tables:
            tables.append(table)
    if not tables:
        raise ValueError("at least one SOE table is required")
    return tables

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

def clean_ident(value):
    return re.sub(r"[^A-Z0-9_]", "_", (value or "").upper()).strip("_")

def table_ref_from_line(line, keyword):
    body = line.strip().rstrip(";")
    body = body[len(keyword):].strip()
    body = body.split(",", 1)[0].strip()
    return body.upper()

def parse_admin_output(raw):
    try:
        return json.loads(raw).get("output", raw)
    except Exception:
        return raw

def info_all_statuses():
    statuses = {}
    text = parse_admin_output(run_admin("info all"))
    for line in text.splitlines():
        m = re.match(r"^\s*(EXTRACT|REPLICAT)\s+(\S+)\s+(\S+)\s+(.+)$", line, flags=re.I)
        if not m:
            continue
        ptype, status, name, rest = m.groups()
        statuses[name.upper()] = {
            "type": ptype.upper(),
            "status": "ACTIVE" if status.upper() == "RUNNING" else "OFFLINE",
            "runtime_status": status.upper(),
            "runtime_detail": re.sub(r"\s+", " ", rest.strip()),
        }
    return statuses

def read_prm(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def parse_prm(name, path, text):
    proc_type = None
    trail = None
    userid = None
    tables = []
    maps = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("--"):
            continue
        upper = line.upper()
        if upper.startswith("EXTRACT "):
            proc_type = "EXTRACT"
        elif upper.startswith("REPLICAT "):
            proc_type = "REPLICAT"
        elif upper.startswith("USERIDALIAS "):
            userid = line.split(None, 1)[1].strip()
        elif upper.startswith(("EXTTRAIL ", "RMTTRAIL ")):
            trail = line.split(None, 1)[1].strip().rstrip(";")
        elif upper.startswith("TABLE "):
            tables.append(table_ref_from_line(line, "TABLE"))
        elif upper.startswith("MAP "):
            maps.append(table_ref_from_line(line, "MAP"))
    return {
        "name": name.upper(),
        "path": path,
        "type": proc_type,
        "trail": trail,
        "userid": userid,
        "tables": tables,
        "maps": maps,
    }

def checkpoint_trail(process_name):
    try:
        text = parse_admin_output(run_admin(f"info {process_name} detail"))
    except Exception:
        return None
    m = re.search(r"Log Read Checkpoint\s+File\s+([A-Za-z0-9_./-]+)", text, flags=re.I)
    if not m:
        return None
    base = os.path.basename(m.group(1))
    if len(base) > 9 and base[-9:].isdigit():
        return base[:-9]
    return re.sub(r"\d+$", "", base) or None

def metadata_snapshot():
    statuses = info_all_statuses()
    processes = {}
    for file_name in sorted(os.listdir(BASE)):
        if not file_name.lower().endswith(".prm") or file_name.lower() == "mgr.prm":
            continue
        path = os.path.join(BASE, file_name)
        name = file_name.rsplit(".", 1)[0].upper()
        proc = parse_prm(name, path, read_prm(path))
        if proc["type"] in ("EXTRACT", "REPLICAT") and name in statuses:
            processes[name] = proc

    nodes = []
    properties = []
    edges = []
    trail_nodes = {}

    layer_counts = {"EXTRACT": 0, "TRAIL": 0, "REPLICAT": 0}
    for name, proc in sorted(processes.items()):
        runtime = statuses.get(name, {})
        node_type = "OGG_EXTRACT" if proc["type"] == "EXTRACT" else "OGG_REPLICAT"
        layer_no = 2 if proc["type"] == "EXTRACT" else 4
        layer_counts[proc["type"]] += 1
        count = len(proc["tables"]) if proc["type"] == "EXTRACT" else len(proc["maps"])
        desc = (
            f"Discovered from GoldenGate parameter file {proc['path']}. "
            f"Runtime status: {runtime.get('runtime_status', 'UNKNOWN')}. "
            f"{'TABLE' if proc['type'] == 'EXTRACT' else 'MAP'} count: {count}."
        )
        node_code = ("OGG_EXTRACT_" if proc["type"] == "EXTRACT" else "OGG_REPLICAT_") + name
        nodes.append({
            "node_code": node_code,
            "node_name": f"{proc['type'].title()} {name}",
            "node_type": node_type,
            "domain_name": "GoldenGate",
            "system_name": "demo_ogg_23ai",
            "layer_no": layer_no,
            "display_order": layer_counts[proc["type"]] * 10,
            "status": runtime.get("status", "OFFLINE"),
            "resource_ref": name,
            "description": desc,
        })
        properties.extend([
            {"node_code": node_code, "property_name": "parameter_file", "property_value": proc["path"]},
            {"node_code": node_code, "property_name": "runtime_status", "property_value": runtime.get("runtime_status", "UNKNOWN")},
        ])
        if proc["userid"]:
            properties.append({"node_code": node_code, "property_name": "useridalias", "property_value": proc["userid"]})
        if proc["tables"]:
            properties.append({"node_code": node_code, "property_name": "table_count", "property_value": str(len(proc["tables"]))})
            properties.append({"node_code": node_code, "property_name": "tables", "property_value": ", ".join(proc["tables"])[:1000]})
        if proc["maps"]:
            properties.append({"node_code": node_code, "property_name": "map_count", "property_value": str(len(proc["maps"]))})
            properties.append({"node_code": node_code, "property_name": "maps", "property_value": ", ".join(proc["maps"])[:1000]})
        if proc["trail"]:
            trail_ref = os.path.basename(proc["trail"])
            trail_code = "OGG_TRAIL_" + clean_ident(trail_ref)
            layer_counts["TRAIL"] += 1
            trail_nodes[trail_code] = {
                "node_code": trail_code,
                "node_name": f"Trail {trail_ref}",
                "node_type": "TRAIL",
                "domain_name": "GoldenGate Trail",
                "system_name": "demo_ogg_23ai",
                "layer_no": 3,
                "display_order": layer_counts["TRAIL"] * 10,
                "status": runtime.get("status", "OFFLINE"),
                "resource_ref": trail_ref,
                "description": f"Discovered from {name} parameter EXTTRAIL/RMTTRAIL {trail_ref}.",
            }
            properties.append({"node_code": node_code, "property_name": "trail", "property_value": trail_ref})
            edges.append({
                "edge_code": f"DISC_{node_code}_TO_{trail_code}",
                "from_node_code": node_code,
                "to_node_code": trail_code,
                "edge_type": "WRITE_TRAIL",
                "mapping_ref": f"confidence=HIGH; source=parameter; trail={trail_ref}",
                "status": runtime.get("status", "OFFLINE"),
                "description": f"{name} writes trail {trail_ref} based on parameter file.",
            })

    for name, proc in sorted(processes.items()):
        if proc["type"] != "REPLICAT":
            continue
        read_trail = checkpoint_trail(name)
        if not read_trail:
            continue
        trail_code = "OGG_TRAIL_" + clean_ident(read_trail)
        rep_code = "OGG_REPLICAT_" + name
        if trail_code not in trail_nodes:
            layer_counts["TRAIL"] += 1
            trail_nodes[trail_code] = {
                "node_code": trail_code,
                "node_name": f"Trail {read_trail}",
                "node_type": "TRAIL",
                "domain_name": "GoldenGate Trail",
                "system_name": "demo_ogg_23ai",
                "layer_no": 3,
                "display_order": layer_counts["TRAIL"] * 10,
                "status": statuses.get(name, {}).get("status", "OFFLINE"),
                "resource_ref": read_trail,
                "description": f"Discovered from {name} runtime checkpoint trail {read_trail}.",
            }
        properties.append({"node_code": rep_code, "property_name": "read_trail", "property_value": read_trail})
        edges.append({
            "edge_code": f"DISC_{trail_code}_TO_{rep_code}",
            "from_node_code": trail_code,
            "to_node_code": rep_code,
            "edge_type": "APPLY",
            "mapping_ref": f"confidence=HIGH; source=runtime_checkpoint; trail={read_trail}",
            "status": statuses.get(name, {}).get("status", "OFFLINE"),
            "description": f"{name} reads trail {read_trail} according to AdminClient info detail.",
        })

    return {"nodes": nodes + list(trail_nodes.values()), "properties": properties, "edges": edges}

def create_extract_lane(payload):
    name = process_name(payload.get("extract_name"))
    trail = trail_name(payload.get("trail_name"))
    alias = userid_alias(payload.get("useridalias"), "src_ogg")
    tables = parse_table_list(payload.get("tables"))
    parameter_text = (payload.get("parameter_text") or "").strip()
    prm_path = os.path.join(BASE, f"{name.lower()}.prm")

    statuses = info_all_statuses()
    if name in statuses or os.path.exists(prm_path):
        raise ValueError(f"process or parameter file already exists: {name}")

    existing_trails = set()
    for file_name in sorted(os.listdir(BASE)):
        if not file_name.lower().endswith(".prm"):
            continue
        proc = parse_prm(file_name.rsplit(".", 1)[0], os.path.join(BASE, file_name), read_prm(os.path.join(BASE, file_name)))
        if proc.get("trail"):
            existing_trails.add(os.path.basename(proc["trail"]).upper())
    if trail.upper() in existing_trails:
        raise ValueError(f"trail already exists in parameter metadata: {trail}")

    if parameter_text:
        lines = [line.rstrip() for line in parameter_text.splitlines() if line.strip()]
        text_upper = "\n".join(lines).upper()
        if not re.search(rf"^\s*EXTRACT\s+{re.escape(name)}\s*$", text_upper, flags=re.M):
            raise ValueError("parameter text must contain the selected EXTRACT name")
        if not re.search(rf"^\s*EXTTRAIL\s+{re.escape(trail.upper())}\s*$", text_upper, flags=re.M):
            raise ValueError("parameter text must contain the selected EXTTRAIL prefix")
    else:
        lines = [
            f"EXTRACT {name}",
            f"USERIDALIAS {alias} DOMAIN OracleGoldenGate",
            "TRANLOGOPTIONS INTEGRATEDPARAMS (max_sga_size 256)",
            "UPDATERECORDFORMAT COMPACT",
            "DDL INCLUDE MAPPED",
            f"EXTTRAIL {trail}",
        ]
        lines.extend([f"TABLE {table};" for table in tables])
    write_lines(prm_path, lines)

    commands = [
        f"register extract {name} database",
        f"add extract {name}, integrated tranlog, begin now",
        f"add exttrail {trail}, extract {name}",
    ]

    steps = []
    status = "APPLIED"
    for cmd in commands:
        try:
            reply = run_admin(cmd)
            steps.append({"cmd": cmd, "status": "OK", "reply": reply})
            time.sleep(1)
        except Exception as exc:
            status = "FAILED"
            steps.append({"cmd": cmd, "status": "FAIL", "reply": str(exc)})
            break
    info_reply = ""
    if status == "APPLIED":
        info_reply = run_admin(f"info extract {name}")

    return {
        "status": status,
        "action": "CREATE_EXTRACT_LANE",
        "extract": name,
        "trail": trail,
        "useridalias": alias,
        "tables": tables,
        "parameter_text": "\n".join(lines),
        "parameter_file": prm_path,
        "commands": steps,
        "info": info_reply,
    }

def create_replicat_lane(payload):
    name = process_name(payload.get("replicat_name"))
    trail = trail_name(payload.get("trail_name"))
    alias = userid_alias(payload.get("useridalias"), "trg_ogg")
    mode = replicat_mode(payload.get("mode"))
    tables = parse_table_list(payload.get("tables"))
    parameter_text = (payload.get("parameter_text") or "").strip()
    max_sga_size = positive_int(payload.get("max_sga_size"), 256, 64, 8192)
    parallelism = positive_int(payload.get("parallelism"), 2, 1, 256)
    threads = positive_int(payload.get("threads"), 3, 1, 5000)
    map_parallelism = positive_int(payload.get("map_parallelism"), 2, 1, 256)
    split_trans_rec = positive_int(payload.get("split_trans_rec"), 100000, 1000, 10000000)
    min_parallelism = positive_int(payload.get("min_parallelism"), 2, 1, 256)
    max_parallelism = positive_int(payload.get("max_parallelism"), max(min_parallelism, 4), min_parallelism, 256)
    prm_path = os.path.join(BASE, f"{name.lower()}.prm")

    statuses = info_all_statuses()
    if name in statuses or os.path.exists(prm_path):
        raise ValueError(f"process or parameter file already exists: {name}")

    if parameter_text:
        lines = [line.rstrip() for line in parameter_text.splitlines() if line.strip()]
        text_upper = "\n".join(lines).upper()
        if not re.search(rf"^\s*REPLICAT\s+{re.escape(name)}\s*$", text_upper, flags=re.M):
            raise ValueError("parameter text must contain the selected REPLICAT name")
    else:
        lines = [
            f"REPLICAT {name}",
            "CACHEMGR CACHESIZE 128M",
            f"USERIDALIAS {alias} DOMAIN OracleGoldenGate",
            "ASSUMETARGETDEFS",
            "APPLYNOOPUPDATES",
        ]
        if mode == "integrated":
            lines.append(f"DBOPTIONS INTEGRATEDPARAMS (max_sga_size {max_sga_size}, parallelism {parallelism})")
        elif mode == "coordinated":
            lines.append(f"-- Coordinated Replicat uses MAXTHREADS {threads} in ADD REPLICAT.")
        elif mode == "parallel-non-integrated":
            lines.append(f"MAP_PARALLELISM {map_parallelism}")
            lines.append(f"SPLIT_TRANS_REC {split_trans_rec}")
        elif mode == "parallel-integrated":
            lines.append(
                "DBOPTIONS INTEGRATEDPARAMS "
                f"(max_sga_size {max_sga_size}, min_parallelism {min_parallelism}, max_parallelism {max_parallelism})"
            )
            lines.append(f"SPLIT_TRANS_REC {split_trans_rec}")
        lines.extend([
            f"DISCARDFILE {name}.dsc, PURGE, MEGABYTES 100",
            "REPORTCOUNT EVERY 1 MINUTES RATE",
            "DDL INCLUDE MAPPED",
            "DDLERROR 4080 IGNORE",
            "DDLERROR 942 IGNORE",
            "DDLERROR 4043 IGNORE",
            "DDLERROR 1434 IGNORE",
        ])
        lines.extend([f"MAP {table}, TARGET {table};" for table in tables])
    write_lines(prm_path, lines)

    if mode == "classic":
        add_cmd = f"add replicat {name}, exttrail {trail}, begin now"
    elif mode == "integrated":
        add_cmd = f"add replicat {name}, integrated, exttrail {trail}, begin now"
    elif mode == "coordinated":
        add_cmd = f"add replicat {name}, coordinated maxthreads {threads}, exttrail {trail}, begin now"
    elif mode == "parallel-non-integrated":
        add_cmd = f"add replicat {name}, parallel, exttrail {trail}, begin now"
    else:
        add_cmd = f"add replicat {name}, parallel, integrated, exttrail {trail}, begin now"

    steps = []
    status = "APPLIED"
    for cmd in [add_cmd]:
        try:
            reply = run_admin(cmd)
            steps.append({"cmd": cmd, "status": "OK", "reply": reply})
            time.sleep(1)
        except Exception as exc:
            status = "FAILED"
            steps.append({"cmd": cmd, "status": "FAIL", "reply": str(exc)})
            break
    info_reply = ""
    if status == "APPLIED":
        info_reply = run_admin(f"info replicat {name}")

    return {
        "status": status,
        "action": "CREATE_REPLICAT_LANE",
        "replicat": name,
        "trail": trail,
        "mode": mode,
        "useridalias": alias,
        "tables": tables,
        "parameter_text": "\n".join(lines),
        "parameter_file": prm_path,
        "commands": steps,
        "info": info_reply,
    }

def drop_process(payload):
    name = process_name(payload.get("process_name"))
    requested_type = (payload.get("process_type") or "").strip().upper()
    statuses = info_all_statuses()
    runtime = statuses.get(name)
    prm_path = os.path.join(BASE, f"{name.lower()}.prm")

    if not runtime and not os.path.exists(prm_path):
        raise ValueError(f"process not found in runtime or parameter directory: {name}")

    proc = None
    if os.path.exists(prm_path):
        proc = parse_prm(name, prm_path, read_prm(prm_path))
    proc_type = (proc or {}).get("type") or (runtime or {}).get("type")
    if requested_type:
        expected = "EXTRACT" if requested_type in ("OGG_EXTRACT", "EXTRACT") else "REPLICAT" if requested_type in ("OGG_REPLICAT", "REPLICAT") else requested_type
        if expected not in ("EXTRACT", "REPLICAT"):
            raise ValueError(f"unsupported process type: {requested_type}")
        if proc_type and proc_type != expected:
            raise ValueError(f"selected node type mismatch: {requested_type} vs {proc_type}")
        proc_type = expected
    if proc_type not in ("EXTRACT", "REPLICAT"):
        raise ValueError(f"cannot determine process type for {name}")

    alias = (proc or {}).get("userid") or payload.get("useridalias") or ("src_ogg" if proc_type == "EXTRACT" else "trg_ogg")
    trail = os.path.basename((proc or {}).get("trail") or payload.get("trail_name") or "")
    commands = []
    if proc_type == "EXTRACT":
        commands.append({"cmd": f"dblogin useridalias {alias}", "optional": False})
        commands.append({"cmd": f"stop extract {name}!", "optional": True})
        commands.append({"cmd": f"delete extract {name}!", "optional": False})
        commands.append({"cmd": f"unregister extract {name} database", "optional": True})
        if trail:
            commands.append({"cmd": f"delete exttrail {trail}", "optional": True})
    else:
        commands.append({"cmd": f"dblogin useridalias {alias}", "optional": False})
        commands.append({"cmd": f"stop replicat {name}!", "optional": True})
        commands.append({"cmd": f"delete replicat {name}!", "optional": False})

    steps = []
    status = "APPLIED"
    for item in commands:
        cmd = item["cmd"]
        try:
            reply = run_admin(cmd)
            steps.append({"cmd": cmd, "status": "OK", "reply": reply})
            time.sleep(1)
        except Exception as exc:
            steps.append({"cmd": cmd, "status": "FAIL", "reply": str(exc)})
            if item.get("optional"):
                status = "PARTIAL"
                continue
            status = "FAILED"
            break

    backup = ""
    if status in ("APPLIED", "PARTIAL") and os.path.exists(prm_path):
        backup = f"{prm_path}.dropped_{time.strftime('%Y%m%d_%H%M%S')}"
        shutil.move(prm_path, backup)
        try:
            shutil.chown(backup, user="ogg", group="ogg")
        except Exception:
            pass

    return {
        "status": status,
        "action": "DROP_PROCESS",
        "process": name,
        "process_type": proc_type,
        "trail": trail,
        "useridalias": alias,
        "parameter_file": prm_path,
        "backup": backup,
        "commands": steps,
    }

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
        if self.path == "/health":
            self._json({"status": "ok"})
            return
        if self.path == "/metadata":
            if self.headers.get("X-Fabric-Token") != TOKEN:
                self.send_response(403)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "invalid fabric apply token"}).encode())
                return
            self._json(metadata_snapshot())
            return
        else:
            self.send_error(404)
            return

    def do_POST(self):
        if self.path not in ("/apply", "/create-lane", "/create-replicat-lane", "/drop-process"):
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
            if self.path == "/create-lane":
                self._json(create_extract_lane(payload))
            elif self.path == "/create-replicat-lane":
                self._json(create_replicat_lane(payload))
            elif self.path == "/drop-process":
                self._json(drop_process(payload))
            else:
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
