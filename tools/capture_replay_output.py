#!/usr/bin/env python3
import argparse
import json
import pathlib
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--output", required=True)
args = parser.parse_args()

payload = None
for raw_line in sys.stdin.buffer:
    line = raw_line.decode("utf-8", errors="replace").rstrip("\r\n")
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
