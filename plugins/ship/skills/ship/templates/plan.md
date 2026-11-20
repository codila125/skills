---
status: draft
blocking: 0
open-questions: 0
---

# Plan

A **task graph**, not a list. Each slice is a tracer bullet: a narrow but complete
path through every layer, demoable on its own, sized to one worker turn.
`Blocked by` names the slices that must land first; the **frontier** is every
slice whose blockers are done, and that is what may build in parallel.

| Slice | Goal | Covers | Blocked by | Files (exclusive) |
|-------|------|--------|------------|-------------------|
| 1     | …    | <AC-id> | none      | `src/…`           |

## Slice 1

- Goal: <…>
- Domain skills: <installed skills the builder must load, if any>
- Crew: <only when it deviates from the default builder: tier or role, and why>
- Tests to write first: <…>
- Security finding: <`S<n>` from security.md, or "none" — the regression test above goes red on the parent commit>
- Files touched: `src/…`, `src/….test.ts`
- Done bar: gate commands green, plus the observable behaviour that now works
- Status: `pending` | `done` | `blocked`

## Defaults

- <default chosen> — <why>
