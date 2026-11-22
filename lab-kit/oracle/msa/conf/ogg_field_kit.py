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
import glob
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
import tty
try:
    from urllib.request import Request, urlopen
    from urllib.error import HTTPError, URLError
    from urllib.parse import urlencode, quote as urlquote
except ImportError:  # pragma: no cover
    from urllib2 import Request, urlopen, HTTPError, URLError
    from urllib import urlencode, quote as urlquote

VERSION = "0.1.21"
DEFAULT_BASE_DIR = os.environ.get("OGG_FK_BASE_DIR", "/u01/oracle/msa/util")
DEFAULT_CONFIG_NAME = os.environ.get("OGG_FK_CONFIG_NAME", "my-ogg.json")
DEFAULT_CONFIG = {
    "targets": {
        "source": {
            "description": "Self-managed GoldenGate on the current host.",
            "admin_url": "http://localhost:9011",
            "admin_user": "oggadmin",
            "mode": "local",
            "ogg_home": DEFAULT_BASE_DIR,
            "trail_dirs": [
                os.path.join(DEFAULT_BASE_DIR, "var/lib/data"),
                os.path.join(DEFAULT_BASE_DIR, "dirdat")
            ]
        },
        "remote-source": {
            "description": "Self-managed GoldenGate reached through SSH. Nothing is installed on the customer host.",
            "admin_url": "http://localhost:9011",
            "admin_user": "oggadmin",
            "mode": "ssh",
            "ssh": "ogg@customer-ogg-host",
            "ogg_home": DEFAULT_BASE_DIR,
            "trail_dirs": [
                os.path.join(DEFAULT_BASE_DIR, "var/lib/data"),
                os.path.join(DEFAULT_BASE_DIR, "dirdat")
            ]
        },
        "onprem-rest": {
            "description": "On-prem GoldenGate Admin Service through REST, using client-local adminclient/logdump. No Docker or sudo required.",
            "admin_url": "https://onprem-ogg-host:9011/services/v2",
            "admin_client_url": "https://onprem-ogg-host:9011",
            "admin_user": "oggadmin",
            "mode": "rest",
            "cli_mode": "local",
            "client_ogg_home": "/u01/ogg",
            "download_client_ogg_home": "/u01/ogg"
        },
        "oci-managed": {
            "description": "OCI GoldenGate managed deployment through Admin Service REST only. No OS access or trail directory is assumed.",
            "admin_url": "https://deployment-console-host:9011/services/v2",
            "admin_user": "oggadmin",
            "mode": "rest"
        },
        "lab-docker": {
            "description": "Lab/demo GoldenGate running inside a container. Requires docker permission.",
            "admin_url": "http://127.0.0.1:9112/services/v2",
            "admin_client_url": "http://localhost:9012",
            "admin_user": "oggadmin",
            "mode": "rest",
            "cli_mode": "docker",
            "cli_container": "demo_ogg_23ai",
            "cli_docker": "sudo docker",
            "client_ogg_home": "/u01/ogg",
            "download_client_ogg_home": "/u01/app/ogg/ogg2310"
        }
    }
}
COMMON_REST_PATHS = [
    "/services/v2/extracts",
    "/services/v2/replicats",
    "/services/v2/trails",
    "/services/v2/exttrails",
    "/services/v2/tasks",
    "/services/v2/messages",
    "/services/v2/credentials",
    "/services/v2/deployments",
]
REST_TRAILS_PATH = "/services/v2/trails"
PROMPT_RE = re.compile(r"(?:OGG[^\r\n]*\d+>|Logdump\s+\d+\s*>)\s*$", re.I)
PASSWORD_RE = re.compile(r"(?:password|passphrase)[^\r\n]{0,120}[:>]\s*$", re.I)
ANSI_RE = re.compile(r"\x1b\[[0-9;?]*[ -/]*[@-~]")
DEFAULT_LOGDUMP_SETTINGS = [
    "ghdr on",
    "detail data on",
    "usertoken detail on",
    "ggstoken detail on",
    "headertoken detail on",
]


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
    candidates = []
    if path:
        candidates.append(path)
    else:
        env_path = os.environ.get("OGG_FK_CONFIG", "")
        if env_path:
            candidates.append(env_path)
        candidates.extend([
            os.path.join(os.getcwd(), DEFAULT_CONFIG_NAME),
            os.path.join(os.getcwd(), "ogg-field-kit-config.json"),
            os.path.join(DEFAULT_BASE_DIR, DEFAULT_CONFIG_NAME),
            os.path.join(DEFAULT_BASE_DIR, "ogg-field-kit-config.json"),
        ])
    for candidate in candidates:
        if candidate and os.path.exists(candidate):
            with open(candidate, "r") as f:
                return json.load(f)
    return DEFAULT_CONFIG.copy()


def write_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write("\n")


def target_names(config):
    return sorted((config.get("targets") or {}).keys())


def get_target(config, args):
    targets = config.get("targets") or {}
    requested = getattr(args, "target", None) or os.environ.get("OGG_FK_TARGET")
    if requested:
        name = requested
    elif "default" in targets:
        name = "default"
    elif "source" in targets:
        name = "source"
    elif targets:
        name = sorted(targets.keys())[0]
    else:
        name = "default"
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
        ("cli_mode", "cli_mode"),
        ("cli_ssh", "cli_ssh"),
        ("cli_container", "cli_container"),
        ("cli_docker", "cli_docker"),
        ("client_ogg_home", "client_ogg_home"),
        ("adminclient_path", "adminclient_path"),
        ("logdump_path", "logdump_path"),
        ("admin_client_url", "admin_client_url"),
        ("download_dir", "download_dir"),
        ("download_client_ogg_home", "download_client_ogg_home"),
        ("download_logdump_path", "download_logdump_path"),
        ("cli_trail_dir", "cli_trail_dirs"),
        ("cli_trail_search_root", "cli_trail_search_roots"),
    ]:
        value = getattr(args, attr, None)
        if value:
            target[key] = value
    if getattr(args, "trail_dir", None):
        target["trail_dirs"] = args.trail_dir
    if not target.get("mode"):
        target["mode"] = "local"
    mode = (target.get("mode") or "local").lower()
    if mode == "oci":
        target["mode"] = "rest"
        mode = "rest"
    if mode != "rest" and not target.get("ogg_home"):
        target["ogg_home"] = os.environ.get("OGG_HOME", DEFAULT_BASE_DIR)
    if mode != "rest" and not target.get("trail_dirs"):
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


def cli_home(target):
    return target.get("client_ogg_home") or target.get("ogg_home") or os.environ.get("OGG_HOME") or DEFAULT_BASE_DIR


def effective_cli_mode(target):
    base_mode = (target.get("mode") or "local").lower()
    mode = (target.get("cli_mode") or "").lower()
    if mode:
        return mode
    if base_mode in ("rest", "oci"):
        if target.get("cli_container") or target.get("container"):
            return "docker"
        if target.get("cli_ssh"):
            return "ssh"
        if target.get("client_ogg_home") or target.get("adminclient_path") or target.get("logdump_path"):
            return "local"
        return "none"
    return base_mode


def configured_tool_path(tool, target):
    return target.get("{0}_path".format(tool)) or target.get("client_{0}_path".format(tool))


def binary_path(tool, target):
    configured = configured_tool_path(tool, target)
    if configured:
        return configured
    home = cli_home(target)
    candidate = os.path.join(home, "bin", tool)
    if os.path.exists(candidate):
        return candidate
    found = shutil.which(tool)
    return found or candidate


def ensure_local_binary(path, tool, target):
    if os.path.sep not in path and shutil.which(path):
        return
    if os.path.exists(path):
        return
    raise SystemExit("Cannot find local {0} for target {1}. Configure client_ogg_home/{0}_path, put {0} in PATH, or set cli_mode to ssh/docker.".format(tool, target.get("name")))


def remote_tool_path(tool, target):
    return configured_tool_path(tool, target) or os.path.join(cli_home(target), "bin", tool)


def exec_argv(tool, target, attach_tty=True):
    mode = effective_cli_mode(target)
    home = cli_home(target)
    if mode == "none":
        raise SystemExit("Target {0} has CLI execution disabled. Use REST functions only.".format(target.get("name")))
    if mode == "local":
        path = binary_path(tool, target)
        ensure_local_binary(path, tool, target)
        return [path]
    if mode == "ssh":
        ssh_target = target.get("cli_ssh") or target.get("ssh")
        if not ssh_target:
            raise SystemExit("Target '{0}' has no cli_ssh or ssh value.".format(target.get("name")))
        tty_arg = "-tt" if attach_tty else "-T"
        remote = "cd {0} && exec {1}".format(quote(home), quote(remote_tool_path(tool, target)))
        return ["ssh", tty_arg, ssh_target, remote]
    if mode == "docker":
        container = target.get("cli_container") or target.get("container")
        if not container:
            raise SystemExit("Target '{0}' has no cli_container or container value.".format(target.get("name")))
        docker = parse_command_prefix(target.get("cli_docker") or target.get("docker") or os.environ.get("OGG_FK_DOCKER", "docker"))
        tty = "-it" if attach_tty else "-i"
        remote = "cd {0} && exec {1}".format(quote(home), quote(remote_tool_path(tool, target)))
        return docker + ["exec", tty, container, "bash", "-lc", remote]
    if mode in ("rest", "oci"):
        raise SystemExit("Target {0} has cli_mode={1}. Admin Client/logdump need a local, SSH, or Docker CLI runner.".format(target.get("name"), mode))
    raise SystemExit("Unsupported cli_mode: {0}".format(mode))


def default_admin_client_url(target):
    url = target.get("admin_client_url") or target.get("adminclient_url") or target.get("connect_url") or target.get("admin_url") or ""
    return re.sub(r"/services/v2/?$", "", url.rstrip("/"))


def describe_cli(t):
    mode = effective_cli_mode(t)
    if mode == "docker":
        return "docker:{0}".format(t.get("cli_container") or t.get("container") or "-")
    if mode == "ssh":
        return "ssh:{0}".format(t.get("cli_ssh") or t.get("ssh") or "-")
    if mode == "local":
        return "local:{0}".format(t.get("client_ogg_home") or t.get("ogg_home") or os.environ.get("OGG_HOME") or "PATH")
    return mode or "-"


def as_list(value):
    if not value:
        return []
    if isinstance(value, list):
        return [str(v) for v in value if v]
    return [str(value)]


def unique_values(values):
    seen = set()
    result = []
    for value in values:
        if not value or value in seen:
            continue
        seen.add(value)
        result.append(value)
    return result


def cli_trail_dirs(target):
    dirs = as_list(target.get("cli_trail_dirs"))
    if not dirs and (target.get("mode") or "local").lower() not in ("rest", "oci"):
        dirs = as_list(target.get("trail_dirs"))
    return unique_values(dirs)


def trail_search_roots(target):
    return unique_values(as_list(target.get("cli_trail_search_roots")))


def trail_sequence_filename(trail_name, sequence):
    prefix = str(trail_name or "").strip()
    seq = str(sequence or "").strip()
    if not prefix or not seq:
        raise SystemExit("Trail name and sequence are required, for example c1 and 6186.")
    if seq.startswith(prefix) and re.search(r"\d{9}$", seq):
        return seq
    if not re.match(r"^\d+$", seq):
        raise SystemExit("Trail sequence must be numeric, for example 6186.")
    return prefix + "{0:09d}".format(int(seq))


def cli_shell_capture(target, remote_script, timeout=60):
    mode = effective_cli_mode(target)
    home = cli_home(target)
    script = "cd {0} && {1}".format(quote(home), remote_script) if home else remote_script
    if mode == "none":
        raise SystemExit("Target {0} has CLI execution disabled. Configure cli_mode to local, ssh, or docker.".format(target.get("name")))
    if mode == "local":
        argv = ["/bin/bash", "-lc", script]
    elif mode == "ssh":
        ssh_target = target.get("cli_ssh") or target.get("ssh")
        if not ssh_target:
            raise SystemExit("Target '{0}' has no cli_ssh or ssh value.".format(target.get("name")))
        argv = ["ssh", "-T", ssh_target, script]
    elif mode == "docker":
        container = target.get("cli_container") or target.get("container")
        if not container:
            raise SystemExit("Target '{0}' has no cli_container or container value.".format(target.get("name")))
        docker = parse_command_prefix(target.get("cli_docker") or target.get("docker") or os.environ.get("OGG_FK_DOCKER", "docker"))
        argv = docker + ["exec", "-i", container, "bash", "-lc", script]
    else:
        raise SystemExit("Unsupported cli_mode: {0}".format(mode))
    proc = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    try:
        out, err = proc.communicate(timeout=timeout)
    except TypeError:
        out, err = proc.communicate()
    except subprocess.TimeoutExpired:
        proc.kill()
        out, err = proc.communicate()
        raise SystemExit("Command timed out: {0}".format(" ".join(argv)))
    if proc.returncode != 0:
        raise SystemExit("Command failed ({0}):\n{1}".format(proc.returncode, err or out))
    return out


def resolve_trail_file(target, trail_name=None, sequence=None, filename=None, timeout=60):
    fname = filename or trail_sequence_filename(trail_name, sequence)
    if os.path.sep in fname:
        return fname

    exact_dirs = cli_trail_dirs(target)
    search_roots = trail_search_roots(target)
    safe_dirs = " ".join(quote(d) for d in exact_dirs)
    safe_roots = " ".join(quote(r) for r in search_roots)
    script = """
fname={fname}
exact_dirs=({exact_dirs})
search_roots=({search_roots})

for d in "${{exact_dirs[@]}}" \
  "${{OGG_VAR_HOME:-}}/lib/data" \
  "${{OGG_VAR_HOME:-}}/data" \
  "${{OGG_HOME:-}}/var/lib/data" \
  "${{OGG_HOME:-}}/dirdat" \
  "./var/lib/data" \
  "./dirdat" \
  "/u02/Deployment/var/lib/data" \
  "/u01/ogg/var/lib/data" \
  "/u01/ogg/dirdat" \
  "/u01/app/ogg/var/lib/data" \
  "/u01/app/ogg/dirdat" \
  "/opt/oracle/ogg/var/lib/data" \
  "/opt/oracle/ogg/dirdat"
do
  [ -n "$d" ] || continue
  [ -d "$d" ] || continue
  f=$(find "$d" -maxdepth 2 -type f -name "$fname" -print -quit 2>/dev/null)
  [ -n "$f" ] && printf '%s\n' "$f" && exit 0
done

if [ ${{#search_roots[@]}} -eq 0 ]; then
  search_roots=("${{OGG_VAR_HOME:-}}" "${{OGG_HOME:-}}" "/u02" "/u01/ogg" "/u01/oracle" "/opt/oracle")
fi
for r in "${{search_roots[@]}}"
do
  [ -n "$r" ] || continue
  [ -d "$r" ] || continue
  f=$(find "$r" -maxdepth 8 -type f -name "$fname" -print -quit 2>/dev/null)
  [ -n "$f" ] && printf '%s\n' "$f" && exit 0
done
true
""".format(fname=quote(fname), exact_dirs=safe_dirs, search_roots=safe_roots)
    out = cli_shell_capture(target, script, timeout=timeout)
    for line in out.splitlines():
        line = line.strip()
        if line.startswith(os.path.sep):
            return line
    hint = "configured dirs: {0}; search roots: {1}".format(
        ", ".join(exact_dirs) or "auto",
        ", ".join(search_roots) or "auto common GoldenGate roots")
    raise SystemExit("Trail file {0} was not found by CLI runner ({1}).".format(fname, hint))


def has_cli_runner(target):
    return effective_cli_mode(target) not in ("none", "rest", "oci")


def list_cli_trail_files(target, trail_name, limit=5, timeout=60):
    prefix = str(trail_name or "").strip()
    if not prefix or not has_cli_runner(target):
        return []
    try:
        limit = max(1, int(limit))
    except Exception:
        limit = 5
    pattern = prefix + "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"
    exact_dirs = cli_trail_dirs(target)
    search_roots = trail_search_roots(target)
    safe_dirs = " ".join(quote(d) for d in exact_dirs)
    safe_roots = " ".join(quote(r) for r in search_roots)
    script = """
pattern={pattern}
limit={limit}
exact_dirs=({exact_dirs})
search_roots=({search_roots})
tmp=${{TMPDIR:-/tmp}}/ogg_fk_trails_$$.lst
: > "$tmp"

for d in "${{exact_dirs[@]}}" \
  "${{OGG_VAR_HOME:-}}/lib/data" \
  "${{OGG_VAR_HOME:-}}/data" \
  "${{OGG_HOME:-}}/var/lib/data" \
  "${{OGG_HOME:-}}/dirdat" \
  "./var/lib/data" \
  "./dirdat" \
  "/u02/Deployment/var/lib/data" \
  "/u01/ogg/var/lib/data" \
  "/u01/ogg/dirdat" \
  "/u01/app/ogg/var/lib/data" \
  "/u01/app/ogg/dirdat" \
  "/opt/oracle/ogg/var/lib/data" \
  "/opt/oracle/ogg/dirdat"
do
  [ -n "$d" ] || continue
  [ -d "$d" ] || continue
  find "$d" -maxdepth 2 -type f -name "$pattern" -printf '%f\t%p\t%s\t%TY-%Tm-%Td %TH:%TM\n' 2>/dev/null >> "$tmp"
done

if [ ! -s "$tmp" ]; then
  if [ ${{#search_roots[@]}} -eq 0 ]; then
    search_roots=("${{OGG_VAR_HOME:-}}" "${{OGG_HOME:-}}" "/u02" "/u01/ogg" "/u01/oracle" "/opt/oracle")
  fi
  for r in "${{search_roots[@]}}"
  do
    [ -n "$r" ] || continue
    [ -d "$r" ] || continue
    find "$r" -maxdepth 8 -type f -name "$pattern" -printf '%f\t%p\t%s\t%TY-%Tm-%Td %TH:%TM\n' 2>/dev/null >> "$tmp"
  done
fi

sort -u "$tmp" | sort -k1,1 | tail -n "$limit"
rm -f "$tmp"
""".format(pattern=quote(pattern), limit=int(limit), exact_dirs=safe_dirs, search_roots=safe_roots)
    out = cli_shell_capture(target, script, timeout=timeout)
    rows = []
    for line in out.splitlines():
        parts = line.split("	")
        if len(parts) >= 4 and parts[1].startswith(os.path.sep):
            rows.append({"file": parts[0], "path": parts[1], "size": parts[2], "mtime": parts[3]})
    return rows


def print_resolved_trail_files(target, summaries, limit=5, timeout=60):
    if not summaries or not has_cli_runner(target):
        return
    printed_header = False
    for summary in summaries:
        name = summary.get("name")
        if not name:
            continue
        try:
            rows = list_cli_trail_files(target, name, limit=limit, timeout=timeout)
        except Exception as exc:
            if not printed_header:
                print("\nResolved trail files visible to logdump:")
                printed_header = True
            print("  {0}: unable to list files: {1}".format(name, exc))
            continue
        if not rows:
            continue
        if not printed_header:
            print("\nResolved trail files visible to logdump:")
            printed_header = True
        print("  {0}:".format(name))
        for row in rows:
            print("    {0:19} {1:>12}  {2}".format(row.get("mtime", "-"), row.get("size", "-"), row.get("path", "-")))
        print("    Example: open {0}".format(rows[-1].get("path")))


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
    elif mode in ("rest", "oci"):
        raise SystemExit("Target {0} is REST-only. This target does not expose OS trail directories. Use REST trails-list or analyze downloaded backup trail files locally.".format(target.get("name")))
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


def run_pty_interactive(argv, pre_commands=None, timeout=60):
    pre_commands = list(pre_commands or [])
    if not sys.stdin.isatty():
        commands = pre_commands + ["env"]
        output, rc = run_pty_script(argv, commands, password=None, timeout=timeout, auto_exit=True)
        return rc

    eprint("Running: {0}".format(" ".join(quote(x) for x in argv)))
    master_fd, slave_fd = pty.openpty()
    set_winsize(master_fd)
    proc = subprocess.Popen(argv, stdin=slave_fd, stdout=slave_fd, stderr=slave_fd, close_fds=True, preexec_fn=os.setsid)
    os.close(slave_fd)

    stdin_fd = sys.stdin.fileno()
    stdout_fd = sys.stdout.fileno()
    old_attrs = termios.tcgetattr(stdin_fd)
    sent = 0
    tail = ""
    start = time.time()

    try:
        tty.setraw(stdin_fd)
        while True:
            if proc.poll() is not None:
                break
            if sent < len(pre_commands) and time.time() - start > timeout:
                raise RuntimeError("Timed out waiting for CLI prompt")
            watch = [master_fd]
            if sent >= len(pre_commands):
                watch.append(stdin_fd)
            ready, _, _ = select.select(watch, [], [], 0.1)
            if master_fd in ready:
                try:
                    data = os.read(master_fd, 8192)
                except OSError:
                    break
                if not data:
                    break
                os.write(stdout_fd, data)
                tail = (tail + clean_ansi(data.decode("utf-8", "replace")))[-1200:]
            if sent < len(pre_commands) and PROMPT_RE.search(clean_ansi(tail)):
                os.write(master_fd, (pre_commands[sent] + "\r").encode("utf-8"))
                sent += 1
                tail = ""
                continue
            if stdin_fd in ready:
                try:
                    data = os.read(stdin_fd, 1024)
                except OSError:
                    data = b""
                if data:
                    os.write(master_fd, data)
                else:
                    break
    finally:
        try:
            termios.tcsetattr(stdin_fd, termios.TCSADRAIN, old_attrs)
        except Exception:
            pass
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
    return proc.returncode


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

    def make_url(self, path, query=None):
        if not self.base_url:
            return None
        clean_path = path or "/"
        if self.base_url.endswith("/services/v2") and clean_path.startswith("/services/v2/"):
            clean_path = clean_path[len("/services/v2"):]
        url = self.base_url + "/" + clean_path.lstrip("/")
        if query:
            url += "?" + urlencode(query)
        return url

    def add_auth(self, req):
        if self.username:
            raw = ("{0}:{1}".format(self.username, self.password or "")).encode("utf-8")
            req.add_header("Authorization", "Basic " + base64.b64encode(raw).decode("ascii"))

    def ssl_context(self, url):
        if self.insecure and url.lower().startswith("https:"):
            return ssl._create_unverified_context()
        return None

    def request(self, method, path):
        url = self.make_url(path)
        if not url:
            return {"ok": False, "path": path, "error": "admin_url is not configured"}
        req = Request(url)
        req.get_method = lambda: method.upper()
        req.add_header("Accept", "application/json")
        self.add_auth(req)
        ctx = self.ssl_context(url)
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

    def download(self, path, output_path, query=None):
        url = self.make_url(path, query=query)
        if not url:
            return {"ok": False, "path": path, "error": "admin_url is not configured"}
        req = Request(url)
        req.get_method = lambda: "GET"
        req.add_header("Accept", "application/binary")
        self.add_auth(req)
        ctx = self.ssl_context(url)
        try:
            resp = urlopen(req, timeout=self.timeout, context=ctx) if ctx else urlopen(req, timeout=self.timeout)
            status = getattr(resp, "status", None) or resp.getcode()
            content_type = resp.headers.get("Content-Type", "") if getattr(resp, "headers", None) else ""
            data = resp.read()
            if "json" in content_type.lower() or content_type.lower().startswith("text/"):
                return {"ok": False, "status": status, "path": path, "url": url, "content_type": content_type, "body": parse_body(data.decode("utf-8", "replace"))}
            with open(output_path, "wb") as f:
                f.write(data)
            return {"ok": 200 <= status < 300, "status": status, "path": path, "url": url, "content_type": content_type, "output": output_path, "bytes": len(data)}
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
    output = args.output or DEFAULT_CONFIG_NAME
    if os.path.exists(output) and not args.force:
        raise SystemExit("Refusing to overwrite existing file: {0}".format(output))
    write_json(output, DEFAULT_CONFIG)
    print("Wrote sample config: {0}".format(output))
    print("Edit target host/user/path values. Do not store customer passwords in this file.")


def command_targets(args, config):
    active = get_target(config, args).get("name")
    for name in target_names(config):
        t = dict(config["targets"][name])
        t["name"] = name
        mode = t.get("mode", "local")
        if mode not in ("rest", "oci"):
            trails = ",".join(t.get("trail_dirs") or [])
        else:
            cli_dirs = ",".join(t.get("cli_trail_dirs") or [])
            roots = ",".join(t.get("cli_trail_search_roots") or [])
            if not has_cli_runner(t):
                trails = "REST metadata/download only"
            elif cli_dirs:
                trails = "REST metadata/download; advanced cli_dirs=" + cli_dirs
            elif roots:
                trails = "REST metadata/download; advanced auto roots=" + roots
            else:
                trails = "REST metadata/download to client; local logdump"
        marker = "*" if name == active else " "
        print("{0} {1:14} mode={2:7} cli={3:24} rest_url={4} admin_connect={5} ssh={6} trails={7}".format(
            marker, name, mode, describe_cli(t), t.get("admin_url", "-"), default_admin_client_url(t) or "-", t.get("ssh", "-"), trails or "-"))

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
    no_auth = getattr(args, "no_auth", False)
    password = ensure_password(args, {"admin_user": user}, "GoldenGate REST") if user and not no_auth else None
    client = RestClient(args.admin_url or target.get("admin_url"), user if not no_auth else None, password, getattr(args, "insecure", False), getattr(args, "timeout", 20))
    paths = getattr(args, "path", None) or COMMON_REST_PATHS
    results = [client.request("GET", p) for p in paths]
    if getattr(args, "json", False):
        print_json({"target": target.get("name"), "results": results})
    else:
        print("GoldenGate REST snapshot target={0} url={1}".format(target.get("name"), client.base_url or "-"))
        for item in results:
            summarize_rest_item(item)
    html_path = getattr(args, "html", None)
    if html_path:
        html_report("GoldenGate REST Snapshot", [("snapshot.json", json.dumps({"target": target.get("name"), "results": results}, indent=2, sort_keys=True))], html_path)
    return 0


def command_admin_shell(args, config):
    target = get_target(config, args)
    requested_url = getattr(args, "connect_url", None)
    if requested_url == "-":
        requested_url = None
    connect_url = requested_url or default_admin_client_url(target)
    user = getattr(args, "connect_user", None) or args.user or target.get("admin_user") or "oggadmin"
    if getattr(args, "connect", False):
        if not connect_url:
            raise SystemExit("No Admin Client connect URL is configured. Set admin_client_url or admin_url in the target.")
        command = "connect {0} as {1} !".format(connect_url, user)
        eprint("Auto-connect: {0}".format(command))
        return run_pty_interactive(exec_argv("adminclient", target, attach_tty=True), pre_commands=[command], timeout=getattr(args, "timeout", 60))
    if connect_url:
        eprint("Hint: connect {0} as {1} !".format(connect_url, user))
    return run_attached(exec_argv("adminclient", target, attach_tty=True))


def command_admin_run(args, config):
    target = get_target(config, args)
    commands = list(args.cmd or [])
    connect_url = getattr(args, "connect_url", None)
    if connect_url == "-":
        connect_url = None
    if connect_url:
        user = args.connect_user or args.user or target.get("admin_user") or "oggadmin"
        commands.insert(0, "connect {0} as {1} !".format(connect_url, user))
        password = ensure_password(args, {"admin_user": user}, "Admin Client")
    else:
        password = None
    if not commands:
        commands = ["info all"]
    output, rc = run_pty_script(exec_argv("adminclient", target, attach_tty=True), commands, password=password, timeout=getattr(args, "timeout", 120))
    if getattr(args, "html", None):
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


def get_path_value(data, path, default=None):
    cur = data
    for key in path:
        if isinstance(cur, dict):
            cur = cur.get(key)
        elif isinstance(cur, list) and isinstance(key, int) and 0 <= key < len(cur):
            cur = cur[key]
        else:
            return default
    return default if cur is None else cur


def rest_items(body):
    items = get_path_value(body, ["response", "items"])
    if items is None and isinstance(body, dict):
        items = body.get("items")
    return items if isinstance(items, list) else []


def trail_detail_summary(name, detail_body):
    response = detail_body.get("response", detail_body) if isinstance(detail_body, dict) else {}
    refs = response.get("processRef") or []
    def ref_name(idx):
        if isinstance(refs, list) and idx < len(refs) and isinstance(refs[idx], dict):
            return refs[idx].get("processName") or ""
        return ""
    return {
        "name": response.get("name") or name,
        "producer": ref_name(0),
        "consumer": ref_name(1),
        "distpath": ref_name(2),
        "sizeMB": response.get("sizeMB"),
        "spaceUsed": response.get("spaceUsed"),
        "sequenceMin": response.get("sequenceMin"),
        "sequenceMax": response.get("sequenceMax"),
    }


def rest_trail_summaries(result):
    summaries = []
    for row in result.get("details") or []:
        detail = row.get("detail") or {}
        if detail.get("ok"):
            summaries.append(trail_detail_summary(row.get("name"), detail.get("body") or {}))
    return summaries


def rest_trails_list(target, args):
    user = args.user or target.get("admin_user")
    password = ensure_password(args, {"admin_user": user}, "GoldenGate REST") if user and not getattr(args, "no_auth", False) else None
    client = RestClient(args.admin_url or target.get("admin_url"), user if not getattr(args, "no_auth", False) else None, password, getattr(args, "insecure", False), getattr(args, "timeout", 20))
    listing = client.request("GET", REST_TRAILS_PATH)
    details = []
    if listing.get("ok"):
        for item in rest_items(listing.get("body")):
            name = item.get("name") if isinstance(item, dict) else None
            if not name:
                continue
            detail = client.request("GET", REST_TRAILS_PATH + "/" + str(name))
            details.append({"name": name, "detail": detail})
    result = {"target": target.get("name"), "mode": target.get("mode"), "listing": listing, "details": details}
    if args.json:
        print_json(result)
    else:
        print("Trail metadata target={0} mode={1} url={2}".format(target.get("name"), target.get("mode"), client.base_url or "-"))
        print("APEX Page 159 compatible flow: GET /trails, then GET /trails/<trail-name>.")
        print("Note: REST metadata does not expose OS trail directories. Download a selected sequence to this client, then analyze it with local logdump.")
        summarize_rest_item(listing)
        if listing.get("ok") and details:
            print("{0:18} {1:18} {2:18} {3:18} {4:10} {5}".format("TRAIL", "PRODUCER", "CONSUMER", "DISTPATH", "SIZE_MB", "SEQUENCES"))
            summaries = []
            for row in details:
                detail = row.get("detail") or {}
                if not detail.get("ok"):
                    print("{0:18} detail fetch failed: {1}".format(row.get("name", "-"), detail.get("status", detail.get("error", "-"))))
                    continue
                summary = trail_detail_summary(row.get("name"), detail.get("body") or {})
                summaries.append(summary)
                seq = "{0} to {1}".format(summary.get("sequenceMin") or "", summary.get("sequenceMax") or "").strip()
                print("{name:18} {producer:18} {consumer:18} {distpath:18} {size!s:10} {seq}".format(
                    name=str(summary.get("name") or "-")[:18],
                    producer=str(summary.get("producer") or "-")[:18],
                    consumer=str(summary.get("consumer") or "-")[:18],
                    distpath=str(summary.get("distpath") or "-")[:18],
                    size=summary.get("sizeMB") if summary.get("sizeMB") is not None else "-",
                    seq=seq or "-"))
            if not getattr(args, "no_resolve_files", False):
                print_resolved_trail_files(target, summaries, limit=getattr(args, "files_per_trail", 5), timeout=getattr(args, "timeout", 20))
        elif listing.get("ok"):
            print("No trail names found in response.items[].name")
    return result if getattr(args, "return_data", False) else 0


def command_trails_list(args, config):
    target = get_target(config, args)
    if (target.get("mode") or "local").lower() in ("rest", "oci"):
        return rest_trails_list(target, args)
    rows = list_trails(target, getattr(args, "limit", 50))
    if args.json:
        print_json({"target": target.get("name"), "trails": rows})
        return 0
    print("Trail files target={0} mode={1}".format(target.get("name"), target.get("mode")))
    for row in rows:
        print("{0:19} {1:>12}  {2}".format(row.get("mtime", "-"), row.get("size", "-"), row.get("path", "-")))
    return {"target": target.get("name"), "mode": target.get("mode"), "files": rows} if getattr(args, "return_data", False) else 0



def default_download_dir(target, trail_name):
    base = target.get("download_dir") or os.environ.get("OGG_FK_DOWNLOAD_DIR")
    if base:
        return os.path.join(base, target.get("name") or "target", str(trail_name or "trail")) if base == os.environ.get("OGG_FK_DOWNLOAD_DIR") else base
    return os.path.join(os.getcwd(), "trail-downloads", target.get("name") or "target", str(trail_name or "trail"))



def download_root_candidates(target):
    roots = []
    if target.get("download_dir"):
        roots.append(target.get("download_dir"))
    if os.environ.get("OGG_FK_DOWNLOAD_DIR"):
        roots.append(os.path.join(os.environ.get("OGG_FK_DOWNLOAD_DIR"), target.get("name") or "target"))
    roots.append(os.path.join(os.getcwd(), "trail-downloads", target.get("name") or "target"))
    default_root = os.path.join(DEFAULT_BASE_DIR, "trail-downloads", target.get("name") or "target")
    if os.path.abspath(default_root) != os.path.abspath(roots[-1]):
        roots.append(default_root)
    result = []
    seen = set()
    for root in roots:
        if not root:
            continue
        key = os.path.abspath(root)
        if key in seen:
            continue
        seen.add(key)
        result.append(root)
    return result


def downloaded_trail_records(target, limit=20):
    rows = []
    seen = set()
    pattern = re.compile(r"^(.+)(\d{9})$")
    for root in download_root_candidates(target):
        if not os.path.isdir(root):
            continue
        for dirpath, _, filenames in os.walk(root):
            for fname in filenames:
                if ".tmp." in fname:
                    continue
                path = os.path.join(dirpath, fname)
                if not os.path.isfile(path):
                    continue
                abs_path = os.path.abspath(path)
                if abs_path in seen:
                    continue
                seen.add(abs_path)
                match = pattern.match(fname)
                trail = match.group(1) if match else "-"
                sequence = str(int(match.group(2))) if match else "-"
                try:
                    stat = os.stat(path)
                    size = stat.st_size
                    mtime = stat.st_mtime
                except OSError:
                    size = 0
                    mtime = 0
                rows.append({"path": abs_path, "trail": trail, "sequence": sequence, "size": size, "mtime": mtime})
    rows.sort(key=lambda r: r.get("mtime", 0), reverse=True)
    return rows[:limit]


def choose_downloaded_trail_file(target, limit=30):
    rows = downloaded_trail_records(target, limit=limit)
    if rows:
        print("Downloaded/local trail files (newest first):")
        for idx, row in enumerate(rows, 1):
            mtime = time.strftime("%Y-%m-%d %H:%M", time.localtime(row.get("mtime") or 0))
            size_mb = int(((row.get("size") or 0) + 1048575) / 1048576)
            print("  {0:2}. trail={1} sequence={2} size={3}MB mtime={4}".format(idx, row.get("trail"), row.get("sequence"), size_mb, mtime))
            print("      {0}".format(row.get("path")))
        choice = ask("Trail number/local file path", "1")
        if choice and re.match(r"^\d+$", choice):
            pos = int(choice)
            if 1 <= pos <= len(rows):
                return rows[pos - 1].get("path")
        if choice:
            return choice
    print("No downloaded trail files found under:")
    for root in download_root_candidates(target):
        print("  {0}".format(root))
    return ask("Local trail file", None)


def rest_password_client(args, target):
    user = args.user or target.get("admin_user")
    no_auth = getattr(args, "no_auth", False) or getattr(args, "no_password", False)
    password = ensure_password(args, {"admin_user": user}, "GoldenGate REST") if user and not no_auth else None
    return RestClient(args.admin_url or target.get("admin_url"), user if not no_auth else None, password, getattr(args, "insecure", False), getattr(args, "timeout", 20))


def rest_trail_path(client, trail_name):
    detail = client.request("GET", REST_TRAILS_PATH + "/" + str(trail_name))
    if detail.get("ok") and isinstance(detail.get("body"), dict):
        body = detail.get("body") or {}
        response = body.get("response", body)
        if isinstance(response, dict):
            return response.get("path") or ""
    return ""


def trail_download_output_path(target, trail_name, sequence, args):
    if getattr(args, "output", None):
        output = args.output
        parent = os.path.dirname(os.path.abspath(output))
        if parent and not os.path.exists(parent):
            os.makedirs(parent)
        return output
    fname = trail_sequence_filename(trail_name, sequence)
    out_dir = getattr(args, "download_dir", None) or default_download_dir(target, trail_name)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    return os.path.join(out_dir, fname)


def download_trail_sequence(target, args):
    trail_name = getattr(args, "trail_name", None)
    sequence = getattr(args, "sequence", None)
    if not trail_name or not sequence:
        raise SystemExit("--trail-name and --seq are required for REST trail download.")
    client = rest_password_client(args, target)
    trail_path = getattr(args, "trail_path", None) or rest_trail_path(client, trail_name)
    output = trail_download_output_path(target, trail_name, sequence, args)
    query = {}
    if not getattr(args, "no_download_param", False):
        query["download"] = "true"
    if trail_path:
        query["path"] = trail_path
    eprint("Downloading trail sequence via REST: {0} sequence {1}".format(trail_name, sequence))
    if trail_path:
        eprint("REST trail path parameter: {0}".format(trail_path))
    result = client.download(REST_TRAILS_PATH + "/" + str(trail_name) + "/sequences/" + str(sequence), output, query=query)
    if not result.get("ok"):
        raise SystemExit("REST trail download failed: {0}".format(json.dumps(result, indent=2, sort_keys=True)))
    print("Trail sequence saved on client: {0}".format(output))
    return output


def local_download_logdump_argv(target):
    explicit = target.get("download_logdump_path")
    if explicit:
        if not os.path.exists(explicit):
            raise SystemExit("download_logdump_path does not exist: {0}".format(explicit))
        return [explicit]
    home = target.get("download_client_ogg_home")
    if home:
        path = os.path.join(home, "bin", "logdump")
        if not os.path.exists(path):
            raise SystemExit("download_client_ogg_home does not contain bin/logdump: {0}".format(home))
        return [path]
    if effective_cli_mode(target) == "local":
        return exec_argv("logdump", target, attach_tty=True)
    found = shutil.which("logdump")
    if found:
        return [found]
    for path in glob.glob("/u01/app/ogg/ogg*/bin/logdump") + ["/u01/ogg/bin/logdump"]:
        if os.path.exists(path):
            return [path]
    raise SystemExit("Cannot find local logdump for downloaded trail analysis. Configure download_client_ogg_home or download_logdump_path.")


def command_trail_download(args, config):
    target = get_target(config, args)
    download_trail_sequence(target, args)
    return 0


def command_download_logdump_shell(args, config):
    target = get_target(config, args)
    trail = getattr(args, "trail", None) or download_trail_sequence(target, args)
    pre_commands = list(DEFAULT_LOGDUMP_SETTINGS) + ["open {0}".format(trail)]
    eprint("Opening client-local trail file with local logdump: {0}".format(trail))
    return run_pty_interactive(local_download_logdump_argv(target), pre_commands=pre_commands, timeout=getattr(args, "timeout", 60))


def command_download_logdump_run(args, config):
    target = get_target(config, args)
    trail = getattr(args, "trail", None) or download_trail_sequence(target, args)
    commands = list(DEFAULT_LOGDUMP_SETTINGS) + ["open {0}".format(trail)]
    commands.extend(getattr(args, "cmd", None) or ["env"])
    output, rc = run_pty_script(local_download_logdump_argv(target), commands, password=None, timeout=getattr(args, "timeout", 120))
    html_path = getattr(args, "html", None)
    if html_path:
        html_report("GoldenGate Downloaded Trail Logdump Output", [("logdump", output)], html_path)
    return rc

def command_logdump_shell(args, config):
    target = get_target(config, args)
    trail = getattr(args, "trail", None)
    if not trail and getattr(args, "trail_name", None) and getattr(args, "sequence", None):
        trail = resolve_trail_file(target, getattr(args, "trail_name"), getattr(args, "sequence"), timeout=getattr(args, "timeout", 60))
        eprint("Resolved trail file: {0}".format(trail))
    elif trail and os.path.sep not in trail and cli_trail_dirs(target):
        trail = resolve_trail_file(target, filename=trail, timeout=getattr(args, "timeout", 60))
        eprint("Resolved trail file: {0}".format(trail))
    pre_commands = list(DEFAULT_LOGDUMP_SETTINGS)
    if trail:
        pre_commands.append("open {0}".format(trail))
    if trail:
        eprint("Logdump interactive. Default detail settings are enabled and the trail is opened automatically; type real logdump commands such as n, pos <rba>, pos reverse, pos forward, scanforendtrans, or exit.")
    else:
        eprint("Logdump interactive. Default detail settings are enabled; open a trail file, then type real logdump commands such as n, pos <rba>, pos reverse, pos forward, scanforendtrans, or exit.")
    return run_pty_interactive(exec_argv("logdump", target, attach_tty=True), pre_commands=pre_commands, timeout=getattr(args, "timeout", 60))


def command_logdump_run(args, config):
    target = get_target(config, args)
    commands = []
    trail = getattr(args, "trail", None)
    if not trail and getattr(args, "trail_name", None) and getattr(args, "sequence", None):
        trail = resolve_trail_file(target, getattr(args, "trail_name"), getattr(args, "sequence"), timeout=getattr(args, "timeout", 120))
        print("Resolved trail file: {0}".format(trail))
    elif trail and os.path.sep not in trail and cli_trail_dirs(target):
        trail = resolve_trail_file(target, filename=trail, timeout=getattr(args, "timeout", 120))
        print("Resolved trail file: {0}".format(trail))
    commands.extend(DEFAULT_LOGDUMP_SETTINGS)
    if trail:
        commands.append("open {0}".format(trail))
    commands.extend(getattr(args, "cmd", None) or [])
    if not commands:
        commands = ["env"]
    output, rc = run_pty_script(exec_argv("logdump", target, attach_tty=True), commands, password=None, timeout=getattr(args, "timeout", 120))
    html_path = getattr(args, "html", None)
    if html_path:
        html_report("GoldenGate Logdump Output", [("logdump", output)], html_path)
    return rc


def command_collect(args, config):
    target = get_target(config, args)
    sections = []
    try:
        rows = list_trails(target, getattr(args, "limit", 50))
        trail_text = "\n".join("{mtime:19} {size:>12}  {path}".format(**r) for r in rows)
        sections.append(("Trail Files", trail_text))
    except Exception as exc:
        sections.append(("Trail Files", "ERROR: {0}".format(exc)))
    if not getattr(args, "skip_rest", False):
        try:
            user = args.user or target.get("admin_user")
            no_auth = getattr(args, "no_auth", False)
            password = ensure_password(args, {"admin_user": user}, "GoldenGate REST") if user and not no_auth else None
            client = RestClient(args.admin_url or target.get("admin_url"), user if not no_auth else None, password, getattr(args, "insecure", False), getattr(args, "timeout", 20))
            results = [client.request("GET", p) for p in COMMON_REST_PATHS]
            sections.append(("REST Snapshot", json.dumps(results, indent=2, sort_keys=True)))
        except Exception as exc:
            sections.append(("REST Snapshot", "ERROR: {0}".format(exc)))
    output = getattr(args, "html", None) or "ogg-field-report-{0}.html".format(time.strftime("%Y%m%d-%H%M%S"))
    html_report("GoldenGate Field Report - {0}".format(target.get("name")), sections, output)


def ask(prompt, default=None):
    suffix = " [{0}]".format(default) if default else ""
    value = input(prompt + suffix + ": ").strip()
    return value or default


def command_menu(args, config):
    last_trails = []

    def print_recent_trails():
        if not last_trails:
            return
        print("Recent REST trail metadata:")
        for idx, row in enumerate(last_trails, 1):
            seq = row.get("sequenceMax") or row.get("sequenceMin") or "-"
            print("  {0}. {1} sequence={2} producer={3} consumer={4}".format(idx, row.get("name") or "-", seq, row.get("producer") or "-", row.get("consumer") or "-"))

    def select_trail_sequence(allow_local_file=False):
        ns = argparse.Namespace(**vars(args))
        ns.trail = None
        ns.trail_name = None
        ns.sequence = None
        ns.trail_path = None
        ns.output = None
        ns.no_download_param = False
        ns.no_auth = False
        ns.insecure = getattr(args, "insecure", False)
        ns.timeout = int(getattr(args, "timeout", 120) or 120)
        print_recent_trails()
        if not last_trails:
            print("Tip: option 5 shows REST trail metadata first. Use trail name + sequence when selecting directly.")
        default_choice = "1" if last_trails else None
        label = "Trail number/name"
        if allow_local_file:
            label += "/local file"
        trail_choice = ask(label, default_choice)
        selected = None
        if trail_choice and last_trails and re.match(r"^\d+$", trail_choice):
            pos = int(trail_choice)
            if 1 <= pos <= len(last_trails):
                selected = last_trails[pos - 1]
        if allow_local_file and trail_choice and os.path.exists(trail_choice):
            ns.trail = trail_choice
            return ns
        if selected:
            ns.trail_name = selected.get("name")
            ns.sequence = selected.get("sequenceMax") or selected.get("sequenceMin")
            if not ns.sequence:
                ns.sequence = ask("Sequence", None)
            print("Selected remote trail {0} sequence {1}".format(ns.trail_name, ns.sequence))
        elif trail_choice:
            ns.trail_name = trail_choice
            ns.sequence = ask("Sequence", None)
        if not ns.trail and (not ns.trail_name or not ns.sequence):
            raise SystemExit("Trail name and sequence are required for REST download.")
        return ns

    while True:
        active_target = get_target(config, args)
        print("\nGoldenGate Field Kit {0}".format(VERSION))
        print("Active target: {0}  admin_connect={1}".format(active_target.get("name"), default_admin_client_url(active_target) or "-"))
        print("Targets: {0}".format(", ".join(target_names(config))))
        print("1. List targets")
        print("2. REST snapshot")
        print("3. Admin Client interactive/login")
        print("4. List trail metadata/files")
        print("5. Download trail sequence + local Logdump interactive")
        print("6. Download trail sequence only")
        print("7. Local/downloaded file Logdump interactive")
        print("8. Advanced direct Logdump on OGG host filesystem")
        print("9. Generate HTML field report")
        print("0. Exit")
        choice = ask("Select", "0")
        try:
            if choice == "1":
                command_targets(args, config)
            elif choice == "2":
                ns = argparse.Namespace(**vars(args)); ns.path = None; ns.json = False; ns.html = None; ns.no_auth = False; ns.insecure = False; ns.timeout = 20
                command_snapshot(ns, config)
            elif choice == "3":
                target = get_target(config, args)
                ns = argparse.Namespace(**vars(args))
                ns.connect_url = default_admin_client_url(target)
                ns.connect_user = args.user or target.get("admin_user", "oggadmin")
                print("Target Admin Client URL: {0}".format(ns.connect_url or "not configured"))
                if ns.connect_url:
                    print("Connect command: connect {0} as {1} !".format(ns.connect_url, ns.connect_user))
                ns.connect = bool(ns.connect_url and ask("Auto-connect with this target? Y/n", "Y").lower().startswith("y"))
                ns.timeout = 60
                command_admin_shell(ns, config)
            elif choice == "4":
                ns = argparse.Namespace(**vars(args)); ns.limit = int(ask("Limit", "30")); ns.json = False; ns.return_data = True; ns.insecure = False; ns.timeout = 20; ns.no_auth = False; ns.files_per_trail = 5; ns.no_resolve_files = True
                data = command_trails_list(ns, config)
                last_trails = rest_trail_summaries(data) if isinstance(data, dict) and "details" in data else []
            elif choice == "5":
                print("This downloads the remote trail sequence through REST to this client first, then opens the downloaded file with local logdump.")
                ns = select_trail_sequence(allow_local_file=False)
                command_download_logdump_shell(ns, config)
            elif choice == "6":
                print("This downloads one remote trail sequence through REST to this client.")
                ns = select_trail_sequence(allow_local_file=False)
                command_trail_download(ns, config)
            elif choice == "7":
                target = get_target(config, args)
                ns = argparse.Namespace(**vars(args)); ns.trail = choose_downloaded_trail_file(target, limit=30); ns.trail_name = None; ns.sequence = None; ns.trail_path = None; ns.output = None; ns.no_download_param = False; ns.no_auth = False; ns.insecure = False; ns.timeout = 120
                if not ns.trail:
                    raise SystemExit("Local trail file path is required.")
                if not os.path.isfile(ns.trail):
                    raise SystemExit("Local trail file not found: {0}".format(ns.trail))
                command_download_logdump_shell(ns, config)
            elif choice == "8":
                target = get_target(config, args)
                ns = argparse.Namespace(**vars(args)); ns.cmd = []; ns.html = None; ns.trail = None; ns.trail_name = None; ns.sequence = None
                print("Advanced direct mode: logdump runs where the CLI runner can directly see the OGG filesystem: {0}".format(describe_cli(target)))
                print_recent_trails()
                selected = None
                default_choice = "1" if last_trails else None
                prompt = "Trail number/name/full path ('-' = plain logdump)" if last_trails else "Trail name/full path (empty = plain logdump)"
                trail_choice = ask(prompt, default_choice)
                if trail_choice == "-":
                    trail_choice = None
                if trail_choice and last_trails and re.match(r"^\d+$", trail_choice):
                    pos = int(trail_choice)
                    if 1 <= pos <= len(last_trails):
                        selected = last_trails[pos - 1]
                if selected:
                    ns.trail_name = selected.get("name")
                    ns.sequence = selected.get("sequenceMax") or selected.get("sequenceMin")
                    if not ns.sequence:
                        ns.sequence = ask("Sequence", None)
                    print("Selected trail {0} sequence {1}".format(ns.trail_name, ns.sequence))
                elif trail_choice and trail_choice.startswith(os.path.sep):
                    ns.trail = trail_choice
                elif trail_choice:
                    ns.trail_name = trail_choice
                    ns.sequence = ask("Sequence", None)
                command_logdump_shell(ns, config)
            elif choice == "9":
                ns = argparse.Namespace(**vars(args)); ns.limit = int(ask("Trail limit", "50")); ns.skip_rest = ask("Skip REST? y/N", "N").lower().startswith("y"); ns.html = ask("Output HTML", None); ns.no_auth = False; ns.insecure = False; ns.timeout = 20
                command_collect(ns, config)
            elif choice == "0":
                return 0
        except KeyboardInterrupt:
            print("\nCanceled.")
        except SystemExit as exc:
            if exc.code not in (None, 0):
                print("ERROR: {0}".format(exc))
        except Exception as exc:
            print("ERROR: {0}".format(exc))

def add_common_target_args(parser):
    parser.add_argument("--target", default=None, help="Target name from config, default OGG_FK_TARGET or default")
    parser.add_argument("--mode", choices=["local", "ssh", "docker", "rest", "oci"], default=None, help="Execution mode override")
    parser.add_argument("--ssh", default=None, help="SSH destination override, for example ogg@host")
    parser.add_argument("--container", default=None, help="Docker container override, lab only")
    parser.add_argument("--docker", default=None, help="Docker command prefix, for example 'sudo -n docker'")
    parser.add_argument("--ogg-home", default=None, help="GoldenGate home override")
    parser.add_argument("--trail-dir", action="append", help="Trail directory override; can be repeated")
    parser.add_argument("--admin-url", default=None, help="GoldenGate Admin Service base URL override")
    parser.add_argument("--user", default=None, help="GoldenGate REST/Admin Client user override")
    parser.add_argument("--cli-mode", choices=["local", "ssh", "docker", "none"], default=None, help="Where to run adminclient/logdump when target mode is REST")
    parser.add_argument("--cli-ssh", default=None, help="SSH destination for the CLI runner")
    parser.add_argument("--cli-container", default=None, help="Docker container for the CLI runner")
    parser.add_argument("--cli-docker", default=None, help="Docker command prefix for the CLI runner")
    parser.add_argument("--client-ogg-home", default=None, help="GoldenGate client home used for adminclient/logdump")
    parser.add_argument("--adminclient-path", default=None, help="Explicit adminclient path")
    parser.add_argument("--logdump-path", default=None, help="Explicit logdump path")
    parser.add_argument("--admin-client-url", default=None, help="Admin Client connect URL; defaults to admin_url without /services/v2")
    parser.add_argument("--download-dir", default=None, help="Client-side directory for downloaded trail sequences")
    parser.add_argument("--download-client-ogg-home", default=None, help="Client-side OGG home for analyzing downloaded trails with local logdump")
    parser.add_argument("--download-logdump-path", default=None, help="Explicit client-side logdump path for downloaded trail analysis")
    parser.add_argument("--cli-trail-dir", action="append", help="Known trail directory visible to the CLI runner; can be repeated")
    parser.add_argument("--cli-trail-search-root", action="append", help="Root path to search when trail directory is unknown; can be repeated")



def add_download_trail_args(parser):
    parser.add_argument("--trail", default=None, help="Already downloaded local trail file to open with local logdump")
    parser.add_argument("--trail-name", default=None, help="Trail name/prefix, for example c1")
    parser.add_argument("--sequence", "--seq", dest="sequence", default=None, help="Trail sequence, for example 6186")
    parser.add_argument("--trail-path", "--path", dest="trail_path", default=None, help="Optional REST trail path query parameter")
    parser.add_argument("--output", "--file", dest="output", default=None, help="Client-side output file path")
    parser.add_argument("--download-dir", default=None, help="Client-side download directory")
    parser.add_argument("--no-download-param", action="store_true", help="Do not add download=true query parameter; keep only Accept: application/binary")
    parser.add_argument("--insecure", action="store_true")
    parser.add_argument("--timeout", type=int, default=120)
    parser.add_argument("--no-auth", action="store_true")

def build_parser():
    parser = argparse.ArgumentParser(description="No-web GoldenGate field kit")
    parser.add_argument("--config", default=None, help="JSON config path; default OGG_FK_CONFIG, ./my-ogg.json, /u01/oracle/msa/util/my-ogg.json, or built-in sample")
    parser.add_argument("--version", action="version", version=VERSION)
    add_common_target_args(parser)
    sub = parser.add_subparsers(dest="command")

    p = sub.add_parser("init-config", help="Write sample config JSON")
    p.add_argument("--output", default=DEFAULT_CONFIG_NAME)
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
    p.add_argument("--connect", action="store_true", help="Auto-send connect URL as USER ! from target config, then hand over to interactive Admin Client")
    p.add_argument("--connect-url", default=None, help="Admin Client connect URL override; defaults to target admin_client_url or admin_url without /services/v2")
    p.add_argument("--connect-user", default=None, help="Admin Client connect user override")
    p.add_argument("--timeout", type=int, default=60)

    p = sub.add_parser("admin-run", help="Run adminclient commands through a local PTY")
    p.add_argument("--cmd", action="append", help="Admin Client command; can be repeated")
    p.add_argument("--connect-url", default=None, help="Prepend 'connect URL as USER !' and prompt securely for password")
    p.add_argument("--connect-user", default=None)
    p.add_argument("--timeout", type=int, default=120)
    p.add_argument("--html", default=None)
    p.add_argument("--no-password", action="store_true")

    p = sub.add_parser("trails-list", help="List trail files locally/through SSH, or OCI REST trail metadata for managed deployments")
    p.add_argument("--limit", type=int, default=50)
    p.add_argument("--json", action="store_true")
    p.add_argument("--insecure", action="store_true", help="Allow self-signed HTTPS certificates for REST-only targets")
    p.add_argument("--timeout", type=int, default=20)
    p.add_argument("--no-auth", action="store_true")
    p.add_argument("--files-per-trail", type=int, default=5, help="Show this many resolved full path trail files per REST trail when --resolve-files is used")
    p.add_argument("--resolve-files", dest="no_resolve_files", action="store_false", help="Advanced: auto-discover full path trail files visible to the CLI runner")
    p.add_argument("--no-resolve-files", dest="no_resolve_files", action="store_true", help="Do not auto-discover full path trail files visible to the CLI runner")
    p.set_defaults(no_resolve_files=True)

    p = sub.add_parser("trail-download", help="Download one trail sequence through Admin Service REST to the client filesystem")
    add_download_trail_args(p)

    p = sub.add_parser("download-logdump-shell", help="Download a trail sequence through REST, then open it with client-local logdump")
    add_download_trail_args(p)

    p = sub.add_parser("download-logdump-run", help="Download a trail sequence through REST, then run client-local logdump commands")
    add_download_trail_args(p)
    p.add_argument("--cmd", action="append", help="Logdump command; can be repeated")
    p.add_argument("--html", default=None)

    p = sub.add_parser("logdump-shell", help="Open interactive logdump; no web server")
    p.add_argument("--trail", default=None, help="Trail path or filename to open before handing over to logdump")
    p.add_argument("--trail-name", default=None, help="Trail name/prefix, for example c1")
    p.add_argument("--sequence", "--seq", dest="sequence", default=None, help="Trail sequence, for example 6186")
    p.add_argument("--timeout", type=int, default=60)

    p = sub.add_parser("logdump-run", help="Run logdump commands through a local PTY")
    p.add_argument("--trail", default=None, help="Trail path or filename to open")
    p.add_argument("--trail-name", default=None, help="Trail name/prefix, for example c1")
    p.add_argument("--sequence", "--seq", dest="sequence", default=None, help="Trail sequence, for example 6186")
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
    if cmd == "trail-download":
        return command_trail_download(args, config)
    if cmd == "download-logdump-shell":
        return command_download_logdump_shell(args, config)
    if cmd == "download-logdump-run":
        return command_download_logdump_run(args, config)
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
