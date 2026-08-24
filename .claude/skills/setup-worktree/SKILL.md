---
name: setup-worktree
description: Create and bootstrap a single git worktree for one Glade repo. Runs git worktree add (from origin/main or tracking an existing branch), direnv allow, then the repo's own scripts/setupDevEnvironment.sh. Use for one repo; start-feature loops this across many.
---

# setup-worktree

Runs a script that does all the work — invoke it with the Bash tool:

```bash
~/home-git/.claude/scripts/setup-worktree <repo> <branch> [dest]
```

- **`<repo>`** — repo name, resolved under `~/dev/glade/core/` then `~/dev/glade/utility/` (or an explicit path to a repo).
- **`<branch>`** — branch for the worktree.
- **`[dest]`** — worktree path. Defaults to `$PWD/<repo>`, so `cd` into the per-feature dir first (e.g. `~/dev/glade/per-feature/<feature>/`) and the worktree lands beside its siblings.

## What the script does

1. **AWS preflight** — runs the repo's own `scripts/resolve-aws-profile.sh` (skipped for repos that don't ship it), so it still exits early with an `aws sso login` hint when nothing is logged in. It deliberately does **not** export `AWS_PROFILE`: the repo's `with-aws-profile.sh` and `createDotEnv.ts` pick the right profile themselves — per environment, least-privileged first — and both honor an inherited `AWS_PROFILE` verbatim, so pinning one here would override them.
2. **Skip if `dest` exists** — idempotent, exits 0.
3. **`git worktree add`** — fetches `origin` first, then tracks `origin/<branch>` if it exists, checks out an existing local branch, or creates a new branch from `origin/main`.
4. **`direnv allow`** on the new worktree.
5. **Bootstrap** — run via `direnv exec` (so it gets the right node from `.envrc`), with per-repo handling:
   - `noodle-frontend` → `scripts/setupDevEnvironment.sh --local`
   - `glade` → `yarn`
   - any repo with `scripts/setupDevEnvironment.sh` → that script (handles `yarn install`, `build:devdotenv`, `.env` symlink, `build:graphqltypes`)
   - otherwise (e.g. `pdf-form-parser`, `utility/*`) → nothing beyond the worktree + `direnv allow`

## Notes

- Fully non-interactive — safe to call in a loop or in parallel across repos.
- Exits non-zero on any failure so a caller can detect it.
