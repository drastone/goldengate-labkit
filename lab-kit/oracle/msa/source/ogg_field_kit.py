#!/usr/bin/env python3
"""GoldenGate Field Kit.

A no-web-server, standard-library-only helper for field engineers.
It runs from the engineer machine and uses local binaries, SSH, Docker exec
(for labs), or GoldenGate REST APIs without installing anything on customer
GoldenGate servers.
"""
from __future__ import print_function

import argparse
import base64
import getpass
import html
import json
import os
import pty
import re
import select
import shlex
import shutil
import signal
import ssl
import struct
import subprocess
import sys
import termios
import time
try:
    from urllib.request import Request, urlopen
    from urllib.error import HTTPError, URLError
except ImportError:  # pragma: no cover
    from urllib2 import Request, urlopen, HTTPError, URLError

VERSION = "0.1.0"
DEFAULT_CONFIG = {
    "targets": {
        "default": {
            "description": "Edit this target for the customer environment.",
            "admin_url": "http://localhost:9011",
            "admin_user": "oggadmin",
            "mode": "ssh",
            "ssh": "ogg@customer-ogg-host",
            "ogg_home": "/u01/ogg",
            "trail_dirs": [
                "/u02/Deployment/var/lib/data",
                "/u01/ogg/dirdat",
                "/u01/ogg/var/lib/data"
            ]
        },
        "local": {
            "description": "Run when adminclient/logdump are installed locally.",
            "admin_url": "http://localhost:9011",
            "admin_user": "oggadmin",
            "mode": "local",
            "ogg_home": "/u01/ogg",
            "trail_dirs": ["/u02/Deployment/var/lib/data", "/u01/ogg/dirdat"]
        },
        "lab-docker": {
            "description": "Optional lab mode. Not required for customer sites.",
            "admin_url": "http://localhost:9011",
            "admin_user": "oggadmin",
            "mode": "docker",
            "container": "demo_ogg_23ai",
            "docker": "docker",
            "ogg_home": "/u01/ogg",
            "trail_dirs": ["/u02/Deployment/var/lib/data"]
        }
    }
}
COMMON_REST_PATHS = [
    "/services/v2/extracts",
    "/services/v2/replicats",
    "/services/v2/tasks",
    "/services/v2/messages",
    "/services/v2/credentials",
    "/services/v2/deployments",
]
PROMPT_RE = re.compile(r"(?:OGG[^\r\n]*\d+>|Logdump\s+\d+\s*>)\s*$", re.I)
PASSWORD_RE = re.compile(r"(?:password|passphrase)[^\r\n]{0,120}[:>]\s*$", re.I)
ANSI_RE = re.compile(r"\x1b\[[0-9;?]*[ -/]*[@-~]")


def eprint(msg):
    sys.stderr.write(str(msg) + "\n")


def clean_ansi(text):
    return ANSI_RE.sub("", text or "")


def redact(text, secrets):
    result = text or ""
    for secret in secrets or []:
        if secret:
            result = result.replace(secret, "********")
    return result


def quote(value):
    return shlex.quote(str(value))


def load_config(path):
    if not path:
        path = os.environ.get("OGG_FK_CONFIG", "")
    if path and os.path.exists(path):
        with open(path, "r") as f:
            return json.load(f)
    return DEFAULT_CONFIG.copy()


def write_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write("\n")


def target_names(config):
    return sorted((config.get("targets") or {}).keys())


def get_target(config, args):
    name = getattr(args, "target", None) or os.environ.get("OGG_FK_TARGET") or "default"
    targets = config.get("targets") or {}
    if name not in targets:
        raise SystemExit("Unknown target '{0}'. Available: {1}".format(name, ", ".join(sorted(targets.keys())) or "none"))
    target = dict(targets[name])
    target["name"] = name
    for attr, key in [
        ("mode", "mode"),
        ("ssh", "ssh"),
        ("container", "container"),
        ("ogg_home", "ogg_home"),
        ("admin_url", "admin_url"),
        ("admin_user", "admin_user"),
        ("docker", "docker"),
    ]:
        value = getattr(args, attr, None)
        if value:
            target[key] = value
    if getattr(args, "trail_dir", None):
        target["trail_dirs"] = args.trail_dir
    if not target.get("mode"):
        target["mode"] = "local"
    if not target.get("ogg_home"):
        target["ogg_home"] = os.environ.get("OGG_HOME", "/u01/ogg")
    if not target.get("trail_dirs"):
        target["trail_dirs"] = ["/u02/Deployment/var/lib/data", os.path.join(target["ogg_home"], "dirdat")]
    return target


def ensure_password(args, target, purpose):
    env_password = os.environ.get("OGG_FK_PASSWORD")
    if env_password:
        return env_password
    if getattr(args, "no_password", False):
        return None
    return getpass.getpass("{0} password for {1}: ".format(purpose, target.get("admin_user") or "user"))


def parse_command_prefix(raw):
    return shlex.split(raw or "")


def binary_path(tool, target):
    home = target.get("ogg_home") or "/u01/ogg"
    candidate = os.path.join(home, "bin", tool)
    if os.path.exists(candidate):
        return candidate
    found = shutil.which(tool)
    return found or candidate


def exec_argv(tool, target, attach_tty=True):
    mode = (target.get("mode") or "local").lower()
    home = target.get("ogg_home") or "/u01/ogg"
    if mode == "local":
        return [binary_path(tool, target)]
    if mode == "ssh":
        ssh_target = target.get("ssh")
        if not ssh_target:
            raise SystemExit("Target '{0}' has no ssh value.".format(target.get("name")))
        tty_arg = "-tt" if attach_tty else "-T"
        remote = "cd {0} && exec {1}".format(quote(home), quote(os.path.join(home, "bin", tool)))
        return ["ssh", tty_arg, ssh_target, remote]
    if mode == "docker":
        container = target.get("container")
        if not container:
            raise SystemExit("Target '{0}' has no container value.".format(target.get("name")))
        docker = parse_command_prefix(target.get("docker") or os.environ.get("OGG_FK_DOCKER", "docker"))
        tty = "-it" if attach_tty else "-i"
        remote = "cd {0} && exec {1}".format(quote(home), quote(os.path.join(home, "bin", tool)))
        return docker + ["exec", tty, container, "bash", "-lc", remote]
    raise SystemExit("Unsupported mode: {0}".format(mode))


def shell_capture(target, remote_script, timeout=60):
    mode = (target.get("mode") or "local").lower()
    if mode == "local":
        argv = ["/bin/bash", "-lc", remote_script]
    elif mode == "ssh":
        ssh_target = target.get("ssh")
        if not ssh_target:
            raise SystemExit("Target '{0}' has no ssh value.".format(target.get("name")))
        argv = ["ssh", "-T", ssh_target, remote_script]
    elif mode == "docker":
        container = target.get("container")
        docker = parse_command_prefix(target.get("docker") or os.environ.get("OGG_FK_DOCKER", "docker"))
        argv = docker + ["exec", "-i", container, "bash", "-lc", remote_script]
    else:
        raise SystemExit("Unsupported mode: {0}".format(mode))
    proc = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    try:
        out, err = proc.communicate(timeout=timeout)
    except TypeError:  # Python 3.6 supports timeout, retained for defensive compatibility.
        out, err = proc.communicate()
    except subprocess.TimeoutExpired:
        proc.kill()
        out, err = proc.communicate()
        raise SystemExit("Command timed out: {0}".format(" ".join(argv)))
    if proc.returncode != 0:
        raise SystemExit("Command failed ({0}):\n{1}".format(proc.returncode, err or out))
    return out


def run_attached(argv):
    eprint("Running: {0}".format(" ".join(quote(x) for x in argv)))
    return subprocess.call(argv)


def set_winsize(fd, rows=36, cols=160):
    try:
        packed = struct.pack("HHHH", rows, cols, 0, 0)
        import fcntl as _fcntl
        _fcntl.ioctl(fd, termios.TIOCSWINSZ, packed)
    except Exception:
        pass


def run_pty_script(argv, commands, password=None, timeout=120, auto_exit=True, echo=True):
    commands = list(commands or [])
    capture = []
    sent = 0
    exit_sent = False
    password_sent = False
    tail = ""
    secrets = [password] if password else []

    master_fd, slave_fd = pty.openpty()
    set_winsize(master_fd)
    proc = subprocess.Popen(argv, stdin=slave_fd, stdout=slave_fd, stderr=slave_fd, close_fds=True, preexec_fn=os.setsid)
    os.close(slave_fd)
    start = time.time()

    def write_line(line):
        os.write(master_fd, (line + "\r").encode("utf-8"))

    try:
        while True:
            if proc.poll() is not None:
                break
            if time.time() - start > timeout:
                raise RuntimeError("Timed out waiting for CLI process")
            r, _, _ = select.select([master_fd], [], [], 0.25)
            if r:
                try:
                    data = os.read(master_fd, 8192)
                except OSError:
                    break
                if not data:
                    break
                text = data.decode("utf-8", "replace")
                safe = redact(text, secrets)
                capture.append(safe)
                if echo:
                    sys.stdout.write(safe)
                    sys.stdout.flush()
                tail = (tail + clean_ansi(text))[-1200:]
            plain_tail = clean_ansi(tail)
            if PASSWORD_RE.search(plain_tail):
                if password is None:
                    password = getpass.getpass("\nPassword: ")
                    secrets.append(password)
                if not password_sent:
                    write_line(password)
                    password_sent = True
                    tail = ""
                continue
            if PROMPT_RE.search(plain_tail):
                password_sent = False
                if sent < len(commands):
                    write_line(commands[sent])
                    sent += 1
                    tail = ""
                    continue
                if auto_exit and not exit_sent:
                    write_line("exit")
                    exit_sent = True
                    tail = ""
                    continue
            if exit_sent and proc.poll() is not None:
                break
    finally:
        try:
            os.close(master_fd)
        except Exception:
            pass
        if proc.poll() is None:
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
            except Exception:
                proc.terminate()
            try:
                proc.wait(timeout=3)
            except Exception:
                try:
                    os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
                except Exception:
                    pass
    return "".join(capture), proc.returncode


class RestClient(object):
    def __init__(self, base_url, username=None, password=None, insecure=False, timeout=20):
        self.base_url = (base_url or "").rstrip("/")
        self.username = username
        self.password = password
        self.insecure = insecure
        self.timeout = timeout

    def request(self, method, path):
        if not self.base_url:
            return {"ok": False, "path": path, "error": "admin_url is not configured"}
        url = self.base_url + "/" + path.lstrip("/")
        req = Request(url)
        req.get_method = lambda: method.upper()
        req.add_header("Accept", "application/json")
        if self.username:
            raw = ("{0}:{1}".format(self.username, self.password or "")).encode("utf-8")
            req.add_header("Authorization", "Basic " + base64.b64encode(raw).decode("ascii"))
        ctx = None
        if self.insecure and url.lower().startswith("https:"):
            ctx = ssl._create_unverified_context()
        try:
            resp = urlopen(req, timeout=self.timeout, context=ctx) if ctx else urlopen(req, timeout=self.timeout)
            body = resp.read().decode("utf-8", "replace")
            status = getattr(resp, "status", None) or resp.getcode()
            return {"ok": 200 <= status < 300, "status": status, "path": path, "url": url, "body": parse_body(body)}
        except HTTPError as exc:
            body = exc.read().decode("utf-8", "replace")
            return {"ok": False, "status": exc.code, "path": path, "url": url, "body": parse_body(body)}
        except URLError as exc:
            return {"ok": False, "path": path, "url": url, "error": str(exc.reason)}
        except Exception as exc:
            return {"ok": False, "path": path, "url": url, "error": str(exc)}


def parse_body(body):
    if not body:
        return None
    try:
        return json.loads(body)
    except Exception:
        return body


def print_json(data):
    print(json.dumps(data, indent=2, sort_keys=True))


def summarize_rest_item(item):
    marker = "OK" if item.get("ok") else "WARN"
    status = item.get("status", "-")
    print("[{0}] {1} {2}".format(marker, status, item.get("path")))
    if item.get("error"):
        print("  {0}".format(item.get("error")))


def html_report(title, sections, output_path):
    now = time.strftime("%Y-%m-%d %H:%M:%S")
    parts = [
        "<!doctype html><html><head><meta charset='utf-8'>",
        "<title>{0}</title>".format(html.escape(title)),
        "<style>body{font:14px system-ui,sans-serif;margin:24px;color:#17202a}h1{font-size:24px}h2{font-size:18px;margin-top:24px}pre{background:#0b1020;color:#dbeafe;padding:14px;border-radius:6px;overflow:auto;white-space:pre-wrap}table{border-collapse:collapse;width:100%}td,th{border:1px solid #d0d7de;padding:6px 8px;text-align:left}.muted{color:#667085}</style>",
        "</head><body><h1>{0}</h1><div class='muted'>Generated {1}</div>".format(html.escape(title), html.escape(now)),
    ]
    for heading, content in sections:
        parts.append("<h2>{0}</h2><pre>{1}</pre>".format(html.escape(heading), html.escape(content or "")))
    parts.append("</body></html>")
    with open(output_path, "w") as f:
        f.write("\n".join(parts))
    print("HTML report: {0}".format(output_path))


def command_init_config(args):
    output = args.output or "ogg-field-kit-config.json"
    if os.path.exists(output) and not args.force:
        raise SystemExit("Refusing to overwrite existing file: {0}".format(output))
    write_json(output, DEFAULT_CONFIG)
    print("Wrote sample config: {0}".format(output))
    print("Edit target host/user/path values. Do not store customer passwords in this file.")


def command_targets(args, config):
    for name in target_names(config):
        t = config["targets"][name]
        print("{0:14} mode={1:7} admin_url={2} ssh={3} container={4}".format(
            name, t.get("mode", "local"), t.get("admin_url", "-"), t.get("ssh", "-"), t.get("container", "-")))


def command_rest_get(args, config):
    target = get_target(config, args)
    user = args.user or target.get("admin_user")
    password = ensure_password(args, {"admin_user": user}, "GoldenGate REST") if user else None
    client = RestClient(args.admin_url or target.get("admin_url"), user, password, args.insecure, args.timeout)
    result = client.request("GET", args.path)
    print_json(result)


def command_snapshot(args, config, echo=True):
    target = get_target(config, args)
    user = args.user or target.get("admin_user")
    password = ensure_password(args, {"admin_user": user}, "GoldenGate REST") if user and not args.no_auth else None
    client = RestClient(args.admin_url or target.get("admin_url"), user if not args.no_auth else None, password, args.insecure, args.timeout)
    paths = args.path or COMMON_REST_PATHS
    results = [client.request("GET", p) for p in paths]
    if args.json:
        print_json({"target": target.get("name"), "results": results})
    else:
        print("GoldenGate REST snapshot target={0} url={1}".format(target.get("name"), client.base_url or "-"))
        for item in results:
            summarize_rest_item(item)
    if args.html:
        html_report("GoldenGate REST Snapshot", [("snapshot.json", json.dumps({"target": target.get("name"), "results": results}, indent=2, sort_keys=True))], args.html)
    return 0


def command_admin_shell(args, config):
    target = get_target(config, args)
    return run_attached(exec_argv("adminclient", target, attach_tty=True))


def command_admin_run(args, config):
    target = get_target(config, args)
    commands = list(args.cmd or [])
    if args.connect_url:
        user = args.connect_user or args.user or target.get("admin_user") or "oggadmin"
        commands.insert(0, "connect {0} as {1} !".format(args.connect_url, user))
        password = ensure_password(args, {"admin_user": user}, "Admin Client")
    else:
        password = None
    if not commands:
        commands = ["info all"]
    output, rc = run_pty_script(exec_argv("adminclient", target, attach_tty=True), commands, password=password, timeout=args.timeout)
    if args.html:
        html_report("GoldenGate Admin Client Output", [("adminclient", output)], args.html)
    return rc


def trails_find_script(dirs, limit):
    safe_dirs = " ".join(quote(d) for d in dirs)
    return "for d in {0}; do [ -d \"$d\" ] && find \"$d\" -maxdepth 2 -type f -printf '%T@\\t%p\\t%s\\t%TY-%Tm-%Td %TH:%TM\\n'; done | sort -n | tail -n {1}".format(safe_dirs, int(limit))


def list_trails(target, limit=50):
    out = shell_capture(target, trails_find_script(target.get("trail_dirs") or [], limit), timeout=60)
    rows = []
    for line in out.splitlines():
        parts = line.split("\t")
        if len(parts) >= 4 and parts[1].startswith("/"):
            rows.append({"path": parts[1], "size": parts[2], "mtime": parts[3]})
    return rows


def command_trails_list(args, config):
    target = get_target(config, args)
    rows = list_trails(target, args.limit)
    if args.json:
        print_json({"target": target.get("name"), "trails": rows})
        return 0
    print("Trail files target={0} mode={1}".format(target.get("name"), target.get("mode")))
    for row in rows:
        print("{0:19} {1:>12}  {2}".format(row.get("mtime", "-"), row.get("size", "-"), row.get("path", "-")))
    return 0


def command_logdump_shell(args, config):
    target = get_target(config, args)
    return run_attached(exec_argv("logdump", target, attach_tty=True))


def command_logdump_run(args, config):
    target = get_target(config, args)
    commands = []
    if args.trail:
        commands.append("open {0}".format(args.trail))
    commands.extend(args.cmd or [])
    if not commands:
        commands = ["env"]
    output, rc = run_pty_script(exec_argv("logdump", target, attach_tty=True), commands, password=None, timeout=args.timeout)
    if args.html:
        html_report("GoldenGate Logdump Output", [("logdump", output)], args.html)
    return rc


def command_collect(args, config):
    target = get_target(config, args)
    sections = []
    try:
        rows = list_trails(target, args.limit)
        trail_text = "\n".join("{mtime:19} {size:>12}  {path}".format(**r) for r in rows)
        sections.append(("Trail Files", trail_text))
    except Exception as exc:
        sections.append(("Trail Files", "ERROR: {0}".format(exc)))
    if not args.skip_rest:
        try:
            user = args.user or target.get("admin_user")
            password = ensure_password(args, {"admin_user": user}, "GoldenGate REST") if user and not args.no_auth else None
            client = RestClient(args.admin_url or target.get("admin_url"), user if not args.no_auth else None, password, args.insecure, args.timeout)
            results = [client.request("GET", p) for p in COMMON_REST_PATHS]
            sections.append(("REST Snapshot", json.dumps(results, indent=2, sort_keys=True)))
        except Exception as exc:
            sections.append(("REST Snapshot", "ERROR: {0}".format(exc)))
    output = args.html or "ogg-field-report-{0}.html".format(time.strftime("%Y%m%d-%H%M%S"))
    html_report("GoldenGate Field Report - {0}".format(target.get("name")), sections, output)


def ask(prompt, default=None):
    suffix = " [{0}]".format(default) if default else ""
    value = input(prompt + suffix + ": ").strip()
    return value or default


def command_menu(args, config):
    while True:
        print("\nGoldenGate Field Kit {0}".format(VERSION))
        print("Targets: {0}".format(", ".join(target_names(config))))
        print("1. List targets")
        print("2. REST snapshot")
        print("3. Admin Client interactive")
        print("4. Admin Client run commands")
        print("5. List trail files")
        print("6. Logdump open/run")
        print("7. Logdump interactive")
        print("8. Generate HTML field report")
        print("0. Exit")
        choice = ask("Select", "0")
        try:
            if choice == "1":
                command_targets(args, config)
            elif choice == "2":
                ns = argparse.Namespace(**vars(args)); ns.path = None; ns.json = False; ns.html = None; ns.no_auth = False
                command_snapshot(ns, config)
            elif choice == "3":
                command_admin_shell(args, config)
            elif choice == "4":
                ns = argparse.Namespace(**vars(args)); ns.cmd = []
                print("Enter Admin Client commands. Empty line runs them.")
                while True:
                    line = input("OGG cmd> ").strip()
                    if not line:
                        break
                    ns.cmd.append(line)
                ns.connect_url = ask("Connect URL, empty to skip", None)
                ns.connect_user = ask("Connect user", args.user or get_target(config, args).get("admin_user", "oggadmin")) if ns.connect_url else None
                ns.html = None
                command_admin_run(ns, config)
            elif choice == "5":
                ns = argparse.Namespace(**vars(args)); ns.limit = int(ask("Limit", "30")); ns.json = False
                command_trails_list(ns, config)
            elif choice == "6":
                ns = argparse.Namespace(**vars(args)); ns.trail = ask("Trail path", None); ns.cmd = []
                default_cmds = ["ghdr on", "detail on", "next 5"]
                print("Enter logdump commands. Empty line uses: {0}".format(", ".join(default_cmds)))
                while True:
                    line = input("Logdump cmd> ").strip()
                    if not line:
                        break
                    ns.cmd.append(line)
                if not ns.cmd:
                    ns.cmd = default_cmds
                ns.html = None
                command_logdump_run(ns, config)
            elif choice == "7":
                command_logdump_shell(args, config)
            elif choice == "8":
                ns = argparse.Namespace(**vars(args)); ns.limit = int(ask("Trail limit", "50")); ns.skip_rest = ask("Skip REST? y/N", "N").lower().startswith("y"); ns.html = ask("Output HTML", None); ns.no_auth = False
                command_collect(ns, config)
            elif choice == "0":
                return 0
        except KeyboardInterrupt:
            print("\nCanceled.")
        except Exception as exc:
            print("ERROR: {0}".format(exc))


def add_common_target_args(parser):
    parser.add_argument("--target", default=None, help="Target name from config, default OGG_FK_TARGET or default")
    parser.add_argument("--mode", choices=["local", "ssh", "docker"], default=None, help="Execution mode override")
    parser.add_argument("--ssh", default=None, help="SSH destination override, for example ogg@host")
    parser.add_argument("--container", default=None, help="Docker container override, lab only")
    parser.add_argument("--docker", default=None, help="Docker command prefix, for example 'sudo -n docker'")
    parser.add_argument("--ogg-home", default=None, help="GoldenGate home override")
    parser.add_argument("--trail-dir", action="append", help="Trail directory override; can be repeated")
    parser.add_argument("--admin-url", default=None, help="GoldenGate Admin Service base URL override")
    parser.add_argument("--user", default=None, help="GoldenGate REST/Admin Client user override")


def build_parser():
    parser = argparse.ArgumentParser(description="No-web GoldenGate field kit")
    parser.add_argument("--config", default=None, help="JSON config path; default OGG_FK_CONFIG or built-in sample")
    parser.add_argument("--version", action="version", version=VERSION)
    add_common_target_args(parser)
    sub = parser.add_subparsers(dest="command")

    p = sub.add_parser("init-config", help="Write sample config JSON")
    p.add_argument("--output", default="ogg-field-kit-config.json")
    p.add_argument("--force", action="store_true")

    sub.add_parser("targets", help="List configured targets")

    p = sub.add_parser("snapshot", help="Collect a REST snapshot from GoldenGate Admin Service")
    p.add_argument("--path", action="append", help="REST path to GET; can be repeated")
    p.add_argument("--json", action="store_true")
    p.add_argument("--html", default=None)
    p.add_argument("--insecure", action="store_true", help="Allow self-signed HTTPS certificates")
    p.add_argument("--timeout", type=int, default=20)
    p.add_argument("--no-auth", action="store_true")

    p = sub.add_parser("rest-get", help="GET one GoldenGate REST path")
    p.add_argument("path")
    p.add_argument("--insecure", action="store_true")
    p.add_argument("--timeout", type=int, default=20)
    p.add_argument("--no-password", action="store_true")

    p = sub.add_parser("admin-shell", help="Open interactive adminclient; no web server")

    p = sub.add_parser("admin-run", help="Run adminclient commands through a local PTY")
    p.add_argument("--cmd", action="append", help="Admin Client command; can be repeated")
    p.add_argument("--connect-url", default=None, help="Prepend 'connect URL as USER !' and prompt securely for password")
    p.add_argument("--connect-user", default=None)
    p.add_argument("--timeout", type=int, default=120)
    p.add_argument("--html", default=None)
    p.add_argument("--no-password", action="store_true")

    p = sub.add_parser("trails-list", help="List trail files locally, through SSH, or docker lab mode")
    p.add_argument("--limit", type=int, default=50)
    p.add_argument("--json", action="store_true")

    p = sub.add_parser("logdump-shell", help="Open interactive logdump; no web server")

    p = sub.add_parser("logdump-run", help="Run logdump commands through a local PTY")
    p.add_argument("--trail", default=None, help="Trail path to open")
    p.add_argument("--cmd", action="append", help="Logdump command; can be repeated")
    p.add_argument("--timeout", type=int, default=120)
    p.add_argument("--html", default=None)

    p = sub.add_parser("collect", help="Generate a lightweight HTML field report")
    p.add_argument("--limit", type=int, default=50)
    p.add_argument("--html", default=None)
    p.add_argument("--skip-rest", action="store_true")
    p.add_argument("--insecure", action="store_true")
    p.add_argument("--timeout", type=int, default=20)
    p.add_argument("--no-auth", action="store_true")

    sub.add_parser("menu", help="Interactive menu")
    return parser


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)
    config = load_config(args.config)
    cmd = args.command or "menu"
    if cmd == "init-config":
        return command_init_config(args)
    if cmd == "targets":
        return command_targets(args, config)
    if cmd == "snapshot":
        return command_snapshot(args, config)
    if cmd == "rest-get":
        return command_rest_get(args, config)
    if cmd == "admin-shell":
        return command_admin_shell(args, config)
    if cmd == "admin-run":
        return command_admin_run(args, config)
    if cmd == "trails-list":
        return command_trails_list(args, config)
    if cmd == "logdump-shell":
        return command_logdump_shell(args, config)
    if cmd == "logdump-run":
        return command_logdump_run(args, config)
    if cmd == "collect":
        return command_collect(args, config)
    if cmd == "menu":
        return command_menu(args, config)
    parser.print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())

