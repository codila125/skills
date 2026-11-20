#!/usr/bin/env bash
# Mechanical gates for a ship run. Every check reads run files and reports one
# MISSING line per failure, so a gate is an exit code instead of a judgement.
#
#   check.sh ac         <run> <file>...   every AC-n in brief.md is referenced
#   check.sh clean      <run> <file>...   frontmatter: done, 0 blocking, 0 open
#   check.sh acceptance <run>             every AC has a PASS row
#   check.sh qa         <run>             no FAIL row, no open BLOCKING bug
#   check.sh scope      <run> <slice> <changed-files-list>
#                                         changed files stay inside the slice's
#                                         Files list in plan.md
#   check.sh security   <run>             every candidate in security.md has vote
#                                         files whose TRUE count and total match
#                                         its `votes <t>/<n>`, and every survivor is
#                                         rated in the range its section allows
set -uo pipefail

usage() { echo "usage: check.sh <ac|clean|acceptance|qa|scope|security> <run-folder> [args]" >&2; exit 2; }

kind="${1:-}"
run="${2:-}"
[ -n "$kind" ] && [ -n "$run" ] || usage
[ -d "$run" ] || { echo "check.sh: no run folder: $run" >&2; exit 2; }
[ -f "$run/brief.md" ] || { echo "check.sh: no brief.md in $run" >&2; exit 2; }

failed=0
require() { printf 'MISSING %s\n' "$1"; failed=1; }
acceptance_ids() { grep -oE 'AC-[0-9]+' "$run/brief.md" | sort -u; }

case "$kind" in
  ac)
    shift 2
    [ "$#" -gt 0 ] || usage
    for file in "$@"; do
      if [ ! -f "$run/$file" ]; then require "$file (absent)"; continue; fi
      while read -r id; do
        grep -qE "${id}([^0-9]|\$)" "$run/$file" || require "$id in $file"
      done < <(acceptance_ids)
    done
    ;;
  clean)
    shift 2
    [ "$#" -gt 0 ] || usage
    for file in "$@"; do
      if [ ! -f "$run/$file" ]; then require "$file (absent)"; continue; fi
      grep -qE '^status: *done' "$run/$file" || require "status: done in $file"
      declared=$(awk -F': *' '/^blocking:/{print $2; exit}' "$run/$file")
      bullets=$(awk '/^### BLOCKING/{f=1; next} /^#{2,3} /{f=0} f && /^- /{c++} END{print c+0}' "$run/$file")
      [ "$declared" = "0" ] || require "blocking: 0 in $file (declares $declared)"
      [ "$bullets" = "0" ] || require "no BLOCKING bullet in $file (found $bullets)"
      grep -qE '^open-questions: *0' "$run/$file" || require "open-questions: 0 in $file"
    done
    ;;
  acceptance)
    [ -f "$run/acceptance.md" ] || require "acceptance.md (absent)"
    if [ -f "$run/acceptance.md" ]; then
      while read -r id; do
        grep -qE "\|[[:space:]]*${id}[[:space:]]*\|.*PASS" "$run/acceptance.md" || require "PASS for $id in acceptance.md"
      done < <(acceptance_ids)
    fi
    ;;
  qa)
    [ -f "$run/qa-report.md" ] || require "qa-report.md (absent)"
    if [ -f "$run/qa-report.md" ]; then
      grep -qE '\|[[:space:]]*FAIL[[:space:]]*\|' "$run/qa-report.md" && require "no FAIL row in qa-report.md"
      grep -qE '\|[[:space:]]*`?BLOCKING`?[[:space:]]*\|' "$run/qa-report.md" && require "no open BLOCKING bug in qa-report.md"
    fi
    ;;
  scope)
    shift 2
    slice="${1:-}"
    changed="${2:-}"
    [ -n "$slice" ] && [ -n "$changed" ] || usage
    section=$(awk -v s="$slice" 'match($0, "^## Slice " s "([^0-9]|$)") {on=1; next} /^## / {on=0} on' "$run/plan.md")
    patterns=$(printf '%s\n' "$section" | grep -i 'files' | grep -oE '`[^`]+`' | tr -d '`')
    if [ -z "$patterns" ]; then
      require "Files list for slice $slice in plan.md"
    else
      while read -r file; do
        [ -n "$file" ] || continue
        inside=0
        while read -r pattern; do
          # shellcheck disable=SC2053 # unquoted right side is a glob on purpose
          if [[ "$file" == $pattern || "$file" == $pattern/* ]]; then inside=1; fi
        done <<< "$patterns"
        [ "$inside" -eq 1 ] || require "scope: $file outside slice $slice"
      done < "$changed"
    fi
    ;;
  security)
    [ -f "$run/security.md" ] || require "security.md (absent)"
    if [ -f "$run/security.md" ]; then
      # Every candidate is one `- S<n> —` row: the section sets its severity band,
      # and its `votes <t>/<n>` must match the vote files the panel actually wrote.
      for section in BLOCKING NOTE; do
        while IFS= read -r line; do
          id=$(printf '%s\n' "$line" | awk '{print $2}')
          case "$section" in
            BLOCKING) printf '%s\n' "$line" | grep -qE '— (CRITICAL|HIGH) ' || require "$id rated CRITICAL or HIGH under BLOCKING" ;;
            NOTE)     printf '%s\n' "$line" | grep -qE '— (MEDIUM|LOW) '  || require "$id rated MEDIUM or LOW under NOTE" ;;
          esac
          votes=$(printf '%s\n' "$line" | grep -oE 'votes [0-9]+/[0-9]+' | awk '{print $2}')
          if [ -z "$votes" ]; then require "votes <t>/<n> on $id in security.md"; continue; fi
          want_true=${votes%/*}
          want_all=${votes#*/}
          set -- "$run"/evidence/security-vote-"$id"-*.md
          if [ ! -f "$1" ]; then require "vote files for $id in evidence/"; continue; fi
          have_all=$#
          have_true=0
          for vote in "$@"; do
            head -n 1 "$vote" | grep -qE '^VOTE (TRUE|FALSE|PREDATES)( |$)' || require "VOTE line in ${vote##*/}"
            head -n 1 "$vote" | grep -qE '^VOTE TRUE( |$)' && have_true=$((have_true + 1))
          done
          [ "$have_all" = "$want_all" ] || require "$id votes $votes: $have_all vote file(s) in evidence/"
          [ "$have_true" = "$want_true" ] || require "$id votes $votes: $have_true TRUE vote file(s)"
        done < <(awk -v want="$section" '/^### (BLOCKING|NOTE)/{s=$2; next} /^#{2,3} /{s=""} s==want && /^- S[0-9]+ /{print}' "$run/security.md")
      done
    fi
    ;;
  *) usage ;;
esac

if [ "$failed" -eq 0 ]; then
  printf 'CHECK_OK %s\n' "$kind"
  exit 0
fi
exit 1
