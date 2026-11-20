---
status: draft
blocking: 0
open-questions: 0
---

# Security scan — tier `<low|medium|high>`

Diff: `<merge-base>..<integration tip>`, <n> files. Candidates: <n>; survived: <n>.

## Round 1

### BLOCKING

- `path:line` — <CRITICAL|HIGH> <CWE-id> <title> — <attacker, source → sink, the gain> — <the fix expected> — votes <t>/<n> — breaks <AC-id or "none">

### NOTE

- `path:line` — <MEDIUM|LOW> <CWE-id> <title> — <one line> — votes <t>/<n>

## Pre-existing

- `path:line` — <title> — the change does not take part; out of this run's scope

## Refuted

| Candidate | Decisive `file:line` | Why it fell |
|-----------|----------------------|-------------|
| …         | …                    | …           |

## Defaults

- <default chosen> — <why>
