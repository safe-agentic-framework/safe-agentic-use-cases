# Work-item summarization assistant (thread + context summaries)

## Metadata

- **SAFE Use Case ID:** `SAFE-UC-0018`
- **Repo path:** `verticals/tmt_tech_media_telecom/safe_sv_software_saas/work-item-summarization-assistant/README.md`
- **Primary vertical:** Technology, Media & Telecom (TMT) (implied by folder)
- **Sub-vertical:** `safe_sv_software_saas`
- **NAICS 2022:** 51 (Information) → 513210 (Software Publishers)
- **Workflow family:** Case management & customer support
- **Operating modes covered:** manual baseline, human-in-the-loop (HITL), fully autonomous (guardrailed)
- **Evidence (public links):**
  - [Public product documentation: summarize a work item's comments using AI](https://support.atlassian.com/jira-service-management-cloud/docs/summarize-an-issues-comments-using-atlassian-intelligence/)
  - [Public product documentation: explore issues and discussions with an assistant](https://docs.github.com/en/copilot/tutorials/explore-issues-and-discussions)
  - [Public product documentation: summarize a helpdesk ticket using AI](https://help.desk365.io/en/articles/summarize-ticket-using-ai/)

> This use case is written as a **starter template**. Keep it concrete, but do not include sensitive information or internal system names.

---

## 1. Executive summary (what + why)

In modern software teams, a single work item (bug, feature request, incident follow-up, support ticket) can accumulate:

- long comment threads
- status changes and ownership handoffs
- links to other work items
- references to code changes, dashboards, or docs

An **issue/work-item summarization assistant** creates a short, structured summary of the current state of a work item:

- what happened so far
- current status and owner
- key decisions and rationale
- open questions / blockers
- next actions

The goal is to reduce the time it takes for a human to:

- get context during handoffs
- re-triage a reopened ticket
- prepare a status update
- decide whether escalation is needed

This assistant is often the *first* “agentic” workflow inside a company because it can be delivered as a read-only tool with strong safety properties.

---

## 2. Industry context & constraints

### Where this shows up

This workflow is common in:

- SaaS product engineering teams (bugs, features, customer issues)
- IT service management (ITSM) / service desks (incidents, requests, problems)
- customer support escalation queues

### Constraints that matter

- **Access control:** summaries must respect the same permissions as the underlying work item (and any linked objects).
- **Data sensitivity:** work items may contain secrets, credentials, PII, security incident details, or customer data.
- **Auditability:** teams often need to know *what source text produced a summary*.
- **Latency:** users expect a summary in seconds, not minutes.
- **Correctness over creativity:** summaries must be faithful to the thread (hallucinations are harmful).

---

## 3. System & agent architecture

### 3.1 Actors and systems

Typical actors:

- **Requester:** engineer / support agent / on-call / manager
- **Work item system:** issue tracker or ticketing system
- **Identity & access:** SSO / RBAC / group membership
- **LLM runtime:** internal or hosted model
- **Optional context sources (read-only):** docs, runbooks, code review links, incident timelines

### 3.2 High-level flow

```mermaid
flowchart LR
  U[User] -->|click "Summarize"| UI[Issue UI]
  UI -->|request| SVC[Summarization service]
  SVC -->|authZ check| IAM[Identity/Access]
  SVC -->|fetch issue data| ISS[Issue/Ticket system]
  SVC -->|optional retrieval| KB[Docs/Runbooks]
  SVC -->|prompt + context| LLM[LLM]
  LLM -->|draft summary| SVC
  SVC -->|redaction + policy checks| POL[Safety filters]
  POL --> UI
  POL -->|optional: post comment| ISS
```

### 3.3 Trust boundaries

Key trust boundaries to call out in reviews:

1. **Untrusted input boundary:** work-item comments and descriptions can contain adversarial text (prompt injection), untrusted links, or malformed markup.
2. **Permission boundary:** the summarizer must not access or reveal data the requester cannot access.
3. **Model boundary:** the LLM is a probabilistic component. Treat its output as untrusted until validated by controls.
4. **Write boundary (if enabled):** posting a summary back into the issue tracker makes the model output persistent and shareable.

### 3.4 Tool inventory (typical)

Minimum (read-only):

- `issue.read` (description, comments, history, labels, assignee, timestamps)

Optional (read-only, high risk if mis-scoped):

- `issue.search` (search across org tickets)
- `docs.read` (runbooks, internal docs)
- `code.read` (linked diffs, PR summaries)

Optional (write, higher risk):

- `issue.comment.create` (post summary)
- `issue.field.update` (update “Summary”, “Next steps”, “Status” fields)

---

## 4. Operating modes & agentic flow variants

### 4.1 Manual baseline (no agent)

A human reads the issue and writes:

- a handoff note
- a status update
- a summary for a manager/customer

**Risk:** slow, inconsistent; humans miss details; context-switch cost is high.

### 4.2 Human-in-the-loop (HITL)

The assistant generates a draft summary, but a human:

- reviews for accuracy
- removes sensitive content
- decides whether to post it back to the issue

**Typical UX:** “Summarize” button + editable output + “Insert/Copy/Post” actions.

**Risk profile:** mostly bounded to incorrect text. The blast radius stays limited if the summary is not auto-posted.

### 4.3 Fully autonomous (guardrailed)

The system automatically generates summaries on triggers, such as:

- ticket moves to “Waiting on customer”
- reassigned to a new owner
- reopened after closure
- comment thread exceeds N messages

Autonomous mode should be **guardrailed**:

- summaries are posted with a clear label (e.g., “auto-generated draft”)
- owners are notified and can edit/remove
- summaries include citations to source comments

**Risk profile:** higher. Auto-posted hallucinations or leaked secrets become persistent.

### 4.4 Sub-agentic / multi-agent variants (optional)

A common safe pattern is to split into small components:

1. **Collector:** fetches only what the requester is authorized to see.
2. **Summarizer:** produces a structured draft.
3. **Redactor:** removes secrets/PII and enforces output policy.
4. **Verifier:** checks for unsupported claims and forces citations/quotes.

This reduces single-point-of-failure risk.

---

## 5. Threat model overview

### Security goals

- **No data exfiltration:** the summary must not reveal data outside the requester’s access scope.
- **No persistence of sensitive content:** if summaries are posted back, they must not include secrets/PII.
- **No silent mis-triage:** summaries should not systematically mislead prioritization, ownership, or decision-making.

### Primary attack surfaces

- **User-generated text** in issues (comments, descriptions)
- **Attachments and pasted logs** (often contain secrets)
- **Links** (may point to restricted resources or malicious pages)
- **Cross-issue retrieval** (search or linked-ticket expansion)
- **Write actions** (posting comments / updating fields)

### High-impact failures

- Hallucinated root cause or incorrect status that drives a bad decision
- Model copies secrets into a widely visible summary
- Prompt injection causes the model to ignore summarization policy and output unrelated/unsafe content

---

## 6. Kill-chain analysis (stages → likely failure modes)

| Stage | What can go wrong | Impact | Notes |
|---|---|---|---|
| 1. Entry | Adversary creates/edits a ticket or comment with malicious instructions | Sets up prompt injection or misinformation | Can be external reporter or compromised user |
| 2. Context capture | Summarizer ingests untrusted thread text verbatim | Model follows attacker’s “instructions” inside the thread | Treat thread text as untrusted |
| 3. Retrieval expansion | Agent pulls in linked issues/docs beyond requester scope | Data exfiltration via summary | Most common when using global search |
| 4. Generation | Model hallucinates facts or misstates status/owner/decisions | Mis-triage, wrong escalations, bad decisions | Requires verification + structured format |
| 5. Persistence | Auto-posted summary becomes record and spreads | Long-lived misinformation or leakage | Higher risk in autonomous mode |
| 6. Feedback loop | People trust the summary and stop reading the source | Systemic failure mode | Encourage citations + “view sources” UX |

---

## 7. SAFE-MCP mapping (stage → SAFE technique → control)

> Keep this defender-friendly. Do **not** include operational exploit steps.

Use this table as the bridge from the narrative kill-chain to concrete controls and tests.

| Kill-chain stage | Failure/attack pattern | SAFE-MCP technique(s) | Recommended controls | Tests |
|---|---|---|---|---|
| Entry / context capture | Prompt injection via ticket comments | SAFE-T1102 — Prompt Injection (Multiple Vectors) | Treat ticket text as untrusted; strict system prompt; strip/neutralize instruction-like text; do not execute instructions from content | Inject adversarial comments and confirm output remains a summary and policy-compliant |
| Retrieval expansion | Cross-scope data leakage via linked issues/search | SAFE-T1309 — Privileged Tool Invocation via Prompt Manipulation; SAFE-T1801 — Automated Data Harvesting | Permission-check every retrieved object; request-scoped tokens; deny global search unless explicitly enabled; log retrieval set | Attempt to reference restricted ticket IDs and confirm agent refuses / omits |
| Generation | Hallucinated status/decisions | SAFE-T2105 — Disinformation Output | Force structured summaries; require citations (comment IDs); run verifier step; show confidence + “needs review” flags | Golden-set evaluation for factual accuracy; hallucination rate thresholds |
| Persistence | Auto-post leaks secrets/PII | SAFE-T1910 — Covert Channel Exfiltration; SAFE-T1911 — Parameter Exfiltration | Secret scanning + PII filters before posting; default to draft-only; require owner approval for posting | Seed tickets with fake secrets and confirm they are redacted/blocked |
| Feedback loop | Over-trust of summaries | SAFE-T1404 — Response Tampering | UI links back to sources; include “generated summary” label; nudge users to spot-check | Usability tests: do users click sources? |

---

## 8. Mitigations & design patterns

### 8.1 Prevent

- **Least privilege by default:** start with read-only `issue.read`.
- **Permission-scoped retrieval:** the summarizer can only fetch objects the requester can access.
- **No external fetching:** do not let the model fetch URLs in the thread.
- **Structured output:** require a fixed schema so the model cannot wander.
- **Citations:** include comment IDs or timestamps for each major claim.
- **Redaction:** scan inputs/outputs for secrets (tokens, keys) and PII.

### 8.2 Detect

- **Prompt-injection detectors:** flag instruction-like patterns in user-generated text.
- **Policy violations:** log and alert on blocked/redacted generations.
- **Drift monitoring:** track changes in summary quality and hallucination rate.

### 8.3 Recover

- **Kill switch:** ability to disable auto-posting globally.
- **Easy rollback:** delete/replace an auto-posted summary.
- **Human escalation:** let users report “bad summary” and route to owners.

---

## 9. Validation & testing

Minimum test suite to ship safely:

1. **Permission boundary tests**
   - same ticket summarized by two users with different access should produce different outputs (no leakage).

2. **Injection robustness tests**
   - embed malicious instructions in comments; ensure output remains a summary and does not follow the instructions.

3. **Secret/PII redaction tests**
   - include synthetic secrets (API keys) and PII in the thread; ensure they are removed from the output.

4. **Factuality / completeness tests**
   - evaluate summaries against a labeled dataset: status, owner, decisions, next steps.

5. **Latency + reliability tests**
   - ensure summaries complete within target SLOs; degrade gracefully (fallback to partial summaries) instead of timing out silently.

---

## 10. Questionnaire prompts

Use these before enabling broader rollouts:

- **Scope & permissions**
  - Who can request summaries?
  - Can the agent access linked issues? Global search?
  - Are access tokens request-scoped and short-lived?

- **Output safety**
  - Will the summary be displayed only to the requester, or posted back into the ticket?
  - Do we scan for secrets/PII before showing/posting?
  - Do we label the output clearly as model-generated?

- **Correctness**
  - What facts must never be wrong (owner, status, SLA timers, customer-facing commitments)?
  - Do we require citations for key claims?
  - What is the rollback plan if summaries are systematically wrong?

- **Operations**
  - What metrics define success (time saved, handoff quality, reduced reopen loops)?
  - What metrics define danger (leakage incidents, hallucination rate, complaint rate)?
  - Who owns the kill switch?

---

## Appendix: Suggested summary format

A format that tends to work well:

- **TL;DR (1-2 sentences)**
- **Current status** (state, owner, SLA clock)
- **What changed recently** (last 24-72h)
- **Key decisions** (with citations)
- **Open questions / blockers**
- **Next steps** (with owner + due date if available)

