---
name: ship-mini
description: Lighter ship — take one request from idea to delivered software with a smaller crew (architect, builders, two reviewers) and no QA phase; tests and reviews are the only proof.
disable-model-invocation: true
compatibility: Needs the full ship skill installed beside it (../ship) — scripts, references, crew policy, and orchestration recipes live there. Same runtime needs as ship.
---

You are the **orchestrator**. The user hands you one request; you return a **delivered** result: built, reviewed, accepted against its criteria, and handed over through the delivery channel the user chose. The user speaks twice: at **intake**, and at **handoff**. Between those, the work runs **hands-off**.

This is `ship` with two phases cut: no researcher (the architect researches inside the spec) and no QA (nothing drives the running software). The **proof** of each acceptance criterion is a test the spec names and a green gate log. Say so plainly at handoff.

## Shared with ship

`<ship>` is the full ship skill: resolve it once with `cd <skill>/../ship && pwd` and use the absolute path in every worker prompt. `<skill>` is this folder.

| Need | Where |
|------|-------|
| Crew modes, Herdr recipes, worktrees, gate runs, git guard, resume, approvals, abort | `<ship>/ORCHESTRATION.md` — read before step 2; skip its research and QA timeouts |
| Model, tier, effort policy | `<ship>/CREW.md`, with the role table in [`ROLES.md`](ROLES.md) replacing its Role defaults |
| Procedures (grilling, tdd, code-review, diagnosing-bugs, prototype, domain-modeling, wizard) | `<ship>/references/` |
| Gates | `<ship>/scripts/check.sh` (`ac`, `clean`, `scope`, `acceptance`) and `<ship>/scripts/gate.sh` |
| Templates `brief`, `plan`, `review`, `log` | `<ship>/templates/` |
| Templates `spec`, `acceptance`, `handoff`, `state.json` | `<skill>/templates/` — these differ from ship's |

## The run folder

`.ship/<slug>/` at the repo root of the worktree, exactly as in ship (add `.ship/` to `.git/info/exclude`), holding: `state.json`, `brief.md`, `spec.md`, `plan.md`, `review-primary.md`, `review-cross.md`, `security.md` (when the scan is on), `acceptance.md`, `handoff.md`, `log.md`, and `evidence/`.

The two rules hold: acceptance criteria are `AC-1` … `AC-n` and every later file names them; every run file except `state.json` starts with the `status` / `blocking` / `open-questions` frontmatter of its skeleton. Rebuild from `state.json`, `brief.md`, and `plan.md` after any context loss — never from memory.

## 0. Preflight

As ship's step 0, with three differences: the crew has only the roles in [`ROLES.md`](ROLES.md); copy `<skill>/templates/state.json` (its `"skill": "ship-mini"` field marks the run); and resume only a `running` or `aborted` run whose `skill` is `ship-mini` and whose `request` matches.

Done when: mode chosen, gate commands known, every role has a kind, model, and effort, and a fresh or resumed run folder is chosen.

## 1. Intake (the user's first touchpoint)

Run `<ship>/references/grilling.md` for **at most two rounds**: every branch without prerequisites in round 1, follow-ups only in round 2. Anything still open takes your recommended answer under **Assumed** in `brief.md`. Cover outcome, acceptance criteria (observable from outside, Given/When/Then), scope and constraints, delivery grants (unset → local branch only), security scan `off` / `low` / `medium` / `high` (unset → `off`), and worker settings — as ship's step 1 lists them.

Write `brief.md` from `<ship>/templates/brief.md`, show it, and get one explicit "go". Corrections edit `brief.md`; they do not reopen grilling. That "go" authorizes everything in the brief.

Done when: `brief.md` has AC IDs, scope, constraints, delivery grants, worker settings, and the user said go.

## 2. Set up the crew

As ship's step 2: integration worktree, `.ship/<slug>/` moved into it, gate pane, `state.json` filled. Read only the latest round of each `review-*.md`, and only its BLOCKING items.

Done when: worktree exists, `.ship/<slug>/` holds `brief.md`, `log.md`, and `state.json`, and the gate pane is ready.

## 3. Spec and plan

Spawn **architect** with the spec prompt; it writes `spec.md`, including the **Proof** table. Then the plan prompt; it writes `plan.md` as tracer-bullet slices with blocked-by edges and exclusive files. A question the spec cannot settle on paper runs as a prototype first.

Check the Proof table yourself: every AC has a named test, and each test drives the outermost layer the suite reaches. A gap goes back to the architect, named.

Gate: `check.sh ac <run> spec.md plan.md` and `check.sh clean <run> spec.md` are green; every slice fits one worker turn with its files listed; no two slices that could run in parallel list the same file; every Proof test lands in some slice's "Tests to write first".

## 4. Build

Exactly ship's step 6: build the **frontier** up to the crew cap, one worktree per slice, one slice per prompt; scope-check each slice tip; re-run every gate yourself through `gate.sh` and read only `GATE_DONE`; merge one slice at a time and re-gate; on **red**, rule out state before code, then apply the builder-red rule in `<ship>/CREW.md` (three reds is a blocker). Mark each slice done in `plan.md` and `state.json` before anything else.

Done when: every slice merged and the gates are green on the integration tip.

## 5. Review

Exactly ship's step 7: **reviewer-primary** (Spec axis, Skeptic lens) and **reviewer-cross** (Standards axis, Architect + Minimalist lens) in parallel, each with Intent, scope-check table, security pass, and a verdict. You are **lead judge**: accept or reject each BLOCKING finding with one line of why in `log.md`; only accepted findings become fix slices. Reviewers also flag any Proof test that does not exercise its AC as claimed — with no QA, a hollow test is a BLOCKING finding. When the brief's **Security scan** is above `off`, run `<ship>/references/security-scan.md` at that tier, in parallel with the reviewers. It writes `security.md`.

Loop: fix slices → build gates → both re-review only the fix diff, and the scan re-runs on it at `low`. At most three rounds; then blocker.

Gate: `check.sh clean <run> review-primary.md review-cross.md` is green, plus `security.md` when the scan is on.

## 6. Acceptance

You fill `acceptance.md` from `<skill>/templates/acceptance.md`: each AC → its Proof test → the gate log where it ran green → PASS/FAIL. Run a final gate on the integration tip into `evidence/gate-final.log` and cite that. A FAIL routes back to its owner (spec gap → 3, bug → 4).

Gate: `check.sh acceptance <run>` is green.

## 7. Delivery and handoff (the user's second touchpoint)

Deliver exactly as ship's step 10: docs, final gate on clean state, then push / PR (ship's PR body) / merge / publish / deploy, stopping at the last granted step, then the post-delivery smoke check if delivery went past the branch.

Write `handoff.md` from `<skill>/templates/handoff.md`. Its **Not verified** section is not optional: name what tests and review could not see.

Report in a few lines: outcome, PR/MR or build link, acceptance table, defaults chosen, what was not verified, and what waits on the user. Close with a short **retro** from ship's step 11 categories — each loop-back is a candidate, and a bug a reviewer caught that a test should have is first in line.

## Escalation

As ship: a **blocker** is what the brief, the repo, and a reasonable default cannot answer — pause only that work, send one batched message (what, options, your recommendation), record the answer in `brief.md` and `state.json.blockers`. Everything else is a **default**: pick the conventional choice, log it in `state.json.defaults` and `log.md` with one line of why, and keep going.
