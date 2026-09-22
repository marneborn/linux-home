---
name: custom-terms-request-builder
description: "Convert law firm documents into signable Custom Terms Request markdown templates for the Glade platform. Trigger when someone says \"turn this into a Custom Terms Request,\" \"make this signable in Glade,\" \"build a template from this PDF,\" \"convert this to terms,\" or uploads a legal document (engagement letter, fee agreement, retainer, consent form) needing an e-signable template. Also trigger on references to Building Blocks, Terms Requests, or Glade dynamic variables. Trigger aggressively: if a legal document is uploaded and context suggests a Glade template, use this skill. Distinguishes Chapter 7 vs. Chapter 13, joint vs. individual petitions. Joint petitions include spouse variables and We/us/our voice. Individual petitions exclude all spouse variables and use I/me/my voice. Filing fees are always hardcoded. {{flatFeeAmount}} is deprecated, never use it."
---

# Custom Terms Request Builder Skill

## Purpose
Convert law firm legal documents (PDFs, Word docs, scanned forms) into clean, signable Custom Terms Request markdown templates for the Glade platform.

## Pipeline Overview
Source Document → **Classify Petition Type** → Extract Full Text → Structure as Markdown → Apply Pronoun Rules → Swap Active Variables (conditionally) → Insert Signature Blocks → Output Variable Report

---

## Step 0: Classify the Document (MANDATORY FIRST STEP)

Before any extraction or variable mapping, read the source document and determine two things:

### A. Chapter Type
- **Chapter 7** (liquidation): Look for terms like "liquidation," "no-asset," "discharge of debts," "means test," flat fee structures, shorter timelines.
- **Chapter 13** (reorganization/repayment plan): Look for terms like "repayment plan," "plan payments," "trustee payments," "wage earner plan," "36-60 months," payment schedules, ongoing fee structures.

### B. Filing Type: Joint vs. Individual
- **Joint Petition**: The document references two debtors, a spouse or co-debtor, "joint petition," "joint debtors," "husband and wife," or contains two separate signature lines for debtor and spouse/joint debtor. Any mention of a second filer, co-petitioner, or joint case means this is joint.
- **Individual Petition**: The document references a single debtor only, has one client signature line, no mention of a spouse or co-debtor in the signing context. "Individual petition," "single filer," or simply the absence of any joint/spouse references.

### Classification Output
State your classification at the top of your working process before proceeding:
```
Classification: [Chapter 7 | Chapter 13] / [Joint Petition | Individual Petition]
Signals: [list the specific phrases/sections that led to this classification]
```

**If ambiguous:** If the document appears to be a general template covering both joint and individual scenarios (e.g., it has a spouse signature line marked "if applicable"), flag this to the user and ask which version to produce, or produce both versions clearly separated.

---

## Step 1: Identification & Extraction
- **Extract EVERYTHING:** No paragraph, clause, or table row is omitted. Match the source document's full text content exactly.
- **Header Logic:** Use `#` for the main title and `##` for all internal section headers and key terms.
- **Formatting:**
  - Use Markdown tables for rate/fee comparisons.
  - Use `> **WARNING:**` or `> **CAUTION:**` for boxed alerts.
  - Convert checkboxes to `- [ ]`.

- **Chapter-specific attention:**
  - For Ch. 13 documents, preserve all references to plan payment amounts, trustee payment schedules, plan duration, and post-confirmation fee provisions.
  - For Ch. 7 documents, preserve means test references, asset/no-asset distinctions, and reaffirmation agreement clauses.

---

## Step 2: Pronoun Voice (HARD RULE — ALL FIRMS, ALL CHAPTERS, EVERY TIME)

Client-voice pronouns are conditional on filing type. This is non-negotiable.

### Individual Petitions: Singular voice
All client-voice text uses **I / me / my / myself**. Examples:
- "I have been advised..."
- "I authorize [Firm] to obtain a consumer credit report on me."
- "I am signing this Good Faith Estimate..."
- "I understand that in signing..."
- "...represents me upon an initial down payment..."
- "Counseling me with respect to..."
- "Filing my petition with the Court."
- "My bankruptcy petition will be filed..."

Client references in third person: **Client** and **Client's** (never "Client(s)").

### Joint Petitions: Plural voice
All client-voice text uses **We / us / our / ourselves**. Examples:
- "We have been advised..."
- "We authorize [Firm] to obtain a consumer credit report on us."
- "We are signing this Good Faith Estimate..."
- "We understand that in signing..."
- "...represents us upon an initial down payment..."
- "Counseling us with respect to..."
- "Filing our petition with the Court."
- "Our bankruptcy petition will be filed..."

Client references in third person: **Client(s)** and **Client(s)'s**.

### Firm-voice "we" is unchanged in both types
When the firm is the speaker (e.g., "We charge $0.50 per page," "We will retain your legal files," "We reserve the right to..."), "we" stays as-is regardless of filing type. Only client-voice pronouns change.

---

## Step 3: Signature Placement (STRICT REQUIREMENT)

Place ALL signatures directly in the Markdown body exactly where they appear in the source.

### Signature Variables by Filing Type:

#### Individual Petitions:
- `{{primarySignatory}}` — The Client / Debtor signature
- `{{signatorySignature}}` — The Attorney signature
- `{{dateSigned}}` — Standard date variable for ALL signature dates

Do NOT include `{{secondarySignatory}}`, `{{spouseSignature}}`, or `{{spouse}}` anywhere.

#### Joint Petitions:
- `{{primarySignatory}}` — The Client / Debtor signature
- `{{secondarySignatory}}` — The Spouse / Joint Debtor signature
- `{{signatorySignature}}` — The Attorney signature
- `{{dateSigned}}` — Standard date variable for ALL signature dates

### Signature Block Format:
Signatures follow this exact pattern (no bold labels wrapping the variable, variable on its own line):

**Individual:**
```
{{primarySignatory}}

Client Signature (Debtor)

{{dateSigned}}

{{signatorySignature}}

Attorney Signature

{{dateSigned}}
```

**Joint:**
```
{{primarySignatory}}

Client Signature (Debtor)

{{dateSigned}}

{{secondarySignatory}}

Joint Debtor Signature

{{dateSigned}}

{{signatorySignature}}

Attorney Signature

{{dateSigned}}
```

### Rules:
- Every signature line gets its own `{{dateSigned}}` on a separate line below the label.
- Labels (e.g., "Client Signature (Debtor)", "Joint Debtor Signature", "Attorney Signature") appear between the signature variable and the date variable.
- If the source document places signatures mid-document (e.g., after a fee section before additional terms), preserve that placement exactly.

---

## Step 4: Active Variable Mapping

Swap specific values or blanks for these active Glade variables.

### Always-active variables:

| Original Context | Active Glade Variable |
|---|---|
| Total Attorney Fee / Flat Fee | `{{invoice:attorneyFees}}` |
| Initial Retainer / Down Payment | `{{initialDownPayment}}` |
| Primary Client Name | `{{customerName}}` |
| Firm Name / Attorney's Firm | `{{creatorName}}` |
| Today's Date / Agreement Date | `{{todaysDate}}` |

**NEVER use a variable for filing fees.** Filing fees are always hardcoded as the exact dollar amount from the source document (e.g., "$338"). Do not use `{{invoice:filingFee}}` or any other variable.

### Conditional variables (Joint Petition ONLY):

| Original Context | Active Glade Variable | Condition |
|---|---|---|
| Spouse / Joint Debtor Name | `{{spouse}}` | Joint Petition only |
| Spouse / Joint Debtor Signature | `{{secondarySignatory}}` | Joint Petition only |

**If Individual Petition:** Do NOT include `{{spouse}}` or `{{secondarySignatory}}` anywhere in the output, even if the source document has blanks or placeholders for a spouse. Strip them entirely.

### Greeting Line:
- **Joint:** `{{customerName}} and {{spouse}}`
- **Individual:** `{{customerName}}` only

### Credit Report Fee Line:
- **Joint:** `{{invoice:creditReport}} (Joint)`
- **Individual:** `{{invoice:creditReport}}` (no Joint label)

### Mandatory B2B Credit Report Disclosure (ALWAYS INCLUDE)

Every retainer template MUST include the following credit report disclosure. This is a Glade B2B platform requirement. Insert it regardless of whether the source document contains credit report language.

- For **Individual Petitions**, use: "The client authorizes the firm ({{creatorName}}) to pull a credit report and acknowledges the fee is $50 for a single report, with the understanding that this report is for bankruptcy preparation purposes."
- For **Joint Petitions**, use: "The client(s) authorizes the firm ({{creatorName}}) to pull a credit report and acknowledges the fee is $50 for a single report or $100 for a joint report, with the understanding that this report is for bankruptcy preparation purposes."

**Placement:** Insert after the fee/payment section of the retainer. If the source document already has its own credit report language, replace it with this standardized version.

`{{creatorName}}` is the only variable in this clause. The $50/$100 amounts are static (CRS B2B standard).

---

## Step 5: Output Format
- **The response must be only the markdown template.** No preamble or "Here is your file" text.
- Follow the template with a `---` separator and a **Variable Usage Report** that includes:
  1. **Classification:** Chapter type and filing type (joint/individual)
  2. **Pronoun voice applied:** I/me/my (individual) or We/us/our (joint)
  3. **Every variable used** and where it appears
  4. **Spouse/joint variables:** Explicitly state whether `{{spouse}}`, `{{secondarySignatory}}` were included or excluded, and why
  5. **Signature convention:** Confirm `{{primarySignatory}}` used for individual and joint, `{{secondarySignatory}}` for joint only
  6. **Any proposed custom variables**
  7. **Mandatory B2B credit report disclosure:** Confirm inserted, note individual vs. joint version used
