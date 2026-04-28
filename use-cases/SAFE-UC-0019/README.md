# Post-incident review drafting assistant

> **SAFE‑AUCA industry reference guide (draft)**
>
> This use case describes a workflow that has become standard at scale across SaaS, cloud, financial services, and any organization with on-call rotations: an AI assistant that takes the artifacts of a production or security incident (timeline, alerts, chat transcripts, tool-call audit logs, customer-impact data, on-call notes) and drafts the post-incident review. The PIR is then reviewed by a named human and used as the input to internal blameless retrospective practice and, when the incident crosses a regulatory threshold, to external disclosure (NIS 2 Article 23, SEC Form 8-K Item 1.05, GDPR Article 33, HIPAA 45 CFR 164.412, state breach-notification laws, customer status-page communication, executive briefing).
>
> It sits downstream of two close cohort siblings: SAFE-UC-0024 (terminal-based outage assistant for SRE, where many of the artifacts are produced) and SAFE-UC-0022 (security operations investigation assistant, where the security-incident artifacts are produced). The defining inversion versus those two is that **here the AI's primary output IS the regulated text**. In 0024 the assistant proposes shell commands that a human approves. In 0022 the assistant proposes investigative actions. In 0019 the assistant directly drafts the narrative that may be filed with the SEC, notified to a national CSIRT under NIS 2, surfaced to affected customers under HIPAA breach notification, or used as evidence in a class-action discovery. A hallucinated fact in a 0024 shell command typically gets caught at the approval prompt; a hallucinated fact in a 0019 PIR draft can land verbatim in a Form 8-K and become a securities-disclosure problem.
>
> It focuses on:
>
> * how the workflow works in practice (tools, data, trust boundaries, autonomy)
> * what can go wrong (defender-friendly kill chain)
> * how it maps to **SAFE‑MCP techniques**
> * what controls + tests make it safer
>
> **Defender-friendly only:** do **not** include operational exploit steps, payloads, or step-by-step attack instructions.
> **No sensitive info:** do not include internal hostnames/endpoints, secrets, customer data, non-public incidents, or proprietary details.

---

## Metadata

| Field                | Value                                                              |
| -------------------- | ------------------------------------------------------------------ |
| **SAFE Use Case ID** | `SAFE-UC-0019`                                                     |
| **Status**           | `draft`                                                            |
| **Maturity**         | draft                                                              |
| **NAICS 2022**       | `51` (Information); `5132` (Software Publishers); `5182` (Computing Infrastructure Providers and Data Processing Services); `5415` (Computer Systems Design and Related Services) |
| **Last updated**     | `2026-04-27`                                                       |

### Evidence (public links)

* [Google SRE Workbook, Chapter 10: Postmortem Culture: Learning from Failure (the canonical "blameless postmortem" reference; widely-adopted vocabulary)](https://sre.google/workbook/postmortem-culture/)
* [PagerDuty: Postmortems documentation (the legacy postmortems.pagerduty.com community guide remains the de facto reference; the workflow-product is now PagerDuty AI for Incident Management)](https://postmortems.pagerduty.com/)
* [incident.io: Post-mortem features (post-mortem template, AI-generated summary, action-item tracking)](https://incident.io/post-mortem)
* [FireHydrant: Retrospectives + Reliability AI](https://firehydrant.com/product/retrospectives/)
* [Rootly: Retrospectives and Rootly AI for incident communications](https://rootly.com/features/retrospectives)
* [Atlassian Statuspage: Best practices for incident communication](https://www.atlassian.com/software/statuspage/best-practices/how-to-write-a-good-incident-postmortem)
* [Datadog Bits AI for incident management (AI-generated incident summaries)](https://www.datadoghq.com/product/platform/bits-ai/)
* [ServiceNow Now Assist for IT Service Management (generative AI for incident management workflows)](https://www.servicenow.com/products/now-assist-for-itsm.html)
* [SEC Cybersecurity Disclosure Rules: Form 8-K Item 1.05 (final rule released 26 July 2023; compliance deadline 18 December 2023; smaller-reporting-company deadline 15 June 2024)](https://www.sec.gov/newsroom/press-releases/2023-139)
* [Directive (EU) 2022/2555 (NIS 2): Article 23 incident reporting (24-hour early warning, 72-hour notification, 1-month final report)](https://eur-lex.europa.eu/eli/dir/2022/2555/oj)
* [Regulation (EU) 2016/679 (GDPR): Article 33 personal-data-breach notification (72 hours)](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
* [NIST SP 800-61 Rev 2: Computer Security Incident Handling Guide (August 2012; revision 3 in development)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)
* [ISO/IEC 27035-1:2023: Information security incident management, Part 1, Principles and process](https://www.iso.org/standard/78973.html)
* [ISO/IEC 27035-2:2023: Information security incident management, Part 2, Guidelines to plan and prepare for incident response](https://www.iso.org/standard/78974.html)
* [HIPAA Breach Notification Rule (45 CFR 164.400 to 164.414): timing requirements for individual notice and HHS reporting](https://www.hhs.gov/hipaa/for-professionals/breach-notification/index.html)
* [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)
* [NIST AI 600-1: AI Risk Management Framework Generative AI Profile (July 2024)](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)
* [SOC 2 Trust Services Criteria (2017 with revised points of focus 2022): CC7.3 incident response and CC7.4 incident monitoring](https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2)

---

## Minimum viable write-up (Seed → Draft fast path)

This document covers:

* Executive summary
* Industry context and constraints
* Workflow and scope
* Architecture (tools, trust boundaries, inputs)
* Operating modes
* Kill-chain table (8 stages)
* SAFE‑MCP mapping table (17 techniques)
* Contributors and Version History

---

## 1. Executive summary (what + why)

**What this workflow does.**
A **post-incident review drafting assistant** is an AI-augmented system that ingests the artifacts of an incident (the timeline, the alert chain, the on-call chat transcript, the tool-call audit log, the customer-impact data, the responder notes, the runbook references) and drafts the post-incident review. Typical drafted artifacts include:

* the canonical PIR document (executive summary, timeline, contributing factors, action items, lessons learned)
* a 5-whys or causal-chain analysis
* a customer-facing status-page update at incident close
* a draft NIS 2 Article 23 24-hour early warning, 72-hour incident notification, or 1-month final report when the incident is reportable to a national CSIRT
* a draft SEC Form 8-K Item 1.05 disclosure when the incident is determined material at a publicly-traded registrant
* a draft GDPR Article 33 personal-data-breach notification to the supervisory authority within 72 hours
* a draft HIPAA 45 CFR 164.412 breach notification
* an executive briefing
* an action-item set with owners, due dates, and acceptance criteria, suitable for sync into Jira, Linear, or ServiceNow

Industry deployments span the full incident-management vendor landscape. **PagerDuty** has run the long-standing community PIR template at postmortems.pagerduty.com and ships AI for Incident Management features. **incident.io** ships a post-mortem feature with AI-generated summaries and action-item tracking. **FireHydrant** ships Retrospectives plus Reliability AI. **Rootly** ships Retrospectives and Rootly AI for incident communications. **Atlassian Jira Service Management** plus Statuspage and Confluence Postmortem templates anchor a large share of the enterprise market. **Squadcast**, **Blameless**, and **Spike.sh** anchor the post-incident-review-specific vendor cluster. **Datadog Bits AI** and **ServiceNow Now Assist for ITSM** ship adjacent generative-AI features. **GitHub Copilot for security** shipped incident-narrative features in 2025. Internal-tool deployments commonly route through **AWS Bedrock** or **Azure OpenAI Service** with retrieval over the org's incident corpus.

**Why it matters (business value).**
The PIR is the operational record of how the org responded to an incident. It is the input to ITIL Major Incident Management, ISO/IEC 27035 incident handling, the SOC 2 CC7.3 incident-response control objective, the NIS 2 Article 23 reporting workflow, and the SEC Item 1.05 4-business-day materiality clock. PagerDuty community materials and Google's SRE Workbook (Chapter 10, "Postmortem Culture") have shaped a generation of practitioner expectation: blameless culture, timeline accuracy, contributing-factor analysis over single-root-cause assignment, and action-items-with-owners as the closing artifact. The drafted PIR shortens the time from incident close to learning, surfaces patterns across incidents that humans miss, and turns regulatory-disclosure-window stress into a structured workflow.

**Why it is risky / what can go wrong.**
This workflow's defining trait is the inversion versus its closest cohort siblings: **here the AI's primary output IS the regulated text**. SAFE-UC-0024's terminal SRE assistant proposes a shell command and a human approves it before execution. SAFE-UC-0022's SOC investigator proposes a query and a human runs it. SAFE-UC-0019's PIR drafter writes a narrative that, in the worst case, lands verbatim in a Form 8-K, a NIS 2 Article 23 notification, or a HIPAA 45 CFR 164.412 breach letter. The blast radius of a hallucinated fact is the regulator's filing cabinet, the company's quarterly earnings call, the customer's litigation file, and the auditor's working papers.

Eight concurrent risk surfaces define this workflow as of 2026, and four of them have no exact analog in any prior SAFE-AUCA cohort use case.

* **Timeline-fact integrity.** A PIR is built on a timestamped sequence of events. AI-drafted timelines pull from chat transcripts, alert logs, tool-call audits, and on-call notes. Hallucinated timestamps, hallucinated alert ordering, and hallucinated operator-action sequencing land as fact in the regulator's notification when the document is approved under deadline pressure. The Garner v. Amazon (W.D. Wash., July 7, 2025) class certification standard for evidence preservation applies symmetrically.
* **Hallucinated root cause.** 5-whys and causal-chain analysis are inherently inferential; a hallucinated middle step in the chain redirects remediation. The wrong fix gets prioritized; the right fix gets deferred. This is the single most consequential PIR drafting failure for engineering org effectiveness over time.
* **Action-item attribution and commitment fabrication.** PIR action items are commitments. An AI-drafted "action-item: SRE team will implement X by date Y" is a commitment the named team did not make. When the action item flows into Jira or Linear and gets sized into a sprint, the fabrication compounds.
* **External-regulator disclosure hallucination.** The SEC Form 8-K Item 1.05 final rule (released 26 July 2023; effective for large filers 18 December 2023; small filers 15 June 2024) requires registrants to disclose material cybersecurity incidents within 4 business days of the materiality determination. NIS 2 Article 23 requires a 24-hour early warning, a 72-hour notification, and a 1-month final report from "essential" or "important" entities. GDPR Article 33 requires personal-data-breach notification to the supervisory authority within 72 hours. HIPAA 45 CFR 164.412 requires breach notification without unreasonable delay and no later than 60 days for breaches affecting fewer than 500 individuals (or contemporaneously to the HHS Secretary for breaches of 500 or more). An AI-hallucinated fact in any of these filings is a securities, NIS 2, GDPR, or HIPAA enforcement event.
* **Sensitive-data leakage in the draft.** PIRs touch customer identifiers, employee names, third-party supplier names, security-vulnerability detail (which may be exploitable if disclosed externally), monetary impact estimates, and internal architecture detail. Default-on inclusion in the AI-drafted text is a privacy and security exposure, even when the draft is internal-only because internal-only drafts get circulated, attached to litigation discovery, and surfaced through SaaS-vendor breaches (the LastPass, Snowflake, and Salesloft Drift class of incident).
* **Materiality-determination influence.** The SEC Item 1.05 4-business-day clock starts at materiality determination, not at incident detection. AI-assisted summarization of an incident's blast radius is increasingly an input to the materiality call. An AI summary that systematically downplays severity delays the disclosure clock; an AI summary that systematically overstates severity over-discloses.
* **Blameless-culture drift.** The PagerDuty postmortems community guide and the Google SRE Workbook Chapter 10 codify the blameless-culture norm. AI-drafted PIRs that surface individual-name attributions in the timeline (which the source-data does contain) drift away from blameless culture by default. The drift is invisible until a named individual surfaces in a discovery filing.
* **Corpus poisoning across the ISO 27035 incident-management system.** The PIR is the input to the org's incident-knowledge corpus. AI-drafted PIRs with hallucinated facts seed the next year's pattern detection. A poisoned corpus produces wrong cross-incident pattern claims that themselves become the input to next year's regulatory disclosures.

A defining inversion versus 0024 SRE: in 0024 the responder is in the loop on every command. In 0019 the responder reviews a draft after the AI has assembled it, and review-fatigue under deadline pressure is the central failure mode. The PagerDuty incident commander running a SEV-0 at 3 a.m. who has just spent 8 hours containing the incident is a structurally weak reviewer of a 12-page AI-drafted regulator filing.

---

## 2. Industry context & constraints (reference-guide lens)

### Where this shows up

Common in:

* SaaS and cloud-native engineering organizations with on-call rotations (every PagerDuty / incident.io / FireHydrant / Rootly customer)
* publicly-traded organizations subject to SEC Form 8-K Item 1.05 cybersecurity-incident disclosure
* EU "essential" or "important" entities under NIS 2 Directive (large parts of digital infrastructure, energy, transport, banking, financial markets, health, drinking water, public administration, postal, waste, manufacture)
* HIPAA-regulated covered entities and business associates with breach-notification obligations (45 CFR 164.412)
* GDPR controllers and processors with personal-data-breach notification obligations (Article 33 to the supervisory authority within 72 hours; Article 34 to data subjects without undue delay)
* PCI DSS 4.0.1-scoped entities under Requirement 12.10 (incident response plan)
* SOC 2 Type II audited organizations (CC7.3 incident response, CC7.4 incident monitoring)
* federal contractors subject to FedRAMP IR (Incident Response) family controls
* DORA-regulated EU financial entities (Regulation (EU) 2022/2554, applicable from 17 January 2025; major-ICT-related-incident classification and reporting)
* US bank service providers subject to the Computer-Security Incident Notification Rule (12 CFR Parts 53, 225, 304; 36-hour notification to primary federal regulator)
* US public companies under SEC cyber rules and the parallel state-AG breach-notification regimes (all 50 states have breach-notification laws)
* state-AG-investigated breach notifications across the 50 US states
* ITIL 4 Major Incident Management practitioners and the broader change-and-release-management overlay

### Typical systems

* incident-management platforms (PagerDuty, incident.io, FireHydrant, Rootly, Squadcast, Blameless, Spike.sh, OpsGenie, ServiceNow Major Incident Management, Atlassian Jira Service Management)
* status-page communication (Statuspage, Status.io, Better Stack Status, internal status-page tools)
* alerting (PagerDuty, OpsGenie, Splunk On-Call, AlertManager)
* observability (Datadog, Splunk, New Relic, Grafana / Loki / Tempo, Honeycomb, Lightstep / ServiceNow Cloud Observability, Dynatrace)
* chat (Slack, Microsoft Teams, Discord); the PIR drafter typically reads the incident channel transcript
* ticketing and issue tracking (Jira, Linear, ServiceNow, Asana, GitHub Issues)
* document repositories (Confluence, Notion, Google Docs, SharePoint, internal wiki)
* security-incident workflow (the SAFE-UC-0022 SOC investigation pipeline; SOAR platforms; SIEM systems)
* regulatory-filing tooling (corporate-secretary platforms for SEC filings; CSIRT-portal connectors for NIS 2; HHS OCR breach portal for HIPAA; CPPA portal for California; state-AG portals)
* AI/ML: foundation-model retrievers grounded in the incident corpus; chain-of-thought summarizers; LLM-drafted action-item suggesters; RAG over runbooks and prior PIRs; named-entity-recognition for sensitive-data redaction
* business-continuity and disaster-recovery systems aligned with ISO 22301:2019

### Constraints that matter

* **SEC Form 8-K Item 1.05 (released 26 July 2023; effective for large accelerated filers 18 December 2023; for smaller reporting companies 15 June 2024).** Material cybersecurity incidents are reportable within 4 business days of the materiality determination. The materiality determination is itself a process. Item 106 of Regulation S-K requires annual disclosure of cybersecurity risk management, strategy, and governance.
* **NIS 2 Directive (EU) 2022/2555 Article 23.** "Essential" or "important" entities are required to file a 24-hour early warning, a 72-hour incident notification with an initial assessment, and a 1-month final report (or, where the incident is ongoing, a progress report and a final report when the incident concludes). Member states transposed by 17 October 2024 with significant variance in penalty regime.
* **GDPR (Regulation (EU) 2016/679) Article 33.** Personal-data-breach notification to the supervisory authority within 72 hours of becoming aware. Article 34 requires notification to affected data subjects without undue delay when the breach is high-risk.
* **HIPAA Breach Notification Rule (45 CFR 164.400 to 164.414).** Covered entities notify affected individuals without unreasonable delay and no later than 60 days; HHS notifications follow on the same individual-notification basis or contemporaneously for breaches of 500 or more. State-AG and media notification at the 500-individual threshold per state.
* **Federal banking Computer-Security Incident Notification Rule (12 CFR Parts 53, 225, 304).** Banking organizations notify their primary federal regulator within 36 hours of determining a notification incident has occurred. Bank service providers notify affected banks "as soon as possible."
* **DORA (Regulation (EU) 2022/2554; applicable 17 January 2025).** Financial entities classify ICT-related incidents per Commission Delegated Regulation criteria; major incidents have Article 19 reporting timelines (early warning, intermediate report, final report).
* **PCI DSS 4.0.1 Requirement 12.10.** Incident-response plan with documented roles, communication protocols, legal and contractual reporting, and BCP recovery.
* **SOC 2 Trust Services Criteria CC7.3 and CC7.4.** Incident-response and incident-monitoring obligations for service organizations seeking SOC 2 Type II attestation.
* **NIST SP 800-61 Rev 2 (August 2012; Rev 3 draft in development at NIST CSRC).** The federal incident-handling guide; FedRAMP IR controls trace through SP 800-53 Rev 5 to this guide.
* **ISO/IEC 27035-1:2023 and 27035-2:2023.** International incident-management framework; commonly cross-referenced in ISO/IEC 27001 ISMS audits.
* **ISO 22301:2019 BCMS.** Business-continuity management; the recovery side of the post-incident workflow.
* **ITIL 4 Major Incident Management.** The de facto vocabulary for major-incident workflow at most enterprise IT shops.
* **EU AI Act (Regulation (EU) 2024/1689) Article 50.** Transparency obligations: the user is informed they are interacting with an AI system. Annex III categories typically do not apply to PIR drafting since the AI does not make a decision with legal effect; the human signer of the disclosure does.
* **State-AG breach-notification laws across all 50 US states.** Material variance in the timing windows, the trigger (encrypted-data exception), and the AG-notification-versus-individual-notification thresholds.
* **Litigation discovery and SOX 404 internal-controls implications.** The PIR is a discoverable record. SOX 404 internal-controls assessments cover the disclosure-controls process around material cybersecurity incidents.

### Must-not-fail outcomes

* drafting and surfacing as final a PIR with a hallucinated timestamp, alert ordering, or operator-action sequence that lands in a regulator filing
* drafting and surfacing as final a PIR with a hallucinated root-cause assignment that drives the wrong remediation
* drafting an action-item assigning a commitment to a named team that never agreed to it
* drafting an external-regulator filing (SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412) with a hallucinated material-fact claim
* leaking customer identifiers, employee names, supplier names, or exploitable vulnerability detail in an internal-only PIR that subsequently propagates
* influencing the SEC Item 1.05 materiality determination through a systematic AI-summary bias that delays or over-discloses
* drifting away from blameless culture by surfacing individual-attributed timeline entries in the published PIR
* poisoning the ISO 27035 incident-knowledge corpus with hallucinated cross-incident pattern claims

---

## 3. Workflow description & scope

### 3.1 Workflow steps (happy path)

1. An incident closes (or transitions out of active response). Triggers include the incident-management platform marking the incident resolved, the incident commander handing off, or a scheduled-time PIR cadence.
2. The PIR drafter ingests artifacts: timeline events from PagerDuty / incident.io / FireHydrant / Rootly / Statuspage; the incident-channel chat transcript from Slack or Teams; alert events from the alerting layer; observability traces and metrics from Datadog / Splunk / Honeycomb; the tool-call audit log from any SAFE-UC-0024 terminal SRE assistant or SAFE-UC-0022 SOC investigator session; the responder's notes and runbook references; customer-impact data from status-page subscriptions and customer-success tickets.
3. The drafter classifies the incident: severity tier, affected systems, affected customers, regulated-data classes touched, jurisdictions, and the corresponding regulator-disclosure obligations.
4. The drafter assembles a timeline. Entries are timestamp-ordered with source attribution; the drafter flags low-confidence entries and missing intervals.
5. The drafter drafts the PIR sections: executive summary, scope and impact, timeline, what went well, what went wrong, contributing factors (a 5-whys or causal-chain analysis; the drafter avoids single-root-cause framing per Google SRE Workbook Chapter 10), action items with proposed owners and due dates.
6. When the incident crosses a regulator-disclosure threshold, the drafter assembles the corresponding draft filings: SEC Form 8-K Item 1.05 narrative section, NIS 2 Article 23 24-hour early warning or 72-hour notification, GDPR Article 33 supervisory-authority notification, HIPAA 45 CFR 164.412 breach notification, state-AG notifications, customer-comm draft, executive briefing.
7. A named human (the incident commander, an engineering manager, the security officer for security incidents, the privacy officer for personal-data-breach incidents, the SEC-disclosure committee for material cyber events, regulatory counsel for external filings) reviews the draft and either signs, edits, or rejects.
8. Action items sync into Jira, Linear, or ServiceNow with owner attribution captured from the PIR review meeting.
9. The signed PIR is filed in the org's incident-knowledge repository and indexed for cross-incident pattern detection in the next cycle.

### 3.2 In scope / out of scope

* **In scope:** AI-drafted PIR composition from incident artifacts; timeline reconstruction with source-attributed entries; 5-whys and causal-chain analysis with explicit confidence signals; action-item generation with proposed owners and due dates; AI-drafted external-regulator disclosure narratives (SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412, state-AG notifications, customer status-page comms); cross-incident pattern detection over the historical PIR corpus.
* **Out of scope:** the materiality determination itself (which is a named-human-and-counsel decision; the AI may inform it but does not make it); fully autonomous filing of any regulator submission without a named human signer; AI-only assignment of blame to an individual employee or contractor; AI-drafted internal-investigation conclusions used in employment-law decisions; AI-drafted litigation responses; AI-only responses to law-enforcement subpoenas.

### 3.3 Assumptions

* The org operates an incident-management platform (PagerDuty, incident.io, FireHydrant, Rootly, ServiceNow, or equivalent) and a single source of truth for incident timeline data.
* The org has a documented incident-response plan that names the incident commander, the security officer, the privacy officer, regulatory counsel, and the SEC-disclosure committee where applicable.
* SOC 2 CC7.3 and CC7.4 controls are in place and the AI drafter operates within them, not around them.
* Regulator-disclosure templates exist in pre-approved language for the org's regulated entities (SEC Item 1.05 boilerplate, NIS 2 Article 23 template, GDPR Article 33 template, HIPAA 45 CFR 164.412 template).
* The blameless-culture norm is documented and the PIR review process is named-human-attributed throughout.
* The historical PIR corpus is per-tenant for multi-tenant SaaS deployments; cross-tenant aggregation requires explicit named-human review.

### 3.4 Success criteria

* Every drafted PIR is reviewed and signed by a named human before it leaves the AI-drafted state.
* Every drafted regulator filing is reviewed and signed by named human counsel before submission.
* Timeline entries are source-attributed; low-confidence entries are flagged; missing intervals are surfaced rather than fabricated.
* 5-whys and causal-chain entries cite source artifacts; single-root-cause framing is avoided.
* Action items are reviewed and confirmed with named owners before sync into the issue tracker.
* Sensitive-data classes (PII, PHI, PCI, vulnerability detail, supplier names, monetary impact) are policy-controlled in the draft; the default is redaction or minimum-necessary.
* The materiality determination remains a named-human decision; the AI's summary is one input among many.
* The historical PIR corpus is per-tenant isolated; cross-tenant pattern detection requires named-human approval.

---

## 4. System & agent architecture

### 4.1 Actors and systems

* **Human roles:** incident commander; on-call SRE or platform engineer; security officer; privacy officer (data-protection officer where GDPR applies); engineering manager; product manager; customer-success owner; regulatory counsel; SEC-disclosure committee chair (for publicly-traded registrants); communications lead; CFO and CISO (for material cyber events); auditors and SOC 2 compliance reviewers.
* **Agent / orchestrator:** the PIR drafter, the timeline reconstructor, the 5-whys analyzer, the action-item generator, the regulator-filing drafter, the cross-incident pattern detector.
* **LLM runtime:** typically a hosted foundation model behind the incident-management platform's AI features (PagerDuty, incident.io, FireHydrant, Rootly built-in) or an internal Bedrock / Azure OpenAI deployment with retrieval over the incident corpus.
* **Tools (MCP servers / APIs / connectors):** PagerDuty Events / Incidents API; incident.io API; FireHydrant API; Rootly API; Slack and Microsoft Teams API; Statuspage API; Datadog Logs / Metrics / Traces / Bits AI; Splunk; Honeycomb; Jira / Linear / ServiceNow; Confluence / Notion / Google Docs; corporate-secretary EDGAR-filing tools; CSIRT-portal connectors for NIS 2; HHS OCR breach portal for HIPAA; DPA portals for GDPR; state-AG portals.
* **Data stores:** the incident-event store; the chat-transcript archive; the alert-event store; the observability time-series and trace store; the tool-call audit log archive; the historical PIR corpus; the regulator-filing template store; the customer-comm template store; the action-item tracker.
* **Downstream systems affected:** the regulator's filing cabinet (SEC EDGAR, national CSIRT, DPA, HHS OCR, state AG); the affected customers; the org's status page; the org's executive briefing channel; the engineering org's Jira / Linear / ServiceNow board; the SOC 2 Type II audit working papers; the litigation-discovery archive.

### 4.2 Trusted vs untrusted inputs

A distinguishing feature of this workflow is that **almost every input class is at least semi-untrusted by construction**, because the incident itself often involves an attacker who has injected content somewhere in the chain.

| Input / source                                                | Trusted?                  | Why                                                                                                              | Typical failure / abuse pattern                                                                                                                                  | Mitigation theme                                                                                                                                |
| ------------------------------------------------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Timeline events from incident-management platform             | Authoritative-but-tamperable | platform is the source of truth, but timestamp updates by responders are inherently subjective                  | hallucinated entry; timestamp drift across timezones; missing intervals fabricated by the drafter                                                                 | source-attributed entries; explicit confidence signals; flag missing intervals rather than fabricate                                            |
| Slack / Teams incident channel transcript                     | Untrusted                  | free-text from many responders, potentially with attacker-injected content via tool integrations                   | adversarial chat content steers the drafter; private-channel context bleed; participant-name attribution drift                                                    | quote-isolation; per-channel scope; participant-name redaction by default                                                                       |
| Alert events from PagerDuty / OpsGenie / AlertManager        | Authoritative              | originated by monitoring; tamper-evident at the source                                                            | misinterpreted ordering; missing alerts mistaken for non-occurrence                                                                                              | source citation; timestamp normalization; missing-alert detection                                                                               |
| Observability traces, logs, metrics                          | Untrusted                  | logs may contain attacker-supplied content (the SAFE-UC-0024 lesson)                                              | indirect prompt injection through log content                                                                                                                    | quote-isolation; size-cap; structured-output schema                                                                                              |
| Tool-call audit log from SAFE-UC-0024 SRE session            | Authoritative              | tamper-evident if the audit pipeline is properly configured                                                       | replay misattribution; agent-attributed actions confused with human-attributed actions                                                                           | preserve agent / human distinction in audit log; cross-reference SAFE-UC-0024 attribution model                                                  |
| On-call responder notes                                      | Trusted-but-incomplete    | first-person but written under time pressure                                                                      | gaps; recency bias; uncertainty mistaken for fact                                                                                                                | flag uncertainty signals; do not promote responder hypothesis to PIR-fact without corroboration                                                  |
| Runbook references                                           | Semi-trusted               | internal but may be stale                                                                                          | citation of stale runbook as if current; prescriptive guidance from a deprecated runbook                                                                        | provenance; version pinning; staleness check                                                                                                    |
| Customer-impact data from Statuspage and customer-success    | Untrusted                  | external-source-derived; customer reports may be inaccurate                                                       | scope inflation or scope downplay based on selective customer reports                                                                                            | corroborate with telemetry; report ranges with confidence signal                                                                                |
| LLM drafter output                                           | Untrusted-by-construction  | probabilistic                                                                                                     | hallucinated timestamp, hallucinated root cause, fabricated action-item commitment, hallucinated regulatory fact                                                 | grounded-retrieval-only on regulated text; verbatim source citation; named-human review on every external-facing draft                          |
| Regulator-filing templates                                   | Authoritative              | pre-approved by counsel                                                                                            | template drift; jurisdictional variant mis-selected                                                                                                              | template version pinning; jurisdiction-aware template selection; named-counsel review                                                            |
| Cross-tenant historical PIR corpus                           | Tenant-scoped              | shared in multi-tenant SaaS; cross-tenant aggregation is sensitive                                                | cross-tenant context bleed                                                                                                                                       | per-tenant scoping; named-human review for any cross-tenant aggregation                                                                          |
| MCP server tool descriptions                                 | Semi-trusted               | authored upstream; the SAFE-UC-0024 lesson on tool poisoning                                                      | tool-description poisoning shaping drafter behavior                                                                                                              | pin and sign manifests; registry verification                                                                                                    |

### 4.3 Trust boundaries

Teams commonly model seven boundaries when reasoning about this workflow:

1. **Incident-artifact-to-drafter boundary.** Every artifact entering the drafter is treated as data, not instruction; SAFE-UC-0024's untrusted-input rule applies symmetrically here.
2. **Drafter-to-internal-PIR boundary.** The internal PIR draft is reviewed by a named human (incident commander or designated reviewer) before sign-off; sensitive-data redaction policy applies before storage.
3. **Drafter-to-customer-comm boundary.** Customer-facing status-page text and customer notifications are reviewed by communications lead and counsel where applicable; default-on customer-data redaction.
4. **Drafter-to-action-item boundary.** Action items with proposed owners are confirmed in a named-human review meeting before sync to Jira, Linear, or ServiceNow.
5. **Drafter-to-external-regulator boundary.** Every draft regulator filing (SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412, state-AG, banking 36-hour, DORA Article 19) is signed by named counsel before submission.
6. **Drafter-to-materiality-determination boundary.** The materiality call (SEC Item 1.05 trigger; NIS 2 significant-incident classification; GDPR high-risk classification under Article 34) is a named-human decision; the AI's summary is one input.
7. **Cross-tenant historical-corpus boundary.** Cross-tenant pattern detection requires explicit named-human review and federation agreement.

### 4.4 Permission and approval design

* **PIR draft to internal sign-off** requires named-human review by the incident commander or designated reviewer.
* **Action-item sync to Jira / Linear / ServiceNow** requires confirmation in a named-human review meeting; AI-proposed owners are not auto-assigned.
* **Customer-comm publication** requires communications-lead approval and (for material cyber, personal-data breaches, or HIPAA-covered breaches) named counsel.
* **External regulator filing** (SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412, state-AG, banking 36-hour, DORA Article 19) requires named regulatory counsel signoff.
* **SEC Item 1.05 materiality determination** is a named-committee decision (typically the SEC-disclosure committee with CISO, CFO, GC, and CEO input); the AI's summary is one input.
* **Cross-tenant pattern detection over the historical PIR corpus** requires named-human review and an explicit federation agreement.

### 4.5 Tool inventory

| Tool / connector                                              | Read / Write   | Scope                               | Risk class                                                                        |
| ------------------------------------------------------------- | -------------- | ----------------------------------- | --------------------------------------------------------------------------------- |
| PagerDuty Incidents / Events API                              | Read           | Per-tenant, per-incident            | Authoritative incident timeline                                                    |
| incident.io / FireHydrant / Rootly API                        | Read           | Per-tenant, per-incident            | Authoritative incident workflow                                                    |
| Slack / Microsoft Teams API                                   | Read           | Per-channel, per-incident           | Sensitive PII; participant-name attribution surface                                |
| Datadog Logs / Bits AI / Splunk / Honeycomb                   | Read           | Per-service, per-incident           | Sensitive PII; secret-shaped string surface                                        |
| Statuspage API                                                | Read + Write   | Per-product                         | Customer-comm publication path                                                     |
| Jira / Linear / ServiceNow                                    | Read + Write   | Per-project; gated for action-item create | Action-item commitment surface                                              |
| Confluence / Notion / Google Docs                             | Read + Write   | Per-space; gated for PIR-publish    | Internal PIR publication path                                                      |
| Corporate-secretary EDGAR connector                           | Write (egress) | Per-registrant; named-counsel-gated | SEC Item 1.05 filing surface                                                       |
| CSIRT-portal connector                                        | Write (egress) | Per-jurisdiction; named-counsel-gated | NIS 2 Article 23 filing surface                                                  |
| HHS OCR breach-portal connector                               | Write (egress) | Per-covered-entity; named-counsel-gated | HIPAA 45 CFR 164.412 filing surface                                            |
| DPA-portal connectors                                         | Write (egress) | Per-jurisdiction; named-counsel-gated | GDPR Article 33 filing surface                                                  |
| State-AG portal connectors                                    | Write (egress) | Per-state; named-counsel-gated      | State-breach-notification filing surface                                           |
| Banking 36-hour notification connector                        | Write (egress) | Per-regulator; named-counsel-gated  | 12 CFR Parts 53/225/304 filing surface                                             |
| Customer-notification email / SMS connector                   | Write (egress) | Per-customer; gated for HIPAA / GDPR Article 34 | Customer breach-notification surface                                       |
| Historical PIR corpus retriever                               | Read           | Per-tenant by default               | Cross-tenant context-bleed surface                                                 |
| Sensitive-data redactor (NER, regex, classifier)              | Read           | Per-draft                           | Privacy-defense surface                                                            |
| Materiality-summarizer                                        | Read           | Per-incident                        | SEC Item 1.05 disclosure-clock influence                                           |

### 4.6 Sensitive data and policy constraints

* **Data classes:** customer identifiers; employee names; supplier names; vulnerability detail (potentially exploitable); architecture detail (potentially exploitable); monetary impact estimates; SLA-credit calculations; PHI under HIPAA; PII under GDPR / CPRA; PCI cardholder data; trade-secret detail; attorney-client-privileged communications.
* **Retention and logging:** the PIR is a discoverable record; retention horizons are set per regulatory regime (SOX 7-year, HIPAA 6-year, GDPR purpose-limited, SEC 3-year for working papers). Litigation-hold workflows preserve PIR drafts on demand. AI-drafted state of every draft is preserved for SOC 2 evidence.
* **Regulatory constraints:** SEC Item 1.05 (4 business days from materiality); NIS 2 Article 23 (24h / 72h / 1mo); GDPR Article 33 (72h supervisory authority); HIPAA 45 CFR 164.412 (60 days individual / contemporaneous HHS for 500+); banking 36-hour notification; DORA Article 19; state-AG breach laws; PCI DSS 4.0.1 Req 12.10; SOC 2 CC7.3 / CC7.4; ISO/IEC 27035-1 and 27035-2; ISO 22301; ITIL 4 Major Incident Management; FedRAMP IR family; EU AI Act Article 50.
* **Output policy:** AI-drafted state is clearly labeled in the internal workflow and stripped only after named-human attestation. External-regulator filings surface verbatim from approved templates where regulation requires specific language. Every regulated-text section cites its source artifacts (timeline entries, alert events, tool-call audit entries, customer-impact data) with timestamps and confidence signals.

---

## 5. Operating modes

### 5.1 Manual baseline (no AI drafter)

The incident commander or designated reviewer drafts the PIR by hand from the artifacts. Existing safeguards (the PagerDuty postmortems community guide, the Google SRE Workbook Chapter 10, the org's incident-response plan, regulatory counsel review) apply. The drafter inherits the org's blameless-culture norm.

**Risk profile:** lowest hallucination risk; bounded by reviewer capacity and by the time-from-incident-close to PIR latency, which is commonly the bottleneck.

### 5.2 AI as drafter (proposal-only)

The AI drafts the PIR sections, action items, and regulator-filing narratives; the named human reviewer edits and signs. No AI-autonomous publication. Most regulated organizations operate here as the default in 2025-2026.

**Risk profile:** moderate. Dominated by review-fatigue under deadline pressure; the reviewer is structurally weak after an 8-hour SEV-0.

### 5.3 HITL per-section (the regulated-disclosure default)

The AI drafts each PIR section and each regulator-filing section separately; the corresponding named-human approver (incident commander for internal PIR, comms lead for customer-comm, named counsel for each regulator filing, materiality-call committee for SEC Item 1.05 trigger) signs each section before progression. Common at publicly-traded registrants and at NIS 2 essential entities.

**Risk profile:** moderate. UI discipline and resistance to rubber-stamp approval determine quality.

### 5.4 Bounded autonomy on a narrow allow-list

A pre-declared allow-list runs without per-section approval: internal-only PIR action-item drafting; cross-incident pattern detection for engineering-team review; routine status-page incident-resolved messages within an approved template envelope. Anything touching external regulators, customer breach notification, materiality determination, or SEC disclosure stays HITL or manual.

**Risk profile:** depends on allow-list discipline; the central governance risk is incentive pressure to expand the allow-list when regulator-filing windows are short.

### 5.5 Variants

Architectural variants teams reach for:

1. **Single-tenant versus multi-tenant historical PIR corpus.** Single-tenant simplifies the cross-tenant-bleed surface; multi-tenant requires explicit federation agreements and named-human review.
2. **Drafter-only versus drafter-plus-reviewer model.** A single AI model drafts and reviews; a separately-developed second AI model reviews; the second-model pattern is the closest analog to the SAFE-UC-0008 independent safety monitor.
3. **In-platform AI features (PagerDuty, incident.io, FireHydrant, Rootly built-in) versus internal Bedrock or Azure OpenAI deployments.** In-platform features inherit the platform's data-residency contract; internal deployments inherit the org's.
4. **AI-drafted SEC Item 1.05 narrative versus human-drafted with AI summarization for the materiality call.** A common safety pattern: never let the AI draft the Item 1.05 narrative; let it summarize the incident facts that inform the materiality call.
5. **Per-section confidence scoring.** The drafter emits a per-section confidence signal; sections below a threshold trigger a deeper human review.
6. **Independent privacy monitor.** A separately-authored monitor watches for sensitive-data emission and individual-name attribution drift in the drafter output on a non-overlapping signal set.

---

## 6. Threat model overview (high-level)

### 6.1 Primary security and safety goals

* preserve timeline-fact integrity in every drafted PIR
* preserve causal-chain integrity (no hallucinated middle steps in the 5-whys)
* preserve action-item attribution integrity (no fabricated commitments)
* preserve regulator-disclosure-fact integrity in every external filing
* preserve sensitive-data discipline (PII, PHI, PCI, vulnerability detail, supplier names)
* preserve the materiality-determination boundary (the named-human committee decides; the AI summarizes)
* preserve blameless-culture norms (no individual-attributed timeline entries surface in the published PIR)
* preserve tenant isolation across the historical PIR corpus
* preserve named-human signer on every external regulator filing

### 6.2 Threat actors (who might attack or misuse)

* **Adversarial responders** intentionally injecting content into chat or notes to steer a PIR away from a true root cause (rare but documented in insider-threat literature)
* **External attackers** whose injection into log content during the incident persists into the PIR drafter's context (the SAFE-UC-0024 lesson)
* **Compromised supplier or tool** whose tool-description poisoning (Invariant Labs MCP class) shapes the drafter
* **Civil adversaries in litigation discovery** seeking PIR drafts that contain individual-attributed blame, exploitable vulnerability detail, or admissions
* **Class-action plaintiffs** subpoenaing PIR drafts as evidence of materiality-determination delay
* **Regulator** scrutinizing the PIR for disclosure-timing accuracy under SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412
* **Insider-threat actors** using the AI drafter to obscure attribution (the AI says it; not me)
* **Researchers** disclosing findings about hallucination patterns in incident-narrative AI drafters

### 6.3 Attack surfaces

* the chat-transcript ingest path
* the log and trace ingest path
* the runbook and prior-PIR retrieval path
* the LLM drafter prompt window
* the regulator-filing template store
* the action-item sync path to Jira / Linear / ServiceNow
* the customer-comm publication path
* the cross-tenant historical PIR corpus
* the materiality-summarizer's input set
* the MCP tool-description ingest

### 6.4 High-impact failures (include industry harms)

* **Customer / consumer harm:** customer-comm draft with hallucinated impact scope under-discloses the breach to affected individuals; HIPAA 45 CFR 164.412 notification delayed past 60 days; GDPR Article 34 high-risk notification omitted.
* **Business harm:** SEC enforcement on Item 1.05 disclosure-timing or accuracy (the post-2023 enforcement frontier); NIS 2 Article 23 enforcement (fines up to 10M EUR or 2% global turnover for essential entities, 7M EUR or 1.4% for important entities); GDPR Article 83 fines (up to 20M EUR or 4% global turnover); HIPAA Office for Civil Rights penalties; state-AG enforcement; banking-regulator action (FDIC, OCC, FRB); class-action exposure under Garner v. Amazon-style frameworks where the AI-drafted narrative becomes the discovery target.
* **Operational harm:** wrong root cause prioritized; right fix deferred; engineering-org learning corrupted; incident-knowledge-corpus poisoning compounds across the next year of cross-incident pattern detection.
* **Reputational harm:** publicly-disclosed AI-drafted PIR with hallucinated facts surfaces in tech press; status-page comm with wrong impact scope erodes customer trust; SEC restatement of an earlier Item 1.05 filing is a market event.
* **Privacy harm:** PII / PHI / supplier-name leakage in internal PIR draft; SaaS-vendor breach (LastPass, Snowflake, Salesloft Drift class) of the incident-management platform exposes the corpus.

---

## 7. Kill-chain analysis (stages → likely failure modes)

> Keep this defender-friendly. Describe patterns, not "how to do it."
>
> Note: this UC uses an **eight-stage kill chain** with **five stages flagged NOVEL** versus SAFE-UC-0024 (terminal SRE outage, the upstream artifact source) and SAFE-UC-0022 (SOC investigation, the security-incident artifact source). The novelty centers on timeline-fact integrity, causal-chain hallucination, commitment fabrication, external-regulator filing hallucination, and the materiality-determination influence. The remaining three stages (artifact ingestion, sensitive-data leakage, and corpus poisoning) extend cohort patterns from SAFE-UC-0024 (untrusted-input ingestion), SAFE-UC-0022 (sensitive-data egress), and SAFE-UC-0006 (multi-tenant context bleed).

| Stage                                                                                | What can go wrong (pattern)                                                                                                                                                                              | Likely impact                                                                                              | Notes / preconditions                                                                                                                              |
| ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1. Incident-artifact ingestion with adversarial content                              | Log lines, chat transcripts, ticket text, or MCP tool descriptions carry attacker-injected content into the drafter's context                                                                              | drafter primed to treat data as instructions                                                               | extends SAFE-UC-0024 stage 1; symmetric mitigation (quote-isolation, structured retrieval)                                                          |
| 2. Timeline reconstruction with hallucinated events (**NOVEL: timeline-fact integrity**) | Hallucinated timestamps, fabricated alert ordering, invented operator-action sequencing, missing intervals filled in rather than flagged                                                                | hallucinated facts land in the regulator's filing under deadline pressure                                  | the central PIR-specific failure; named-human reviewer is structurally weak after 8-hour SEV-0                                                      |
| 3. Causal-chain / 5-whys analysis with hallucinated root cause (**NOVEL: causal hallucination**) | Plausible-sounding middle steps in the causal chain are inferential; a hallucinated middle step redirects remediation; single-root-cause framing is reintroduced where contributing-factor framing belongs | wrong fix prioritized; right fix deferred; engineering-org learning corrupted                              | drifts away from Google SRE Workbook Chapter 10 norms                                                                                              |
| 4. Action-item generation with fabricated owner-attribution (**NOVEL: commitment fabrication**) | Drafter proposes "SRE team will implement X by Y" as if the team agreed; action item syncs to Jira / Linear / ServiceNow under HITL fatigue; commitment compounds                                         | engineering-org commitment-debt; named-team backlog poisoning; PIR-meeting trust erosion                   | review meeting becomes the recovery anchor; AI-proposed owners are not auto-assigned                                                                |
| 5. Sensitive-data exfiltration via PIR draft                                         | Customer identifiers, employee names, supplier names, vulnerability detail, monetary impact, PHI / PII / PCI surface in the draft and propagate                                                          | privacy and security exposure; SaaS-vendor breach amplifies                                                | extends SAFE-UC-0022 sensitive-data stage; minimum-necessary policy and NER redaction are recovery anchors                                          |
| 6. AI-drafted external-regulator disclosure with hallucinated facts (**NOVEL: regulated-text hallucination**) | SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412, state-AG, banking 36-hour, DORA Article 19 filings drafted with hallucinated material facts                                       | securities-disclosure violation; NIS 2 fines; GDPR Article 83 fines; HIPAA OCR penalties; state-AG action  | regulator-filing template store and named-counsel signoff are the recovery anchors                                                                  |
| 7. Materiality-determination influence (**NOVEL: SEC Item 1.05 4-business-day clock**) | AI summary systematically downplays severity (delays the disclosure clock) or systematically overstates severity (over-discloses); SEC Item 1.05 4-business-day clock starts at the materiality call    | securities-disclosure-timing violation; over-disclosure market-event harm                                  | SEC-disclosure committee remains the named-human decision authority; the AI summary is one input                                                    |
| 8. Historical PIR corpus poisoning across the ISO 27035 system                       | Hallucinated PIR facts seed the cross-incident pattern detector; next year's pattern claims build on poisoned input; cross-tenant aggregation bleeds context                                              | compounding learning corruption; cross-incident regulator-claim drift; tenant isolation breach              | per-tenant scoping by default; named-human review on cross-tenant federation; periodic corpus audit                                                |

---

## 8. SAFE‑MCP mapping (kill-chain → techniques → controls → tests)

Practitioners commonly map this workflow's failure patterns to the following SAFE‑MCP techniques. The mapping is directional: teams adapt it to their stack, threat model, regulatory regime, and tenancy posture. Links in Appendix B resolve to the canonical technique pages.

**A note on framework gap.** SAFE-MCP today covers the LLM and MCP-tool surface well, but does not yet have first-class techniques for **timeline-fact-integrity hallucination in regulated narrative drafting**, **commitment fabrication** (action items as fabricated promises), or **materiality-determination influence by AI summarization**. The mapping below cites the closest anchors (SAFE-T2105 Disinformation Output is the umbrella for hallucinated regulated text; SAFE-T2106 Context Memory Poisoning covers corpus-level harm; SAFE-T1404 Response Tampering covers drafter-output manipulation) and flags the gaps honestly.

| Kill-chain stage                                                  | Failure / attack pattern (defender-friendly)                                                                                                  | SAFE‑MCP technique(s)                                                                                                                                                                                                    | Recommended controls (prevent / detect / recover)                                                                                                                                                                                                                                                                                                                                                                                                                  | Tests (how to validate)                                                                                                                                                                                                                                                                                                                          |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Incident-artifact ingestion with adversarial content              | Log lines, chat transcripts, ticket text, or MCP tool descriptions carry attacker-injected content                                              | `SAFE-T1102` (Prompt Injection (Multiple Vectors)); `SAFE-T1110` (Multimodal Prompt Injection via Images/Audio); `SAFE-T1001` (Tool Poisoning Attack (TPA)); `SAFE-T1402` (Instruction Stenography - Tool Metadata Poisoning) | quote-isolate every free-text source; structured retrieval with source attribution; pin and verify MCP tool descriptions; size-cap chat-transcript ingest; multimodal sanity check on incident-screenshot ingest                                                                                                                                                                                                                                                  | adversarial chat-transcript fixtures; adversarial log-line fixtures; multimodal-injection fixtures on incident screenshots; tool-description tamper detection                                                                                                                                                                                  |
| Timeline reconstruction with hallucinated events (**NOVEL gap**)  | Hallucinated timestamps, fabricated alert ordering, invented operator-action sequencing                                                          | `SAFE-T2105` (Disinformation Output); `SAFE-T1404` (Response Tampering). **Gap:** timeline-fact-integrity in regulated narrative drafting is not yet a first-class SAFE-MCP technique                                       | source-attributed entries with timestamps; explicit confidence signals per entry; flag missing intervals rather than fabricate; cross-reference at least two independent sources before promoting an entry to PIR-fact; named-human review on the timeline section                                                                                                                                                                                                | seeded-missing-interval fixtures; verify drafter flags rather than fabricates; seeded-conflicting-source fixtures; verify drafter surfaces conflict                                                                                                                                                                                            |
| Causal-chain / 5-whys hallucination (**NOVEL gap**)               | Plausible middle step in the causal chain hallucinated; single-root-cause framing reintroduced                                                  | `SAFE-T2105` (Disinformation Output); `SAFE-T1404` (Response Tampering)                                                                                                                                                  | grounded-retrieval-only on causal claims; verbatim source citation per causal-chain step; contributing-factor framing per Google SRE Workbook Chapter 10; named-human review with explicit "is this hallucinated?" prompt                                                                                                                                                                                                                                          | seeded-incident-with-known-cause fixtures; verify drafter does not invent additional causes; verify single-root-cause framing is rejected                                                                                                                                                                                                       |
| Action-item commitment fabrication (**NOVEL gap**)                | Drafter proposes action items with named owners as if the team agreed                                                                            | `SAFE-T2105` (Disinformation Output); `SAFE-T1701` (Cross-Tool Contamination) when the action item syncs to Jira / Linear / ServiceNow                                                                                   | AI-proposed owners labeled "proposed"; named-human confirmation in the PIR review meeting before sync; action-item-create gate on Jira / Linear / ServiceNow connector; audit trail preserves human-attributed owner change                                                                                                                                                                                                                                       | seeded-team-name fixtures; verify owner is "proposed" not "assigned"; verify sync gate fires; verify PIR review meeting captures human attribution                                                                                                                                                                                              |
| Sensitive-data exfiltration via PIR draft                         | Customer identifiers, employee names, supplier names, vulnerability detail, PHI / PII / PCI surface and propagate                              | `SAFE-T1502` (File-Based Credential Harvest); `SAFE-T1503` (Env-Var Scraping); `SAFE-T1801` (Automated Data Harvesting); `SAFE-T1910` (Covert Channel Exfiltration)                                                       | NER-based redaction by default for PII / PHI / PCI / supplier names; minimum-necessary principle on every section; sensitive-data classification gate before publish; egress allow-list on the customer-comm and regulator-filing connectors                                                                                                                                                                                                                       | seeded-PII fixtures; seeded-PHI fixtures; seeded-supplier-name fixtures; verify redaction; verify gate blocks publication                                                                                                                                                                                                                       |
| AI-drafted regulator filing hallucination (**NOVEL gap**)         | SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412 filings drafted with hallucinated material facts                          | `SAFE-T2105` (Disinformation Output); `SAFE-T1404` (Response Tampering); `SAFE-T1309` (Privileged Tool Invocation via Prompt Manipulation) on the regulator-filing connector                                              | template-grounded filing with verbatim regulatory language; per-claim source-artifact citation; named regulatory counsel signoff before submission; AI-drafted state preserved in audit trail; regulator-filing-connector gate enforces named-counsel attestation                                                                                                                                                                                                  | tabletop a SEC Item 1.05 hallucinated-fact scenario; tabletop a NIS 2 Article 23 hallucinated-fact scenario; verify template-grounding gate fires; verify named-counsel attestation is captured                                                                                                                                                  |
| Materiality-determination influence (**NOVEL gap**)               | AI summary systematically downplays or overstates severity, influencing the SEC Item 1.05 4-business-day clock or NIS 2 significant-incident classification | `SAFE-T2105` (Disinformation Output); `SAFE-T1404` (Response Tampering). **Gap:** materiality-determination influence by AI summarization is not yet a first-class SAFE-MCP technique                                       | the materiality call is a named-committee decision; the AI summary is one input among many; the summary surfaces the underlying artifacts (impact, scope, regulated-data classes, jurisdictional exposure) verbatim; explicit confidence signal on the summary; periodic audit of summary-versus-committee-decision drift                                                                                                                                          | seeded-borderline-materiality fixtures; verify the summary surfaces both directions of severity; verify the SEC-disclosure committee receives the underlying artifacts; verify summary-vs-decision audit captures drift                                                                                                                          |
| Historical PIR corpus poisoning                                   | Hallucinated PIR facts seed cross-incident pattern detection; cross-tenant aggregation bleeds context                                            | `SAFE-T2106` (Context Memory Poisoning via Vector Store Contamination); `SAFE-T2107` (AI Model Poisoning via MCP Tool Training Data Contamination); `SAFE-T2103` (Code Sabotage via Malicious Agentic Pull Request) when corpus poisoning influences engineering-action items | per-tenant scoping by default; named-human review on cross-tenant federation; periodic corpus audit; cross-incident-pattern claims cite per-incident PIR sources; reviewer-attestation on cross-incident pattern claims                                                                                                                                                                                                                                            | tabletop a cross-tenant bleed scenario; seeded-poisoned-PIR fixtures; verify per-tenant scoping holds; verify cross-incident pattern claims cite per-incident sources                                                                                                                                                                          |

---

## 9. Controls & mitigations (organized)

### 9.1 Prevent (reduce likelihood)

* **Source-attributed entries** in every drafted timeline, with timestamps and explicit confidence signals; flag missing intervals rather than fabricate.
* **Grounded-retrieval-only** on every regulated-text section (SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412, state-AG, banking 36-hour, DORA Article 19); verbatim citation of source artifacts.
* **Template-grounded** filings: pre-approved templates per regulator, per jurisdiction, per filing type; the AI fills slots, never invents legal language.
* **Named-counsel signoff** on every external regulator filing.
* **Named-human attestation** on every section before sign-off.
* **Action-item proposed-not-assigned** by default; named-human confirmation in PIR review meeting before sync to Jira / Linear / ServiceNow.
* **NER-based redaction** of PII / PHI / supplier names by default; sensitive-data classification gate before any external publication.
* **Materiality-determination boundary**: the named SEC-disclosure committee decides; the AI summarizes the underlying facts; the summary cites verbatim and surfaces both directions of severity.
* **Per-tenant scoping** of the historical PIR corpus by default; named-human review on any cross-tenant aggregation.
* **Quote-isolation** on every free-text channel into the drafter (chat transcripts, ticket text, log content).
* **Pin and verify** MCP tool descriptions.
* **Egress allow-list** on the regulator-filing, customer-comm, and action-item connectors.
* **Blameless-culture default**: individual-attributed timeline entries are redacted to role-attributed before publication unless named-human review explicitly elects otherwise.
* **EU AI Act Article 50 transparency**: the assistant identifies itself as AI in the drafted state; AI-drafted state is labeled in the workflow.

### 9.2 Detect (reduce time-to-detect)

* timeline-entry source-attribution rate (target near 100%)
* missing-interval flag rate (should never be zero on real incidents)
* causal-chain source-citation rate
* AI-proposed owner versus human-attributed owner divergence rate
* sensitive-data emission rate per draft (PII / PHI / supplier)
* regulator-filing template grounding rate
* materiality-summarizer confidence-signal distribution
* materiality-summary versus SEC-committee-decision divergence rate
* per-tenant scoping enforcement rate
* AI-drafted-state preservation in audit trail
* cross-incident pattern claims with valid per-incident citations rate
* customer-comm sensitive-data emission rate

### 9.3 Recover (reduce blast radius)

* incident-response playbook for an inferred or confirmed hallucinated regulator filing (the SEC Item 1.05 amendment-or-restatement path; the NIS 2 Article 23 supplement; the GDPR Article 33 supplemental notification)
* incident-response playbook for an inferred or confirmed sensitive-data leakage in an internal PIR (litigation-hold and notification workflow)
* incident-response playbook for an inferred or confirmed cross-tenant corpus bleed
* periodic corpus audit with redaction-and-rebuild path for poisoned entries
* coordinated-disclosure path through the AI Incident Database for hallucination patterns in PIR drafters
* regulator-notification playbook per jurisdiction (SEC, ENISA, national CSIRTs, DPAs, HHS OCR, state AGs, federal banking regulators) pre-mapped with countdown SLAs

---

## 10. Validation & testing plan

### 10.1 What to test (minimum set)

* **Timeline-fact integrity**: drafter does not fabricate timestamps, alert orderings, or operator-action sequences; missing intervals are flagged.
* **Causal-chain integrity**: drafter does not invent middle steps; single-root-cause framing is rejected.
* **Action-item attribution**: AI-proposed owners are labeled "proposed"; sync gate enforces named-human attribution.
* **Sensitive-data redaction**: PII / PHI / supplier names are redacted by default; egress allow-list blocks unredacted publication.
* **Regulator-filing template grounding**: SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412 templates fire; verbatim language is preserved.
* **Materiality-summarizer balance**: the summary surfaces both directions of severity; the SEC-disclosure committee receives underlying artifacts.
* **Per-tenant scoping**: historical PIR corpus does not bleed across tenants under adversarial query.
* **Named-counsel signoff**: every external regulator filing routes through named-counsel attestation.
* **Blameless-culture redaction**: individual-attributed timeline entries are redacted to role-attributed by default.
* **EU AI Act Article 50 transparency**: AI-drafted state is labeled in the workflow.

### 10.2 Test cases (make them concrete)

| Test name                                              | Setup                                                                | Input / scenario                                                                                                              | Expected outcome                                                                                                                                       | Evidence produced                                              |
| ------------------------------------------------------ | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| Hallucinated-timestamp fixture                         | Synthetic incident with deliberately gapped timeline                  | drafter asked to assemble timeline with a 2-hour gap                                                                          | drafter flags the gap rather than fabricates entries                                                                                                  | timeline + gap-flag log                                         |
| Conflicting-source fixture                             | Two sources disagree on event timestamp                               | drafter assembles timeline                                                                                                    | drafter surfaces the conflict with both timestamps and confidence signals                                                                              | timeline + conflict-surface log                                  |
| Hallucinated-root-cause fixture                        | Synthetic incident with known cause                                   | drafter assembles 5-whys                                                                                                      | drafter cites source artifacts per causal step; does not invent additional causes; uses contributing-factor framing                                     | 5-whys + source-citation log                                    |
| Action-item commitment fabrication                     | Synthetic PIR with no named-team agreement on file                    | drafter proposes "SRE team will implement X by Y"                                                                            | owner labeled "proposed"; sync gate to Jira blocks until named-human confirmation                                                                       | owner-label log + sync-gate log                                  |
| PII / PHI redaction                                    | Synthetic incident with customer email + SSN + phone in chat log      | drafter assembles PIR                                                                                                          | NER-based redactor fires; PII / PHI replaced with role-attributed placeholders; egress gate blocks unredacted external publication                       | redaction log + egress-gate log                                  |
| Supplier-name redaction                                | Synthetic incident with named third-party vendor                      | drafter assembles PIR                                                                                                          | supplier-name redacted by default; named-human review can elect to retain                                                                              | redaction log                                                   |
| SEC Item 1.05 hallucinated-fact tabletop               | Borderline-material cyber incident                                    | drafter assembles Item 1.05 narrative                                                                                          | template-grounded; per-claim source-artifact citation; named-counsel attestation captured before submission                                            | template log + counsel-attestation log                          |
| NIS 2 Article 23 hallucinated-fact tabletop            | Significant-incident-classified ICT incident at NIS 2 essential entity | drafter assembles 24-hour early warning                                                                                       | template-grounded; per-claim citation; named-counsel attestation                                                                                       | template log + counsel-attestation log                          |
| GDPR Article 33 hallucinated-fact tabletop             | Personal-data breach affecting EU data subjects                       | drafter assembles supervisory-authority notification                                                                          | template-grounded; per-claim citation; named-counsel attestation                                                                                       | template log + counsel-attestation log                          |
| HIPAA 45 CFR 164.412 hallucinated-fact tabletop        | PHI breach affecting fewer than 500 individuals                       | drafter assembles individual notification + HHS notification                                                                  | template-grounded; per-claim citation; named-counsel attestation; 60-day timer initialized                                                             | template log + counsel-attestation log + timer log              |
| Materiality-summarizer balance                         | Borderline-material incident with both severity-up and severity-down signals | drafter summarizes for the SEC-disclosure committee                                                                       | summary surfaces both directions; underlying artifacts cited; confidence signal explicit                                                              | summary + artifact-citation log                                  |
| Cross-tenant corpus bleed                              | Two synthetic tenant historical-PIR corpora                          | tenant A queries cross-incident pattern that includes tenant B PIRs                                                          | per-tenant scoping rejects; named-human federation review path captures intent                                                                         | scoping log                                                     |
| Blameless-culture redaction                            | Synthetic timeline with named-individual entries                      | drafter assembles published PIR                                                                                                | individual-attributed entries redacted to role-attributed by default; named-human review can elect to retain                                            | redaction log + review-attestation log                          |
| EU AI Act Article 50 transparency                      | First-touch interaction with the drafter                              | new user invokes drafter                                                                                                      | drafter identifies as AI verbatim per Article 50; AI-drafted state labeled in workflow                                                                | first-interaction audit                                          |

### 10.3 Operational monitoring (production)

* timeline source-attribution rate
* missing-interval flag rate
* causal-chain source-citation rate
* AI-proposed-versus-human-attributed-owner divergence
* PII / PHI / supplier emission rate per draft
* regulator-filing template grounding rate by regulator
* materiality-summarizer confidence-signal distribution
* materiality-summary versus committee-decision drift
* named-counsel attestation rate on regulator-filing connector
* per-tenant scoping enforcement rate
* AI-drafted-state preservation rate in audit trail
* cross-incident pattern-claim source-citation rate
* blameless-culture redaction rate

---

## 11. Open questions & TODOs

- [ ] Define the org's standard timeline-confidence-signal taxonomy (high / medium / low) and the threshold that triggers named-human review.
- [ ] Define the org's regulator-filing template store: per regulator, per jurisdiction, per filing type, with the verbatim legal language pre-approved by counsel.
- [ ] Define the SEC-disclosure committee composition and the materiality-summary input contract.
- [ ] Define the named-counsel signoff path per regulator (SEC, ENISA / national CSIRTs, DPAs, HHS OCR, state AGs, federal banking regulators).
- [ ] Define the action-item proposed-versus-assigned protocol and the sync-gate to Jira / Linear / ServiceNow.
- [ ] Define the sensitive-data classification taxonomy and the NER-based redactor's coverage.
- [ ] Define the per-tenant scoping enforcement and the cross-tenant federation review path for the historical PIR corpus.
- [ ] Define the blameless-culture redaction policy and the review path for retaining named-individual attribution.
- [ ] Map regulator-filing SLAs per jurisdiction with countdown timers (SEC 4 business days; NIS 2 24h / 72h / 1mo; GDPR 72h; HIPAA 60 days / contemporaneous 500+; banking 36h; DORA Article 19).
- [ ] Define the AI Incident Database coordinated-disclosure path for hallucination patterns observed in the drafter.
- [ ] Define the corpus-audit cadence and the redaction-and-rebuild path for poisoned entries.

---

## 12. Questionnaire prompts (for reviewers)

### Workflow realism

* Are the integrations (PagerDuty, incident.io, FireHydrant, Rootly, Slack, Teams, Datadog, Statuspage, Jira, Linear, ServiceNow, EDGAR, CSIRT-portal, HHS OCR, DPA portals, state-AG portals) realistic for the org's incident-management stack and regulatory regime?
* Does the workflow distinguish internal-only PIR from regulator-facing filings?
* Is the AI's role bounded to drafting, with named-human signoff on every external-facing artifact?

### Trust boundaries and permissions

* Is the materiality-determination boundary preserved (the SEC-disclosure committee decides; the AI summarizes)?
* Is per-tenant scoping enforced on the historical PIR corpus?
* Is the action-item proposed-versus-assigned distinction enforced through the sync gate?

### Output safety and persistence

* Are timeline entries source-attributed with confidence signals?
* Are causal-chain entries source-cited with contributing-factor framing?
* Are regulator filings template-grounded with verbatim legal language?
* Is the AI-drafted state preserved in the audit trail?

### Sensitive-data discipline

* Is NER-based redaction the default for PII / PHI / supplier names?
* Is the egress allow-list enforced on customer-comm and regulator-filing connectors?
* Is the blameless-culture redaction default in place?

### Regulatory integrity

* Are SEC Item 1.05, NIS 2 Article 23, GDPR Article 33, HIPAA 45 CFR 164.412, state-AG, banking 36-hour, DORA Article 19 templates pre-approved?
* Is named-counsel signoff captured before every external filing?
* Are countdown timers tied to materiality determination, breach awareness, or notification incident classification?

### Operations

* Success metrics: PIR-time-to-publish reduction, regulator-filing-on-time rate, action-item-completion rate, blameless-culture-redaction rate
* Danger metrics: hallucinated-timestamp incidents, hallucinated-root-cause incidents, sensitive-data-emission incidents, cross-tenant-bleed incidents, named-counsel-bypass attempts, materiality-summarizer drift events
* Who owns the kill switch on the drafter and the regulator-filing-connector gate?

---

## Appendix A: Contributors and Version History

* **Authoring:** Astha (DSO contributor, 2026-04-27)
* **Initial draft:** 2026-04-27 (Seed → Draft)

| Version | Date       | Changes                                                                                                                                                                                                            | Author |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ |
| 1.0     | 2026-04-27 | Initial documentation of `SAFE-UC-0019` from seed to full draft. 8-stage kill chain, 5 stages flagged NOVEL, 17 SAFE-MCP techniques across 8 stages, 6-subsection Appendix B. Track S off SAFE-UC-0024 and 0022. | Astha  |

---

## Appendix B: References & frameworks

### B.1 SAFE-MCP techniques referenced in this use case

* [SAFE-T1001 Tool Poisoning Attack (TPA)](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1001/README.md)
* [SAFE-T1102 Prompt Injection (Multiple Vectors)](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1102/README.md)
* [SAFE-T1110 Multimodal Prompt Injection via Images/Audio](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1110/README.md)
* [SAFE-T1304 Credential Relay Chain](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1304/README.md)
* [SAFE-T1309 Privileged Tool Invocation via Prompt Manipulation](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1309/README.md)
* [SAFE-T1402 Instruction Stenography - Tool Metadata Poisoning](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1402/README.md) (the title preserves the verbatim "Stenography" typo from the SAFE-MCP source; the body uses the correct "steganography")
* [SAFE-T1403 Consent-Fatigue Exploit](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1403/README.md)
* [SAFE-T1404 Response Tampering](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1404/README.md)
* [SAFE-T1502 File-Based Credential Harvest](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1502/README.md)
* [SAFE-T1503 Env-Var Scraping](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1503/README.md)
* [SAFE-T1701 Cross-Tool Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1701/README.md)
* [SAFE-T1801 Automated Data Harvesting](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1801/README.md)
* [SAFE-T1910 Covert Channel Exfiltration](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1910/README.md)
* [SAFE-T2103 Code Sabotage via Malicious Agentic Pull Request](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2103/README.md)
* [SAFE-T2105 Disinformation Output](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2105/README.md)
* [SAFE-T2106 Context Memory Poisoning via Vector Store Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2106/README.md)
* [SAFE-T2107 AI Model Poisoning via MCP Tool Training Data Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2107/README.md)

### B.2 Industry and AI-specific frameworks teams commonly consult

* [NIST AI Risk Management Framework 1.0 (AI 100-1, January 2023)](https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf)
* [NIST AI 600-1 Generative AI Profile (July 2024)](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)
* [NIST SP 800-218A SSDF Generative AI Profile (July 2024)](https://csrc.nist.gov/pubs/sp/800/218/a/final)
* [NIST SP 800-53 Rev 5 Security and Privacy Controls](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final)
* [Regulation (EU) 2024/1689 (EU AI Act; Article 50 transparency)](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
* [ISO/IEC 42001:2023 Artificial Intelligence Management System](https://www.iso.org/standard/81230.html)
* [ISO/IEC 23894:2023 AI Risk Management](https://www.iso.org/standard/77304.html)
* [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)
* [MITRE ATLAS adversarial threat landscape for AI systems](https://atlas.mitre.org/)

### B.3 Public incidents, disclosures, and case studies adjacent to this workflow

* [Fortune: An AI-powered coding tool wiped out a software company's database (July 2025)](https://fortune.com/2025/07/23/ai-coding-tool-replit-wiped-database-called-it-a-catastrophic-failure/) (post-incident review of an AI-originated production deletion)
* [AI Incident Database (the canonical public incident catalog for AI-system harms; relevant to PIR drafter hallucination patterns)](https://incidentdatabase.ai/)
* [Garner v. Amazon.com (W.D. Wash.; class certification granted by Judge Lasnik on July 7, 2025; relevant to discovery of AI-system records)](https://www.classaction.org/news/judge-grants-class-certification-in-amazon-alexa-privacy-lawsuit)
* [Anthropic: Claude Code auto mode, a safer way to skip permissions (March 2026; relevant to AI-agent permission boundaries cited as a 0024 reference)](https://www.anthropic.com/engineering/claude-code-auto-mode)
* [AWS Security Bulletin AWS-2025-019: Amazon Q Developer and Kiro prompt injection (October 2025; relevant to incident-handling AI workflows in cloud environments)](https://aws.amazon.com/security/security-bulletins/AWS-2025-019/)

### B.4 Domain-regulatory references

* [SEC Cybersecurity Disclosure Rules: Form 8-K Item 1.05 (released 26 July 2023)](https://www.sec.gov/newsroom/press-releases/2023-139)
* [SEC Form 8-K (Cornell Law canonical reference for the form including Item 1.05)](https://www.law.cornell.edu/cfr/text/17/249.308)
* [Directive (EU) 2022/2555 (NIS 2): Article 23 incident reporting](https://eur-lex.europa.eu/eli/dir/2022/2555/oj)
* [Regulation (EU) 2016/679 (GDPR): Article 33 personal-data-breach notification (72 hours)](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
* [Regulation (EU) 2022/2554 (DORA Digital Operational Resilience Act; applicable from 17 January 2025)](https://eur-lex.europa.eu/eli/reg/2022/2554/oj)
* [HIPAA Breach Notification Rule (45 CFR 164.400 to 164.414; HHS canonical reference)](https://www.hhs.gov/hipaa/for-professionals/breach-notification/index.html)
* [Federal banking Computer-Security Incident Notification Rule (12 CFR Parts 53, 225, 304; FDIC final-rule press release)](https://www.fdic.gov/news/press-releases/2021/pr21099.html)
* [PCI DSS v4.0.1 (Payment Card Industry Data Security Standard; PCI Security Standards Council)](https://www.pcisecuritystandards.org/document_library/?category=pcidss)
* [SOC 2 Trust Services Criteria (AICPA reference)](https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2)

### B.5 Industry safety and governance frameworks

* [NIST SP 800-61 Rev 2 Computer Security Incident Handling Guide (August 2012; revision 3 in development at NIST CSRC)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)
* [ISO/IEC 27035-1:2023 Information security incident management Part 1: Principles and process](https://www.iso.org/standard/78973.html)
* [ISO/IEC 27035-2:2023 Information security incident management Part 2: Guidelines to plan and prepare for incident response](https://www.iso.org/standard/78974.html)
* [ISO/IEC 27001:2022 Information security management systems](https://www.iso.org/standard/27001)
* [ISO 22301:2019 Business continuity management systems](https://www.iso.org/standard/75106.html)
* [Google SRE Workbook, Chapter 10: Postmortem Culture, Learning from Failure](https://sre.google/workbook/postmortem-culture/)
* [PagerDuty Postmortems documentation](https://postmortems.pagerduty.com/)
* [ITIL 4 Major Incident Management (Axelos / PeopleCert canonical reference)](https://www.axelos.com/certifications/itil-service-management/itil-4-foundation)
* [FedRAMP Moderate Baseline (NIST SP 800-53 Rev 5 IR control family)](https://www.fedramp.gov/baselines/)

### B.6 Vendor product patterns (illustrative; not endorsements)

* [PagerDuty AI for Incident Management](https://www.pagerduty.com/platform/ai/)
* [incident.io Post-mortem features](https://incident.io/post-mortem)
* [FireHydrant Retrospectives + Reliability AI](https://firehydrant.com/product/retrospectives/)
* [Rootly Retrospectives and Rootly AI](https://rootly.com/features/retrospectives)
* [Atlassian Statuspage best practices for incident postmortems](https://www.atlassian.com/software/statuspage/best-practices/how-to-write-a-good-incident-postmortem)
* [Squadcast Postmortems](https://www.squadcast.com/features/postmortems)
* [Datadog Bits AI for incident management](https://www.datadoghq.com/product/platform/bits-ai/)
* [ServiceNow Now Assist for IT Service Management](https://www.servicenow.com/products/now-assist-for-itsm.html)
* [GitHub Copilot for security (the security-incident workflow features)](https://github.com/features/copilot)
* [AWS Bedrock for retrieval-augmented incident-corpus drafting](https://aws.amazon.com/bedrock/)
* [Azure OpenAI Service for retrieval-augmented incident-corpus drafting](https://azure.microsoft.com/en-us/products/ai-services/openai-service)
