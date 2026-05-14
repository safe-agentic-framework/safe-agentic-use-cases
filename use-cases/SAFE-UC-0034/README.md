# SAFE-AUCA Industry Reference Guide: Saved Credit Card Payment Flow

This use case describes a secure saved credit card payment workflow, focused on tokenized transaction processing, 3D Secure (SCA) enforcement, and protection against fraud and payment payload manipulation within an e-commerce environment.

## Table of Contents

1. [Use Case Metadata](#use-case-metadata)
2. [Executive Summary](#1-executive-summary-what--why)
3. [Industry Context & Constraints](#2-industry-context--constraints)
4. [Workflow Description & Scope](#3-workflow-description--scope)
5. [System Architecture](#4-system-architecture)
6. [Operating Modes & Agentic Flow Variants](#5-operating-modes--agentic-flow-variants)
7. [Threat Model Overview](#6-threat-model-overview-high-level)
8. [Kill-Chain Analysis](#7-kill-chain-analysis-stages----likely-failure-modes)
9. [Controls and Mitigations](#9-controls-and-mitigations-organized)
10. [Validation and Testing Plan](#10-validation-and-testing-plan)
11. [Contributors & Version History](#contributors--version-history)

---

## Use Case Metadata

| Field                     | Value                                                                                       |
|---------------------------|---------------------------------------------------------------------------------------------|
| **SAFE Use Case ID**      | SAFE-UC-0034                                                                               |
| **Status**                | Draft                                                                                      |
| **NAICS 2022**            | Finance and Insurance (52), Financial Transactions Processing, Reserve, and Clearinghouse Activities (522320) |
| **Workflow Family**       | E-commerce & Payment Processing                                                            |
| **Last Updated**          | 2026-02-19                                                                                 |

---

## 1. Executive Summary (What + Why)

### What this workflow does:
This workflow defines the operational and security boundaries for processing user transactions via a saved credit card flow. It details the retrieval of vaulted payment methods, communication with the Payment System (EPS), and the execution of 3D Secure step-up verification for transaction authorization.

### Why it matters (Business Value):
A frictionless saved-card experience dramatically reduces cart abandonment and improves conversion rates for returning customers. Relying on vaulted tokens rather than raw Primary Account Numbers (PAN) minimizes the merchant's compliance footprint.

### Why it is risky / What can go wrong:
- **High-value target**: Financial transactions are attractive to attackers.
- **Account Takeover (ATO)**: Risk of attackers abusing saved payment methods.
- **Tampering or payload manipulation**: Potential for altering transaction amounts.
- **3D Secure bypass**: Attempts to evade verification challenge prompts.

---

## 2. Industry Context & Constraints

- **Industry-specific constraints**: Strict adherence to PCI-DSS, PSD2 SCA requirements, and localized data residency laws.
- **Typical workflows**:
    - Customer Identity and Access Management (CIAM)
    - E-Commerce Storefront
    - Payment Platform
    - Payment Gateway
    - 3D Secure Access Control Server (ACS)
- **Must-not-fail outcomes**:
    - No raw PAN exposure in logs.
    - No bypass of 3D Secure challenges.
    - No manipulation of final transaction amounts or currencies.
- **Operational constraints**:
    - Millisecond-level latency for authorization loops.
    - Graceful degradation during gateway timeouts.
    - Strict least-privilege access for API tokens.

---

## 3. Workflow Description & Scope

### 3.1 Workflow Steps (Happy Path)
1. Authenticated user initiates checkout and selects a previously saved credit card.
2. Application securely retrieves the customer's vaulted payment token.
3. Frontend initiates the payment gateway interaction to evaluate transaction risks.
4. If required, the issuing bank triggers the user challenge via 3D Secure.
5. Upon successful 3D Secure authentication, the payment gateway issues a one-time cryptographic authorization payload (nonce).
6. Backend validates transaction details and submits the nonce for settlement.

### 3.2 In-Scope / Out-of-Scope

#### In-Scope:
- Token retrieval
- 3D Secure challenge execution
- Payload tampering prevention
- Gateway API communication
- Failure state handling

#### Out-of-Scope:
- Raw card ingestion or vaulting process
- Merchant payout reconciliation
- Physical point-of-sale (POS) systems

### 3.3 Assumptions:
- Application operates on tokenized data; no processing, storage, or transmission of PAN.
- Customer accounts utilize MFA.

---

## 4. System Architecture

### 4.1 Actors and Systems:
- **Human Roles**: Consumers, fraud analysts, payment engineers.
- **Systems**:
    - Frontend app
    - Backend Order Management System
    - Payment Gateway
    - Issuing Bank ACS

### 4.2 Trusted vs. Untrusted Inputs:

| Input/Source               | Trusted?     | Risk                                       | Mitigation                           |
|----------------------------|--------------|--------------------------------------------|--------------------------------------|
| **Transaction Amount**     | Untrusted    | User/browser-supplied price manipulation   | Server-side validation.              |
| **Nonce**                  | Semi-trusted | Risk of reuse                              | Single-use validation.               |
| **3D Secure JWT**          | Mixed        | Replay/signature stripping attacks         | Strict signature checks.             |
| **Gateway API Keys**       | Sensitive    | Risk of fraudulent transaction generation  | Vault storage, IP restrictions.      |

### 4.3 Trust Boundaries:
- **Boundary 1**: Browser -> Backend (verify client inputs like cart totals, nonce match).
- **Boundary 2**: Backend -> Payment Gateway (Mutual TLS, API security).

---

## 5. Operating Modes & Agentic Flow Variants

### 5.1 Manual Baseline (No Agent)
- User selects saved card -> Vault token retrieved -> Payment processed.

### 5.2 Human-in-the-Loop (HITL)
- Assistant Agent prepares the cart autonomously; human approves sensitive actions like price confirmations or 3D Secure prompts.

### 5.3 Fully Autonomous
- Checkout Agent completes all steps autonomously, scoped within pre-approved safety thresholds. Hard caps ensure safety and prevent risks.

---

## 6. Threat Model Overview (High-Level)

### 6.1 Security Goals
- Prevent unauthorized saved-card transactions.
- Detect/stop payload tampering.
- Ensure full auditability.

### 6.2 Threat Actors
- External attackers (e.g., ATO via stolen credentials).
- Malicious insiders.

### 6.4 High-Impact Failures:
- Consumer harm: Unauthorized billing.
- Merchant reputation harm: Chargebacks, compliance penalties.
- Security compromises: API key leaks leading to fraudulent charges.

---

## 7. Kill-Chain Analysis (Stages -> Likely Failure Modes)

### Sample Failure Modes Include:
1. **Entry/Trigger**: Accounts are compromised (ATO).
2. **Execution**: Checkout payload tampered to alter price.
3. **Authorization**: Removal of 3D Secure challenge.
4. **Persistence**: Addition of "hidden" devices to whitelist.
5. **Exfiltration or Final Harm**: Fraud settlement or data leaks.

Details on HITL and Full Agent variants provided in team review documents.

---

## 9. Controls and Mitigations (Organized)

### 9.1 Prevent:
- Recalculate cart totals server-side; enforce 3D Secure.
- Cryptographically bind agent tokens to verified device enclaves.

### 9.2 Detect:
- Monitor abnormal transaction velocity + flag spikes.
- Enforce cryptographic tagging for auditability.

### 9.3 Recover:
- Implement kill-switches for compromised agent tokens.
- Graceful fallback to HITL if automation exceeds safety policies.

---

## 10. Validation and Testing Plan

| Test Name                  | Scenario                                              | Expected Outcome                     |
|----------------------------|------------------------------------------------------|--------------------------------------|
| **Baseline Price Check**   | Tampered cart value                                  | Server-side rejection.               |
| **Token Binding**          | Replay of Agent token                                | Signature rejection.                 |
| **Hard Caps**              | Exceeded cart value; HITL fallback                   | Agent degrades; human prompt shown.  |
| **Rapid Transactions**     | Excessive velocity by an Agent                       | Circuit breaker triggers revocation. |

---

## Contributors & Version History

- **Contributors**: @santoshtrip (Initial draft), SAFE team.
- **Version 1.0**: Initial Draft (2026-02-28).