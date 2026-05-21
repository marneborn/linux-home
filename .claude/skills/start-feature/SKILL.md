---
name: start-feature
description: Set up git worktrees for a new feature across multiple repos. Asks for a Linear ticket ID, fetches the branch name from Linear, prompts for which repos are needed, then creates worktrees in ~/dev/glade/per-feature/$ticket-id/$repo.
---

# start-feature

Run the shell script directly — it handles all interaction:

```bash
~/home-git/.claude/scripts/start-feature [TICKET-ID]
```

The script will:
1. Resolve a `LINEAR_API_KEY` (env → `~/.config/glade/linear_token` → prompt to paste + save)
2. Accept a ticket ID as argument or prompt for one (e.g. `DEV-1234`)
3. Fetch `branchName` from Linear's GraphQL API
4. Show a numbered menu of all repos in `~/dev/glade/core/` and `~/dev/glade/utility/`
5. Accept space-separated numbers or `a` for all
6. Create worktrees at `~/dev/glade/per-feature/$ticket-id/$repo` branched from `origin/main` (or tracking an existing remote branch)

## Running it via Claude

Use the Bash tool:

```bash
~/home-git/.claude/scripts/start-feature "$TICKET"
```

Pass the ticket ID if already known; otherwise the script will prompt.
The script is fully interactive, so invoke it with the Bash tool — it reads from stdin.
