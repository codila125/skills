# Crew: models, effort, budget

How the orchestrator picks an agent kind, model, and effort for each worker.

## Policy, not inventory

Which families exist, which models fill each tier, which kinds reach them, and
which effort levels those models accept are user- and machine-specific facts.
They live outside this skill: read the **local roster** at `$SHIP_CREW` if it is
set, else `~/.agents/crew.local.md`, else `~/.config/ship/crew.local.md`. Take
the roster, the installed kinds, the vision column, and the effort table from
there. Everything below is policy — how to use whatever that file lists.

No cross family — no local roster at all, or a roster with a single family — and the
rules below still run, with the primary family as the only family and
`reviewer-cross` keeping its independence from a fresh context and its different
prompt rather than from a different family. Spawn that run's workers on the
kind's own default model rather than inventing a tier, and record the degradation
in `log.md`: a run that reviews and builds on one model is a weaker run than the
one the policy describes.

## Tiers

Each **family** is one billing budget. Within a family, models are ranked into
three tiers — `lead`, `worker`, `bulk` — and one model may fill more than one
tier. Roles name a tier, never a model id, so swapping a family or re-tiering a
model is a roster edit and not a prompt rewrite. Models outside the roster are
never used.

## Kinds

A **kind** is the CLI a worker agent runs on. Model and effort args go after `--`
in `herdr agent start`:

| Kind     | Model flag              | Effort flag                  |
|----------|-------------------------|------------------------------|
| `claude` | `--model <id>`          | `--effort <level>`           |
| `pi`     | `--model <provider/id>` | `--thinking <level>`         |

Those two are examples, not the set: Herdr launches any of its kinds (`codex`,
`gemini`, `cursor`, `opencode`, `copilot`, …) by running that CLI, so a worker is
only as reachable as the CLI the user has installed and signed in.

For any other kind, read its `--help` for the model and effort flags before
spawning it; `herdr agent` prints the kind list the installed binary accepts, and
that list is the authority, not this table. Which families a kind reaches here,
and which levels its models accept, come from the local roster: never assume a
kind can reach a family, and never pass a level the effort table does not list
for that model.

## Orchestrator

The orchestrator is the session running this skill: its kind, model, and effort
stay exactly as the user started it. Its family is the **primary family**; the
cross family is the first family in the local roster that is not the primary and
has a plan.

If the orchestrator's own CLI is not in the local roster, add its row before
preflight: every role needs a model to spawn on, and the primary family is where
most of them run.

## Role defaults

| Role                    | Family  | Tier   | Effort | Why                                                           |
|-------------------------|---------|--------|--------|---------------------------------------------------------------|
| researcher              | cross   | bulk   | medium | spares the primary budget                                     |
| architect (spec, plan)  | primary | lead   | high   | —                                                             |
| qa (test plan)          | cross   | lead   | high   | an independent reading of the brief by a different family      |
| builder                 | primary | worker | medium | —                                                             |
| reviewer-primary        | primary | worker | high   | —                                                             |
| reviewer-cross          | cross   | lead   | high   | a different family has different blind spots than the builder  |
| qa (execute)            | primary | worker | medium | needs to drive the running app and read its screens              |
| re-review of a fix diff | as above| as above | low  | —                                                             |

`reviewer-cross` runs as the kind that reaches its own cross family — never the
kind the builder ran on. Verify the pairing before spawning: a kind with no key
for its cross family drops that role back onto the primary family, and the run
gets one review done twice without saying so.

Preflight copies every resolved kind, model, and effort into `brief.md`, so a
resumed run inherits its crew instead of re-resolving it against an edited
roster.

## Effort rules

- Effort follows how unchecked the output is: gate-checked work runs at medium, judgment nothing downstream verifies runs at high.
- Every spawn sets effort explicitly, `max` never.
- When a model does not accept the level a role asks for, round **up** to the nearest level it does accept and log the substitution — a family whose `worker` model has no `medium` runs that role at `high`, which is a budget decision, not a formatting one.
- A role that must read images runs only on a model the local roster marks as vision-capable.

## Escalation and fallback

- **Small run** (plan has 1–2 slices): the architect runs at the worker tier, high effort.
- **Builder red**: first red retries the slice at high effort; second red retries once at the lead tier, high effort, and requires the diagnosis pass — one command that goes red on this failure, per `<skill>/references/diagnosing-bugs.md` — before any further code change; third red is a blocker.
- **Lead spawns** in a family the local roster gives a fallback flag carry it.
- **Budget exhausted**: a rate-limit or out-of-credit message in a worker pane (`herdr agent read`) moves that role to the same tier in another family with a plan, or one tier down in its own family, whichever keeps every image-reading role on a vision-capable model. Log the move.
- **No family has capacity** for a role: that role is a blocker.

## Deviating

The tables are defaults. The orchestrator may change a role's family, tier, or
effort for a run-specific reason (a slice where a mistake is expensive to find,
such as native or platform-specific code, gets a lead-tier builder), staying
inside the roster and the effort rules, with one line of why in `log.md` — and on
the slice in `plan.md`, so the override survives a context loss and the next
orchestrator inherits it.
