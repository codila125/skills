---
name: ship
description: Take one request from idea to delivered software through a Herdr-orchestrated crew of agents (intake, research, spec, plan, build, review, QA, acceptance, delivery) with one human touchpoint at the start and one at the end.
disable-model-invocation: true
compatibility: macOS, Linux, or WSL, with an agent runtime that supports Agent Skills, git, and bash 3.2+ with grep and awk. Worker agents need Herdr (HERDR_ENV=1), a subagent tool, or sequential mode. Provide a local crew roster for the machines and plans you actually have (path in CREW.md); without one the run stays on the orchestrator's family. No other skill is required — every procedure is a file in references/.
---

You are the **orchestrator**. The user hands you one request; you return a **delivered** result: built, reviewed, QA'd, accepted against its criteria, and handed over through the delivery channel the user chose. The user speaks twice: at **intake**, and at **handoff**. Between those, the work runs **hands-off**.

You coordinate; workers do. Each phase runs in a **worker** agent given a role prompt from [`ROLES.md`](ROLES.md), on the kind, model, and effort [`CREW.md`](CREW.md) assigns its role. You hold the **run folder**, read worker output from files, enforce **gates**, and route failures back.

[`ORCHESTRATION.md`](ORCHESTRATION.md) holds the crew modes, the Herdr recipes (worktrees, panes, spawning, gate runs, merging), the context budget, the git guard, resume, approvals, and abort. Read it before step 2. The procedures each phase names live in [`references/`](references/README.md) — read one when its phase starts, and nothing else needs to be installed.

## The run folder

Every run lives in `.ship/<slug>/` at the repo root of the worktree (add `.ship/` to `.git/info/exclude`, never to `.gitignore`). It is the single source of truth and the resume point.

| File               | Written by   | Holds                                                          |
|--------------------|--------------|----------------------------------------------------------------|
| `state.json`       | orchestrator | machine state: phase, slice, rounds, reds, gates — the resume point |
| `brief.md`         | orchestrator | the request, acceptance criteria, constraints, delivery grants |
| `research.md`      | researcher   | codebase map, prior art, versioned API facts, risks            |
| `spec.md`          | architect    | behaviour, edge cases, interfaces, data, non-functionals, ADRs |
| `test-plan.md`     | qa           | one check per acceptance criterion, written before code exists |
| `plan.md`          | architect    | task graph: slices, blocking edges, owned files                 |
| `review-cross.md`  | cross reviewer | findings per round, each marked BLOCKING or NOTE             |
| `review-primary.md`| primary reviewer | findings per round, each marked BLOCKING or NOTE           |
| `security.md`      | orchestrator | security scan survivors, pre-existing flaws, refuted candidates (only when the scan is on) |
| `qa-report.md`     | qa           | evidence per test-plan check, bugs found                       |
| `acceptance.md`    | orchestrator | each acceptance criterion → evidence → PASS/FAIL               |
| `handoff.md`       | orchestrator | what shipped, how to use it, what was decided, what remains    |
| `log.md`           | orchestrator | append-only narrative: phases, defaults chosen, loop-backs     |

`evidence/` beside them holds gate logs, captures, and other proof.

**Two rules make the run machine-checkable; every file obeys them:**

1. **IDs.** Acceptance criteria are `AC-1` … `AC-n` in `brief.md`. Every later file references those IDs — a criterion no file names is a gap, and `check.sh` finds it.
2. **Headers.** Every run file except `state.json` starts with the same three frontmatter fields — `status`, `blocking`, `open-questions` — exactly as its skeleton in `templates/` shows. Start each file from that skeleton; `state.json` is the resume point, so update it on every transition, and `log.md` records the story. When your own context is summarized, rebuild from `state.json`, `brief.md`, and `plan.md` — never from memory.

## 0. Preflight

1. Pick the crew mode: `herdr` when `test "${HERDR_ENV:-}" = 1` passes, else `subagents`, else `sequential` ([`ORCHESTRATION.md`](ORCHESTRATION.md)).
2. Read the repo's agent instructions (`AGENTS.md`, `CLAUDE.md`, or equivalent).
3. Find the repo's own verification commands — whatever its build tool calls them (a JS repo usually has typecheck, lint, test, build; Go has vet and test; Rust has clippy and fmt) — from its manifest (`package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`) or its docs, and its **verification entry point** if it has one: a `verify-*` skill, `scripts/verify.sh`, or a doctor/launch command that brings the app up and drives it. An entry point beats manifest parsing — it encodes how to launch and prove, which no manifest carries. A gate the repo does not have is recorded as `none`, never invented. Record its
   own security tooling the same way — secret scanning, dependency audit
   (`npm audit`, `govulncheck`, `pip-audit`), SAST — because the intake scan
   complements those checks and never replaces them.
4. Build the **crew** from [`CREW.md`](CREW.md): read the local roster it names, run each family's detect command, and let a family that fails detection sit out this run. Resolve every role's kind, model, and effort — including the substitutions a family's models force — and write the resolved table into `brief.md`.
5. Choose the **slug** (kebab-case, from the request) and the base ref. Resume instead of starting fresh if the repo root's `.ship/*/state.json` holds a `running` or `aborted` run whose `request` matches. Otherwise create `.ship/<slug>/` at the repo root (`git rev-parse --show-toplevel`) with its `evidence/` folder, and copy `templates/state.json` in as its starting state.

Done when: mode chosen, gate commands known, every role has a kind, model, and effort, and a fresh or resumed run folder is chosen.

## 1. Intake (the user's first touchpoint)

Run the interview in [`references/grilling.md`](references/grilling.md) against the request, with one difference: stop after **at most three rounds**, so the user answers once and walks away. Put every branch without prerequisites into round 1; later rounds only follow up on what earlier answers opened. Any question still open after round 3 takes your recommended answer, recorded in `brief.md` under **Assumed** so the user reviews it at "go". Cover every branch the later phases need:

- **Outcome**: who uses it, what they can do afterwards that they cannot do now.
- **Acceptance criteria**: numbered `AC-1` … `AC-n`, each observable from outside — a Given/When/Then line is the easy way to test that. These are the contract every later gate checks.
- **Scope and constraints**: what is explicitly out; platforms, performance budget, accessibility level, dependencies allowed, files or config that need permission to touch.
- **Delivery grants**: exactly which outward actions are pre-approved: local branch only / push branch / open a PR or MR / merge / publish build or release / deploy. Anything not granted stops at handoff; if still open after round 3, assume local branch only.
- **Security scan**: `off` / `low` / `medium` / `high`, with each tier's cost in one line from [`references/security-scan.md`](references/security-scan.md). It reads the branch's diff, never the whole tree. Recommend a tier from blast radius — auth, payments, crypto, secrets, uploads, or an unauthenticated endpoint → `medium`; docs, copy, or styling only → `off` — and record the reason. If still open after round 3, assume `off`.
- **Worker settings**: the crew from preflight (role → kind, model, effort, one-line why), and the permission mode workers start in. The user overrides here or not at all.

Write `brief.md` from its template, show it, and get one explicit "go". Corrections at this point edit `brief.md` directly; they do not reopen grilling. That "go" is the durable authorization for everything in the brief.

Done when: `brief.md` has AC IDs, scope, constraints, delivery grants, worker settings, and the user said go.

## 2. Set up the crew

Create the isolated worktree and record `branch`, `base_ref`, `merge_base`, `worktree`, and the pane IDs in `state.json` ([`ORCHESTRATION.md`](ORCHESTRATION.md) has the commands). Move `.ship/<slug>/` into it. All workers run inside the worktree; the user's checkout stays untouched. Create the **gate pane** — a plain shell in the worktree that never hosts an agent. In a mode without panes, it is simply the directory you run gates from.

Start each worker when its phase starts, wait for its reply, and close it when the phase ends.

**Context discipline**: read only the latest round of `review-*.md` and `qa-report.md`, and only its BLOCKING items and open bugs. The frontmatter's `blocking` and `open-questions` counts tell you what is in a file before you open it.

Done when: worktree exists, `.ship/<slug>/` holds `brief.md`, `log.md`, and `state.json`, and the gate pane is ready.

## 3. Research

Spawn **researcher**, which writes `research.md`.

Gate: `<skill>/scripts/check.sh ac <run> research.md` is green, and every external API named in it cites its versioned doc.

## 4. Spec and test plan, in parallel

Spawn **architect** (writes `spec.md`) and **qa** (writes `test-plan.md`) at the same time, both from `brief.md` + `research.md`. QA plans from the brief, not the spec, so the test plan is an independent reading of what "done" means.

Then cross-check them yourself: anything the spec covers that the test plan misses, or the reverse, goes back to its owner with the gap named. Decisions with lasting consequences become ADRs in the repo's ADR folder, if it has one.

Gate: `check.sh ac <run> spec.md test-plan.md` and `check.sh clean <run> spec.md test-plan.md` are green.

## 5. Plan

Architect turns the spec into `plan.md`: **tracer-bullet** slices, each declaring its **blocked by** edges and the files it exclusively owns. The edges make the plan a task graph, so the **frontier** — every slice whose blockers are done — is what builds in parallel. A design question the spec could not settle on paper runs as a [prototype](references/prototype.md) first, and only the decision it produced folds into the plan.

Gate: `check.sh ac <run> plan.md` is green, every slice fits one worker turn with its files listed, every slice names a domain skill when one applies and a crew override when it deviates, and no two slices that could run in parallel list the same file. A security fix slice names its `S<n>` and the regression test that goes red on the parent commit.

## 6. Build

Build the **frontier**, up to the crew cap, **one worktree per slice** on its own branch off the integration branch — two builders never share a git index ([`ORCHESTRATION.md`](ORCHESTRATION.md)). Feed each builder **one slice per prompt**. For each finished slice:

1. Builder commits in its slice worktree, test-first ([`references/tdd.md`](references/tdd.md)).
2. Scope: `git diff --name-only <merge-base>...<slice tip>` into a file, then `check.sh scope <run> <slice> <file>`. Files outside the slice's list go back as a fix, not to review.
3. You re-run every gate command yourself, in the gate pane, through `<skill>/scripts/gate.sh`. Read only the `GATE_DONE` line; a worker's "tests pass" is a claim, your gate run is the evidence.
4. Merge the slice into the integration branch, one merge at a time, and re-gate the merge commit.
5. Red: rule out **state before code** — is the slice based on the current integration tip, is a merge half-applied, does `state.json` disagree with git? A stale worktree is the most common false red. Then send the builder a fix prompt pointing at the gate log by name; it reads the failures, you do not. Each red applies the builder-red rule in [`CREW.md`](CREW.md); three reds on one slice is a blocker.

Mark each slice done in `plan.md` and `state.json` before starting anything else, since every merge moves the frontier.

Done when: every slice merged, and the gates are green on the integration branch tip.

## 7. Review

Spawn **two reviewers in parallel** — `reviewer-primary` and `reviewer-cross` — writing `review-primary.md` and `review-cross.md`. Each takes a different **axis** and a different **lens**, because one review run twice buys one review:

| Reviewer | Axis ([`references/code-review.md`](references/code-review.md)) | Lens |
|----------|----------------------|------|
| primary | Spec: does the work deliver `spec.md` | Skeptic — what input, state, or sequence breaks it |
| cross | Standards: does it follow the repo's conventions | Architect + Minimalist — boundary leaks, coupling, what can be deleted |

Both state the **Intent** first, judge whether the work achieves it (not whether the intent is right), fill the scope-check table, and return a verdict: PASS / CONTESTED / REJECT. Plus the security pass: input handling, secrets, permissions, dependencies added.

When the brief's **Security scan** is above `off`, run [`references/security-scan.md`](references/security-scan.md) at that tier, in parallel with the reviewers. It writes `security.md` and the votes under `evidence/`; record the tier and round in `state.json.security`. Keep at most four agent panes live, the reviewers' two included ([`ORCHESTRATION.md`](ORCHESTRATION.md)).

Then act as **lead judge**, not a postbox: for each blocking finding, accept or reject it with one line of why, recorded in `log.md`. Send rejections back to the reviewer with the reason so it is not raised again. Only accepted findings become fix slices.

Loop: fix slices → build gates → both reviewers re-review only the fix diff, with the same lenses, and the scan re-runs on it at `low`. At most three rounds; then blocker.

Gate: `check.sh clean <run> review-primary.md review-cross.md` is green, plus `security.md` and `check.sh security <run>` when the scan is on. The second check re-derives each survivor's `votes <t>/<n>` from `evidence/`, so the panel's work is checked rather than believed.

## 8. QA

QA executes `test-plan.md` against the **running software**, not the source, using the repo's verification entry point when it has one and its run command otherwise. Evidence goes under `.ship/<slug>/evidence/`, and `qa-report.md` records one PASS/FAIL row per check.

Bugs route back to the builder as fix slices, through the build gates and a pass on the fix by both reviewers, then QA re-tests only the affected checks plus the regression suite. A security fix is proven by its regression test and the `low` re-scan, not by QA; QA re-tests only the behaviour the fix touched. At most three QA rounds; then blocker.

Gate: `check.sh qa <run>` is green, and no open bug reaches the severity bar in the brief.

## 9. Acceptance

You, not a worker, fill `acceptance.md`: each AC → the evidence that proves it → PASS/FAIL. Any FAIL routes back to the phase that owns it (spec gap → 4, bug → 6). A security survivor that names an AC keeps that AC from PASSing until its fix lands and the re-scan clears it.

Gate: `check.sh acceptance <run>` is green.

## 10. Delivery

Do exactly what the brief's delivery grants allow, in this order, stopping at the last granted step:

1. Docs: README/changelog/in-app copy the change needs.
2. Final gate run on a clean state.
3. Push the branch.
4. Open the PR or MR with this body, evidence pulled from `evidence/` and `acceptance.md`:

```markdown
## Summary

<the smallest view that makes the change obvious: a tree, a call flow, a
before/after, or a few lines of pseudocode for the logic>

## Evidence

- **Before:** <screenshot, output, failing run>
  **After:** <screenshot, output, passing run>

## Merge Danger

**Door:** <one-way, when reverting is expensive or impossible | two-way>

**Blast Radius:** <one word>
```
When the scan ran, the PR body names the fix and its regression test, never the exploit path, a payload, or a credential: that detail stays in `handoff.md`, which does not leave the run folder.

5. Merge / publish build / publish release / deploy, using the repo's own scripts.
6. Post-delivery smoke check: the delivered artifact works (the build installs, the deploy responds, the published channel serves it).

Then write `handoff.md` from its template: what shipped and where, how to try it, decisions made on the user's behalf (from `log.md`), what is out of scope or deferred, the scan's survivors and refutations when it ran, and the next action that needs the user. Reference `spec.md`, `plan.md`, and the commits by path or sha rather than restating them, and leave the worktree in place.

## 11. Handoff (the user's second touchpoint)

Report in a few lines: outcome, link to the PR/MR or build, acceptance table, defaults you chose, and what is waiting on them. Name the next step the user should take, and if it is a manual procedure, say that [`references/wizard.md`](references/wizard.md) turns it into one script.

Finish with a **retro**: every loop-back in this run is a candidate, and the categories are ordered by what fixes them most cheaply.

1. **An automated check** that would have caught it — the default. A security survivor the panel caught at review is a loop-back too: name the scanner, lint rule, or audit that would have caught it before review. A gate command, lint rule, or pre-commit hook beats any sentence, and a repo gate that exists but runs nowhere is the finding. A QA run that had to improvise launch or drive steps is the same finding one level up: the repo needs a verification entry point (launch, doctor, drive, prove) that QA and builders load instead of rediscovering. Name it concretely.
2. **A navigation pointer** — the agent spent time finding something a one-line pointer would have named.
3. **A coding standard** the reviewer enforces — judgement calls only, the ones no check could ever catch.
4. **Tool economy and no-ops** — an expensive call that could be cheaper, an instruction that changes nothing.

A note earns its place only if the agent would reliably get it wrong without it, and it is frequent or high-impact. Route each finding to the file that owns it — the repo's agent-instructions file, its standards file, or this skill — and apply it only with the user's ok.

## Escalation

A **blocker** is anything the brief, the repo, and a reasonable default cannot answer: an ungranted outward action, a config file the constraints protect, a loop limit hit, an acceptance criterion that turns out impossible or contradictory. On a blocker: pause only the affected work, send one batched message (what is blocked, the options, your recommendation), and record the answer in `brief.md` and `state.json.blockers` so it is never asked twice. Everything short of a blocker is a **default**: pick the conventional choice, write it to `state.json.defaults` and `log.md` with one line of why, and keep going.
