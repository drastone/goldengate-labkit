#!/bin/bash
set -euo pipefail

OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
TARGET_CONTAINER="${TARGET_CONTAINER:-demo_otrg_23ai}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_SQL="${SCRIPT_DIR}/refresh_fabric_metadata.sql"

printf "Refresh Chapter 20 Fabric metadata from GoldenGate parameter files\n"
printf "Host      : "; uname -n
printf "OGGHUB    : %s\n" "${OGGHUB_CONTAINER}"
printf "Target DB : %s\n" "${TARGET_CONTAINER}"
printf "\n"

python3 - "${OGGHUB_CONTAINER}" "${OUT_SQL}" <<'PY'
import json
import os
import re
import subprocess
import sys

container = sys.argv[1]
out_sql = sys.argv[2]

def read_file(path):
    return subprocess.check_output(
        ["docker", "exec", "-i", container, "bash", "-lc", f"cat {path} 2>/dev/null || true"],
        universal_newlines=True,
    )

def run_ogg(cmd):
    try:
        raw = subprocess.check_output(
            [
                "docker",
                "exec",
                "-i",
                container,
                "bash",
                "-lc",
                "curl -s 'http://localhost:8765/api/adminclient?cmd=" + cmd.replace(" ", "%20") + "' || true",
            ],
            universal_newlines=True,
        )
        if not raw.strip():
            return ""
        try:
            return json.loads(raw).get("output", raw)
        except Exception:
            return raw
    except Exception:
        return ""

def list_prm_files():
    raw = subprocess.check_output(
        ["docker", "exec", "-i", container, "bash", "-lc", "ls -1 /u02/Deployment/etc/conf/ogg/*.prm 2>/dev/null || true"],
        universal_newlines=True,
    )
    return [p.strip() for p in raw.splitlines() if p.strip() and not p.strip().endswith("/mgr.prm")]

def q(value):
    return "'" + str(value).replace("'", "''") + "'"

def ident(value):
    return re.sub(r"[^A-Z0-9_]", "_", value.upper()).strip("_")

def table_name(line, keyword):
    body = line.strip()
    body = re.sub(r";\s*$", "", body)
    body = body[len(keyword):].strip()
    body = body.split(",", 1)[0].strip()
    return body.upper()

def parse_info_all():
    statuses = {}
    text = run_ogg("info all")
    for line in text.splitlines():
        m = re.match(r"^\s*(EXTRACT|REPLICAT)\s+(\S+)\s+(\S+)\s+(.+)$", line, flags=re.I)
        if m:
            ptype, status, name, rest = m.groups()
            statuses[name.upper()] = {
                "type": ptype.upper(),
                "status": "ACTIVE" if status.upper() == "RUNNING" else "OFFLINE",
                "runtime_status": status.upper(),
                "runtime_detail": re.sub(r"\s+", " ", rest.strip()),
            }
    return statuses

def parse_prm(name, path, text):
    proc_type = None
    tables = []
    maps = []
    trail = None
    userid = None
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
            tables.append(table_name(line, "TABLE"))
        elif upper.startswith("MAP "):
            maps.append(table_name(line, "MAP"))
    return {
        "name": name.upper(),
        "path": path,
        "type": proc_type,
        "tables": tables,
        "maps": maps,
        "trail": trail,
        "userid": userid,
    }

def checkpoint_trail(process_name):
    text = run_ogg(f"info {process_name} detail")
    m = re.search(r"Log Read Checkpoint\s+File\s+([A-Za-z0-9_./-]+)", text, flags=re.I)
    if not m:
        return None
    base = os.path.basename(m.group(1))
    if len(base) > 9 and base[-9:].isdigit():
        return base[:-9]
    return re.sub(r"\d+$", "", base) or None

def exact_tables(values):
    return {v for v in values if "*" not in v and "?" not in v}

statuses = parse_info_all()
processes = {}
for path in list_prm_files():
    name = os.path.basename(path).rsplit(".", 1)[0].upper()
    text = read_file(path)
    proc = parse_prm(name, path, text)
    if proc["type"] in ("EXTRACT", "REPLICAT"):
        processes[name] = proc

rows = []
nodes = []
edges = []
summary = []
trails = {}

for name, proc in sorted(processes.items()):
    discovered = statuses.get(name, {})
    status = discovered.get("status", "OFFLINE")
    node_code = ("OGG_EXTRACT_" if proc["type"] == "EXTRACT" else "OGG_REPLICAT_") + name
    node_type = "OGG_EXTRACT" if proc["type"] == "EXTRACT" else "OGG_REPLICAT"
    layer_no = 2 if proc["type"] == "EXTRACT" else 4
    display_order = (len([n for n in nodes if n[5] == layer_no]) + 1) * 10
    count = len(proc["tables"]) if proc["type"] == "EXTRACT" else len(proc["maps"])
    desc = (
        f"Discovered from GoldenGate parameter file {proc['path']}. "
        f"Runtime status: {discovered.get('runtime_status', 'UNKNOWN')}. "
        f"{'TABLE' if proc['type'] == 'EXTRACT' else 'MAP'} count: {count}."
    )
    nodes.append((node_code, f"{proc['type'].title()} {name}", node_type, "GoldenGate", "demo_ogg_23ai", layer_no, display_order, status, name, desc))
    rows.append((node_code, "parameter_file", proc["path"]))
    rows.append((node_code, "runtime_status", discovered.get("runtime_status", "UNKNOWN")))
    if proc["userid"]:
        rows.append((node_code, "useridalias", proc["userid"]))
    if proc["trail"]:
        trail_id = ident(os.path.basename(proc["trail"]))
        trail_node = "OGG_TRAIL_" + trail_id
        trails[trail_node] = (trail_node, f"Trail {os.path.basename(proc['trail'])}", "TRAIL", "GoldenGate Trail", "demo_ogg_23ai", 3, (len(trails) + 1) * 10, status, proc["trail"], f"Discovered from {name} parameter EXTTRAIL/RMTTRAIL {proc['trail']}.")
        rows.append((node_code, "trail", proc["trail"]))
        edges.append((f"DISC_{node_code}_TO_{trail_node}", node_code, trail_node, "WRITE_TRAIL", f"confidence=HIGH; source=parameter; trail={proc['trail']}", status, f"{name} writes trail {proc['trail']} based on parameter file."))
    if proc["tables"]:
        rows.append((node_code, "table_count", str(len(proc["tables"]))))
        rows.append((node_code, "tables", ", ".join(proc["tables"])))
        summary.append((name, "TABLE", len(proc["tables"]), ", ".join(proc["tables"][:6]) + (" ..." if len(proc["tables"]) > 6 else "")))
    if proc["maps"]:
        rows.append((node_code, "map_count", str(len(proc["maps"]))))
        rows.append((node_code, "maps", ", ".join(proc["maps"])))
        summary.append((name, "MAP", len(proc["maps"]), ", ".join(proc["maps"][:6]) + (" ..." if len(proc["maps"]) > 6 else "")))

extracts = [p for p in processes.values() if p["type"] == "EXTRACT" and p["trail"] and p["tables"]]
replicats = [p for p in processes.values() if p["type"] == "REPLICAT" and p["maps"]]
for rep in replicats:
    read_trail = checkpoint_trail(rep["name"])
    rep_node = "OGG_REPLICAT_" + rep["name"]
    edge_status = statuses.get(rep["name"], {}).get("status", "OFFLINE")
    if read_trail:
        trail_node = "OGG_TRAIL_" + ident(read_trail)
        if trail_node in trails:
            rows.append((rep_node, "read_trail", read_trail))
            edges.append((
                f"DISC_{trail_node}_TO_{rep_node}",
                trail_node,
                rep_node,
                "APPLY",
                f"confidence=HIGH; source=runtime_checkpoint; trail={read_trail}",
                edge_status,
                f"{rep['name']} reads trail {read_trail} according to AdminClient info detail.",
            ))
            continue

    rep_set = exact_tables(rep["maps"])
    if not rep_set:
        continue
    best = None
    tied = False
    for ext in extracts:
        ext_set = exact_tables(ext["tables"])
        score = len(rep_set.intersection(ext_set))
        if not score:
            continue
        if best is None or score > best[0]:
            best = (score, ext)
            tied = False
        elif best is not None and score == best[0]:
            tied = True
    if best and not tied:
        ext = best[1]
        trail_node = "OGG_TRAIL_" + ident(os.path.basename(ext["trail"]))
        edges.append((
            f"DISC_{trail_node}_TO_{rep_node}",
            trail_node,
            rep_node,
            "APPLY",
            f"confidence=MEDIUM; source=table_map_intersection; matched={best[0]}",
            edge_status,
            f"{rep['name']} is linked to {ext['name']} trail by matching MAP entries to captured TABLE entries.",
        ))

with open(out_sql, "w", encoding="utf-8") as f:
    f.write("set define off\n")
    f.write("whenever sqlerror exit sql.sqlcode rollback\n")
    f.write("alter session set container=ORCLPDB1;\n\n")
    f.write("delete from ggadmin.fabric_edge where edge_code like 'DISC\\_%' escape '\\';\n\n")
    f.write("delete from ggadmin.fabric_node_property\n")
    f.write(" where property_name in ('parameter_file','trail','table_count','tables','map_count','maps','runtime_status','useridalias');\n\n")
    for node in sorted(nodes + list(trails.values()), key=lambda n: (n[5], n[6])):
        node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description = node
        f.write("merge into ggadmin.fabric_node d\n")
        f.write(
            "using (select "
            f"{q(node_code)} node_code, {q(node_name)} node_name, {q(node_type)} node_type, "
            f"{q(domain_name)} domain_name, {q(system_name)} system_name, {layer_no} layer_no, "
            f"{q(str(display_order))} display_order, {q(status)} status, {q(resource_ref)} resource_ref, {q(description)} description "
            "from dual) s\n"
        )
        f.write("   on (d.node_code = s.node_code)\n")
        f.write(" when matched then update set d.node_name = s.node_name, d.node_type = s.node_type, d.domain_name = s.domain_name, d.system_name = s.system_name, d.layer_no = s.layer_no, d.display_order = s.display_order, d.status = s.status, d.resource_ref = s.resource_ref, d.description = s.description, d.updated_at = systimestamp\n")
        f.write(" when not matched then insert (node_code, node_name, node_type, domain_name, system_name, layer_no, display_order, status, resource_ref, description)\n")
        f.write("   values (s.node_code, s.node_name, s.node_type, s.domain_name, s.system_name, s.layer_no, s.display_order, s.status, s.resource_ref, s.description);\n\n")
    for node_code, prop, value in rows:
        f.write("merge into ggadmin.fabric_node_property d\n")
        f.write(f"using (select {q(node_code)} node_code, {q(prop)} property_name, {q(value)} property_value from dual) s\n")
        f.write("   on (d.node_code = s.node_code and d.property_name = s.property_name)\n")
        f.write(" when matched then update set d.property_value = s.property_value, d.updated_at = systimestamp\n")
        f.write(" when not matched then insert (node_code, property_name, property_value)\n")
        f.write("   values (s.node_code, s.property_name, s.property_value);\n\n")
    for edge in edges:
        edge_code, from_node, to_node, edge_type, mapping_ref, status, description = edge
        f.write("merge into ggadmin.fabric_edge d\n")
        f.write(
            "using (select "
            f"{q(edge_code)} edge_code, {q(from_node)} from_node_code, {q(to_node)} to_node_code, "
            f"{q(edge_type)} edge_type, {q(mapping_ref)} mapping_ref, {q(status)} status, {q(description)} description "
            "from dual) s\n"
        )
        f.write("   on (d.edge_code = s.edge_code)\n")
        f.write(" when matched then update set d.from_node_code = s.from_node_code, d.to_node_code = s.to_node_code, d.edge_type = s.edge_type, d.mapping_ref = s.mapping_ref, d.status = s.status, d.description = s.description, d.updated_at = systimestamp\n")
        f.write(" when not matched then insert (edge_code, from_node_code, to_node_code, edge_type, mapping_ref, status, description)\n")
        f.write("   values (s.edge_code, s.from_node_code, s.to_node_code, s.edge_type, s.mapping_ref, s.status, s.description);\n\n")
    f.write("commit;\n")
    f.write("prompt Fabric metadata refreshed from GoldenGate parameter files.\n")

print("Discovered GoldenGate mappings:")
for name, kind, count, preview in summary:
    print(f"  {name:<4} {kind:<5} {count:>2}  {preview}")
print(f"\nDiscovered nodes: {len(nodes) + len(trails)}")
print(f"Discovered edges: {len(edges)}")
print(f"\nGenerated SQL: {out_sql}")
PY

docker cp "${OUT_SQL}" "${TARGET_CONTAINER}:/tmp/refresh_fabric_metadata.sql"
docker exec -i "${TARGET_CONTAINER}" bash -lc \
  "sqlplus / as sysdba @/tmp/refresh_fabric_metadata.sql"

printf "\nFabric metadata refresh completed.\n"
