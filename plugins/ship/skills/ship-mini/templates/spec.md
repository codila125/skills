---
status: draft
blocking: 0
open-questions: 0
---

# Spec

## Codebase

| Where | What it is | Reuse or replace |
|-------|------------|------------------|
| `src/…:12` | … | … |

Prior art: <how this repo already solves a similar problem: `path:line`>

## External facts

| API / library | Version pinned | Fact relied on | Doc URL |
|---------------|----------------|----------------|---------|
| …             | …              | …              | …       |

## Behaviour per acceptance criterion

### <AC-id> — <short name>

States: `<discriminated union of loading / empty / error / success>`.
Edge cases: <…>
Failure states: <…>

## Proof

The test that proves each criterion. With no QA phase, this table is the only
check that the behaviour works, so each test drives the outermost layer the
repo's test suite reaches (route, CLI, rendered component), not a helper.

| AC    | Test (file › name) | Layer it drives |
|-------|--------------------|-----------------|
| <AC-id> | `src/….test.ts` › "…" | … |

## Interfaces

<types, signatures, public surface: functions, CLI flags, routes, props, storage shapes>

## Data

<shapes persisted or sent, with migration notes if a shape changes>

## Non-functionals

- Performance: <budget from the brief>
- Accessibility: <level from the brief>
- Security: <…>

## Risks

| Risk | Why it bites | Spike or mitigation |
|------|--------------|---------------------|
| …    | …            | …                   |

## Decisions (ADRs)

### ADR-1 — <title>

- Context: <…>
- Decision: <…>
- Consequence: <…>

## Defaults

- <default chosen> — <why>
