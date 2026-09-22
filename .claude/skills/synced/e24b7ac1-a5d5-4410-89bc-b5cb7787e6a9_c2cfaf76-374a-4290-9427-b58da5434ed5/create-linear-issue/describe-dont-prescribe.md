# Describe, Don't Prescribe — the CX issue-writing standard

The one rule: **we describe the problem and what "fixed" feels like to the customer. Dev owns the
diagnosis and the solution.** None of us — CX, the customer, or an agent — is the engineer, so the
ticket shouldn't pretend to be one.

Full guide (Notion): https://app.notion.com/p/3a65385bf59e81f18d8ece9e93c0c8f1

## Why it matters

When a ticket tells dev *what to build* ("add these values to the filter"), it quietly does the
engineering diagnosis for them. If the guess is wrong, dev either builds the wrong thing or has to
reverse-engineer what CX actually meant. A good issue transfers **what the customer experienced and
why it matters**, then gets out of the way on the *how*.

In one line: **symptoms + impact + who reported it + what good looks like** — not a spec.

## The five moves

1. **Title names the problem, not the fix.** `Van Horn: can't filter cases by status through the
   MCP` — not `Add status values to the workflow filter`.
2. **Open with the job-to-be-done.** What was the customer trying to accomplish, in their terms —
   not the mechanism you suspect is broken.
3. **Separate observation from conclusion.** What CX can stand behind (repro steps, exact values,
   screenshots) is observation. Anything about the *cause* is a conclusion — flag it as a guess or
   attribute it to the customer. Conclusions stated as facts are how tickets mislead.
4. **Attribute customer-relayed claims.** "Chad reports…", "she observes…" — don't launder the
   customer's account into asserted fact. Never state an engineering root cause unless a dev
   confirmed it.
5. **Describe the destination, not the route.** Say what a good outcome feels like to the customer,
   including properties that must hold ("doesn't fail silently"). A genuinely useful fix idea can be
   included — labeled a *suggestion*, never the spec.

## The subtle move that matters most

Separate observation from conclusion. "She gets zero results filtering on `docs-stage`" is an
observation CX can stand behind. "The filter only accepts these five values" is a conclusion — so it
gets attributed to the customer, not asserted by the ticket. Guesses that turn out shaky shouldn't be
wearing the ticket's own voice.

## Pre-flight checklist

Run this against the draft **before** the approval step.

**Framing**
- [ ] Title names the problem, not a proposed solution.
- [ ] Opens with what the customer is trying to do, not the mechanism they think is broken.

**Facts vs. guesses**
- [ ] Every claim is either something observed or clearly marked as an inference.
- [ ] Customer-relayed claims are attributed ("they report…"), not stated as fact.
- [ ] No engineering root cause is asserted unless a dev confirmed it.

**No prescription**
- [ ] No "Requested fix: change X to Y." Instead there's a desired outcome.
- [ ] Any fix idea that's useful context is labeled a suggestion, not the spec.

**Enough for dev to start**
- [ ] Repro steps or the exact values/inputs used are included.
- [ ] Impact is clear enough to prioritize (blocking? workaround exists? silent failure?).
- [ ] If the firm genuinely can't file because of this, that's stated plainly in the body — and the
      `FILING BLOCKER` label decision matches what the body says. If it's unclear whether filing is
      blocked, that's a question for the requester, not a guess.
- [ ] Any silent or misleading behavior is called out explicitly, not buried.
- [ ] Source + channel + related issues are linked.

**Gut check**
- [ ] A dev reading this cold knows *what's wrong* and *what "fixed" feels like to the customer* —
      without being told *how to build it*.
