---
name: create-linear-issue
description: >
  Turn a single Plain ticket or a plain-language problem description into ONE beautifully written,
  well-triaged Linear issue using the CX issue templates. Use this whenever someone hands you a Plain
  thread URL (app.plain.com/.../thread/th_...) or describes a customer problem and wants it filed in
  Linear — phrases like "file this as a Linear issue", "make a bug report from this ticket", "log a
  feature request for this", "turn this Plain thread into a Linear issue", "write this up for dev", or
  just pastes a Plain link with a note like "bug for this". The skill classifies the input (feature
  request / bug report / configuration change / other), fills the matching CX template, writes it to
  the "Describe, Don't Prescribe" standard, and — after your approval — creates it in Linear with the
  correct team, project, label, and triage state. This is for ONE issue from ONE ticket or description;
  for turning meeting notes into many tasks, use call-to-tasks instead.
---

# Create Linear Issue

Turn a Plain ticket or a problem description into one well-formed, well-triaged Linear issue.

The whole point is to take messy input — a customer's frustrated email, a half-formed Slack complaint, a paragraph of notes — and produce an issue a developer can pick up cold and understand: **what's wrong, why it matters, and what "fixed" feels like to the customer** — without telling them how to build it.

The pipeline is: **understand → check the firm's file cabinet → classify → draft → approve → create → link back to Plain → report.**

## Workflow Overview

1. **Understand the input** — a Plain thread URL, or a written description
2. **Check the firm's file cabinet** in Notion — account context, and especially whether they're on Alpha (where parity gaps live)
3. **Classify** it — feature request, bug report, configuration change, or other — and decide whether it also earns the `FILING BLOCKER` label
4. **Draft** the issue into the matching template, written the Glade way
5. **Get explicit approval** — nothing goes into Linear without a clear yes
6. **Create** the issue with the right team, project, label, and triage state
7. **Link the new issue back to the Plain thread** — if the source was a Plain ticket
8. **Report back** with the issue identifier and URL

---

## Step 1: Understand the Input

The argument is one of two things:

- **A Plain ticket URL** — looks like `https://app.plain.com/workspace/w_.../thread/th_...`. Extract the thread ID (the `th_...` segment) and call `Plain:getThreadDetails` with `threadId` set to it. Read the full timeline: the customer's own words, what they were trying to do, any back-and-forth, screenshots, error text, and which firm/customer it's tied to. The customer's actual phrasing is gold — you'll attribute claims to them later.
- **A written description** — a paragraph, a pasted Slack message, a few bullet points. Work from what's there.

If the input is thin (a one-liner with no detail), don't invent facts. Note what's missing and either ask a quick clarifying question or flag the gaps in the draft so triage knows what to chase. A vague-but-honest issue beats a confident-but-wrong one.

Also capture, wherever it lives in the input: **the firm/customer name**, **who reported it**, **the source link** (Plain thread, Slack thread), and **any related Linear issues** mentioned.

## Step 2: Check the Firm's File Cabinet

Before drafting, look up the firm in Notion. Glade tracks firms in **file cabinets** — living status pages (account health, key contacts, CSM/account owner, open Linear items, recent PULSE notes) that routinely contain context that changes how an issue should be written. They all live under one home page, **Firm File Cabinets** (`https://app.notion.com/p/38f5385bf59e81828f1acf039bc03dad`) — start there. Under it are three databases, and a firm may be in any one depending on its tier:

- **Enterprise Accounts** — Enterprise + Semi-Enterprise firms (full cabinets)
- **Mid-Market Accounts** — mid-market firms (condensed cabinets; top semi-enterprise get full builds)
- **Solo Accounts** — solo firms

**How to find it:** `Notion:notion-search` for the firm name (e.g. `"Van Horn file cabinet"`), then `Notion:notion-fetch` the firm's page — search spans all three databases, so you don't need to know the tier first. If nothing turns up, the firm may be a condensed Mid-Market/Solo cabinet or simply not tracked yet — note that and proceed. The check is best-effort and never blocks; cabinet depth varies, so pull what's there and move on.

**What to pull out, and why it matters:**

- **Alpha vs. Beta.** This is the big one. "Alpha" is Glade 2.0 — the reimagined monorepo UI — rolled out firm-by-firm and team-by-team. Alpha still has **parity gaps** vs. Beta, so a feature that "used to work" or "doesn't work" may be an Alpha parity gap rather than a true regression. Check whether the firm is on Alpha, which teams are, and whether the reporter specifically works in Alpha or Beta. Feed this into the **Environment** field, and let it shape the framing (a parity gap reads differently than a Beta regression). If the cabinet is silent on the reporter's surface, say so and flag it for triage to confirm — don't assert one.
- **Related / duplicate Linear issues.** Cabinets list open items and recent tickets. If the problem overlaps an existing issue, note it in **Other Evidence** so triage can link or dedupe rather than open a parallel ticket.
- **Account weight and health.** Tier, priority (e.g. P0), and whether this is a high-volume or at-risk account — useful context for the Summary's impact framing (but still don't set Linear priority; that's triage's call).
- **Key people and the account owner.** The CSM and the firm's main contacts — helpful for attributing the report and knowing who triage will loop in.

Everything from the cabinet is **context, not customer-reported fact**. Anything you infer from it (e.g. "likely on Beta") gets flagged as an inference, per the "Describe, Don't Prescribe" standard — never laundered into asserted fact in the issue.

## Step 3: Classify

Decide which of these the input is. This drives the template and the routing:

| Classification | Template | Team | Project | Label | State |
|---|---|---|---|---|---|
| **Feature request** — a new capability, enhancement, or "can it also do X" | CX Feature Request | `Dev` | `CX Feature Request Triage` | `Feature Request` | `Triage` |
| **Bug report** — something is broken, erroring, or behaving wrong | CX Bug Report | `Dev` | `CX Requests` | `Bug` | `Triage` |
| **Configuration change** — a firm/district/template setting needs adjusting | CX Bug Report | `Dev` | `CX Requests` | `Bug` | `Triage` |
| **Something else** — doesn't cleanly fit the above | CX Bug Report | `Dev` | `CX Requests` | `Bug` | `Triage` |

**Rule:** Feature requests use the Feature Request template. **Everything else defaults to the Bug Report template.** When it's genuinely ambiguous (a "bug" that's really a missing feature, or a config ask dressed up as a bug), pick the closer fit and say which you chose and why in your preview so the user can redirect you.

For a configuration change, still use the Bug Report template, but make the config nature explicit in the Summary (e.g. "Configuration change: …"). If the team already has a more specific label like `Configuration`, you may add it alongside `Bug` — check with `Linear:list_issue_labels` (team `Dev`) rather than inventing one.

### The `FILING BLOCKER` label

`FILING BLOCKER` (exact name, all caps, on team `Dev`) is an **additional** label that sits alongside `Bug` or `Feature Request` — it never replaces the classification label. It means one narrow thing:

> **The firm cannot get a filing to the court because of the thing this issue is about.**

This label is sensitive. It's the loudest signal CX can put on a ticket, and it only keeps that meaning if it's rare and accurate. Over-applying it is the failure mode — an inbox where a third of the tickets are filing blockers has no filing blockers.

**The test — all three must hold:**

1. **It's filing that's blocked.** The action the firm can't complete is submitting a case to the court, or a hard prerequisite for doing so (e.g. the petition or a district-required document can't be produced at all). Intake, doc collection, client comms, and anything post-filing are not filing.
2. **This issue is the cause.** The blockage traces to what you're writing up — not to a separate known issue, a court outage, or something on the firm's end.
3. **There's no way through.** Not "slower," not "annoying," not "takes three extra steps." If a workaround exists that still gets the filing out, it's not a blocker — describe the workaround and its cost in the body instead.

**On the third point:** if the only remaining path is to abandon Glade for that case and file by hand outside the platform, that's a judgment call, not a rule — treat it as uncertain and **ask** (see below).

A hard external deadline (foreclosure sale, garnishment, wage-order date, a court-set deadline) doesn't make something a blocker on its own, but it's worth stating in the Summary when it's present — it tells triage how much clock there is.

**Feature requests can be filing blockers too.** A capability that doesn't exist yet can block filing just as effectively as something broken — a district's required form Glade doesn't support, a plan provision that can't be expressed. Don't treat this as a bug-only label.

**Not filing blockers** (common near-misses):

- Filing works but is tedious — manual re-entry, extra clicks, copy-paste
- A form renders wrong but can be corrected before it goes out
- Post-filing problems — court notices not syncing, docket gaps, amendments
- A feature ask about future cases where nothing is currently blocked
- One user is blocked but a colleague at the firm can complete the filing
- The customer is upset or says "urgent" — tone is not evidence

**The evidence bar.** Apply the label only on something concrete in the input or the file cabinet: the reporter says they can't file or are stuck at the filing step, the failure happens at e-filing submission, or a required-for-filing artifact demonstrably can't be produced. Frustration, urgency, and escalation language are not evidence. As with everything else in this skill, don't launder an inference into a fact — if the blocker read is an inference, it's an inference.

**Three possible outcomes:**

- **Clear yes** → add the label, and in the preview say in one line what makes it a blocker, quoting the reporter's own words where you have them. Put the blocked-filing framing in the Summary too, so the body and the label agree.
- **Clear no** → don't add it, and don't raise it. No need to narrate a label you didn't apply.
- **Not sure** → **ask the person who asked you to file the issue.** Don't apply it on a hunch and don't quietly drop it either. In the preview, state what you'd add it for and the specific thing you don't know (e.g. *"Is Tracy stuck at submission, or can she still file this one manually?"*), then wait. Their answer decides it. Uncertainty resolves to a question, never to applying the label.

Uncertainty is the expected case more often than not — Plain threads rarely spell out whether a filing is truly stuck. Asking is cheap and it's the designed behavior here, not a failure to decide.

Read the matching template file before drafting:
- Feature request → `references/feature-request-template.md`
- Bug / config / other → `references/bug-report-template.md`

## Step 4: Draft the Issue

Fill the chosen template. The template gives you the **sections**; the "Describe, Don't Prescribe" standard governs **how you write inside them**. Read `references/describe-dont-prescribe.md` and hold to it — it's the difference between a ticket dev trusts and one they have to reverse-engineer.

The five moves that matter most:

1. **The title names the problem, not the suspected fix.**
   - ✅ `Van Horn: can't filter cases by status through the MCP`
   - 🚫 `Add status values to the workflow filter`
2. **Open with what the customer was trying to do** — the job-to-be-done in their terms — not the mechanism you think is broken.
3. **Separate what was observed from what you're concluding.** "She gets zero results filtering on `docs-stage`" is an observation you can stand behind. "The filter only accepts five values" is a conclusion — attribute it to the reporter or flag it as a guess. Never assert an engineering root cause unless a dev confirmed it.
4. **Attribute customer-relayed claims** — "Chad reports…", "she observes…" — don't launder them into stated fact.
5. **Describe the destination, not the route.** Say what a good outcome feels like to the customer (including properties that must hold, like "doesn't fail silently"). Leave the *how* to dev. If you have a genuinely useful fix idea, label it a *suggestion*, not the spec.

Fold in the file-cabinet context from Step 2: put the Alpha/Beta read into **Environment** (flagged as inference where it is one), add any overlapping existing issues to **Other Evidence**, and let account weight inform the impact framing in **Summary**. If the firm is on Alpha and the problem could be a parity gap, say so — it points triage at the right surface.

Fill in only the sections you have real content for. Delete sections that would just be "N/A" padding — an honest, shorter issue is better than a template with empty limbs. Always include the source (Plain thread link, who reported it, when) so dev can trace it back.

Turn the raw input into clean, scannable prose. Short sentences. Concrete values, exact error text, and repro steps where you have them. This is where "beautifully articulated" is earned.

## Step 5: Preview and Approve

Show the user the full drafted issue before touching Linear. Present:

- The **classification** you chose (and a one-line why, if it was a close call)
- The **routing** — team, project, label(s), triage state — in a compact line
- **The `FILING BLOCKER` call**, if it's in play — either "adding `FILING BLOCKER` because \<evidence\>" or the open question you need answered. Skip this line entirely when it's a clear no.
- The **title**
- The **full description** as it'll appear

Then ask, plainly: *"Want me to create this in Linear as-is, or change anything first?"*

**STOP here. Do not create the issue until the user gives a clear yes.** Edits, questions, and "hmm" are not approval — apply changes, re-show the draft, and ask again. If the user wants a different classification or template, switch and re-preview.

If you have an **open `FILING BLOCKER` question**, ask it here alongside the approval request and don't resolve it yourself. A plain "yes, create it" that doesn't answer the question isn't an answer to it — ask once more, briefly, before creating. Don't hold the issue hostage over it, though: if they tell you to file it without the label or to stop asking, file it without the label and note the open question in the body so triage can pick it up.

## Step 6: Create the Issue

Once approved, create it with `Linear:save_issue`:

- **title**: the problem-naming title from Step 4
- **team**: `"Dev"`
- **project**: the project from the routing table (`"CX Feature Request Triage"` or `"CX Requests"`)
- **labels**: `["Feature Request"]` or `["Bug"]`, plus `"FILING BLOCKER"` if Step 3 landed on a yes, plus any other label the user approved — e.g. `["Bug", "FILING BLOCKER"]`. The `labels` parameter **replaces** the whole label set, so pass every label you want in one array. Use the exact name `FILING BLOCKER` (all caps, one space); it already exists on team `Dev`, so never `Linear:create_issue_label` a variant of it.
- **state**: `"Triage"` — CX issues go through Triage Intelligence for team/assignee/priority routing
- **description**: the filled template in Markdown
- **links**: if there's a Plain thread, attach it — `[{url: "<plain-thread-url>", title: "Plain thread"}]`. Attach a Slack thread link too if you have one.

Do **not** set priority and do **not** assign the issue. CX issues land in Triage unprioritized and unassigned on purpose — priority, team routing, and owner are decided in triage (Linear's Triage Intelligence will suggest them). This matches both templates' default properties, and setting them here works against the "Describe, Don't Prescribe" principle that dev owns the diagnosis. Let the impact you described in the body speak for prioritization.

Two template fields behave differently through the MCP than in the form UI: the **Customer** picker renders as plain text (put the firm name under a `#### Customer` heading), and **Upload screenshots** can't accept files — reference where screenshots live (e.g. in the linked Plain thread) under Other Evidence instead.

## Step 7: Link the Issue Back to the Plain Thread

If the source was a Plain thread, link the newly created Linear issue back onto it so the customer ticket and the dev issue point at each other. (Skip this step entirely when the input was a plain-text description with no Plain thread.)

Call `Plain:createThreadLink` with the thread ID and the new issue:

```
input: {
  threadId: "<th_... from Step 1>",
  linearIssue: {
    linearIssueId: "<issue identifier, e.g. DEV-1234>",
    linearIssueUrl: "<the issue URL>"
  }
}
```

Notes:
- `linearIssueId` accepts the identifier (e.g. `DEV-1234`) — Plain resolves it to Linear's internal UUID itself, so you don't need to look the UUID up.
- This creates a `RELATED_TO` link that surfaces the issue (title + Triage state) under the thread's **Thread links**. It's internal metadata — it does **not** send anything to the customer — so it's safe to run automatically as the completion of the approved create; no separate approval is needed.
- It relies on the workspace's Machine-User Linear integration. If it fails with `workspace_linear_integration_not_found` (or any error), don't retry blindly — report that the link couldn't be created and give the user the issue identifier so they can link it by hand from the thread's "Link Linear issue" action.
- The Linear side already carries the Plain link (attached in Step 6), so together the two directions close the loop.

## Step 8: Report Back

Confirm it's created. Give the user the **issue identifier** (e.g. `DEV-1234`) and the **URL** so they can jump to it. Note that it's landed in Triage and will auto-post to `#cx` in Slack. If you attached a Plain thread, mention it's linked so the loop back to the customer is intact.

---

## Edge Cases

- **No firm/customer identifiable** — file it anyway; put "Not specified" in the customer field and flag it for triage to identify.
- **Plain thread won't load** — if `getThreadDetails` fails, tell the user, and offer to proceed from whatever description they can give you instead.
- **Multiple problems in one ticket** — a Plain thread can contain a bug *and* a feature ask. Point this out and ask whether to file separate issues (one per problem) or focus on one. Don't cram two unrelated problems into one issue.
- **Already prescriptive input** — if the customer or CX handed you "just add X to Y", don't pass the prescription through. Re-derive the underlying problem and desired outcome, and demote any fix idea to a labeled suggestion.
- **Urgent-sounding but not blocked** — heat in the customer's message is not evidence of a blocked filing. Reflect the urgency in the Summary's impact framing and leave `FILING BLOCKER` off.
- **Blocked, but by something already filed** — if the filing is stuck because of a *different, known* issue, this ticket isn't the blocker. Link the existing issue in Other Evidence and mention that the blocker label belongs there, not here.
- **Multiple problems, one of them blocking** — when you split a ticket into separate issues, the label follows the problem that actually blocks filing. Don't stamp it on all of them.
- **It shouldn't be a ticket at all** — a one-off user error that's already resolved and won't recur doesn't need an issue. Say so rather than filing noise.
- **Linear create fails** — hand the user the full title + description Markdown so they can paste it in manually, and report the exact error.

## Reference Files

- `references/feature-request-template.md` — the CX Feature Request template structure
- `references/bug-report-template.md` — the CX Bug Report template structure
- `references/describe-dont-prescribe.md` — the writing standard + pre-flight checklist

## Example Triggers

- "File this Plain thread as a bug: https://app.plain.com/workspace/w_01.../thread/th_01..."
- "Turn this into a Linear feature request — Washington Law Group wants the message block to be resizable"
- "Log a bug for this: renamed documents keep reverting to their original filename for Van Horn"
- "Make a Linear issue from this ticket for dev"
