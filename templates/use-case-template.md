# <Use case title>

## Metadata

- **SAFE Use Case ID:** `SAFE-UC-____`
- **Repo path:** `verticals/<vertical_id>/<subvertical_folder>/<use-case-slug>/README.md`
- **Primary vertical:** `<vertical display name>` (implied by folder)
- **Sub-vertical:** `general` (default) or `safe_sv_*` (if a curated sub-vertical exists)
- **NAICS 2022:** `<code (name)>` (primary), `<code (name)>` (optional secondary)
- **Workflow family:** `<exact text from README "Workflow families (v0)" list - do not paraphrase>`
- **Operating modes covered:** manual / HITL / autonomous / other
- **Evidence (public links):**
  - <link 1>
  - <link 2>

---

## 1. Executive summary (what + why)

<...>

## 2. Industry context & constraints

<...>

## 3. System & agent architecture

### 3.1 Actors and systems

<...>

### 3.2 Trust boundaries

<...>

### 3.3 Tool inventory

<...>

## 4. Operating modes & agentic flow variants

### 4.1 Manual baseline (no agent)

<...>

### 4.2 Human-in-the-loop (sub-autonomous)

<...>

### 4.3 Fully autonomous (end-to-end agentic)

<...>

### 4.4 Sub-agentic / multi-agent variants (optional)

<...>

## 5. Threat model overview

- **Primary security goals:** <...>
- **Attack surfaces:** <...>
- **High-impact failures:** <...>

## 6. Kill-chain analysis (stages → likely failure modes)

| Stage | What can go wrong | Impact | Notes |
|---|---|---|---|
| <stage> | <failure> | <impact> | <notes> |

## 7. SAFE-MCP mapping (stage → SAFE technique → control)

> Keep this defender-friendly. Do **not** include operational exploit steps.

| Kill-chain stage | Failure/attack pattern | SAFE-MCP technique(s) | Recommended controls | Tests |
|---|---|---|---|---|
| <stage> | <pattern> | <SAFE technique IDs/names> | <controls> | <tests> |

## 8. Mitigations & design patterns

### 8.1 Prevent

<...>

### 8.2 Detect

<...>

### 8.3 Recover

<...>

## 9. Validation & testing

<...>

## 10. Questionnaire prompts

<...>
