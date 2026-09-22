---
name: create-help-center
description: >
  Turn Linear project or issue context (plus any linked GitHub PRs) into a polished, user-facing
  help center article, publish it to the Glade help center in Plain, and announce it in the
  product-updates Slack channel. Use this skill whenever the user shares a Linear project or issue
  URL or ID and wants documentation for end users — phrases like "write a help center article",
  "document this feature", "create a help doc", "turn this into a help article", "publish this to
  the help center", or "add this to Plain". Also trigger when someone describes a shipped feature
  they want written up for customers, or references the Glade Help Center, Plain help center, or
  Sidekick suggested responses. Trigger even when the user just pastes a Linear link with a short
  note like "help doc for this" — the whole pipeline (gather context, draft, approve, publish,
  announce) lives here.
---

# Create Help Center Article

Turn what shipped in Linear into a customer-facing help center article, then get it live and announced. The pipeline is: **gather context → draft → approve → publish to Plain → announce in Slack.**

The whole point is to translate engineering-speak into something a law firm attorney or paralegal can actually use. Linear issues and PRs describe *how the system changed*; the article describes *what the user can now do*. Keep that translation front of mind at every step.

## Workflow Overview

1. **Gather context** from Linear (and any linked GitHub PRs)
2. **Draft** a user-facing article
3. **Get explicit approval** before anything goes live
4. **Publish** to the Glade help center in Plain
5. **Announce** in `#product-updates`

---

## Phase 1: Gather Context

### Figure out what you were given

The user will usually hand you one of these. Detect which:

- **Linear project** — URL containing `/project/` (e.g. `https://linear.app/glade/project/...`)
- **Linear issue** — a URL or a bare identifier (e.g. `https://linear.app/glade/issue/DEV-27520` or just `DEV-27520`)
- **A topic description** — no Linear reference at all. Ask whether there's a project or issue to anchor on; if not, you can proceed from the description alone, but the article will be thinner.

If you were given nothing, ask for a Linear project/issue URL or ID (or a feature description) before continuing.

### Pull the Linear context

**For a project:** use `Linear:get_project` for the description and details, then `Linear:list_issues` to enumerate its issues. For each issue that matters, use `Linear:get_issue` for the title/description/status and `Linear:list_comments` for the comments — implementation notes and "here's how it actually works" context tend to live in the comments, not the description.

**For an issue:** use `Linear:get_issue` and `Linear:list_comments`. If it belongs to a project, pull sibling issues for broader context, and grab any sub-issues too.

Pay attention to issue **status** — you're documenting what shipped, so lean on Done/completed issues and don't describe in-progress behavior as if it's live.

### Pull the GitHub PR context (best-effort)

PRs are the clearest record of user-facing behavior changes. Find PR links in the issue description, comments, and Linear attachments (a `Linear:get_issue` result includes attachments and the git branch name — the branch often maps to a PR).

If the `gh` CLI is available (Claude Code), read each PR with `gh pr view <number> --repo glade-ai/<repo>` for the title, description, and files changed. If `gh` isn't available, or a GitHub connector isn't set up, that's fine — skip it and work from Linear alone. Either way, **focus on user-visible changes** and ignore internal refactors, CI, and test-only PRs.

### Synthesize

Before writing, compile a short internal summary:

- **Feature name** — what a customer would call it (not the Linear title)
- **Problem it solves** — the user pain point
- **What changed** — new UI, new workflow, new behavior the user will notice
- **How it works** — the steps from the user's point of view
- **Limits / edge cases** — anything a user should know

---

## Phase 2: Draft the Article

Use this structure:

```markdown
# {Feature Name}

{1-2 sentence overview: what it does and why it matters}

## Overview

{Brief explanation and when a user would reach for this}

## How It Works

1. **{Step name}**: what to do
2. **{Step name}**: what to do

## Key Details

{Limits, requirements, supported formats, anything users need to know}

## FAQ

**Q: {Common question}**
A: {Clear answer}
```

### Writing guidelines

- **Write for attorneys and paralegals, not engineers.** No API references, code, table names, or internal architecture.
- **Say "Glade"** for the product, consistently.
- **Address the reader as "you."**
- **Be scannable.** Short sentences, real steps, concrete examples where they help.
- **Focus on tasks** — what the user can *do*, not how the system works underneath.
- **Never name internal tools** (Linear, GitHub, PRs, ticket IDs). Those don't exist from the customer's side.

---

## Phase 3: Review and Publish

### Get approval first

Publishing to the public help center and posting to Slack are both public actions, so nothing goes live without a clear yes. Show the full draft and ask:

> Here's the draft. Want me to:
> 1. **Publish as-is** to the Glade Help Center and announce it in `#product-updates`
> 2. **Edit first** — tell me what to change
> 3. **Publish only** (skip the Slack announcement)
> 4. **Start over** with a different angle

**STOP. Do not publish or post to Slack until the user explicitly approves.** Edits and follow-up questions are not approval — apply changes, re-show the draft, and ask again. Confirm which help center too (see below) if there's any ambiguity.

### Publish to Plain

Default to the **public** help center. Only use the internal one if the user explicitly asks.

- **Public** — `hc_01KA1PQRJPYH94HCT9SPE5WHT7` ("Glade.Ai Help Center")
- **Internal** — `hc_01KAF0ZEEST08DBBJFDDVDF4S6` ("Glade.Ai INTERNAL Help Center")

Publish with `Plain:upsertHelpCenterArticle`. If the exact tool or its parameters aren't loaded, search for the Plain help-center upsert tool first to confirm the current shape — the upsert typically wants the help center ID, a title, the Markdown body, and often an article group; if a group is required, list the available groups (`Plain:getHelpCenterArticleGroups`) and pick the best fit or ask which one.

If publishing fails, hand the user the full article Markdown so they can paste it in manually, and report the exact error.

### Report back

Confirm it published, share the URL or identifier Plain returns, and suggest quick follow-ups: verify formatting in Plain, add screenshots if the feature is visual, and link to the article from relevant spots in the product.

---

## Phase 4: Announce in Slack

Only after the article is live (and only if the user didn't choose "publish only"), post to **`#product-updates`** (channel ID `C0AE3MSQ6L8`) with `Slack:slack_send_message`.

Compose the message for the *team*, not end users:

1. Lead with the checkered-flag emoji and a bold title — `:checkered_flag: *New Help Center Article: {Feature Name}*`
2. A **TL;DR** — 1-2 sentences on what the feature is and why it matters to us
3. A **link** to the article — `https://glade-ai.support.site/article/{slug}`
4. A note that it'll start showing up in **Sidekick suggested responses**, so everyone should get familiar with the feature

If the Slack tool isn't connected, hand the user the composed message so they can post it themselves.

---

## Error Handling

- **No Linear context** — fall back to asking the user to describe the feature.
- **No GitHub PRs** — proceed on Linear alone; descriptions and comments usually carry enough.
- **Plain not connected / publish fails** — give the user the article Markdown and the error, and point them to reconnect the Plain connector.
- **Slack not connected** — provide the composed announcement for manual posting.
- **Thin context** — ask clarifying questions rather than inventing behavior. A wrong help doc is worse than a missing one.

## Example Triggers

- "write a help center article for this Linear project: https://linear.app/glade/project/document-templates-abc123"
- "document DEV-27520 for customers"
- "turn https://linear.app/glade/issue/GLA-789 into a help doc and publish it"
- "we shipped the new e-filing status view — can you write up a help article and announce it?"
