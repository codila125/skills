# References

Procedures the `ship` phases name, distilled so the run needs no other skill
installed. Read the one your phase names, when that phase starts; nothing here
is loaded by default.

| File | Adapts | Read by | Does |
|------|--------|---------|------|
| `grilling.md` | `mattpocock/skills` · `grilling` | orchestrator, intake | interviews the user to a shared understanding |
| `domain-modeling.md` | `mattpocock/skills` · `domain-modeling` | architect, spec | glossary terms and when a decision earns an ADR |
| `prototype.md` | `mattpocock/skills` · `prototype` | architect, spec | answers a design question with throwaway code |
| `tdd.md` | `mattpocock/skills` · `tdd` | builder | red → green loop |
| `diagnosing-bugs.md` | `mattpocock/skills` · `diagnosing-bugs` | builder, second red | a feedback loop before any more code |
| `code-review.md` | `mattpocock/skills` · `code-review`; smells from Fowler, *Refactoring* ch. 3 | both reviewers | what to look for and how to report it |
| `security-scan.md` | Anthropic's Claude Security plugin, its public design only | orchestrator, review | tiered research of the diff, then a panel that tries to refute each finding |
| `wizard.md` | `mattpocock/skills` · `wizard` | orchestrator, handoff | a script that walks a human through manual steps |

Rules for this folder:

- **Procedures only.** A body template belongs in `templates/`; a rule that fits
  in one sentence belongs in [`../SKILL.md`](../SKILL.md). Keep every file under
  ~55 lines.
- **One source of truth.** The phase says *when* to read a file; the file says
  *how*. Never repeat a procedure in two places.
- **Provenance lives here.** Everything above adapts the MIT-licensed
  `mattpocock/skills` collection (the file names the skill), and the frontier,
  scope-check, lens, and lead-judgment ideas in [`../SKILL.md`](../SKILL.md)
  come from `poteto/noodle`. These are rewritten for a hands-off, multi-agent
  run, not maintained as a mirror: when upstream changes, take the idea, not
  the diff.
- **`security-scan.md` is original text.** It takes only the publicly documented
  shape of Anthropic's proprietary Claude Security plugin: researchers, then a
  panel that refutes by default. Copy none of that plugin's text into this
  folder, since its license forbids redistribution.
