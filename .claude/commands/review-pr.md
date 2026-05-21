---
description: Review a pull request given a GitHub PR URL
argument-hint: <pr-url>
---

Review the pull request at the given URL. If no URL was provided as an argument, ask for one.

## Step 1: Fetch PR Details

Use `gh` to get the PR metadata and diff:

```bash
gh pr view <pr-url> --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,url
```

```bash
gh pr diff <pr-url>
```

Also fetch the list of changed files:

```bash
gh pr view <pr-url> --json files --jq '.files[].path'
```

## Step 2: Understand the Change

Read the PR title and description carefully. Identify:
- What problem is being solved or what feature is being added
- The scope of the change (how many files, lines changed)
- Any context or motivation the author provided

## Step 3: Review the Diff

Go through the diff and evaluate the following dimensions:

### Correctness
- Does the code do what the PR description says it does?
- Are there any obvious bugs, off-by-one errors, or edge cases not handled?
- Are error cases handled appropriately?

### Code Quality
- Is the code readable and reasonably simple?
- Are there any unnecessary abstractions or over-engineering?
- Is there duplicated logic that could be consolidated?
- Are variable and function names clear?

### Security
- Are there any injection risks (SQL, command, XSS)?
- Is user input validated at system boundaries?
- Are secrets or credentials handled safely?

### Tests
- Are there tests for the changed behavior?
- Do existing tests cover the affected code paths?

## Step 4: Write the Review

Structure your review as:

**Summary** — 2-3 sentences describing what the PR does and your overall impression.

**Feedback** — a bulleted list of findings. For each item include:
- Severity: `[critical]`, `[major]`, `[minor]`, or `[nit]`
- File and line reference if applicable
- A clear description of the issue and a suggested fix or improvement

If there are no issues, say so clearly.

**Verdict**
- Decision: one of — Approve / Approve with suggestions / Request changes
- Confidence: percentage reflecting how certain you are in the verdict (e.g. 85%) — lower if the diff is large, context is missing, or the logic is complex
- Needs tests: Yes / No — based on whether the change introduces or modifies behavior that lacks test coverage
