# Contributing

## Add a skill to an existing plugin

1. Create `plugins/<plugin>/skills/<skill-name>/SKILL.md`. Use a lowercase,
   hyphenated folder name, and put the same name in the frontmatter:

   ```markdown
   ---
   name: <skill-name>
   description: What the skill does and when to use it (1024 characters max).
   ---
   ```

2. Add `plugins/<plugin>/skills/<skill-name>/agents/openai.yaml` for Codex:

   ```yaml
   interface:
     display_name: "Skill Name"
     short_description: "One line"
     default_prompt: "Use $<skill-name> to ..."
   ```

3. Add a row for the skill to the plugin's README.

## Add a plugin

1. Create `plugins/<plugin>/` with a `skills/` folder.
2. Add `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`. Both must use
   the same `name`. Copy them from `plugins/ship/` and edit.
3. List the plugin in **both** `.claude-plugin/marketplace.json` and
   `.agents/plugins/marketplace.json`.
4. Add a row for the plugin to the root README.

## Before you push

```sh
python3 scripts/validate.py
claude plugin validate .
```

CI runs these checks, plus shellcheck, on every push and pull request. To block
merging when a check fails, mark the three `Validate skills` jobs as required
status checks in the branch protection rule for `main`.

## Releasing

Raise `version` in both plugin manifests when a plugin's behaviour changes.
Claude Code uses this version to decide whether installed copies need an update.
