---
name: cleanup-branch
description: Clean up a merged branch by removing its worktrees and local refs across all Glade repos. First verifies the branch is no longer active on GitHub (Glade auto-deletes branches on merge, so a still-existing remote branch means the work is in flight); if active, surface the PR link instead of deleting.
---

# cleanup-branch

Remove worktrees and local branch refs for a feature branch that has already been merged.

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
webforms            Merged (remote deleted)  Removed worktree + local branch
```

If any repo was skipped because the branch is still active, end with a one-line callout listing those repos and PR URLs so it's impossible to miss.

## Guardrails

- Refuse to operate on `main`, `master`, `develop`, or anything matching `release/*`.
- Always `fetch --prune` before classifying — stale remote refs would cause silent data loss.
- Never `--force` worktree removal silently; always surface dirty files first.
- Per-repo state is independent: it's normal for the same branch to be "active" in one repo and "merged" in another. Handle each independently.
