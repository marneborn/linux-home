---
name: attorney-profile-miner
description: >
  Automatically populate Glade attorney profile fields by mining state bar registries,
  firm websites, and open web sources. Use this skill whenever someone says "look up
  an attorney," "populate attorney info," "onboard an attorney," "find bar info for
  [name]," or asks to fill in the Glade attorney information section for one or more
  attorneys. Also trigger when a user pastes a list of attorney names and asks to pull
  their contact details, bar numbers, or firm information. This skill should trigger
  aggressively — if attorney profile data is needed for any reason, use it.
---

# Attorney Profile Miner

Automates population of Glade's attorney information form fields by querying state bar
registries, scraping firm websites, and falling back to open web sources. Covers all
50 states + DC.

## Fields this skill populates

| Field | Source tier | Expected hit rate |
|---|---|---|
| First / last name | Bar registry (A) | ~100% |
| Bar number | Bar registry (A) | ~95% |
| Organization / firm name | Bar registry (A) | ~90% |
| Mailing address (full) | Bar registry (A) | ~95% |
| Activity status | Bar registry (A) | ~100% |
| Licensing authority | Auto-derived from state | 100% |
| Daytime phone | Bar registry (A) → firm site (B) | ~70% |
| Fax number | Bar registry (A) → firm site (B) | ~50% |
| Email | Bar (A) → firm site (B) → open web (C) | ~90–95% |
| Middle name | Bar registry (A) | ~40% |
| Physical address | Bar registry (A) | ~60% |
| Mobile phone | Firm site (B) → open web (C) | ~25% |

**Do not attempt to populate:** USCIS account number, default filing attorney flag.
These are collected on the onboarding call.

---

## Workflow

### Step 1 — Identify the state bar

Determine which state(s) the attorney is licensed in. If the user provides a state,
use it. If not, ask before proceeding — the bar registry URL depends on it.

Load `references/state-bar-directory.md` for the full URL list keyed by state.

### Step 2 — Query the state bar registry (Tier A)

Using the URL from the reference file, search for the attorney by name. If a bar
number is already known, use it as the primary lookup key — it's unambiguous.

**Extract all available fields** in one pass:
- Full name (split into first / middle / last)
- Bar number / registration number
- Firm / organization name
- Mailing address (street, suite, city, state, zip)
- Physical address if listed separately
- Activity / license status
- Phone and fax if present
- Email if present

If email is found in Tier A → skip to Step 5.
If email is not found → proceed to Step 3.

**Status check:** If the registry shows the attorney as inactive, suspended, or
disbarred, flag this prominently before continuing. Do not silently populate a
profile for an inactive attorney.

### Step 3 — Find the firm website (Tier B, part 1)

Using the firm name + city + state extracted in Step 2, run a web search:

```
"[Firm Name]" [City] [State] law firm site
```

Confirm the result is the actual firm website (not Avvo, FindLaw, Martindale, etc.).
If the firm name is generic (e.g. "Law Offices of John Smith"), include the bar
address city to narrow it.

If no firm website found → skip to Step 4 (open web).

### Step 4 — Scrape firm website for email (Tier B, part 2)

On the firm website, check these pages in order:
1. `/attorneys` `/team` `/people` `/lawyers` `/our-team`
2. `/contact` `/contact-us`
3. Homepage (some small firms list all attorneys there)

On each page, locate the attorney by name match and extract:
- Email address
- Direct phone / mobile if listed
- Any additional contact info

**Email pattern inference:** If no explicit email is found but the domain is known,
try inferring the pattern from other attorneys on the same page (e.g. if
`jsmith@acmlaw.com` is listed, try `[first initial][last]@acmlaw.com` for the
target attorney). Flag inferred emails clearly — do not present them as confirmed.

If email found → skip to Step 5.
If not found → proceed to open web (Tier C).

### Step 5 — Open web fallback (Tier C)

Try these sources in order, stopping as soon as email is confirmed:

1. **LinkedIn** — Search `"[First Last]" "[Firm Name]" attorney`. Check bio and
   contact info sections. LinkedIn sometimes surfaces emails directly.

2. **Targeted Google search** — `"[First Last]" "[Firm Name]" email OR contact`
   and separately `"[First Last]" site:[firmwebsite.com]`

3. **Email enrichment** — If Hunter.io or Apollo MCP tools are available, query
   by name + firm domain. Flag these as "enrichment-sourced" in the notes field.

4. **Google domain guess** — If firm domain is known, construct the most common
   patterns (`firstname@`, `flast@`, `firstlast@`) and note them as unverified
   guesses requiring confirmation.

If no email found after all tiers → leave field blank and add note:
`"Email not found — confirm on onboarding call."`

### Step 6 — Compile and present

Present a structured summary of all fields found before writing anything to Glade,
so the user can review and correct. Format:

```
ATTORNEY PROFILE DRAFT
──────────────────────
Name:             [First] [Middle] [Last]
Bar number:       [#]
Licensing auth:   [State] State Bar / [Court system]
Status:           Active ✓  (or flag if otherwise)
Firm:             [Org name]
Mailing address:  [Street], [Suite], [City], [State] [Zip]
Physical address: [Same as mailing / different / not listed]
Phone (daytime):  [#] (source: bar registry / firm site / not found)
Fax:              [#] (source: bar registry / firm site / not found)
Mobile:           [#] (source: firm site / not found)
Email:            [address] (source: A / B / C / inferred / not found)

Notes:            [Any flags — inactive status, inferred email, gaps]
```

Ask: "Does this look right? I'll add it to Glade once confirmed."

### Step 7 — Handle multiple attorneys

If the user provides a list of attorneys, process them sequentially. After each one,
show the draft and ask for a quick confirm/correct before moving to the next. Do not
batch-write without per-attorney confirmation.

---

## Key rules

- **Never silently skip a field.** If something wasn't found, say so explicitly.
- **Never present an inferred email as confirmed.** Always label the source tier.
- **Always status-check before populating.** An inactive attorney profile should be
  flagged, not quietly filled in.
- **Licensing authority is always auto-derived** from the state being queried — do
  not ask the user for this.
- **Middle name:** If not in the registry, leave blank. Do not guess from other sources.
- **USCIS account number and default filing attorney:** Do not attempt. Note on the
  draft that these will be handled on the onboarding call.

---

## Reference files

- `references/state-bar-directory.md` — Full URL list for all 50 states + DC,
  organized by state with notes on available fields and any access quirks
  (opt-out states, form-based vs. REST, login walls). Load this whenever you
  need to look up which URL to use for a given state.

---

## Edge cases

**Solo practitioners with no firm website**
Skip Tier B entirely. Go straight to Tier C. Note in the profile draft that no
firm site was found.

**Attorneys licensed in multiple states**
Pull from the state the user specifies. If unclear, ask which state's bar record
should be the primary. Note other states in the profile if the registry mentions them.

**Oklahoma and Virginia (opt-out states)**
The attorney may not appear in the directory even if active. If no result is found,
note: "Attorney may have opted out of public listing — verify status by phone."
Oklahoma: 405-416-7000 / Virginia: 804-775-0500.

**South Dakota (no online directory)**
Skip Tier A entirely. Go straight to Tier B (firm website). Note in draft:
"SD has no public online directory — bar status unverified."

**Name conflicts (multiple attorneys with same name)**
Use bar number if known. If not, use city + firm name to disambiguate. If still
ambiguous, surface both results to the user and ask them to confirm which one.

**Form-based bar sites (Playwright required)**
About 30 states use JavaScript-heavy forms that don't respond to simple HTTP fetch.
If a web_fetch fails or returns an empty/login page, note this and attempt the
search manually by navigating to the URL. Flag which states need browser automation
in `references/state-bar-directory.md`.
