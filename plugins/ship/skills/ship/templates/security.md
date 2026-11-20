---
status: draft
blocking: 0
open-questions: 0
---

# Security scan — tier `<low|medium|high>`

Diff: `<merge-base>..<integration tip>`, <n> files. Candidates: <n>; survived: <n>.

## Coverage

- Read: <the changed files, and the files the data crosses>
- Not read: `path` — <generated | vendored | lockfile | …> — <why this changed file was set aside>

## Round 1

### BLOCKING

- `path:line` — <CRITICAL|HIGH> <CWE-id> <title> — confidence <low|medium|high> — <attacker, source → sink, the gain> — <the fix expected> — votes <t>/<n> — breaks <AC-id or "none">

### NOTE

- `path:line` — <MEDIUM|LOW> <CWE-id> <title> — confidence <low|medium|high> — <one line> — votes <t>/<n>

## Pre-existing

- `path:line` — <title> — the change does not take part; out of this run's scope

## Refuted

| Candidate | Vote | Decisive `file:line` | Why it fell |
|-----------|------|----------------------|-------------|
| `path:line` | FALSE | `path:line`           | …           |

## Unverified

- `path:line` — <title> — over the twelve-candidate cap — <why it was not paneled>

## Defaults

- <default chosen> — <why>
