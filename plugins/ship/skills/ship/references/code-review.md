# Code review

## Pin the point

Review `git diff <merge-base>...HEAD`, three-dot so the comparison is against the
merge-base. Confirm the ref resolves and the diff is not empty before reading
anything: an empty diff is a report about the branch, not a clean review.

## Two axes, one per reviewer

- **Spec**: does the work deliver what `spec.md` promises, including the edge and
  failure states it names?
- **Standards**: does it follow the repo's documented conventions — its agent
  instructions (`AGENTS.md` or equivalent), `CONTRIBUTING.md`,
  `CODING_STANDARDS.md`, lint config, the surrounding code?

A finding on either axis is reported the same way. Skip anything a tool already
enforces; the reviewer exists for what a tool cannot see.

## The smell baseline

Applies when the repo documents nothing. Each is a labelled heuristic
("possible Feature Envy"), never a hard violation, and a documented repo standard
always wins.

| Smell | What it looks like | Fix |
|-------|--------------------|-----|
| Mysterious name | the name does not reveal what it does or holds | rename; if no honest name exists, the design is murky |
| Duplicated code | the same shape in two places | extract, or delete one |
| Long function | more than one job in one body | split by responsibility |
| Long parameter list | four or more, or booleans as flags | options object, or a type |
| Feature envy | a method that mostly reads another module's data | move it there |
| Data clumps | the same few fields travel together | make them a type |
| Primitive obsession | strings and numbers where a type belongs | introduce the type |
| Repeated switches | the same case analysis in several places | one polymorphic seam |
| Shotgun surgery | one change edits many files | gather the responsibility |
| Divergent change | one file changes for unrelated reasons | split it |
| Speculative generality | abstraction with one caller, or "for later" | delete it |

## Reporting

- `path:line`, what is wrong, the fix you expect, and the AC id it breaks or
  "none".
- **BLOCKING** means merge-stopping. Rank by severity and cap the list at ten;
  the rest are **NOTE**.
- Name the evidence: which test, gate, or observed state proves the finding.
- Say what the work does well, in one line. A review that finds only faults is
  usually looking too hard.
