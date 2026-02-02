# Contributing

This repo is a community library of **industry-specific case analyses** for agentic workflows (MCP-enabled systems and tool-using agents).

A good contribution is **practical** and **defender-friendly**:

- how the workflow works in real systems
- how it can fail (or be attacked)
- how to build it safely (controls + detections + tests)

## Safety + disclosure rules (non-negotiable)

- **No sensitive information.** Do not include internal system names, private endpoints, customer data, secrets, non-public incidents, or unpublished roadmaps.
- **No operational exploitation instructions.** Keep analysis at the level of goals, stages, and failure modes. Do not provide step-by-step exploit guidance.
- **Grounded in reality.** Use cases must be based on workflows that exist today and include **public evidence**.
- **Default to anonymized writeups.** Do not name specific organizations unless it is strictly necessary and already broadly public. Prefer generic wording (e.g., “a SaaS issue tracker”, “a contact center platform”).

## Contribution flow

### 1) Choose a workflow family

Pick the closest match from the workflow families listed in the root `README.md`.

- **Use the exact text** from the list (e.g., "Case management & customer support", not a paraphrase).
- **One family per use case** in the metadata block.
- If none fits, see "Proposing a new workflow family" in the root README.

### 2) Choose where the use case lives (vertical + sub-vertical)

Use vertical folders for navigation:

`verticals/<vertical_id>/<subvertical_folder>/<use-case-slug>/README.md`

- Use `general/` when no curated sub-vertical exists.
- Use curated sub-vertical folders (`safe_sv_*`) when applicable.

### Choosing a sub-vertical

| Folder type | When to use |
|-------------|-------------|
| `general/` | Default. Use when no curated sub-vertical exists, or when the use case applies broadly. |
| `safe_sv_*` | Use when a SAFE-curated sub-vertical exists and your use case fits its scope. |

**Do not create new sub-verticals without discussion.** Sub-verticals are created sparingly when a cluster of use cases shares a distinct risk profile (different regulatory regime, trust boundaries, threat actors, or failure consequences). See the "Sub-verticals" section in the root README for full criteria.

### 3) Assign a SAFE Use Case ID

SAFE Use Case IDs are stable and never reused.

> **ID policy:** Only use cases receive formal IDs (`SAFE-UC-XXXX`). Sub-verticals, verticals, and workflow families use their folder names or exact text as identifiers.

1. Open (or create) `use-cases.naics2022.crosswalk.json` at the repo root.
2. Pick the next monotonically increasing ID: `SAFE-UC-0001`, `SAFE-UC-0002`, …
3. Add a new entry with:
   - `id` (the SAFE-UC)
   - `repo_path` (canonical path to the use case README)
   - `naics_2022` (one or more NAICS codes)
   - `workflow_family`
   - `operating_modes`
   - `evidence` (public links)

> Rule: **one canonical home per use case** (one repo path). If it applies to multiple industries, add multiple NAICS codes to the same entry—do not duplicate folders.

### 4) Create the folder + write the use case README

Create the folder (kebab-case slug) and add a `README.md`:

`verticals/<vertical_id>/<subvertical_folder>/<use-case-slug>/README.md`

Use `templates/use-case-template.md` as your base.

### 5) (Optional) Add to the human-readable table

The root `README.md` includes a human-readable crosswalk table.

- If you add a new use case ID, consider adding a row so readers can discover it.
- If your use case maps to multiple NAICS codes, include one row per NAICS code.

## Evidence guidelines

Each use case must include **public evidence**.

Good evidence sources:

- product documentation
- engineering blog posts
- conference talks / slides
- incident postmortems (public)
- regulatory filings / transparency reports

Evidence should be:

- **publicly accessible**
- **non-sensitive**
- **specific to the workflow**

Tip: use neutral link text (e.g., “Public product documentation: issue thread summarization”) even if the URL contains vendor branding.

## Writing style guidelines

- Write for **builders and reviewers**: engineers, product, security, reliability.
- Prefer concrete nouns (systems, queues, tokens, roles) over abstractions.
- When describing attacks/failures, focus on:
  - attacker goal
  - entry points
  - what breaks
  - detection + mitigations
- Include **operating modes** (manual → HITL → autonomous) and explain how risk changes.

## PR checklist

Before opening a PR:

- [ ] Folder path follows the convention under `verticals/…`
- [ ] Use case includes the metadata block (ID, NAICS, workflow family, evidence)
- [ ] Workflow family uses exact text from the canonical list in root README
- [ ] Operating modes are included (or explicitly marked N/A)
- [ ] Kill-chain analysis is defender-friendly (no exploit steps)
- [ ] SAFE-MCP mapping table is included (even if technique IDs are “TBD”)
- [ ] Controls include testable items (not just recommendations)
- [ ] `use-cases.naics2022.crosswalk.json` updated with the new use case entry

