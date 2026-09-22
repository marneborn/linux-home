---
name: call1-recap-email
description: >
  Generate and send a warm, milestone-focused onboarding recap email after a Call 1 / kickoff call
  with a new Glade law firm client. Use this skill whenever someone shares a Granola meeting link
  and asks for a recap email, onboarding summary, or kickoff follow-up. Also trigger when someone
  says "send the Call 1 recap", "write the onboarding email", "follow up with [firm]", or pastes a
  notes.granola.ai URL in a context that suggests client onboarding. The skill pulls meeting notes
  from Granola, extracts firm-specific context (fee structure, state-specific requirements, workflow
  preferences), and drafts a personalized but consistently structured recap email. After approval, it
  sends via Gmail.
---

# Call 1 Recap Email

Turn a Granola meeting link into a warm, personalized onboarding recap email and send it via Gmail.

## Workflow Overview

1. **Fetch meeting notes** from Granola
2. **Draft the email** using the standard Call 1 template, personalized with details from the call
3. **Show the draft** and wait for approval or edits
4. **Send via Gmail**

---

## Step 1: Fetch Meeting Notes

Extract the meeting ID from the Granola URL (everything after `/t/`). Call `Granola:get_meetings` with that ID.

From the notes, extract:
- **Attorney name** (first name for salutation)
- **Firm name**
- **Fee structure** (attorney fees, filing fee, credit counseling, total, down payment, payment plan terms)
- **State** (for state-specific callouts, e.g., Colorado domestic support obligation worksheet)
- **Trustee / court specifics** (if mentioned)
- **Target launch date** (if mentioned)
- **Any preferences or customizations** mentioned (e.g., no rigid payment schedules, adding estate planning, case type switching)
- **Attendees** (to personalize the sign-off — include Glade team members who were on the call)

---

## Step 2: Draft the Email

Use the template below. Fill in `[BRACKETED]` fields with information from the meeting notes. Keep the tone warm, excited, and momentum-building — this email should make the attorney feel confident and supported, not overwhelmed.

**Key principles:**
- Lead with energy and warmth, not formality
- Reinforce that they can go at their own pace
- Highlight the "G to chat" tip prominently at the top — this is a priority
- Include firm-specific details wherever possible (fees, state, trustee quirks, preferences)
- The links are standard and the same for all firms — do not change them
- If the notes don't mention something (e.g., fee structure), omit that detail gracefully rather than leaving a placeholder
- Keep "Coming Up Later" milestones consistent — don't expand them based on the call

---

### Email Template

**Subject:** Glade Kickoff Recap – Your First 3 Milestones

---

Hi [FIRST NAME],

Great meeting with you today. We're excited to have you getting started in Glade, and I think we have a clear path for getting you launched with momentum. Like we discussed, take this at your own pace — we're standing by to help as you need.

First Thing – Chat with Us in Glade!

Press G anywhere in Glade to open a chat directly with our team. That's the fastest way to ask questions, flag anything, or get help while you're getting set up.

For this first phase of onboarding, we're going to focus on three core milestones:

1. Initiate intake with a client
2. Retain a client
3. Complete a document checklist

Here's a quick recap of what we covered and what to focus on next.

---

Milestone 1 – Initiate Intake with a Client

The goal here is to make it easy for prospective clients to book with you and begin the intake process through Glade.

- Connect your calendar so clients can book consultations based on your availability:
https://app.glade.ai/dashboard/account/edit-profile?

- Install the Intake Widget on your website when you're ready. Just click "Add Glade AI to my website" on this page and copy the code into your website's header:
https://app.glade.ai/dashboard/account/edit-profile?

- Quick tip: Press "B" anywhere in Glade to jump straight into Booking.

Once this is set up, prospective clients can start moving from your website into Glade much more seamlessly.

---

Milestone 2 – Retain a Client

Once a client is ready to move forward, Glade helps you send the retainer and invoice together in one clean step.

- Connect your bank account using the big green button on the Glade homepage.

- Review your Retainer Templates here: https://app.glade.ai/dashboard/terms-templates

- Review your Invoice Templates here: https://app.glade.ai/dashboard/terms-templates

[IF FEE STRUCTURE MENTIONED — include this block:]
A few notes from our call:

- Dynamic variables use {{brackets}} to automatically pull in details like client names, fee amounts, and other case-specific information.
- Your fee structure is currently set up around [ATTORNEY FEES] in attorney fees + [FILING FEE] filing fee + [CREDIT COUNSELING FEE] credit counseling, for a total of [TOTAL].
- You're planning to collect [DOWN PAYMENT] down, with a flexible payment plan for the remaining balance.

Because retainers and invoices are sent together, these two templates work closely together. Once they're dialed in, retaining a client should feel simple and consistent.

Quick tip: When ready, press "C" anywhere in Glade to create a Case and start the retaining flow.

---

Milestone 3 – Complete a Document Checklist with a Client

After the client is retained, the next milestone is getting their documents requested, uploaded, and reviewed.

- Review and customize your Document Checklist templates here:
https://app.glade.ai/dashboard/document-request-templates

You can set up different checklists by case type, like Chapter 7 or Chapter 13. [IF STATE-SPECIFIC REQUIREMENTS MENTIONED — add a sentence here, e.g.: "We'll also make sure the Colorado domestic support obligation worksheet is added where it belongs for your trustee meeting templates."]

Once documents are uploaded, Glade can help extract data, flag issues, and follow up with clients automatically by email and SMS — so the checklist doesn't become a manual chasing process.

---

Coming Up Later

Once these first three milestones are moving, we'll tackle the next ones together:

- Pull credit – We can help onboard your firm into CRS if you want to pull credit reports on behalf of clients.
- Prepare a petition – This can happen hands-on as you build your first petition in Glade.
- File a case – We'll help with PACER setup for MFA, eFiling, and Court Notices.

[IF LAUNCH DATE MENTIONED:]
Your target launch window is [LAUNCH DATE], and we'll work with you to make sure you're ready well before then.

Great first call today. Excited to get this moving.

[GLADE TEAM MEMBERS WHO WERE ON THE CALL]
& the Glade Team

---

## Step 3: Show the Draft and Wait for Approval

Present the full email draft in plain text (no markdown bold/italics — it doesn't render properly in Gmail). Tell the user: "Here's the draft — let me know if you'd like to change anything, or say 'send it' and I'll fire it off."

**STOP. Do not send until the user explicitly approves.** Approval means "send it", "looks good", "go ahead", or equivalent. Edits or questions are not approval.

---

## Step 4: Send via Gmail

Once approved, use the Gmail MCP to send the email.

- **To:** The attorney's email address (from Granola attendees)
- **Subject:** Glade Kickoff Recap – Your First 3 Milestones
- **Body:** The approved plain text email

After sending, confirm to the user: "Sent to [email address]!"

---

## Edge Cases

- **No fee structure in notes:** Skip the fee structure bullet block entirely. Don't leave placeholders.
- **No launch date mentioned:** Skip the launch date sentence.
- **No state-specific requirements:** Skip that sentence in Milestone 3.
- **Multiple Glade team members on call:** List all of them in the sign-off (e.g., "Marcus, Nate & the Glade Team").
- **Attorney email not in Granola attendees:** Ask the user for it before sending.
- **User wants to edit the draft:** Apply edits, show the revised version, and wait for re-approval before sending.
