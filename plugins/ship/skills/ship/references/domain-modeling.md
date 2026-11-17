# Domain modeling

Read `GLOSSARY.md` when it exists so names in the spec and tests match the
project's language. This file is about *changing* the model, which the spec phase
does.

## Sharpen the vocabulary

When a term is fuzzy or overloaded, split it: "you say 'session' — the login session,
or the editing session?" Check the code against the claim; if the code disagrees,
surface it instead of writing the spec around the contradiction. A resolved term
goes into `GLOSSARY.md` when the repo has one, in one line, with no
implementation detail.

## When a decision earns an ADR

All three must be true: **hard to reverse**, **surprising without context**, and
**a real trade-off**. If any is missing, record the decision in `spec.md` and move
on.

```md
# <short title>

<1–3 sentences: the context, what was decided, and why.>
```

Add **Considered options** or **Consequences** only when they carry real
information. Number sequentially (`0001-slug.md`) in the repo's ADR folder; if it
has none, keep the ADRs in `spec.md` rather than inventing a directory.
