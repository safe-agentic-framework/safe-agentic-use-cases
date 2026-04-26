# Mobile fleet-maintenance dispatch & scheduling assistant

> **SAFE‑AUCA industry reference guide (draft)**
>
> This use case describes the workflow at the heart of commercial-vehicle and heavy-duty fleet operations: AI-assisted dispatch and scheduling of mobile mechanics for fleet maintenance, integrated with telematics signals, parts supply chain, regulatory-compliance overlays, and recall-discovery pipelines. It is the **first SAFE-AUCA use case in NAICS 81 (Other Services, except Public Administration)** and adjacent to SAFE-UC-0006 (fleet telematics, the upstream observation layer) and SAFE-UC-0008 (OTA software updates, the downstream remediation layer). Together, the three trace a complete cyber-physical lifecycle: telematics observes, maintenance discovers and dispatches, OTA remediates.
>
> The defining characteristic of this workflow is that **the AI's dispatch decision determines who works on the brake system of a Class 8 truck operating at highway speeds.** Wrong mechanic, wrong skill, wrong part, wrong wage class is a regulatory event and often a safety event. The Federal Motor Carrier Safety Administration's Large Truck Crash Causation Study found that a truck with brake problems was 170 percent more likely to be coded with the critical reason for a crash than a truck without brake problems, and more than one-third of the 407 trucks inspected by the Michigan Field Accident Causation Team had maintenance defects that would have placed them out-of-service.
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
| **SAFE Use Case ID** | `SAFE-UC-0007`                                                     |
| **Status**           | `draft`                                                            |
| **Maturity**         | draft                                                              |
| **NAICS 2022**       | `81` (Other Services, except Public Administration)                |
| **Last updated**     | `2026-04-25`                                                       |

### Evidence (public links)

* [49 CFR Part 396 Inspection, Repair, and Maintenance (FMCSA; the operative regulation; cite Appendix A as redesignated 14 October 2021, NOT Appendix G)](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-III/subchapter-B/part-396)
* [FMCSA Inspection, Repair, and Maintenance + Driver-Vehicle Inspection Report (DVIR) hub (3-month DVIR retention per §396.11(c)(2))](https://www.fmcsa.dot.gov/regulations/inspection-repair-and-maintenance-driver-vehicle-inspection-report-dvir)
* [FMCSA Large Truck Crash Causation Study Analysis Brief (170 percent relative risk on brake-issue trucks; one-third Michigan FACT post-crash inspection OOS)](https://www.fmcsa.dot.gov/safety/research-and-analysis/large-truck-crash-causation-study-analysis-brief)
* [EPA National Enforcement and Compliance Initiative: Stopping Aftermarket Defeat Devices (172 civil enforcement cases, $55.5 million in civil penalties, FY2020 through FY2023)](https://www.epa.gov/enforcement/national-enforcement-and-compliance-initiative-stopping-aftermarket-defeat-devices)
* [EPA Air Enforcement Division study underlying the NECI: more than 570,000 tons excess NOx and 5,000 tons excess PM from tampered diesel pickups, after 2009 and before 2020](https://www.epa.gov/enforcement/national-enforcement-and-compliance-initiative-stopping-aftermarket-defeat-devices)
* [EPA Power Performance Enterprises and Kory Blaine Willis Clean Air Act Settlement ($3.1 million combined criminal fines and civil penalties; 59,135 electronic tunes or tuning devices manufactured 2013-2018)](https://www.epa.gov/enforcement/power-performance-enterprises-inc-and-kory-blaine-willis-clean-air-act-settlement)
* [EPA Aftermarket Defeat Devices and Tampering Enforcement Alert (December 2020; civil penalties of $48,192 per violative vehicle or engine for manufacturers and dealers, $4,819 per violative vehicle or engine for any other person, effective 13 January 2020)](https://www.epa.gov/sites/default/files/2020-12/documents/tamperinganddefeatdevices-enfalert.pdf)
* [NHTSA Consumer Alert on Substandard Replacement Air Bags (2024; at least 3 people killed and 2 suffered life-altering disfiguring injuries; CBP seized more than 211,000 counterfeit automotive parts in fiscal year 2024 including 490 counterfeit airbags, more than 10 times FY2023)](https://www.nhtsa.gov/press-releases/consumer-alert-nhtsa-alerts-used-car-owners-buyers-dangerous-substandard-replacement)
* [The Record: KNP Logistics insolvency after Akira ransomware (September 2023; 158-year-old UK transport firm collapsed; 730 redundancies; access via brute-forced employee password with no MFA)](https://therecord.media/knp-logistics-ransomware-insolvency-uk)
* [Cybersecurity Dive: Estes Express LockBit ransomware (October 2023; 21,184 individuals notified; class action filed)](https://www.cybersecuritydive.com/news/estes-express-lines-cyberattack/695614/)
* [Decisiv Surpasses 25 Million Service Event Milestone on its SRM Platform (November 2022; more than 5,000 service-provider locations, over 74,000 fleet owners and managers, more than seven million assets)](https://www.decisiv.com/decisiv-surpasses-25-million-service-event-milestone/)
* [ATRI An Analysis of the Operational Costs of Trucking 2025 Update (average cost of operating a truck in 2024 was $2.260 per mile; non-fuel marginal cost $1.779 per mile, the highest non-fuel operating cost ever recorded by ATRI)](https://truckingresearch.org/2025/07/an-analysis-of-the-operational-costs-of-trucking-2025-update/)
* [TMC of ATA Recommended Practices (the de facto industry standard for heavy-duty maintenance practices; 70-year history; more than 400 recommended practices)](https://tmc.trucking.org/TMC-Recommended-Practices)
* [U.S. Treasury Releases Two New Resources to Guide AI Use in the Financial Sector (19 February 2026; the Financial Services AI Risk Management Framework with 230 control objectives)](https://home.treasury.gov/news/press-releases/sb0401)

---

## Minimum viable write-up (Seed → Draft fast path)

This document covers:

* Executive summary
* Industry context and constraints
* Workflow and scope
* Architecture (tools, trust boundaries, inputs)
* Operating modes
* Kill-chain table (8 stages)
* SAFE‑MCP mapping table (18 techniques)
* Contributors and Version History

---

## 1. Executive summary (what + why)

**What this workflow does.**
A **mobile fleet-maintenance dispatch and scheduling assistant** is an AI-assisted system used by motor carriers, fleet-management organizations, OEM dealer networks, and independent service providers to receive maintenance work orders, classify priority, select the right mobile mechanic from a pool, route the mechanic to the vehicle (or route the vehicle to a shop), coordinate parts-ETA from suppliers, enforce SLA constraints, and integrate with regulatory compliance overlays. Typical capabilities include:

* ingest of telematics signals from SAFE-UC-0006 (vehicle-health fault codes, predictive-maintenance recommendations, ELD HOS exceptions, harsh-event detections)
* work-order classification by priority, skill level, certification requirement, and geographic constraint
* mobile-mechanic selection from a pool with skill, ASE certification, DOT 49 CFR Part 382 safety-sensitive eligibility, and SLA constraints
* routing optimization (mechanic-to-vehicle versus vehicle-to-shop)
* parts-ETA coordination across OEM, aftermarket, gray-market, and shop-inventory channels
* DOT driver-vehicle-inspection-report (DVIR) integration per 49 CFR §396.11
* warranty and recall integration with OEMs (defect-pattern discovery during maintenance routes into the NHTSA 49 CFR Part 573 reporting pipeline)
* compliance overlays: DOL Wage and Hour Division (Davis-Bacon and Service Contract Act for federal-contract field service), OSHA 29 CFR Part 1904 recordable-injury reporting, FMCSA 49 CFR §396 Inspection, Repair, and Maintenance, EPA Clean Air Act §203(a)(3) anti-tampering provisions

Industry deployments span the **heavy-duty Service Relationship Management (SRM) ecosystem** anchored by Decisiv (which surpassed 25 million service events on its SRM platform in November 2022 across more than 5,000 service-provider locations, more than 74,000 fleet owners and managers, and more than seven million assets), bundled with new Volvo and Mack trucks as ASIST and with Peterbilt and Kenworth as PACCAR Solutions, and integrated with Daimler Truck and Cummins. Adjacent platforms include Cetaris, Trimble TMT (formerly TMW Systems, managing more than one million assets), Karmak Fusion (4,000+ rooftops), Procede Excede, Mitchell 1 TruckSeries, Fullbay, Whip Around (digital DVIR), Fleetio (with a Maintenance Shop Network connecting fleets to national, independent, and mobile service providers), Samsara Connected Maintenance, JJ Keller Encompass (compliance overlay), and Penske's Dynamic PM (data-driven preventive maintenance using remote diagnostics, fault codes, and repair history with 24/7 roadside and a "back on road within 2 hours" target). Field-service AI dispatch in adjacent residential domains (HVAC, plumbing, electrical) is anchored by ServiceTitan Dispatch Pro and FieldEdge.

**Why it matters (business value).**
The American Transportation Research Institute reported in its 2025 Update that the average cost of operating a truck in 2024 was $2.260 per mile, with non-fuel marginal cost rising 3.6 percent to $1.779 per mile (the highest non-fuel operating cost ever recorded by ATRI). Class 8 truck downtime is commonly cited at roughly $1,000 per day per vehicle in lost revenue. AI-assisted dispatch shortens the mean time from telematics-detected fault to mechanic-on-vehicle, raises mechanic utilization, improves first-time-fix rates, and enables predictive maintenance to substitute for reactive roadside response. The TMC of ATA Recommended Practices (more than 400 RPs across a 70-year history) provide the labor-time and procedural baselines that AI scheduling typically aligns to.

**Why it's risky / what can go wrong.**
This workflow's defining trait is that **the AI's dispatch decision is a cyber-physical event by proxy**: the AI selects which human performs which physical action on which vehicle, and the resulting work either keeps a Class 8 truck safe to operate at highway speeds or it does not. The FMCSA Large Truck Crash Causation Study found that a truck with brake problems was 170 percent more likely to be coded with the critical reason for a crash than a truck without brake problems, and more than one-third of the 407 trucks inspected by the Michigan Field Accident Causation Team had maintenance defects that would have placed them out-of-service. Brake problems were associated factors in approximately 29 percent of the LTCCS dataset.

Five concurrent risk surfaces define this workflow as of 2026, and none of them resolve cleanly:

* **Cyber-physical-via-mechanic-action.** A wrong mechanic, wrong skill, wrong torque specification, or wrong part is a roadside or in-traffic safety event. Unlike SAFE-UC-0008 OTA software updates, where the wrong artifact ships to many vehicles in software, here the wrong artifact ships in the form of a human action on a single vehicle.
* **Parts-supply-chain trust boundary** straddling OEM, aftermarket, gray-market, and counterfeit. The EPA's National Enforcement and Compliance Initiative on aftermarket defeat devices finalized 172 civil enforcement cases with $55.5 million in civil penalties between FY2020 and FY2023; a separate EPA Air Enforcement Division study calculated more than 570,000 tons of excess NOx and 5,000 tons of excess particulate matter from tampered diesel pickups operating after 2009 and before 2020. The EPA Power Performance Enterprises settlement assessed $3.1 million in combined criminal fines and civil penalties for 59,135 electronic tunes or tuning devices manufactured between 2013 and 2018. NHTSA reported in its 2024 Consumer Alert on Substandard Replacement Air Bags that at least three people were killed and two suffered life-altering disfiguring injuries from counterfeit aftermarket airbag inflators; CBP seized more than 211,000 counterfeit automotive parts in fiscal year 2024, including more than 490 counterfeit airbags, more than 10 times the FY2023 count. AI parts-ETA optimization that selects gray-market or counterfeit parts can void warranty, trigger emissions-tampering enforcement under Clean Air Act §203(a)(3), and surface as a roadside fatality.
* **Prevailing-wage-compliance as an AI cost-optimization decision.** Federal-contract field-service work falls under the DOL Davis-Bacon Act (40 USC Chapter 31; covered contracts in excess of $2,000) or the McNamara-O'Hara Service Contract Act (41 USC Chapter 67; covered contracts in excess of $2,500). AI cost-optimization that routes federal-contract work to lower-wage non-prevailing-wage mechanics is a wage-and-hour violation; debarment is up to 3 years.
* **OSHA recordable-injury routing.** Field-service workers in NAICS 8113 (Commercial and Industrial Machinery and Equipment Repair and Maintenance) face roadside, lifting, electrical, and HazCom risks higher than typical manufacturing. The AI's routing decision is an OSHA 29 CFR Part 1904 recordable-injury determinant: dispatching a mechanic to a high-risk environment without proper PPE or safety briefing can be a recordable event.
* **Cyberattack on the dispatch system as existential business risk.** Estes Express experienced a LockBit ransomware attack in October 2023 affecting 21,184 individuals and triggering class action; the carrier still managed to move customers' freight. KNP Logistics, a 158-year-old UK transport firm, did not survive: Akira ransomware accessed its systems via a brute-forced employee password with no multi-factor authentication, and the firm collapsed into insolvency in September 2023 with 730 redundancies. The dispatch system is the operational nervous system of the carrier; loss of it is loss of the business.

A defining inversion versus SAFE-UC-0006 fleet telematics is **the AI is now in the action loop, not just the observation loop.** SAFE-UC-0006 reads from millions of vehicles. SAFE-UC-0007 dispatches humans to perform physical actions on those vehicles. The privacy-versus-safety tension of 0006 becomes the wage-versus-safety-versus-emissions tension of 0007.

---

## 2. Industry context & constraints (reference-guide lens)

### Where this shows up

Common in:

* heavy-duty truck OEM dealer networks (Volvo Trucks, Mack, Peterbilt, Kenworth, Daimler Truck, Navistar International, Hino, Isuzu)
* truckload, less-than-truckload, and last-mile carriers running mobile-mechanic and shop-network dispatch
* third-party logistics providers, fleet-leasing operators (Penske, Ryder, Element), and rental fleets
* OEM-Decisiv-integrated programs (Volvo ASIST, PACCAR Solutions, Daimler Truck, Cummins)
* aftermarket fleet-maintenance platforms (Cetaris, Trimble TMT, Karmak Fusion, Procede Excede, Mitchell 1 TruckSeries)
* digital-DVIR-and-shop-management vendors (Whip Around, Fleetio, Fullbay, Samsara Connected Maintenance)
* mobile-mechanic networks (independent operators, OEM-authorized service vans, roadside-assistance integrations through OEM and TSP partners)
* federal-contract motor pools (DoD, GSA, USPS, state DOT) where Davis-Bacon, Service Contract Act, and prevailing-wage rules apply
* compliance-overlay vendors (JJ Keller Encompass, ATBS, ProDriver, BSI EHS)
* adjacent residential field-service AI (ServiceTitan Dispatch Pro, FieldEdge, Workiz, Housecall Pro) where the dispatch-pattern shape is similar

### Typical systems

* **work-intake side:** telematics signals from SAFE-UC-0006 (vehicle-health fault codes, ELD HOS exceptions); driver-side DVIR submissions; roadside-assistance triggers; OEM-warranty-bulletin pushes; recall notifications; routine PM scheduling
* **dispatch-and-scheduling side:** Decisiv SRM, Cetaris, Trimble TMT, Karmak Fusion, Procede Excede, ServiceTitan Dispatch Pro
* **shop-management side:** Mitchell 1 ProDemand, AllData, Fullbay, Procede, Karmak
* **mechanic-side (mobile):** mobile dispatch app, OBD-II / J1939 diagnostic tools (per SAE J3138_202210), parts-lookup, work-order entry, photo evidence capture
* **parts-supply-chain side:** OEM warranty parts portals, aftermarket distributors (FleetPride, Rush Truck Centers, TravelCenters of America TruckPro), gray-market and online channels, shop-inventory ERP
* **regulatory-facing side:** FMCSA DVIR retention, NHTSA Part 573 recall reporting, EPA emissions records, OSHA 29 CFR Part 1904 recordable-injury logs, DOL certified payroll for federal-contract work
* **AI/ML:** LLM dispatcher copilot for work-order narrative summarization, classifier for priority and skill matching, routing optimizer, AI parts-ETA prediction, AI-assisted DVIR triage and recall-pattern discovery
* **payment-and-finance side:** fleet cards (Comdata, EFS, WEX), warranty claim payments, factoring, parts-billing, PCI DSS 4.0.1 scope

### Constraints that matter

* **49 CFR §396 (FMCSA Inspection, Repair, and Maintenance).** §396.3 systematic inspection, repair, and maintenance program; §396.7 unsafe operations forbidden; §396.11 driver-vehicle inspection report; §396.13 driver inspection (pre-trip, post-trip); §396.17 periodic inspection; §396.19 inspector qualifications; §396.21 periodic inspection record; **Appendix A** (redesignated from Appendix G on 14 October 2021) Minimum Periodic Inspection Standards.
* **49 CFR Part 393 Parts and Accessories.** Brakes, lamps, fuel systems, coupling, frame, steering, and other safety-equipage minimums; touches counterfeit-parts substitution.
* **49 CFR Part 382 DOT Drug and Alcohol Testing.** Pre-employment, random, reasonable-suspicion, post-accident, return-to-duty, follow-up testing for safety-sensitive transportation employees. Mobile mechanics performing safety-sensitive functions (such as road-testing a CMV) commonly fall under Part 382.
* **49 CFR Part 573 NHTSA Defect and Noncompliance Reporting.** Maintenance is a discovery channel for recall-relevant defects; the AI's pattern-mining across work orders surfaces §573.6 "defect related to motor vehicle safety" signals.
* **EPA Clean Air Act §203(a)(3) tampering and defeat-device prohibitions.** Civil penalties of $48,192 per violative vehicle or engine for manufacturers and dealers, $4,819 per violative vehicle or engine for any other person, effective 13 January 2020. AI parts-ETA optimization that selects DEF-bypass tunes, defeat devices, or tampering parts is an enforcement target.
* **OSHA 29 CFR Part 1904.** Fatalities reported within 8 hours; amputations, eye-loss, and inpatient hospitalizations within 24 hours; 5-year record retention. The AI's routing decision is part of the recordable-injury chain.
* **OSHA 29 CFR Part 1910 General Industry Standards.** HazCom, PPE, lockout/tagout, hand and portable tools, electrical, machine guarding (commonly cited for field-service workplaces).
* **DOL Davis-Bacon Act (40 USC Chapter 31).** Prevailing-wage requirement on federal construction and repair contracts in excess of $2,000; weekly certified payroll; debarment up to 3 years.
* **DOL Service Contract Act (McNamara-O'Hara, 41 USC Chapter 67).** Prevailing wages plus health and welfare benefits on covered federal service contracts in excess of $2,500.
* **TMC of ATA Recommended Practices.** The de facto industry vocabulary for heavy-duty maintenance (more than 400 RPs, 70-year history). AI dispatch commonly aligns labor-time and task templates to TMC RPs.
* **ASE certification.** The de facto mechanic-skill credential. AI assignment that matches job complexity to ASE specialty (e.g., T-series Medium and Heavy Truck) is a common feature.
* **State contractor and auto-repair licensing.** Wide variance by state (California BAR, Maryland Certificate of Registration, Michigan motor-vehicle service certification, EPA §609 for MVAC). AI assignment crossing state lines respects each state's licensure.
* **NHTSA Cybersecurity Best Practices for the Safety of Modern Vehicles (September 2022).** When the dispatch assistant integrates with diagnostic tools or telematics that write back to vehicles, the 45 general plus 23 technical best practices apply.
* **SAE J3138_202210 Diagnostic Link Connector Security (October 2022).** When the field mechanic plugs into OBD-II or J1939 with a tool the assistant orchestrates, J3138 sets the expectation for safe vehicle behavior under tool or upstream-channel compromise.
* **U.S. Treasury Financial Services AI RMF (19 February 2026; 230 control objectives).** Applies to fleet-finance and warranty-payment integration when the operator is a regulated financial institution.
* **PCI DSS 4.0.1.** For roadside parts billing, mobile card-on-file warranty co-pays, and fleet-card integration.

### Must-not-fail outcomes

* dispatching a mechanic without the correct ASE specialty, OEM training, or state license to perform a safety-critical repair on a Class 8 truck or other heavy vehicle
* selecting a counterfeit, gray-market, or defeat-device part that creates an EPA tampering violation, voids OEM warranty, or surfaces as a NHTSA recall trigger
* routing federal-contract field-service work to lower-wage mechanics in violation of Davis-Bacon or Service Contract Act prevailing-wage rules
* dispatching a mechanic to a high-risk environment without proper PPE, safety briefing, or HazCom controls (an OSHA 29 CFR Part 1904 recordable event)
* dispatching a non-Part 382-compliant mechanic to a safety-sensitive function
* missing a 49 CFR §573.6 defect-determination signal during maintenance discovery
* permitting tenant isolation to fail across a multi-tenant TMS or SRM platform
* losing the dispatch system to ransomware in a way that collapses the carrier (the KNP Logistics shape)

---

## 3. Workflow description & scope

### 3.1 Workflow steps (happy path)

1. A maintenance need arises. Common triggers: telematics fault codes from SAFE-UC-0006, driver-side DVIR submission, roadside breakdown, OEM warranty bulletin, recall notification, or routine PM scheduling.
2. The AI classifies the work order: priority, required skill level, ASE specialty, OEM training, geographic and SLA constraints, parts requirements, and applicable regulatory overlays.
3. The AI selects the right mobile mechanic from the pool. Constraints include skill match, ASE certification, DOT 49 CFR Part 382 eligibility for safety-sensitive functions, state licensure, prevailing-wage class for federal contracts, current schedule, and proximity.
4. The AI chooses a routing strategy: mechanic-to-vehicle (mobile service), vehicle-to-shop, or vehicle-to-OEM-dealer (warranty work). It coordinates parts-ETA from OEM, aftermarket distributor, gray-market, or shop-inventory channels.
5. The dispatcher reviews and approves (HITL) or the system auto-dispatches under a narrow allow-list (bounded autonomy).
6. The mechanic receives the dispatch, performs pre-trip safety checks, and begins work. The AI provides task-specific repair information from Mitchell 1 TruckSeries, AllData, or OEM service literature; aligns labor time to TMC RP baselines.
7. The mechanic captures DVIR (per 49 CFR §396.11), photo evidence, parts used, and labor hours. The AI assists in DVIR completion and recall-pattern discovery.
8. Post-completion, the AI updates the warranty claim, files any required NHTSA Part 573 trigger to the OEM workflow, updates OSHA Part 1904 records if a recordable injury occurred, and submits Davis-Bacon or SCA certified payroll for federal-contract work.
9. Telematics resumes normal operation; the maintenance event closes; data flows to the fleet-cost analytics layer and (where regulated) to the OEM, NHTSA, FMCSA, EPA, OSHA, or DOL reporting pipelines.

### 3.2 In scope / out of scope

* **In scope:** AI-assisted work-order classification; mobile-mechanic selection with skill, certification, and SLA constraints; routing optimization; parts-ETA coordination across channels; DVIR integration per 49 CFR §396.11; recall-pattern discovery and routing into the NHTSA Part 573 pipeline; LLM dispatcher copilot for work-order narrative; integration with TMS, SRM, ELD, and TSP platforms; compliance overlays (FMCSA, NHTSA, OSHA, DOL, EPA, DOT).
* **Out of scope:** OTA software updates to vehicles (handled in SAFE-UC-0008); fully autonomous dispatch of safety-critical field-service work without HITL approval; AI-only mechanic firing or hiring decisions (employment-related decisions affecting workers' rights are EU AI Act Annex III §4 high-risk territory and are commonly kept HITL); selection of counterfeit, gray-market, or defeat-device parts without a documented exception path; routing of federal-contract field-service work without prevailing-wage class verification.

### 3.3 Assumptions

* The carrier or service provider operates a TMS or SRM with per-tenant scoping, regulated-record retention (49 CFR §396 DVIR retention is at least 3 months), and named-human accountability for any decision with safety-of-life or wage-and-hour effect.
* Mobile-mechanic identity, ASE certification, DOT 49 CFR Part 382 eligibility, and state licensure are validated before dispatch.
* Parts authenticity is verified through OEM channels for safety-critical parts; gray-market or aftermarket parts pass a documented authenticity check before dispatch.
* The diagnostic tool the mechanic uses complies with SAE J3138_202210 expectations on the diagnostic-link connector.
* Federal-contract work has prevailing-wage class verification before dispatch.

### 3.4 Success criteria

* Every dispatch is to a mechanic with the correct ASE specialty, OEM training, state license, and DOT Part 382 status for the work.
* Every parts selection is auditable to an authentic OEM or authorized-aftermarket channel.
* Every federal-contract dispatch is wage-class verified.
* Every safety-critical environment is OSHA 29 CFR Part 1904-aware and PPE-briefed.
* Every defect-pattern discovery routes to the OEM NHTSA Part 573 pipeline within the 5-business-day window.
* Tenant isolation holds across the multi-tenant TMS or SRM platform.
* The dispatch system is recoverable from ransomware within a documented RTO.

---

## 4. System & agent architecture

### 4.1 Actors and systems

* **Human roles:** dispatcher; mobile mechanic; shop foreman; parts manager; OEM warranty manager; OEM dealer; recall coordinator; safety officer; OSHA recordable-injury coordinator; DOL certified-payroll administrator; fleet manager (customer); driver (customer-side).
* **Agent / orchestrator:** the LLM dispatcher copilot; the work-order classifier; the mechanic-selection ML model; the routing optimizer; the AI parts-ETA predictor; the AI DVIR-triage assistant; the recall-pattern-discovery model.
* **LLM runtime:** typically hosted foundation model behind the dispatcher console, often with retrieval over the SRM / TMS prior-work-order corpus and over Mitchell 1 / AllData repair information.
* **Tools (MCP servers / APIs / connectors):** Decisiv SRM connector; Cetaris connector; Trimble TMT connector; Karmak Fusion connector; OEM warranty portal connectors (Volvo, PACCAR, Daimler Truck, Cummins, Navistar); parts-supply connectors (FleetPride, Rush Truck Centers, OEM dealers); aftermarket distributors; ELD interface; dashcam media service; NHTSA Part 573 filing connector; OSHA 29 CFR Part 1904 recordable-injury connector; DOL certified-payroll connector; SAE J3138-compliant diagnostic-tool integration.
* **Data stores:** per-tenant work-order records; mechanic identity and credential store; DVIR retention store (3-month FMCSA minimum); OSHA injury log (5-year retention); DOL certified-payroll archive; parts-authenticity audit log; recall-pattern detection store; LLM dispatcher corpus.
* **Downstream systems affected:** the vehicle (cyber-physical via mechanic action); the carrier's safety record (FMCSA Vehicle Maintenance BASIC scoring); the OEM's recall pipeline; the federal contract's wage-and-hour record; the OSHA injury record; the EPA emissions-compliance record.

### 4.2 Trusted vs untrusted inputs (the identity quintet)

A defining feature of this workflow is a five-party identity model with regulators on the periphery: dispatcher / mobile mechanic / shop / parts supplier / OEM / customer (fleet owner), with FMCSA, NHTSA, OSHA, DOL, EPA, and DOT as supervisors. Each party has different rights, threat postures, and compliance obligations.

| Input / source                                       | Trusted?              | Why                                                                        | Typical failure / abuse pattern                                                                  | Mitigation theme                                                                |
| ---------------------------------------------------- | --------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| Telematics signals from SAFE-UC-0006                 | Semi-trusted          | originates inside the OEM or TSP trust perimeter; vehicles can be compromised | telemetry poisoning; fabricated fault codes for warranty fraud                                  | crypto-signed telemetry where supported; multi-source corroboration             |
| Driver-side DVIR submission                          | Untrusted             | driver may falsify or be coached by AI                                      | falsified DVIR; AI-fabricated defect descriptions; missing recordable items                       | photo evidence requirement; recordable-item enumeration; named-human review     |
| Mobile-mechanic credential and identity              | Authoritative-but-tamperable | issued by ASE, OEM, state DMV / contractor board, DOT                  | counterfeit credential; expired certification; revoked DOT Part 382 status                        | continuous credential validation; named-human exceptions; periodic audit         |
| Parts-supply-chain output (OEM, aftermarket, gray)   | Counterparty-untrusted | counterparty has commercial incentive; counterfeit market is documented   | counterfeit airbags (NHTSA 2024 alert); defeat-device tunes (EPA NECI); gray-market parts        | OEM-channel-only for safety-critical parts; authenticity check; named-human exception |
| LLM dispatcher copilot output                        | Untrusted-by-construction | probabilistic; can hallucinate                                          | hallucinated repair specification; fabricated TMC RP labor time; invented OEM bulletin            | grounded retrieval; verbatim-source citation; named-human review on regulated text |
| Cross-tenant TMS / SRM data                          | Tenant-scoped         | shared multi-tenant SaaS                                                    | cross-fleet bleed; rug-pull after platform M&A                                                   | per-tenant scoping; differential-query bleed detection; vendor M&A due diligence  |
| Federal-contract wage-class data                     | Authoritative         | DOL Wage Determinations Online                                              | misclassification of work as non-prevailing-wage when it is                                       | wage-class verification gate; named-human approval for federal-contract dispatch  |
| OSHA-recordable-environment classification           | Internally-trusted    | carrier's own safety classifications                                        | misclassified hazard environment; missed PPE requirement                                          | safety-officer review; recordable-event audit; PPE-briefing acknowledgment       |
| OEM recall and warranty bulletin feeds               | Authoritative         | OEM-originated                                                              | phishing masquerading as OEM contact; spoofed bulletin                                           | out-of-band authentication; established channels                                  |
| Diagnostic-tool output (OBD-II, J1939, J3138-compliant) | Semi-trusted        | diagnostic tool can be compromised; bus injection from compromised dongle | tool-poisoning; CAN signal injection; J3138 violation                                            | SAE J3138 alignment; signed tool firmware; bus monitoring                        |
| Public threat-intel and Auto-ISAC disclosures        | Semi-trusted          | useful but mixed quality                                                    | feed poisoning                                                                                    | provenance weighting; cross-reference                                            |

### 4.3 Trust boundaries (required)

* **Driver to AI:** driver-side DVIR is untrusted free text; the AI must treat as data, not instruction.
* **Mechanic to dispatch:** the mechanic's credential must be continuously valid; an expired or revoked credential closes the dispatch path.
* **Parts supplier to dispatch:** safety-critical parts must come from an OEM or authorized-aftermarket channel; gray-market substitution requires named-human exception.
* **Dispatch to vehicle:** the mechanic action that follows the dispatch is the cyber-physical event; tenant isolation must hold across the multi-tenant SRM platform; one customer's vehicle records must not bleed into another's.
* **AI to regulator:** any AI-drafted regulatory text (NHTSA Part 573, DOL certified payroll, OSHA recordable injury) must surface verbatim from authoritative source and route through named-human approval before submission.
* **Mobile-mechanic identity verification:** the AI must not dispatch a mechanic whose DOT 49 CFR Part 382 status, ASE certification, OEM training, or state license is invalid.

### 4.4 Permission and approval design

* **Dispatch to safety-critical work** (brake, steering, fuel, ADAS, HV battery, emissions-control system) requires mechanic credential validation, ASE specialty match, and OEM training match before the dispatch is sent.
* **Federal-contract dispatch** requires Davis-Bacon or Service Contract Act prevailing-wage class verification before the dispatch is sent.
* **Parts selection for safety-critical systems** is OEM-channel-only by default; gray-market or aftermarket selection requires named-human exception with documented authenticity verification.
* **DVIR posting** to the regulated record is named-human attributed.
* **NHTSA Part 573 defect signals** route through the OEM warranty workflow with named-human approval before any external filing.
* **OSHA Part 1904 recordable-injury** posting is safety-officer attributed.
* **DOL certified payroll** for federal-contract work is administrator attributed.

### 4.5 Tool inventory (required)

| Tool / connector                                          | Read / Write | Scope                                            | Risk class                                                                       |
| --------------------------------------------------------- | ------------ | ------------------------------------------------ | -------------------------------------------------------------------------------- |
| Telematics ingest from SAFE-UC-0006                       | Read         | Per-tenant, per-VIN                              | Privacy-sensitive, cyber-physical-adjacent                                        |
| LLM dispatcher copilot                                    | Read + Write | Tenant-scoped                                    | Indirect prompt-injection surface; hallucination surface for regulated text       |
| Mechanic-selection ML model                               | Read         | Per-tenant, per-mechanic                         | Discrimination-sensitive; ECOA / Reg B fair-lending analog for federal contracts |
| Routing optimizer                                         | Read         | Per-tenant                                       | Cost-optimization that can violate Davis-Bacon / SCA                              |
| Parts-ETA predictor                                       | Read + Write | Per-tenant, per-channel                          | Counterfeit-substitution surface; EPA tampering surface                           |
| Decisiv SRM connector                                     | Read + Write | Per-tenant                                       | Multi-tenant isolation-critical                                                   |
| OEM warranty portal connectors                            | Read + Write | Per-OEM                                          | Authoritative regulator-adjacent                                                  |
| ELD interface                                             | Read         | Per-driver, per-tenant                           | Regulated record (49 CFR Part 395)                                                |
| OBD-II / J1939 diagnostic-tool integration                | Read + Write | Per-vehicle                                      | SAE J3138 alignment-critical                                                      |
| DVIR posting                                              | Write        | Per-vehicle, per-driver                          | Regulated record (49 CFR §396.11)                                                 |
| NHTSA Part 573 filing connector                           | Write (egress) | OEM-only                                       | Regulated submission                                                              |
| OSHA 29 CFR Part 1904 recordable-injury connector         | Write (egress) | Per-employer                                   | Regulated submission                                                              |
| DOL certified-payroll connector                           | Write (egress) | Per-federal-contract                           | Regulated submission                                                              |
| Mitchell 1 / AllData repair information                   | Read         | Per-vehicle                                      | Authoritative; commonly licensed                                                  |
| TMC RP catalog                                            | Read         | Industry-wide                                    | De facto standard; non-regulated but load-bearing                                 |

---

## 5. Operating modes

### 5.1 Manual (read-only assistance)

The AI summarizes work orders, recommends mechanics, and proposes routes. The dispatcher decides every action.

**Risk profile:** bounded by dispatcher capacity. Privacy and SLA risk dominate over cyber-physical risk because the dispatcher provides the safety net.

### 5.2 HITL per-action (the common pattern for safety-critical work)

The AI proposes specific actions (mechanic selection, routing, parts choice, DVIR text, NHTSA Part 573 trigger) and a named human approves each before execution. Common at large carriers and OEM dealer networks.

**Risk profile:** moderate. UI discipline and resistance to consent-fatigue determine quality. Long dispatcher queues during weather events or recall surges are a known T1403 surface.

### 5.3 Autonomous on a narrow allow-list (bounded autonomy)

A pre-declared allow-list runs without per-action approval: routine PM scheduling, low-priority non-safety-critical reminder messages, parts-stocking optimization. Anything touching safety-critical work, federal-contract wage class, parts authenticity, or regulator submission stays HITL or manual.

**Risk profile:** depends on allow-list discipline. Incentive pressure to expand the allow-list during driver-shortage or downtime-cost surges is the central governance risk.

### 5.4 Fully autonomous with guardrails (rare)

End-to-end autonomous dispatch with post-hoc human review. Hard to defend for any path that touches safety-critical work, parts authenticity, federal-contract wages, OSHA recordable environments, or regulator submissions.

**Risk profile:** highest. Reconciling with FMCSA, NHTSA, OSHA, DOL, and EPA enforcement posture is structurally difficult.

### 5.5 Variants

Architectural variants teams reach for:

1. **OEM-dealer-only versus mobile-mechanic-network versus hybrid.** OEM-dealer-only deployments simplify warranty and parts authenticity; mobile-mechanic-network deployments scale faster but multiply trust-boundary surface.
2. **Decisiv SRM as canonical platform versus point integrations.** Decisiv's 25-million-event milestone reflects industry convergence on SRM as the standard pattern.
3. **AI-drafted plus human-edited dual-artifact model** for regulated text (NHTSA Part 573 triggers, OSHA Part 1904 records, DOL certified payroll).
4. **Independent safety monitor** that watches dispatch decisions for credential, wage-class, and parts-authenticity violations on a non-overlapping signal set.
5. **Ransomware-resilience playbook** with offline backups, tested RTO, and dispatch-system recovery rehearsal (the KNP Logistics shape).

---

## 6. Threat model overview (high-level)

### 6.1 Primary security & safety goals

* preserve mechanic-credential integrity (ASE, OEM training, DOT Part 382, state license)
* preserve parts-authenticity for safety-critical systems
* preserve Davis-Bacon and Service Contract Act prevailing-wage compliance for federal contracts
* preserve OSHA Part 1904 recordable-injury awareness
* preserve tenant isolation across multi-tenant SRM and TMS platforms
* preserve FMCSA Vehicle Maintenance BASIC scoring through accurate DVIR and §396 compliance
* preserve recoverability of the dispatch system from ransomware

### 6.2 Threat actors (who might attack or misuse)

* **Counterfeit-parts suppliers and gray-market distributors** offering counterfeit airbags, defeat devices, and tampered emissions-control parts (the EPA NECI and NHTSA 2024 Consumer Alert pattern)
* **Insiders gaming federal-contract wage class** to capture margin from Davis-Bacon or Service Contract Act work
* **Carriers gaming the FMCSA Vehicle Maintenance BASIC** through false DVIR or missed §396.17 periodic inspections
* **Ransomware actors** targeting dispatch systems (the KNP Logistics and Estes Express pattern)
* **Compromised credential issuers** (counterfeit ASE certificates, falsified state licenses)
* **Mobile-mechanic insiders** using AI-assisted retrieval to surface customer or fleet data outside their job
* **Researchers** disclosing in good faith via Auto-ISAC

### 6.3 Attack surfaces

* driver-side DVIR free text and photo uploads
* mechanic-credential issuance and validation
* parts-supply-chain channels (OEM portal, aftermarket distributor, gray-market online)
* dispatcher LLM copilot (indirect prompt injection from work-order narratives, OEM bulletins)
* multi-tenant SRM and TMS data plane
* OBD-II / J1939 diagnostic-tool channel (SAE J3138 scope)
* cyber-physical bridge: the mechanic action that follows the dispatch
* regulator-facing connectors (NHTSA Part 573, OSHA Part 1904, DOL certified payroll)
* the dispatch system itself (ransomware target)

### 6.4 High-impact failures (include industry harms)

* **Customer / consumer harm:** counterfeit airbag installed during repair (the NHTSA 2024 alert: 3 deaths, 2 disfiguring injuries); brake repair performed without proper ASE specialty leading to roadside fatality (the LTCCS 170% relative risk); cabin imagery or VIN-level data leakage from a multi-tenant TMS.
* **Business harm:** EPA tampering enforcement under Clean Air Act §203(a)(3) ($48,192 per vehicle for manufacturers and dealers, $4,819 per vehicle for any other person); NHTSA recall investigation triggered by missed Part 573 reporting; FMCSA Vehicle Maintenance BASIC scoring degradation; DOL Wage and Hour Division enforcement on Davis-Bacon or SCA violations including up to 3-year debarment; OSHA enforcement on Part 1904 violations.
* **Catastrophic operational harm:** ransomware on the dispatch system causing carrier collapse (the KNP Logistics pattern, where 158 years of operations ended with 730 redundancies after a single brute-forced password without MFA).
* **Cyber-physical harm:** counterfeit, gray-market, or defeat-device parts surfacing as a roadside fatality, EPA tampering enforcement, or NHTSA recall.

---

## 7. Kill-chain analysis (stages → likely failure modes)

> Keep this defender-friendly. Describe patterns, not "how to do it."
>
> Note: this UC uses an **eight-stage kill chain** with **5 stages flagged NOVEL** versus SAFE-UC-0006 (fleet telematics, the upstream observation layer), SAFE-UC-0008 (OTA vehicle update, the downstream remediation layer), and SAFE-UC-0021 (contact-center). NAICS 81 sits at the intersection of FMCSA, NHTSA, OSHA, DOL, EPA, and DOT regulatory regimes, and almost every operational stage of the workflow has a regulatory hard-corner that no other UC's workflow touches.

| Stage                                                                                     | What can go wrong (pattern)                                                                                                                                  | Likely impact                                                                                                            | Notes / preconditions                                                                                                                              |
| ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1. Telematics signal ingest and work-order classification                                 | Adversarial fault-code descriptions or driver-DVIR free text steer the AI's priority and skill-level classification                                          | wrong skill assigned; wrong priority queue; missed safety-critical signal                                               | every free-text channel is a vector; quote-isolation is the floor                                                                                  |
| 2. Mobile-workforce identity verification (**NOVEL: DOT Part 382 hard rule**)             | Counterfeit ASE certification; expired DOT 49 CFR Part 382 status; revoked state license; falsified OEM training credential                                  | safety-sensitive work performed by ineligible mechanic; FMCSA enforcement exposure                                       | analog-only-ish in 0006/0008 (no human-in-the-loop), direct in 0007                                                                                |
| 3. Parts-supply-chain trust boundary (**NOVEL: physical supply chain on top of SaaS**)    | AI parts-ETA optimization selects counterfeit, gray-market, or defeat-device parts; the EPA NECI and NHTSA 2024 Consumer Alert patterns                      | EPA tampering enforcement; NHTSA recall trigger; warranty void; roadside fatality                                        | UC-0008 OTA has a software supply chain; UC-0007 has a *physical-parts* supply chain on top of a SaaS supply chain; both apply                     |
| 4. Prevailing-wage-compliance as AI cost-optimization (**NOVEL: Davis-Bacon AI decision**) | AI cost-optimization routes federal-contract field-service work to lower-wage non-prevailing-wage mechanics                                                  | DOL Wage and Hour Division enforcement; debarment up to 3 years; certified-payroll falsification exposure                | no other SAFE-UC pulls Davis-Bacon into the AI decision path                                                                                       |
| 5. OSHA-safety-routing (**NOVEL: 29 CFR Part 1904 recordable-injury determinant**)        | AI routes mechanic to high-risk environment without PPE briefing or HazCom controls; missed lockout/tagout; missed electrical safety                         | OSHA Part 1904 recordable injury or fatality; 8-hour fatality reporting window; 24-hour amputation/eye-loss/hospitalization | the AI's routing decision is part of the recordable-injury chain                                                                                   |
| 6. Cyber-physical-via-mechanic-action                                                     | Wrong torque specification; wrong brake-system bleeding procedure; wrong refrigerant; wrong wire harness reconnect; the LTCCS-documented brake-failure pattern | roadside fatality; injury; vehicle damage; FMCSA Vehicle Maintenance BASIC degradation                                   | LTCCS: brake-issue trucks 170 percent more likely to be coded with the critical reason for a crash                                                 |
| 7. Recall-discovery-via-maintenance (**NOVEL: upstream of NHTSA Part 573**)               | AI fails to surface a defect pattern across maintenance work orders that should trigger 49 CFR §573.6 reporting; OEM workflow misses the 5-business-day window | NHTSA recall investigation; consent order; reputational and customer-safety harm                                          | UC-0007 is the *upstream* of the recall pipeline; UC-0008 OTA is the downstream remediation                                                       |
| 8. Ransomware on the dispatch system                                                      | Adversary encrypts the TMS or SRM; carrier loses dispatch capability; customers, partners, and regulators lose confidence                                    | partial recovery (the Estes Express shape); total business collapse (the KNP Logistics shape: 158 years to 730 redundancies) | brute-forced password without MFA was the KNP entry point; offline backup and tested RTO are the only reliable mitigations                          |

---

## 8. SAFE‑MCP mapping (kill-chain → techniques → controls → tests)

Practitioners commonly map this workflow's failure patterns to the following SAFE‑MCP techniques. The mapping is directional: teams adapt it to their stack, threat model, regulatory regime, and fleet class. **A note on framework gap:** SAFE-MCP today covers the LLM and MCP-tool surface well, but does not yet have first-class techniques for **physical parts-supply-chain authenticity** (the closest anchor is T1002 Supply Chain Compromise, which is software-oriented), **prevailing-wage AI-cost-optimization harm** (T2107 model poisoning is the closest), **OSHA recordable-injury routing as AI decision**, or **cyber-physical-via-mechanic-action** (a structurally human-mediated harm path). The mapping below cites the closest anchors and flags the gaps honestly.

| Kill-chain stage                                          | Failure / attack pattern (defender-friendly)                                                                                  | SAFE‑MCP technique(s)                                                                                                                                                                                                                            | Recommended controls (prevent / detect / recover)                                                                                                                                                                                                                                                                                                                       | Tests (how to validate)                                                                                                                                                                                                                                                                                                                                                |
| --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Telematics ingest + work-order classification             | Adversarial fault-code descriptions, DVIR free text, OEM-bulletin ingestion steer priority and skill classification           | `SAFE-T1102` (Prompt Injection (Multiple Vectors)); `SAFE-T1110` (Multimodal Prompt Injection via Images/Audio); `SAFE-T1003` (Malicious MCP-Server Distribution)                                                                                | quote-isolate every free-text channel; structured output schema; multimodal sanity checks on photo evidence; named-human review on any reclassification that crosses skill or priority tier                                                                                                                                                                            | adversarial DVIR text fixtures; multimodal-injection fixtures on damage photos; verify the LLM cannot drive a tool call from work-order free text                                                                                                                                                                                                                      |
| Mobile-workforce identity verification (**NOVEL**)        | Counterfeit ASE cert, expired DOT Part 382 status, revoked state license, falsified OEM training                              | `SAFE-T1304` (Credential Relay Chain); `SAFE-T1307` (Confused Deputy Attack); `SAFE-T1502` (File-Based Credential Harvest)                                                                                                                       | continuous credential validation against ASE, OEM, state DMV, DOT Part 382 sources; named-human exception with documented audit trail; periodic re-verification; closed-path on expired or revoked status                                                                                                                                                            | seeded-counterfeit-credential fixtures; expired-credential fixtures; verify dispatch is blocked and audit captures attempt                                                                                                                                                                                                                                              |
| Parts-supply-chain trust boundary (**NOVEL gap**)         | AI parts-ETA selects counterfeit airbag, defeat device, or gray-market emissions-control part                                 | `SAFE-T1002` (Supply Chain Compromise); `SAFE-T1407` (Server Proxy Masquerade); `SAFE-T1001` (Tool Poisoning Attack (TPA)). **Gap:** physical parts authenticity is not a SAFE-MCP technique today                                              | OEM-channel-only for safety-critical parts; documented authenticity check for gray-market or aftermarket; EPA Clean Air Act §203(a)(3) compliance gate; NHTSA counterfeit-parts watchlist integration                                                                                                                                                                  | seeded-counterfeit-parts fixtures; defeat-device-tune fixture; verify gate blocks safety-critical substitution; verify named-human exception path is auditable                                                                                                                                                                                                          |
| Prevailing-wage-compliance as AI cost-optimization (**NOVEL**) | AI cost-optimization routes federal-contract work to lower-wage mechanics in violation of Davis-Bacon or Service Contract Act | `SAFE-T2107` (AI Model Poisoning via MCP Tool Training Data Contamination); `SAFE-T1404` (Response Tampering)                                                                                                                                    | wage-class verification gate before federal-contract dispatch; named-human approval for any wage-class exception; DOL Wage Determinations Online retrieval; documented certified-payroll trail                                                                                                                                                                          | adversarial cost-optimization fixtures across federal-contract scenarios; verify wage-class gate fires; verify Davis-Bacon and SCA threshold detection                                                                                                                                                                                                                  |
| OSHA-safety-routing (**NOVEL**)                            | AI routes mechanic to high-risk environment without PPE, HazCom, or lockout/tagout; missed Part 1904 recordable-event signal | `SAFE-T1104` (Over-Privileged Tool Abuse); `SAFE-T2105` (Disinformation Output); `SAFE-T1404` (Response Tampering)                                                                                                                              | PPE-briefing acknowledgment gate; HazCom-environment classification; safety-officer review on high-risk environments; Part 1904 recordable-event detection; 8-hour fatality reporting workflow; 24-hour amputation/eye-loss/hospitalization workflow                                                                                                                  | seeded-high-risk-environment fixtures; verify PPE briefing fires; verify safety-officer review path is enforced; recordable-event detection regression                                                                                                                                                                                                                  |
| Cyber-physical-via-mechanic-action                         | Wrong torque, wrong brake-bleed procedure, wrong refrigerant, wrong wiring; the LTCCS brake-failure pattern                  | `SAFE-T1404` (Response Tampering); `SAFE-T2105` (Disinformation Output); `SAFE-T1309` (Privileged Tool Invocation via Prompt Manipulation)                                                                                                       | grounded retrieval over Mitchell 1, AllData, OEM service literature; verbatim-procedure citation; TMC RP labor-time alignment; named-human review on safety-critical procedure changes; SAE J3138-aligned diagnostic-tool integration                                                                                                                                  | adversarial procedure-text fixtures; verify hallucinated torque or procedure is flagged; OBD-II / J1939 J3138-compliance test suite                                                                                                                                                                                                                                     |
| Recall-discovery-via-maintenance (**NOVEL**)               | AI misses defect pattern across work orders; OEM workflow misses the 49 CFR §573.6 5-business-day window                     | `SAFE-T2106` (Context Memory Poisoning via Vector Store Contamination); `SAFE-T2105` (Disinformation Output); `SAFE-T1309` (Privileged Tool Invocation via Prompt Manipulation)                                                                  | per-tenant pattern-detection across maintenance corpus; cross-tenant aggregated pattern signals to the OEM warranty workflow; named-human approval before any external Part 573 filing draft; verbatim regulatory-language surfacing                                                                                                                                  | seeded-defect-pattern fixtures; verify pattern detection fires; tabletop a §573.6 timing scenario                                                                                                                                                                                                                                                                       |
| Ransomware on the dispatch system                          | Adversary encrypts TMS or SRM; carrier loses dispatch capability; KNP Logistics-shaped business collapse                     | `SAFE-T2101` (Data Destruction); `SAFE-T2102` (Service Disruption via External API Flooding); `SAFE-T1502` (File-Based Credential Harvest); `SAFE-T1503` (Env-Var Scraping)                                                                       | offline backups with tested RTO; multi-factor authentication on every privileged credential (the KNP entry point was a brute-forced password without MFA); network segmentation; incident-response playbook including offline dispatch fallback                                                                                                                       | tabletop a KNP-shape scenario against your platform; offline dispatch fallback exercise; MFA enforcement audit; backup restoration test                                                                                                                                                                                                                                  |

---

## 9. Controls & mitigations (organized)

### 9.1 Prevent (reduce likelihood)

* **Continuous mechanic-credential validation** against ASE, OEM training, state DMV, and DOT 49 CFR Part 382 sources; closed-path on expired or revoked status.
* **OEM-channel-only for safety-critical parts** by default; named-human exception with documented authenticity verification for gray-market or aftermarket.
* **Wage-class verification gate** before any federal-contract dispatch; DOL Wage Determinations Online retrieval; named-human approval for exceptions.
* **PPE-briefing acknowledgment gate** on every dispatch to a hazardous environment; safety-officer review on high-risk environments.
* **Quote-isolation** on every free-text channel into the LLM dispatcher copilot.
* **Grounded retrieval** over Mitchell 1, AllData, OEM service literature, and TMC RP catalog for any procedure or labor-time text the AI surfaces.
* **Verbatim-regulatory-language surfacing** for NHTSA Part 573 triggers, OSHA Part 1904 records, DOL certified payroll, and EPA reporting.
* **SAE J3138_202210 alignment** on every diagnostic-tool integration.
* **Multi-factor authentication on every privileged credential** in the dispatch system (the KNP Logistics entry point was a brute-forced password without MFA).
* **Tenant isolation as a hard invariant** across storage, cache, and vector store.
* **Egress allow-list** for every external regulator and OEM connector.
* **Auto-ISAC engagement** for coordinated disclosure of telematics and dispatch findings.

### 9.2 Detect (reduce time-to-detect)

* mechanic-credential drift monitoring (expirations, revocations)
* parts-channel anomaly detection (gray-market substitution rate by mechanic and by region)
* federal-contract wage-class drift detection
* PPE-briefing acknowledgment rate
* DVIR-completion-quality monitoring
* recall-pattern-detection drift across the maintenance corpus
* tenant-isolation differential queries run continuously in CI and production
* dispatch-system unauthorized access detection (the KNP entry signal)
* §573.6 filing-timer integrity (defect determination to filing latency)
* OSHA Part 1904 recordable-event detection rate

### 9.3 Recover (reduce blast radius)

* offline-dispatch fallback playbook (the KNP versus Estes Express comparison: Estes survived because they had operational resilience)
* tested RTO for the dispatch system from offline backup
* incident-response playbook for an inferred or confirmed counterfeit-parts dispatch
* incident-response playbook for an inferred or confirmed Davis-Bacon or SCA violation
* incident-response playbook for an OSHA Part 1904 recordable event
* coordinated-disclosure path through Auto-ISAC for telematics and dispatch vulnerabilities
* regulator-notification playbook per jurisdiction (FMCSA, NHTSA, OSHA, DOL, EPA, DOT, state AG) pre-mapped with countdown SLAs

---

## 10. Validation & testing plan

### 10.1 What to test (minimum set)

* **Mechanic-credential validation** holds across ASE, OEM, state, and DOT Part 382 sources.
* **Safety-critical parts** are OEM-channel-only by default; gray-market substitution requires named-human exception.
* **Federal-contract wage-class verification** fires before dispatch.
* **PPE-briefing acknowledgment** is recorded before every hazardous-environment dispatch.
* **Quote-isolation** holds on every free-text channel into the LLM.
* **Grounded retrieval** returns Mitchell 1 / AllData / OEM verbatim citations for procedures.
* **SAE J3138** alignment holds on every diagnostic-tool integration.
* **Tenant isolation** holds under adversarial cross-tenant queries.
* **MFA enforcement** holds on every privileged credential.
* **§573.6 filing-timer integrity** from defect determination to filing.
* **OSHA Part 1904 recordable-event detection** runs.

### 10.2 Test cases (make them concrete)

| Test name                                        | Setup                                                                        | Input / scenario                                                                                                  | Expected outcome                                                                                                                              | Evidence produced                                              |
| ------------------------------------------------ | ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Counterfeit ASE certificate                      | Seeded counterfeit-credential fixture                                         | Mechanic with falsified ASE T-series cert                                                                          | Dispatch blocked; audit captures attempt; named-human exception path documented                                                                | credential-validation log + dispatch-block log                  |
| Counterfeit airbag substitution                  | Seeded counterfeit-airbag part-channel fixture                                | AI proposes counterfeit-airbag part for safety-critical dispatch                                                   | OEM-channel-only gate fires; named-human exception required; audit captures attempt                                                            | parts-channel log + gate-rejection log                          |
| Davis-Bacon wage-class fixture                   | Federal-contract dispatch fixture                                             | AI cost-optimization proposes lower-wage mechanic for $5,000 federal road repair contract                          | Wage-class gate fires; DOL Wage Determinations Online retrieved; named-human approval required                                                  | wage-class verification log                                     |
| OSHA Part 1904 recordable-event detection        | Seeded high-risk-environment fixture                                          | Mechanic dispatched to roadside HazCom environment without PPE briefing                                            | PPE-briefing gate fires; safety-officer review path enforced; audit captures attempt                                                            | PPE-briefing log + safety-officer-review log                    |
| LTCCS brake-procedure adversarial fixture        | Adversarial-procedure-text fixture                                            | AI proposes wrong torque or wrong brake-bleed procedure                                                            | Grounded retrieval fires; verbatim Mitchell 1 / AllData / OEM citation surfaces; named-human review on safety-critical procedure                | grounded-retrieval log                                          |
| SAE J3138 write-disable                          | Diagnostic tool on test bench                                                 | Tool attempts CAN write to safety-critical bus                                                                     | Write blocked at gateway; J3138 alignment confirmed; alert fires                                                                              | gateway log + J3138-test log                                    |
| Cross-tenant bleed differential                  | Two synthetic tenant fleets on same SRM platform                              | Tenant A queries for VIN belonging to Tenant B                                                                     | Query rejected; differential test passes; audit captures attempt                                                                              | differential-query log                                          |
| MFA enforcement audit                            | Privileged-credential audit                                                   | Audit run across all privileged dispatch credentials                                                              | 100 percent MFA enforcement; any exception is documented and time-bounded                                                                    | MFA audit log                                                   |
| §573.6 defect-pattern detection                  | Seeded defect-pattern fixture                                                 | AI processes maintenance corpus with known defect cluster                                                          | Pattern detection fires; OEM warranty workflow notified; 5-business-day timer initialized                                                     | pattern-detection log + filing-timer log                        |
| KNP-shape ransomware tabletop                    | Offline-backup restoration test                                               | Simulated dispatch-system encryption                                                                              | Offline-dispatch fallback engages; tested RTO met; no data loss beyond declared RPO                                                            | RTO log + fallback-engagement log                                |

### 10.3 Operational monitoring (production)

* mechanic-credential expiration and revocation rates
* parts-channel anomaly rate (gray-market substitution by mechanic, by region)
* federal-contract wage-class drift detection
* PPE-briefing acknowledgment rate
* DVIR-completion-quality monitoring
* recall-pattern-detection drift
* tenant-isolation differential-query pass rate
* MFA enforcement on privileged credentials
* §573.6 filing-timer integrity
* OSHA Part 1904 recordable-event rate
* dispatch-system access anomaly detection (the KNP entry signal)
* Auto-ISAC coordinated-disclosure ingest rate

---

## 11. Open questions & TODOs

- [ ] Define the organization's safety-critical-parts list and the OEM-channel-only enforcement scope.
- [ ] Document the named-human roles (dispatcher, safety officer, BSA officer, DOL administrator, recall coordinator) and their attestation artifacts.
- [ ] Specify the credential-validation cadence and exception path for ASE, OEM, state, and DOT Part 382 sources.
- [ ] Map the federal-contract wage-class verification path against DOL Wage Determinations Online.
- [ ] Document the PPE-briefing acknowledgment gate and the high-risk-environment classifications.
- [ ] Map regulator-filing SLAs per jurisdiction (FMCSA, NHTSA, OSHA, DOL, EPA, DOT, state AG).
- [ ] Decide the recall-discovery-pattern threshold for §573.6 filing.
- [ ] Document the offline-dispatch fallback playbook and RTO target.
- [ ] Document Auto-ISAC engagement procedures for telematics and dispatch findings.

---

## 12. Questionnaire prompts (for reviewers)

### Workflow realism

* Are the integrations (Decisiv SRM, Cetaris, Trimble TMT, Karmak Fusion, OEM warranty portals, ELD, NHTSA Part 573, OSHA Part 1904, DOL certified payroll) realistic for the organization's stack and fleet class?
* Does the workflow distinguish OEM-dealer-only, mobile-mechanic-network, and hybrid deployments?
* Is the LLM dispatcher copilot scoped to summarization and grounded retrieval, or does it author regulated text?

### Trust boundaries & permissions

* Does mechanic-credential validation hold continuously?
* Are safety-critical parts OEM-channel-only by default?
* Is federal-contract wage-class verification a hard gate before dispatch?
* Does tenant isolation hold across the SRM and TMS plane?

### Output safety & persistence

* Are AI-drafted regulatory texts (NHTSA Part 573 triggers, OSHA Part 1904 records, DOL certified payroll) reviewed by a named human before send?
* Is the regulated disclosure language surfaced verbatim from authoritative sources?
* Are dual-artifact audit trails (AI draft plus human edit) preserved?

### Cyber-physical safety

* Is grounded retrieval over Mitchell 1, AllData, and OEM service literature enforced for safety-critical procedures?
* Is SAE J3138_202210 alignment evidenced on every diagnostic-tool integration?

### Cyberattack resilience

* Is MFA enforced on every privileged credential? (The KNP Logistics entry point was a brute-forced password without MFA.)
* Is there a tested offline-dispatch fallback with a documented RTO?
* Is there an offline-backup restoration test cadence?

### Regulatory-facing integrity

* Are FMCSA Vehicle Maintenance BASIC implications evidenced?
* Are 49 CFR §573.6 filing-timer integrity and named-signer attestation evidenced?
* Which controls are commonly viewed as mandatory under the organization's primary regulator (FMCSA, NHTSA, OSHA, DOL, EPA, DOT, state AG) versus recommended?

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
* [SAFE-T1304 Credential Relay Chain](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1304/README.md)
* [SAFE-T1307 Confused Deputy Attack](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1307/README.md)
* [SAFE-T1309 Privileged Tool Invocation via Prompt Manipulation](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1309/README.md)
* [SAFE-T1402 Instruction Stenography - Tool Metadata Poisoning](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1402/README.md) (the title preserves the verbatim "Stenography" typo from the SAFE-MCP source; the body uses the correct "steganography")
* [SAFE-T1403 Consent-Fatigue Exploit](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1403/README.md)
* [SAFE-T1404 Response Tampering](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1404/README.md)
* [SAFE-T1407 Server Proxy Masquerade](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1407/README.md)
* [SAFE-T1502 File-Based Credential Harvest](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1502/README.md)
* [SAFE-T1503 Env-Var Scraping](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1503/README.md)
* [SAFE-T1701 Cross-Tool Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1701/README.md)
* [SAFE-T1702 Shared-Memory Poisoning](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1702/README.md)
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
* [NIST SP 800-218A SSDF Generative AI Profile (July 2024)](https://csrc.nist.gov/pubs/sp/800/218/a/final)
* [Regulation (EU) 2024/1689 (EU AI Act; Article 50 transparency; Annex III §4 employment-related decisions)](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
* [ISO/IEC 42001:2023 Artificial Intelligence Management System](https://www.iso.org/standard/81230.html)
* [ISO/IEC 23894:2023 AI Risk Management](https://www.iso.org/standard/77304.html)
* [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)
* [OWASP Machine Learning Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)
* [MITRE ATLAS adversarial threat landscape for AI systems](https://atlas.mitre.org/)
* [U.S. Treasury Financial Services AI Risk Management Framework (19 February 2026; 230 control objectives)](https://home.treasury.gov/news/press-releases/sb0401)

### B.3 Public incidents and disclosures adjacent to this workflow

* [The Record: KNP Logistics insolvency after Akira ransomware (September 2023; 158-year-old UK transport firm; 730 redundancies; brute-forced password without MFA)](https://therecord.media/knp-logistics-ransomware-insolvency-uk)
* [Cybersecurity Dive: Estes Express Lines LockBit ransomware (October 2023; 21,184 individuals notified)](https://www.cybersecuritydive.com/news/estes-express-lines-cyberattack/695614/)
* [EPA National Enforcement and Compliance Initiative: Stopping Aftermarket Defeat Devices (172 civil enforcement cases; $55.5M civil penalties; FY2020-FY2023)](https://www.epa.gov/enforcement/national-enforcement-and-compliance-initiative-stopping-aftermarket-defeat-devices)
* [EPA Air Enforcement Division study underlying NECI (more than 570,000 tons excess NOx and 5,000 tons excess PM from tampered diesel pickups, after 2009 and before 2020)](https://www.epa.gov/enforcement/national-enforcement-and-compliance-initiative-stopping-aftermarket-defeat-devices)
* [EPA Power Performance Enterprises and Kory Blaine Willis Clean Air Act Settlement ($3.1 million combined criminal fines and civil penalties; 59,135 electronic tunes or tuning devices manufactured 2013-2018)](https://www.epa.gov/enforcement/power-performance-enterprises-inc-and-kory-blaine-willis-clean-air-act-settlement)
* [EPA Aftermarket Defeat Devices and Tampering Enforcement Alert (December 2020; $48,192 per violative vehicle for manufacturers and dealers, $4,819 per violative vehicle for any other person, effective 13 January 2020)](https://www.epa.gov/sites/default/files/2020-12/documents/tamperinganddefeatdevices-enfalert.pdf)
* [NHTSA Consumer Alert on Substandard Replacement Air Bags (2024; 3 deaths, 2 disfiguring injuries; 211,000 counterfeit auto parts seized FY2024 including 490 airbags)](https://www.nhtsa.gov/press-releases/consumer-alert-nhtsa-alerts-used-car-owners-buyers-dangerous-substandard-replacement)
* [FMCSA Large Truck Crash Causation Study Analysis Brief (170 percent relative risk on brake-issue trucks; one-third Michigan FACT post-crash inspection OOS)](https://www.fmcsa.dot.gov/safety/research-and-analysis/large-truck-crash-causation-study-analysis-brief)
* [FleetOwner: Counterfeit Parts, Buyer Beware (FTC estimate of $12 billion per year globally and $3 billion in the U.S. in lost auto-parts sales)](https://www.fleetowner.com/news/article/21658885/counterfeit-parts-buyer-beware)
* [Human Rights Watch: The Gig Trap, Algorithmic Wage and Labor Exploitation in Platform Work in the US (12 May 2025; closest disparate-impact analog for AI dispatch)](https://www.hrw.org/report/2025/05/12/the-gig-trap/algorithmic-wage-and-labor-exploitation-in-platform-work-in-the-us)

### B.4 Domain-regulatory references

* [49 CFR Part 396 Inspection, Repair, and Maintenance (Appendix A redesignated 14 October 2021)](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-III/subchapter-B/part-396)
* [FMCSA Inspection, Repair, and Maintenance + Driver Vehicle Inspection Report (DVIR) hub](https://www.fmcsa.dot.gov/regulations/inspection-repair-and-maintenance-driver-vehicle-inspection-report-dvir)
* [49 CFR Part 393 Parts and Accessories Necessary for Safe Operation](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-III/subchapter-B/part-393)
* [49 CFR Part 382 Controlled Substances and Alcohol Use and Testing](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-III/subchapter-B/part-382)
* [49 CFR Part 573 Defect and Noncompliance Responsibility and Reports](https://www.ecfr.gov/current/title-49/subtitle-B/chapter-V/part-573)
* [29 CFR Part 1904 Recording and Reporting Occupational Injuries and Illnesses](https://www.ecfr.gov/current/title-29/subtitle-B/chapter-XVII/part-1904)
* [29 CFR Part 1910 Occupational Safety and Health Standards (general industry)](https://www.ecfr.gov/current/title-29/subtitle-B/chapter-XVII/part-1910)
* [DOL Fact Sheet #66 The Davis-Bacon and Related Acts (40 USC Chapter 31)](https://www.dol.gov/agencies/whd/fact-sheets/66-dbra)
* [DOL Fact Sheet #67 The McNamara-O'Hara Service Contract Act (41 USC Chapter 67)](https://www.dol.gov/agencies/whd/fact-sheets/67-sca)
* [NHTSA Cybersecurity Best Practices for the Safety of Modern Vehicles (September 2022)](https://www.nhtsa.gov/document/cybersecurity-best-practices-safety-modern-vehicles-2022)

### B.5 Industry safety and governance frameworks

* [TMC of ATA Recommended Practices](https://tmc.trucking.org/TMC-Recommended-Practices)
* [SAE J3138_202210 Diagnostic Link Connector Security (October 2022)](https://www.sae.org/standards/content/j3138_202210/)
* [ATRI An Analysis of the Operational Costs of Trucking 2025 Update](https://truckingresearch.org/2025/07/an-analysis-of-the-operational-costs-of-trucking-2025-update/)
* [Penske Cost of Downtime resource](https://www.pensketruckleasing.com/resources/resource-library/cost-of-downtime/)

### B.6 Vendor product patterns (illustrative; not endorsements)

* [Decisiv Surpasses 25 Million Service Event Milestone (November 2022)](https://www.decisiv.com/decisiv-surpasses-25-million-service-event-milestone/)
* [Decisiv ASIST/Fleet for Volvo and Mack](https://volvo.asist.decisiv.net/)
* [PACCAR Solutions on Decisiv](https://paccar.decisiv.net/)
* [Samsara Connected Maintenance](https://www.samsara.com/products/telematics/fleet-maintenance)
* [Fleetio Go mobile app](https://www.fleetio.com/go)
* [Trimble TMT Fleet Maintenance (manages 1M+ assets)](https://transportation.trimble.com/products/tmt-fleet-maintenance)
* [Cetaris Fleet Maintenance](https://cetaris.com/)
* [Karmak Fusion (4,000+ rooftops)](https://www.karmak.com/fusion)
* [Fullbay Heavy-Duty Truck and Trailer Repair Shop Software](https://www.fullbay.com/)
* [Whip Around digital DVIR](https://trial.whiparound.com/fleet-inspection-software)
* [ServiceTitan Field Service Dispatch (Dispatch Pro)](https://www.servicetitan.com/features/dispatch-software)
