# Orchestration reference

Consulted on demand by the `ship` orchestrator: crew modes, Herdr recipes, gate
runs, resume, approvals, abort. The steps themselves live in
[`SKILL.md`](SKILL.md).

The installed `herdr` binary is the authority for syntax. If a command here
fails, run `herdr <group>` to print its real usage before improvising.

## Crew modes

Pick the first mode the environment supports; record it in `state.json` and
`log.md`.

| Mode | When | How |
|------|------|-----|
| `herdr` | `test "${HERDR_ENV:-}" = 1` passes | Worker agents in panes, as below |
| `subagents` | the agent has a subagent/task dispatch tool | One dispatch per role, given the role section of [`ROLES.md`](ROLES.md), `brief.md`, and its input files; the orchestrator writes the returned text to the run file |
| `sequential` | neither exists | One role at a time in this context: read that role's section, do the work, write its file, then move on |

`sequential` loses cross-family independence. Keep the one place it matters:
write `test-plan.md` before reading `spec.md`, and review from the diff plus
`spec.md`, not from memory of writing it.

## Layout

Create the branch and the worktree from the **repo root**, wherever the session
started, then read the JSON it returns for the workspace id, root pane id, and
path:

```bash
repo=$(git rev-parse --show-toplevel)
herdr worktree create --cwd "$repo" --branch <type>/<slug> --base <base_ref> \
  --label <slug> --trust-repository --no-focus
```

`--trust-repository` is not optional: without it the first worker stops on a
repository-trust dialog. Record `base_ref`, `merge_base`
(`git -C <worktree> merge-base <base_ref> HEAD`), `worktree`, and `branch` in
`state.json`.

Inside the worktree workspace, use three kinds of pane:

| Pane | Holds | Notes |
|------|-------|-------|
| `gates` | a plain shell, never an agent | gates and merges run here and only here; created with `--cwd <worktree>`, which carries the integration branch |
| one pane per role | that role's agent | closed when the phase ends |

```bash
herdr tab create --workspace <workspace> --cwd <worktree> --label gates --no-focus
herdr pane split <pane> --direction right --cwd <worktree> --no-focus
```

A tab holds four panes; open another tab when it is full. Cap **four live
agents at once** — panes are cheap, rate limits and metered budgets are not.

## Slice worktrees

The run's worktree carries the **integration branch** `<type>/<slug>`. Every
frontier slice builds in its own worktree off it, on branch `<slug>/slice-<n>`, so
no two builders share a git index:

```bash
herdr worktree create --workspace <workspace> --branch <slug>/slice-<n> \
  --base <type>/<slug> --label slice-<n> --trust-repository --no-focus
herdr pane split <pane> --direction down --cwd <slice-worktree> --no-focus
```

Merge in the gate pane, one slice at a time, re-gating after each so the
integration branch never carries an unverified merge:

```bash
herdr pane run <gate_pane> "git merge --no-ff <slug>/slice-<n>"
```

A merge conflict is a plan defect, not a builder failure: two slices that touch
the same file were not parallel work. Stop the second slice, add the edge to
`plan.md`, and rebuild it against the updated frontier. Remove a slice worktree
once its branch is merged.

## Spawn

```bash
herdr agent start <role> --kind <kind> --pane <pane> -- <model args> <effort args>
```

Model and effort flags per kind come from [`CREW.md`](CREW.md).

## Handoff

Confirm the target is ready before prompting — `--wait` matches the completion
of a turn already in flight, so a stale `done` can be mistaken for the new one:

```bash
herdr agent get <role>            # expect state idle or done
herdr agent prompt <role> "<role prompt>" --wait --until done --until blocked --timeout <ms from the table below>
```

### Parallel roles

Roles with no edge between them — the two reviewers are the only pair that
qualifies — dispatch together: spawn both panes, then send both prompts with
`--wait` running in the background, so neither role waits on the other's turn.
Waiting inside the loop serializes them and spends the second role's timeout for
nothing.

```bash
herdr agent prompt reviewer-primary "<reviewer-primary prompt>" --wait --until done --until blocked --timeout 900000 &
herdr agent prompt reviewer-cross "<reviewer-cross prompt>" --wait --until done --until blocked --timeout 900000 &
wait
```

A role that reports `blocked` or times out while its sibling is still working is
read with `herdr agent read <role> --lines 20` on its own; the pair's gate opens
only when both files are written.

| Phase | Timeout (ms) |
|-------|--------------|
| research | 900000 |
| spec, test-plan, plan | 900000 |
| build slice | 1800000 |
| review, re-review | 900000 / 600000 |
| QA execute, re-test | 1800000 / 900000 |

Worker states:

| State | Meaning | Orchestrator move |
|-------|---------|-------------------|
| `idle` / `done` + `REPLY DONE <file>` or `<sha>` | output written | read the file, run the gate |
| `BLOCKED <reason>` | none of brief, repo, default answered it | answer it, or escalate |
| `blocked` (dialog) | approval prompt | see Approvals |
| timeout / stall | unknown — not proof the prompt was lost | `herdr agent read <role> --lines 20` before acting, never resend blind |

## Gate runs

`herdr pane run` types into a pane and returns no exit status, so the gate
script writes markers and the marker is what you read:

```bash
herdr pane run <gate_pane> "<skill>/scripts/gate.sh <label> <run>/evidence/gate-<label>.log \
  '<gate 1>' '<gate 2>' '<gate 3>'"
herdr pane wait-output <gate_pane> --regex 'GATE_DONE <label> = [0-9]+' --lines 5 --timeout 1200000
```

Read only the `GATE_DONE` line when it is green; on red, read the `GATE_EXIT`
lines to name the failing command in the fix prompt, and leave the log for the
builder to read. Record `gates.<label>` in `state.json`.

Mechanical gates use `<skill>/scripts/check.sh`; a `MISSING` line names exactly
what to send back to the owning worker.

## Context budget

The orchestrator accumulates verdicts, not content. Spend the window on
decisions:

- Open a file for its frontmatter and only the section a gate named. The
  `blocking` and `open-questions` counts say how much is inside before you look.
- At each **phase boundary** choose in this order: continue; start a fresh
  session, when nothing here matters next; delegate to a subagent, when the work
  is scoped and can run unattended; write a handoff document; or compress the
  context with an instruction, where the harness offers that. A handoff document
  is only for work leaving this harness or directory: state, decisions, the next
  step, pointers to `spec.md`/`plan.md`/shas rather than copies, secrets
  redacted. Compressing mid-phase loses the thread; do it at the boundary.
- Past roughly 150k tokens — a rule of thumb, not a measurement of any current model — the reasoning gets worse before the window fills.
  `state.json` survives a clear, so clearing is cheap; a confident guess about a
  decision the summary flattened is not.

## Git guard

Workers never push, merge, or rewrite history; the orchestrator owns all three.
Where the harness has hooks, enforce that instead of only instructing it: wire
`<skill>/scripts/guard-git.sh` as the pre-tool hook for shell commands. It reads
the command from argv or from a hook's JSON on stdin, and exits 2 to block a push,
a history rewrite, or a working-tree reset.

```bash
<skill>/scripts/guard-git.sh "$command"                          # argv form
<skill>/scripts/guard-git.sh <<< '{"tool_input":{"command":"git push"}}'   # hook form
```

## Resume

`state.json` is the resume point; `log.md` is the story. On a new session:

```bash
cd "$(git rev-parse --show-toplevel)" && grep -l '"status": "running"' .ship/*/state.json
```

Match the user's request against the `request` field, then re-enter at
`phase` and carry the counters as they stand. Confirm the
worktree and branch still exist (`git -C <worktree> status`, `herdr agent list`)
before prompting anything, and close panes left over from a dead session.

## Approvals

- Repository-trust or folder-trust dialog on the worktree path: approve.
- Any dialog whose action stays inside the worktree and inside the brief's
  grants: approve.
- Anything touching files outside the worktree, installing a global, or an
  outward action past the grants: escalate, never approve.

## Abort

On user stop, killed session, or an abandoned run:

1. Close worker panes (`herdr pane close`), leave the worktree and `.ship/` intact.
2. Set `state.json.status = "aborted"` and append the reason to `log.md`.
3. Write `handoff.md` with what shipped, what is half-done, and the phase to
   resume from.

Resume re-enters that phase; nothing is re-derived from memory.
