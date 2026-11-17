# Diagnosing bugs

Reaching this file means a gate is red twice. Stop changing code until you have a
**tight loop**: one command that goes red on *this* failure. Everything after
that is mechanical; without it, no amount of staring at the diff helps.

## Build the loop

In roughly this order, and refuse to give up early:

1. A failing test at the seam that reaches the bug.
2. A CLI invocation with a fixture input, diffed against known-good output.
3. A script against the running app (HTTP, or a UI driver asserting on what the
   user sees).
4. Replay a captured payload or event log through the code path in isolation.
5. A throwaway rig: the smallest subset of the system that reaches the bug.
6. **Bisect** when it appeared between two known-good states: automate "boot at
   X, check", then `git bisect run`.
7. **Differential**: same input through old and new, diff the outputs.

## Tighten it

- Faster: cache setup, skip unrelated initialization, narrow the scope.
- Sharper: assert the symptom, not "didn't crash".
- Deterministic: pin time, seed randomness, isolate the filesystem, freeze the
  network.

## Then

- Read the failure, don't guess at it. Form one hypothesis, test it with the
  loop, keep the result.
- Fix the **root cause**. If the first fix that comes to mind is a symptom fix,
  ask why until it isn't: bad value → missing guard → the source returns empty →
  handle empty at the source.
- Write the regression test at the loop's seam, then confirm it fails without
  the fix and passes with it.
- Grep for the same pattern elsewhere: a bug that exists once usually exists
  twice.
- Redact secrets in anything you show or quote.
