#!/usr/bin/env python3
"""
Logdump API Server - port 8765
Serves /api/trails, /api/logdump, /api/exec, /api/health
for the Logdump Web Terminal (ORDS logdump module in demo_otrg_23ai).
"""
import os
import re
import sys
import json
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

TRAIL_DIRS  = [
    '/home/oracle/script/msa/23aifree/trails',  # c1 (source, downloaded)
]
LOGDUMP_BIN = '/home/oracle/TRG/logdump'
LD_LIB      = '/opt/oracle/instantclient_19/instantclient_19_24'

SEP_RE  = re.compile(r'_{20,}')
# e.g. "2026/06/05 05:49:00.977.339 Insert               Len   264 RBA 3067"
REC_RE  = re.compile(
    r'(\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}[\d.]+)\s+'
    r'(\S+)\s+Len\s+(\d+)\s+RBA\s+(\d+)',
    re.IGNORECASE
)
NAME_RE = re.compile(r'Name:\s+(\S+)', re.IGNORECASE)
PROMPT_RE = re.compile(r'Logdump\s+\d+\s*>\s*')


def run_logdump(commands: list) -> str:
    script = '\n'.join(commands) + '\nEXIT\n'
    env = {**os.environ, 'LD_LIBRARY_PATH': LD_LIB + ':' + os.environ.get('LD_LIBRARY_PATH', '')}
    try:
        proc = subprocess.run(
            [LOGDUMP_BIN],
            input=script, capture_output=True, text=True, timeout=30, env=env
        )
        return proc.stdout
    except subprocess.TimeoutExpired:
        return ''
    except Exception as e:
        return ''


def build_opts_cmds(opts_str: str) -> list:
    opts = [o.strip().lower() for o in opts_str.split(',') if o.strip()]
    cmds = []
    cmds.append('GHDR ON' if 'ghdr' in opts else 'GHDR OFF')
    cmds.append('DETAIL DATA ON' if 'data' in opts else 'DETAIL DATA OFF')
    cmds.append('USERTOKEN DETAIL ON' if 'usertoken' in opts else 'USERTOKEN DETAIL OFF')
    cmds.append('HEADERTOKEN DETAIL ON' if 'headertoken' in opts else 'HEADERTOKEN DETAIL OFF')
    cmds.append('GGSTOKEN DETAIL ON' if 'ggstoken' in opts else 'GGSTOKEN DETAIL OFF')
    return cmds


def strip_prompts(raw: str) -> str:
    return PROMPT_RE.sub('', raw)


def parse_records(output: str):
    """
    Split logdump output into record blocks.
    Returns list of dicts: {rba, operation, timestamp, length, table, raw}
    and the RBA after the last record.
    """
    clean = strip_prompts(output)
    lines = clean.split('\n')

    records = []
    cur_lines = []
    in_rec = False
    last_rba = None
    eof = False

    for line in lines:
        if SEP_RE.match(line):
            if cur_lines:
                rec = _parse_one_record(cur_lines)
                if rec:
                    records.append(rec)
                    last_rba = rec['rba']
            cur_lines = []
            in_rec = True
            continue
        if in_rec:
            cur_lines.append(line)
        if 'end of log' in line.lower() or 'no more records' in line.lower():
            eof = True

    # flush last block
    if cur_lines:
        rec = _parse_one_record(cur_lines)
        if rec:
            records.append(rec)
            last_rba = rec['rba']

    # check eof in full output
    if 'end of log' in output.lower() or 'no more records' in output.lower():
        eof = True

    return records, last_rba, eof


def _parse_one_record(lines):
    text = '\n'.join(lines).strip()
    if not text:
        return None
    rec = {'raw': text, 'rba': None, 'operation': None,
           'timestamp': None, 'length': None, 'table': None}
    for line in lines:
        line = line.strip()
        m = REC_RE.match(line)
        if m:
            rec['timestamp'] = m.group(1)
            rec['operation']  = m.group(2)
            rec['length']     = int(m.group(3))
            rec['rba']        = int(m.group(4))
            continue
        m = NAME_RE.match(line)
        if m and rec['table'] is None:
            rec['table'] = m.group(1)
    return rec if rec['rba'] is not None else None


def handle_trails():
    trails = []
    for trail_dir in TRAIL_DIRS:
        try:
            files = sorted(os.listdir(trail_dir))
        except Exception:
            continue
        for f in files:
            path = os.path.join(trail_dir, f)
            try:
                size = os.path.getsize(path)
            except Exception:
                size = 0
            if size > 0:  # skip empty files
                trails.append({'name': f, 'size': size, 'path': path})
    return {'trails': trails}


def handle_logdump(qs):
    trail  = qs.get('trail', [''])[0]
    pos    = qs.get('pos',   ['0'])[0]
    opts   = qs.get('opts',  ['ghdr'])[0]
    count  = min(int(qs.get('count', ['5'])[0]), 20)

    if not trail:
        return {'error': 'trail parameter required'}

    cmds = ['OPEN ' + trail]
    cmds += build_opts_cmds(opts)
    if pos and pos != '0':
        cmds.append('POS ' + pos)
    for _ in range(count + 1):  # one extra to determine next_rba
        cmds.append('NEXT')

    out = run_logdump(cmds)
    all_recs, _, eof = parse_records(out)

    next_rba = None
    if len(all_recs) > count:
        next_rba = all_recs[count]['rba']
        records = all_recs[:count]
    else:
        records = all_recs
        if not eof and len(all_recs) < count:
            eof = True

    return {
        'records':  records,
        'next_rba': next_rba,
        'eof':      eof
    }


def handle_exec(qs):
    trail = qs.get('trail', [''])[0]
    pos   = qs.get('pos',   ['0'])[0]
    opts  = qs.get('opts',  ['ghdr'])[0]
    cmd   = qs.get('cmd',   [''])[0]

    if not trail:
        return {'error': 'trail parameter required'}
    if not cmd:
        return {'error': 'cmd parameter required'}

    cmds = ['OPEN ' + trail]
    cmds += build_opts_cmds(opts)
    if pos and pos != '0':
        cmds.append('POS ' + pos)
    cmds.append(cmd)

    out = run_logdump(cmds)
    clean = strip_prompts(out)
    # Remove banner lines
    filtered = '\n'.join(
        l for l in clean.split('\n')
        if not re.match(r'^(Oracle GoldenGate|Version |Copyright|$)', l)
        and 'Current LogTrail' not in l
        and 'Reading forward' not in l
    ).strip()

    return {'output': filtered}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write(f'[logdump-api] {fmt % args}\n')

    def send_json(self, data, status=200):
        body = json.dumps(data).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(body))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
        qs     = parse_qs(parsed.query)
        path   = parsed.path

        if path == '/api/trails':
            self.send_json(handle_trails())
        elif path == '/api/logdump':
            self.send_json(handle_logdump(qs))
        elif path == '/api/exec':
            self.send_json(handle_exec(qs))
        elif path == '/api/health':
            self.send_json({'status': 'ok'})
        else:
            self.send_json({'error': f'unknown path: {path}'}, 404)


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    server = HTTPServer(('0.0.0.0', port), Handler)
    sys.stderr.write(f'[logdump-api] listening on :{port}\n')
    sys.stderr.flush()
    server.serve_forever()
