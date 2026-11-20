---
status: draft
blocking: 0
open-questions: 0
---

# Handoff

## Shipped

<what changed, on which branch or artifact, and where it lives. Reference
`spec.md`, `plan.md`, and the commits by path or sha; do not restate them.>

## How to try it

<the commands or steps that reach the new behaviour>

## Verification

| AC    | Proof test | Result |
|-------|------------|--------|
| <AC-id> | `…` | PASS |

## Security

<When the scan ran: the tier and the diff's range, survivors fixed, refuted
candidates, and pre-existing flaws left alone with their `file:line`. When it did
not run, write "scan off — not audited". Never reproduce a credential's value
here; cite its location and use the Redactions section.>

## Not verified

This run had no QA phase: nothing launched the running software and drove it
like a user. Proof is the test suite and two code reviews. List what that
leaves unchecked — UI that tests do not render, flows across processes,
real devices, real network:

- <…>

## Decisions made on your behalf

- <default from `log.md`> — <why>

## Deferred or out of scope

- <…>

## Waiting on you

<the steps only a human can take — credentials, dashboard clicks, a release
submission, an ungranted push. When the step is a procedure, say that ship's
`references/wizard.md` turns it into one script the user can run.>

## Redactions

<List anything removed or masked here, or write "none".>
