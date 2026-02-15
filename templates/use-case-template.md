# <Use case title>

> **SAFE‑AUCA Use Case Template**
>
> This document is an **industry reference guide** for a real-world agentic workflow. It explains:
> - how the workflow works in practice (tools, data, trust boundaries, autonomy)
> - what can go wrong (defender-friendly kill chain)
> - how it maps to **SAFE‑MCP techniques**
> - what controls + tests make it safer
>
> **Defender-friendly only:** do **not** include operational exploit steps, payloads, or step-by-step attack instructions.  
> **No sensitive info:** do not include internal hostnames/endpoints, secrets, customer data, non-public incidents, or proprietary details.

---

## Metadata

| Field | Value |
|---|---|
| **SAFE Use Case ID** | `SAFE-UC-____` |
| **Status** | `seed` / `draft` / `published` |
| **NAICS 2022** | `<code>, <code>, ...` |
| **Last updated** | `YYYY-MM-DD` |

### Evidence (public links)
> **Required** for `draft` and `published`. **Recommended** for `seed`.

- [<Public reference 1>](https://...)
- [<Public reference 2>](https://...)
- [<Public reference 3>](https://...)

---

## Minimum viable write-up (Seed → Draft fast path)

If you’re converting a `seed` into a first `draft`, aim to complete:
- Executive summary
- Industry context & constraints
- Workflow + scope
- Architecture (tools + trust boundaries + inputs)
- Operating modes
- Kill-chain table
- SAFE‑MCP mapping table (technique IDs may be `TBD` initially)
- Contributors + Version History (add your initial row)

---

## 1. Executive summary (what + why)

**What this workflow does:**  
<1–3 sentences>

**Why it matters (business value):**  
<1–3 sentences>

**Why it’s risky / what can go wrong:**  
<1–3 sentences>

---

## 2. Industry context & constraints (reference-guide lens)

Keep this **high level** (no implementation specifics).

- **Industry-specific constraints:** <regulatory, operational, safety/consumer harm drivers>
- **Typical systems in this industry:** <claim mgmt, policy admin, underwriting, billing, CRM, doc mgmt, etc.>
- **“Must-not-fail” outcomes:** <wrong denial, unsafe payout, privacy breach, unfair outcomes, regulatory penalties>
- **Operational constraints:** <latency, peak volumes, availability, localization, accessibility>

---

## 3. Workflow description & scope

### 3.1 Workflow steps (happy path)
Describe the end-to-end flow as it happens in real life.

1. <Step 1>
2. <Step 2>
3. <Step 3>

### 3.2 In scope / out of scope
- **In scope:** <...>
- **Out of scope:** <...>

### 3.3 Assumptions
- <Assumption 1>
- <Assumption 2>

### 3.4 Success criteria
What does “good” look like?
- <...>

---

## 4. System & agent architecture

### 4.1 Actors and systems
- **Human roles:** <...>
- **Agent/orchestrator:** <...>
- **Tools (MCP servers / APIs / connectors):** <...>
- **Data stores:** <...>
- **Downstream systems affected:** <...>

### 4.2 Trusted vs untrusted inputs (high value, keep simple)

| Input/source | Trusted? | Why | Typical failure/abuse pattern | Mitigation theme |
|---|---|---|---|---|
| Customer free text | Untrusted | external | prompt injection / fraud | isolation + policy |
| Attachments (PDF/images) | Untrusted | external | malicious/irrelevant content | scanning + sandbox |
| Internal KB/docs | Semi-trusted | stale/incorrect | wrong guidance | provenance + review |
| Tool outputs | Mixed | depends on tool | contaminated context | schema + validation |

### 4.3 Trust boundaries (required)
Describe the boundaries where data or control moves between trust zones.

Examples:
- user ↔ agent
- agent ↔ tools
- tool ↔ external APIs
- internal ↔ third-party SaaS
- dev/test ↔ prod

**Trust boundary notes:**
- <Boundary 1: what crosses, auth, logging>
- <Boundary 2: ...>

### 4.4 Tool inventory (required)
List each tool the agent can call and what it can do.

| Tool / MCP server | Read / write? | Permissions | Typical inputs | Typical outputs | Failure modes |
|---|---|---|---|---|---|
| `<tool 1>` | read | `<scopes/roles>` | `<...>` | `<...>` | `<...>` |
| `<tool 2>` | write | `<scopes/roles>` | `<...>` | `<...>` | `<...>` |

### 4.5 Governance & authorization matrix (recommended for draft/published)
This makes the guide actionable without being implementation-specific.

| Action category | Example actions | Allowed mode(s) | Approval required? | Required auth | Required logging/evidence |
|---|---|---|---|---|---|
| Read-only retrieval | <fetch claim status> | manual/HITL/autonomous | no | user session | query logs |
| Write to records | <update notes> | HITL/autonomous | yes (HITL gate) | scoped role | before/after diff |
| High-risk action | <deny claim / approve payout> | manual/HITL only | always | step-up auth | audit trail + rationale |
| External comms | <email/SMS customer> | HITL initially | yes | verified identity | message archive |

### 4.6 Sensitive data & policy constraints
- **Data classes:** <PII/PHI/PCI/secrets/etc.>
- **Retention / logging constraints:** <...>
- **Regulatory constraints:** <...>
- **Safety/consumer harm constraints:** <...>

---

## 5. Operating modes & agentic flow variants

Describe how risk changes across autonomy levels.

### 5.1 Manual baseline (no agent)
- What is manual today?
- What checks/controls exist already?
- Where do humans catch errors?

### 5.2 Human-in-the-loop (HITL / sub-autonomous)
- What does the agent draft vs what does a human approve?
- Where are approval gates?
- What is the agent allowed to execute automatically (if anything)?

### 5.3 Fully autonomous (end-to-end agentic)
- What actions are automated?
- What guardrails exist (policy checks, rate limits, sandboxing, rollback)?
- What is the blast radius if the agent is wrong or manipulated?

### 5.4 Variants (optional)
- Multi-agent / specialist agents
- Different tool stacks
- Offline/batch vs real-time

---

## 6. Threat model overview (high-level)

### 6.1 Primary security & safety goals
- <Goal 1>
- <Goal 2>

### 6.2 Threat actors (who might attack / misuse)
- <Actor 1>
- <Actor 2>

### 6.3 Attack surfaces
- <Surface 1>
- <Surface 2>

### 6.4 High-impact failures (include industry harms)
- **Customer/consumer harm:** <misleading guidance, unfair outcomes, mistaken denial, privacy breach>
- **Business harm:** <fraud loss, regulatory penalties, reputational damage, operational outages>
- **Security harm:** <unauthorized access, exfiltration, integrity attacks, tool misuse>

---

## 7. Kill-chain analysis (stages → likely failure modes)

> Keep this defender-friendly. Describe **patterns**, not “how to do it.”

| Stage | What can go wrong (pattern) | Likely impact | Notes / preconditions |
|---|---|---|---|
| 1. Entry / trigger | <...> | <...> | <...> |
| 2. Context contamination | <...> | <...> | <...> |
| 3. Tool misuse / unsafe action | <...> | <...> | <...> |
| 4. Persistence / repeat | <...> | <...> | <...> |
| 5. Exfiltration / harm | <...> | <...> | <...> |

---

## 8. SAFE‑MCP mapping (kill-chain → techniques → controls → tests)

> Goal: make SAFE‑MCP actionable in this workflow.  
> Use SAFE‑MCP technique IDs like `SAFE-T2107`. Prefer linking to the technique page in the SAFE‑MCP repo.

| Kill-chain stage | Failure/attack pattern (defender-friendly) | SAFE‑MCP technique(s) | Recommended controls (prevent/detect/recover) | Tests (how to validate) |
|---|---|---|---|---|
| <stage> | <pattern> | `SAFE-T____` | <controls> | <tests> |
| <stage> | <pattern> | `SAFE-T____`, `SAFE-T____` | <controls> | <tests> |

**Notes**
- It’s OK if technique IDs are `TBD` in an early draft, but keep the table structure.
- Tests should be repeatable (fixtures, negative tests, logging assertions, rollback tests, etc.).
- If a control depends on operating mode (manual vs HITL vs autonomous), say so.

---

## 9. Controls & mitigations (organized)

Summarize controls in a way implementers can copy into engineering plans.

### 9.1 Prevent (reduce likelihood)
- <...>

### 9.2 Detect (reduce time-to-detect)
- <...>

### 9.3 Recover (reduce blast radius)
- <...>

---

## 10. Validation & testing plan

### 10.1 What to test (minimum set)
- **Permission boundaries:** agent cannot exceed intended scopes
- **Prompt/tool-output robustness:** agent resists malicious/untrusted content patterns
- **Action gating:** high-risk actions require approvals (where applicable)
- **Logging/auditability:** actions are attributable and reviewable
- **Rollback / safety stops:** system can halt and reverse unsafe actions

### 10.2 Test cases (make them concrete)

| Test name | Setup | Input / scenario | Expected outcome | Evidence produced |
|---|---|---|---|---|
| `<test 1>` | <...> | <...> | <...> | logs / screenshots / traces |
| `<test 2>` | <...> | <...> | <...> | logs / traces |

### 10.3 Operational monitoring (production)
- Metrics: <...>
- Alerts: <...>
- Runbooks: <...>

---

## 11. Open questions & TODOs

- [ ] <Question 1>
- [ ] <Missing evidence link>
- [ ] <Technique IDs to confirm>
- [ ] <Tests to implement>

---

## 12. Questionnaire prompts (for reviewers)

### Workflow realism
- Are the tools and steps realistic for this industry?
- What major system integration or constraint is missing?

### Trust boundaries & permissions
- Where are the real trust boundaries?
- What’s the true blast radius of a bad tool call?

### Threat model completeness
- What threat actor is most relevant here?
- What is the highest-impact failure we haven’t described?

### Controls & tests
- Which controls are “must-have” vs “nice-to-have”?
- Are the proposed tests sufficient to detect regressions?

---

## Appendix (optional)

### A. Glossary
- <Term>: <definition>

### B. References (optional)
- <extra links or citations>


---

## Version History

| Version | Date | Changes | Author |
|---|---|---|---|
| 1.0 | YYYY-MM-DD | Initial documentation of `SAFE-UC-____` use case | <Name> |
