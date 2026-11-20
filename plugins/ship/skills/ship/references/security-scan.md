# Security scan

A change-scoped hunt for vulnerabilities on the integration branch, run beside
the two reviewers when `brief.md` sets **Security scan** above `off`. Researchers
propose; a **panel** of verifiers tries to refute each proposal; only survivors
reach `security.md`. A short report the user can trust beats a long one they must
re-check.

## Target

The diff `git diff <merge-base>...<integration tip>`, committed work only. A flaw
is in scope when the change takes part in it: it adds or moves the source, the
sink, a guard, or a new route between them. A flaw that reads the same before
the change is **pre-existing**: it is listed as a NOTE, never BLOCKING.

## Tiers

| Tier | Before research | Researchers (prompt in `ROLES.md`) | Panel per candidate | Survives when | Agents, for *c* candidates |
|------|-----------------|-------------|---------------------|---------------|-----------|
| `low` | — | 1, every category | 1 verifier, all three lenses | it votes TRUE | 1 + *c* |
| `medium` | — | 2: **input** and **access** (secrets and logic split between them) | 3 verifiers, one lens each | 2 of 3 vote TRUE | 2 + 3*c* |
| `high` | a researcher writes `evidence/threat-model.md`: entry points, trust boundaries, assets the change touches | 4: **input**, **access**, **secrets**, **logic** | 3 verifiers, one lens each | 2 of 3 vote TRUE | 5 + 3*c* |

Categories, for splitting the work:

- **input**: injection (SQL, shell, template), XSS, path traversal, SSRF, unsafe deserialization, unbounded input.
- **access**: missing authentication or authorization, IDOR, privilege escalation, session and token handling.
- **secrets**: committed credentials (fixtures count), secrets in logs or errors, weak crypto, new dependencies.
- **logic**: races, state that can be skipped, trust placed in client-side checks.

## Severity

Rate from the code: who can reach it, and the worst realistic harm.

- **CRITICAL**: severe harm, nothing in the attacker's way (remote, unauthenticated, no victim).
- **HIGH**: severe harm behind one real hurdle (privileges, a victim's action, a non-default setting).
- **MEDIUM**: bounded harm, or severe harm behind several hurdles. Information disclosure sits here.
- **LOW**: limited harm and demanding access.

Between two tiers, take the lower one. Confidence is a separate field from severity.

## Run it

1. Dispatch the tier's researchers in parallel, read-only, each writing `evidence/security-<category>.md`.
2. Deduplicate candidates by sink `file:line`, keeping the highest reported severity.
3. Dispatch the panel for each candidate. Each verifier sees one candidate and one lens.
4. Count the votes yourself. A survivor takes the **lowest** severity its TRUE voters gave. The panel can lower a severity but never raise it.
5. Write `security.md` from `templates/security.md`. CRITICAL and HIGH survivors go under BLOCKING, MEDIUM and LOW under NOTE, pre-existing flaws under Pre-existing. Record every candidate the panel refuted in the Refuted table with its decisive `file:line`.
6. As **lead judge**, accept or reject each BLOCKING item exactly as you do for review findings. Accepted items become fix slices.

On a fix round, re-scan only the fix commits at `low`, appending a round.

Done when: every candidate has a verdict in `security.md` and its frontmatter counts are true.
