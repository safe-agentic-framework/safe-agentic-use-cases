# Digital dispute / chargeback intake assistant

> **SAFE‑AUCA industry reference guide (draft)**
>
> This use case describes a workflow at the intersection of consumer financial protection and AI: AI-assisted intake of disputes and chargebacks at issuing banks, credit unions, fintechs, neobanks, and BNPL providers. The AI conducts the claim-narrative interview, classifies the dispute reason code, collects supporting evidence, performs Reg E §1005.11 and Reg Z §1026.13 narrow-grounds analysis, drafts provisional-credit decisions within statutory timing windows, packages the case for representment to the card network, and drafts customer communications. SAFE-UC-0011 (Banking virtual assistant) covers real-time customer interaction; this use case covers post-transaction investigation and adjudication, which has its own statutory timing regime and its own emerging failure surface.
>
> A defining feature of this workflow as of 2026: the AI on the issuer side is being asked to evaluate AI output produced by counterparties on both sides of the dispute. AppZen reported in late 2025 that approximately 14 percent of fraud documents submitted in September 2025 were AI-generated, compared with essentially none in 2024, and that more than 3.5 million fake receipts were created on the top four expense-fraud sites in a six-month window. The cardholder side and the merchant representment side are both producing AI-generated artifacts that the issuer's AI is asked to adjudicate, while the issuer's own statutory timing windows continue to run.
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
| **SAFE Use Case ID** | `SAFE-UC-0014`                                                         |
| **Status**           | `draft`                                                                |
| **Maturity**         | draft                                                                  |
| **NAICS 2022**       | `52` (Finance and Insurance), `522` (Credit Intermediation and Related Activities), `5223` (Activities Related to Credit Intermediation, including dispute servicing) |
| **Last updated**     | `2026-04-25`                                                           |

### Evidence (public links)

* [CFPB Issue Spotlight: "Chatbots in Consumer Finance" (June 2023; the load-bearing supervisory voice on AI in consumer-finance dispute intake)](https://www.consumerfinance.gov/about-us/newsroom/cfpb-issue-spotlight-analyzes-artificial-intelligence-chatbots-in-banking/)
* [CFPB and OCC Fine Bank of America $225 Million Over Botched Disbursement of State Unemployment Benefits (14 July 2022; "implemented a fraud filter with a simple set of flags that automatically triggered an account freeze" and "retroactively applied its fraud filter to deny some notices of error")](https://www.consumerfinance.gov/about-us/newsroom/federal-regulators-fine-bank-of-america-225-million-over-botched-disbursement-of-state-unemployment-benefits-at-height-of-pandemic/)
* [CFPB Orders Wells Fargo to Pay $3.7 Billion for Widespread Mismanagement of Auto Loans, Mortgages, and Deposit Accounts (20 December 2022; over 16 million affected consumer accounts)](https://www.consumerfinance.gov/about-us/newsroom/cfpb-orders-wells-fargo-to-pay-37-billion-for-widespread-mismanagement-of-auto-loans-mortgages-and-deposit-accounts/)
* [CFPB Takes Action Against Bank of America for Illegally Charging Junk Fees, Withholding Credit Card Rewards, and Opening Fake Accounts (11 July 2023; over $250M total)](https://www.consumerfinance.gov/about-us/newsroom/bank-of-america-for-illegally-charging-junk-fees-withholding-credit-card-rewards-opening-fake-accounts/)
* [CFPB Action to Require Citizens Bank to Pay $9 Million Penalty for Unlawful Credit Card Servicing (complaint filed 30 January 2020; Reg Z §1026.13 violations including "automatically denying such claims for failure to return a fraud affidavit")](https://www.consumerfinance.gov/enforcement/actions/citizens-bank/)
* [CFPB Supervisory Highlights, Issue 37 (Winter 2024; Reg E §1005.11 error-resolution findings)](https://files.consumerfinance.gov/f/documents/cfpb_Supervisory-Highlights-Issue-37_Winter-2024.pdf)
* [12 CFR §1005.11 Procedures for Resolving Errors (Reg E; 60-day cardholder notice; 10 business days investigate or provisional credit; 45 days complete; 90 days for new accounts and POS / foreign per (c)(3))](https://www.ecfr.gov/current/title-12/chapter-X/part-1005/subpart-A/section-1005.11)
* [12 CFR §1026.13 Billing Error Resolution (Reg Z; 60-day cardholder notice; 30 days to acknowledge; 2 complete billing cycles or 90 days to resolve)](https://www.ecfr.gov/current/title-12/chapter-X/part-1026/subpart-B/section-1026.13)
* [U.S. Treasury Releases Two New Resources to Guide AI Use in the Financial Sector (19 February 2026; the Financial Services AI Risk Management Framework with 230 control objectives across governance, data, model development, validation, monitoring, third-party risk, and consumer protection)](https://home.treasury.gov/news/press-releases/sb0401)
* [Visa Compelling Evidence 3.0 Merchant Readiness Guide (March 2023; reason code 10.4 effective 15 April 2023)](https://usa.visa.com/content/dam/VCOM/regional/na/us/support-legal/documents/compelling-evidence-3.0-merchant-readiness-mar2023.pdf)
* [AppZen: The Invisible Threat, Detecting AI-Generated Fake Receipts (2025; 14% of fraudulent documents in September 2025, up from essentially none in 2024; 3.5M+ fake receipts on top four expense-fraud sites in six months)](https://www.appzen.com/resources/ai-generated-fake-receipts)
* [Visa Acquirer Monitoring Program 2025 Fact Sheet (Above Standard ≥0.5%, Excessive ≥0.7%; merchant 2.2% from June 2025 phasing to 1.5% effective 1 April 2026)](https://corporate.visa.com/content/dam/VCOM/corporate/visa-perspectives/security-and-trust/documents/visa-acquirer-monitoring-program-fact-sheet-2025.pdf)

---

## Minimum viable write-up (Seed → Draft fast path)

This document covers:

* Executive summary
* Industry context and constraints
* Workflow and scope
* Architecture (tools, trust boundaries, inputs)
* Operating modes
* Kill-chain table (7 stages)
* SAFE‑MCP mapping table (18 techniques)
* Contributors and Version History

---

## 1. Executive summary (what + why)

**What this workflow does.**
A **digital dispute / chargeback intake assistant** is an AI-assisted system used by issuing banks, credit unions, fintechs, neobanks, and BNPL providers to receive consumer disputes, classify them by reason code, collect and evaluate supporting evidence, perform Reg E §1005.11 and Reg Z §1026.13 narrow-grounds analysis, draft provisional-credit decisions within statutory timing windows, package representment cases for the card network (Visa, Mastercard, American Express, Discover), and draft customer communications. Typical capabilities include:

* claim-narrative intake interview through mobile app, web portal, chat, or voice IVR
* dispute reason-code classification (unauthorized vs. billing error vs. service-not-rendered vs. quality dispute vs. first-party misuse)
* evidence collection (receipts, screenshots, location data, IP context, dashcam frames where relevant)
* AI-generated-evidence detection (AppZen reported in 2025 that approximately 14 percent of fraud documents submitted in September 2025 were AI-generated, up from essentially none in 2024)
* provisional-credit decisioning under Reg E §1005.11 (10-business-day or provisional-credit trigger) and under Reg Z §1026.13
* representment packaging (Visa Compelling Evidence 3.0, Mastercard Mastercom, American Express MOC, Discover ops regs)
* customer communication drafting (acknowledgment, status update, denial, resolution)
* furnishing-back to credit bureaus when a dispute outcome flips a previously-furnished tradeline (FCRA §1681s-2 furnisher accuracy obligations)

Industry deployments span issuer-side platforms (Visa Resolve Online, Mastercard Mastercom, American Express dispute system, Discover dispute system), bank dispute-intake products at Bank of America, JPMorgan Chase, Wells Fargo, Capital One, Citi, U.S. Bank, PNC, and Truist, fintech dispute intake at Square / Block, Stripe, Adyen, Affirm, Klarna, Afterpay, and PayPal, vendor decisioning AI from Verifi (a Visa subsidiary), Ethoca (a Mastercard subsidiary), Justt, Chargeflow (which raised a $35M Series A in November 2025 and serves over 15,000 merchants), Chargebacks911, and Disputifier, and issuer dispute-decisioning platforms from Featurespace, BioCatch, Sift, and Forter.

**Why it matters (business value).**
Dispute volume is large and growing. Mastercard projects industry chargeback costs to reach $42 billion by 2028. The Chargebacks911 2024 Field Report cited an average 18 percent friendly-fraud increase over three years and noted that as much as 70 percent of all credit-card fraud can be traced to chargeback misuse (also called friendly fraud or first-party misuse). Issuer call-center and back-office dispute-handling capacity has not scaled with that volume; AI-assisted intake and decisioning is now the operational answer at most large U.S. and EU issuers.

**Why it's risky / what can go wrong.**
Three concurrent forces define this workflow's risk surface, and none of them resolve cleanly.

First, **the consumer-protection regime is statutory, time-bounded, and enforced.** Reg E §1005.11 and Reg Z §1026.13 set hard timing windows: 60-day cardholder notice, 10 business days to investigate or issue provisional credit under Reg E (45 days to complete; 90 days under §1005.11(c)(3) for new accounts, point-of-sale, or foreign-initiated transactions), 30 days to acknowledge under Reg Z, 2 complete billing cycles or 90 days to resolve under Reg Z. Auto-denial without genuine investigation is the central CFPB enforcement vector. The CFPB and OCC fined Bank of America $225 million on 14 July 2022 for using an automated fraud filter as the basis for denying Reg E error notices on prepaid unemployment cards; CFPB's verbatim language was that the bank "implemented a fraud filter with a simple set of flags that automatically triggered an account freeze" and "retroactively applied its fraud filter to deny some notices of error." That is the AI-driven Reg E auto-denial precedent in regulator language. CFPB's $3.7 billion order against Wells Fargo on 20 December 2022 (over 16 million affected consumer accounts) cited dispute-investigation failures among multiple causes; the $250 million BofA order on 11 July 2023 cited junk fees and dispute mishandling; the $9 million Citizens Bank order (complaint filed 30 January 2020) cited Reg Z §1026.13 violations including "automatically denying such claims for failure to return a fraud affidavit signed under penalty of perjury." The CFPB's June 2023 Chatbots in Consumer Finance Issue Spotlight is the supervisory anchor.

Second, **the evidence the AI is asked to adjudicate is increasingly AI-generated.** The AppZen 14-percent figure for September 2025 represents an order-of-magnitude shift in twelve months. Cardholders submit AI-generated receipts, screenshots, and narrative claims; merchants submit AI-generated representment narratives produced by vendors like Justt and Chargeflow that explicitly market dynamic-arguments and automated representment. The issuer's AI is being asked to detect AI fabrication adversarially while drafting its own AI-generated content (decisions, customer comms, representment packages). This is a registry-first composition; SAFE-MCP today does not have a first-class technique for "adjudication on AI-generated artifacts," and §8 flags the gap honestly.

Third, **the friendly-fraud classifier is a fairness-failure surface.** Issuers run first-party-misuse models to flag disputes likely to be illegitimate. A poorly-trained or biased classifier disproportionately denies legitimate first-time disputes, particularly from cohorts whose dispute patterns differ from training data. The harm runs through Reg E (improper denial), through FCRA furnishing (the denied dispute can affect credit reporting), and back to ECOA / Reg B as a fair-lending analog (a denied dispute that lowers a credit score can shape later credit decisions). The April 2026 CFPB final rule narrowed Reg B disparate-impact territory, but state attorneys general and class-action plaintiffs continue to view dispute-approval-rate disparities as a UDAAP and unfair-discrimination surface.

The CFPB Ejudicate ban (October 2024), banning a private dispute-resolution platform from arbitrating consumer financial product disputes, is a signal that AI-decisioning vendors that act as adjudicators will be examined as adjudicators, not as platforms. The U.S. Treasury released its Financial Services AI Risk Management Framework on 19 February 2026 with 230 control objectives across governance, data, model development, validation, monitoring, third-party risk, and consumer protection; the framework names dispute-decisioning as an in-scope use case.

A defining inversion versus SAFE-UC-0011 (banking virtual assistant) is **the regulator-anchored statutory timing regime.** SAFE-UC-0011's primary failure modes involve real-time customer interaction (impersonation, step-up bypass, hallucinated rate quotes). SAFE-UC-0014's primary failure modes involve clock-driven adjudication: every minute the AI is wrong is a minute against the §1005.11 or §1026.13 statutory window, and CFPB enforcement has repeatedly turned on that timing. Auto-denial is not just a quality issue. Auto-denial is the harm.

---

## 2. Industry context & constraints (reference-guide lens)

### Where this shows up

Common in:

* large U.S. retail banks and credit unions running mobile-app and web-portal dispute intake at scale
* neobanks and fintechs (Chime, Varo, Current, Cash App / Block, SoFi) running entirely digital dispute flows
* card networks (Visa, Mastercard, American Express, Discover) running issuer-and-acquirer-facing dispute platforms (Visa Resolve Online with VCR; Mastercard Mastercom)
* network-affiliated AI vendors (Verifi for Visa CE 3.0, Ethoca for Mastercard alerts and Consumer Clarity)
* merchant-side representment AI (Justt, Chargeflow, Chargebacks911, Disputifier, Verifi RDR / Order Insight, Ethoca alerts)
* BNPL providers running dispute-and-refund flows that interact with both card-network rules and consumer-credit law
* PSPs and acquirers (Stripe, Adyen, Square, PayPal) running dispute-evidence APIs that issuers and merchants both consume
* issuer-side fraud-and-dispute decisioning vendors (Featurespace, BioCatch, Sift, Forter)
* third-party arbitration / dispute-resolution platforms (the CFPB Ejudicate ban is the cautionary precedent for these)

### Typical systems

* **conversational front ends:** mobile-app dispute intake, web-portal dispute intake, voice IVR for call-center handoff
* **case management:** dispute-and-case-management systems (issuer-side), with statutory-clock fields per case
* **decisioning:** rule-and-model-based fraud and friendly-fraud classifiers (issuer-side), Reg E narrow-grounds reasoning, Reg Z billing-error resolution
* **evidence intake:** PDF, image, and video upload pipelines; OCR and multimodal vision; AI-fabrication detection
* **representment packaging:** Visa CE 3.0 eligibility checks, Mastercard Mastercom workflows, Amex MOC, Discover ops regs
* **regulator-and-disclosure-facing:** Reg E §1005.7 disclosure tooling, Reg Z §1026.6 disclosure tooling, FCRA §1681s-2 furnisher pipelines
* **AI/ML:** LLM claim-narrative interviewers, LLM dispute-summary drafters, vector retrieval over prior-disputes corpora, friendly-fraud classifier, AI-fabricated-evidence detector, AI-drafted customer communications

### Constraints that matter

* **Reg E §1005.11 and Reg Z §1026.13 timing windows.** 60-day cardholder notice, 10-business-day investigation or provisional credit, 45-day completion, 90-day extended window per §1005.11(c)(3) for new accounts and POS / foreign-initiated, 30-day acknowledgment under §1026.13, 2 complete billing cycles or 90 days under §1026.13. The clock is statutory; missing it is a Reg E or Reg Z violation regardless of intent.
* **Reg E §1005.6 unauthorized-transfer liability tiers.** Cardholder liability ranges from $0 to unlimited based on timing of notice; the AI must classify reason code correctly to apply the right tier.
* **Reg Z §1026.12(b) cardholder $50 unauthorized-use cap.** A separate ceiling for credit-card unauthorized use.
* **FCRA §1681s-2 furnisher accuracy.** When a dispute resolution flips a tradeline, the issuer becomes a furnisher with reasonable-investigation duties under 12 CFR §1022.43.
* **CFPB UDAAP.** Auto-denial without genuine investigation is the documented enforcement vector (Wells Fargo 2022, BofA 2022, BofA 2023, Citizens 2020). The federal Treasury Financial Services AI RMF (February 2026, 230 control objectives) names dispute-decisioning as an in-scope use case.
* **Card-network rules.** Visa Core Rules, Mastercard Chargeback Guide, Amex MOC, Discover ops regs. Visa CE 3.0 reason code 10.4 (effective 15 April 2023) requires at least two prior undisputed transactions 120-365 days old with the same merchant, with at least one of two matches being IP address or Device ID. Mastercard ECP / HECM thresholds (ECM at 100 chargebacks plus 150 bps; HECM at 300 chargebacks plus 300 bps) and Visa VAMP (Above Standard at ≥0.5 percent, Excessive at ≥0.7 percent for acquirers; merchant 2.2 percent from June 2025 phasing to 1.5 percent effective 1 April 2026) drive the merchant-side ratios.
* **EU and UK overlays.** PSD2 Article 73 obliges next-business-day refund of unauthorized payments; PSD2 Article 74 sets a €50 consumer liability cap; UK Consumer Credit Act 1974 §75 establishes joint-and-several creditor liability between £100 and £30,000; PSD3 / PSR (proposed) extends liability for APP fraud and tightens timers.
* **EU AI Act Article 50.** Transparency obligations apply when an AI interviews a cardholder ("you are interacting with an AI") and when AI drafts customer communications.
* **Tipping-off-style hard rule.** For fraud-flagged disputes that overlap with SAR / STR territory, AI-drafted customer communications must not reveal investigation status in ways that compromise underlying fraud investigation. This is an analog only to 31 USC §5318(g)(2) BSA tipping-off, but Reg E §1005.11's "investigation in good faith" standard creates a parallel duty within the dispute regime itself.

### Must-not-fail outcomes

* auto-denying a Reg E §1005.11 or Reg Z §1026.13 dispute without genuine investigation (the central CFPB enforcement vector)
* missing the 10-business-day provisional-credit trigger under Reg E §1005.11
* missing the 30-day acknowledgment or 90-day / 2-billing-cycle resolution window under Reg Z §1026.13
* allowing AI-fabricated evidence (cardholder-side or merchant-side) to drive a dispute outcome without independent verification
* permitting cross-customer dispute-record bleed (one cardholder's records readable by another, or by an unrelated merchant)
* letting the friendly-fraud classifier disproportionately deny legitimate disputes from a cohort
* tipping off a fraud-flagged cardholder, merchant, or third party in ways that compromise an open SAR / STR or fraud investigation
* furnishing inaccurate dispute-outcome data to credit bureaus under FCRA §1681s-2

---

## 3. Workflow description & scope

### 3.1 Workflow steps (happy path)

1. The cardholder initiates a dispute through the mobile app, web portal, chat, or call-center IVR. The AI begins the claim-narrative interview and discloses (per EU AI Act Article 50 in EU jurisdictions, and per CFPB chatbot expectations more broadly) that the cardholder is interacting with an AI.
2. The AI classifies the dispute reason code (unauthorized vs. billing error vs. service-not-rendered vs. quality dispute vs. first-party misuse). It routes by rail (Reg E for debit / prepaid; Reg Z for credit) and starts the appropriate statutory clock.
3. The AI requests supporting evidence (receipts, screenshots, location data, IP context). It runs AI-fabricated-evidence detection (image-forensics, EXIF analysis, multimodal sanity checks, prior-pattern retrieval).
4. The AI drafts a narrow-grounds analysis under Reg E §1005.11 or Reg Z §1026.13. A named human dispute analyst reviews. Provisional credit is issued or denied per the 10-business-day Reg E trigger.
5. The case proceeds. Investigation completes within 45 days under Reg E (90 days under (c)(3) for new accounts and POS / foreign), within 2 complete billing cycles or 90 days under Reg Z.
6. If the dispute is approved, the issuer charges back to the merchant via the card network (Visa Resolve Online, Mastercard Mastercom, Amex, Discover). The merchant or acquirer may submit representment.
7. If the merchant submits representment (often via a vendor like Justt or Chargeflow, often with AI-generated rebuttal narratives and AI-summarized delivery confirmations), the issuer's AI evaluates the representment package against Visa CE 3.0 / Mastercom eligibility and against AI-fabricated-evidence detection on the merchant side.
8. The final decision is communicated to the cardholder. AI-drafted customer comms are reviewed before send. If a denial flips a previously-furnished tradeline (or if the dispute itself triggers furnishing under FCRA §1681s-2), the credit-bureau pipeline is updated through the furnisher path under 12 CFR §1022.43.
9. Post-decision: customer-experience surveys, complaint-pipeline routing, and (if the cardholder escalates to CFPB) the consumer-complaint database integration.

### 3.2 In scope / out of scope

* **In scope:** AI-assisted intake interview; reason-code classification; evidence collection and AI-fabrication detection; Reg E and Reg Z narrow-grounds analysis; provisional-credit decisioning with named-human review; representment packaging for card-network rules; AI-drafted customer communications with named-human review before send; FCRA §1681s-2 furnishing-back of dispute outcomes; integration with CFPB consumer-complaint database when the cardholder escalates.
* **Out of scope:** real-time customer-service interaction (handled in SAFE-UC-0011); fully autonomous dispute denial without named-human review (the CFPB BofA 2022 prepaid-card precedent makes this an enforcement frontier); AI-only credit-decisioning under Reg B / ECOA (out of scope here; the dispute path can affect credit reporting via FCRA but is not direct credit decisioning); arbitration platform functions in the manner of the CFPB-banned Ejudicate model (October 2024).

### 3.3 Assumptions

* The issuer operates a dispute-and-case-management system with per-case statutory-clock fields and named-human accountability for every Reg E / Reg Z decision.
* The AI is configured per the CFPB Chatbots Issue Spotlight expectation that it reliably recognizes a §1005.11 error notice in any phrasing the cardholder might use, and escalates to a human when uncertain.
* Provisional credit is issued automatically when the 10-business-day Reg E trigger fires absent a completed investigation.
* AI-drafted denials, customer comms, and representment packages are reviewed by a named human before send; the AI's draft and the human's edits are both audit-trail artifacts.
* Card-network rules (Visa Core Rules, Mastercard Chargeback Guide, Amex MOC, Discover ops regs) are private contracts; the AI cites only public abstracts and never asserts compliance with non-public sections.

### 3.4 Success criteria

* Every dispute receives a §1005.11 or §1026.13 acknowledgment within the regulated window.
* Every Reg E dispute that is not investigated within 10 business days receives provisional credit per the statutory trigger.
* Every dispute investigation is genuine (per the CFPB BofA 2022 precedent: a fraud-filter flag is not, by itself, an investigation).
* AI-fabricated-evidence detection runs on every cardholder-submitted artifact and every merchant-submitted representment artifact; its outputs are weighted, not dispositive.
* The friendly-fraud classifier passes fairness regression across protected cohorts, and named-human review applies to any dispute denial it triggers.
* Tenant isolation holds across the multi-tenant dispute platform; one cardholder's records are not readable by another.
* AI-drafted customer comms do not tip off a fraud-flagged cardholder, merchant, or third party in ways that compromise underlying fraud investigation.
* FCRA §1681s-2 furnisher accuracy holds for every dispute-outcome credit-bureau update.

---

## 4. System & agent architecture

### 4.1 Actors and systems

* **Human roles:** cardholder (consumer); merchant (potentially with acquirer-side staff); issuing-bank dispute analyst; issuing-bank fraud analyst; representment specialist (issuer-side); customer-service representative; named human decisioner for any Reg E / Reg Z decision; data-protection officer (DPO) for EU flows; FCRA furnisher operations.
* **Counterparty AI roles:** cardholder-side AI assistants drafting claim narratives or generating evidence; merchant-side AI representment vendors (Justt, Chargeflow, Verifi, Ethoca) drafting representment packages.
* **Issuer-side AI / orchestrator:** the LLM claim-narrative interviewer; the dispute-reason classifier; the friendly-fraud classifier; the AI-fabricated-evidence detector; the provisional-credit decisioning workflow; the AI customer-comms drafter; the AI representment evaluator.
* **LLM runtime:** typically a hosted foundation model behind the dispute console, often with retrieval over the issuer's prior-disputes corpus.
* **Tools (MCP servers / APIs / connectors):** Visa Resolve Online connector; Mastercom connector; American Express dispute system connector; Discover dispute system connector; Stripe / Adyen / PayPal disputes APIs; FCRA furnisher pipeline; CFPB consumer-complaint database integration; case-management system; statutory-clock service.
* **Data stores:** dispute records (per-tenant, per-cardholder); evidence object store; prior-disputes vector store; friendly-fraud classifier training and validation sets; statutory-clock state; FCRA furnishing audit log.
* **Downstream systems affected:** card-network systems; credit bureaus (TransUnion, Equifax, Experian); CFPB consumer-complaint database; state-AG channels.

### 4.2 Trusted vs untrusted inputs (the identity quadrangle)

A defining feature of this workflow is that the same dispute record has at least four legitimate readers (cardholder, issuing bank, card network, merchant) with different rights and threat postures, plus a fifth (acquiring bank) and a sixth (regulator) on the periphery. AI is now a producer of inputs on at least two of those sides.

| Input / source                                     | Trusted?              | Why                                                                                              | Typical failure / abuse pattern                                                                    | Mitigation theme                                                                |
| -------------------------------------------------- | --------------------- | ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Cardholder claim narrative (free text, voice, chat) | Untrusted             | originates outside any trust perimeter; can be coached by AI                                     | indirect prompt injection; AI-coached narrative tuned to the issuer's classifier                   | quote-isolate; treat as data; do not let free text drive tool calls             |
| Cardholder-submitted evidence (receipts, screenshots, photos, location) | Untrusted-by-construction | AI-generated artifacts are increasingly common (AppZen 14% in Sept 2025)                       | AI-fabricated receipts; EXIF-tampering; location-spoof screenshots                                  | image-forensics; EXIF analysis; multimodal sanity checks; prior-pattern retrieval |
| Cardholder-submitted documents (PDF, audio)         | Untrusted             | embedded text and metadata are an injection vector                                              | indirect prompt injection embedded in PDF text or audio transcripts                                  | content sanitization; CDR (content disarm and reconstruction); OCR-text isolation |
| Merchant representment package                      | Counterparty-untrusted | merchant has commercial incentive to win the representment                                       | AI-generated rebuttal narrative; AI-summarized delivery confirmation; CE 3.0 eligibility gaming     | independent verification of CE 3.0 eligibility; AI-fabrication detection on merchant artifacts |
| Merchant representment vendor output (Justt, Chargeflow, Verifi, Ethoca) | Counterparty-untrusted | vendor is paid on representment-win-rate                                                       | dynamic-arguments narrative tuned to the issuer's classifier                                        | treat as data; verify against transaction record; attribution to a named human    |
| Acquirer signal (Stripe, Adyen, PayPal, Square)     | Semi-trusted          | originates from a regulated counterparty                                                         | misclassification of dispute lifecycle stage                                                       | per-tenant signing of API responses; cross-source corroboration                  |
| Card-network signal (Visa, Mastercard, Amex, Discover) | Authoritative-but-private | network-originated; private contract                                                          | phishing masquerading as network contact                                                           | out-of-band authentication; established channels                                  |
| Issuer's prior-disputes vector store                | Tenant-scoped         | shared multi-tenant retrieval                                                                    | cross-tenant bleed; vector store contamination                                                      | per-tenant indexing; retrieval-time tenant scoping; integrity attestation         |
| Friendly-fraud classifier training data             | Internally-trusted    | issuer's own historical decisions                                                                | training-data bias propagating disparate-impact harm; data poisoning during retraining             | data-provenance signing; fairness regression; named-human approval for retraining |
| LLM output (decisions, comms, representment)        | Untrusted-by-construction | probabilistic; the issuer's own AI is a producer of artifacts                                  | hallucinated Reg E / Reg Z text; hallucinated dispute-outcome facts                                 | grounded retrieval; verbatim regulatory-language surfacing; named-human review     |
| Regulator communication (CFPB, state AG)            | Authoritative         | regulator-originated                                                                              | phishing masquerading as regulator contact                                                          | out-of-band authentication; established channels                                  |

### 4.3 Trust boundaries (required)

* **Cardholder to issuer:** the cardholder's free text and submitted artifacts are untrusted; the issuer's AI must treat them as data, not instruction.
* **Merchant / acquirer to issuer:** representment packages are counterparty-untrusted; AI-generated merchant-side narratives are commonly detected and weighted, rather than accepted at face value.
* **Issuer-internal across tenants and cardholders:** tenant isolation must hold; one customer's context must not bleed into another's, even when the platform serves multiple issuers.
* **Issuer to card network:** out-of-band authentication for any unsolicited contact; only public abstracts of network rules are cited externally.
* **Issuer to credit bureaus (FCRA furnisher path):** every dispute-outcome update is auditable; reasonable-investigation duty under 12 CFR §1022.43 applies.
* **Issuer to fraud-flagged cardholder or merchant (tipping-off analog):** AI-drafted customer comms must not reveal investigation status in ways that compromise an open SAR / STR or fraud investigation.

### 4.4 Permission and approval design

* **Provisional credit issuance** is gated by a named-human-approval path for any dispute over a documented dollar threshold and below the threshold is auto-approved per the 10-business-day Reg E §1005.11 trigger.
* **Dispute denial** (Reg E or Reg Z) requires named-human review; the AI's narrow-grounds analysis is a draft, not a decision.
* **AI-drafted customer comms** are reviewed by a named human before send; the regulated disclosure language in any denial communication must surface verbatim from an authoritative source.
* **Friendly-fraud classifier outputs** never solely-automate a dispute denial that affects credit reporting; named-human review applies.
* **FCRA furnisher updates** require a documented chain of custody from dispute outcome to credit-bureau submission.
* **Tipping-off-analog gate:** for any dispute that overlaps with a fraud investigation, AI-drafted customer comms route through a specialized review path that ensures investigation status is not revealed.

### 4.5 Tool inventory (required)

| Tool / connector                                     | Read / Write | Scope                                                | Risk class                                                                  |
| ---------------------------------------------------- | ------------ | ---------------------------------------------------- | --------------------------------------------------------------------------- |
| Claim-narrative interview LLM                        | Read + Write | Per-cardholder, per-dispute                          | Indirect prompt-injection surface; CFPB Chatbot Spotlight scope             |
| Dispute reason classifier                            | Read         | Per-dispute                                          | Reason-code drives statutory clock; classification error is a Reg E or Reg Z risk |
| Friendly-fraud classifier (ML)                       | Read         | Per-dispute, per-cohort                              | Disparate-impact surface; ECOA / Reg B analog                                |
| AI-fabricated-evidence detector (multimodal)         | Read         | Per-evidence-artifact                                | False-negative drives unjust approval; false-positive drives unjust denial    |
| Provisional-credit decisioning workflow              | Write        | Per-dispute, per-cardholder                          | Direct dollar impact; Reg E §1005.11 trigger                                 |
| Reg E / Reg Z narrow-grounds drafter                 | Read         | Per-dispute                                          | Hallucination surface; verbatim-regulatory-language requirement              |
| Customer-comms drafter                               | Read         | Per-dispute                                          | Tipping-off-analog surface; EU AI Act Article 50 transparency surface        |
| Representment evaluator                              | Read         | Per-dispute, per-merchant-package                    | Counterparty-AI-fabrication detection                                        |
| Card-network connectors (Visa Resolve Online, Mastercom, Amex, Discover) | Write (egress) | Issuer-only                                          | Regulated submission surface                                                 |
| FCRA furnisher pipeline                              | Write (egress) | Issuer-only                                          | Reasonable-investigation duty under §1022.43                                 |
| CFPB consumer-complaint database integration         | Read + Write (egress) | Per-cardholder escalation                            | Regulator-facing surface                                                     |
| Statutory-clock service                              | Read + Write | Per-dispute                                          | Missing the clock is a violation                                              |
| Prior-disputes vector store                          | Read         | Per-tenant, per-issuer                               | Cross-tenant bleed surface; vector store poisoning                            |

---

## 5. Operating modes

### 5.1 Manual (read-only assistance)

Humans drive every decision. The AI proposes; the analyst decides. Most regulator-sensitive deployments default here, and the CFPB BofA 2022 precedent is the reason.

**Risk profile:** bounded by reviewer capacity. Privacy and clock-precision risks dominate over decision-error risk.

### 5.2 HITL per-action (the common pattern for dispute denial and provisional credit)

The AI proposes specific actions (reason-code classification, provisional-credit issuance, denial drafting, representment packaging) and a named human approves each before execution. Common at large U.S. issuers post-CFPB-BofA-2022.

**Risk profile:** moderate. UI discipline and resistance to consent-fatigue determine quality. Long queues are a known T1403 surface.

### 5.3 Autonomous on a narrow allow-list (bounded autonomy)

A pre-declared allow-list runs without per-action approval: provisional credit under a low-dollar threshold inside the 10-business-day Reg E window; routine acknowledgment messages; ingestion-pipeline classification. Anything touching denial, representment, FCRA furnishing, or tipping-off-analog territory stays HITL or manual.

**Risk profile:** depends on allow-list discipline. Reg E §1005.11 timing makes this lane attractive; the CFPB BofA 2022 precedent makes it dangerous.

### 5.4 Fully autonomous with guardrails (rare, contested)

End-to-end autonomous denial with post-hoc human review. The CFPB BofA 2022 order against this exact pattern (an automated fraud filter as the basis for denying Reg E error notices) is the operative precedent making this lane hard to defend.

**Risk profile:** highest. Hard to reconcile with CFPB enforcement posture, FCRA reasonable-investigation duty, EU AI Act Article 50 transparency, or GDPR Article 22 where applicable.

### 5.5 Variants

Architectural variants teams reach for:

1. **Issuer-only versus network-shared.** Some issuers run all dispute decisioning in-house; others delegate to network platforms (Visa Resolve Online with VCR, Mastercard Mastercom). The network-shared model multiplies the cross-tenant boundary.
2. **AI-drafted plus human-edited dual-artifact model.** Both the AI's draft and the human's edits are preserved in the audit trail; the audit trail itself becomes the artifact in the event of CFPB exam.
3. **Friendly-fraud classifier behind a specialized review path.** Disputes flagged as likely first-party-misuse route to a dedicated team rather than to general dispute analysts.
4. **Tipping-off review path.** Disputes flagged as overlapping with SAR / STR territory route to a fraud-investigations-specialized review path that knows how to draft customer comms without compromising investigation.
5. **Independent fairness monitor.** A separately-authored monitor watches friendly-fraud-classifier outcomes across cohorts and flags drift.

---

## 6. Threat model overview (high-level)

### 6.1 Primary security & safety goals

* preserve Reg E §1005.11 and Reg Z §1026.13 statutory timing for every dispute
* prevent auto-denial without genuine investigation (the CFPB enforcement vector)
* detect AI-fabricated evidence on both cardholder and merchant sides
* preserve tenant isolation across multi-tenant dispute platforms
* prevent friendly-fraud-classifier disparate impact across protected cohorts
* prevent tipping off fraud-flagged cardholders, merchants, or third parties
* preserve FCRA §1681s-2 furnisher accuracy on every dispute-outcome credit-bureau update

### 6.2 Threat actors (who might attack or misuse)

* **Cardholders (legitimate and illegitimate)** including consumers using AI to draft claim narratives or generate supporting receipts
* **First-party-misuse actors** disputing transactions they actually authorized (Chargebacks911 estimates as much as 70 percent of all credit-card fraud is friendly fraud)
* **Merchants and merchant-side representment vendors** (Justt, Chargeflow) submitting AI-generated rebuttal narratives and AI-summarized delivery confirmations
* **Bot-driven dispute mills** submitting high-volume AI-generated disputes
* **Adversaries targeting the friendly-fraud classifier** to skew approvals, drift the model, or trigger denials of a target cohort
* **Insider misuse** at the issuer: an analyst routing disputes outside the documented path
* **AI-decisioning vendors** marketed as adjudicators (the CFPB Ejudicate ban precedent)
* **Regulators acting in good faith** (CFPB, OCC, FFIEC, state AG, EU DPA): not adversaries, but a forcing function

### 6.3 Attack surfaces

* claim-narrative free text and audio (indirect prompt injection)
* uploaded receipts, screenshots, photos, PDFs, audio (multimodal injection; AI-fabricated content)
* merchant representment packages (counterparty-AI fabrication)
* friendly-fraud classifier (ML supply chain; training-data poisoning; evasion)
* prior-disputes vector store (cross-tenant bleed; vector store contamination)
* statutory-clock service (denial-of-clock; misclassification of new-account or POS / foreign disputes that should trigger §1005.11(c)(3))
* AI-drafted customer comms (tipping-off analog; EU AI Act Article 50 transparency)
* FCRA furnisher pipeline (reasonable-investigation duty)
* card-network connectors (representment-package integrity)
* CFPB consumer-complaint database integration (regulator-facing surface)

### 6.4 High-impact failures (include industry harms)

* **Customer / consumer harm:** auto-denied disputes that should have been approved (the CFPB BofA 2022 prepaid-unemployment-card harm shape); wrongful furnishing to credit bureaus that lowers credit scores; tipped-off fraud-flagged cardholders who lose investigation cooperation.
* **Business harm:** CFPB UDAAP enforcement (Wells Fargo $3.7B Dec 2022, BofA $250M Jul 2023, BofA $225M Jul 2022, Citizens $9M, Discover and others); state-AG action; EU DPA action; class-action litigation on disparate-impact dispute denial; private-arbitration ban (Ejudicate Oct 2024).
* **Regulator harm:** missed §1005.11 or §1026.13 windows; missed FCRA §1681s-2 furnisher-accuracy obligations; missed EU AI Act Article 50 transparency obligations; tipping-off violations (analog).
* **Counterparty harm:** approving disputes on AI-fabricated evidence that should have been denied (the merchant is harmed); denying legitimate disputes on adversarial AI representment narratives (the cardholder is harmed).

---

## 7. Kill-chain analysis (stages → likely failure modes)

> Keep this defender-friendly. Describe patterns, not "how to do it."
>
> Note: this UC uses a **seven-stage kill chain** with **5 stages flagged NOVEL** versus SAFE-UC-0011 (Banking VA, the closest financial-services precedent) and SAFE-UC-0027 (Anti-scam) and SAFE-UC-0006 (Fleet telematics). The novelty centers on AI-on-AI adjudication: the issuer's AI is being asked to evaluate AI output produced by counterparties on both sides of the dispute, while the issuer's own statutory timing windows continue to run. SAFE-MCP today does not have a first-class technique for "adjudication on AI-generated artifacts," and §8 flags the gap honestly.

| Stage                                                                                     | What can go wrong (pattern)                                                                                                                                | Likely impact                                                                                              | Notes / preconditions                                                                                                       |
| ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| 1. Claim-narrative intake and reason-code classification                                  | Indirect prompt injection in the claim narrative; AI-coached narrative tuned to the issuer's classifier; misclassification triggers wrong statutory clock  | Reg E vs. Reg Z timing applied incorrectly; missed window                                                  | every free-text channel is a vector; quote-isolation is the floor                                                            |
| 2. Cardholder-side AI-fabricated evidence (**NOVEL: SAFE-MCP partial coverage**)          | AI-generated receipts, screenshots, location-spoof images, fabricated chat transcripts submitted as evidence (AppZen September 2025: ~14 percent of fraud documents) | dispute approved on fabricated evidence; merchant harmed                                                   | T1110 (multimodal injection) covers mechanics; "adjudication on AI-generated artifacts" is not a SAFE-MCP technique today    |
| 3. Merchant / representment-side AI-fabricated evidence (**NOVEL: SAFE-MCP partial coverage**) | AI-generated rebuttal narrative; AI-summarized delivery confirmation; CE 3.0 eligibility gaming via Justt / Chargeflow / Verifi-style dynamic arguments     | dispute denied on fabricated representment; cardholder harmed                                              | counterparty AI is a registry-first composition; T1110 + T1404 + T1102 cover mechanics, not the harm category               |
| 4. Reg E §1005.11 / Reg Z §1026.13 statutory-clock harm (**NOVEL: timing-as-harm**)       | Auto-denial without genuine investigation; missed 10-business-day provisional-credit trigger; missed 30-day acknowledgment; missed 90-day or 2-billing-cycle resolution | the central CFPB enforcement vector; UDAAP exposure                                                        | the BofA 2022 $225M order is the precedent; auto-deny is the harm                                                            |
| 5. Friendly-fraud / first-party-misuse classifier disparate-impact (**NOVEL: cohort harm**) | Classifier disproportionately denies legitimate first-time disputes from a cohort                                                                          | disparate-impact harm; FCRA furnishing flips a tradeline; ECOA / Reg B analog exposure                       | T2107 + T2105 cover mechanics; fairness-failure is not a SAFE-MCP technique distinct from poisoning                          |
| 6. Cross-tenant or cross-customer dispute-record bleed                                     | Misconfigured per-tenant scoping; vector-store contamination; rug-pull after platform acquisition                                                          | one customer's dispute records exposed to another; regulatory exposure                                     | tenant isolation must hold; differential queries verify in CI                                                                |
| 7. Tipping-off-analog: dispute-status disclosure (**NOVEL: hard rule**)                   | AI-drafted customer comms reveal investigation status to a fraud-flagged cardholder, merchant, or third party; SAR / STR investigation compromised        | underlying fraud investigation harmed; BSA tipping-off analog (31 USC §5318(g)(2)); state-AG exposure       | analog only to BSA; Reg E §1005.11 "investigation in good faith" creates the parallel duty within the dispute regime         |

---

## 8. SAFE‑MCP mapping (kill-chain → techniques → controls → tests)

Practitioners commonly map this workflow's failure patterns to the following SAFE‑MCP techniques. The mapping is directional: teams adapt it to their stack, threat model, regulatory regime, and card-network rules. Links in Appendix B resolve to the canonical technique pages. **A note on framework gap:** SAFE-MCP today covers the LLM and MCP-tool surface well, but does not yet have first-class techniques for **adjudication on AI-generated artifacts** (the central novelty here, where the issuer's AI is asked to evaluate AI output produced by counterparties on both sides), **Reg E / Reg Z statutory-timing harms**, or **fairness-failure distinct from data poisoning**. The mapping below cites the closest anchors and flags the gap honestly.

| Kill-chain stage                                                       | Failure / attack pattern (defender-friendly)                                                                                                       | SAFE‑MCP technique(s)                                                                                                                                                                                                                                                | Recommended controls (prevent / detect / recover)                                                                                                                                                                                                                                                                                                                                              | Tests (how to validate)                                                                                                                                                                                                                                                                                                                                          |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Claim-narrative intake and reason-code classification                  | Indirect prompt injection; AI-coached narrative; misclassification triggers wrong statutory clock                                                  | `SAFE-T1102` (Prompt Injection (Multiple Vectors)); `SAFE-T1003` (Malicious MCP-Server Distribution); `SAFE-T1402` (Instruction Stenography - Tool Metadata Poisoning)                                                                                                | quote-isolate every free-text channel; structured-output schema for classifier; named-human review on any reason-code reclassification that changes the regulatory clock                                                                                                                                                                                                                       | adversarial prompt-injection fixtures across each free-text source; reason-code-flip fixtures; verify the LLM cannot drive a tool call from claim-narrative free text                                                                                                                                                                                            |
| Cardholder-side AI-fabricated evidence (**NOVEL gap**)                  | AI-generated receipts, screenshots, location-spoof images, fabricated chat transcripts                                                              | `SAFE-T1110` (Multimodal Prompt Injection via Images/Audio); `SAFE-T1102` (Prompt Injection (Multiple Vectors)). **Gap:** "adjudication on AI-generated artifacts" is not a SAFE-MCP technique today                                                                | image-forensics; EXIF analysis; multimodal sanity checks; prior-pattern retrieval against the issuer's AI-fabrication corpus; named-human review on any approval that turns on a single artifact                                                                                                                                                                                              | AI-fabricated-evidence fixture library; verify approval rate on fabricated fixtures is below declared threshold; verify named-human review fires on single-artifact approvals                                                                                                                                                                                    |
| Merchant / representment-side AI-fabricated evidence (**NOVEL gap**)    | AI-generated rebuttal narrative; AI-summarized delivery confirmation; CE 3.0 eligibility gaming                                                     | `SAFE-T1110` (Multimodal Prompt Injection via Images/Audio); `SAFE-T1404` (Response Tampering); `SAFE-T1102` (Prompt Injection (Multiple Vectors))                                                                                                                  | independent verification of CE 3.0 eligibility against transaction-record ground truth (≥2 prior transactions 120-365 days, IP / Device ID match); AI-fabrication detection on merchant artifacts; named-human review on any denial that turns on a single representment artifact                                                                                                            | adversarial merchant-representment fixture library; CE 3.0 eligibility-gaming tests; verify denial rate on fabricated representment fixtures is below declared threshold                                                                                                                                                                                          |
| Reg E §1005.11 / Reg Z §1026.13 statutory-clock harm (**NOVEL: timing-as-harm**) | Auto-denial without genuine investigation; missed provisional-credit trigger; missed acknowledgment or resolution windows                          | `SAFE-T1404` (Response Tampering); `SAFE-T1403` (Consent-Fatigue Exploit); `SAFE-T2105` (Disinformation Output)                                                                                                                                                      | hard policy-as-code gate: auto-denial path is closed; named-human review on every Reg E / Reg Z denial; statutory-clock service with auto-trigger on 10-business-day Reg E provisional-credit; verbatim-regulatory-language surfacing; dual-artifact audit trail (AI draft plus human edit)                                                                                                  | tabletop the BofA 2022 prepaid-unemployment-card scenario against your platform; verify auto-denial path is closed; verify provisional-credit auto-trigger fires on day 10                                                                                                                                                                                          |
| Friendly-fraud / first-party-misuse classifier disparate-impact         | Classifier disproportionately denies legitimate first-time disputes from a cohort                                                                  | `SAFE-T2107` (AI Model Poisoning via MCP Tool Training Data Contamination); `SAFE-T2106` (Context Memory Poisoning via Vector Store Contamination); `SAFE-T2105` (Disinformation Output). **Gap:** fairness-failure distinct from poisoning is not a SAFE-MCP technique today | training-data provenance and signing; fairness regression across protected cohorts; named-human review on every classifier-driven denial that affects credit reporting; appeal flow with documented response timelines; specialized review path for first-time disputers                                                                                                                  | adversarial training-data fixtures; fairness regression tests; appeal-flow integrity test; verify named-human review is enforced for solely-automated denials affecting credit reporting                                                                                                                                                                          |
| Cross-tenant or cross-customer dispute-record bleed                     | Misconfigured per-tenant scoping; vector-store contamination; rug-pull after platform acquisition                                                  | `SAFE-T1701` (Cross-Tool Contamination); `SAFE-T1702` (Shared-Memory Poisoning); `SAFE-T1201` (MCP Rug Pull Attack); `SAFE-T2106` (Context Memory Poisoning via Vector Store Contamination); `SAFE-T1104` (Over-Privileged Tool Abuse)                              | tenant-isolation enforcement at every layer (storage, cache, vector store); per-tenant signing of API responses; differential queries to detect bleed; vendor due-diligence on platform M&A; named-human review of any cross-tenant federation                                                                                                                                                | adversarial cross-tenant query fixtures; shared-cache poisoning fixtures; bleed-detection differential tests run in CI                                                                                                                                                                                                                                            |
| Tipping-off-analog: dispute-status disclosure                          | AI-drafted customer comms reveal investigation status; SAR / STR investigation compromised                                                          | `SAFE-T1404` (Response Tampering); `SAFE-T2105` (Disinformation Output); `SAFE-T1801` (Automated Data Harvesting); `SAFE-T1804` (API Data Harvest)                                                                                                                  | specialized review path for any dispute that overlaps with a fraud investigation; verbatim disclosure-language surfacing for regulated text; named-human approval before any external send on a fraud-flagged dispute; egress allow-list for any disclosure to a counterparty                                                                                                                  | tabletop a SAR-overlap scenario; verify the AI does not draft language revealing investigation status; verify named-human review is enforced; verify the customer-comms drafter cannot bypass the specialized review path                                                                                                                                          |

---

## 9. Controls & mitigations (organized)

### 9.1 Prevent (reduce likelihood)

* **Hard policy-as-code gate on auto-denial.** The auto-denial path is closed; every Reg E / Reg Z denial requires named-human review. The CFPB BofA 2022 precedent makes this the operative posture.
* **Statutory-clock service** with auto-trigger on the 10-business-day Reg E §1005.11 provisional-credit threshold; auto-trigger on the 30-day Reg Z §1026.13 acknowledgment threshold; dashboard for the 45-day / 90-day / 2-billing-cycle completion thresholds.
* **AI-fabricated-evidence detection** on every cardholder-submitted artifact and every merchant-submitted representment artifact, with documented thresholds and named-human review on single-artifact approvals or denials.
* **Tenant isolation as a hard invariant** across storage, cache, and vector store; differential queries verify in CI.
* **Tipping-off-analog gate** on every fraud-flagged dispute; specialized review path; verbatim-regulatory-language surfacing for any external send.
* **Quote-isolation** on every free-text channel into the LLM.
* **Verbatim-regulatory-language surfacing** for Reg E disclosures, Reg Z disclosures, and EU AI Act Article 50 AI-interaction notices.
* **Named-human attribution** on every solely-automated decision with legal or significant effect (provisional-credit issuance above a documented threshold, dispute denial, FCRA furnishing-back).
* **Fairness regression** on the friendly-fraud classifier across protected cohorts.
* **Egress allow-list** on every external connector (card networks, credit bureaus, CFPB consumer-complaint database).

### 9.2 Detect (reduce time-to-detect)

* statutory-clock-violation alerts (every dispute that crosses the 10-business-day Reg E threshold without a provisional-credit decision)
* tenant-isolation differential queries run continuously in CI and in production
* AI-fabricated-evidence detection rates per artifact class (cardholder-side, merchant-side)
* friendly-fraud classifier fairness drift across cohorts
* AI-drafted customer-comms tipping-off-analog detection on every external send
* FCRA furnisher accuracy monitoring (12 CFR §1022.43 reasonable-investigation surface)
* CFPB consumer-complaint database escalation rate per dispute class
* Visa CE 3.0 eligibility-failure rate on inbound merchant representment

### 9.3 Recover (reduce blast radius)

* incident-response playbook for an inferred or confirmed cross-tenant dispute-record bleed
* incident-response playbook for an inferred or confirmed Reg E §1005.11 timing failure (the BofA 2022 shape)
* incident-response playbook for an inferred or confirmed friendly-fraud-classifier disparate-impact event
* tipping-off-analog incident-response playbook with fraud-investigation-team coordination
* CFPB and state-AG notification playbook with countdown SLAs per jurisdiction
* dispute-decision rollback path when AI-fabricated evidence is detected post-decision
* customer-side appeal path with documented response timelines

---

## 10. Validation & testing plan

### 10.1 What to test (minimum set)

* **Reg E §1005.11 statutory-clock integrity** holds across acknowledgment, 10-business-day provisional-credit, 45-day completion, 90-day extended.
* **Reg Z §1026.13 statutory-clock integrity** holds across 30-day acknowledgment, 2-billing-cycle / 90-day completion.
* **Auto-denial path** is closed; every Reg E / Reg Z denial requires named-human review.
* **AI-fabricated-evidence detection** runs on every artifact and meets declared thresholds.
* **Tenant isolation** holds under adversarial cross-tenant queries.
* **Friendly-fraud classifier** passes fairness regression across protected cohorts.
* **Tipping-off-analog gate** holds on every fraud-flagged dispute.
* **CE 3.0 eligibility verification** independent of merchant-submitted representment claims.
* **FCRA furnisher accuracy** holds on every credit-bureau update.
* **EU AI Act Article 50 transparency** surfaces in every AI-interaction.

### 10.2 Test cases (make them concrete)

| Test name                                  | Setup                                                                  | Input / scenario                                                                                                       | Expected outcome                                                                                                                              | Evidence produced                                              |
| ------------------------------------------ | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Reg E 10-day provisional-credit trigger    | Synthetic Reg E dispute; investigation incomplete on day 10           | Day 10 with no completion                                                                                              | Provisional credit auto-issued; clock service logs the trigger                                                                                | clock-service log + provisional-credit transaction              |
| Auto-denial path closed                    | Synthetic Reg E denial draft from the AI                              | AI proposes denial without named-human review                                                                          | Denial blocked at the policy-as-code gate; flagged for named-human review                                                                     | gate-rejection log + flagged-claim list                         |
| Cardholder AI-fabricated receipt detection | Synthetic AI-generated receipt fixture                                 | Cardholder submits AI-fabricated receipt as evidence                                                                   | Detector flags the artifact; approval rate on fabricated fixtures below declared threshold; named-human review fires                          | detector log + approval-rate metric                              |
| Merchant AI-fabricated representment       | Synthetic AI-generated representment narrative                         | Merchant submits AI-fabricated representment package                                                                   | Detector flags; CE 3.0 eligibility verification fires; named-human review fires                                                                | detector log + CE 3.0 eligibility log                            |
| Cross-tenant bleed differential            | Two synthetic tenant issuers on the same platform                       | Tenant A queries for VIN belonging to Tenant B's cardholder                                                            | Query rejected; differential test passes; audit captures attempt                                                                              | differential-query log + audit trail                            |
| Friendly-fraud fairness regression         | Synthetic cohort fixtures across protected attributes                   | Classifier produces friendly-fraud flags across cohorts                                                                | Fairness metrics within declared bounds; named-human review enforced on solely-automated denials                                              | fairness-metric log + approval-gate log                          |
| Tipping-off-analog gate                    | Synthetic dispute overlapping a SAR-style flag                          | AI drafts customer comms                                                                                                | Drafts route through specialized review path; comms do not reveal investigation status; named-human approval fires                            | review-path log + comms-audit log                                |
| Verbatim regulatory language               | Synthetic Reg E denial draft                                            | AI generates denial language                                                                                            | Regulated language surfaces verbatim from authoritative source; AI-paraphrasing fails the gate                                                 | language-source log                                              |
| FCRA furnisher accuracy                    | Synthetic dispute outcome flipping a previously-furnished tradeline    | Furnisher pipeline updates credit bureau                                                                                | Reasonable-investigation evidence captured; furnisher-accuracy audit passes                                                                    | furnisher-audit log                                              |
| EU AI Act Article 50 transparency          | Synthetic EU cardholder interaction                                      | AI begins claim-narrative interview                                                                                     | Article 50 disclosure surfaces verbatim; the cardholder is informed they are interacting with an AI                                            | disclosure-surfacing log                                          |

### 10.3 Operational monitoring (production)

* §1005.11 / §1026.13 statutory-clock dashboards (no missed thresholds)
* tenant-isolation differential-query pass rate
* AI-fabricated-evidence detection rate per artifact class
* friendly-fraud fairness drift across cohorts
* tipping-off-analog gate trigger rate on fraud-flagged disputes
* named-human-review enforcement rate on Reg E / Reg Z denials
* FCRA furnisher-accuracy audit pass rate
* CFPB consumer-complaint database escalation rate
* CE 3.0 eligibility-failure rate on inbound merchant representment
* EU AI Act Article 50 disclosure-surfacing rate

---

## 11. Open questions & TODOs

- [ ] Define the organization's auto-denial-path closure policy and named-human-review requirements per Reg E and Reg Z dispute class.
- [ ] Document the named-human roles (dispute analyst, fraud analyst, representment specialist, named decisioner, FCRA furnisher operator, DPO) and their attestation artifacts.
- [ ] Specify the AI-fabricated-evidence detection thresholds for cardholder and merchant artifact classes.
- [ ] Map the statutory-clock service auto-triggers to Reg E §1005.11 and Reg Z §1026.13 thresholds.
- [ ] Document the tipping-off-analog specialized review path and its coordination with fraud investigations.
- [ ] Specify the friendly-fraud classifier fairness-regression cohorts and thresholds; document the appeal flow.
- [ ] Map regulator-notification SLAs per jurisdiction (CFPB, OCC, FFIEC, state AG, EU DPA, FCA in the UK).
- [ ] Document the CE 3.0 / Mastercom / Amex / Discover representment-package independent-verification path.
- [ ] Decide the FCRA furnisher-accuracy audit cadence and named-human-review requirements.

---

## 12. Questionnaire prompts (for reviewers)

### Workflow realism

* Are the integrations (Visa Resolve Online, Mastercom, Amex, Discover, Stripe, Adyen, PayPal, FCRA furnisher pipeline, CFPB consumer-complaint database) realistic for the organization's stack?
* Does the workflow distinguish issuer-only, network-shared, and federated deployments, and document the trust boundaries in each?
* Is the LLM scoped to claim-narrative intake and decision-drafting only, or does it author regulated text without grounded retrieval?

### Trust boundaries & permissions

* Does tenant isolation hold across storage, cache, and vector store, and is it tested in CI?
* Is AI-fabricated-evidence detection running on every cardholder-submitted artifact and every merchant-submitted representment artifact?
* Is the tipping-off-analog gate active on every fraud-flagged dispute?

### Output safety & persistence

* Are AI-drafted denials reviewed by a named human before send?
* Are Reg E and Reg Z disclosures surfaced verbatim from authoritative sources, not generated by the LLM?
* Is the dual-artifact audit trail (AI draft plus human edit) preserved for every dispute decision?

### Statutory-clock integrity

* Does the statutory-clock service auto-trigger on the 10-business-day Reg E provisional-credit threshold?
* Does it auto-trigger on the 30-day Reg Z acknowledgment threshold?
* Are the 45-day, 90-day, and 2-billing-cycle resolution thresholds dashboarded and alerted?

### Fairness and disparate impact

* Does the friendly-fraud classifier pass fairness regression across protected cohorts?
* Is named-human review enforced on every classifier-driven denial that affects credit reporting?
* Is there a documented appeal flow with response timelines?

### Regulator-facing integrity

* Are CFPB UDAAP enforcement scenarios (BofA 2022, Wells Fargo 2022, BofA 2023, Citizens 2020, Discover 2024) tabletoped and rehearsed?
* Are FCRA §1681s-2 furnisher-accuracy obligations evidenced for every credit-bureau update?
* Which controls are commonly viewed as mandatory under the organization's primary regulator (CFPB, OCC, FDIC, FFIEC, state AG, EU DPA, FCA) versus recommended?

---

## Appendix A: Contributors and Version History

* **Authoring:** Astha (DSO contributor, 2026-04-25)
* **Initial draft:** 2026-04-25 (Seed → Draft)

---

## Appendix B: References & frameworks

### B.1 SAFE-MCP techniques referenced in this use case

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
* [SAFE-T2105 Disinformation Output](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2105/README.md)
* [SAFE-T2106 Context Memory Poisoning via Vector Store Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2106/README.md)
* [SAFE-T2107 AI Model Poisoning via MCP Tool Training Data Contamination](https://github.com/safe-agentic-framework/safe-mcp/blob/main/techniques/SAFE-T2107/README.md)

### B.2 Industry and AI-specific frameworks teams commonly consult

* [NIST AI Risk Management Framework 1.0 (AI 100-1, January 2023)](https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf)
* [NIST AI 600-1 Generative AI Profile (July 2024)](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)
* [NIST AI 100-2 E2025 Adversarial Machine Learning Taxonomy and Terminology of Attacks and Mitigations (24 March 2025)](https://csrc.nist.gov/pubs/ai/100/2/e2025/final)
* [NIST SP 800-218A SSDF Generative AI Profile (July 2024)](https://csrc.nist.gov/pubs/sp/800/218/a/final)
* [Regulation (EU) 2024/1689 (EU AI Act; Article 50 transparency for AI interacting with natural persons)](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
* [EU AI Act Article 50 commentary (artificialintelligenceact.eu reference site; cite alongside the EUR-Lex primary)](https://artificialintelligenceact.eu/article/50/)
* [ISO/IEC 42001:2023 Artificial Intelligence Management System](https://www.iso.org/standard/81230.html)
* [ISO/IEC 23894:2023 AI Risk Management](https://www.iso.org/standard/77304.html)
* [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)
* [OWASP Machine Learning Security Top 10](https://owasp.org/www-project-machine-learning-security-top-10/)
* [MITRE ATLAS adversarial threat landscape for AI systems](https://atlas.mitre.org/)

### B.3 Public incidents and disclosures adjacent to this workflow

* [CFPB Issue Spotlight: Chatbots in Consumer Finance (June 2023; the load-bearing supervisory voice)](https://www.consumerfinance.gov/about-us/newsroom/cfpb-issue-spotlight-analyzes-artificial-intelligence-chatbots-in-banking/)
* [CFPB and OCC fine Bank of America $225 Million over botched disbursement of state unemployment benefits (14 July 2022; "implemented a fraud filter with a simple set of flags that automatically triggered an account freeze")](https://www.consumerfinance.gov/about-us/newsroom/federal-regulators-fine-bank-of-america-225-million-over-botched-disbursement-of-state-unemployment-benefits-at-height-of-pandemic/)
* [CFPB Orders Wells Fargo to Pay $3.7 Billion (20 December 2022; over 16 million affected consumer accounts)](https://www.consumerfinance.gov/about-us/newsroom/cfpb-orders-wells-fargo-to-pay-37-billion-for-widespread-mismanagement-of-auto-loans-mortgages-and-deposit-accounts/)
* [CFPB Wells Fargo Consent Order PDF (December 2022)](https://files.consumerfinance.gov/f/documents/cfpb_wells-fargo-na-2022_consent-order_2022-12.pdf)
* [CFPB Takes Action Against Bank of America for Illegally Charging Junk Fees, Withholding Credit Card Rewards (11 July 2023; over $250M total)](https://www.consumerfinance.gov/about-us/newsroom/bank-of-america-for-illegally-charging-junk-fees-withholding-credit-card-rewards-opening-fake-accounts/)
* [CFPB Enforcement Action against Citizens Bank for Unlawful Credit Card Servicing ($9 million; complaint filed 30 January 2020)](https://www.consumerfinance.gov/enforcement/actions/citizens-bank/)
* [CFPB Action to Require Citizens Bank to Pay $9 Million Penalty for Unlawful Credit Card Servicing (companion press release)](https://www.consumerfinance.gov/about-us/newsroom/cfpb-action-require-citizens-bank-pay-9-million-unlawful-credit-card-servicing/)
* [CFPB Supervisory Highlights, Issue 37 (Winter 2024; Reg E §1005.11 error-resolution findings)](https://files.consumerfinance.gov/f/documents/cfpb_Supervisory-Highlights-Issue-37_Winter-2024.pdf)
* [CFPB Bans Private Dispute Resolution Platform Ejudicate from Arbitrating Consumer Financial Product Disputes (October 2024; analysis by Consumer Finance Monitor)](https://www.consumerfinancemonitor.com/2024/10/17/cfpb-bans-private-dispute-resolution-platform-ejudicate-from-arbitrating-consumer-financial-product-disputes/)
* [FTC Secures Historic $2.5 Billion Settlement Against Amazon (September 2025; subscription-cancellation friction analog)](https://www.ftc.gov/news-events/news/press-releases/2025/09/ftc-secures-historic-25-billion-settlement-against-amazon)
* [AppZen: The Invisible Threat, Detecting AI-Generated Fake Receipts (2025; ~14% of fraud documents in September 2025; 3.5M+ fake receipts on top four fraud sites in six months)](https://www.appzen.com/resources/ai-generated-fake-receipts)
* [PYMNTS: Phony AI-Created Receipts Become Real Problem for Businesses (2025)](https://www.pymnts.com/news/security-and-risk/2025/phony-ai-created-receipts-become-real-problem-for-businesses/)
* [Mastercard 2025 First-Party Trust press release ($42B chargeback cost projected by 2028)](https://www.mastercard.com/us/en/news-and-trends/press/2025/june/first-party-trust-countering-friendly-fraud.html)
* [Chargebacks911 2024 Chargeback Field Report (~18 percent friendly-fraud increase; up to 70 percent of all credit-card fraud traced to chargeback misuse)](https://chargebacks911.com/chargeback-field-report/)
* [Datos Insights: First-Party Fraud Conundrum (Aite-Novarica, commissioned by Ethoca)](https://datos-insights.com/reports/first-party-fraud-conundrum-how-protect-financial-institutions-and-merchants/)

### B.4 Domain-regulatory references

* [12 CFR §1005.11 Procedures for Resolving Errors (Reg E; 60-day notice; 10-business-day investigate or provisional credit; 45-day complete; 90-day extended per (c)(3))](https://www.ecfr.gov/current/title-12/chapter-X/part-1005/subpart-A/section-1005.11)
* [12 CFR §1005.11 (CFPB rendering)](https://www.consumerfinance.gov/rules-policy/regulations/1005/11/)
* [12 CFR §1026.13 Billing Error Resolution (Reg Z; 60-day notice; 30-day acknowledgment; 2 complete billing cycles or 90 days resolve)](https://www.ecfr.gov/current/title-12/chapter-X/part-1026/subpart-B/section-1026.13)
* [12 CFR §1026.13 (CFPB rendering)](https://www.consumerfinance.gov/rules-policy/regulations/1026/13/)
* [12 CFR §1022.43 Direct Disputes (FCRA furnisher duties)](https://www.consumerfinance.gov/rules-policy/regulations/1022/43/)
* [12 CFR Part 1022 Subpart E Duties of Furnishers of Information](https://www.ecfr.gov/current/title-12/chapter-X/part-1022/subpart-E)
* [OCC Bulletin 2023-17 Interagency Guidance on Third-Party Risk Management](https://www.occ.gov/news-issuances/bulletins/2023/bulletin-2023-17.html)
* [FFIEC IT Examination Handbook: Retail Payment Systems Booklet](https://ithandbook.ffiec.gov/it-booklets/retail-payment-systems)
* [FTC Safeguards Rule (16 CFR Part 314)](https://www.ftc.gov/legal-library/browse/rules/safeguards-rule)
* [U.S. Treasury Financial Services AI Risk Management Framework (19 February 2026; 230 control objectives)](https://home.treasury.gov/news/press-releases/sb0401)
* [PSD2 Article 73 (refund unauthorized payments by next business day) via European Banking Authority](https://www.eba.europa.eu/regulation-and-policy/single-rulebook/interactive-single-rulebook/14600)
* [UK Consumer Credit Act 1974 §75 (joint and several creditor liability £100-£30,000)](https://www.legislation.gov.uk/ukpga/1974/39/section/75?view=plain)
* [PCI DSS v4.0.1 (effective 31 March 2025)](https://www.pcisecuritystandards.org/)

### B.5 Card-network and payment-platform references

* [Visa Resolve Online](https://usa.visa.com/solutions/post-purchase-solutions/visa-resolve-online.html)
* [Visa Compelling Evidence 3.0 Merchant Readiness Guide (March 2023; reason code 10.4 effective 15 April 2023)](https://usa.visa.com/content/dam/VCOM/regional/na/us/support-legal/documents/compelling-evidence-3.0-merchant-readiness-mar2023.pdf)
* [Visa Acquirer Monitoring Program 2025 Fact Sheet](https://corporate.visa.com/content/dam/VCOM/corporate/visa-perspectives/security-and-trust/documents/visa-acquirer-monitoring-program-fact-sheet-2025.pdf)
* [Mastercard Dispute and Chargeback Management](https://www.mastercard.com/us/en/business/cybersecurity-fraud-prevention/dispute-management.html)
* [Mastercom Developer Documentation](https://developer.mastercard.com/mastercom/documentation/getting-started/)
* [Mastercard Excessive Chargeback Program guide (acquirer-published; ECM 100 + 150 bps; HECM 300 + 300 bps)](https://www.jpmorgan.com/content/dam/jpm/merchant-services/payment-network-updates/documents/mastercard-excessive-chargeback-program-guide.pdf)
* [Stripe Disputes API](https://docs.stripe.com/disputes/api)
* [Stripe Responding to Disputes (150,000-character combined-evidence-fields limit)](https://docs.stripe.com/disputes/responding)
* [Adyen Disputes API (explicit prohibition on submitting PAN, passport, SSN as defense material)](https://docs.adyen.com/risk-management/disputes-api)
* [PayPal Resolution Center](https://www.paypal.com/us/cshelp/article/how-do-i-escalate-a-paypal-dispute-to-a-claim-help367)
* [Ethoca Consumer Clarity (Mastercard pre-dispute deflection)](https://www.ethoca.com/ethoca-consumer-clarity)

### B.6 Vendor product patterns (illustrative; not endorsements)

* [Justt: Automated Chargeback Management Platform](https://justt.ai/platform/)
* [Chargeflow ($35M Series A November 2025; 15,000+ merchants)](https://www.chargeflow.io)
* [Verifi (Visa subsidiary; Compelling Evidence 3.0 implementation guide)](https://www.verifi.com/in-the-news/visa-compelling-evidence-3-0.html)
* [BioCatch (behavioral biometrics for post-dispute fraud review)](https://www.biocatch.com/)
