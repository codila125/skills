# Worker roles

Role prompts for the `ship-mini` orchestrator. Every prompt opens with ship's
shared preamble from `<ship>/ROLES.md`, with `<skill>` replaced by `<ship>` —
except that the architect's spec skeleton is `<skill>/templates/spec.md`, not
ship's.

## Crew

Replaces the Role defaults table in `<ship>/CREW.md`; every other rule there
(tiers, kinds, effort, escalation, fallback, deviating) applies unchanged.

| Role                    | Family  | Tier   | Effort | Why                                                           |
|-------------------------|---------|--------|--------|---------------------------------------------------------------|
| architect (spec, plan)  | primary | lead   | high   | carries the research too, and nothing re-checks the Proof table but review |
| builder                 | primary | worker | medium | gate-checked                                                  |
| reviewer-primary        | primary | worker | high   | —                                                             |
| reviewer-cross          | cross   | lead   | high   | a different family has different blind spots than the builder  |
| re-review of a fix diff | as above| as above | low  | —                                                             |
| security-researcher, security-verifier | as ship | as ship | as ship | only when the brief's Security scan is above `off`; prompts in `<ship>/ROLES.md` |

Small run (1–2 slices): the architect still runs at the lead tier, since it does
the researcher's work.

## architect → `spec.md`, then `plan.md`

Spec prompt:

```
Map the codebase this request touches, then fill spec.md. Four rules carry it:
- Codebase and External facts: cite code as path:line, and check every external API against the docs
  for the exact version the repo pins, citing URL plus version. Never state an API fact from memory.
- Per acceptance criterion, model every state the user can see (loading/empty/error/success) and the
  failure paths, not the happy path alone.
- Proof: name one test per AC id that proves it, driving the outermost layer the repo's test suite
  reaches (route, CLI, rendered component). There is no QA phase; this test is the only proof.
- Leave no open question: decide it and record the reason, as an ADR when it meets the test in
  <ship>/references/domain-modeling.md. A question you cannot settle on paper is answered with a
  throwaway prototype (<ship>/references/prototype.md); record only the decision it produced.
```

Plan prompt: ship's architect plan prompt from `<ship>/ROLES.md`, plus:

```
Every Proof test in spec.md appears under "Tests to write first" in exactly one slice.
```

## builder → commits

Ship's builder slice, fix, and second-red prompts from `<ship>/ROLES.md`, with
this line added to the slice prompt:

```
The Proof tests spec.md assigns to this slice must exercise their AC as written, at the layer named.
```

## reviewer-primary and reviewer-cross → `review-primary.md` / `review-cross.md`

Ship's reviewer prompt, axis/lens table, and re-review prompt from
`<ship>/ROLES.md`, with this line added to both:

```
There is no QA phase. For each Proof test in spec.md, check that it actually exercises its AC at the
layer named; a test that would pass with the feature broken is BLOCKING.
```
