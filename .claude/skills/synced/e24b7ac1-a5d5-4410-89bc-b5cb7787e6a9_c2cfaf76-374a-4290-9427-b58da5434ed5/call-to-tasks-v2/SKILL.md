---
name: call-to-tasks-v2
description: >
  TEST VERSION of call-to-tasks — extract action items from Granola meeting notes and create Linear
  issues, with corrected triage/assignment behavior for Bug and Feature Request tickets (self-assign,
  no auto-priority, manual hand-off to on-call) per Mikael's feedback. Use only when explicitly asked
  for "call-to-tasks-v2", "call to tasks v2", or "the new/test version of the call-to-tasks skill".
  Do not trigger on generic "here are my call notes" / "process my meeting notes" requests — those
  should use the standard call-to-tasks skill unless v2 is explicitly named.
---

# Call-to-Tasks v2

Turn Granola meeting notes into triaged Linear issues in two steps: extract → approve → create.

## What changed in v2 (why)

On 7/6/2026, Mikael flagged (DM with Jude) that Bug tickets created from this pipeline were landing in his queue tagged as urgent, without going through triage first — he was doing them by default just because they showed up assigned to him. Working through it with Mikael, the agreed fix was:

- The skill should never decide urgency. A ticket creator should self-assign and sit in Triage until a human has actually looked at it and set a priority.
- Once priority is set, the ticket creator either unassigns it (so the on-call engineer, who watches the Triage bucket, picks it up) or assigns the on-call engineer directly.
- Mikael gets looped in only as a real escalation — not as the default landing spot for anything the skill happened to tag urgent.

v1 already defaulted `assignee` to `"me"` and never set a priority field, so the core mechanics were already close — but nothing in the skill said *why*, so it would have been easy for a future edit to "helpfully" add urgency auto-tagging back in and recreate the exact problem. v2 makes the reasoning explicit and adds the hand-off step v1 was missing: what happens *after* the issue is created, not just how it's filed.

## Workflow Overview

1. **Get the meeting notes** from Granola
2. **Extract and present tasks** for the user to review
3. **On approval, create Linear issues** on the Legal Ops team

---

## Step 1: Get the Meeting Notes

The user will typically share a Granola link like:
`https://notes.granola.ai/t/<meeting-id>`

Extract the meeting UUID from the URL. The ID is the path segment after `/t/`, it may include a suffix after the UUID (e.g., `2ae6dd89-3f2a-406d-a34b-00c5025cfd4c-008umkv4`). Try passing the full string to `Granola:get_meetings` first. If that fails, extract just the UUID portion (first 36 characters in standard UUID format).

Call `Granola:get_meetings` with the meeting ID to retrieve the full notes, summary, and attendees.

If the user doesn't share a link but says something like "process my last call", use `Granola:list_meetings` with `time_range: "this_week"` to find recent meetings, then confirm which one before proceeding.

## Step 2: Extract and Present Tasks

Read through the meeting notes and identify every actionable task. For each task, extract:

- **Law firm name**: Which client/firm the task is for (look for firm names mentioned in the notes)
- **Task title**: A concise, action-oriented title
- **Description**: What specifically needs to be done, with enough context from the notes
- **Due date**: If mentioned in the notes, use that date in ISO format. If no due date is mentioned, default to today's date so the user can triage it
- **Task type label**: The kind of work. Pick one: Bug, Customer Request, Configuration, Training, Feature Request, Onboarding, Follow-up, Investigation, Ops Task. See **Configuration vs. Training vs. Feature Request** below before reaching for `Feature Request`.
- **Triage label**: See rules below. Pick one: `triage:automate`, `triage:cleanup`, `triage:recurring-ops`, `triage:keep-manual`
- **Surface label**: See rules below. Pick one: `surface:customer` or `surface:internal`
- **Filing blocker?**: Yes / no / not sure — see **The `FILING BLOCKER` label** below. Most tasks are a clear no

### Triage label rules

- **`triage:automate`** — A repetitive move that happens on most or every firm. The kind of thing Glade should eventually do automatically. Examples: "follow up to confirm bank account connected," "pull credit report," "configure retainer agreement variables."
- **`triage:cleanup`** — A one-off backlog item we can knock out and be done. Does not recur. Examples: "upload Alliance Law's creditor list once," "migrate old cases for this one firm."
- **`triage:recurring-ops`** — Keeps happening but not worth automating yet, usually because it needs judgment or MCP writes aren't there yet. Examples: "build custom workflow threads for this firm," "configure post-filing notifications per firm."
- **`triage:keep-manual`** — Judgment calls, edge cases, anything that needs a human in a legal context. Examples: "judge-specific order formatting," "state-specific compliance review," "custom terms legal language review."

### Configuration vs. Training vs. Feature Request

Before labeling something a `Feature Request`, check whether it actually needs new engineering — many asks that sound like features are really configuration or training:

- **`Configuration`** — Can be set up today in the existing product with no new engineering. If the ask can be achieved by configuring the **questionnaire** (or other existing firm/workflow settings), label it `Configuration`, not `Feature Request`. Examples: adding a Y/N question to the questionnaire and mapping its answer onto a form/schedule (e.g., a "was this property repossessed?" flag feeding the SOFA, or a "lawsuit on this creditor?" question feeding SOFA 9), or changing where a section prints when that's a configurable option.
- **`Training`** — The product already does this; the firm just needs to be shown how. No build and no config change — just demonstrate it (a Loom or a walkthrough). Example: showing a firm how to add a non-filing spouse (Debtor 2) income organizer via the three-dot menu.
- **`Feature Request`** — Genuinely needs new engineering or product work; it can't be done through configuration or training today. Only these get routed to a project.

**Routing — two types go to a triage project instead of the Legal Ops backlog, and skip the triage labels (keep the surface label):**

- **`Bug`** (a clear, obvious platform bug) → apply the `Bug` label, set the **project** to **CX Requests**, and set the issue **status** to **Triage**. If it's unclear whether something is really a bug, leave it as a normal task and flag it instead.
- **`Feature Request`** (genuinely needs new engineering) → apply the `Feature Request` label and set the **project** to **CX Feature Request Triage**.

**Never set a priority field on any issue** (no "Urgent," "High," etc.), and especially not on Bug or Feature Request issues. Priority is a judgment call a human makes after looking at the actual problem — not something to infer from the meeting notes. This is the exact mistake v1 avoided by omission but never explained: an issue that ships pre-tagged urgent skips triage entirely and lands straight in whoever it's assigned to, which is what happened to Mikael. See **Step 3c** for what happens to Bug/Feature Request issues after creation.

Every other type — `Configuration`, `Training`, `Onboarding`, `Follow-up`, `Investigation`, `Ops Task`, `Customer Request` — is normal onboarding/ops work: give it the usual triage + surface labels, no project, and default (Backlog) status.

### The `FILING BLOCKER` label

`FILING BLOCKER` (exact name, all caps) is an **additional** label alongside the task type — never a replacement. It means one narrow thing:

> **The firm cannot get a filing to the court because of the thing this task is about.**

**This is not priority in disguise — read this before applying it.** Everything above says the skill must never infer urgency from meeting notes, and that rule stands. `FILING BLOCKER` is compatible with it because it's a different kind of claim: *the firm cannot file* is a fact about their situation, checkable and falsifiable. *This is Urgent* is a judgment about what someone should work on next. The label hands the triager better evidence; it does not make the triage call for them. Concretely, that means:

- **Still never set `priority`** — not even on a confirmed blocker. No exceptions, same as before.
- **Still no urgency inference.** "ASAP," "this is killing us," an escalated tone — none of that is evidence of a blocked filing. If the label starts landing on tickets because a call sounded heated, it has become the auto-priority behavior v2 was written to delete, just wearing a different name.
- **Routing, assignment, and hand-off are unchanged.** A blocker still self-assigns, still sits in Triage, still hands off per Step 3c. It does not go to Mikael by default.

**The test — all three must hold:**

1. **It's filing that's blocked** — submitting a case to the court, or a hard prerequisite for it. Not intake, doc collection, client comms, or anything post-filing.
2. **This task is the cause** — not a separate known issue, a court outage, or something on the firm's end.
3. **There's no way through** — not slower, not clunkier. If a workaround still gets the filing out, it isn't a blocker; put the workaround and its cost in the description.

A hard external deadline (foreclosure sale, garnishment, court-set date) belongs in the description but does **not** satisfy the test on its own.

**Any task type can qualify except `Training`.** A `Bug` can block filing; so can a `Configuration` task the firm can't file without, or a true `Feature Request` for something a district requires. `Training` essentially never qualifies — if the product already does it and the firm just needs to be shown how, filing isn't blocked.

**Meeting notes are weak evidence.** They're paraphrased, second-hand, and compressed. "They've been having trouble filing" doesn't clear the bar. What does: someone stated plainly that the firm can't file, or that cases are sitting unfiled waiting on this. Reading between the lines means you're at "not sure."

**Three outcomes per task:**

- **Clear yes** → mark it, with a one-line reason ready, quoting the notes where possible.
- **Clear no** → leave it off, say nothing. This is most tasks.
- **Not sure** → **ask the user.** Never apply on a hunch, never silently drop it. Batch these into the confirm block under the table (below). The user was on the call; they can usually answer in a word.

### Surface label rules

- **`surface:customer`** — An attorney or paralegal touches it, or would touch it in the automated version. Customer-facing in any way.
- **`surface:internal`** — Only Glade staff touches it. Internal tooling, ops scripts, data fixes.

If customer-facing AND `triage:keep-manual`, this is the Phase 2 agent shortlist. Tag both.

### Size label (do not auto-apply)

Do not apply `size:S`, `size:M`, or `size:L`. These are dev effort estimates that only Marcus can size accurately. Leave them for manual assignment.

### Present the tasks

Before creating anything in Linear, show the user a compact table so they can scan and edit first — one row per task:

```
| # | Title | Type | → Routes to | Status | Due |
|---|-------|------|-------------|--------|-----|
| 1 | [Firm Name]: [Task Title] | [swatch] [Type] | [routing] | [status] | [due] |
```

- **Type**: lead the cell with the label's color swatch emoji, then the task type — e.g. `🟥 Bug`, `🟪 Feature Request`, `🟨 Training`, `🟪 Configuration`, `🟦 Ops Task`. (Swatches are approximate — the legend carries the exact hex.)
- **→ Routes to**: `CX Requests` for Bugs, `CX Feature Request Triage` for Feature Requests, otherwise `Legal Ops backlog`.
- **Status**: `Triage` for Bugs, otherwise `Backlog`.
- **Due**: short date (e.g. `Jun 12`).
- **Filing blockers**: prefix the title cell with `🚨` for any task confirmed as a blocker. Don't add a column — a whole column of empty cells for a label that should be rare is exactly the wrong emphasis.

Directly under the table, add a **label-color legend** for the types that appear — swatch · name · hex (pull the hex from the label list in Step 3a):

- 🟥 **Bug** — `#EB5757`
- 🟪 **Feature Request** — `#5e6ad2`
- 🟨 **Training** — `#FACC15`
- 🟪 **Configuration** — `#9B51E0`
- 🟦 **Ops Task** — `#56CCF2`

Then in one line below the legend: state the **assignee** (default `me` unless the user says otherwise), and note that **triage + surface labels are still applied to every issue** per the label rules above — they're just kept out of the table for legibility. Flag any ambiguous item in a short "(confirm: …)" line under the table. For any Bug or Feature Request rows, add a one-line note that they'll be self-assigned and left unprioritized pending manual triage (see Step 3c) — the user should see this before approving, not discover it after.

Any **not sure** filing-blocker calls go in that same confirm block, grouped together and phrased as answerable questions — e.g. *"(confirm: #3 Ridley template — stopping them filing, or can they file with the old one?)"*. One block, not scattered per-row. If a task is a confirmed blocker, add a one-line note that it's getting the `FILING BLOCKER` label and why, so the user can veto it before it's created rather than after.

After presenting the table, ask: "These look right? I can change the title, type, routing, assignee, or due date — or add/remove any task — before I create them in Linear."

**STOP. Do not proceed to Step 3 until the user gives explicit approval.** Approval means a clear "yes," "looks good," "create them," or equivalent. Silence, follow-up questions, or edits are not approval. If the user asks to modify tasks, apply the edits and re-present the full table, then wait again for explicit approval.

A blanket "yes, create them" is approval to create, but it is **not** an answer to an open filing-blocker question. Ask those once more, briefly. If the user doesn't want to resolve it, create the task **without** the label and put the open question in its description — don't hold up the batch, and don't apply the label by default.

## Step 3: Create Linear Issues

Once the user approves:

### 3a: Ensure labels exist

Before creating issues, check that each label exists on the Legal Ops team. Use `Linear:list_issue_labels` with `team: "Legal Ops"` to get the current labels. For any label that doesn't exist yet, create it with `Linear:create_issue_label` using these color defaults:

**Task type labels:**
- Bug → `#EB5757` (red)
- Customer Request → `#2F80ED` (blue)
- Feature Request → `#5e6ad2` (indigo)
- Onboarding → `#27AE60` (green)
- Configuration → `#9B51E0` (purple)
- Training → `#FACC15` (yellow)
- Follow-up → `#F2994A` (orange)
- Investigation → `#F2C94C` (yellow)
- Ops Task → `#56CCF2` (light blue)
- Any other → `#828282` (gray)

**Triage labels:**
- triage:automate → `#27AE60` (green)
- triage:cleanup → `#F2C94C` (yellow)
- triage:recurring-ops → `#F2994A` (orange)
- triage:keep-manual → `#EB5757` (red)

**Surface labels:**
- surface:customer → `#2F80ED` (blue)
- surface:internal → `#9B51E0` (purple)

Set the `teamId` to the Legal Ops team ID. Only create labels that are missing, don't recreate ones that already exist.

**Never create `FILING BLOCKER`.** It already exists as a workspace-level label (id `09767732-d17b-43b5-b308-2a997b68f803`), so it's usable on Legal Ops without being created there and will appear in the team's label list. Pass it by exact name — all caps, one space. A team-scoped duplicate or variant spelling would silently split every filing-blocker view in the workspace.

### 3b: Create the issues

Create each task as a Linear issue using `Linear:save_issue` with these parameters:

- **title**: `"[Firm Name]: [Task Title]"` e.g., "Van Horn Law Group: Fix document generation timeout"
- **team**: `"Legal Ops"`
- **assignee**: `"me"` — for every issue, including Bug and Feature Request. This is a deliberate self-assign, not a default to skip over: it's what keeps the ticket with the person who filed it until priority is actually assessed, instead of it landing on whoever the skill feels like routing it to.
- **priority**: do not set this field at all. Leave it unset for every issue, no exceptions.
- **dueDate**: The ISO date from Step 2
- **labels**: An array with the task type label, the triage label, and the surface label from Step 2 (e.g., `["Configuration", "triage:automate", "surface:customer"]`). For `Bug` and `Feature Request` items, skip the triage label (they route to a project instead) but keep the surface label. Add `"FILING BLOCKER"` for any task confirmed as a blocker — e.g. `["Bug", "surface:customer", "FILING BLOCKER"]`. `labels` replaces the entire set, so pass every label in one array
- **priority**: do not set this field at all. Leave it unset for every issue, no exceptions — including confirmed filing blockers. The label is the signal; priority remains a human call made after someone looks at it
- **project**: For `Feature Request` items set to `"CX Feature Request Triage"`; for `Bug` items set to `"CX Requests"`. Omit for all other task types.
- **state**: For `Bug` items, set to `"Triage"`. Leave default (Backlog) for all other task types.
- **description**: The task description in Markdown, with a link back to the Granola notes at the bottom:
  ```
  [Description from Step 2]

  ---
  Source: [Meeting title](granola-link-url)
  ```
- **links**: Include the Granola URL as a link attachment: `[{url: "https://notes.granola.ai/t/...", title: "Granola Meeting Notes"}]`

Create the issues one at a time.

### 3c: Hand off Bug and Feature Request issues correctly

This is the step v1 didn't have, and its absence is what caused the problem with Mikael. Creating the issue is not the end of the job for Bug and Feature Request tickets — they need an explicit next step, or they'll just sit self-assigned and unprioritized forever, which is its own failure mode.

In the final summary (below), for every Bug or Feature Request issue created, tell the user directly:

> These are self-assigned to you and unprioritized in Triage. Once you've looked at [issue] and know how urgent it actually is, either unassign it (the on-call engineer watches the Triage bucket) or assign it straight to whoever's on call. Only loop in Mikael if it's a genuine escalation — not as the default landing spot.

Don't try to guess who's on call or auto-assign anyone else — that determination belongs to the user, per Mikael's explicit ask. The skill's job is to make sure the *reminder* happens, not to make the triage call itself.

After all issues are created, summarize what was created with the Linear issue identifiers (e.g., `LEG-123`) so the user can reference them, followed by the Bug/Feature Request hand-off reminder above if any were created.

## Edge Cases

- **No firm name identifiable**: If a task isn't clearly tied to a specific firm, use "Internal" as the prefix instead
- **Multiple firms in one meeting**: This is common, just tag each task with the correct firm
- **Vague action items**: If the notes mention something that might be a task but is ambiguous, include it in the list but flag it with a note like "(confirm if needed)" so the user can decide
- **No tasks found**: If the meeting notes don't contain clear action items, say so and offer to pull up the transcript via `Granola:get_meeting_transcript` for a deeper look
- **Configuration / training vs. feature request**: Before filing a `Feature Request`, check whether the ask is really `Configuration` (doable today via the questionnaire or existing settings) or `Training` (the product already does it; the firm just needs to be shown how) — see "Configuration vs. Training vs. Feature Request" above. Only a true feature request gets the `Feature Request` label and the `CX Feature Request Triage` project; configuration and training keep normal triage/surface labels and no project.
- **A whole call about a blocked firm**: When a firm is genuinely stuck, one call can produce several tasks touching the blockage. The label goes on the task that actually blocks filing, not on all of them. If you can't tell which, that's one question to ask, not five labels to apply
- **Filing blocker vs. urgency creep**: `FILING BLOCKER` is the one severity-adjacent signal this skill may apply, and only on the three-part test. If you find yourself reaching for it because a call sounded tense, or because a firm is important, stop — that's auto-priority rebuilt under a new name. Uncertain always resolves to asking the user, never to applying it
- **Transcript check before asking**: If the notes are too compressed to tell whether filing is blocked, `Granola:get_meeting_transcript` often contains the actual exchange. Worth a look before putting the question to the user
- **Don't reintroduce auto-priority**: If a future edit to this skill is tempted to add automatic urgency detection (e.g., "mark as Urgent if the notes say 'ASAP'"), don't — that's the exact behavior this v2 was written to remove. Priority is always a manual, post-creation call.
