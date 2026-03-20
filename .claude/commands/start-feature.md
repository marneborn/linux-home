---
description: Set up git worktrees for a new feature across multiple repos
argument-hint: [branch-name]
---

Set up git worktrees for a new feature. Creates per-feature worktrees in `~/dev/glade/per-feature/<feature-name>/` from repos in `~/dev/glade/core/` and `~/dev/glade/utility/`, then bootstraps each worktree.

## Step 1: Gather Inputs

### Branch Name

If a branch name was provided as an argument, use it. Otherwise ask:

> What branch name should the worktrees use? (e.g. `ted/dev-12345-my-feature`)

### Feature Name

Immediately after receiving the branch name, derive a suggested feature name:
1. Strip a leading `<user>/` prefix (e.g. `ted/`)
2. Strip a leading ticket prefix matching `dev-NNNNN-` or `DEV-NNNNN-`
3. Use the remaining slug as the suggestion

Examples:
- `ted/dev-12345-case-filing-fix` → `case-filing-fix`
- `dev-12345-case-filing-fix` → `case-filing-fix`
- `my-cool-feature` → `my-cool-feature`

Ask immediately using `AskUserQuestion` with two options — do NOT discover repos first:
- **`<suggested-name>`**
- **Type something else**

If they choose "Type something else", follow up with a plain text prompt asking them to enter the feature name.

### Repos

Once the feature name is confirmed, discover all git repos in both `~/dev/glade/core/` and `~/dev/glade/utility/`:

```bash
for base in ~/dev/glade/core ~/dev/glade/utility; do
  for d in "$base"/*/; do
    if [ -d "$d/.git" ] || [ -f "$d/.git" ]; then
      echo "$base/$(basename $d)"
    fi
  done
done
```

For each discovered repo, ask a yes/no question using `AskUserQuestion` with two options — **Yes** and **No**. Ask them one at a time in order. Show the repo name and base directory in the question, e.g.:

> Include **noodle-api** (core)?

Treat Enter / "y" / "Yes" as include. "n" / "No" as skip. Collect the confirmed list before moving on.

## Step 2: Create the Per-Feature Directory

```bash
mkdir -p ~/dev/glade/per-feature/<feature-name>
```

## Step 3: Set Up Each Repo Worktree

For each selected repo, run the following sequence. Repos without dependencies on each other can be set up in parallel (use parallel Bash tool calls), but within each repo the steps must run sequentially.

### 3a. Create the Worktree

```bash
CORE_REPO=<full-path-from-discovery>   # e.g. ~/dev/glade/core/noodle-api or ~/dev/glade/utility/glade-claude-plugin
WORKTREE=~/dev/glade/per-feature/<feature-name>/<repo>
BRANCH=<branch-name>

# Fetch to get latest remote refs
git -C "$CORE_REPO" fetch origin 2>/dev/null || true

# Check whether the branch already exists locally or on origin
LOCAL_EXISTS=$(git -C "$CORE_REPO" show-ref --verify refs/heads/$BRANCH 2>/dev/null && echo yes || echo no)
REMOTE_EXISTS=$(git -C "$CORE_REPO" show-ref --verify refs/remotes/origin/$BRANCH 2>/dev/null && echo yes || echo no)

if [ "$LOCAL_EXISTS" = "yes" ]; then
  # Branch already exists locally — check it out into the worktree
  git -C "$CORE_REPO" worktree add "$WORKTREE" "$BRANCH"
elif [ "$REMOTE_EXISTS" = "yes" ]; then
  # Branch exists on origin — create local tracking branch in the worktree
  git -C "$CORE_REPO" worktree add --track -b "$BRANCH" "$WORKTREE" "origin/$BRANCH"
else
  # New branch — create it from main (or HEAD if main doesn't exist)
  START=$(git -C "$CORE_REPO" show-ref --verify refs/heads/main 2>/dev/null && echo main || echo HEAD)
  git -C "$CORE_REPO" worktree add -b "$BRANCH" "$WORKTREE" "$START"
fi
```

### 3b. Run Direnv Allow

```bash
cd ~/dev/glade/per-feature/<feature-name>/<repo> && direnv allow
```

### 3c. Install Dependencies

For repos with an `.nvmrc` (noodle-frontend, noodle-documents), use `nvm use` before yarn:

```bash
cd ~/dev/glade/per-feature/<feature-name>/<repo> && nvm use && yarn install
```

For all other repos:

```bash
cd ~/dev/glade/per-feature/<feature-name>/<repo> && yarn install
```

For `webforms`, run install at the repo root (it delegates to sub-packages):

```bash
cd ~/dev/glade/per-feature/<feature-name>/webforms && yarn install
```

For `pdf-form-parser` (Python/uv), use `uv sync` instead of yarn:

```bash
cd ~/dev/glade/per-feature/<feature-name>/pdf-form-parser && uv sync
```

Skip yarn/uv steps for repos that have neither a `package.json` nor a `pyproject.toml`.

### 3d. Build GraphQL Types (if supported)

Check whether the repo's `package.json` has a `build:graphqltypes` script before running:

```bash
cd ~/dev/glade/per-feature/<feature-name>/<repo>
node -e "const s=require('./package.json').scripts||{}; process.exit(s['build:graphqltypes']?0:1)" 2>/dev/null && yarn build:graphqltypes || true
```

For `webforms`, check and run inside `forms-backend/`:

```bash
cd ~/dev/glade/per-feature/<feature-name>/webforms/forms-backend
node -e "const s=require('./package.json').scripts||{}; process.exit(s['build:graphqltypes']?0:1)" 2>/dev/null && yarn build:graphqltypes || true
```

### 3e. Build Dev Dotenv (if supported)

Check whether the repo's `package.json` has a `build:devdotenv` script before running:

```bash
cd ~/dev/glade/per-feature/<feature-name>/<repo>
node -e "const s=require('./package.json').scripts||{}; process.exit(s['build:devdotenv']?0:1)" 2>/dev/null && yarn build:devdotenv || true
```

For `webforms`, run inside `forms-backend/`:

```bash
cd ~/dev/glade/per-feature/<feature-name>/webforms/forms-backend
node -e "const s=require('./package.json').scripts||{}; process.exit(s['build:devdotenv']?0:1)" 2>/dev/null && yarn build:devdotenv || true
```

### 3f. Symlink .env

```bash
cd ~/dev/glade/per-feature/<feature-name>/<repo> && ln -fs .env.development .env
```

For `webforms`, run inside `forms-backend/`:

```bash
cd ~/dev/glade/per-feature/<feature-name>/webforms/forms-backend && ln -fs .env.development .env
```

## Step 4: Report Results

Print a summary table:

```
Repo                       Worktree path                                         Status
------------------------------------------------------------------------------------------
noodle-api                 ~/dev/glade/per-feature/<feature>/noodle-api          Done
noodle-frontend            ~/dev/glade/per-feature/<feature>/noodle-frontend     Done
noodle-documents           ~/dev/glade/per-feature/<feature>/noodle-documents    Done
...
```

If any repo failed, show the error and suggest running the failed steps manually.

## Notes

- **Core repos are bare-worktree clones** stored in `~/dev/glade/core/`. Never commit or develop directly in `core/` — all work happens in per-feature worktrees under `~/dev/glade/per-feature/`.
- **The per-feature directory** (`~/dev/glade/per-feature/<feature-name>/`) is already a valid dev root: it contains `AGENTS.md` and `CLAUDE.md` symlinks so Claude Code picks up project instructions when opened from there.
- **`direnv allow` requires the worktree to already exist** — always run it after `worktree add`.
- **`build:devdotenv` generates `.env.development`** — the subsequent `ln -fs .env.development .env` makes tools that expect `.env` work without duplication.
- **webforms has a nested structure**: the git root is `webforms/` but the backend lives in `webforms/forms-backend/`. Run yarn commands in the `forms-backend/` subdirectory.
- **Parallel setup**: repo setups are independent of each other — run them in parallel Bash tool calls to save time.
