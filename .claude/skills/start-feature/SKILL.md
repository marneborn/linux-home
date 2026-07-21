---
name: start-feature
description: Set up git worktrees for a new feature across multiple Glade repos. Creates a per-feature dir under ~/dev/glade/per-feature and bootstraps one worktree per repo (branch + deps + dev env). Use when starting work that spans one or more repos. Wraps setup-worktree.
---

# start-feature

Runs a script that does all the work — invoke it with the Bash tool:

```bash
~/home-git/.claude/scripts/start-feature <subdir> <branch> <repo> [repo ...]
```

- **`<subdir>`** — directory name under `~/dev/glade/per-feature/` that holds this feature's worktrees (e.g. `dev-1234-case-filing`).
- **`<branch>`** — branch name used for every worktree.
- **`<repo...>`** — one or more repo names, resolved under `~/dev/glade/core/` then `~/dev/glade/utility/` (or explicit paths).

## Gathering the inputs

Before calling the script, work out the three inputs:

- **Branch** — if the user gives a Linear ticket instead of a branch, resolve the ticket's `branchName` (via the Linear MCP or the user), then use that.
- **Subdir** — the branch name typically looks like `<user>/DEV-NNNN-<slug>` (e.g. `ted/dev-35695-enable-with-aws-profile-in-all-repos`). Ask the user which form they want for the directory name:
  - **ticket id** — just the ticket, e.g. `dev-35695`
  - **slug** — the descriptive part, e.g. `enable-with-aws-profile-in-all-repos`

  Strip the leading `<user>/` prefix either way. If there's no ticket in the branch, use the slug without asking.
- **Repos** — ask which repos the feature touches. To list what's available:

  ```bash
  ls ~/dev/glade/core ~/dev/glade/utility
  ```

## What the script does

1. Validates the repo names, then does one AWS preflight (`staging-admin`) so it fails fast if you're not logged in.
2. `mkdir -p ~/dev/glade/per-feature/<subdir>`.
3. Fans out one **`setup-worktree`** per repo **in parallel** (each targets a different source repo, so no contention), logging each to `<subdir>/.setup-logs/<repo>.log`.
4. Prints a pass/fail summary; exits non-zero if any repo failed (its log path is shown).

Each repo's worktree creation + dev-env bootstrap is handled by [setup-worktree](../setup-worktree/SKILL.md) — see that skill for the per-repo details.
