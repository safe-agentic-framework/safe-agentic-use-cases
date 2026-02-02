# SAFE-Agentic Use Case Analysis (SAFE-AUCA)

A community library of **industry-specific case analyses** for agentic workflows (MCP-enabled systems and tool-using agents).

- **Each use case has a stable SAFE Use Case ID** and maps to one or more **NAICS 2022** industry codes.
- Use cases live under **vertical folders** for navigation.
- **Readers:** open a use case → understand the real workflow, how it fails, and how to harden it.
- **Contributors:** add use cases using the templates + registry workflow. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for full guidelines.

---

## Table of Contents

- [Quick start](#quick-start)
- [What this repository is](#what-this-repository-is)
- [Why this exists](#why-this-exists-the-submarine-analogy)
- [How to use this repo](#how-to-use-this-repo)
- [Use case IDs + NAICS crosswalk](#use-case-ids--naics-crosswalk-the-core-idea)
- [Workflow families](#workflow-families-shared-patterns-across-industries)
- [Repository structure](#repository-structure-recommended)
- [What a use case includes](#what-a-use-case-analysis-includes)
- [Industry navigation](#industry-navigation)
- [Sub-verticals](#sub-verticals)
- [Seeding strategy](#seeding-strategy-how-we-decide-what-to-write-next)
- [Contributing](#contributing)

---

## Quick start

**Reading a use case:**
1. Browse [`verticals/`](verticals/) or use the [NAICS crosswalk table](#naics-2022--safe-use-case-id-crosswalk-human-readable-index)
2. Open a use case README → review the workflow, threat model, and controls

**Contributing a use case:**
1. Pick a [workflow family](#workflow-families-shared-patterns-across-industries) and [vertical folder](#industry-navigation)
2. Copy `templates/use-case-template.md` to `verticals/<vertical>/<subvertical>/your-use-case/README.md`
3. Fill out the template, update `use-cases.naics2022.crosswalk.json`, and open a PR
4. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for full guidelines

---

## What this repository is

This repository is designed to answer a practical question:

> “How are agents actually built in *my* industry and what are the most realistic ways the workflow can be attacked or fail?”

Each use case is written to be concrete and implementation-oriented:

- **How the workflow works in the real world** (systems, tools, constraints)
- **Operating modes (evolution over time)**:
  - **Traditional / manual baseline (no agent)**
  - **Human-in-the-loop (sub-autonomous)**
  - **Fully autonomous (end-to-end agentic)**
  - *(plus sub-agentic / multi-agent variants where applicable)*
- **Kill-chain analysis**: attacker objectives and stages (**without exploitation instructions**)
- **SAFE-MCP mapping**: which SAFE techniques apply at each stage
- **Controls + detections + validation tests**
- **Questionnaire prompts**: the questions builders should ask *before* shipping a high-impact agent

---

## Why this exists (the submarine analogy)

Building an agent for a low-stakes environment is like building a submarine for a small lake:
- if something goes wrong, the blast radius is smaller,
- you can recover quickly,
- failure is embarrassing - but not catastrophic.

Building an agent that acts on the real world (money movement, healthcare decisions, robotics, critical infrastructure) is like building a submarine for the deep ocean:
- the environment is hostile,
- small cracks become fatal at depth,
- you must assume things will go wrong and engineer for containment, observability, and recovery.

This repo is the “deep ocean” playbook: **use case by use case**, we document how systems can break and how to design safer.

---

## How to use this repo

1. Start with a **workflow family** (below) *or* browse a **vertical folder**.
2. Open a use case and review:
   - system diagram & trust boundaries
   - operating-mode variants (manual → HITL → autonomous)
   - kill-chain narrative
   - SAFE-MCP mapping table
   - recommended controls, detections, and tests
   - questionnaire prompts

---

## Use case IDs + NAICS crosswalk (the core idea)

Companies often span multiple industries.

So in SAFE-AUCA we do **NAICS crosswalking at the use case level**:

- A **company** might map to multiple NAICS codes depending on business unit.
- A **use case** is much more specific (a concrete workflow), so it can be anchored to the *right* NAICS code(s).

### What to do in practice

- Every use case declares:
  - a **SAFE Use Case ID** (stable)
  - **NAICS 2022 code(s)** (primary + optional secondary)
  - a **primary vertical folder** (where it lives)
  - optional **related verticals** (if the same workflow appears elsewhere)

**SAFE Use Case ID format**

- Use IDs like `SAFE-UC-0001` (zero-padded, monotonically increasing).
- IDs are **never reused**, even if a use case is removed.
- The canonical registry is `use-cases.naics2022.crosswalk.json`.

### Canonical crosswalk file

The machine-readable “source of truth” for the crosswalk lives in:

- `use-cases.naics2022.crosswalk.json`

This file maps:

`SAFE Use Case ID → repo path → NAICS 2022 code(s) → workflow family → operating modes (+ optional tags)`

> Rule: **one canonical home per use case** (one repo path). If it belongs in multiple industries, capture that via **NAICS codes** + **related verticals**, don’t duplicate folders.

### NAICS 2022 ↔ SAFE Use Case ID crosswalk (human-readable index)

This table is the README view of the canonical file `use-cases.naics2022.crosswalk.json`.

- This list is **seeded from publicly described, real-world workflows**; organization names are **intentionally omitted**.
- A use case may be **in-progress** (folder may not exist yet), but the **ID + NAICS mapping** should be stable once assigned.
- Each use case appears once, under the NAICS code where it canonically lives.

<details open>
  <summary><strong>NAICS 2022 → SAFE Use Case ID crosswalk</strong></summary>

| NAICS 2022 | SAFE Use Case ID | Use case title | Canonical repo path |
|---|---|---|---|
| 31-33 | SAFE-UC-0008 | Over-the-air vehicle software update orchestration | `verticals/manufacturing_industrial/general/vehicle-ota-update-orchestration/` |
| 31-33 | SAFE-UC-0009 | Manufacturing line visual inspection assistant | `verticals/manufacturing_industrial/general/visual-inspection-quality-assistant/` |
| 31-33 | SAFE-UC-0010 | In-vehicle voice assistant for local controls | `verticals/manufacturing_industrial/general/in-vehicle-voice-assistant/` |
| 44-45 | SAFE-UC-0001 | AI-assisted seller listing creation | `verticals/retail_ecommerce/general/seller-listing-creation-assistant/` |
| 44-45 | SAFE-UC-0002 | Personalized shopping sidekick | `verticals/retail_ecommerce/general/personalized-shopping-sidekick/` |
| 44-45 | SAFE-UC-0003 | Buyer-seller messaging assistant | `verticals/retail_ecommerce/general/buyer-seller-messaging-assistant/` |
| 44-45 | SAFE-UC-0004 | Listing media enhancement assistant | `verticals/retail_ecommerce/general/listing-media-enhancement-assistant/` |
| 44-45 | SAFE-UC-0005 | Visual search & image-based product discovery | `verticals/retail_ecommerce/general/visual-search-product-discovery/` |
| 48-49 | SAFE-UC-0006 | Fleet telematics & vehicle-health monitoring assistant | `verticals/transport_logistics_warehousing/general/fleet-telematics-health-assistant/` |
| 51 | SAFE-UC-0016 | IT service-desk virtual agent | `verticals/tmt_tech_media_telecom/safe_sv_software_saas/itsm-virtual-service-agent/` |
| 51 | SAFE-UC-0017 | Service request triage assistant | `verticals/tmt_tech_media_telecom/safe_sv_software_saas/service-request-triage-assistant/` |
| 51 | SAFE-UC-0018 | Issue/work-item summarization assistant | `verticals/tmt_tech_media_telecom/safe_sv_software_saas/work-item-summarization-assistant/` |
| 51 | SAFE-UC-0019 | Post-incident review drafting assistant | `verticals/tmt_tech_media_telecom/safe_sv_software_saas/post-incident-review-drafting-assistant/` |
| 51 | SAFE-UC-0020 | On-call incident context assistant | `verticals/tmt_tech_media_telecom/safe_sv_software_saas/oncall-incident-context-assistant/` |
| 51 | SAFE-UC-0023 | Cloud ops troubleshooting assistant | `verticals/tmt_tech_media_telecom/safe_sv_cloud_infrastructure_hosting/cloud-ops-troubleshooting-assistant/` |
| 51 | SAFE-UC-0024 | Terminal-based outage assistant for SRE | `verticals/tmt_tech_media_telecom/safe_sv_cloud_infrastructure_hosting/sre-terminal-outage-assistant/` |
| 51 | SAFE-UC-0025 | Enterprise agent-building platform | `verticals/tmt_tech_media_telecom/safe_sv_cloud_infrastructure_hosting/enterprise-agent-platform/` |
| 51 | SAFE-UC-0026 | At-scale content policy enforcement pipeline | `verticals/tmt_tech_media_telecom/safe_sv_social_streaming_content_platforms/content-policy-enforcement-pipeline/` |
| 51 | SAFE-UC-0027 | Anti-scam messaging safety assistant | `verticals/tmt_tech_media_telecom/safe_sv_social_streaming_content_platforms/anti-scam-messaging-safety-assistant/` |
| 51 | SAFE-UC-0028 | Fake-account & inauthentic behavior detection assistant | `verticals/tmt_tech_media_telecom/safe_sv_social_streaming_content_platforms/inauthentic-behavior-detection-assistant/` |
| 51 | SAFE-UC-0030 | Teen safety & age-assurance enforcement assistant | `verticals/tmt_tech_media_telecom/safe_sv_social_streaming_content_platforms/teen-safety-age-assurance-assistant/` |
| 52 | SAFE-UC-0011 | Banking virtual assistant | `verticals/financial_services_insurance/safe_sv_banking_credit/banking-virtual-assistant/` |
| 52 | SAFE-UC-0012 | Interactive fraud alert & card controls assistant | `verticals/financial_services_insurance/safe_sv_banking_credit/fraud-alert-card-controls-assistant/` |
| 52 | SAFE-UC-0013 | Virtual card number generation & checkout assistant | `verticals/financial_services_insurance/safe_sv_banking_credit/virtual-card-checkout-assistant/` |
| 52 | SAFE-UC-0014 | Digital dispute/chargeback intake assistant | `verticals/financial_services_insurance/safe_sv_banking_credit/dispute-chargeback-intake-assistant/` |
| 52 | SAFE-UC-0015 | AML suspicious-activity triage assistant | `verticals/financial_services_insurance/safe_sv_banking_credit/aml-suspicious-activity-triage-assistant/` |
| 54 | SAFE-UC-0022 | Security operations investigation assistant | `verticals/professional_technical_services/general/security-operations-investigation-assistant/` |
| 54 | SAFE-UC-0029 | Automated ad campaign optimization assistant | `verticals/professional_technical_services/general/ad-campaign-optimization-assistant/` |
| 56 | SAFE-UC-0021 | Contact-center agent assist | `verticals/business_support_facilities_environmental/general/contact-center-agent-assist/` |
| 81 | SAFE-UC-0007 | Mobile fleet-maintenance dispatch & scheduling assistant | `verticals/personal_local_services/general/mobile-fleet-maintenance-dispatch-assistant/` |

</details>

---

## Workflow families (shared patterns across industries)

Agentic work repeats. The same *kind of work* shows up across many industries just with different tools, constraints, and failure modes.

Every use case should declare a **primary workflow family**.

**Workflow families (v0)**

- **Incident response & reliability** (SRE/NOC, outage triage, remediation, postmortems)
- **Case management & customer support** (ticket triage, escalations, refunds, dispute handling)
- **Fraud, risk & investigations** (alerts, investigations, sanctions/AML triage, abuse patterns)
- **Compliance, audit & reporting** (controls evidence, regulatory workflows, policy enforcement)
- **Scheduling, dispatch & field operations** (routing, workforce dispatch, work orders, SLAs)
- **Onboarding, identity & access** (KYC/KYB, account onboarding, IAM provisioning)
- **Trust & safety operations** (content moderation, spam/abuse response, user safety)
- **Finance operations** (billing, reconciliation, collections, chargebacks)
- **Procurement & vendor operations** (vendor onboarding, approvals, contracts, renewals)
- **Employee / internal operations** (IT service desk, HR ops, access requests)

### Choosing a workflow family

When assigning a workflow family to a use case:

1. **Use exact text from the list above.** Copy the family name verbatim (e.g., "Case management & customer support", not "customer support" or "case-management").
2. **Pick the closest match.** If a use case spans multiple families, choose the primary one and note secondary families in the use case description.
3. **One family per use case** in the metadata block. The crosswalk registry expects a single `workflow_family` value.

### Proposing a new workflow family

Workflow families are **cross-industry patterns**, not industry-specific categories. They should be:

- **Horizontal**: The same pattern appears in 3+ distinct verticals.
- **Distinct**: The risk profile, failure modes, or control patterns differ meaningfully from existing families.
- **Stable**: The pattern is well-established in industry practice, not emerging or speculative.

**To propose a new workflow family:**

1. Open an issue describing the proposed family name, scope, and how it differs from existing families.
2. Include at least 3 planned use cases from different verticals that would use it.
3. If accepted, add it to the list above and update existing use cases if they better fit the new family.

### Workflow family governance

- **Workflow families do not receive IDs.** They are metadata labels, not versioned artifacts.
- **The list above is the canonical source.** Use cases must reference families exactly as written here.
- **Changes require a PR.** Adding, renaming, or removing a family requires updating this README and all affected use cases.

---

## Repository structure (recommended)

Use cases should be organized so that:
- each **vertical** has an overview (shared context),
- each **sub-vertical** (when defined) has an index (`general/` is the default),
- each **use case** is a self-contained folder with a `README.md`.

Example paths:

```text
verticals/financial_services_insurance/safe_sv_banking_credit/card-dispute-case-agent/README.md
verticals/tmt_tech_media_telecom/safe_sv_software_saas/incident-triage-agent/README.md
verticals/retail_ecommerce/general/weekly-grocery-shopping-agent/README.md
```

Templates:
- `templates/vertical-template.md`
- `templates/use-case-template.md`

---

## What a “use case analysis” includes

Every use case should follow a consistent structure (see `templates/use-case-template.md`).

At the top of every use case, include a small metadata block:

- **SAFE Use Case ID** (stable)
- **Repo path** (implied by folder path)
- **Primary vertical** (implied by folder path)
- **Sub-vertical** (`general/` or a `safe_sv_*` folder)
- **NAICS 2022** (primary + optional secondary)
- **Workflow family** (choose one from this README)
- **Operating modes covered** (manual → HITL → autonomous, as applicable)
- **Evidence** (public links / sources; no internal docs)

Use case sections:

1. Executive summary (what + why)
2. Industry context & constraints (regulatory, safety, latency, privacy)
3. System & agent architecture (assets, trust boundaries, tool inventory)
4. **Operating modes & agentic flow variants**
   - Traditional/manual baseline (no agent)
   - Human-in-the-loop (sub-autonomous)
   - Fully autonomous (end-to-end agentic)
   - Sub-agentic and/or multi-agent variants (when relevant)
5. Threat model overview (goals, attack surfaces)
6. Kill-chain analysis (stages → likely failure modes)
7. SAFE-MCP mapping (stage → SAFE technique → control)
8. Mitigations & design patterns (prevent / detect / recover)
9. Validation & testing (what to test, what “good” looks like)
10. Questionnaire prompts (standard + industry-specific + use-case-specific)

> Why the operating modes matter: they show how **risk changes as autonomy increases**.
> A failure mode that is “annoying but obvious” in manual flows can become “silent and systemic” in fully autonomous flows.

---

## Industry navigation

Use **vertical folders** to browse by industry. Each vertical groups related use cases.

<details>
  <summary><strong>SAFE-AUCA vertical folder IDs (click to expand)</strong></summary>

| Vertical (display) | Vertical ID (folder) |
|---|---|
| Agriculture, Forestry & Fisheries | `agriculture_food_natural_resources` |
| Energy & Natural Resources (Extraction) | `energy_resources_extraction` |
| Utilities & Energy Distribution | `utilities_energy_distribution` |
| Construction & Infrastructure | `construction_infrastructure` |
| Manufacturing & Industrial | `manufacturing_industrial` |
| Wholesale & Distribution | `wholesale_distribution` |
| Retail & eCommerce | `retail_ecommerce` |
| Transportation, Logistics & Warehousing | `transport_logistics_warehousing` |
| Technology, Media & Telecom (TMT) | `tmt_tech_media_telecom` |
| Financial Services (Banking, Payments, Capital Markets, Insurance) | `financial_services_insurance` |
| Real Estate, Property & Leasing | `real_estate_property_rental` |
| Professional & Technical Services | `professional_technical_services` |
| Corporate HQ / Holding Companies | `corporate_hq_holding` |
| Business Support, Facilities & Environmental Services | `business_support_facilities_environmental` |
| Education & Learning | `education_learning` |
| Healthcare & Social Services | `healthcare_life_social_services` |
| Entertainment, Sports & Recreation | `entertainment_sports_recreation` |
| Hospitality & Food Services | `hospitality_food_travel` |
| Personal & Local Services | `personal_local_services` |
| Government & Public Sector | `government_public_sector` |

</details>

---

## Sub-verticals

### Why sub-verticals exist

NAICS codes group businesses by **economic activity** (what they sell), not by **security risk profile**. Two companies with the same NAICS code can have vastly different:

- **Regulatory regimes** (e.g., consumer SaaS vs. healthcare SaaS - both "Software Publishers" under NAICS 513210)
- **Trust boundaries** (e.g., single-tenant vs. multi-tenant, on-prem vs. cloud)
- **Threat actors** (e.g., nation-state targets vs. opportunistic fraud)
- **Failure consequences** (e.g., inconvenience vs. safety-critical harm)

Sub-verticals let us **group use cases that share a security context**, even when they share the same NAICS code.

### The `safe_sv_*` naming convention

Sub-vertical folder names use the `safe_sv_` prefix to signal they are **SAFE-invented categories**, not external standards:

```text
verticals/<vertical_id>/safe_sv_<descriptor>/<use-case-slug>/README.md
```

| Vertical | Sub-vertical folder | What it groups |
|---|---|---|
| `tmt_tech_media_telecom` | `safe_sv_software_saas` | B2B software, ITSM, DevOps tooling workflows |
| `tmt_tech_media_telecom` | `safe_sv_cloud_infrastructure_hosting` | Cloud providers, hosting, multi-tenant platform ops |
| `tmt_tech_media_telecom` | `safe_sv_social_streaming_content_platforms` | Social networks, streaming, UGC platforms |
| `financial_services_insurance` | `safe_sv_banking_credit` | Retail/commercial banking, credit cards, lending |

The `safe_sv_` prefix serves two purposes:

1. **Clarity**: Distinguishes SAFE-curated groupings from external taxonomies.
2. **Humility**: Signals these are working categories, not authoritative industry definitions.

### When to use `general/` vs `safe_sv_*`

| Folder type | When to use |
|-------------|-------------|
| `general/` | Default. Use when no curated sub-vertical exists, or when the use case applies broadly across the vertical. |
| `safe_sv_*` | Use when a SAFE-curated sub-vertical exists and the use case fits its scope. |

**Decision tree:**

```
Start here
    │
    ▼
┌─────────────────────────────────────────────┐
│ Does a safe_sv_* folder already exist       │
│ in your target vertical?                    │
└─────────────────────────────────────────────┘
    │                           │
   YES                          NO
    │                           │
    ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐
│ Does your use case  │    │ Use general/        │
│ fit that sub-       │    │                     │
│ vertical's scope?   │    │ (You're done!)      │
└─────────────────────┘    └─────────────────────┘
    │           │
   YES          NO
    │           │
    ▼           ▼
┌───────────┐  ┌─────────────────────────────────┐
│ Use       │  │ Does your use case share 2+     │
│ safe_sv_* │  │ criteria with other potential   │
│           │  │ use cases? (regulatory, trust,  │
│ (Done!)   │  │ threat actors, consequences)    │
└───────────┘  └─────────────────────────────────┘
                   │               │
                  YES              NO
                   │               │
                   ▼               ▼
              ┌──────────┐    ┌──────────┐
              │ Propose  │    │ Use      │
              │ a new    │    │ general/ │
              │ safe_sv_ │    │          │
              └──────────┘    └──────────┘
```

**Examples:**

- `verticals/retail_ecommerce/general/seller-listing-creation-assistant/` - Applies broadly to retail/ecommerce.
- `verticals/tmt_tech_media_telecom/safe_sv_software_saas/itsm-virtual-service-agent/` - Specific to SaaS/software platform operations.
- `verticals/financial_services_insurance/safe_sv_banking_credit/fraud-alert-card-controls-assistant/` - Specific to banking/credit card workflows.

### Proposing a new sub-vertical

Sub-verticals are created sparingly. Before proposing one, check whether `general/` or an existing sub-vertical already covers your use case.

**Criteria for a new sub-vertical:**

A new `safe_sv_*` sub-vertical is warranted when a cluster of use cases shares **at least two** of the following that differ meaningfully from the rest of the vertical:

1. **Distinct regulatory regime** - Subject to specific regulations (e.g., PCI-DSS for payments, HIPAA for healthcare IT) that impose unique controls.
2. **Different trust boundaries** - Fundamentally different deployment model, data residency, or isolation requirements.
3. **Different threat actors** - Attracts a different threat profile (e.g., nation-state actors, organized fraud rings, opportunistic attackers).
4. **Different failure consequences** - Failures have categorically different impact (e.g., financial loss vs. physical safety).

**To propose a new sub-vertical:**

1. Open an issue describing the proposed sub-vertical name, scope, and which criteria apply.
2. Include at least 2-3 planned use cases that would live there.
3. If accepted, create the folder with a README describing its scope.

### ID policy

- **Use cases** receive stable IDs: `SAFE-UC-XXXX` (e.g., `SAFE-UC-0001`).
- **Sub-verticals do not receive IDs.** They are organizational folders, not versioned artifacts.
- **Verticals do not receive IDs.** They map to NAICS sectors and are named by convention.

The canonical registry (`use-cases.naics2022.crosswalk.json`) tracks use case IDs only.

---

## Seeding strategy (how we decide what to write next)

We seed this library based on **community pull**:

- When people from a new company/vertical start showing up, we create **at least 3 “seed” use cases** that are:
  - general enough to be safe and public,
  - specific enough to be useful,
  - and grounded in public evidence.

A practical way to start:

- Collect **5–10 public references** describing real workflows (docs, engineering blogs, conference talks, incident postmortems, compliance writeups, earnings calls, etc.).
- Pick the **3 most repeatable workflows** and write them up as SAFE-AUCA use cases.

Then we ask domain folks to review:

- “Does this look realistic?”
- “What would you change?”
- “What failure modes are we missing?”

**Do not include sensitive information.** If a workflow is tied to confidential programs, internal system names, customer data, or non-public incidents, it does not belong here.

---

## Contributing

> **Full details:** See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the complete contribution guide, evidence guidelines, writing style, and PR checklist.

**Quick start:**

1. **Choose a workflow family** from the list above.
2. **Pick a vertical folder** where this use case most naturally lives.
3. **Create a new use case folder:**
   ```
   verticals/<vertical_id>/<subvertical_folder>/use-case-slug/README.md
   ```
   Use `general/` when no curated sub-vertical exists; use `safe_sv_*` folders when one applies.

4. **Fill out the template** (`templates/use-case-template.md`).

5. **Update the crosswalk registry** (`use-cases.naics2022.crosswalk.json`).

### Safety + disclosure rules (non-negotiable)

- **No sensitive information** (internal system names, private endpoints, customer data, secrets, non-public incidents).
- **No operational exploitation instructions.** Keep attack analysis defender-friendly.
- **No speculative-only use cases.** Ground writeups in workflows that exist today with public evidence.
