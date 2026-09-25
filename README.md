# temporal-demo-agents

Claude Code plugin for spec-driven, multi-agent builds of Temporal demo apps and utilities in Python.

## What's included

- **Six subagents** (`agents/`):
  - `temporal-workflow-writer` — workflow/activity definitions, determinism rules
  - `temporal-activity-writer` — activity implementations, retries, heartbeats
  - `temporal-test-writer` — tests, including replay tests
  - `demo-reviewer` — read-only, diffs a change set against SPEC.md/PLAN.md
  - `spec-sync-checker` — read-only, detects drift between code and spec after hand edits
  - `temporal-docs-writer` — README/walkthrough per demo app
- **SessionStart hook** (`hooks/hooks.json` + `scripts/session-start-spec-check.sh`) — runs `spec-sync-checker` automatically at the start of every session if `SPEC.md`/`PLAN.md` exist in the project.
- **Bundled MCP server** (`.mcp.json`) — connects the Temporal Knowledge Base docs server (`temporal-docs`) automatically on install.
- **Sample fetcher** (`scripts/install-samples.sh`) — clones `temporalio/samples-python` into a demo repo as `references/temporal-samples/`, which three of the agents consult before inventing a pattern.

## Install

### Local test (before pushing to GitHub)
```bash
claude --plugin-dir /path/to/temporal-demo-agents
```

### New or existing repo (after this repo is pushed to GitHub, private is fine)
```bash
/plugin marketplace add <you>/temporal-demo-agents
/plugin install temporal-demo-agents@joe-temporal-marketplace
```
Restart Claude Code. Choose **project** scope if prompted, so this only applies to Temporal demo repos.

If installing in a second repo doesn't create that repo's `.claude/settings.json` entry (a known Claude Code quirk when a plugin is already installed elsewhere at project scope), add this manually and merge it into the file rather than overwriting it:
```json
{
  "enabledPlugins": {
    "temporal-demo-agents@joe-temporal-marketplace": true
  }
}
```

## Reference samples

`temporal-workflow-writer`, `temporal-activity-writer` and `temporal-test-writer` are told to
check `references/temporal-samples/` for an existing pattern before inventing one. Nothing creates
that directory for you, so wire it into the demo repo's own install step:

```bash
# in the demo repo's scripts/install.sh
"${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/.../temporal-demo-agents}/scripts/install-samples.sh" "$REPO_ROOT"
```

or run it once by hand from the repo root. Add `references/` to `.gitignore` — the clone is a
convenience, not source. If the directory is missing the agents fall back to the `temporal-docs`
MCP server and say so, rather than skipping the check silently.

## Using it

In a demo repo with this plugin installed:
1. Write `SPEC.md` and `PLAN.md` with the main session (this is a conversation, not delegated to a subagent).
2. Let the main session delegate execution to the subagents above as work comes up — auto-delegation follows each agent's `description`, or invoke one by name explicitly.
3. Run `demo-reviewer` before considering a build done.
4. `spec-sync-checker` runs automatically at session start via the hook — no manual step needed.

Two things the agents will do that are worth expecting:

- `temporal-test-writer` proves each test can fail by breaking the behavior it pins and watching
  it go red, then restoring. A test that passes the first time it runs has demonstrated nothing.
- `demo-reviewer` runs the suite and mutates a scratch copy of the tree rather than reading the
  tests. A guard that survives its behavior being deleted is a finding in itself, and usually a
  more valuable one than anything the tests caught.

## Updating

Edit this repo, commit and push, then in each installed project re-run the marketplace add/install cycle (or use `/plugin` to manage/update) to pick up the change.
