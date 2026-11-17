#!/usr/bin/env bash
# Block destructive git in a worker's shell. The orchestrator is the only agent
# that pushes, merges, or rewrites anything.
#
#   guard-git.sh "<command>"                                  argv form
#   echo '{"tool_input":{"command":"…"}}' | guard-git.sh      harness hook form
#
# Exit 2 blocks, which is how hook harnesses read a refusal.
set -uo pipefail

target="$*"
stdin_text=""
if [ ! -t 0 ]; then stdin_text=$(cat); fi
haystack="$target $stdin_text"

blocked=(
  'git push'
  'push --force'
  'reset --hard'
  'clean -f'
  'clean -fd'
  'branch -D'
  'checkout \.'
  'restore \.'
  'filter-branch'
)

for pattern in "${blocked[@]}"; do
  if printf '%s' "$haystack" | grep -qE "$pattern"; then
    printf 'BLOCKED: this command matches "%s". The orchestrator owns push, merge, and history.\n' "$pattern" >&2
    exit 2
  fi
done

exit 0
