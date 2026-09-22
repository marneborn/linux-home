---
name: cleanup-branch
description: Clean up a merged branch by removing its worktrees, local refs, and per-worktree Postgres test databases across all Glade repos. First verifies the branch is no longer active on GitHub (Glade auto-deletes branches on merge, so a still-existing remote branch means the work is in flight); if active, surface the PR link instead of deleting.
---

# cleanup-branch

Remove worktrees, local branch refs, and per-worktree Postgres test databases for a feature branch that has already been merged.

Glade auto-deletes branches on merge, so the rule is simple: **if `origin/<branch>` still exists, the branch is still active and must not be deleted**.

## Inputs

The branch name to clean up. If not supplied as an argument:

1. If the current working directory is inside a worktree, offer the worktree's branch as the default (`git -C . branch --show-current`).
2. Otherwise ask the user with `AskUserQuestion`.

Never assume `main` / `master` / a release branch — refuse if the user names one of these.

## Repos in scope

Search both `~/dev/glade/core/` and `~/dev/glade/utility/`:

```bash
for base in ~/dev/glade/core ~/dev/glade/utility; do
  for d in "$base"/*/; do
    if [ -d "$d/.git" ] || [ -f "$d/.git" ]; then
      echo "$base/$(basename $d)"
    fi
  done
done
```

## Step 1: Refresh remote refs (parallel per repo)

```bash
git -C "$REPO" fetch origin --prune
```

`--prune` removes stale `refs/remotes/origin/*` entries for branches deleted upstream — essential for trusting the next check.

## Step 2: Classify each repo

For each repo, determine:

```bash
REMOTE=$(git -C "$REPO" show-ref --verify --quiet "refs/remotes/origin/$BRANCH" && echo yes || echo no)
LOCAL=$(git -C "$REPO" show-ref --verify --quiet "refs/heads/$BRANCH"           && echo yes || echo no)
```

Three states:

| Remote | Local | Meaning | Action |
|---|---|---|---|
| yes | * | Still active on GitHub | **Skip — surface PR link** |
| no  | yes | Merged & auto-deleted upstream | Clean up |
| no  | no  | Not present in this repo | Skip silently |

## Step 3: For "still active" repos — report, don't delete

Look up the PR from the repo directory:

```bash
gh -C "$REPO" pr list --head "$BRANCH" --state all --json url,state,title,number --limit 1
```

Note: `gh` doesn't have `-C`; cd into the repo or use `--repo`. Simplest:

```bash
(cd "$REPO" && gh pr list --head "$BRANCH" --state all --json url,state,title,number --limit 1)
```

In the final report, clearly mark these repos as **NOT deleted** and include the PR URL (or note if no PR was found — that's an unusual state worth flagging).

## Step 4: For "merged & deleted" repos — clean up

### 4a. Find worktrees on this branch

```bash
git -C "$REPO" worktree list --porcelain | awk -v b="$BRANCH" '
  /^worktree / { wt=$2 }
  /^branch / {
    ref=$2; sub(/^refs\/heads\//, "", ref)
    if (ref == b) print wt
  }
'
```

### 4b. Remove each worktree

Before removing, check for uncommitted changes:

```bash
git -C "$WT" status --porcelain
```

- If clean → `git -C "$REPO" worktree remove "$WT"`
- If dirty → **stop and ask the user** before passing `--force`. List the modified files in the prompt.

### 4c. Delete the local branch

```bash
git -C "$REPO" branch -D "$BRANCH"
```

Use `-D` (force). The remote being deleted means the branch was merged on GitHub, but the local branch may not be merged into the local checkout (e.g. the bare-clone management copy is on `main` with no fast-forward).

### 4d. Drop the worktree's Postgres test database

Backend repos that run tests against Postgres get a **per-worktree test database** so
concurrent worktrees and agents don't truncate each other's rows (see the
`test-db-isolation` shared instructions). Those databases are never cleaned up by git, so
drop this branch's copy here.

Only for repos that have one — `.env.test` with a `POSTGRES_DB` (today: noodle-api,
noodle-documents, webforms, us-government-integrations, labs). Read `.env.test` from
`$REPO` (the main checkout), not the worktree, which may already be gone.

```bash
BASE_DB=$(grep -m1 '^POSTGRES_DB=' "$REPO/.env.test" 2>/dev/null | cut -d= -f2)
# No POSTGRES_DB in .env.test -> not a Postgres repo; skip this repo and move on.

PREFIX=${BASE_DB%_test}              # noodle_test -> noodle
SLUG=$(printf '%s' "$BRANCH" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')
MAXSLUG=$((63 - ${#PREFIX} - 6))     # keep "<prefix>_<slug>_test" inside PG's 63-byte limit
SLUG=${SLUG:0:$MAXSLUG}
CANDIDATE="${PREFIX}_${SLUG}_test"
```

Verify, then drop only if it exists:

```bash
psql -h 127.0.0.1 -U postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname = '$CANDIDATE'"

dropdb -h 127.0.0.1 -U postgres --force "$CANDIDATE"
```

`--force` (PG13+) disconnects any leftover session — a crashed test run can hold a
connection open and would otherwise block the drop.

**Refuse to drop** — these are non-negotiable, a mistake here destroys a working database:

- `$CANDIDATE` equal to `$BASE_DB` (an empty slug collapses the name onto the shared
  database every worktree falls back to)
- any name not ending in `_test`, or ending in `_dev`
- anything in a repo classified "still active on remote" in Step 2, or whose worktree
  removal the user declined in 4b — the branch is still in use, so is its database

### 4e. Report reclaimable orphans (don't drop them)

Per-worktree databases predate this step and people improvise names
(`noodle_test_p2mapping`, `questionnaires_test2`, `questionnaires_test_core3058` are all
real examples), so a name-suffix match won't find them. Cast a wide net on the prefix and
subtract every database any repo legitimately owns.

Build the protected set from all repos' env files first — this is what stops a
`noodle%`-style prefix match from offering up **noodle-documents' shared database**:

```bash
for base in ~/dev/glade/core ~/dev/glade/utility; do
  for d in "$base"/*/; do
    for f in .env.test .env .env.development; do
      grep -h -m1 '^POSTGRES_DB=' "$d$f" 2>/dev/null | cut -d= -f2
    done
  done
done | sort -u | grep . > /tmp/known_dbs.txt

LIST=$(sed "s/.*/'&'/" /tmp/known_dbs.txt | paste -sd, -)
psql -h 127.0.0.1 -U postgres -tAc \
  "SELECT datname FROM pg_database
    WHERE datname LIKE '${PREFIX}%' AND datname NOT IN ($LIST)"
```

Cross-check each hit against `git -C "$REPO" worktree list` and the local branch list.
Report ones with no matching worktree or branch as reclaimable, with the `dropdb` command
ready to copy — but **never drop these automatically**. The prefix match is deliberately
loose, so a hit may be someone's hand-made scratch database rather than a dead worktree's;
the name is a guess, not an attribution.

## Step 5: Tidy empty per-feature directory

If every removed worktree was a child of a common `~/dev/glade/per-feature/<feature>/` directory and the directory is now empty, ask the user whether to `rmdir` it.

Do not remove a non-empty per-feature directory.

## Step 6: Report

Print a summary table:

```
Repo                State                    Action
---------------------------------------------------------------------------
noodle-api          Active on remote         Skipped — PR: https://github.com/...
noodle-frontend     Merged (remote deleted)  Removed worktree + local branch
noodle-documents    Not present              —
webforms            Merged (remote deleted)  Removed worktree + local branch + questionnaires_myfeature_test
```

If any repo was skipped because the branch is still active, end with a one-line callout listing those repos and PR URLs so it's impossible to miss.

## Guardrails

- Refuse to operate on `main`, `master`, `develop`, or anything matching `release/*`.
- Always `fetch --prune` before classifying — stale remote refs would cause silent data loss.
- Never `--force` worktree removal silently; always surface dirty files first.
- Never drop a database whose name does not end in `_test`, and never the shared base database from `.env.test` — every worktree without its own database falls back to that one.
- Per-repo state is independent: it's normal for the same branch to be "active" in one repo and "merged" in another. Handle each independently.
