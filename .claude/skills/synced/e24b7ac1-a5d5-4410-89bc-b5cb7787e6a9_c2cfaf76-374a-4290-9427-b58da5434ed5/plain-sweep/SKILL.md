---
name: plain-sweep
description: >
  Mark Plain threads as Done to keep the inbox clean and metrics accurate. Two modes: (1) TARGETED: "mark [name] done in Plain", "close the Plain thread for [name]", "mark [name] done". (2) SWEEP: "sweep Plain", "clean up Plain", "check for orphan threads", "Plain sweep", "sweep orphans", batch-mark outbound CC'd threads as Done. Trigger aggressively on ANY indication the user wants to mark Plain threads as Done, whether by name or in batch. Also trigger when the user just sent an email with support@glade.ai CC'd and wants the resulting Plain thread handled. Core problem: outbound emails with support CC'd create orphan threads in Plain that muddy metrics. These need to be marked Done so they reopen naturally on client reply.
---

# Plain Sweep: Thread Cleanup Tool

Mark Plain threads as Done to keep the inbox clean and metrics accurate. Two modes: targeted (one thread by name) and sweep (batch cleanup of orphan outbound threads).

## Required Tools

Before running, call `tool_search` to load:

- `Plain:searchThreads` (find threads by text content)
- `Plain:getThreads` (filter threads by status/statusDetail)
- `Plain:getThreadDetails` (inspect timeline to determine if thread is outbound-initiated)
- `Plain:markThreadAsDone` (mark thread as Done)

## Mode 1: Targeted Mark-as-Done

Use when the user names a specific person, firm, or thread.

### Workflow

1. **Parse the target** from the user's message. Could be a client name, firm name, email subject, or Plain thread ID.

2. **Find the thread**:
   - If a thread ID is provided (starts with `th_`), use `Plain:getThreadDetails` directly.
   - Otherwise, use `Plain:searchThreads` with the name/subject as the query. Filter to `statuses: ["TODO"]` to avoid touching already-resolved threads.

3. **Confirm if ambiguous**: If the search returns multiple matches, present them to the user and ask which one. If exactly one match, proceed.

4. **Mark as Done**: Call `Plain:markThreadAsDone` with `statusDetail: "DONE_MANUALLY_SET"`.

5. **Report**: Tell the user which thread was marked Done (ref number, title, customer name).

### Example interaction

User: "mark the Plain thread for Warren as done"

Steps:
- `Plain:searchThreads(searchQuery: "Warren", statuses: ["TODO"])` 
- Find the matching thread
- `Plain:markThreadAsDone(input: {threadId: "th_...", statusDetail: "DONE_MANUALLY_SET"})`
- Report: "Marked T-6914 (Re: Glade setup, Warren Uthe) as Done."

## Mode 2: Sweep (Batch Orphan Cleanup)

Use when the user asks to sweep, clean up, or batch-process Plain threads.

### What qualifies as an "orphan" thread

An orphan is a thread that was created by an outbound email from a Glade team member (sent from their personal inbox with support@glade.ai CC'd). These threads land in Plain in a CREATED/TODO state and should be immediately marked Done so they reopen naturally when the client replies.

### Detection signature

A thread is an orphan if ALL of these are true:
1. Status is `TODO`
2. Status detail is `CREATED` (thread has never been interacted with in Plain)
3. The first timeline entry is an `EmailEntry` where `from.email` ends in `@glade.ai`

Threads where the first email is FROM an external address (a client writing in) are real inbound support requests and must NOT be touched.

### Workflow

1. **Pull candidate threads**: `Plain:getThreads(statuses: ["TODO"], statusDetails: ["CREATED"])` to get all untouched TODO threads.

2. **Inspect each candidate**: For each thread, call `Plain:getThreadDetails` and check the timeline. Look at the LAST timeline entry (earliest chronologically, since timeline is newest-first). If it is an `EmailEntry` with `from.email` ending in `@glade.ai`, it's an orphan.

3. **Present findings to the user**: List all orphan threads found with their ref, title, customer name, and the Glade sender. Also list any non-orphan CREATED threads (real inbound) so the user can see what was skipped and why.

   Format:
   ```
   ORPHANS (will mark as Done):
   - T-XXXX: "Subject" (Customer Name, sent by sender@glade.ai)

   SKIPPED (real inbound, not touching):
   - T-YYYY: "Subject" (Customer Name, from client@example.com)
   ```

4. **Get confirmation**: Ask the user to confirm before marking any threads as Done. Never auto-execute the batch without confirmation.

5. **Execute**: For each confirmed orphan, call `Plain:markThreadAsDone(input: {threadId: "th_...", statusDetail: "DONE_MANUALLY_SET"})`.

6. **Report**: Summarize what was done, how many threads marked, how many skipped.

### Edge Cases

**Empty sweep**: If no orphan threads are found, report "Plain inbox is clean, no orphan threads found." This is a good outcome, not an error.

**Mixed results**: Some CREATED threads may be real inbound (client emailed support directly). The `from.email` check prevents these from being marked Done. Always show the user what was skipped.

**Thread already assigned**: If a CREATED thread is assigned to someone, it might have been claimed intentionally. Flag it to the user but still include it in the orphan list if it matches the signature, since assignment alone does not mean it is being worked.

**Large batch**: If there are more than 10 orphan threads, still present them all but warn the user about the volume before executing.

## Key Behaviors

- Never mark a thread as Done without either (a) the user naming it specifically, or (b) the user confirming a sweep list.
- Always use `statusDetail: "DONE_MANUALLY_SET"` (not IGNORED, which would prevent the thread from reopening on client reply).
- The whole point is that Done threads reopen on the next client reply. IGNORED threads do not. This distinction is critical and is the entire reason this skill exists.
