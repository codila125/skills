# Wizard

For the steps only a human can take: credentials, a third-party dashboard, a
release submission, a one-off cutover. The deliverable is a bash script that walks
them through it. Never for anything the agent can do itself.

**Scope it from the repo first**, not by asking: `.env*`, the README, and its CI
config — `.github/workflows/*`, `.gitlab-ci.yml`, or whatever the repo uses (every
`secrets.*` / `vars.*` in it is a value the wizard must produce). Then list the
stages in order, and for each: where the human gets the value, where it is
written, and whether it is secret. Confirm the list with the user before writing
code.

One `stage` per step, in dependency order:

```bash
stage "Create the API key"                # clears the screen, shows n/N
say   "Dashboard → Developers → API keys → Reveal test key"
open_url "https://example.com/keys"       # open before asking for its value
value=$(ask_secret "Paste the test key")  # hidden input for anything secret
write_env API_TEST_KEY "$value"           # values that persist
set_secret API_TEST_KEY "$value"          # only what CI actually needs
confirm "This deletes the old bucket."    # every irreversible action
```

Keep one focused task per stage so nothing scrolls away. Never invent a UI path
you have not verified — say the step is unverified instead.

**Verify statically**: `bash -n`, `shellcheck` when available, `chmod +x`; then
trace it — every value is captured and lands where scoped, and every
`set_secret` name matches a `secrets.*` in CI. Never run it end to end; it waits
on a human. Ephemeral by default: keep it in `scripts/` and delete it once the
job is done.
