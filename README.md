# skills

Agent skills by [codila125](https://github.com/codila125). This repository is a plugin
marketplace named `codila125-skills` for both **Claude Code** and **Codex**. The skills
are plain Markdown with [Agent Skills](https://agentskills.io) frontmatter, so other
agents can use them too.

## Plugins

| Plugin | Skills | What it does |
|---|---|---|
| [`ship`](plugins/ship/README.md) | `ship`, `ship-mini` | Takes one request from idea to delivered software through an orchestrated crew of agents. You give the request at the start and review the result at the end. |

## Install

| Agent | Install | Update |
|---|---|---|
| Claude Code | `claude plugin marketplace add codila125/skills`<br>`claude plugin install ship@codila125-skills` | `claude plugin marketplace update codila125-skills`, or turn on auto-update under `/plugin` → Marketplaces |
| Codex | `codex plugin marketplace add codila125/skills`<br>`codex plugin add ship@codila125-skills` | `codex plugin marketplace upgrade` |
| Other agents | `npx skills add codila125/skills -g` | `npx skills update -g` |

In Claude Code, plugin skills are namespaced: run `/ship:ship` or `/ship:ship-mini`.
In Codex, mention `$ship` or `$ship-mini`.

### Manual install

Clone the repository and symlink the skills into your agent's skills folder. Keep
`ship` and `ship-mini` together, because `ship-mini` reads files from `../ship`.

```sh
git clone https://github.com/codila125/skills ~/Developer/skills
ln -s ~/Developer/skills/plugins/ship/skills/ship      ~/.claude/skills/ship
ln -s ~/Developer/skills/plugins/ship/skills/ship-mini ~/.claude/skills/ship-mini
```

## Layout

```
.claude-plugin/marketplace.json   Claude Code marketplace
.agents/plugins/marketplace.json  Codex marketplace
plugins/<plugin>/
  .claude-plugin/plugin.json      Claude Code plugin manifest
  .codex-plugin/plugin.json       Codex plugin manifest
  skills/<skill>/
    SKILL.md                      the skill (frontmatter + instructions)
    agents/openai.yaml            Codex display name and default prompt
scripts/validate.py               checks run in CI
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Every push and pull request runs
[`validate.yml`](.github/workflows/validate.yml). It has three checks:

- **Skill files**: runs `scripts/validate.py`. It checks that each skill's frontmatter
  `name` matches its folder name, that each skill has a description of 1024 characters
  or fewer, and that each skill has an `agents/openai.yaml`. It also checks that both
  marketplaces list the same plugins, that every plugin has a Claude and a Codex
  manifest, that all JSON parses, that relative Markdown links point to real files, and
  that shell scripts are executable and have valid syntax.
- **Shellcheck**: runs `shellcheck` on every `*.sh` in `plugins/`.
- **Claude plugin validate**: runs `claude plugin validate` on the marketplace and on
  each plugin.
