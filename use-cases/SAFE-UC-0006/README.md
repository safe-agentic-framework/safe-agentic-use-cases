# Fleet telematics & vehicle-health monitoring assistant

> **SAFE‑AUCA industry reference guide (draft)**
>
> This use case describes the workflow at the center of modern commercial and consumer fleet operations: AI-assisted ingestion, anomaly detection, predictive maintenance, hours-of-service compliance, driver-behavior scoring, route optimization, and recall-trigger surveillance over millions of streaming telematics records (GPS, CAN bus signals, ECU diagnostics, J1939, OBD-II, ELD records, dashcam imagery). It is the **first SAFE‑AUCA use case in the Transportation and Warehousing sector (NAICS 48-49)** and the registry's first **read-heavy cyber-physical** workflow. SAFE-UC-0008 (OTA software updates) writes to vehicles at fleet scale; this workflow mostly reads from them at fleet scale, and the privacy-versus-safety tension that creates is the defining risk surface.
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

| Field                | Value                                                                  |
| -------------------- | ---------------------------------------------------------------------- |
| **SAFE Use Case ID** | `SAFE-UC-0006`                                                         |
| **Status**           | `draft`                                                                |
| **Maturity**         | draft                                                                  |
| **NAICS 2022**       | `48-49` (Transportation and Warehousing)                               |
| **Last updated**     | `2026-04-25`                                                           |

### Evidence (public links)

* [FTC Finalizes Order Settling Allegations that GM and OnStar Collected and Sold Geolocation Data Without Consumers' Informed Consent (14 January 2026; 5-year ban on disclosure to consumer reporting agencies)](https://www.ftc.gov/news-events/news/press-releases/2026/01/ftc-finalizes-order-settling-allegations-gm-onstar-collected-sold-geolocation-data-without-consumers)
* [Wyden and Markey Investigation Letter to FTC on automaker driver data sharing (26 July 2024; Hyundai 1.7M vehicles to Verisk for $1M+, Honda 97k cars for $25,920 = $0.26 per car)](https://www.wyden.senate.gov/news/press-releases/wyden-investigation-reveals-new-details-about-automakers-sharing-of-driver-information-with-data-brokers-wyden-and-markey-urge-ftc-to-crack-down-on-disclosures-of-americans-data-without-drivers-consent)
* [Texas AG Paxton Sues Allstate and Arity for Unlawfully Collecting Driving Data from 45M+ Consumers (January 2025; first TDPSA enforcement)](https://www.texasattorneygeneral.gov/news/releases/attorney-general-ken-paxton-sues-allstate-and-arity-unlawfully-collecting-using-and-selling-over-45)
* [Mozilla Foundation: Privacy Nightmare on Wheels, all 25 reviewed car brands flunk privacy review (September 2023)](https://www.mozillafoundation.org/en/blog/privacy-nightmare-on-wheels-every-car-brand-reviewed-by-mozilla-including-ford-volkswagen-and-toyota-flunks-privacy-test/)
* [Upstream Security 2025 Global Automotive Cybersecurity Report (telematics rose from 43% to 66% of automotive incidents 2023 to 2024)](https://upstream.auto/blog/insights-from-upstreams-2025-automotive-cybersecurity-report/)
* [CISA ICS-ALERT-15-203-01 FCA Uconnect Vulnerability (foundational telematics-as-attack-surface; first cybersecurity-driven recall, 1.4M vehicles)](https://www.cisa.gov/news-events/ics-alerts/ics-alert-15-203-01)
* [Wilson Sonsini analysis: California CPPA $632,500 Settlement with American Honda Motor Co. (12 March 2025)](https://www.wsgr.com/en/insights/lessons-from-the-cppas-dollar632500-settlement-with-connected-vehicle-manufacturer.html)
* [49 CFR Part 395 Subpart B Electronic Logging Devices (FMCSA HOS regulation)](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-III/part-395/subpart-B)
* [49 CFR Part 573 Defect and Noncompliance Responsibility and Reports (NHTSA 5-business-day reporting)](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-V/part-573)
* [NHTSA Cybersecurity Best Practices for the Safety of Modern Vehicles (September 2022)](https://www.nhtsa.gov/document/cybersecurity-best-practices-safety-modern-vehicles-2022)
* [SAE J3138_202210 Diagnostic Link Connector Security (October 2022; supersedes J3138_201806)](https://www.sae.org/standards/content/j3138_202210/)
* [Automotive ISAC Best Practice Guides and Vulnerability Disclosure Programs](https://automotiveisac.com/best-practice-guides)

---

## Minimum viable write-up (Seed → Draft fast path)

This document covers:

* Executive summary
* Industry context and constraints
* Workflow and scope
* Architecture (tools, trust boundaries, inputs)
* Operating modes
* Kill-chain table (7 stages)
* SAFE‑MCP mapping table (19 techniques)
* Contributors and Version History

---

## 1. Executive summary (what + why)

**What this workflow does.**
An AI-assisted **fleet telematics and vehicle-health monitoring** system ingests continuous telemetry from connected vehicles (GPS coordinates, CAN bus messages, OBD-II / J1939 fault codes, ECU diagnostics, dashcam imagery, ELD hours-of-service records, fuel and tire data, harsh-event signals) into dashboards used by a many-party set of legitimate consumers. Typical capabilities include:

* anomaly and predictive-maintenance triage (engine, transmission, battery, brake, tire signals)
* hours-of-service compliance flagging for FMCSA-regulated commercial drivers (49 CFR Part 395)
* driver-behavior scoring (harsh-braking, hard-acceleration, speeding, distracted-driving, drowsiness)
* route optimization, fuel-efficiency coaching, and dispatch decision support
* recall-trigger surveillance against warranty signals and feed of the OEM's defect-reporting workflow (49 CFR Part 573)
* insurance underwriting and usage-based-insurance (UBI) premium calculation
* fleet-safety dashboarding and dispatcher copilots that summarize incidents and route exceptions

Industry examples span **OEM connected-vehicle programs** (GM OnStar, Ford Pro Telematics, Stellantis Connect, Tesla fleet API, BMW ConnectedDrive, Mercedes Connect, Toyota Smart Connect, Hyundai Bluelink, Volvo Connect, Daimler Truck Detroit Connect with Virtual Technician monitoring 150 DT12 fault codes, PACCAR SmartLINQ, Volvo Trucks Connected Services), **aftermarket telematics service providers (TSPs)** (Geotab with approximately 5 million vehicle subscriptions across roughly 100,000 customers; Samsara processing 80 billion miles annually and 120 billion API calls; Verizon Connect, Trimble Fleet Mobility, Motive, Lytx with 600,000+ drivers using machine-vision dashcams, Solera Omnitracs, Fleet Complete, Azuga), and **insurance telematics platforms** (Cambridge Mobile Telematics, which powers Progressive's Accident Response product among others).

**Why it matters (business value).**
Fleet telematics is the connective tissue between physical vehicles and the operations, maintenance, compliance, insurance, and recall functions that depend on them. Used well, it shortens mean-time-to-detect for safety-relevant defects (Detroit Connect Virtual Technician routes specific fault codes to engineers and dealers within minutes of a triggering event), keeps long-haul fleets within HOS compliance (the Commercial Vehicle Safety Alliance's 2024 International Roadcheck reported 48,761 inspections, a 23 percent vehicle out-of-service rate, and HOS as the top driver out-of-service reason at 32.1 percent of all driver OOS), and feeds the OEM defect-and-noncompliance reporting workflow that drives statutory recalls.

**Why it's risky / what can go wrong.**
This workflow's defining trait is the **privacy-versus-safety tension** that comes from being read-heavy at fleet scale. The same continuous telemetry that detects an imminent engine failure or coaches a fatigued driver also produces a multi-year record of every trip, every stop, every speeding event, and every cabin sensor frame, and that record has commercial value to data brokers, consumer reporting agencies, and insurers. Recent enforcement makes the tension concrete:

* The U.S. Federal Trade Commission's January 2025 action against General Motors and OnStar, finalized 14 January 2026, established a five-year ban on disclosing consumers' precise geolocation and driver-behavior data to consumer reporting agencies, with affirmative-consent and consumer-rights provisions across a 20-year consent order period. This is the canonical regulator articulation of what unfair-and-deceptive looks like for connected-vehicle data sales.
* The July 2024 letter from Senator Ron Wyden and Senator Edward Markey to the FTC quantified the secondary-use market: Hyundai supplied data from 1.7 million vehicles to Verisk for more than $1 million (about 61 cents per car), and Honda shared data from 97,000 cars for $25,920 (about 26 cents per car). Driver-behavior data, in other words, retails to data brokers for less than the price of a coffee per vehicle.
* The Texas Attorney General's January 2025 action against Allstate and its Arity subsidiary, the first TDPSA enforcement, alleged collection of trillions of miles of location data from over 45 million consumers nationwide via SDKs embedded in unrelated mobile apps.
* Mozilla Foundation's September 2023 connected-vehicle privacy review found that all 25 brands evaluated failed; the category was the first in seven years to fail 100 percent.
* The California Privacy Protection Agency's $632,500 settlement with American Honda Motor Co., announced 12 March 2025, alleged CCPA violations in connected-vehicle privacy practices.

The Upstream Security 2025 Global Automotive Cybersecurity Report shows the operational picture: telematics rose from 43 percent of automotive incidents in 2023 to 66 percent in 2024, and the VicOne 2025 report counted 530 automotive CVEs in 2024 with most concentrated in onboard and in-vehicle systems. The 2015 Miller-Valasek Jeep Uconnect remote-exploit research (CISA ICS-ALERT-15-203-01, CERT/CC VU#819439) remains the foundational illustration that the telematics path is itself the attack surface, not a side channel; it triggered the first cybersecurity-driven vehicle recall affecting roughly 1.4 million vehicles.

A defining inversion versus SAFE-UC-0008 (OTA software updates) is **read-side risk dominance.** SAFE-UC-0008's primary failure modes involve writing the wrong artifact to many vehicles. SAFE-UC-0006's primary failure modes involve reading the right data from many vehicles and then doing the wrong thing with that read: reselling it, repurposing it for insurance discrimination, leaking it across tenants, or letting it be tampered with to evade a regulator. Many of these failure modes are not yet covered by SAFE-MCP techniques and are flagged honestly in §8.

---

## 2. Industry context & constraints (reference-guide lens)

### Where this shows up

Common in:

* **commercial fleets** (truckload, less-than-truckload, last-mile delivery, transit, school-bus, refuse, utility, ride-hail, rental, shared-mobility) ranging from single-vehicle owner-operators to global carriers with hundreds of thousands of power units
* **passenger-vehicle OEMs with connected-vehicle programs** ingesting telemetry for warranty, recall, feature usage, and OEM-cloud services
* **commercial-vehicle and truck OEMs** (Daimler Truck, PACCAR, Volvo Trucks, Scania, Navistar) running Class 8 connected-services platforms
* **aftermarket telematics service providers** selling SaaS dashboards, often via OBD-II or J1939 dongles or factory-fit gateways with a CAN tap
* **insurance carriers** running usage-based-insurance programs, accident-response detection, and claims-investigation telematics pulls
* **fleet-management software platforms** (Geotab, Samsara, Verizon Connect, Trimble, Motive) that aggregate cross-OEM and cross-fleet data
* **regulatory-facing systems** for FMCSA HOS, NHTSA Part 573, IFTA, IRP, and dispatcher-to-driver compliance flows
* **roadside-assistance, fuel-card, toll, and weigh-station integrations** that consume a subset of telematics data

### Typical systems

* **vehicle-side:** CAN / CAN FD / Automotive Ethernet, OBD-II port (light duty), SAE J1939 (heavy duty), telematics control unit (TCU), gateway ECU, ADAS ECUs, HMI / IVI, dashcam (forward and inward facing), GNSS receiver, cellular modem, electronic logging device (ELD)
* **edge / aftermarket:** OBD-II or J1939 dongle, fleet-installed gateway, edge AI camera (dashcam with on-device ML)
* **backend:** TSP cloud (multi-tenant SaaS), OEM cloud (single-OEM), CAN-data normalization service, time-series telemetry store, anomaly-detection ML pipeline, predictive-maintenance ML pipeline, driver-behavior scoring pipeline, dispatcher console with LLM assistant, insurance underwriting feed, recall-screening service
* **regulatory-facing:** FMCSA ELD interface (per 49 CFR §395.20 onward), NHTSA Part 573 filing tooling, IFTA / IRP reporting, dealer-service-management integration
* **AI/ML:** anomaly detection on time-series telemetry, computer vision on dashcam frames (driver state, road state, harsh-event classification), LLM dashboards and dispatcher copilots, predictive-maintenance models, driver-scoring models, route-optimization models

### Constraints that matter

* **Cyber-physical with read-side privacy weight.** The same telemetry that drives a maintenance alert is sensitive personal information under CCPA/CPRA, Texas DPSA, Virginia VCDPA, Colorado CPA, and equivalent state laws, and is protected health-adjacent under GDPR Article 9 in the EU when behavioral inferences cross into health.
* **Multi-party legitimate readers.** A single telemetry record can be read by the driver, the dispatcher, the fleet-safety manager, the OEM warranty team, the aftermarket TSP, the insurer, the roadside-assistance provider, the recall-screening service, and (under subpoena) law enforcement. Each reader has different rights, retention obligations, and disclosure constraints.
* **Regulated reporting on the recall side.** 49 CFR §573.6 obliges manufacturers to file defect or noncompliance reports within 5 working days of a safety-related determination; telematics data is increasingly the source of that determination. EU 2018/858 in-service conformity creates a parallel obligation in Europe.
* **Regulated logging on the HOS side.** 49 CFR Part 395 Subpart B requires registered ELDs for most CMV drivers in interstate commerce; §395.34 governs malfunction handling and gives the motor carrier 8 days to correct an ELD malfunction. FMCSA periodically removes ELDs from the registered list when they fail to meet specifications.
* **Consent and disclosure under privacy law.** California CCPA/CPRA treats precise geolocation and behavioral data as sensitive personal information; the FTC's May 2024 Tech Blog post articulates the federal posture that surreptitious disclosure is unfair-and-deceptive; the GM/OnStar order is now the operative precedent. EU GDPR Article 22 governs solely-automated decisions with legal or significant effects (such as UBI premium calculation).
* **OT / IT trust boundary.** Telemetry originates as OT data (NIST SP 800-82 Rev. 3 scope). As soon as it crosses into the SaaS or OEM cloud it becomes IT data subject to a different control regime; the boundary itself is a trust event.
* **Aftermarket-device supply chain.** The OBD-II or J1939 dongle is a write-capable port on the vehicle network. SAE J3138_202210 (Diagnostic Link Connector Security, October 2022) governs its security expectations.

### Must-not-fail outcomes

* selling, transferring, or otherwise disclosing precise geolocation or driver-behavior data without informed consent to consumer reporting agencies, data brokers, or insurance companies (the GM/OnStar pattern)
* allowing telematics data of one tenant fleet to be readable by another tenant fleet on a shared TSP plane (cross-fleet bleed)
* missing a 49 CFR §573.6 defect-determination filing window when the determination is grounded in telematics signals
* permitting ELD tampering or falsification to go undetected when it would change the regulatory record under 49 CFR Part 395
* using telematics-derived inferences to support an insurance underwriting decision that has legal or significant effects without GDPR Article 22 or equivalent state-law safeguards
* allowing dashcam imagery, particularly inward-facing cabin imagery, to leak from the platform (the April 2023 Tesla cabin-camera reporting illustrates the harm shape)
* permitting an aftermarket dongle's compromise to write to vehicle-control networks (J3138 violation)

---

## 3. Workflow description & scope

### 3.1 Workflow steps (happy path)

1. Telematics is provisioned on the vehicle. Either the OEM TCU activates against the OEM cloud, or an aftermarket dongle is installed at the OBD-II / J1939 port and registers against a TSP cloud, or both.
2. Continuous telemetry (GPS, CAN messages, ECU faults, dashcam frames, harsh-event detections, HOS-driver-status events, fuel and tire signals) streams to the cloud over cellular.
3. Cloud ingest validates the data shape, deduplicates, and routes to per-tenant time-series stores; ML pipelines run anomaly-detection, predictive-maintenance, and driver-behavior scoring.
4. Dispatcher and fleet-manager dashboards present aggregated views, often with an LLM assistant that summarizes incidents, drafts coaching notes, and answers "why is this truck flagged" questions.
5. Specific signal classes route to specialized consumers: warranty fault codes to the OEM warranty team or dealer, recall-relevant signals to the recall-screening service, HOS exceptions to the safety manager, harsh-event clips to the safety-coaching workflow, UBI signals to the insurer feed.
6. When a signal class crosses a regulatory threshold (a defect-determination signal or an ELD malfunction or an injury-relevant harsh event) the workflow triggers the corresponding regulated process: NHTSA Part 573 filing draft, ELD malfunction notice, insurance claim hand-off.
7. Drivers and fleet managers receive periodic exports for IFTA / IRP / DOT / state-DOT filings; insurers receive periodic UBI feeds; OEMs receive periodic warranty-aggregation feeds.
8. End-of-life: telematics provisioning is removed at vehicle decommissioning; retention windows for the various data classes apply (driver-identifiable, anonymized, aggregated).

### 3.2 In scope / out of scope

* **In scope:** ingest of OEM-cloud and aftermarket-TSP telemetry; multi-tenant fleet dashboarding; LLM-assisted dispatcher and fleet-safety consoles; predictive-maintenance recommendations; HOS compliance flagging; driver-behavior scoring; recall-trigger surveillance; insurance-feed generation; dashcam clip review (forward and inward facing); cross-OEM telematics aggregation on TSP platforms; ELD compliance per 49 CFR Part 395; defect-determination feed into 49 CFR Part 573; warranty-feed generation.
* **Out of scope:** writing to the vehicle's safety-critical E/E systems (handled in SAFE-UC-0008 OTA workflow); autonomous remote-disable or remote-control of moving vehicles without a named human authorizer; insurance underwriting decisions made solely by AI without GDPR Article 22 or equivalent safeguards; selling driver-identified telemetry to data brokers or consumer reporting agencies without informed consent (the operative GM/OnStar prohibition); dashcam imagery release outside the documented retention and access path.

### 3.3 Assumptions

* The TSP or OEM operates a multi-tenant cloud where one fleet's data must not be readable by another fleet without explicit federation agreement.
* A named human (fleet safety officer, OEM safety officer, or insurance underwriter as appropriate) is accountable for any decision with legal or significant effects on the driver or vehicle.
* The aftermarket dongle, if present, complies with SAE J3138_202210 expectations on the diagnostic-link connector.
* The ELD, if present, is on the FMCSA registered list and operates per 49 CFR §395.20 onward.
* The OEM has a CSMS under UN R155 (where the vehicle is type-approved in a UNECE jurisdiction).

### 3.4 Success criteria

* Every legitimate consumer (driver, dispatcher, fleet-safety manager, OEM warranty, TSP, insurer, recall-screening, roadside) can read only the slice of telemetry their role and consent grant, and no more.
* Cross-fleet bleed across the TSP plane is provably absent under test.
* Defect-determination signals reach the Part 573 workflow within the regulated window.
* ELD malfunctions are detected and corrected within the 8-day window of §395.34.
* No telemetry leaves the platform to a consumer reporting agency or data broker without affirmative driver consent (the GM/OnStar standard).
* Dashcam imagery, particularly cabin imagery, is gated, audited, and never accessible to operations staff outside the documented path.
* UBI scoring decisions with legal or significant effects on the driver have a named human in the loop.

---

## 4. System & agent architecture

### 4.1 Actors and systems

* **Human roles:** driver; dispatcher; fleet-safety officer; fleet-maintenance manager; OEM warranty manager; OEM safety officer (UN R155 cyber, ISO 26262 functional safety where applicable); recall coordinator; insurance underwriter; insurance claims investigator; TSP customer-success and platform-operations; data-protection officer (DPO).
* **Agent / orchestrator:** the LLM-assisted dashboard and dispatcher copilot; the predictive-maintenance and driver-scoring ML pipelines; the recall-screening and warranty-feed services.
* **LLM runtime:** typically a hosted foundation model behind the dispatcher console and the fleet-safety summarizer; sometimes an OEM-private foundation model for OEM-cloud consoles.
* **Tools (MCP servers / APIs / connectors):** OEM-cloud API, TSP API (Geotab MyGeotab, Samsara Cloud, Verizon Connect Reveal, Motive, Trimble), telematics-normalization service, ELD-system API, dashcam media service, insurance-feed connector, NHTSA Part 573 filing connector, IFTA / IRP filing connectors, fuel-card and toll integrations, ticketing and dealer-service-management integration.
* **Data stores:** per-tenant time-series telemetry, dashcam media object store, ELD record store (regulated retention), driver-identity store, vehicle-identity store, fleet-hierarchy store, customer-consent store.
* **Downstream systems affected:** vehicle-side ECUs (only via the OEM OTA workflow in SAFE-UC-0008, not this one); driver-pay systems; insurance underwriting systems; OEM warranty systems; recall-coordination workflows; roadside-assistance dispatch; law-enforcement subpoena-response.

### 4.2 Trusted vs untrusted inputs (the identity pentangle)

A defining trait of this workflow is that the same telemetry record has at least five legitimate readers with different rights and different threat postures. The trust posture is per-source, per-consumer, and per-purpose, not per-record.

| Input / source                                  | Trusted?             | Why                                                                              | Typical failure / abuse pattern                                                            | Mitigation theme                                                              |
| ----------------------------------------------- | -------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| OEM-cloud telemetry (TCU + gateway ECU)         | Semi-trusted         | originates inside the OEM trust perimeter; vehicles can still be compromised     | telemetry poisoning by a compromised TCU; fabricated fault codes                           | crypto-signed telemetry where supported; statistical anomaly detection        |
| Aftermarket dongle (OBD-II / J1939)             | Untrusted-leaning    | install path is outside any trust perimeter; dongle is a write-capable port      | tool-poisoning, firmware compromise, J3138 violation, CAN-bus injection from the dongle    | SAE J3138 alignment; write-disable on the dongle; per-tenant manifest signing |
| Driver dashcam (forward-facing)                 | Semi-trusted         | OEM or TSP-provisioned, but adversarial road inputs are real                     | physical adversarial signage; lighting attacks; harsh-event misclassification              | multimodal sanity checks; do not let the model alone trigger regulated action |
| Driver dashcam (inward / cabin-facing)          | Sensitive            | personal data of the driver and any passenger                                    | inappropriate access (the April 2023 Tesla Mattermost case); cross-tenant leakage          | strict access path; audit on every view; cabin-imagery is its own consent scope |
| ELD record (per 49 CFR Part 395)                | Authoritative-but-tamperable | the regulatory record itself                                                  | falsification by a malicious driver, fleet manager, or compromised ELD provider            | tamper-detection; FMCSA registered-list verification; cross-source corroboration |
| Driver-entered notes and dispatcher chat        | Untrusted            | free text                                                                        | indirect prompt injection into the LLM dashboard                                           | quote-isolate; treat as data; do not let free text drive tool calls           |
| TSP API output (cross-fleet aggregations)       | Tenant-scoped        | shared multi-tenant plane                                                        | cross-tenant bleed; rug-pull after a TSP acquisition                                       | tenant isolation must hold; per-tenant signing of API responses               |
| Recall / regulator communications               | Authoritative        | regulator-originated                                                              | phishing masquerading as regulator contact                                                  | out-of-band authentication; established channels                              |
| LLM output (dashboard summaries, coaching notes) | Untrusted-by-construction | probabilistic                                                                  | hallucinated maintenance recommendation; fabricated incident narrative                      | grounded retrieval; source-record citation; attribution to a named drafter    |
| Public threat-intel and researcher disclosures  | Semi-trusted         | useful but mixed quality                                                          | feed poisoning; false-positive engineering                                                  | provenance weighting; cross-reference Auto-ISAC                               |

### 4.3 Trust boundaries (required)

* **Driver to vehicle:** the human is accountable for what happens at the wheel; the vehicle is the system of record.
* **Vehicle to OEM cloud:** OEM-issued credentials, TLS, signed firmware; the vehicle is semi-trusted because it can be compromised.
* **Vehicle to aftermarket dongle:** SAE J3138 expectations apply; the dongle must not write to safety-critical networks.
* **Aftermarket dongle to TSP cloud:** TSP-issued credentials; per-tenant scoping; dongle firmware is in the supply chain.
* **TSP cloud across tenants:** tenant isolation must hold; one customer's context must not bleed into another's.
* **OEM cloud to insurer feed:** explicit consent path under the GM/OnStar standard; precise geolocation and driver-behavior data must not flow to consumer reporting agencies without informed consent.
* **OEM cloud to data broker:** absent affirmative consent, this path is closed (the canonical FTC enforcement frontier).
* **Driver-identifiable telemetry to subpoena response:** named-human attribution and documented chain of custody.

### 4.4 Permission and approval design

* **Read scopes are per-role and per-purpose,** not per-record. A fleet-safety manager can see a driver's harsh-events; the dispatcher can see live position; the OEM warranty team can see fault codes and VIN; the insurer can see UBI features but not raw cabin imagery; the recall-screening service can see specific defect signals.
* **Cabin imagery is its own consent scope** with its own audit trail.
* **Cross-tenant queries on TSP platforms** require explicit federation agreement and run through a separate audit path.
* **Any disclosure to a consumer reporting agency, data broker, or insurance carrier** must surface the GM/OnStar-style affirmative-consent record and the regulated disclosure language verbatim.
* **Solely-automated decisions with legal or significant effects** (UBI premium changes, employment actions tied to driver scoring) require a named human approver.

### 4.5 Tool inventory (required)

| Tool / connector                                  | Read / Write | Scope                                              | Risk class                                                                 |
| ------------------------------------------------- | ------------ | -------------------------------------------------- | -------------------------------------------------------------------------- |
| OEM-cloud telemetry API                           | Read         | Per-tenant, per-VIN, per-role                     | Privacy-sensitive; cyber-physical-adjacent                                  |
| TSP API (Geotab, Samsara, Verizon Connect, etc.)  | Read         | Per-tenant, per-VIN, per-role                     | Privacy-sensitive; multi-tenant isolation-critical                          |
| ELD interface                                     | Read         | Per-driver                                         | Regulated record; tamper-evident                                            |
| Dashcam media service                             | Read         | Per-tenant; cabin imagery has its own consent scope | Sensitive PII                                                               |
| Predictive-maintenance ML pipeline                | Read + Write | Inferences only; no vehicle-side write             | Decision-influencing; do not connect to OTA                                 |
| Driver-behavior scoring pipeline                  | Read + Write | Inferences only                                    | Discrimination-sensitive; UBI feed                                          |
| LLM dispatcher copilot                            | Read         | Tenant-scoped                                      | Indirect prompt-injection surface                                           |
| Insurance feed connector                          | Write (egress) | Per-customer, per-consent                        | Regulated disclosure surface                                                |
| NHTSA Part 573 filing connector                   | Write (egress) | OEM-only                                         | Regulated disclosure surface                                                |
| FMCSA / IFTA / IRP filing connectors              | Write (egress) | Carrier-only                                     | Regulated disclosure surface                                                |
| Roadside-assistance dispatch                      | Write         | Per-driver consent                                | Privacy-sensitive                                                           |
| Subpoena-response handler                         | Read         | Documented chain of custody                       | Legal-process-only                                                          |

---

## 5. Operating modes

### 5.1 Manual (read-only assistance)

Humans drive every action. The system shows the dashboard, the LLM summarizes, and humans decide. Most regulator-sensitive deployments default here.

**Risk profile:** bounded by reviewer capacity. Privacy risk dominates over decision-error risk.

### 5.2 HITL per-action (common for safety, recall, and underwriting decisions)

The system proposes specific actions (drafting a Part 573 filing, escalating an HOS exception, flagging a UBI tier change, recommending a maintenance intervention) and a named human approves each. Common for OEM warranty, insurer, and fleet-safety teams.

**Risk profile:** moderate. UI discipline and resistance to consent fatigue determine quality. Long alert lists are a known SAFE-T1403 surface.

### 5.3 Autonomous on a narrow allow-list (bounded autonomy)

A pre-declared allow-list of low-risk actions runs without per-action approval: routine maintenance reminders, route-optimization suggestions, low-stakes dispatcher coaching nudges. Anything touching regulated reporting, insurance underwriting, or data-broker disclosure stays HITL or manual.

**Risk profile:** depends on allow-list discipline and on resistance to telemetry poisoning that could satisfy the allow-list under adversarial conditions.

### 5.4 Fully autonomous with guardrails (rare)

End-to-end autonomous flagging and feed-out, with post-hoc human review. Practitioners commonly avoid this for any path that touches insurance underwriting, defect determination, or data-broker disclosure.

**Risk profile:** highest. Hard to reconcile with GDPR Article 22, the FTC Section 5 GM/OnStar precedent, or 49 CFR §573.6 named-officer accountability.

### 5.5 Variants

Architectural variants teams reach for:

1. **OEM-only versus TSP versus federated.** Single-OEM deployments are simpler but rarer at fleet scale; aftermarket-TSP deployments span OEMs but multiply the multi-tenant trust surface; federated deployments combine both and require explicit federation agreements.
2. **Edge AI on dashcam.** Running driver-state and harsh-event classification on the dashcam itself reduces backhaul cost and exposure to cabin imagery. Lytx and Motive document this pattern; the trade-off is model-update governance at the edge.
3. **Insurer-isolated UBI plane.** Some carriers run UBI behind a separate API plane to keep underwriting decisions auditable under GDPR Article 22 and state insurance-regulator scrutiny.
4. **Dispatcher copilot as read-only summarizer.** A common safe default: the LLM only summarizes per-tenant telemetry and never authors regulated text.
5. **Independent privacy monitor.** A separately-authored monitor that watches for cross-tenant queries, broker-feed activations, and dashcam-cabin-access events on a non-overlapping signal set.

---

## 6. Threat model overview (high-level)

### 6.1 Primary security & safety goals

* preserve driver and passenger privacy across the multi-party reader set
* preserve tenant isolation across the TSP multi-tenant plane (one customer's context must not bleed into another's)
* preserve the integrity of regulated records (ELD per 49 CFR Part 395; defect determinations per 49 CFR Part 573)
* prevent telematics-derived inferences from supporting unfair, deceptive, or discriminatory underwriting decisions
* prevent the aftermarket dongle from becoming a vehicle-control attack surface (J3138 alignment)
* preserve the workflow's fitness-for-purpose under adversarial telemetry inputs

### 6.2 Threat actors (who might attack or misuse)

* **OEM-internal data-broker arms** repurposing telematics for resale (the GM/OnStar pattern; Hyundai-Verisk and Honda-Verisk per the Wyden-Markey investigation)
* **Insurance carrier data-aggregator subsidiaries** harvesting via embedded SDKs (the Allstate-Arity pattern under TDPSA)
* **Fleet-management TSPs** with weak tenant isolation
* **Compromised aftermarket-dongle suppliers** (J3138 scope)
* **Malicious drivers or fleet managers** falsifying ELDs to evade HOS enforcement
* **Nation-state and criminal actors** targeting the cellular and cloud paths (Upstream's 2025 finding that telematics is now 66 percent of automotive incidents)
* **Civil adversaries** including stalking, domestic-abuse misuse of OEM connected-vehicle apps (well-documented in journalism)
* **Researchers** disclosing in good faith via Auto-ISAC

### 6.3 Attack surfaces

* OEM and TSP cloud APIs, ingestion pipelines, multi-tenant data plane
* aftermarket OBD-II / J1939 dongle, dongle firmware, dongle install path
* dashcam imagery store and access path (forward-facing and cabin-facing)
* ELD device and ELD-cloud sync
* dispatcher LLM copilot (indirect prompt injection from telemetry-derived free text)
* insurance feed connector (egress to consumer-reporting and underwriting systems)
* recall-screening and Part 573 filing path
* subpoena-response path
* identity, consent, and per-tenant scoping infrastructure

### 6.4 High-impact failures (include industry harms)

* **Customer / consumer harm:** non-consented data sale to a consumer reporting agency or data broker (the operative GM/OnStar harm); UBI premium discrimination; cabin-imagery misuse; stalking enabled by OEM connected-vehicle app misuse; data leakage to a domestic-abuser co-owner.
* **Business harm:** FTC Section 5 enforcement; state-AG action under TDPSA / VCDPA / CPA / CCPA-CPRA; CPPA settlements (the $632,500 American Honda settlement is the operative California precedent); EU GDPR fines; SEC disclosure exposure for connected-vehicle data incidents at public OEMs.
* **Cyber-physical harm:** aftermarket-dongle compromise that crosses J3138 expectations; TSP supply-chain compromise that pivots into vehicle-control networks; CAN-injection that propagates through the gateway.
* **Safety harm:** missed defect-determination signal that delays a Part 573 recall window; missed predictive-maintenance signal on a safety-critical subsystem; HOS falsification that lets a fatigued driver remain on the road.

---

## 7. Kill-chain analysis (stages → likely failure modes)

> Keep this defender-friendly. Describe patterns, not "how to do it."
>
> Note: this UC uses a **seven-stage kill chain**. Four stages are flagged NOVEL versus SAFE-UC-0008 (OTA, the closest cyber-physical precedent) and SAFE-UC-0009 (manufacturing CV). The novelty centers on the read-side privacy surface, the aftermarket-TSP trust boundary, the adversarial-telemetry surface, and the UBI pricing-discrimination surface.

| Stage                                                                                            | What can go wrong (pattern)                                                                                                                         | Likely impact                                                                                            | Notes / preconditions                                                                                                  |
| ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| 1. Aftermarket telematics device or TSP-integration trust onboarding (**NOVEL: 5-party identity pentangle**) | Compromised dongle firmware; rogue TSP MCP server; J3138-out-of-spec write-back from the dongle; over-scoped TSP API token at install              | tampered telemetry from day one; dongle as a CAN attack surface; over-broad reads across the fleet       | aftermarket installs by definition outside any OEM trust perimeter; J3138 alignment is the recovery anchor             |
| 2. Telemetry-derived prompt corruption and indirect injection                                    | Adversarial driver notes, dispatcher chat, dashcam OCR, or fault-code descriptions injected into the LLM dashboard's context                        | the LLM proposes the wrong intervention; the dashboard summary is wrong                                   | every free-text channel is a vector; quote-isolation is the floor mitigation                                            |
| 3. Adversarial telemetry inputs (**NOVEL: SAFE-MCP partial coverage**)                          | GPS spoofing for HOS evasion; CAN-bus signal injection; dashcam adversarial frames or lighting attacks; fabricated maintenance signals to game warranty | regulator-record falsification; missed safety signal; warranty fraud                                     | RF-layer GPS spoofing and CAN injection sit outside SAFE-MCP today; T1110 is the closest analog but does not fully fit |
| 4. Cross-tenant data bleed on the multi-tenant TSP plane                                         | Misconfigured per-tenant scoping; rug-pull after TSP acquisition; shared-cache poisoning that crosses tenants                                          | one customer's data exposed to another; regulatory exposure; reputational harm                            | tenant isolation must hold; this is the central TSP failure mode                                                       |
| 5. Privileged action manipulation (recall trigger, HOS flag, remote-disable)                     | The agent persuaded to issue a recall flag, file a Part 573 draft, or issue a remote-disable command on poisoned signals                              | regulator-record damage; service disruption; loss of trust                                                | recall and HOS paths must be HITL with named-human attribution; remote-disable belongs in SAFE-UC-0008's scope, not here |
| 6. Privacy-secondary-use or data-broker resale (**NOVEL: load-bearing**)                        | Driver-behavior or geolocation data sold or transferred to a consumer reporting agency, insurer, or data broker without affirmative consent          | the GM/OnStar harm shape; FTC Section 5 enforcement; state-AG action; CPPA fine                          | T1801 (Automated Data Harvesting) and T1804 (API Data Harvest) are the closest SAFE-MCP anchors; secondary-use harm itself is not yet a SAFE-MCP technique |
| 7. UBI / driver-scoring pricing discrimination (**NOVEL: model-poisoning + cohort harm**)        | The driver-scoring model is poisoned, or its training data is biased, in ways that produce discriminatory UBI tiers or employment recommendations  | unfair-and-deceptive insurance practices; GDPR Article 22 violation; state-insurance-regulator action     | T2107 (model poisoning) and T2105 (disinformation output) are the closest anchors; fair-lending-equivalent fairness review is a separate discipline |

---

## 8. SAFE‑MCP mapping (kill-chain → techniques → controls → tests)

Practitioners commonly map this workflow's failure patterns to the following SAFE‑MCP techniques. The mapping is directional: teams adapt it to their stack, threat model, regulatory regime, fleet class, and TSP. Links in Appendix B resolve to the canonical technique pages. A note on framework gap: SAFE-MCP today covers the LLM and MCP-tool surface well, but does not yet have first-class techniques for **RF-layer GPS spoofing, CAN-bus signal injection, dashcam adversarial-frame attacks, the privacy-secondary-use / data-broker resale harm, or cohort-fairness discrimination in UBI pricing.** The mapping below cites the closest anchors and flags the gap honestly.

| Kill-chain stage                                                            | Failure / attack pattern (defender-friendly)                                                                          | SAFE‑MCP technique(s)                                                                                                                                                                                                                                                                              | Recommended controls (prevent / detect / recover)                                                                                                                                                                                                                                                                                                                                                                              | Tests (how to validate)                                                                                                                                                                                                                                                                                                                                       |
| --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Aftermarket device / TSP-integration trust onboarding                       | Dongle firmware compromise; rogue TSP MCP server; J3138-out-of-spec write-back; over-scoped TSP token                  | `SAFE-T1001` (Tool Poisoning Attack (TPA)); `SAFE-T1002` (Supply Chain Compromise); `SAFE-T1003` (Malicious MCP-Server Distribution); `SAFE-T1104` (Over-Privileged Tool Abuse)                                                                                                                    | SAE J3138_202210 alignment on the diagnostic-link connector; signed dongle firmware with reproducible builds; TSP manifest signing; tenant-scoped tokens with least privilege; per-tenant signing of API responses; install-path attestation                                                                                                                                                                                | red-team a dongle install with tampered firmware; verify J3138 write-disable; verify TSP manifest signature; least-privilege escalation tests on tokens                                                                                                                                                                                                       |
| Telemetry-derived prompt corruption and indirect injection                  | Adversarial free text in driver notes, dispatcher chat, dashcam OCR, fault-code descriptions enters the LLM context  | `SAFE-T1102` (Prompt Injection (Multiple Vectors)); `SAFE-T1110` (Multimodal Prompt Injection via Images/Audio); `SAFE-T1402` (Instruction Stenography - Tool Metadata Poisoning)                                                                                                                  | quote-isolate every free-text source; treat telemetry-derived text as data not instruction; structured-output schema for LLM responses; output-validation against a tool-call audit; multimodal sanity checks on dashcam OCR                                                                                                                                                                                                  | adversarial prompt-injection fixtures across each free-text source; multimodal-injection fixtures on dashcam frames; verify the LLM cannot drive a tool call from telemetry-derived text                                                                                                                                                                       |
| Adversarial telemetry inputs (RF-layer, CAN-bus, dashcam) (**NOVEL gap**)   | GPS spoofing for HOS evasion; CAN signal injection from a compromised dongle; dashcam adversarial frames               | `SAFE-T1110` (Multimodal Prompt Injection via Images/Audio) for dashcam; **partial fit** for RF/CAN. The privacy-secondary-use ingestion form maps to `SAFE-T1801` (Automated Data Harvesting) and `SAFE-T1804` (API Data Harvest)                                                              | multi-source corroboration (GPS plus IMU plus odometer plus cellular tower); cryptographically-signed telemetry where supported; statistical anomaly detection on telemetry distributions; do not let a single signal trigger a regulated action                                                                                                                                                                              | inject spoofed GPS fixtures and verify HOS-flag suppression; inject fabricated CAN-fault fixtures and verify multi-source disagreement; dashcam adversarial-frame fixture library                                                                                                                                                                              |
| Cross-tenant data bleed on the multi-tenant TSP plane                       | Misconfigured per-tenant scoping; shared-cache poisoning; rug-pull after TSP acquisition                              | `SAFE-T1701` (Cross-Tool Contamination); `SAFE-T1702` (Shared-Memory Poisoning); `SAFE-T1201` (MCP Rug Pull Attack); `SAFE-T2106` (Context Memory Poisoning via Vector Store Contamination)                                                                                                       | tenant-isolation enforcement at every layer (storage, cache, vector store); per-tenant signing of API responses; differential queries to detect cross-tenant bleed; vendor due diligence on TSP M&A activity; named-human review of any cross-tenant federation                                                                                                                                                                | adversarial cross-tenant query fixtures; shared-cache poisoning fixtures; bleed-detection differential tests run in CI                                                                                                                                                                                                                                          |
| Privileged action manipulation (recall, HOS, remote-disable)                | Agent persuaded to flag a recall, file a Part 573 draft, or push a remote-disable on poisoned signals                 | `SAFE-T1309` (Privileged Tool Invocation via Prompt Manipulation); `SAFE-T1404` (Response Tampering); `SAFE-T1403` (Consent-Fatigue Exploit)                                                                                                                                                       | every regulated path is HITL with named-human attribution; structured policy-as-code gates on Part 573 filing, ELD-malfunction notice, insurance feed activation; consent-fatigue mitigations on long alert lists; named signer for every external submission                                                                                                                                                                  | tabletop on a poisoned-signal-driven Part 573 attempt; verify the gate rejects without complete signal corroboration; verify consent-fatigue mitigations actually slow consent rate                                                                                                                                                                              |
| Privacy-secondary-use or data-broker resale (**NOVEL: SAFE-MCP gap**)       | Driver-behavior or geolocation data flows to a consumer reporting agency, insurer, or data broker without informed consent (the GM/OnStar harm) | `SAFE-T1801` (Automated Data Harvesting); `SAFE-T1804` (API Data Harvest); `SAFE-T1502` (File-Based Credential Harvest); `SAFE-T1503` (Env-Var Scraping). **Gap:** no SAFE-MCP technique today captures secondary-use harm itself                                                                | egress allow-list for any consumer-reporting / data-broker / insurance-carrier endpoint; affirmative-consent gate (the GM/OnStar standard) verbatim-surfaced to the driver; named-human approval on every disclosure path; minimum-data principle on every feed; differential-privacy noise where appropriate                                                                                                              | tabletop the GM/OnStar scenario against your platform; verify egress allow-list blocks unconsented disclosure; verify affirmative-consent flow surfaces verbatim regulated language                                                                                                                                                                            |
| UBI / driver-scoring pricing discrimination (**NOVEL: cohort harm**)        | Driver-scoring model poisoned or biased; UBI tiers or employment recommendations disproportionately harm a cohort     | `SAFE-T2107` (AI Model Poisoning via MCP Tool Training Data Contamination); `SAFE-T2106` (Context Memory Poisoning via Vector Store Contamination); `SAFE-T2105` (Disinformation Output)                                                                                                          | training-data provenance and signing; fairness audits aligned to GDPR Article 22 / state-insurance-regulator expectations; named-human approval for any solely-automated decision with legal or significant effect; driver-side appeals process with documented response                                                                                                                                                       | adversarial training-data fixtures; fairness regression tests across protected cohorts; appeal-flow integrity test; verify named-human approval is enforced for solely-automated decisions                                                                                                                                                                       |
| ELD and regulated-record tampering / impact                                  | Falsified ELD records; tampered defect signals; missing 49 CFR §573.6 filing window                                  | `SAFE-T2101` (Data Destruction); `SAFE-T2102` (Service Disruption via External API Flooding); `SAFE-T2105` (Disinformation Output)                                                                                                                                                                  | tamper-evident ELD record store; FMCSA registered-list verification; cross-source corroboration (ELD plus telematics plus dashcam); §573.6 filing-timer integrity; named signer for every external submission                                                                                                                                                                                                                  | tabletop a §573.6 timing-failure scenario; tamper-attempt detection on the ELD store; cross-source corroboration tests                                                                                                                                                                                                                                            |

---

## 9. Controls & mitigations (organized)

### 9.1 Prevent (reduce likelihood)

* **SAE J3138 alignment** on every aftermarket dongle install path; the dongle must not write to safety-critical networks.
* **Tenant isolation as a hard invariant** across storage, cache, and vector store; differential queries verify isolation in CI.
* **Affirmative-consent gate** on every disclosure path to a consumer reporting agency, data broker, or insurance carrier; the gate surfaces regulated disclosure language verbatim from an authoritative source.
* **Egress allow-list** for any external consumer-reporting / data-broker / insurance-carrier endpoint.
* **Minimum-data principle** on every feed: send the smallest record the consumer's purpose justifies; aggregate or anonymize where the purpose allows.
* **Cabin-imagery is its own consent scope** with its own audit path; access by operations staff is strictly gated.
* **Quote-isolation** on every free-text channel into the LLM dashboard.
* **Named-human attribution** on every solely-automated decision with legal or significant effect (UBI premium changes, employment actions tied to driver scoring, defect determinations under 49 CFR §573.6).
* **Cryptographically-signed telemetry** where the OEM and platform support it; multi-source corroboration where they do not.
* **Auto-ISAC engagement** for coordinated disclosure of telematics-relevant findings.

### 9.2 Detect (reduce time-to-detect)

* tenant-isolation differential queries run continuously in CI and in production
* egress monitoring on every consumer-reporting / data-broker endpoint
* anomaly detection on telemetry distributions (GPS, CAN, fault-code rates) keyed to spoofing patterns
* dashcam-imagery access audit (forward and cabin imagery, separately)
* consent-rate monitoring on driver-facing disclosure flows
* §573.6 filing-timer integrity (defect determination to filing latency)
* ELD-malfunction-detection-to-correction latency against the §395.34 8-day window
* indicators of compromise on TSP API tokens, dongle firmware versions, OEM-cloud credentials
* fairness regression on UBI scoring across cohorts

### 9.3 Recover (reduce blast radius)

* incident-response playbook for an inferred or confirmed cross-tenant bleed
* incident-response playbook for an inferred or confirmed unconsented data-broker disclosure (the GM/OnStar shape)
* coordinated-disclosure path through Auto-ISAC for telematics vulnerabilities
* dongle-revocation playbook if a J3138-out-of-spec write is detected
* driver-side appeals process for UBI scoring decisions, with documented response timelines
* cabin-imagery breach playbook with privacy-officer involvement
* regulator-notification playbook per jurisdiction (FTC, state AG, CPPA, EU DPA, FMCSA, NHTSA) pre-mapped with countdown SLAs

---

## 10. Validation & testing plan

### 10.1 What to test (minimum set)

* **Tenant isolation** holds under adversarial cross-tenant queries.
* **J3138 alignment** holds on every aftermarket dongle path.
* **Affirmative-consent gate** triggers on every disclosure to consumer reporting agencies, data brokers, and insurance carriers.
* **Quote-isolation** holds on every free-text channel into the LLM dashboard.
* **Spoofed-GPS** does not suppress an HOS flag without multi-source disagreement.
* **Fabricated CAN-fault** does not trigger a Part 573 filing without multi-source corroboration.
* **Dashcam adversarial frames** do not trigger regulated action.
* **UBI scoring** passes fairness regression across protected cohorts.
* **§573.6 filing-timer** integrity from defect determination to filing.
* **§395.34 ELD-malfunction** detection-to-correction latency.

### 10.2 Test cases (make them concrete)

| Test name                                | Setup                                                          | Input / scenario                                                                                          | Expected outcome                                                                                                          | Evidence produced                              |
| ---------------------------------------- | -------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| Cross-tenant bleed differential          | Two synthetic tenant fleets on the same TSP plane              | Tenant A queries for VIN belonging to Tenant B                                                            | Query rejected; differential test passes; audit captures attempt                                                          | differential-query log + audit trail            |
| J3138 write-disable                      | Aftermarket dongle on a test bench                              | Dongle attempts a CAN write to a safety-critical bus                                                       | Write blocked at the gateway; alert fires                                                                                 | gateway log + alert                              |
| Affirmative-consent gate                 | Synthetic disclosure flow to a mock consumer-reporting endpoint | Operator triggers a disclosure without affirmative consent on file                                         | Disclosure blocked; verbatim-surfaced consent UI displayed; audit captures intent                                          | consent-flow log + blocked disclosure log       |
| Telemetry-prompt-injection isolation     | LLM dashboard with seeded adversarial driver-note text          | Adversarial driver note attempts to trigger a Part 573 filing through the LLM                              | LLM treats text as data; no tool call escalation; filing not drafted; audit captures injection                              | LLM-call audit + tool-call audit                |
| Spoofed GPS HOS suppression              | Synthetic GPS spoofing fixture on a test driver                 | Spoofed GPS fixture attempts to suppress an HOS exception                                                   | Multi-source disagreement (IMU, cellular, odometer) fires; HOS flag stands; spoof attempt audited                            | multi-source-disagreement log                    |
| Fabricated CAN-fault corroboration        | Synthetic CAN-fault injection fixture                           | Fabricated fault attempts to trigger a Part 573 draft                                                      | Multi-source corroboration fails; draft not generated; audit captures injection                                              | corroboration-failure log                        |
| Dashcam adversarial-frame robustness     | Adversarial-frame fixture library                               | Adversarial frames attempt to trigger a regulated action                                                   | Multimodal sanity check fires; no regulated action; audit captures attempt                                                  | sanity-check log                                  |
| UBI fairness regression                  | Synthetic cohort fixtures across protected attributes            | Driver-scoring model produces UBI tier recommendations                                                     | Fairness metrics within declared bounds; named-human approval enforced for solely-automated decisions                       | fairness-metric log + approval-gate log         |
| §573.6 filing-timer                      | Synthetic defect-determination event                             | Determination triggers Part 573 workflow                                                                   | Filing-timer integrity from determination to draft to named-signer attestation; deadline met                                 | filing-timer log                                  |
| Cabin-imagery access audit               | Synthetic operator account                                       | Operator attempts to view cabin imagery outside the documented path                                        | Access blocked; privacy-officer alert; audit captures attempt                                                                | cabin-imagery audit                              |

### 10.3 Operational monitoring (production)

* tenant-isolation differential-query pass rate
* dongle-firmware version distribution and signing-validation pass rate
* affirmative-consent gate trigger rate on disclosure flows
* dashcam-imagery access events (forward and cabin, separately)
* consent-rate distribution on driver-facing disclosure flows
* §573.6 filing-timer integrity (no missed windows)
* §395.34 ELD-malfunction-correction latency
* TSP API token least-privilege drift detection
* UBI fairness metric drift
* Auto-ISAC coordinated-disclosure ingest rate

---

## 11. Open questions & TODOs

- [ ] Define the organization's acceptable scope of autonomous decisions on telematics-driven workflows; which actions are HITL-only versus allow-listed.
- [ ] Document the named-human roles (fleet safety officer, OEM safety officer, OEM warranty manager, insurance underwriter, recall coordinator, DPO) and their attestation artifacts.
- [ ] Specify the tenant-isolation invariant across storage, cache, and vector store, and how it is tested in CI.
- [ ] Map the disclosure paths to consumer reporting agencies, data brokers, and insurance carriers, and the affirmative-consent gate language for each.
- [ ] Document the J3138 alignment evidence for every aftermarket dongle path.
- [ ] Map regulator-filing SLAs per jurisdiction (FTC, state AG, CPPA, EU DPA, FMCSA, NHTSA) and pre-mapped countdown timers.
- [ ] Decide the cabin-imagery access path, retention window, and audit cadence.
- [ ] Define the UBI fairness regression and the appeals process for solely-automated decisions.
- [ ] Document Auto-ISAC engagement procedures for telematics-specific findings.

---

## 12. Questionnaire prompts (for reviewers)

### Workflow realism

* Are the integrations (OEM cloud, TSP API, ELD, dashcam, insurance feed, NHTSA Part 573, FMCSA filing) realistic for the organization's stack and fleet class?
* Does the workflow distinguish OEM-only, aftermarket-TSP, and federated deployments, and document the trust boundaries in each?
* Is the dispatcher LLM copilot scoped to summarization only, or does it author regulated text?

### Trust boundaries & permissions

* Does tenant isolation hold across storage, cache, and vector store, and is it tested in CI?
* Is the aftermarket dongle path J3138-aligned, and is the alignment evidenced?
* Is cabin imagery a separate consent scope with a separate audit path?

### Output safety & persistence

* Are LLM-authored summaries grounded in source-record retrieval with verbatim-surfaced regulated language where applicable?
* Are solely-automated decisions with legal or significant effect gated by named-human approval?
* Are appeals on UBI scoring decisions documented, time-bounded, and audit-evident?

### Disclosure and consent

* Does the affirmative-consent gate trigger on every disclosure to consumer reporting agencies, data brokers, and insurance carriers?
* Is the regulated disclosure language surfaced verbatim from an authoritative source?
* Does the egress allow-list block unconsented disclosure paths?

### Adversarial robustness

* Is the workflow tested against spoofed GPS, fabricated CAN faults, dashcam adversarial frames, and adversarial driver-note text?
* Are multi-source corroboration thresholds documented and tested?
* Are TSP-acquisition rug-pull scenarios tabletoped and rehearsed?

### Regulated-reporting integrity

* Are 49 CFR §573.6 filing-timer integrity and named-signer attestation evidenced?
* Is 49 CFR §395.34 ELD-malfunction-correction latency within the 8-day window?
* Which controls are commonly viewed as mandatory under the organization's sector framework (FMCSA, NHTSA, state AG, CPPA, EU DPA) versus recommended?

---

## Appendix A: Contributors and Version History

* **Authoring:** Astha (DSO contributor, 2026-04-25)
* **Initial draft:** 2026-04-25 (Seed → Draft)

---

## Appendix B: References & frameworks

### B.1 SAFE-MCP techniques referenced in this use case

* [SAFE-T1001 Tool Poisoning Attack (TPA)](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1001/README.md)
* [SAFE-T1002 Supply Chain Compromise](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1002/README.md)
* [SAFE-T1003 Malicious MCP-Server Distribution](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1003/README.md)
* [SAFE-T1102 Prompt Injection (Multiple Vectors)](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1102/README.md)
* [SAFE-T1104 Over-Privileged Tool Abuse](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1104/README.md)
* [SAFE-T1110 Multimodal Prompt Injection via Images/Audio](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1110/README.md)
* [SAFE-T1201 MCP Rug Pull Attack](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1201/README.md)
* [SAFE-T1309 Privileged Tool Invocation via Prompt Manipulation](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1309/README.md)
* [SAFE-T1402 Instruction Stenography - Tool Metadata Poisoning](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1402/README.md) (the title preserves the verbatim "Stenography" typo from the SAFE-MCP source; the body uses the correct "steganography")
* [SAFE-T1403 Consent-Fatigue Exploit](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1403/README.md)
* [SAFE-T1404 Response Tampering](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1404/README.md)
* [SAFE-T1502 File-Based Credential Harvest](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1502/README.md)
* [SAFE-T1503 Env-Var Scraping](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1503/README.md)
* [SAFE-T1701 Cross-Tool Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1701/README.md)
* [SAFE-T1702 Shared-Memory Poisoning](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1702/README.md)
* [SAFE-T1801 Automated Data Harvesting](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1801/README.md)
* [SAFE-T1804 API Data Harvest](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1804/README.md)
* [SAFE-T2101 Data Destruction](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2101/README.md)
* [SAFE-T2102 Service Disruption via External API Flooding](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2102/README.md)
* [SAFE-T2105 Disinformation Output](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2105/README.md)
* [SAFE-T2106 Context Memory Poisoning via Vector Store Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2106/README.md)
* [SAFE-T2107 AI Model Poisoning via MCP Tool Training Data Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2107/README.md)

### B.2 Industry and AI-specific frameworks teams commonly consult

* [NIST AI Risk Management Framework 1.0 (AI 100-1, January 2023)](https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf)
* [NIST AI 600-1 Generative AI Profile (July 2024)](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)
* [NIST AI 100-2 E2025 Adversarial Machine Learning Taxonomy and Terminology of Attacks and Mitigations (24 March 2025)](https://csrc.nist.gov/pubs/ai/100/2/e2025/final)
* [NIST SP 800-82 Rev. 3 Guide to Operational Technology (OT) Security (September 2023)](https://csrc.nist.gov/pubs/sp/800/82/r3/final)
* [NIST SP 800-30 Rev. 1 Guide for Conducting Risk Assessments](https://csrc.nist.gov/pubs/sp/800/30/r1/final)
* [Regulation (EU) 2024/1689 (EU AI Act)](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
* [ISO/IEC 42001:2023 Artificial Intelligence Management System](https://www.iso.org/standard/81230.html)
* [ISO/IEC 23894:2023 AI Risk Management](https://www.iso.org/standard/77304.html)
* [ISO/SAE 21434:2021 Road vehicles cybersecurity engineering](https://www.iso.org/standard/70918.html)
* [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)
* [OWASP Machine Learning Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)
* [MITRE ATLAS adversarial threat landscape for AI systems](https://atlas.mitre.org/)
* [NIST SP 800-218A SSDF Generative AI Profile (July 2024)](https://csrc.nist.gov/pubs/sp/800/218/a/final)

### B.3 Public incidents and disclosures adjacent to this workflow

* [FTC Takes Action Against General Motors for Sharing Drivers' Precise Location and Driving Behavior Data Without Consent (January 2025 proposed action)](https://www.ftc.gov/news-events/news/press-releases/2025/01/ftc-takes-action-against-general-motors-sharing-drivers-precise-location-driving-behavior-data)
* [FTC Finalizes Order Settling Allegations that GM and OnStar Collected and Sold Geolocation Data Without Consumers' Informed Consent (14 January 2026 finalization; 5-year ban on disclosure to consumer reporting agencies)](https://www.ftc.gov/news-events/news/press-releases/2026/01/ftc-finalizes-order-settling-allegations-gm-onstar-collected-sold-geolocation-data-without-consumers)
* [Wyden and Markey Investigation Letter to FTC on automaker driver data sharing (26 July 2024; Hyundai 1.7M cars to Verisk for $1M+; Honda 97k cars for $25,920 = $0.26 per car)](https://www.wyden.senate.gov/news/press-releases/wyden-investigation-reveals-new-details-about-automakers-sharing-of-driver-information-with-data-brokers-wyden-and-markey-urge-ftc-to-crack-down-on-disclosures-of-americans-data-without-drivers-consent)
* [Texas AG Paxton Sues Allstate and Arity for Unlawfully Collecting Driving Data from 45M+ Consumers (January 2025; first TDPSA enforcement)](https://www.texasattorneygeneral.gov/news/releases/attorney-general-ken-paxton-sues-allstate-and-arity-unlawfully-collecting-using-and-selling-over-45)
* [Mozilla Foundation: Privacy Nightmare on Wheels, all 25 reviewed brands flunk privacy review (September 2023)](https://www.mozillafoundation.org/en/blog/privacy-nightmare-on-wheels-every-car-brand-reviewed-by-mozilla-including-ford-volkswagen-and-toyota-flunks-privacy-test/)
* [FTC Tech Blog: Cars and Consumer Data, On Unlawful Collection and Use (14 May 2024)](https://www.ftc.gov/policy/advocacy-research/tech-at-ftc/2024/05/cars-consumer-data-unlawful-collection-use)
* [California CPPA $632,500 Settlement with American Honda Motor Co. (12 March 2025; analysis by Wilson Sonsini)](https://www.wsgr.com/en/insights/lessons-from-the-cppas-dollar632500-settlement-with-connected-vehicle-manufacturer.html)
* [California CPPA Connected Vehicle Privacy Review Announcement (31 July 2023)](https://cppa.ca.gov/announcements/2023/20230731.html)
* [Upstream Security 2025 Global Automotive Cybersecurity Report (telematics 43% in 2023, 66% in 2024 of automotive incidents)](https://upstream.auto/blog/insights-from-upstreams-2025-automotive-cybersecurity-report/)
* [VicOne 2025 Automotive Cybersecurity Report (530 CVEs in 2024)](https://vicone.com/reports/2025-automotive-cybersecurity-report)
* [CISA ICS-ALERT-15-203-01 FCA Uconnect Vulnerability (2015 Jeep remote exploit; first cybersecurity-driven recall, 1.4M vehicles)](https://www.cisa.gov/news-events/ics-alerts/ics-alert-15-203-01)
* [CERT/CC VU#819439 FCA UConnect remote vehicle-control vulnerability (companion record)](https://www.kb.cert.org/vuls/id/819439)
* [Washington Post: Tesla employees shared private footage from customers' cars, lawsuit says (8 April 2023)](https://www.washingtonpost.com/business/2023/04/08/tesla-sued-employees-sharing-footage/)
* [CVSA 2024 International Roadcheck Results (48,761 inspections; 23% vehicle OOS; HOS top driver OOS at 32.1%)](https://cvsa.org/news/2024-roadcheck-results/)

### B.4 Domain-regulatory references

* [49 CFR Part 395 Subpart B Electronic Logging Devices (FMCSA HOS regulation)](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-III/part-395/subpart-B)
* [49 CFR §395.34 ELD malfunctions and data diagnostic events (8-day correction window)](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-III/subchapter-B/part-395/subpart-B/section-395.34)
* [49 CFR Part 573 Defect and Noncompliance Responsibility and Reports (NHTSA 5-business-day reporting)](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-V/part-573)
* [NHTSA Cybersecurity Best Practices for the Safety of Modern Vehicles (September 2022)](https://www.nhtsa.gov/document/cybersecurity-best-practices-safety-modern-vehicles-2022)
* [NHTSA Updates Cybersecurity Best Practices for New Vehicles (press release)](https://www.nhtsa.gov/press-releases/nhtsa-updates-cybersecurity-best-practices-new-vehicles)
* [FMCSA Removes Five Electronic Logging Devices from Registered List (newsroom item; FMCSA periodically revokes ELDs from the registered list)](https://www.fmcsa.dot.gov/newsroom/fmcsa-removes-five-electronic-logging-devices-registered-list)
* [California Consumer Privacy Act / CPRA (precise geolocation as sensitive personal information)](https://oag.ca.gov/privacy/ccpa)
* [GLBA Safeguards Rule (16 CFR Part 314)](https://www.ecfr.gov/current/title-16/chapter-I/subchapter-C/part-314)
* [GDPR Article 22 (automated individual decision-making)](https://gdpr-info.eu/art-22-gdpr/)
* [Regulation (EU) 2018/858 type-approval and in-service conformity](https://eur-lex.europa.eu/eli/reg/2018/858/oj/eng)
* [PCI DSS v4.0.1 (March 2025)](https://www.pcisecuritystandards.org/)

### B.5 Industry safety and governance frameworks

* [SAE J3138_202210 Diagnostic Link Connector Security (October 2022)](https://www.sae.org/standards/content/j3138_202210/)
* [Automotive ISAC Best Practice Guides](https://automotiveisac.com/best-practice-guides)
* [Automotive ISAC Member Vulnerability Disclosure Programs](https://automotiveisac.com/member-vdp-1)
* [UN R155 Cyber Security Management System and UN R156 Software Update Management System (UNECE WP.29; via VCA UK)](https://www.vehicle-certification-agency.gov.uk/connected-and-automated-vehicles/cyber-security-and-software-updating/)

### B.6 Vendor product patterns (illustrative; not endorsements)

* [Geotab platform overview (5M+ vehicle subscriptions across ~100k customers; 100B data points/day)](https://www.geotab.com/products/platform-overview/)
* [Samsara Fleet Telematics (80B+ miles annually; 120B+ API calls)](https://www.samsara.com/products/telematics)
* [Ford Pro Telematics](https://www.fordpro.com/en-us/telematics/)
* [Motive AI Dashcam Plus](https://gomotive.com/products/dashcam/)
* [Lytx DriveCam and Surfsight (machine-vision dashcams; 600k+ drivers)](https://www.lytx.com/)
* [Detroit Connect Virtual Technician (monitors 150 DT12 fault codes)](https://www.demanddetroit.com/connect)
* [Cambridge Mobile Telematics (powers Progressive Accident Response among other carrier programs)](https://www.cmtelematics.com/)
