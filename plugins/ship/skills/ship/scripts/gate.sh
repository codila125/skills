#!/usr/bin/env bash
# Run a repo's gate commands one at a time, recording each exit code in a log.
#
#   gate.sh <label> <log> "<command>" ["<command>"...]
#
# The log ends with `GATE_DONE <label> = <status>`, the only line the
# orchestrator reads. Each failing command keeps its own `GATE_EXIT` line so a
# fix prompt can name the command that failed.
set -uo pipefail

label="${1:?usage: gate.sh <label> <log> \"<command>\"...}"
log="${2:?usage: gate.sh <label> <log> \"<command>\"...}"
shift 2
[ "$#" -gt 0 ] || { echo "gate.sh needs at least one command" >&2; exit 2; }

mkdir -p "$(dirname "$log")"
: > "$log"
status=0
for command in "$@"; do
  printf '=== %s\n' "$command" >> "$log"
  bash -c "$command" >> "$log" 2>&1
  code=$?
  printf 'GATE_EXIT %s = %s\n' "$command" "$code" >> "$log"
  [ "$code" -ne 0 ] && status="$code"
done

printf 'GATE_DONE %s = %s\n' "$label" "$status"
exit "$status"
