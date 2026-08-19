#!/usr/bin/env python3
import argparse
import json
import pathlib
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--godot", required=True)
parser.add_argument("--project", required=True)
parser.add_argument("--script", required=True)
parser.add_argument("--repeat", type=int, default=100)
parser.add_argument("--output", required=True)
args = parser.parse_args()

command = [args.godot, "--headless", "--path", args.project, "--script", args.script, "--", "--repeat", str(args.repeat)]
completed = subprocess.run(command, cwd=args.project, capture_output=True)

def decode(data: bytes) -> str:
    if data.startswith((b"\xff\xfe", b"\xfe\xff")) or data.count(b"\x00") > len(data) // 4:
        return data.decode("utf-16", errors="replace")
    for encoding in ("utf-8", "gb18030", "cp1252"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            pass
    return data.decode("utf-8", errors="replace")

stdout = decode(completed.stdout)
stderr = decode(completed.stderr)
print(stdout, end="")
print(stderr, end="", file=sys.stderr)
if completed.returncode != 0:
    raise SystemExit(completed.returncode)

payload = None
# Godot's Windows console build can route script print output to stderr.
# Parse both streams while keeping them separately visible in CI logs.
for line in reversed((stdout + "\n" + stderr).splitlines()):
    try:
        candidate = json.loads(line)
    except json.JSONDecodeError:
        continue
    if isinstance(candidate, dict) and "status" in candidate:
        payload = candidate
        break
if payload is None:
    raise SystemExit("Godot replay command produced no JSON status payload")
if payload.get("status") not in ("passed", "success"):
    raise SystemExit(f"Replay payload failed: {payload.get('status')}")

output = pathlib.Path(args.output)
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")), encoding="utf-8")
if not output.is_file() or output.stat().st_size == 0:
    raise SystemExit(f"Failed to write replay output: {output}")
print(f"CI_REPLAY_WRITTEN {output.resolve()} {output.stat().st_size}")
