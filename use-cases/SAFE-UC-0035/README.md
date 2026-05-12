# AI medical scribe and ambient clinical documentation assistant

> **SAFE‑AUCA industry reference guide (draft)**
>
> This use case describes the workflow that has become the highest-deployment AI agentic surface in US healthcare delivery as of 2025-2026: an ambient clinical documentation assistant that listens to a clinician-patient encounter through an in-room or smartphone microphone, performs automatic speech recognition (ASR) on the captured audio, and uses a large language model to draft the clinical note (history of present illness, review of systems, physical exam, assessment, plan, orders, and billing code suggestions) in the format the clinician's electronic health record expects. The clinician reviews and signs. The note becomes the legal record of the encounter, the basis for the bill submitted to Medicare or a commercial payer, the input to clinical decision support, and the chart-note that the patient sees through their patient portal under the ONC Information Blocking Rule (45 CFR Part 171).
>
> This is the **first SAFE-AUCA use case in NAICS 62 (Health Care and Social Assistance)** and the cohort baseline for sibling healthcare UCs (prior authorization automation, patient triage chatbots, imaging triage, RPM alerting, mental-health conversational AI). It has no NAICS-adjacent sibling but has two structurally close cohort siblings: SAFE-UC-0019 (post-incident review drafting), where the AI's primary output IS the regulated text and review-fatigue under deadline pressure is the dominant failure mode, and SAFE-UC-0010 (in-vehicle voice assistant), where the microphone is the cyber-physical sensor and acoustic-channel injection is a documented attack surface. The defining inversion versus 0019 is that **here the AI's output is the legal medical record and the basis for a False Claims Act-relevant billing claim**. A hallucinated medication in a draft note can land in a Medicare claim. The Cornell University study presented at ACM FAccT in June 2024 found OpenAI's Whisper model, the canonical open-source ASR system used by many commercial scribes, hallucinated content in roughly 1% of medical-transcription test samples, including fabricated medications, racial commentary, and violent statements. AP and ABC News covered the finding in October 2024.
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
| **SAFE Use Case ID** | `SAFE-UC-0035`                                                     |
| **Status**           | `draft`                                                            |
| **Maturity**         | draft                                                              |
| **NAICS 2022**       | `62` (Health Care and Social Assistance); `6211` (Offices of Physicians); `6221` (General Medical and Surgical Hospitals) |
| **Last updated**     | `2026-05-09`                                                       |

### Evidence (public links)

* [Cornell University Department of Computer Science: Careless Whisper, Speech-to-Text Hallucination Harms (Koenecke, Choi, Mei, Schellmann, Sloane; presented at ACM FAccT June 2024; identified hallucinated content in roughly 1% of medical-transcription test samples)](https://arxiv.org/abs/2402.08021)
* [Associated Press: Researchers say AI transcription tool used in hospitals invents things no one ever said (26 October 2024 coverage of the Whisper hallucination findings)](https://apnews.com/article/ai-artificial-intelligence-health-business-90020cdf5fa16c79ca2e5b6c4c9bbb14)
* [Microsoft Nuance: Dragon Ambient eXperience (DAX) Copilot product page](https://www.nuance.com/healthcare/ambient-clinical-intelligence.html)
* [Microsoft: Microsoft Cloud for Healthcare adds DAX Copilot generally available across Microsoft 365 (announcement)](https://www.microsoft.com/en-us/industry/blog/healthcare/2024/01/17/dax-copilot-is-now-generally-available-with-new-features-to-help-healthcare-organizations-improve-the-patient-and-clinician-experience/)
* [Abridge: company website (clinical-conversation generative AI; Series E announced February 2025)](https://www.abridge.com/)
* [Suki AI: voice-enabled AI assistant for clinical documentation](https://www.suki.ai/)
* [DeepScribe: ambient AI medical scribe](https://www.deepscribe.ai/)
* [Augmedix: ambient automation for clinicians](https://www.augmedix.com/)
* [HIPAA Privacy Rule (45 CFR Part 164 Subpart E; HHS canonical reference)](https://www.hhs.gov/hipaa/for-professionals/privacy/index.html)
* [HIPAA Security Rule (45 CFR Part 164 Subpart C; HHS canonical reference; administrative, physical, and technical safeguards for electronic PHI)](https://www.hhs.gov/hipaa/for-professionals/security/index.html)
* [HIPAA Breach Notification Rule (45 CFR 164.400 to 164.414; HHS canonical reference)](https://www.hhs.gov/hipaa/for-professionals/breach-notification/index.html)
* [HHS Office for Civil Rights: Healthcare and Public Health Sector Cybersecurity Performance Goals (released December 2023; voluntary essential and enhanced practices)](https://hphcyber.hhs.gov/performance-goals.html)
* [21st Century Cures Act, Section 3060 amending Federal Food, Drug, and Cosmetic Act 21 USC 360j(o); the Clinical Decision Support exception that scopes when software is or is not a medical device](https://www.law.cornell.edu/uscode/text/21/360j)
* [FDA: Clinical Decision Support Software final guidance (September 2022)](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/clinical-decision-support-software)
* [ONC Information Blocking Rule (45 CFR Part 171; CMS and ASTP coordinated; the rule that requires patient access to electronic health information including AI-generated notes through a patient portal)](https://www.healthit.gov/topic/information-blocking)
* [CMS Conditions of Participation, Medical Record Services (42 CFR 482.24; the operative federal hospital regulation governing medical record content, authentication, and timeliness)](https://www.ecfr.gov/current/title-42/chapter-IV/subchapter-G/part-482/subpart-C/section-482.24)
* [American Medical Association: Augmented Intelligence in Health Care policy (adopted 2018; updated 2023; the canonical AMA position on physician-of-record attestation for AI-assisted clinical work)](https://www.ama-assn.org/practice-management/digital/augmented-intelligence-ai)
* [Joint Commission: Record of Care, Treatment, and Services standards (the operative accreditation standards for medical record content; RC.01.01.01 and RC.02.01.01 are the most-cited)](https://www.jointcommission.org/standards/standard-faqs/)
* [False Claims Act (31 USC 3729 to 3733; the operative federal statute governing fraudulent submission of claims to federal health programs)](https://www.law.cornell.edu/uscode/text/31/chapter-37/subchapter-III)
* [42 CFR Part 2: Confidentiality of Substance Use Disorder Patient Records (the federal rule with stricter consent requirements than HIPAA for SUD records; 2024 final rule aligned more closely with HIPAA but retained core consent protections)](https://www.ecfr.gov/current/title-42/chapter-I/subchapter-A/part-2)
* [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)
* [NIST AI Risk Management Framework Generative AI Profile (AI 600-1; July 2024)](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)

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
An **AI medical scribe and ambient clinical documentation assistant** is a workflow in which a clinician initiates an audio recording of an in-person, telehealth, or telephone patient encounter, the captured audio is transcribed by an ASR pipeline, and a large language model drafts the clinical note in the structure the clinician's EHR expects. Typical drafted artifacts include:

* the visit note (subjective, objective, assessment, plan; or chief complaint, history of present illness, review of systems, past medical and family and social history, physical exam, assessment, and plan)
* problem-list updates and active-medication reconciliation
* draft orders (medications, imaging, lab, referrals) staged for clinician signature
* draft billing-code suggestions (ICD-10-CM diagnosis codes, CPT and HCPCS procedure codes, modifiers) for the revenue-cycle pipeline
* draft after-visit summary content for the patient
* draft prior-authorization narrative to support a downstream PA workflow
* draft referral letters and care-coordination messages
* clinician-facing summaries of the patient's prior encounters and recent results

Industry deployments span every major US health system. **Microsoft Nuance Dragon Ambient eXperience (DAX) Copilot** is the dominant enterprise deployment, generally available since January 2024 and bundled with Microsoft 365 Copilot for Healthcare. **Abridge** raised a Series E in February 2025 with widely-reported $250M at a $2.75B valuation and is the canonical pure-play vendor in the space. **Suki**, **DeepScribe**, **Augmedix**, **Doximity GPT**, **Ambience Healthcare**, **Atropos Health**, and the EHR-vendor-native suites (**Epic with Microsoft DAX integration**, **Oracle Health Clinical Digital Assistant**, **Athenahealth ambient features**) anchor the rest of the production market. Internal-tool deployments at large IDNs (Kaiser Permanente, Mayo Clinic, Cleveland Clinic, Mass General Brigham, UPMC, Sutter Health, Stanford Health Care) often build on AWS HealthLake, Azure Health Data Services, or Google Vertex AI Healthcare.

**Why it matters (business value).**
Documentation burden is the single largest driver of clinician burnout in US medicine. The Annals of Family Medicine has reported clinicians spending more time on the EHR than in face-to-face patient care, with roughly two hours of after-hours documentation work per clinical day commonly cited in burnout research. Ambient documentation automates the writing step. Pilot results from large IDNs publicly report reduced documentation time, improved clinician satisfaction, faster time to encounter close, and faster revenue-cycle close. The clinical note is also the basis for billing, so a complete and accurate note shortens the days-in-AR cycle. The surface is also strategically central for the EHR vendor's AI roadmap: every Epic-Microsoft, Oracle Health, and Athenahealth investment in ambient documentation is a bet that the encounter note is the foundational data product on which downstream clinical AI will be built.

**Why it is risky and what can go wrong.**
This workflow's defining trait is that **the AI's primary output IS the legal medical record**. SAFE-UC-0019's PIR drafter writes a regulator-facing narrative that a named human signs. SAFE-UC-0024's terminal SRE assistant proposes a shell command that a human approves. SAFE-UC-0035's medical scribe writes the chart note that becomes the legal record of the encounter, the basis for a Medicare or commercial-payer claim, the input to malpractice litigation discovery, the source of patient-portal-visible information under the ONC Information Blocking Rule, and the data feeding the next year of clinical decision support. A hallucinated medication, a fabricated diagnosis, a phantom physical-exam finding, or an invented past-medical-history element can land verbatim in the chart, the bill, the patient's portal, and the outbound interoperability feed.

Eight concurrent risk surfaces define this workflow as of 2026, and several have no exact analog in any prior SAFE-AUCA cohort use case.

* **ASR hallucination of clinical content.** The Cornell University study presented at ACM FAccT in June 2024 found OpenAI Whisper hallucinated content in roughly 1% of medical-transcription test samples. Documented hallucinations included fabricated medications, racial commentary, and violent statements. AP and ABC News covered the finding in October 2024. Whisper underlies many commercial scribes either directly or as a component. The hallucination is generative at the ASR layer, distinct from the LLM-summarization layer; it cannot be caught by prompting the LLM to "be more careful."
* **Phantom encounter content.** The LLM may draft history, review of systems, physical exam, or past-medical-history content that the clinician did not discuss with the patient. The note appears clinically plausible because the LLM has seen millions of similar notes. The clinician under review-fatigue may sign without catching the fabrication.
* **PHI cross-patient bleed.** A multi-tenant ambient-scribe deployment that fails to isolate per-encounter context can surface patient A's history in patient B's note. The HIPAA Privacy Rule §164.502(a) permission boundary is breached the moment the bleed occurs.
* **Audio-capture consent violation under state two-party consent law.** The federal Wiretap Act (18 USC 2510 to 2523) preempts a one-party-consent floor in many jurisdictions, but California (Penal Code §632), Florida, Illinois, Massachusetts, Michigan, Montana, Nevada, New Hampshire, Pennsylvania, and Washington require all-party consent for the audio recording. The patient's consent has to be obtained before the recording starts; the AMA Augmented Intelligence policy and most health-system policies treat this as a hard prerequisite.
* **False Claims Act exposure via AI-fabricated billing support.** When the AI-drafted note supports a CPT code or modifier the clinician did not actually justify with documented work, and the bill is submitted to Medicare or Medicaid, the False Claims Act (31 USC 3729) is in scope. The Department of Justice has consistently treated upcoded or unsupported claims as FCA-actionable; AI-fabricated documentation is an emerging litigation frontier.
* **ONC Information Blocking exposure of AI-drafted notes to the patient.** Under 45 CFR Part 171, hospitals and providers participating in federal programs are required to provide patient access to electronic health information through certified APIs. AI-drafted notes are part of that information. Inaccurate notes flow to the patient through MyChart-class portals; the patient sees the AI's hallucination.
* **FDA SaMD scope creep.** The 21st Century Cures Act (21 USC 360j(o)(1)) carves out certain Clinical Decision Support software from FDA medical-device regulation when four criteria hold (no medical-image analysis, intended for healthcare-provider review, intended to support not replace clinical judgment, allows the provider to independently review the basis). FDA's September 2022 final guidance on Clinical Decision Support Software interprets the carve-out. An ambient scribe that generates a clinical recommendation, prioritizes differential diagnoses, or orders staging for malignancy crosses the line and becomes a regulated medical device.
* **42 CFR Part 2 substance-use-disorder records.** SUD records have stricter consent requirements than general PHI. The 2024 final rule aligned 42 CFR Part 2 more closely with HIPAA but retained core consent protections. Ambient scribes capturing SUD-relevant content (methadone clinics, OB clinics seeing SUD-positive parents, primary-care visits with SUD diagnoses) inherit Part 2's consent regime in addition to HIPAA.

A defining inversion versus SAFE-UC-0019: in 0019 the AI drafts an internal-then-regulator narrative reviewed by the incident commander. In 0035, the clinician is the only human in the loop, the encounter is one of dozens that day, and review-fatigue compounds across the daily clinic schedule. The patient never sees the audio; they see the chart note in the portal weeks later. The reviewer of the AI-drafted regulatory disclosure to a regulator (0019) is structurally weaker after an 8-hour SEV-0; the reviewer of the AI-drafted chart note (0035) is structurally weaker after a 10-hour clinic day with 25 patients seen.

---

## 2. Industry context & constraints (reference-guide lens)

### Where this shows up

Common in:

* US integrated delivery networks and academic medical centers (Kaiser Permanente, Mayo Clinic, Cleveland Clinic, Mass General Brigham, UPMC, Sutter Health, Stanford Health Care, NYU Langone, Cedars-Sinai, Mount Sinai, Geisinger, Intermountain, Atrium, Advocate, Banner, Northwell, HCA, CommonSpirit)
* community hospitals and rural health systems
* multi-specialty group practices (primary care, internal medicine, family medicine, pediatrics, OB-GYN, surgical specialties, behavioral health, oncology)
* federally qualified health centers and rural health clinics under HRSA
* telehealth platforms (Teladoc, Amwell, MDLive, Doctor on Demand, Included Health) where the encounter is by definition recorded
* inpatient hospital settings with bedside rounding documentation
* emergency departments with high-volume, time-pressured documentation
* skilled nursing facilities and long-term care
* home-health visit documentation
* mental and behavioral health settings (special handling for 42 CFR Part 2 SUD records)
* dental, optometry, and physical-therapy offices increasingly adopting parallel ambient tools
* veterinary medicine adopting parallel tools (out of scope here but the workflow shape mirrors)

### Typical systems

* electronic health record systems (Epic, Oracle Health formerly Cerner, Meditech, Athenahealth, Allscripts/Veradigm, eClinicalWorks, NextGen, Greenway, Practice Fusion, athenaOne)
* ambient documentation platforms (Microsoft Nuance DAX Copilot, Abridge, Suki, DeepScribe, Augmedix, Ambience Healthcare, Doximity GPT, Atropos Health, Oracle Health Clinical Digital Assistant, Athenahealth ambient features)
* speech-recognition components (OpenAI Whisper, Microsoft Azure Speech, Google Speech-to-Text, AWS Transcribe Medical, Nuance proprietary engines)
* foundation-model layers (OpenAI GPT-class, Anthropic Claude, Google Gemini, Meta Llama, Mistral, Cohere; deployed via Azure OpenAI, AWS Bedrock, GCP Vertex AI; or hosted directly)
* clinical decision support and order-set systems (Epic SmartSets, Oracle Health PowerOrders, UpToDate, OpenEvidence)
* coding and revenue-cycle systems (3M 360 Encompass, Optum CAC, R1 RCM, Change Healthcare)
* identity and access (Active Directory, Okta, Imprivata for tap-and-go badge auth; SMART on FHIR for app-level)
* interoperability layers (HL7 v2 messaging, FHIR R4 APIs, USCDI v3 data classes; ASTP-coordinated)
* health information exchanges (Carequality, CommonWell, eHealth Exchange) for cross-organization sharing
* patient portals (MyChart for Epic, Oracle Health Patient Portal, athenaPatient) under ONC Information Blocking
* analytics and population health (Epic Cogito, Health Catalyst, Innovaccer)
* AI/ML: ASR pipelines, foundation-model summarizers, retrieval over the patient's prior chart, fine-tuned coding suggesters, named-entity recognition for medication and allergy extraction, structured-output schema enforcement

### Constraints that matter

* **HIPAA Privacy Rule (45 CFR Part 164 Subpart E).** Permission boundaries on PHI use and disclosure. §164.502(a) "minimum necessary" applies to most uses. §164.508 authorization for non-treatment-payment-operations uses. §164.512 permitted disclosures. Business-associate agreements (§164.504(e)) with every ambient-scribe vendor.
* **HIPAA Security Rule (45 CFR Part 164 Subpart C).** Administrative, physical, and technical safeguards for electronic PHI. §164.308 administrative safeguards (security management, workforce security, information access management, training, contingency planning, evaluation). §164.312 technical safeguards (access control, audit controls, integrity, person or entity authentication, transmission security).
* **HIPAA Breach Notification Rule (45 CFR 164.400 to 164.414).** Notification to individuals within 60 days of discovery; HHS Secretary contemporaneously for breaches affecting 500 or more; media notification at the 500-individual-per-state threshold.
* **HHS Office for Civil Rights Healthcare and Public Health Sector Cybersecurity Performance Goals (December 2023).** Voluntary essential and enhanced practices that examiners increasingly reference.
* **21st Century Cures Act 21 USC 360j(o)(1) Clinical Decision Support exception.** Software is not a medical device when it (1) is not intended to acquire, process, or analyze a medical image or signal from in vitro diagnostic device or signal acquisition system; (2) is intended to display, analyze, or print medical information; (3) is intended to support or provide recommendations to a healthcare provider about prevention, diagnosis, or treatment; AND (4) is intended for the purpose of enabling such healthcare provider to independently review the basis for such recommendations. Failing any of these four criteria triggers FDA medical-device regulation.
* **FDA Clinical Decision Support Software Final Guidance (September 2022).** The FDA's interpretation of the four-criteria exception. The fourth criterion ("independently review the basis") is the most-litigated boundary; an ambient scribe that draws a confident conclusion without surfacing the source is closer to medical-device territory.
* **ONC Information Blocking Rule (45 CFR Part 171).** Healthcare providers and IT developers cannot interfere with access, exchange, or use of electronic health information. The CMS-ASTP coordinated rule under the 21st Century Cures Act applies to "actors" including healthcare providers, health information networks, and certified health IT developers. The eight defined exceptions (preventing harm, privacy, security, infeasibility, content and manner, fees, licensing, manner) are narrow.
* **CMS Conditions of Participation (42 CFR 482.24).** The operative federal hospital regulation. §482.24(c) requires medical record entries to be timed, dated, and authenticated by the responsible practitioner. AI-drafted content does not satisfy authentication; the clinician's signature does. The 30-day completion requirement (§482.24(c)(4)(viii)) caps how long a draft can sit unsigned.
* **AMA Augmented Intelligence in Health Care policy (2018, updated 2023).** Calls for clinician oversight, transparency, equity, and physician-of-record attestation. Many state medical boards reference AMA policy in disciplinary positions on AI-assisted documentation.
* **Joint Commission Record of Care, Treatment, and Services standards (RC.01.01.01, RC.02.01.01).** Accreditation-level requirements on medical record content, completeness, authentication, and authentication timing. Critical-access-hospital and ambulatory accreditation programs share these standards.
* **False Claims Act (31 USC 3729 to 3733).** Treble damages plus per-claim civil penalties for knowingly submitting false claims to federal programs. AI-fabricated documentation supporting an unsupported CPT or HCPCS code is an emerging FCA frontier.
* **42 CFR Part 2 (Confidentiality of Substance Use Disorder Patient Records).** Stricter consent than HIPAA for SUD records. The 2024 final rule aligned more closely with HIPAA but retained core protections.
* **HIPAA-aligned state laws.** California CMIA, Texas HB 300, Florida confidentiality of medical records, New York PHL §18.
* **State two-party-consent recording statutes.** California Penal Code §632, Florida Statute §934.03, Illinois 720 ILCS 5/14-2, Massachusetts G.L. c. 272 §99, Michigan, Montana, Nevada, New Hampshire, Pennsylvania, Washington. The audio capture is a recording even when the audio is processed and discarded; the consent obligation attaches at the recording.
* **Federal Wiretap Act (18 USC 2510 to 2523).** Federal floor; state two-party laws are stricter for in-state-recorded audio.
* **Stark Law (42 USC 1395nn) and Anti-Kickback Statute (42 USC 1320a-7b).** Vendor relationships and free-or-discounted ambient-scribe access from referral sources are scrutinized when the vendor is a referring entity.
* **EU AI Act (Regulation EU 2024/1689) Article 50** transparency for the conversational layer when used for EU patients; **Annex III §1** biometric-identification scope when voiceprint-based clinician identification is used.
* **GDPR Article 9** special-category health data; **Article 33** 72-hour breach notification; for any EU-patient encounter.
* **Joint Commission Sentinel Event reporting** for patient-harm events traceable to documentation errors.
* **State medical board AI scribe policies.** Emerging from California Medical Board, Texas Medical Board, New York Department of Health, and others (2024-2025 releases).

### Must-not-fail outcomes

* drafting a clinical note containing hallucinated medication, allergy, diagnosis, or physical-exam content that the clinician signs without catching
* drafting a billing code (ICD-10-CM, CPT, HCPCS) the clinician's actual work does not support, leading to a False Claims Act-exposable submission
* surfacing patient A's PHI in patient B's note (cross-encounter bleed)
* recording audio without obtaining patient consent in a two-party-consent state
* drafting a clinical decision (differential diagnosis prioritization, treatment recommendation, staging recommendation) that crosses the FDA Clinical Decision Support exception line and operates as an unregistered medical device
* publishing an AI-drafted note to the patient portal under ONC Information Blocking with hallucinated content
* capturing 42 CFR Part 2 substance-use-disorder content without the heightened consent
* failing to authenticate the medical record under 42 CFR 482.24 (the clinician's signature; AI-drafted content alone does not satisfy authentication)
* breaching HIPAA Security Rule §164.312 technical safeguards on the audio-capture-and-transcript pipeline
* missing the §164.412 breach-notification 60-day window when an ambient-scribe-vendor breach exposes PHI

---

## 3. Workflow description and scope

### 3.1 Workflow steps (happy path)

1. The clinician obtains patient consent for the audio recording per the state-applicable consent regime (one-party federal floor; two-party for the listed states). Consent is recorded in the chart and timestamped.
2. The clinician initiates the recording from a smartphone app, an in-room microphone, or an EHR-integrated capture surface (Epic Hyperdrive ambient capture, Oracle Health Clinical Digital Assistant button, athenaOne ambient).
3. The encounter occurs. The ASR pipeline transcribes in near-real-time or post-encounter. Transcription may run on-device, in a vendor cloud, or in the health system's own VPC.
4. The transcript is segmented and the LLM drafts the structured note: chief complaint, history of present illness, review of systems, past medical and family and social history, physical exam, assessment, plan, and orders. The drafter cites the transcript span supporting each note section.
5. The drafter proposes ICD-10-CM diagnosis codes and CPT and HCPCS procedure codes with modifiers, drawing from the transcript and the clinician's prior coding patterns.
6. The clinician reviews the drafted note in the EHR. The clinician edits, accepts, or rejects each section. Order entries are staged but not signed until the clinician explicitly signs.
7. The clinician signs the note. The signature is the §482.24 authentication. The note becomes the legal record.
8. The signed note triggers downstream pipelines: revenue-cycle claim assembly, ONC Information Blocking patient-portal publication, interoperability outbound to HIE, problem-list update, medication-reconciliation update, care-coordination outbound, and decision-support trigger evaluation.
9. The audio recording, transcript, and AI-drafted state are retained per the vendor's contracted retention schedule and the health system's HIPAA Security Rule policies. Retention horizons commonly range from delete-after-signoff to 7-year retention.
10. Post-incident analytics feed clinician-facing quality dashboards (note-completion time, note-amendment rate, billing-code-acceptance rate) and vendor model retraining (under the Business Associate Agreement's permitted-use scope).

### 3.2 In scope and out of scope

* **In scope:** ambient audio capture with clinician-attested patient consent; ASR transcription; LLM-drafted clinical note in EHR-expected structure; LLM-drafted billing-code suggestions; LLM-drafted orders staged for signature; LLM-drafted after-visit summary content; LLM-drafted prior-authorization narrative; LLM-drafted referral letters; per-clinician personalization of style and structure; clinician-attestation gate before any note becomes part of the legal record.
* **Out of scope:** AI-generated clinical decisions that cross the FDA CDS exception (differential-diagnosis prioritization with confident recommendation, treatment-protocol selection, malignancy staging, dose calculation); AI-only signing of the medical record (every note signature is the clinician's); AI-only ordering (every order requires clinician signature); AI-only billing-claim submission (revenue-cycle review remains a separate function); AI-drafted disclosures to law enforcement; AI-drafted Substance Use Disorder records that bypass the 42 CFR Part 2 consent regime.

### 3.3 Assumptions

* The health system has executed a HIPAA Business Associate Agreement with the ambient-scribe vendor covering the scope of PHI use, retention, deletion, breach notification, and subcontractor flow-down.
* Patient consent for audio recording is obtained per the state-applicable regime (one-party or two-party) and recorded in the chart with timestamp.
* The clinician retains physician-of-record attestation per AMA Augmented Intelligence policy and signs every note.
* The EHR's authentication layer (Active Directory, Imprivata tap-and-go, SMART on FHIR) gates clinician sign-off.
* The ambient-scribe deployment falls within the FDA CDS exception (the four §360j(o)(1) criteria hold). If the vendor's product crosses into clinical decision generation, FDA premarket review is presumed.
* The ONC Information Blocking publication path is configured per the health system's policy; AI-drafted notes flow to the patient portal after clinician signoff and per the configured delay window.
* PHI handling complies with HIPAA Security Rule §164.312 technical safeguards (access controls, audit controls, integrity, authentication, transmission security).

### 3.4 Success criteria

* Hallucinated clinical content (medication, allergy, diagnosis, physical-exam finding, past-medical-history element, race or ethnicity attribution) is at or near zero in signed notes.
* Cross-patient PHI bleed in note generation is zero.
* Patient consent for audio recording is documented for every recorded encounter in two-party states.
* Billing codes proposed by the AI are supported by the actual encounter content; the False Claims Act exposure surface is zero.
* Notes published to the patient portal under ONC Information Blocking are accurate.
* Clinical decisions remain in the clinician's hands; the FDA CDS exception holds.
* 42 CFR Part 2 SUD-content handling follows the heightened consent regime when applicable.
* The medical record is authenticated by the clinician per 42 CFR 482.24; the 30-day completion window is met.
* HIPAA Privacy, Security, and Breach Notification rules are continuously demonstrated through OCR-aligned evidence.
* Vendor breach notification reaches the covered entity within the BAA-contracted window (commonly 30 days or sooner).

---

## 4. System and agent architecture

### 4.1 Actors and systems

* **Human roles:** the clinician (physician, advanced practice provider, registered nurse documenting under a clinician's authorization, behavioral-health clinician); the patient and any consenting guardian or surrogate; the privacy officer; the security officer; the chief medical informatics officer; the quality and patient-safety officer; the revenue-cycle integrity team; the compliance officer; counsel for the health system; the FDA-regulatory liaison if the ambient product approaches the CDS line.
* **Agent / orchestrator:** the ambient-capture client; the ASR pipeline; the LLM drafter; the billing-code suggester; the order-stager; the after-visit-summary drafter; the patient-portal-publisher.
* **LLM runtime:** typically a hosted foundation model behind the vendor's product surface (Microsoft DAX uses Azure OpenAI; Abridge runs on multiple models; Suki and Augmedix have proprietary stacks). Some health systems run a private model in their own VPC for data-residency reasons.
* **Tools (MCP servers / APIs / connectors):** EHR write API (HL7 v2 ADT and ORM messages, FHIR R4 resources for Encounter, Observation, MedicationRequest, ServiceRequest, Procedure, DocumentReference); EHR read API for the patient's prior chart; ASR API; Audio capture API (smartphone or room microphone); coding suggestion service; order set service; CDS Hooks for clinician-facing prompts; ASTP-coordinated FHIR API for outbound interoperability; HIE connectors (Carequality, CommonWell); 42 CFR Part 2 consent gate; HIPAA audit log writer.
* **Data stores:** audio recording archive (with retention per BAA); transcript archive; AI-drafted note archive (separate from the signed note); signed note in the EHR's record-of-care store; billing-claim drafts; patient-portal publication queue; HIPAA audit log; consent record; clinician signature audit; Sentinel Event monitoring queue.
* **Downstream systems affected:** the patient (through portal access under Information Blocking); the payer (through claim submission under FCA); the HIE and outbound interoperability (through FHIR APIs); the population-health and analytics platform; the revenue-cycle pipeline; the clinical decision support layer; the malpractice litigation discovery archive.

### 4.2 Trusted vs untrusted inputs

A defining feature of this workflow is that **the audio capture is the cyber-physical input and the patient's speech is the prompt**. Every input class is at least semi-untrusted because the patient may say anything (intentional fabrication, confusion, intoxication, mental-health crisis), the clinician's notes may be incomplete, the prior chart may contain stale or wrong content, and the LLM hallucination is generative.

| Input / source                                                | Trusted?                  | Why                                                                                                                  | Typical failure / abuse pattern                                                                                                                                  | Mitigation theme                                                                                                                                |
| ------------------------------------------------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Audio recording of the encounter                              | Cyber-physical-untrusted   | the microphone captures whatever speech is in the room, including untrusted content from any source                  | acoustic injection from outside the room (the SAFE-UC-0010 pattern); third-party speech inadvertently captured; ambient noise misclassified                       | room-microphone narrow capture; pre-recording consent; post-capture-review-before-publish                                                       |
| ASR transcript                                                | Untrusted-by-construction  | hallucinations are documented (Cornell ACM FAccT June 2024 Whisper finding)                                          | hallucinated medication, allergy, diagnosis, racial commentary, violent statement                                                                                | secondary verification on safety-critical entities (medication, allergy, diagnosis); confidence signals; source-span citation in drafted note   |
| LLM drafter output                                            | Untrusted-by-construction  | probabilistic                                                                                                         | phantom encounter content, plausible-sounding fabrications, billing code unsupported by transcript                                                              | source-span citation per note section; no-content-without-source policy on safety-critical sections; clinician-attestation gate                  |
| Patient speech                                                | Trusted-but-incomplete    | the patient is the source of truth on subjective complaints but may be wrong on history, medications, or allergies   | medication-list errors; allergy-list errors; past-medical-history confusion                                                                                      | medication reconciliation against the EHR record; allergy verification against authoritative sources                                            |
| Prior chart content (problem list, medications, allergies)    | Authoritative-but-stale   | EHR is the system of record but stale content is common                                                              | drafting from stale problem list; outdated allergy list                                                                                                          | timestamp-and-source-of-truth display; staleness markers; clinician-review prompt on safety-critical fields                                      |
| Patient consent record                                        | Trusted                    | clinician-attested at the start of the encounter                                                                     | missing consent in two-party-consent state; consent obtained but not recorded                                                                                    | hard gate on recording without consent; consent timestamp in audit log                                                                          |
| Coding-suggestion model output                                | Untrusted-by-construction  | probabilistic; trained to optimize for coder acceptance, not for FCA compliance                                      | upcoded suggestion; modifier suggestion unsupported by documentation                                                                                            | revenue-cycle integrity review; named-coder signoff; billing-code-versus-documentation match check                                              |
| Decision-support hooks                                        | Authoritative              | trigger logic from the EHR vendor or the CDS service                                                                  | over-firing alerts; mis-fired hooks                                                                                                                              | CDS-vendor SLA; alert-fatigue monitoring                                                                                                       |
| Cross-patient context retrieval                               | Tenant-scoped              | shared multi-tenant SaaS                                                                                              | patient-A context bleed into patient-B note                                                                                                                      | per-encounter session ID; tenant-isolation enforcement at every layer                                                                          |
| Vendor model retraining via BAA                               | Contractually-bounded     | BAA may permit deidentified retraining                                                                                | unbounded permitted use; mis-deidentified PHI leakage to model                                                                                                   | BAA scope discipline; deidentification audit                                                                                                   |
| MCP server tool descriptions                                  | Semi-trusted               | authored upstream                                                                                                     | tool-description poisoning shaping the drafter                                                                                                                  | pin and sign manifests; registry verification                                                                                                    |

### 4.3 Trust boundaries

Teams commonly model eight boundaries when reasoning about this workflow:

1. **Audio-capture-to-ASR boundary.** The microphone is the cyber-physical sensor; the room is the threat boundary; consent gates the capture.
2. **ASR-to-LLM boundary.** Transcript hallucinations propagate into the LLM context. Source-span citation discipline at this boundary is the hallucination-control anchor.
3. **LLM-to-EHR-draft boundary.** The drafted note enters the EHR as a draft, not as the legal record.
4. **Clinician-attestation boundary.** The clinician's signature is the authentication under 42 CFR 482.24. AI-drafted state is preserved before signoff for audit.
5. **EHR-to-claim-submission boundary.** Billing codes proposed by the AI flow to the revenue-cycle pipeline. The False Claims Act exposure attaches at submission; revenue-cycle integrity review is the recovery anchor.
6. **EHR-to-patient-portal boundary.** Under ONC Information Blocking, the signed note flows to the patient portal per the configured delay window. The patient sees what the clinician signed.
7. **EHR-to-interoperability boundary.** FHIR and HIE outbound flows propagate the note to other organizations. The note's accuracy is the trust anchor.
8. **Vendor-BAA boundary.** PHI flows to the vendor under a Business Associate Agreement. Deidentified retraining, retention horizons, breach-notification windows, and subcontractor flow-down are the contracted dimensions.

### 4.4 Permission and approval design

* **Patient consent for audio recording** is obtained before recording starts. In two-party-consent states the consent is explicit and verbal or written; in one-party states the clinician's consent suffices but health-system policy commonly requires patient consent anyway.
* **Clinician signature on every note** before it becomes the legal record. AI-drafted state is preserved in the audit trail.
* **Clinician signature on every order** before it is transmitted to the pharmacy, lab, imaging, or referral target.
* **Revenue-cycle integrity review** on AI-suggested billing codes before claim submission for any code class flagged as high-FCA-risk by the health system's compliance program.
* **42 CFR Part 2 consent** for SUD-record content; the consent gate is separate from general HIPAA consent.
* **ONC Information Blocking** publication delay configured per health-system policy and regulatory permission.
* **Vendor-breach-notification** within the BAA-contracted window (commonly 30 days or sooner; HHS OCR rule is up to 60 days for the CE notification, but BAAs commonly tighten).
* **FDA SaMD scope review** before any product or feature crosses the CDS exception line.

### 4.5 Tool inventory

| Tool / connector                                              | Read / Write   | Scope                               | Risk class                                                                       |
| ------------------------------------------------------------- | -------------- | ----------------------------------- | -------------------------------------------------------------------------------- |
| Audio capture client (smartphone, in-room mic, EHR-integrated) | Read           | Per-encounter                       | Cyber-physical sensor; consent-gated                                              |
| ASR pipeline (Whisper / Azure Speech / AWS Transcribe Medical) | Read + Write   | Per-encounter                       | Hallucination surface (the canonical Cornell finding)                             |
| LLM drafter                                                   | Read + Write   | Per-encounter                       | Hallucination surface; phantom-content surface                                    |
| EHR write API (Epic Hyperdrive, Oracle Health, Athena, FHIR)  | Read + Write   | Per-encounter; gated for sign       | Authentication-relevant under 42 CFR 482.24                                       |
| EHR read API (prior chart, problem list, meds, allergies)     | Read           | Per-patient                         | Stale-content surface                                                             |
| Coding suggester (3M 360 Encompass, Optum CAC, vendor-native) | Read           | Per-encounter                       | False Claims Act exposure surface                                                 |
| Order stager (medication, lab, imaging, referral)             | Read + Write   | Per-encounter; gated for sign       | Patient-safety-critical                                                           |
| CDS Hooks                                                     | Read           | Per-encounter                       | Alert-fatigue surface                                                             |
| FHIR outbound (USCDI v3 data classes)                         | Write          | Per-patient                         | Interoperability propagation                                                      |
| HIE outbound (Carequality, CommonWell, eHealth Exchange)      | Write          | Per-patient                         | Cross-organization propagation                                                    |
| Patient-portal publisher (MyChart, Oracle Health, athenaPatient) | Write       | Per-patient                         | ONC Information Blocking surface                                                   |
| Consent gate (general HIPAA + 42 CFR Part 2 SUD)              | Read + Write   | Per-encounter                       | Statutory consent surface                                                         |
| HIPAA audit log writer                                        | Write          | Per-event                           | §164.312(b) audit-controls compliance                                             |
| Revenue-cycle claim assembler                                 | Read + Write   | Per-claim                           | False Claims Act exposure                                                         |
| Sentinel Event monitor                                        | Read           | Per-incident                        | Joint Commission accreditation                                                     |
| Vendor model retraining gate (BAA-scoped)                     | Read           | Per-vendor                          | BAA-scope discipline                                                              |

### 4.6 Sensitive data and policy constraints

* **Data classes:** PHI per HIPAA (the chart note, audio, transcript, prior chart, medication list, allergy list, problem list, lab and imaging results, billing codes, claim content); SUD records per 42 CFR Part 2; biometric data per state law (voiceprint when used for clinician identification); minor patient records under state-of-the-minor rules; behavioral-health records under state law.
* **Retention and logging:** audio retention per BAA (commonly delete-after-signoff or 30-90 days; longer retention drives privacy exposure); transcript retention per BAA; AI-drafted state retention for SOC 2 / OCR audit (commonly 6 years to align with HIPAA §164.530(j) policy retention); signed note retention per state law (commonly 7-10 years for adult records, longer for minors); audit log per HIPAA §164.312(b).
* **Regulatory constraints:** HIPAA Privacy / Security / Breach (45 CFR 164); HHS OCR HIPAA Cybersecurity Performance Goals (December 2023); FDA Clinical Decision Support exception 21 USC 360j(o)(1); FDA SaMD guidance; ONC Information Blocking 45 CFR Part 171; CMS Conditions of Participation 42 CFR 482.24; AMA Augmented Intelligence policy (2018, updated 2023); Joint Commission Record of Care standards; False Claims Act 31 USC 3729; 42 CFR Part 2; state two-party-consent recording statutes; state medical board AI policies; Stark Law and Anti-Kickback Statute on vendor relationships; EU AI Act Article 50 + Annex III §1 (for EU patients); GDPR Article 9 + Article 33 (for EU patients).
* **Output policy:** every AI-drafted note section cites the transcript span supporting it; billing-code suggestions cite the documented work supporting them; the AI identifies itself as AI-assisted in the audit trail; AI-drafted state is preserved before clinician signoff.

---

## 5. Operating modes

### 5.1 Manual baseline (no AI scribe)

The clinician documents in the EHR by typing or dictating to a deterministic dictation tool (Dragon Medical One historically; structured templates; SmartTexts in Epic). This was the baseline through approximately 2022 in most US health systems. Documentation burden is high; clinician burnout is high; the 30-day signoff window is met but with significant after-hours work.

**Risk profile:** lowest hallucination risk; bounded by clinician fatigue and typing speed. The note is what the clinician wrote.

### 5.2 Ambient capture with deterministic structured-template population (early ambient, 2022-2023)

The audio is captured and transcribed; structured fields (medication list, allergy list, problem list, vital signs) are populated by deterministic NLU; narrative sections are still typed by the clinician.

**Risk profile:** moderate; bounded by NLU misclassification on structured-field extraction.

### 5.3 Ambient capture with LLM-drafted narrative (the 2024-2026 default)

The audio is captured and transcribed; the LLM drafts the full note in the EHR-expected structure; the clinician reviews, edits, and signs. Microsoft Nuance DAX Copilot, Abridge, Suki, DeepScribe, Augmedix, and the EHR-vendor-native suites operate here.

**Risk profile:** high. Dominant surfaces are ASR hallucination (the Cornell Whisper finding), phantom encounter content from the LLM, billing-code suggestions unsupported by documentation, and review-fatigue under daily clinic load.

### 5.4 Ambient capture with LLM-drafted narrative and bounded-autonomy decision-support generation (the FDA CDS line)

The LLM additionally proposes differential diagnoses, prioritizes them, suggests treatment, calculates doses, or stages malignancy. This crosses the 21 USC 360j(o)(1) Clinical Decision Support exception line and operates as an FDA-regulated medical device requiring premarket review (510(k), De Novo, or PMA depending on classification).

**Risk profile:** highest. FDA premarket-review status determines whether the product can lawfully ship in the US for this scope.

### 5.5 Variants

Architectural variants teams reach for:

1. **In-vendor cloud versus health-system VPC.** In-vendor cloud (Microsoft DAX, Abridge SaaS) inherits the vendor's data-residency and BAA contract; health-system VPC (Azure or AWS deployed in the system's own subscription) inherits the system's own perimeter.
2. **Persistent audio retention versus delete-after-signoff.** Retention drives privacy exposure and litigation discovery; delete-after-signoff reduces both but limits vendor-model-improvement and post-hoc investigation.
3. **Per-clinician personalization versus global template.** Personalization improves note quality and clinician satisfaction; global templates improve auditability and reduce inter-clinician note-style variance.
4. **EHR-vendor-native versus best-of-breed.** Native (Epic-DAX) inherits the EHR vendor's interoperability; best-of-breed (Abridge, Suki, Augmedix) provides multi-EHR support.
5. **Whisper-based versus proprietary ASR.** Whisper has the documented Cornell hallucination finding but is widely deployed; proprietary ASR (Nuance, Azure Speech medical-tuned) has its own opaque error profile.
6. **Independent-review monitor.** A separately-developed monitor watches drafted notes for safety-critical-field hallucinations (medications, allergies, diagnoses) on a non-overlapping signal set.

---

## 6. Threat model overview (high-level)

### 6.1 Primary security and safety goals

* preserve clinical-content integrity in every drafted note (no hallucinated medication, allergy, diagnosis, or physical-exam finding)
* preserve cross-patient PHI isolation across encounters and tenants
* preserve patient-consent integrity for audio recording in two-party-consent states
* preserve billing-code accuracy to the documented work (False Claims Act exposure floor)
* preserve the FDA Clinical Decision Support exception boundary
* preserve 42 CFR Part 2 consent for SUD-record content
* preserve clinician authentication under 42 CFR 482.24 (every note signed by the clinician)
* preserve HIPAA Privacy, Security, and Breach Notification compliance
* preserve patient access integrity under ONC Information Blocking (no AI-hallucinated content surfaced through the patient portal)

### 6.2 Threat actors (who might attack or misuse)

* **Adversarial patients** intentionally injecting content into the encounter to manipulate the chart (rare but documented in legal-medicine literature)
* **External attackers** compromising the ambient-scribe vendor's cloud (the SaaS-vendor-breach pattern: see LastPass, Snowflake, Salesloft Drift class incidents)
* **Insider-threat clinicians** using the AI drafter to obscure attribution or to upcode for revenue
* **Compromised supplier** (Whisper or other open-source ASR component supply-chain compromise; LLM provider compromise)
* **Civil adversaries in malpractice discovery** seeking AI-drafted-then-signed notes that contain hallucinated content the clinician did not catch
* **State or federal regulators** investigating False Claims Act, HIPAA, FDA CDS, or ONC Information Blocking violations
* **Class-action plaintiffs** under state two-party-consent recording statutes
* **Researchers** disclosing in good faith via the AI Incident Database, ACM FAccT, and academic medical-informatics venues

### 6.3 Attack surfaces

* the audio-capture microphone and room audio (the SAFE-UC-0010 acoustic-channel parallel)
* the ASR pipeline (Whisper-class hallucinations)
* the LLM drafter prompt window and context
* the EHR write API
* the coding-suggestion service
* the cross-patient context retrieval
* the patient-portal publisher (Information Blocking surface)
* the FHIR outbound and HIE outbound paths
* the vendor's BAA-scoped retention and retraining store
* the MCP tool-description ingest

### 6.4 High-impact failures (include industry harms)

* **Patient harm:** hallucinated medication or allergy in the chart leading to a wrong-medication or contraindicated-medication event; phantom diagnosis driving an unnecessary procedure; missed real diagnosis when AI-summarized prior chart obscures key findings.
* **Business harm:** OCR HIPAA enforcement on a vendor breach (the 2024 Change Healthcare ALPHV breach exemplar; multi-billion-dollar impact); FCA exposure on AI-fabricated billing support; FDA enforcement on unregistered medical-device operation; ONC Information Blocking penalties (up to $1M per violation per day under the Cures Act); state-AG enforcement on consent violations; class-action exposure under state two-party-consent statutes (Garner v. Amazon class-cert framework applies symmetrically).
* **Operational harm:** clinician trust collapse leading to abandonment of the ambient-scribe deployment; documentation-burden return; revenue-cycle days-in-AR inflation if billing-code accuracy degrades.
* **Reputational harm:** publicly-disclosed AI-hallucinated note in a high-profile patient case; AP/ABC News-class story that becomes the canonical "AI in medicine went wrong" narrative; medical-board disciplinary action against a clinician who signed without catching.
* **Privacy harm:** PHI leakage through the vendor's cloud; cross-patient bleed in note generation; unauthorized retention of audio beyond BAA scope; voiceprint biometric retention without state-law-compliant consent.

---

## 7. Kill-chain analysis (stages → likely failure modes)

> Keep this defender-friendly. Describe patterns, not "how to do it."
>
> Note: this UC uses an **eight-stage kill chain** with **six stages flagged NOVEL**. Because this is the FIRST healthcare UC in the registry (no NAICS 62 cohort siblings), the novelty is documented against the closest workflow-shape sibling (SAFE-UC-0019 PIR drafting, where the AI's primary output IS regulated text) and the closest sensor-input sibling (SAFE-UC-0010 in-vehicle voice, where the microphone is the cyber-physical sensor). The novelty centers on ASR hallucination of clinical content, phantom encounter content, audio-capture consent under state two-party-consent law, False Claims Act exposure via AI-fabricated billing support, ONC Information Blocking exposure to the patient, and FDA SaMD scope creep. The remaining two stages (PHI cross-patient bleed and clinician-attestation review-fatigue) extend cohort patterns from SAFE-UC-0019 (review-fatigue) and SAFE-UC-0006 (multi-tenant context bleed).

| Stage                                                                                | What can go wrong (pattern)                                                                                                                                                                                                                                                                                | Likely impact                                                                                                            | Notes / preconditions                                                                                                                                          |
| ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1. Audio-capture consent under state two-party-consent law (**NOVEL: statutory-recording boundary**) | Recording starts before patient consent in a two-party-consent state (CA, FL, IL, MA, MI, MT, NV, NH, PA, WA); 42 CFR Part 2 SUD content captured without the heightened consent regime                                                                                                                  | state-AG enforcement; class-action under state recording statutes; 42 CFR Part 2 federal exposure                         | hard gate on recording start; consent record with timestamp; SUD-content detection feedback                                                                    |
| 2. ASR hallucination of clinical content (**NOVEL: Whisper-class generative hallucination at the ASR layer**) | The Cornell ACM FAccT June 2024 finding: Whisper hallucinated content in roughly 1% of medical-transcription test samples, including fabricated medications, racial commentary, and violent statements                                                                                                  | wrong-medication risk; charting harm; clinician-trust collapse                                                            | confidence signals on ASR output; secondary verification on safety-critical entities; source-span citation in drafted note                                    |
| 3. Phantom encounter content from the LLM (**NOVEL: drafter invents what was not discussed**) | LLM drafts plausible-sounding history, ROS, exam, or PMH content not actually discussed in the encounter                                                                                                                                                                                                  | clinically-misleading note; signed under review-fatigue; downstream decision-support based on phantom data                | source-span citation per note section; no-content-without-source policy on safety-critical sections                                                            |
| 4. PHI cross-patient bleed across encounters                                         | Multi-tenant vendor or per-clinician session-state failure surfaces patient A's content in patient B's note                                                                                                                                                                                                | HIPAA §164.502(a) breach; OCR enforcement; patient-trust collapse                                                         | per-encounter session ID; tenant-isolation enforcement at every layer; differential testing                                                                    |
| 5. Clinician-attestation review-fatigue                                              | Clinician signs note after a 25-patient day without catching hallucinated medication, allergy, diagnosis, or fabricated content; the §482.24 authentication goes through                                                                                                                                  | every downstream pipeline ingests the hallucination; FCA exposure if a code is supported only by the hallucination        | per-section confidence signals; safety-critical-field highlight; in-app diff against transcript span                                                            |
| 6. False Claims Act exposure via AI-fabricated billing support (**NOVEL: AI documentation supports a Medicare claim**) | AI suggests CPT or HCPCS codes (or modifiers) the clinician's actual work does not support; the bill is submitted to Medicare or Medicaid                                                                                                                                                                | treble damages plus per-claim civil penalties under 31 USC 3729; whistleblower qui tam exposure                            | revenue-cycle integrity review; named-coder signoff; documentation-versus-code match check                                                                    |
| 7. ONC Information Blocking exposure of AI-drafted hallucinations to the patient (**NOVEL: AI hallucination surfaces in MyChart**) | Signed note flows to the patient portal under 45 CFR Part 171; patient sees AI-hallucinated medication, allergy, or diagnosis content                                                                                                                                                                    | patient-trust collapse; complaint to OCR / state AG / AMA; potential malpractice exposure                                  | publication-delay window with clinician-final-review prompt; patient-portal-amendment workflow                                                                  |
| 8. FDA SaMD scope creep beyond the CDS exception (**NOVEL: ambient scribe crosses into clinical decision generation**) | The drafter generates differential-diagnosis prioritization, treatment-protocol selection, malignancy staging, or dose calculation; the four 21 USC 360j(o)(1) criteria no longer hold; the product operates as an unregistered medical device                                                          | FDA enforcement; product withdrawal; potential criminal exposure for misbranding under 21 USC 333                          | FDA-regulatory liaison gate before any feature crosses the CDS line; periodic CDS-exception scope audit                                                        |

---

## 8. SAFE‑MCP mapping (kill-chain → techniques → controls → tests)

Practitioners commonly map this workflow's failure patterns to the following SAFE‑MCP techniques. The mapping is directional: teams adapt it to their stack, threat model, regulatory regime, and clinical setting. Links in Appendix B resolve to the canonical technique pages.

**A note on framework gap.** SAFE-MCP today covers the LLM and MCP-tool surface well, but does not yet have first-class techniques for **ASR-layer generative hallucination of clinical content**, **state two-party-consent audio-recording boundary violations**, **False Claims Act exposure via AI-fabricated documentation**, **ONC Information Blocking exposure**, or **FDA SaMD scope creep**. The mapping below cites the closest anchors. SAFE-T2105 Disinformation Output is the umbrella for hallucinated clinical content; SAFE-T1110 Multimodal Prompt Injection covers the audio modality; SAFE-T2106 Context Memory Poisoning covers cross-patient bleed at the retrieval layer.

| Kill-chain stage                                                  | Failure / attack pattern (defender-friendly)                                                                                            | SAFE‑MCP technique(s)                                                                                                                                                                                              | Recommended controls (prevent / detect / recover)                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Tests (how to validate)                                                                                                                                                                                                                                                                                                                                                       |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Audio-capture consent under state law (**NOVEL gap**)            | Recording starts before patient consent in a two-party-consent state; 42 CFR Part 2 SUD content captured without heightened consent     | `SAFE-T1102` (Prompt Injection (Multiple Vectors)) when the consent gate is bypassed by injection; `SAFE-T1801` (Automated Data Harvesting) when retention exceeds consent. **Gap:** statutory recording-consent is not yet a first-class SAFE-MCP technique | hard gate on recording start; per-encounter consent record with timestamp; state-jurisdiction detection (geo and patient-address-of-record); 42 CFR Part 2 SUD-content classifier with consent-gate fallback                                                                                                                                                                                                                                                                                              | seeded two-party-consent-state fixtures; verify recording is blocked without consent record; SUD-content fixture; verify Part 2 consent gate fires                                                                                                                                                                                                                            |
| ASR hallucination of clinical content (**NOVEL gap**)            | Whisper-class hallucination of medication, allergy, diagnosis, racial commentary, or violent statement (the Cornell ACM FAccT finding) | `SAFE-T1110` (Multimodal Prompt Injection via Images/Audio); `SAFE-T2105` (Disinformation Output). **Gap:** ASR-layer generative hallucination of clinical content is not yet a first-class SAFE-MCP technique     | ASR confidence signals per token; secondary verification on safety-critical entities (medication NER cross-checked against RxNorm; allergy NER cross-checked against patient's allergy list); source-span citation in the drafted note; ASR-vendor-disclosure of model and version                                                                                                                                                                                                                          | seeded medical-transcription fixtures with known content; verify drafter does not hallucinate beyond the transcript; track hallucination rate against the Cornell ACM FAccT methodology                                                                                                                                                                                       |
| Phantom encounter content from the LLM (**NOVEL gap**)           | LLM drafts plausible-sounding history, ROS, exam, or PMH content not actually discussed in the encounter                                | `SAFE-T2105` (Disinformation Output); `SAFE-T1404` (Response Tampering). **Gap:** phantom encounter content in clinical drafting is not yet a first-class SAFE-MCP technique                                       | source-span citation per note section; no-content-without-source policy on safety-critical sections (medication, allergy, diagnosis, exam findings); the drafter explicitly emits "not discussed in this encounter" rather than fabricate; per-section confidence signals                                                                                                                                                                                                                                  | seeded encounter-transcript-with-known-omissions fixtures; verify drafter does not fabricate omitted sections; verify source-span coverage on every signed note                                                                                                                                                                                                              |
| PHI cross-patient bleed across encounters                         | Multi-tenant vendor or per-clinician session-state failure surfaces patient A's content in patient B's note                              | `SAFE-T1701` (Cross-Tool Contamination); `SAFE-T1702` (Shared-Memory Poisoning); `SAFE-T1307` (Confused Deputy Attack); `SAFE-T2106` (Context Memory Poisoning via Vector Store Contamination)                       | per-encounter session ID; tenant-isolation enforcement at every layer (storage, cache, vector store, prompt context); differential queries to detect cross-tenant or cross-encounter bleed; vendor BAA scope discipline                                                                                                                                                                                                                                                                                  | seeded two-patient-encounter fixture; verify patient B's note contains zero patient A content; differential bleed test in CI                                                                                                                                                                                                                                                  |
| Clinician-attestation review-fatigue                             | Clinician signs note after a long clinic day without catching hallucinated content                                                       | `SAFE-T1403` (Consent-Fatigue Exploit); `SAFE-T1404` (Response Tampering)                                                                                                                                          | per-section confidence signals; safety-critical-field highlight in the EHR review surface; in-app diff against transcript span; pre-sign-off prompt on novel-medication, novel-allergy, novel-diagnosis flags                                                                                                                                                                                                                                                                                              | usability test on long-day signing workflow; verify safety-critical highlights surface; verify diff prompt fires on novel content                                                                                                                                                                                                                                            |
| False Claims Act exposure via AI billing support (**NOVEL gap**) | AI suggests CPT or HCPCS codes (or modifiers) the clinician's documented work does not support; the bill is submitted                   | `SAFE-T1309` (Privileged Tool Invocation via Prompt Manipulation); `SAFE-T1404` (Response Tampering); `SAFE-T2105` (Disinformation Output). **Gap:** False Claims Act exposure via AI-fabricated documentation is not yet a first-class SAFE-MCP technique | revenue-cycle integrity review on AI-suggested codes; named-coder signoff; documentation-versus-code match check; high-FCA-risk-code allow-list with extra review; clinician-attestation that the work supports the code                                                                                                                                                                                                                                                                                  | seeded encounter-and-code-mismatch fixtures; verify revenue-cycle review catches; tabletop a qui tam scenario                                                                                                                                                                                                                                                                |
| ONC Information Blocking exposure of hallucinations (**NOVEL gap**) | Signed note flows to the patient portal; patient sees AI-hallucinated content                                                            | `SAFE-T2105` (Disinformation Output); `SAFE-T1404` (Response Tampering). **Gap:** Information Blocking exposure of AI-drafted content is not yet a first-class SAFE-MCP technique                                  | publication-delay window with clinician-final-review prompt; patient-portal-amendment workflow; provider-amendment process for patient-flagged inaccuracies; periodic patient-portal-published-note audit                                                                                                                                                                                                                                                                                                  | seeded note-with-known-hallucination fixture; verify publication delay catches; verify amendment workflow handles patient flags                                                                                                                                                                                                                                              |
| FDA SaMD scope creep beyond CDS exception (**NOVEL gap**)        | Drafter generates differential-diagnosis prioritization, treatment-protocol selection, dose calculation, or staging                     | `SAFE-T1309` (Privileged Tool Invocation via Prompt Manipulation); `SAFE-T1104` (Over-Privileged Tool Abuse); `SAFE-T1701` (Cross-Tool Contamination). **Gap:** FDA SaMD scope creep is not yet a first-class SAFE-MCP technique                            | FDA-regulatory liaison gate before any feature crosses the CDS line; periodic 21 USC 360j(o)(1) four-criteria audit; LLM-output-classifier for clinical-recommendation content; refusal pattern on direct treatment recommendations                                                                                                                                                                                                                                                                       | seeded clinical-decision-prompt fixtures; verify drafter refuses to generate treatment recommendations; verify CDS-exception four-criteria audit is current                                                                                                                                                                                                                  |

---

## 9. Controls and mitigations (organized)

### 9.1 Prevent (reduce likelihood)

* **Hard gate on audio recording without patient consent** in two-party-consent states; consent record with timestamp logged before recording starts.
* **42 CFR Part 2 consent gate** on substance-use-disorder content; SUD-content classifier with consent-gate fallback.
* **ASR confidence signals per token** plus secondary verification on safety-critical entities (medication NER cross-checked against RxNorm; allergy NER cross-checked against the patient's allergy list).
* **Source-span citation per note section** so every claim in the drafted note is traceable to a transcript span; **no-content-without-source policy** on safety-critical sections.
* **Per-encounter session ID** and **tenant-isolation enforcement at every layer** (storage, cache, vector store, prompt context).
* **Pre-sign-off prompt** on novel-medication, novel-allergy, novel-diagnosis flags; **in-app diff** against transcript span.
* **Revenue-cycle integrity review** on AI-suggested codes; named-coder signoff on high-FCA-risk codes.
* **Publication-delay window** before a signed note flows to the patient portal under ONC Information Blocking; clinician-final-review prompt during the delay.
* **FDA-regulatory liaison gate** before any product feature crosses the 21 USC 360j(o)(1) Clinical Decision Support exception line; periodic four-criteria audit.
* **LLM-output classifier** that detects clinical-recommendation content (differential-diagnosis prioritization, treatment-protocol selection, dose calculation, malignancy staging) and triggers refusal.
* **HIPAA Security Rule §164.312 technical safeguards** on the audio-capture-and-transcript pipeline (access controls, audit controls, integrity, authentication, transmission security).
* **Business Associate Agreement** with vendor scope discipline (PHI use, retention, deletion, breach notification, subcontractor flow-down).
* **Patient-amendment workflow** for patient-flagged inaccuracies in portal-published notes.
* **EU AI Act Article 50** transparency for EU patients; **42 CFR 482.24** clinician authentication on every signed note.

### 9.2 Detect (reduce time-to-detect)

* ASR hallucination rate against a held-out medical-transcription benchmark (the Cornell ACM FAccT methodology)
* phantom-encounter-content rate against seeded omission fixtures
* cross-patient PHI bleed rate (should be zero)
* safety-critical-field-highlight enforcement rate
* novel-medication / allergy / diagnosis prompt rate at sign-off
* billing-code-versus-documentation match rate
* AI-suggested-code revenue-cycle-review pass rate
* ONC Information Blocking publication-delay enforcement rate
* patient-portal amendment-request rate by category
* FDA CDS-exception four-criteria audit cadence
* HIPAA §164.312 audit-log integrity rate
* vendor BAA-breach-notification SLA adherence
* clinician note-amendment-after-signoff rate (a leading hallucination indicator)

### 9.3 Recover (reduce blast radius)

* incident-response playbook for an inferred or confirmed ASR hallucination causing patient harm (Sentinel Event reporting; root-cause analysis aligned with Joint Commission RC standards)
* incident-response playbook for an inferred or confirmed cross-patient PHI bleed (HIPAA breach-notification workflow per §164.412; OCR pre-notification)
* incident-response playbook for an inferred or confirmed False Claims Act exposure (compliance-officer escalation; voluntary self-disclosure under DOJ guidance)
* incident-response playbook for an inferred or confirmed ONC Information Blocking violation (CMS pre-notification; provider-amendment workflow)
* incident-response playbook for an inferred or confirmed FDA SaMD scope creep (FDA pre-submission; product-feature withdrawal; counsel)
* incident-response playbook for a vendor BAA breach (CE notification; OCR notification; patient notification per §164.404)
* coordinated-disclosure path through the HHS OCR, AI Incident Database, and ACM FAccT for hallucination patterns
* malpractice-litigation-discovery preparation: AI-drafted state preservation; clinician-attestation audit; patient-amendment history

---

## 10. Validation and testing plan

### 10.1 What to test (minimum set)

* **Audio-capture consent gate** in two-party-consent states.
* **42 CFR Part 2 consent gate** on SUD-content.
* **ASR hallucination rate** against the Cornell ACM FAccT methodology baseline.
* **Phantom encounter content rate** against seeded omission fixtures.
* **Cross-patient PHI bleed** in CI differential testing.
* **Source-span citation coverage** on every signed note.
* **Safety-critical-field highlight** enforcement at clinician review.
* **Billing-code-versus-documentation match** check.
* **ONC Information Blocking publication-delay** enforcement.
* **FDA CDS-exception four-criteria audit** currency.
* **HIPAA §164.312 technical safeguards** continuous demonstration.
* **EU AI Act Article 50 transparency** for EU patients.
* **42 CFR 482.24 authentication** on every signed note.

### 10.2 Test cases (make them concrete)

| Test name                                              | Setup                                                                | Input / scenario                                                                                                              | Expected outcome                                                                                                                                       | Evidence produced                                              |
| ------------------------------------------------------ | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| Two-party-consent audio gate                           | Encounter in California (Penal Code §632 jurisdiction)                | recording attempted without patient consent                                                                                   | hard gate blocks recording start; consent record absent; audit captures attempt                                                                       | consent-gate log + audit                                        |
| 42 CFR Part 2 SUD-content gate                         | Encounter with SUD-content in transcript                              | drafter assembles note                                                                                                        | SUD-content classifier fires; Part 2 consent gate enforced; drafter does not include SUD content without heightened consent                            | SUD-classifier log + consent-gate log                          |
| ASR hallucination benchmark                            | Cornell ACM FAccT-aligned medical-transcription test set              | ASR pipeline transcribes                                                                                                      | hallucination rate is at or near zero; safety-critical entities (medication, allergy, diagnosis) are verified                                          | hallucination-rate report                                       |
| Phantom encounter content fixture                      | Encounter transcript with deliberately omitted ROS section            | drafter assembles note                                                                                                        | drafter emits "not discussed in this encounter" or omits the section; does not fabricate                                                              | source-span coverage report                                     |
| Cross-patient PHI bleed                                | Two synthetic patient encounters in adjacent sessions                 | patient B's note generation                                                                                                   | zero patient A content in patient B's note; per-encounter session ID enforced; differential bleed test passes                                         | bleed-test log                                                  |
| Safety-critical highlight                              | Drafted note with novel medication                                    | clinician review surface                                                                                                      | novel-medication highlighted; pre-sign-off prompt fires; in-app diff against transcript span                                                          | review-surface log                                              |
| Billing-code mismatch                                  | Drafted note + AI-suggested code unsupported by documentation         | revenue-cycle review                                                                                                          | mismatch flagged; named-coder signoff blocked until documentation supports code                                                                        | revenue-cycle review log                                        |
| ONC Information Blocking publication delay             | Signed note with potentially-inaccurate content                       | publication pipeline                                                                                                          | publication-delay window honored; clinician-final-review prompt fires before publication                                                              | publication-pipeline log                                        |
| FDA CDS-exception four-criteria audit                  | Production product feature set                                        | quarterly review                                                                                                              | each of the four §360j(o)(1) criteria documented as currently satisfied; any feature crossing the line surfaces with FDA-regulatory liaison signoff   | CDS-exception audit                                             |
| HIPAA §164.312 audit-log integrity                     | Production audit-log pipeline                                         | continuous monitoring                                                                                                          | audit logs are tamper-evident, time-synchronized, and complete per §164.312(b)                                                                        | audit-log integrity report                                      |
| Patient-portal amendment workflow                      | Patient flags inaccuracy in MyChart                                   | amendment-request workflow                                                                                                    | provider-amendment process fires; patient acknowledged; chart amended per state law                                                                   | amendment-workflow log                                          |
| Sentinel Event                                          | Documentation-error harm event                                        | RCA process                                                                                                                   | Joint Commission Sentinel Event reporting completed; RC standards root-cause analysis documented                                                      | Sentinel Event report                                           |
| EU AI Act Article 50                                   | EU patient encounter                                                  | first-touch with the drafter                                                                                                  | drafter identifies as AI-assisted per Article 50                                                                                                      | first-interaction audit                                         |

### 10.3 Operational monitoring (production)

* ASR hallucination rate per ASR vendor and version
* phantom-encounter-content rate
* cross-patient PHI bleed rate (target zero)
* source-span citation coverage rate
* novel-medication / allergy / diagnosis prompt rate
* billing-code-versus-documentation match rate
* AI-suggested-code revenue-cycle-review pass rate
* ONC Information Blocking publication-delay enforcement rate
* patient-portal amendment-request rate
* FDA CDS-exception scope-creep monitoring
* HIPAA §164.312 audit-log integrity rate
* vendor BAA-breach SLA adherence
* clinician note-amendment-after-signoff rate (a leading hallucination indicator)
* Sentinel Event reporting cadence

---

## 11. Open questions and TODOs

- [ ] Define the health system's hallucination-rate benchmark per ASR vendor and version, aligned with the Cornell ACM FAccT methodology.
- [ ] Define the source-span citation policy per note section, with stricter enforcement on safety-critical sections (medication, allergy, diagnosis, physical exam).
- [ ] Define the per-encounter session-ID model and the cross-tenant isolation enforcement contract with the vendor.
- [ ] Define the consent-record schema for two-party-consent states; map state jurisdictions to consent obligations.
- [ ] Define the 42 CFR Part 2 SUD-content classifier and the consent-gate fallback.
- [ ] Define the safety-critical-field highlight UX and the pre-sign-off prompt contract.
- [ ] Define the high-FCA-risk-code allow-list and the named-coder signoff contract.
- [ ] Define the ONC Information Blocking publication-delay window and the clinician-final-review prompt contract.
- [ ] Define the FDA CDS-exception four-criteria audit cadence and the FDA-regulatory liaison signoff path.
- [ ] Document the BAA scope discipline for vendor model retraining (deidentified versus identified PHI; subcontractor flow-down).
- [ ] Map regulator-notification SLAs (HHS OCR for HIPAA, CMS for Information Blocking, FDA for SaMD, state AGs for consent, DOJ for FCA, FTC for general consumer protection).
- [ ] Define the AI Incident Database coordinated-disclosure path for hallucination patterns observed.

---

## 12. Questionnaire prompts (for reviewers)

### Workflow realism

* Are the integrations (Microsoft DAX, Abridge, Suki, DeepScribe, Augmedix, EHR vendor native, Whisper-based ASR or proprietary, FHIR R4, HIE outbound, patient portal) realistic for the health system's stack?
* Does the workflow distinguish ambient drafting from clinical decision generation (the FDA CDS-exception line)?
* Is the AI's role bounded to drafting and coding suggestion, with clinician-attestation on every signed note?

### Trust boundaries and permissions

* Is the FDA CDS-exception four-criteria audit current?
* Is per-encounter session ID enforced; is tenant-isolation differential testing in CI?
* Is the BAA scope for vendor model retraining documented and audited?
* Is patient consent for audio recording obtained and recorded for every two-party-consent-state encounter?

### Output safety and persistence

* Are source-span citations generated per note section?
* Are safety-critical fields (medication, allergy, diagnosis) verified against authoritative sources?
* Is the AI-drafted state preserved in the audit trail before clinician signoff?

### Sensitive-data discipline

* Is HIPAA §164.312 technical safeguards demonstrated continuously?
* Is 42 CFR Part 2 SUD-content handling implemented?
* Is the patient-portal-amendment workflow live for patient-flagged inaccuracies?

### Regulatory integrity

* Is the Joint Commission Sentinel Event reporting cadence met for documentation-error harm?
* Is the False Claims Act exposure surface measured and bounded?
* Is the AMA Augmented Intelligence policy reflected in clinician-of-record attestation discipline?
* Is ONC Information Blocking publication-delay enforced?

### Operations

* Success metrics: clinician documentation-time reduction, note-completion-time reduction, days-in-AR reduction, clinician-satisfaction signal, patient-portal note-amendment rate at acceptable level
* Danger metrics: ASR hallucination rate, phantom-encounter content rate, cross-patient PHI bleed rate, billing-code mismatch rate, novel-medication / allergy / diagnosis pre-sign-off prompt acceptance rate, FDA CDS-exception scope-creep events
* Who owns the kill switch on the ambient-capture pipeline and the publication-delay gate?

---

## Appendix A: Contributors and Version History

* **Authoring:** Astha (DSO contributor, 2026-05-09)
* **Initial draft:** 2026-05-09 (new ID; first NAICS 62 healthcare UC in registry)

| Version | Date       | Changes                                                                                                                                                                                                                                                                                                                                                                                  | Author |
| ------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 1.0     | 2026-05-09 | Initial documentation of `SAFE-UC-0035` from new-ID reservation to full draft. First healthcare (NAICS 62) UC in the registry. 8-stage kill chain with 6 stages flagged NOVEL versus closest cohort siblings (SAFE-UC-0019 PIR drafting and SAFE-UC-0010 in-vehicle voice). 18 SAFE-MCP techniques across 8 stages with explicit framework-gap notes. 6-subsection Appendix B.       | Astha  |

---

## Appendix B: References & frameworks

### B.1 SAFE-MCP techniques referenced in this use case

* [SAFE-T1001 Tool Poisoning Attack (TPA)](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1001/README.md)
* [SAFE-T1002 Supply Chain Compromise](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1002/README.md)
* [SAFE-T1102 Prompt Injection (Multiple Vectors)](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1102/README.md)
* [SAFE-T1104 Over-Privileged Tool Abuse](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1104/README.md)
* [SAFE-T1110 Multimodal Prompt Injection via Images/Audio](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1110/README.md)
* [SAFE-T1304 Credential Relay Chain](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1304/README.md)
* [SAFE-T1307 Confused Deputy Attack](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1307/README.md)
* [SAFE-T1309 Privileged Tool Invocation via Prompt Manipulation](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1309/README.md)
* [SAFE-T1402 Instruction Stenography - Tool Metadata Poisoning](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1402/README.md) (the title preserves the verbatim "Stenography" typo from the SAFE-MCP source; the body uses the correct "steganography")
* [SAFE-T1403 Consent-Fatigue Exploit](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1403/README.md)
* [SAFE-T1404 Response Tampering](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1404/README.md)
* [SAFE-T1502 File-Based Credential Harvest](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1502/README.md)
* [SAFE-T1503 Env-Var Scraping](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1503/README.md)
* [SAFE-T1701 Cross-Tool Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1701/README.md)
* [SAFE-T1702 Shared-Memory Poisoning](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1702/README.md)
* [SAFE-T1801 Automated Data Harvesting](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T1801/README.md)
* [SAFE-T2105 Disinformation Output](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2105/README.md)
* [SAFE-T2106 Context Memory Poisoning via Vector Store Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2106/README.md)

### B.2 Industry and AI-specific frameworks teams commonly consult

* [NIST AI Risk Management Framework 1.0 (AI 100-1, January 2023)](https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf)
* [NIST AI 600-1 Generative AI Profile (July 2024)](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)
* [NIST SP 800-218A SSDF Generative AI Profile (July 2024)](https://csrc.nist.gov/pubs/sp/800/218/a/final)
* [NIST SP 800-66 Rev 2 Implementing the HIPAA Security Rule (February 2024)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-66r2.pdf)
* [Regulation (EU) 2024/1689 (EU AI Act; Article 50 transparency, Annex III biometric ID)](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
* [ISO/IEC 42001:2023 Artificial Intelligence Management System](https://www.iso.org/standard/81230.html)
* [ISO/IEC 23894:2023 AI Risk Management](https://www.iso.org/standard/77304.html)
* [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)
* [MITRE ATLAS adversarial threat landscape for AI systems](https://atlas.mitre.org/)

### B.3 Public incidents, disclosures, and case studies adjacent to this workflow

* [Cornell University: Careless Whisper, Speech-to-Text Hallucination Harms (Koenecke et al., arXiv preprint; presented at ACM FAccT June 2024)](https://arxiv.org/abs/2402.08021)
* [Associated Press: Researchers say AI transcription tool used in hospitals invents things no one ever said (26 October 2024)](https://apnews.com/article/ai-artificial-intelligence-health-business-90020cdf5fa16c79ca2e5b6c4c9bbb14)
* [AI Incident Database (the canonical public incident catalog for AI-system harms; relevant to medical-scribe hallucination patterns)](https://incidentdatabase.ai/)
* [HHS Office for Civil Rights Breach Portal (the public-disclosure database for HIPAA breaches affecting 500 or more)](https://ocrportal.hhs.gov/ocr/breach/breach_report.jsf)

### B.4 Domain-regulatory references

* [HIPAA Privacy Rule (45 CFR Part 164 Subpart E; HHS canonical reference)](https://www.hhs.gov/hipaa/for-professionals/privacy/index.html)
* [HIPAA Security Rule (45 CFR Part 164 Subpart C; HHS canonical reference)](https://www.hhs.gov/hipaa/for-professionals/security/index.html)
* [HIPAA Breach Notification Rule (45 CFR 164.400 to 164.414; HHS canonical reference)](https://www.hhs.gov/hipaa/for-professionals/breach-notification/index.html)
* [HHS OCR: Healthcare and Public Health Sector Cybersecurity Performance Goals (released December 2023)](https://hphcyber.hhs.gov/performance-goals.html)
* [21st Century Cures Act, Section 3060 amending FDC Act 21 USC 360j(o); the Clinical Decision Support exception](https://www.law.cornell.edu/uscode/text/21/360j)
* [FDA Clinical Decision Support Software final guidance (September 2022)](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/clinical-decision-support-software)
* [FDA Software as a Medical Device (SaMD) program overview](https://www.fda.gov/medical-devices/digital-health-center-excellence/software-medical-device-samd)
* [ONC Information Blocking Rule (45 CFR Part 171; ASTP canonical reference)](https://www.healthit.gov/topic/information-blocking)
* [CMS Conditions of Participation for Hospitals, Medical Record Services (42 CFR 482.24)](https://www.ecfr.gov/current/title-42/chapter-IV/subchapter-G/part-482/subpart-C/section-482.24)
* [42 CFR Part 2 Confidentiality of Substance Use Disorder Patient Records](https://www.ecfr.gov/current/title-42/chapter-I/subchapter-A/part-2)
* [False Claims Act (31 USC 3729 to 3733; Cornell LII)](https://www.law.cornell.edu/uscode/text/31/chapter-37/subchapter-III)
* [California Penal Code 632 (two-party consent recording statute; canonical example of state two-party regimes; CA Legislative Information)](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=PEN&sectionNum=632.)
* [Federal Wiretap Act (18 USC 2510 to 2523; Cornell LII)](https://www.law.cornell.edu/uscode/text/18/part-I/chapter-119)

### B.5 Industry safety, clinical governance, and informatics frameworks

* [American Medical Association: Augmented Intelligence in Health Care policy (adopted 2018; updated 2023)](https://www.ama-assn.org/practice-management/digital/augmented-intelligence-ai)
* [Joint Commission: Standards FAQs (Record of Care, Treatment, and Services; the operative accreditation standards on medical record content)](https://www.jointcommission.org/standards/standard-faqs/)
* [HL7 FHIR (Fast Healthcare Interoperability Resources; the canonical health-IT interoperability standard)](https://www.hl7.org/fhir/)
* [Office of the National Coordinator (now ASTP, Assistant Secretary for Technology Policy): canonical health-IT policy reference](https://www.healthit.gov/)
* [USCDI v3 (United States Core Data for Interoperability; the data-class baseline for FHIR-based interoperability)](https://www.healthit.gov/isa/united-states-core-data-interoperability-uscdi)
* [National Academy of Medicine: Artificial Intelligence in Health Care, The Hope, the Hype, the Promise, the Peril (2019)](https://nam.edu/artificial-intelligence-special-publication/)
* [NIST SP 800-66 Rev 2 Implementing the HIPAA Security Rule (February 2024)](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-66r2.pdf)

### B.6 Vendor product patterns (illustrative; not endorsements)

* [Microsoft Nuance Dragon Ambient eXperience (DAX) Copilot](https://www.nuance.com/healthcare/ambient-clinical-intelligence.html)
* [Microsoft: DAX Copilot generally available across Microsoft 365 (announcement; January 2024)](https://www.microsoft.com/en-us/industry/blog/healthcare/2024/01/17/dax-copilot-is-now-generally-available-with-new-features-to-help-healthcare-organizations-improve-the-patient-and-clinician-experience/)
* [Abridge: company website (Series E announced February 2025)](https://www.abridge.com/)
* [Suki AI: voice-enabled AI assistant for clinical documentation](https://www.suki.ai/)
* [DeepScribe: ambient AI medical scribe](https://www.deepscribe.ai/)
* [Augmedix: ambient automation for clinicians](https://www.augmedix.com/)
* [Ambience Healthcare: AI-driven documentation and revenue cycle](https://www.ambiencehealthcare.com/)
* [Doximity: Doximity GPT for clinicians](https://www.doximity.com/dialer/dialerai)
* [Oracle Health: Clinical Digital Assistant](https://www.oracle.com/health/clinical-suite/clinical-digital-assistant/)
* [Athenahealth: ambient documentation features](https://www.athenahealth.com/products/ambient-notes)
* [Epic: ambient and AI capabilities through DAX integration](https://www.epic.com/)
* [OpenAI Whisper (the open-source ASR system referenced in the Cornell ACM FAccT findings)](https://github.com/openai/whisper)
