# ship

Takes one request from idea to delivered software. An orchestrator agent runs a crew
of worker agents through the request. You talk to it twice: at **intake**, when you
agree on the brief, and at **handoff**, when you review what it delivered. The work in
between runs without you.

| Skill | Crew | Use it when |
|---|---|---|
| [`ship`](skills/ship/SKILL.md) | intake → research → spec + test plan → plan → build → cross and primary review → QA → acceptance → delivery | The change is real product work, and someone or something should drive the running software before you accept it. |
| [`ship-mini`](skills/ship-mini/SKILL.md) | architect → builders → two reviewers → acceptance → delivery | The change is smaller. Tests and reviews are enough proof. There is no research or QA phase. |

`ship-mini` uses the scripts, references, crew policy, and orchestration recipes in
`../ship`, so the two skills ship together in this plugin.

## How a run works

- **Run folder.** Each run lives in `.ship/<slug>/` at the root of an isolated git
  worktree. The folder holds `state.json`, `brief.md`, `spec.md`, `plan.md`, review and
  QA reports, `acceptance.md`, and `handoff.md`. `state.json` is the resume point.
- **Acceptance criteria.** Criteria are numbered `AC-1` to `AC-n` in the brief, and
  every later file refers to them. [`scripts/check.sh`](skills/ship/scripts/check.sh)
  fails a gate when a criterion is missing from a file, a report has unresolved
  blockers, or a slice changes files outside its scope.
- **Delivery grants.** At intake you choose which outward actions are pre-approved:
  local branch, push, open a PR, merge, release, or deploy. Anything you didn't grant
  stops at handoff. If you don't choose, it stays on a local branch.
- **Security scan.** At intake you pick `off`, `low`, `medium`, or `high`. When it is
  on, read-only researchers hunt the branch's diff — never the whole tree — for
  vulnerabilities during review, and a panel of verifiers then tries to refute each
  finding. Survivors rated CRITICAL or HIGH block the review gate, and `handoff.md`
  reports what survived, what was refuted, and what was left alone. The scan writes
  nothing outside the run folder. If you don't choose, the scan is off.
- **Self-contained.** The procedures for grilling, TDD, code review, bug diagnosis,
  prototyping, domain modelling, security scanning, and manual-step wizards are in
  [`skills/ship/references/`](skills/ship/references/README.md). The skill doesn't
  depend on any other skill being installed.

## Requirements

- macOS, Linux, or WSL, with git and bash 3.2+ (`grep`, `awk`).
- A way to run worker agents, chosen automatically in this order:
  1. Herdr panes, when `HERDR_ENV=1`
  2. the agent's subagent tool
  3. sequential mode in a single agent
- Optional: a **crew roster** that lists the model families, tiers, and effort levels
  you have. Ship reads it from `$SHIP_CREW`, then `~/.agents/crew.local.md`, then
  `~/.config/ship/crew.local.md`. Without a roster, every worker runs on the
  orchestrator's own model family. [`CREW.md`](skills/ship/CREW.md) explains the format
  and the policy.

## Usage

Both skills set `disable-model-invocation`, so the agent never starts them by itself.
You have to call them:

| Agent | Command |
|---|---|
| Claude Code (plugin) | `/ship:ship add rate limiting to the public API` |
| Claude Code (symlinked skill) | `/ship add rate limiting to the public API` |
| Codex | `$ship add rate limiting to the public API` |

Use `ship-mini` the same way.

## Files

```
skills/ship/
  SKILL.md            orchestrator instructions, phase by phase
  ORCHESTRATION.md    crew modes, Herdr recipes, worktrees, gates, resume, abort
  CREW.md             model/tier/effort policy
  ROLES.md            role prompts for each worker
  references/         procedures the phases follow
  scripts/            check.sh, gate.sh, guard-git.sh
  templates/          skeletons for every run file
skills/ship-mini/
  SKILL.md            the lighter orchestrator
  ROLES.md            its smaller role table
  templates/          spec, acceptance, handoff, state.json that differ from ship's
```
