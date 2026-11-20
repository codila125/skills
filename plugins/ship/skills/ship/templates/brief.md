---
status: draft
blocking: 0
open-questions: 0
---

# Brief: `<slug>`

## Request

<the user's request, verbatim>

## Outcome

<who uses it, and what they can do afterwards that they cannot do now>

## Acceptance criteria

| ID   | Criterion (observable) |
|------|------------------------|
| AC-1 | Given … When … Then … |

## Out of scope

- <explicitly not this change>

## Constraints

- Platforms: <…>
- Gates: <the repo's own names and commands — `<name>` `<command>`, repeated; not a fixed set>
- Absent gates: <a gate the repo does not have, recorded as `none`: …>
- Protected: <files, config, or dependencies that need permission to touch>

## Delivery grants

Tick what is pre-approved; delivery stops at the last ticked step.

- [ ] local branch only
- [ ] push branch
- [ ] open a PR or MR
- [ ] merge
- [ ] publish a build or release
- [ ] deploy

## Security scan

`<off|low|medium|high>` — <why this tier for this diff: blast radius, cost>. Tiers
in `references/security-scan.md`, which scans the branch's diff only. Unset → `off`.

## Worker settings

| Role | Kind | Model | Effort | Why |
|------|------|-------|--------|-----|
| …    | …    | …     | …      | …   |

Resolved at preflight from the local crew roster. A resumed run inherits this
table, not the roster it came from.

Worker permission mode: `<mode>`

## Assumed

- <question still open after intake round 3> → <the answer assumed> — <why>
