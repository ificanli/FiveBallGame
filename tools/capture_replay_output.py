#!/usr/bin/env python3
import argparse
import json
import pathlib
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--output", required=True)
parser.add_argument("--input")
args = parser.parse_args()

if args.input:
    raw = pathlib.Path(args.input).read_bytes()
    if raw.startswith((b"\xff\xfe", b"\xfe\xff")) or raw.count(b"\x00") > len(raw) // 4:
        text = raw.decode("utf-16", errors="replace")
    else:
        text = raw.decode("utf-8", errors="replace")
    lines = text.splitlines()
else:
    lines = (line.decode("utf-8", errors="replace").rstrip("\r\n") for line in sys.stdin.buffer)
payload = None
for line in lines:
    print(line)
    try:
        candidate = json.loads(line)
    except json.JSONDecodeError:
        continue
    if isinstance(candidate, dict) and "status" in candidate:
        payload = candidate
if payload is None:
    raise SystemExit("Godot replay stream produced no JSON status payload")
if payload.get("status") not in ("passed", "success"):
    raise SystemExit(f"Replay payload failed: {payload.get('status')}")
output = pathlib.Path(args.output)
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")), encoding="utf-8")
print(f"CI_REPLAY_WRITTEN {output.resolve()} {output.stat().st_size}")
