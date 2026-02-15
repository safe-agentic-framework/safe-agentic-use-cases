# Contributing

This repo is a community library of **real-world agentic workflow (use case) analyses**.

It complements **SAFE‑MCP**:
- **SAFE‑MCP** catalogs *how agentic/MCP systems can be attacked or fail* (techniques).
- **SAFE‑AUCA** makes those techniques actionable by grounding them in *real workflows* and producing **controls + tests**.

We use a **seed-first** model:
- We publish a catalog of seeded `SAFE-UC-XXXX` IDs (short descriptions + NAICS crosswalk).
- Contributors pick a seed and expand it into a detailed write-up.

---

## Safety + disclosure rules (non‑negotiable)

- **No sensitive information.** Do not include internal system names, private endpoints, customer data, secrets, non‑public incidents, or unpublished roadmaps.
- **No operational exploitation instructions.** Keep analysis at the level of goals, stages, and failure modes. Do not provide step‑by‑step exploit guidance.
- **Grounded in reality.** Use cases should reflect workflows that exist today.
- **Default to anonymized writeups.** Do not name specific organizations unless strictly necessary and already broadly public.

---

## DSO signoff (required)

**All PRs require DSO signoff before merging.**

A “DSO signoff” means:
- a GitHub **approval review** from a designated DSO/maintainer, **or**
- a PR comment from a designated DSO/maintainer stating **“DSO Approved”**.

If you’re unsure who can provide DSO signoff, ask in the PR thread and a maintainer will route it.

---

## Where use cases live

Each use case has a single canonical page:

`use-cases/SAFE-UC-XXXX/README.md`

This mirrors the SAFE‑MCP pattern: one stable ID → one page that can evolve from seed → draft → published.

---

## Status definitions

Use one of the following in both the registry and the use case page:

- `seed` — ID reserved; short description exists; full analysis not written yet
- `draft` — first real write-up exists (architecture + kill chain + SAFE‑MCP mapping + initial tests)
- `published` — reviewed and ready for general use

(If you want “starter template” semantics, keep `status: draft` and add a separate `maturity: starter-template` field in the registry.)

---

## Contribution flow

### 1) Pick a workflow family
Pick the closest match from the workflow families listed in the root `README.md`.

Rules:
- **Use the exact text** from the list (no paraphrases).
- **One primary workflow family per use case**.

---

### 2) Pick a SAFE Use Case ID (or create a new one)

SAFE Use Case IDs are stable and never reused.

- Prefer adopting an existing `seed` from the root README index.
- If you need a new one, pick the next monotonically increasing ID: `SAFE-UC-0001`, `SAFE-UC-0002`, …

---

### 3) Update the canonical registry (required)

File: `use-cases.naics2022.crosswalk.json`

Add/update exactly **one entry per use case ID**.

Minimum fields for a `seed`:
- `id`
- `title`
- `status`
- `repo_path` = `use-cases/SAFE-UC-XXXX/README.md`
- `naics_2022` (one or more NAICS codes)

Recommended fields (especially for `draft` / `published`):
- `workflow_family`
- `operating_modes`
- `tags`
- `evidence` (public links)

**Multi‑industry rule:**  
If a use case maps to multiple NAICS codes, include all of them inside the same use case entry under `naics_2022`. Do **not** duplicate the use case entry.

---

### 4) Create or update the use case page

Path:
`use-cases/SAFE-UC-XXXX/README.md`

Start from:
- `templates/use-case-template.md`

**For a new `seed` page**, minimum content:
- Metadata filled (ID, status, NAICS, workflow family)
- 5–15 line workflow description (what it is / who uses it / what tools it touches)
- In-scope / out-of-scope bullets
- SAFE‑MCP mapping table present (technique IDs may be `TBD` initially, but keep the structure)

**To upgrade `seed` → `draft`,** complete at least:
- workflow steps
- architecture + trust boundaries
- operating modes (manual → HITL → autonomous) and how risk changes
- kill-chain table
- SAFE‑MCP mapping table with concrete controls + tests
- add public evidence links

---

### 5) Request DSO signoff (required)

Before merging, request DSO review on the PR and ensure there is an explicit DSO approval
(approval review or “DSO Approved” comment).

---

### 6) Update the root README index (recommended)

If you added a new ID or changed status/title/NAICS mapping, update the big index table in `README.md` so people can discover it.

Tip: link the SAFE‑UC ID to `use-cases/SAFE-UC-XXXX/README.md`.

---

## Evidence guidelines

Required for `draft` and `published`. Recommended for `seed`.

Good evidence sources:
- product documentation
- engineering blog posts
- conference talks / slides
- public incident postmortems
- regulatory filings / transparency reports

Evidence should be:
- publicly accessible
- non-sensitive
- specific to the workflow

---

## Writing style guidelines (keep it usable)

- Write for builders and reviewers (engineering + security + reliability).
- Be concrete about tools, trust boundaries, and permissions.
- Keep attacks/failures defender-friendly:
  - attacker goal
  - entry points
  - what breaks
  - detection + mitigations
- Every meaningful control should have at least one **test** (how you’d validate it).

---

## PR checklist

Before opening a PR:

- [ ] No sensitive info included
- [ ] No exploit steps included
- [ ] `use-cases.naics2022.crosswalk.json` updated for the ID
- [ ] Use case page exists at `use-cases/SAFE-UC-XXXX/README.md`
- [ ] Metadata includes: ID, status, NAICS, workflow family
- [ ] SAFE‑MCP mapping table included (technique IDs may be “TBD” for first draft)
- [ ] Controls include testable items (not just recommendations)
- [ ] Public evidence links included for `draft`/`published`
- [ ] **DSO signoff obtained** (approval review or "DSO Approved" comment)
