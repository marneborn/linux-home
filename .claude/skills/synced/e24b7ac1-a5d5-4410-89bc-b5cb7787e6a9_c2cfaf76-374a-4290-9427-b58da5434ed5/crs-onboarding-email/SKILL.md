---
name: crs-onboarding-email
description: "Send the CRS B2B onboarding email to activate Direct Pull credit reports for a new Glade law firm. Use this skill whenever someone says \"onboard [firm] with CRS\", \"send the CRS email\", \"CRS onboarding for [firm]\", \"set up direct pull for [firm]\", \"send CRS docs for [firm]\", or references needing to send the CRS B2B onboarding email for any firm. Also trigger when someone says \"onboard [firm]\" in a context that implies CRS credit report setup (not general Glade onboarding). This skill should trigger aggressively: if there is ANY indication the user wants to send the CRS onboarding email or set up B2B/Direct Pull credit for a firm, use this skill. It gathers firm data from Glade, prompts the user to collect the required documents from the onboarding flow, drafts the email, and creates the Gmail draft for the user to attach documents to and send. The skill never reads, encodes, or attaches the CRS documents itself; document handling is always manual on the sender's end."
---

# CRS B2B Onboarding Email

Draft a single email to CRS, with the required documents attached manually by the sender, introducing a new law firm for Direct Pull (B2B) credit report activation.

## Why This Skill Exists

Every new Glade firm starts on the Client Approval (B2C) credit flow, which requires client consent before each pull. The Direct Pull (B2B) flow removes that step, letting attorneys pull credit instantly. Switching requires a one-time vetting process with CRS (Glade's third-party credit reporting partner). This email kicks off that process.

The email is a single message that does three things at once:
1. Introduces the firm to CRS operations (Patricia Gomez, Mario Cisneros)
2. Explains the process to the attorney(s) at the firm
3. Carries all 7 required documents, attached manually by the sender, so CRS can begin vetting immediately

**This skill never touches the documents themselves.** It tells the user what's required and where to get it, and creates the Gmail draft with the body and recipients set. Attaching the files is a manual step the sender does in Gmail before hitting send.

---

## Required Tools

Call `tool_search` to load these before running:

### Gmail
- `Gmail:create_draft` -- Create the email draft (body + recipients only; no attachments added by the skill)

### Glade Production MCP (primary source of firm data)
- `creators_list` / `creators_get` -- Firm profile (name, address, phone, website)
- `team_members_list` -- Attorney names and emails
- `customers_list` -- Cross-reference for contact info if needed

### Web Search (documented backup, not primary)
- `web_search` -- Use ONLY when a required field (address, phone, website, legal entity name) is missing or incomplete in Glade. This is a fallback for public firm information, not a substitute for Glade data, and it is never used to source anything client-personal (SSNs, case details, financial info). See "Firm Data Resolution Order" below for exactly when this tier applies.

---

## Workflow

### Step 1: Identify the Firm in Glade

Resolve the firm's creator ID. Check both sides:

```
creators_list(perPage: 100)
```

Match by firm name. If the creator ID is already known from memory, skip this.

Then pull firm details:
```
creators_get(creatorId: "<id>")
team_members_list(creatorId: "<id>")
```

Extract:
- **Firm name** (exact legal name as registered, not a DBA or shorthand)
- **Attorney name(s)** and **email(s)** (the contacts who will complete CRS vetting)
- **Firm address** (full street address including suite number)
- **Firm phone number**
- **Firm website**

#### Firm Data Resolution Order

Resolve firm data (address, phone, website, legal entity name) in this strict order. Document which tier you used when presenting the draft to the user.

1. **Glade Production MCP.** Always the first and default source. Pull from `creators_get` and `team_members_list`. If everything needed is present here, stop, this is authoritative.
2. **Web search (backup only).** If a field is missing or looks stale in Glade, search the public web (firm website, state bar directory listing) to fill the gap. Only use this for public firm-level facts (name, address, phone, website). Never use web search to source anything about individual clients or case data.
3. **Ask the user.** If web search doesn't resolve it either, ask directly. Do not send the email with placeholders, ever.

#### Soft Trigger: Address or Firm Info Confusion

If at any point there's ambiguity or conflicting information about the firm's address, legal entity name, or contact details (e.g., Glade shows one address, the website shows another, or the user isn't sure which is current), don't just hard-stop and ask a bare question. Instead, softly prompt the user:

> I'm seeing [conflicting/unclear] information on [firm]'s [address/entity name/etc.]: Glade has [X], and [web search / your note] shows [Y]. If it'd help, you can drop the firm's source documents (business license, bank letter, etc.) into a shared Drive folder and I'll review them against what's in Glade to flag the discrepancy before we draft anything. Or if you already know which is correct, just tell me and we'll proceed.

This is a suggestion, not a gate. If the user just answers directly, proceed with their answer and skip the Drive step.

#### Critical: Verify the Legal Entity Name

Using the wrong entity name (e.g., a DBA instead of the LLC name) will cause CRS vetting to fail and require restarting. If there is any ambiguity between the firm's display name in Glade and their legal entity name, use the soft trigger above rather than assuming.

---

### Step 2: Prompt the User to Collect the Required Documents

This skill does not collect, read, or process documents. Its job is to tell the user exactly what's needed and point them to where it lives in the onboarding flow, then let them handle the files themselves.

**Tell the user:**

> Before sending the CRS onboarding email for [Firm Name], you'll need to pull 7 documents from the firm's onboarding flow (or request them from the firm if they're not already on file). Here's exactly what's required:
>
> **Business Vetting Documents (5):**
> 1. **Current Business License, LLC Documentation, or Articles of Incorporation** -- proof the firm is a registered legal entity
> 2. **Verification of Business Checking Account** -- a voided check or a bank letter confirming the account
> 3. **Photo ID of the Signer** -- driver's license or government-issued ID of the attorney who will sign the CRS contract
> 4. **Business Phone Number Verification** -- a recent phone bill showing the firm's business number. Use the phone bill submitted to Glade during Attorney onboarding.
> 5. **Sample Consumer Authorization** -- the firm's existing client-facing authorization form for pulling credit
>
> **Contracting Documents (2):**
> 6. **Master Service Agreement (MSA)** -- CRS's standard service agreement
> 7. **Service Application** -- built into the MSA
>
> Product selection is always "Glade-Bankruptcy CRS/MCL".
>
> I won't handle these files directly. Once you've got them together, attach them to the Gmail draft yourself before sending. If the firm doesn't have a Consumer Authorization form, let me know and I'll generate the standard template language.

#### Consumer Authorization Fallback

If the firm does not have an existing consumer authorization form, provide this template text for them to use:

> I authorize [LAW FIRM NAME] to obtain a consumer credit report on me. [LAW FIRM NAME] will use the consumer credit report to prepare my bankruptcy case. Upon request, [LAW FIRM NAME] will provide me with the name and address of the Consumer Reporting Agency contacted to supply the report. I understand that credit inquiries have the potential to impact my credit score.

#### Document Readiness Gate

Do NOT proceed to Step 3 until the user has confirmed they have all documents ready to attach themselves (or confirmed which ones they have). The whole point of this email is that documents go out attached upfront so CRS can begin immediately. The skill confirms readiness; it does not verify the files or touch them.

If the user only has the 5 business vetting documents and not the MSA/Service Application (which come from CRS's side), proceed with the 5 and note that the contracting documents will come from CRS during the portal process. This is common.

---

### Step 3: Draft the Email

#### Recipients

- **To:** patricia.gomez@crscreditapi.com
- **CC:** mario.cisneros@crscreditapi.com, support@crscreditapi.com, [attorney email(s)], support@glade.ai, pete@glade.ai, [sender's own @glade.ai email]

#### Subject Line

```
CRS Onboarding -- [Firm Name]
```

Use a double hyphen (--), not an em dash.

#### Email Body Template

Use a time-appropriate greeting (morning/afternoon/evening based on current time in ET).

**Single Attorney Template:**

```
Good [morning/afternoon] Mario and Patricia,

Please meet [Full Name] of [Firm Name].

They'll be using the Direct Pull (B2B) credit report purchase feature inside Glade, and we'd like your help onboarding them into CRS.

[First Name], CRS is the leading credit reporting service online, and Glade's integration allows credit & financial reports to be purchased directly within your workflows. Currently, you're on the Client Approval flow, which requires client approval to pull reports. This has benefits but can slow things down. Switching to the Direct Pull flow removes this step but requires a one-time onboarding & verification process to set up your CRS account.

Action Items --

Invite to CRS Vetting Portal:
- Mario Cisneros will initiate the invite.
- Point of contact: Mario Cisneros -- mario.cisneros@crscreditapi.com

Documents:
I've attached the required business verification documents to this email.

[First Name], you will need to:
- Sign the CRS Standard Contract
- Complete the Letter of Intent (LoI) in the portal
- Complete the onsite inspection (required by the credit bureaus)

For convenience, the Contract, LoI, and onsite instructions will also be sent directly via email.

Confirmation From Mario:
Please confirm receipt of this request and share next steps and expected timing for account activation.

Firm Details:
[Firm Name]
[Street Address]
[Suite if applicable]
[City, State ZIP]
[Phone Number]
Website: [URL]

[First Name], if any questions arise regarding the documents or onboarding process, please feel free to reach out to Mario directly at mario.cisneros@crscreditapi.com or to us at Glade for assistance.

We're excited to help make credit report pulls even smoother for your team. [Personal closing line]

All the best,

[Sender signature block]
```

Note: "I've attached the required business verification documents to this email" stays in the body as-is regardless of who physically adds the attachments. It reads to CRS as coming from the sender. The skill drafts this text; the sender attaches the files before sending.

#### Sender Signature

The signature should match whoever is sending the email. Detect the current user from context (memory, conversation, or ask if unknown). Format:

```
-- [Full Name]
[Role]
[Phone] | [email]
```

Examples:
- `-- Jude Iredell\nLegal Ops\n310-869-4901 | jude@glade.ai`
- `-- Ivan Pinillos | ivan@glade.ai`
- `-- Pete Reed\n(610) 772-1103 | pete@glade.ai`

If the sender's info is not known, ask before drafting.

**Multiple Attorney Template:**

Adjust these lines:
- Opening: "Please meet [Full Name] and [Full Name] from [Firm Name]."
- Address attorneys together throughout: "[First] & [First],"
- Action items: "[First] & [First], you will need to:"
- Closing: "[First] & [First], if any questions arise..."

#### Personal Closing Line

Add a sentence tied to the relationship if context exists:
- Upcoming call: "Looking forward to our call on [day]!"
- Just had a call: "Great connecting today, excited to get this moving."
- No specific touchpoint: "We look forward to getting you set up!"

If the user provides context about a recent interaction, use it. Otherwise default to the generic close.

---

### Step 4: Present Draft for Approval

Show the user:
- The full email text
- The recipient list (To + CC)
- The firm details that will appear in the email
- A reminder of which 7 documents still need to be attached manually before sending

Ask: "Here's the draft. Let me know if you'd like to change anything, or say 'create it' and I'll create the draft in Gmail. You'll attach the documents yourself in Gmail before sending."

**STOP. Do not create the draft until the user explicitly approves.**

---

### Step 5: Create the Gmail Draft (No Attachments)

Once approved, create the draft using `Gmail:create_draft` with the body and recipients only. The skill does not read, encode, or attach any files, that step is entirely manual and happens in Gmail after the draft is created.

```
Gmail:create_draft(
  to: ["patricia.gomez@crscreditapi.com"],
  cc: [
    "mario.cisneros@crscreditapi.com",
    "support@crscreditapi.com",
    "<attorney_email(s)>",
    "support@glade.ai",
    "pete@glade.ai",
    "<sender_glade_email>"
  ],
  subject: "CRS Onboarding -- [Firm Name]",
  body: "<approved email body>"
)
```

Confirm to the user:
- Draft created successfully
- A reminder of the 7 documents (or however many apply) they still need to attach themselves
- A reminder to open Gmail, attach the documents, review, and send

**The skill's job ends here.** It never touches `/mnt/user-data/uploads/` for this workflow, never base64-encodes a document, and never sends the email. All of that is manual, by design.

---

## Edge Cases

### Firm Not Found in Glade
If the firm isn't in Glade yet, they shouldn't be getting a CRS email. The firm must be created in Glade first. Tell the user.

### Attorney Email Not Available
If the attorney's email isn't in Glade's team member list, ask the user. Do not send without CC'ing the attorney.

### Only Business Vetting Docs Available (No MSA)
This is normal. The MSA and Service Application typically come from CRS during the portal process. Proceed with the 5 business vetting documents and note in the email that contracting documents will follow from CRS.

### Consumer Authorization Missing
Provide the standard template language (see Step 2) and let the user decide whether to create a PDF from it or ask the firm for their existing form.

### Multiple Firms in One Session
Run the full workflow for each firm separately. Do not batch CRS onboarding emails.

### Documents Never Handled by the Skill
The skill never reads, encodes, stores, or attaches CRS documents, even if the user offers to upload them directly in chat. If the user tries to hand over files for this purpose, remind them to attach the documents themselves in Gmail once the draft is created. The one exception is the Soft Trigger flow: documents uploaded to a shared Drive folder there are for the skill to *review for discrepancies* against Glade data, not to attach to the email.

### Firm Address Discrepancy
The address used in the CRS email must match what CRS will verify. If the firm has multiple locations or Glade and outside sources disagree, use the Soft Trigger flow above (offer to review source documents in Drive) rather than guessing. Getting this wrong can stall the vetting process (this happened with Resolve Law Firm, which had a Downey address on file but wanted to use their Irvine address).

---

## Quick Reference: Recipients

| Field | Address |
|---|---|
| To | patricia.gomez@crscreditapi.com |
| CC | mario.cisneros@crscreditapi.com |
| CC | support@crscreditapi.com |
| CC | [attorney email(s) at the firm] |
| CC | support@glade.ai |
| CC | pete@glade.ai |
| CC | [sender's own @glade.ai email] |

## Quick Reference: Required Documents (7)

| # | Document | Purpose |
|---|---|---|
| 1 | Business License / LLC / Articles of Incorporation | Proves registered legal entity |
| 2 | Voided Check or Bank Letter | Verifies business checking account |
| 3 | Photo ID of the Signer | Identity verification |
| 4 | Phone Bill | Verifies business phone number |
| 5 | Sample Consumer Authorization | Authorizes credit pulls on clients |
| 6 | Master Service Agreement (MSA) | CRS contracting (may come from CRS) |
| 7 | Service Application | Built into MSA (may come from CRS) |

## Quick Reference: Signature

Use the current user's signature. See "Sender Signature" section in Step 3 for format.