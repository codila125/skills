# Security scan

A change-scoped hunt for vulnerabilities on the branch's diff, run beside the
two reviewers when `brief.md` sets **Security scan** above `off`. Researchers
propose; a **panel** of verifiers tries to refute each proposal; only survivors
reach `security.md`. A short report the user can trust beats a long one they
must re-check.

## Target

The diff `git diff <merge-base>...<integration tip>`, committed work only. A flaw
is in scope when the change takes part in it: it adds or moves the source, the
sink, a guard, or a new route between them. A flaw whose source, sink, guards, and
routes are all unchanged by the diff is **pre-existing**: a NOTE, never BLOCKING.

## Tiers

| Tier | Before research | Researchers (prompts in `ROLES.md`) | Panel per candidate | Survives when | Agents, for *c* candidates |
|------|-----------------|-------------|---------------------|---------------|-----------|
| `low` | — | 1, every category | 1 verifier, all three lenses | it votes TRUE | 1 + *c* |
| `medium` | — | 2: **input** and **access** (secrets and logic split between them) | 3 verifiers, one lens each | 2 of 3 vote TRUE | 2 + 3*c* |
| `high` | a researcher writes `evidence/threat-model.md`: entry points, trust boundaries, assets the change touches | 4: **input**, **access**, **secrets**, **logic** | 3 verifiers, one lens each | 2 of 3 vote TRUE | 5 + 3*c* |

`low` is triage: one vote confirms, so a survivor is a lead to read, not a proven
finding, and `security.md` says so. Recommend the tier at intake from blast radius —
auth, payments, crypto, secrets, uploads, or an unauthenticated endpoint → `medium`;
docs, copy, or styling only → `off` — and record the reason. The user decides.

Categories, for splitting the work:

- **input**: injection (SQL, shell, template), XSS, path traversal, SSRF, unsafe deserialization, unbounded input.
- **access**: missing authentication or authorization, IDOR, privilege escalation, session and token handling.
- **secrets**: committed credentials (fixtures count), secrets in logs or errors, weak crypto, new dependencies.
- **logic**: races, state that can be skipped, trust placed in client-side checks.

## Severity and confidence

Rate from the code: who can reach it, and the worst realistic harm.

- **CRITICAL**: severe harm, nothing in the attacker's way (remote, unauthenticated, no victim).
- **HIGH**: severe harm behind one real hurdle (privileges, a victim's action, a non-default setting).
- **MEDIUM**: bounded harm, or severe harm behind several hurdles. Information disclosure sits here.
- **LOW**: limited harm and demanding access.

Between two tiers, take the lower one. Confidence is a separate field: HIGH only
when every voter voted TRUE, MEDIUM at two of three, LOW for a single voter. The
panel can lower a severity but never raise it.

## Run it

1. At `high`, the threat-model researcher goes first, so the researchers read its map.
2. Dispatch the tier's researchers in parallel, read-only, one per category, each writing `evidence/security-<category>.md`.
3. Deduplicate by sink `file:line`, enclosing symbol, and CWE, keeping the highest severity. Cap the panel at twelve candidates; the rest stay in their evidence file and are listed under **Unverified** with the reason, never dropped silently.
4. Dispatch the panel, one verifier per candidate × lens. Each writes `evidence/security-vote-<candidate>-<lens>.md`: the file is the vote, and a reply with no file does not count.
5. Count the votes from the files; never from memory of a reply.
6. Write `security.md` from `templates/security.md`. CRITICAL and HIGH survivors go under BLOCKING, MEDIUM and LOW under NOTE, pre-existing flaws under Pre-existing, refuted candidates under Refuted with their decisive `file:line`, and capped ones under Unverified. Fill **Coverage**: the range, the files read, and any changed file set aside (generated, vendored, a lockfile) with the reason, so a clean result reads as covered-and-clean rather than unexamined.
7. As **lead judge**, accept or reject each BLOCKING item exactly as you do for review findings, one line of why in `log.md`. Accepted items become fix slices that write a failing test first (`tdd.md`); a fix that only blocks the reported input is not a fix.
8. On a fix round, re-scan the fix commits at `low` and pass the accepted findings in as candidates: each must fall now because its path is closed, and the fix must add nothing new at MEDIUM or above. Append a round.

Done when: every candidate has a verdict in `security.md` and its frontmatter counts are true.
