---
name: fill-file-cabinet-v2
description: TEST VERSION of fill-file-cabinet — build or update a firm's "file cabinet" (the qualitative status page in the Notion Enterprise Success database) by exhaustively pulling live context from Glade (footprint, in-platform conversations, doc/intake status, case notes), Granola, Linear, Gmail, Plain, and Slack, then synthesizing it into a diagnosis of account stage, key players, and what actually needs to happen next — a deeper analytical pass than the original skill. Use only when explicitly asked for "fill-file-cabinet-v2", "file cabinet v2", or "the new/test version of the file cabinet skill" for a given firm. Do not trigger on generic "fill the file cabinet" requests — that should use the standard fill-file-cabinet skill unless v2 is explicitly named.
---

# Fill File Cabinet

Build or refresh a law firm's **file cabinet**: the qualitative, self-serve status page that lives as one row in the **Enterprise Success** database in Notion. This is the analytical layer — where the account actually stands, who's driving the relationship, and what's really blocking progress — not just a log of what happened. It's the counterpart to the live metrics on the Glade admin page and the items in Linear.

## Background (why this exists)

Decided with Marcus (6/22/2026):

- **Notion** holds the qualitative layer: written status, Granola call recaps, account pulse, active-matter tracking.
- **Glade admin page** holds live metrics: footprint, workflow counts, usage, Plain support history.
- **Linear** holds Linear items only.
- Driver: Sidekick/support can read Notion but not Linear, so prose belongs in Notion so the team can self-serve ("what's the latest on [firm]?") without pinging the account owner. It also leaves a paper trail if a firm churns.
- Each row in the **Enterprise Success** database = one firm. Enterprise firms are the priority (biggest cabinets). **Alliance Law** is the gold-standard format; **Adam Law Group** was the first build target.

The bar for a good cabinet: someone who has never touched this account should be able to read it and know (1) what stage the account is in and where it's headed, (2) who the people are and whether they're bought in, (3) the one or two things that actually determine whether this account grows or churns, and (4) what to do next. If a reader finishes the page and still has to go ask the account owner "so is this going well or not," the cabinet failed, no matter how many sources got checked.

## Key locations

- **Enterprise Success database:** https://app.notion.com/p/6aafbd305589420ba68b8a91c9c393ba
- **Enterprise Clients data source:** `collection://900b27b8-5a0d-434c-b244-3b731901e63d`
- **Format reference (gold standard):** Alliance Law | Virginia — `3515385b-f59e-8070-97be-c4ed60dfa7f2`

## Required tools

Load via ToolSearch before running:

- Glade footprint: `persons_me`, `organizations_list`, `services_list`, `user_workflows_list`, `invoices_list`, `customers_list`
- Glade direct signal (often skipped, don't skip it): `conversations_list` + `conversation_messages_list` (in-platform chat with the firm, frequently the most current friction signal), `documents_list` (doc collection status, esp. onboarding firms), `form_requests_list` (intake/questionnaire status), `user_workflow_notes_list` (internal notes logged against specific cases, where blockers often get written down informally)
- Granola: `query_granola_meetings` (call recaps, status) — pull the full meeting history for the firm, not just the latest call
- Linear: `list_projects`, `list_issues` — pull **both open and recently closed/done** issues. Closed issues show resolved momentum; open-only undercounts what's actually happened.
- Gmail: `search_threads`; Plain: `searchThreads`; Slack search — run multiple query angles per source (firm name, each known contact's name, and 2-3 topic keywords from context already gathered), not a single firm-name search. One query under-returns; this is the actual scraping gap.
- Notion: `notion-search`, `notion-fetch`, `notion-update-page`, `notion-get-users`

This runs the same way regardless of who's deploying it or which firm's cabinet is being built — it should work for any CSM on any account they have access to, not just specific portfolios.

## Process

### 1. Resolve the firm

- Confirm the Glade creator (id + slug) via `persons_me` / `organizations_list`.
- `notion-search` the firm name. If a page already exists in Enterprise Success, you're **updating**; if not, create a new row in the Enterprise Clients data source (or confirm with the user where it should live).

### 2. Gather context (exhaustively, in parallel — this is the step people shortcut, don't)

Run every applicable source below to completion before moving on. "One quick search" is not sufficient; if a source returns nothing useful, say so explicitly in the body rather than silently omitting it (silence reads as "not checked," not "nothing there"). As you go, keep a running note of two things that step 3 will need: every named person you encounter and what they said/did, and the date of everything — you can't reason about trajectory or staleness later if you didn't capture *when* something happened.

- **Granola** — full meeting history for the firm, not just the latest call. Recaps, action items, decisions across all calls on record. Note who spoke, what they asked for, and what tone they took, not just the topic list.
- **Glade in-platform conversations** (`conversations_list` / `conversation_messages_list`) — this is the firm's direct chat with Glade inside the product. Check it even if Gmail/Plain look quiet; it's frequently where the real-time friction lives and the other channels miss it.
- **Glade doc/intake status** (`documents_list`, `form_requests_list`) — for onboarding-stage firms, this tells you exactly what's blocking launch (missing docs, incomplete intake). For live firms it's usually a non-issue, skip the detail.
- **Glade case notes** (`user_workflow_notes_list`) — internal notes against specific cases. Worth a pass for firms with active churn risk or known case-level friction; skip for firms with no flagged cases to avoid noise.
- **Linear** — onboarding/expansion project, open LEG/DEV issues, AND recently closed/done issues (last 30-60 days). Closed issues are what changed; open-only tells half the story. Note any blockers.
- **Gmail / Plain / Slack** — multiple query passes per source: firm name, each known firm contact's name, and topic keywords surfaced from Granola/Glade/Linear (e.g. a specific feature, a specific case type, a recurring complaint). A single firm-name search misses threads where the contact emailed about something specific without using the firm name.
- **Glade footprint** — case counts (Ch7/Ch13), workflows, invoices, payments, team seats, onboarded date. (For pre-launch firms this is mostly 0, say so.)
- **Firm docs**, if provided — fee structure, districts, software, languages, contacts.

### 3. Synthesize before you write

This is the step that separates a real diagnosis from a data dump, and it's the one most easily skipped under time pressure. Do not go straight from "gathered everything" to "writing the page." Stop and work through these questions first, using evidence from step 2 — if you can't answer one with a specific fact, that's a real gap, and the cabinet should say so rather than paper over it with a vague sentence.

- **Where is this account, and where is it headed?** Place it on the stage ladder below. Is it moving toward the next stage, stalled, or sliding backward? What's the evidence for "moving" vs. "stalled" — a stalled account with a scheduled call next week is different from a stalled account that's gone silent for a month.
- **Who actually matters here, and what's their read?** Not a contact list — a cast of characters. For each person who showed up more than once across sources: their role, whether they're a champion, neutral, skeptical, or checked-out, and the one thing they clearly care about (cost, speed, a specific case type, a bad past experience, a feature they keep asking for). If the only contact you have is one paralegal who never responds, that itself is a finding — single-threaded accounts are a risk worth naming.
- **What's the one or two things that actually determine what happens next?** Every account has a real bottleneck — a missing signature, a partner who hasn't signed off, a feature gap, a support experience that soured them. Name it specifically. "Engagement is a bit mixed" is not a finding; "the managing partner loved the demo but their ops lead has ignored three follow-ups about the BAA, and that's the actual holdup on launch" is.
- **Do the sources agree?** When Gmail reads warm but a Plain thread from the same week reads frustrated, or a Granola recap says "all good" right before three Linear bugs got filed, that tension is the most useful thing in the cabinet — surface it explicitly rather than picking whichever source is more flattering or writing something vague enough to not contradict either.
- **What's actually new since the last update?** For refreshes, compare against the existing PULSE history. Don't re-report the same fact three weeks running as if it were news — either something changed (say what) or it didn't (say that plainly, briefly, and move on).

Write down short answers to these before drafting prose. They map directly onto the Stage, Key players, and Summary fields in step 5 — this isn't extra work on top of writing the page, it's the thinking the page is supposed to contain.

### 4. Account stage ladder

Use this shared vocabulary so cabinets are comparable across CSMs and accounts. Pick the stage that fits best and say so explicitly in the Stage field — don't leave it implicit in the health emoji.

- **Contracting** — deal signed or nearly signed, not yet in setup.
- **Onboarding** — docs, intake, and workflow configuration in progress; no live cases yet.
- **Activating** — first cases are live, firm is still learning the product, volume is low and inconsistent.
- **Steady-state** — regular case volume, workflows running with minimal friction, relationship is routine.
- **Expansion signal** — steady-state firm showing signs of wanting more (new case types, more seats, another office) — worth flagging even if nothing's been asked for yet.
- **At-risk** — real signal of dissatisfaction, disengagement, or a competitive threat, regardless of how healthy the metrics look.
- **Churned / churning** — actively winding down or gone.

An account can look "healthy" on volume and still be At-risk (a champion just left, or every recent touchpoint has been a complaint), and an account with zero cases can be a perfectly normal Onboarding — the stage is about trajectory and relationship quality, not just the numbers on the Glade dashboard.

### 5. Set page properties

Use `notion-fetch` first to read the exact schema, then `update_properties`. Typical fields: `Client`, `Tier` (Enterprise), `Priority` (P1–P3), `CSM` (people), `Bankruptcy Cases`, `Firm Notes` (one dense paragraph: who they are, status, this-week signals, blockers).

- Note: properties named `id`/`url` need the `userDefined:` prefix; people properties use `<mention-user url="user://...">` (look up IDs via `notion-get-users`).

### 6. Write the body (insert at `{"type":"start"}` so it sits above any inline Initiatives db)

Mirror the Alliance Law structure. Skip sections that don't apply (e.g., fee structure is normally viewable in the workflow editor — include it only when the firm is pre-launch or it's genuinely useful). The Summary and Key players sections are where the synthesis from step 3 has to actually show up — if they could have been written without doing step 3, step 3 didn't happen.

```
## 🟢/🟡/🟠 PULSE — <date> <label>
- 3–5 bullets: what happened, what's next, risk. Newest PULSE on top; keep prior PULSE entries below as a log.

**Stage:** <one of the ladder stages> — <trajectory: advancing / stalled / at risk, one clause on why>

**Status:** <emoji> <one line>

**Summary:** <2–4 sentences that diagnose, not describe — the bottleneck, the trajectory, and what would change it. A reader should learn something they couldn't get from the dashboard alone.>

## Key players
- <Name>, <role> — <champion / neutral / skeptical / checked-out>, cares about <specific thing>. <One clause of evidence.>
(repeat per person who's actually shown up in the evidence; note explicitly if the account is single-threaded)

## Snapshot
- Location / offices, Districts, Case types, Software, Languages, Volume on Glade, Contacts, Account team

## What's working   (live firms)  /  ## What's needed to launch  (onboarding firms)

## What's at risk   /  ## Open questions

## Top open items   — Linear issues as [LEG-123](url)

## Recent evidence  — dated Granola / Glade conversations / Gmail / Plain / Slack / Linear references with links. Flag any place sources disagreed with each other.

---
```

### 7. Verify

- Re-fetch the page; confirm properties + body rendered and all Linear links resolve.
- For updates: add a new dated PULSE block at the top rather than overwriting history.
- Reread the Summary and Key players sections on their own, without the rest of the page: could someone who's never seen this account tell you the stage, the bottleneck, and who to talk to? If not, go back to step 3 — the gathering was probably fine, the synthesis wasn't finished.

## Health emojis

🟢 Healthy · 🟡 Watch · 🟠 Onboarding/pre-launch or needs attention · 🔴 At risk

## Notes

- Keep it qualitative and skimmable — this is the prose layer, not a metrics dump. Link to the Glade admin page for live numbers.
- Gather exhaustively, write selectively: the cabinet stays a handful of dense sentences plus dated bullets, not a transcript of everything found. Cutting detail is fine; skipping a source because it's inconvenient to check is not — those are different failures and only one of them is acceptable.
- Always preserve prior PULSE entries (paper trail). Append, don't replace.
- Don't invent Linear IDs, URLs, names, or quotes — only use values and claims that trace back to something a tool actually returned. If you're inferring rather than quoting (e.g. reading disposition from tone), say "seems" or "reads as," not as flat fact.
