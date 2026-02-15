# SAFE-Agentic Use Case Analysis (SAFE-AUCA)

SAFE-AUCA is a community library of **real-world use case analyses** for agentic workflows (MCP-enabled systems and tool-using agents), **mapped to SAFE‑MCP techniques**.

**SAFE‑MCP** → catalogs *what can go wrong* (attack/failure techniques)  
**SAFE‑AUCA** → shows *where it happens in reality* (workflow + tools + trust boundaries + autonomy) and turns techniques into **controls + tests**

Quick links:
- SAFE‑MCP technique catalog: https://github.com/safe-agentic-framework/safe-mcp
- Contributing: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Use case template: [`templates/use-case-template.md`](templates/use-case-template.md)
- Canonical (machine‑readable) registry: [`use-cases.naics2022.crosswalk.json`](use-cases.naics2022.crosswalk.json)

---

## Why we do use case analysis

Techniques alone aren’t enough: the *same* technique can be low-risk in one workflow and catastrophic in another.

Each detailed use case analysis connects the dots:

**Workflow + operating mode (manual → HITL → autonomous)**  
→ **Kill-chain / failure analysis** (defender-friendly; no exploit steps)  
→ **SAFE‑MCP technique IDs**  
→ **Controls, detections, and validation tests**

---

## Contribute (fast path)

We seed a stable list of `SAFE-UC-XXXX` IDs (like SAFE‑MCP), then contributors “pick up” an ID and write the detailed analysis.

1) Pick a use case ID below with **Status = Seed**  
2) Create the folder at the linked canonical location and write the README using the template  
3) Update the canonical registry (`use-cases.naics2022.crosswalk.json`) and open a PR

Safety rules (non‑negotiable): **no sensitive info, no exploit instructions, grounded in public evidence** (see `CONTRIBUTING.md`).

---

## SAFE Use Case ID ↔ NAICS 2022 crosswalk

**How to read this table**
- **One row per use case** (`SAFE-UC-XXXX` is the primary object).
- **NAICS is a crosswalk/mapping field**, not a parent folder.
- A use case can map to **multiple NAICS codes** (shown in the same row).
- Some NAICS sectors use combined-sector shorthand (e.g., **31–33**, **44–45**, **48–49**).

**Status legend**
- **Seed**: ID reserved + mapping exists; detailed write-up may not exist yet (you can contribute it)
- **Starter**: starter write-up exists and can be expanded
- *(optional future)* Draft / Published

| SAFE Use Case ID | Use case title | NAICS 2022 industry mapping (Name + Code) | Status |
|---|---|---|---|
| [SAFE-UC-0001](use-cases/SAFE-UC-0001/) | AI-assisted seller listing creation | [Retail Trade (44–45)][naics-44-45] | Seed |
| [SAFE-UC-0002](use-cases/SAFE-UC-0002/) | Personalized shopping sidekick | [Retail Trade (44–45)][naics-44-45] | Seed |
| [SAFE-UC-0003](use-cases/SAFE-UC-0003/) | Buyer-seller messaging assistant | [Retail Trade (44–45)][naics-44-45] | Seed |
| [SAFE-UC-0004](use-cases/SAFE-UC-0004/) | Listing media enhancement assistant | [Retail Trade (44–45)][naics-44-45] | Seed |
| [SAFE-UC-0005](use-cases/SAFE-UC-0005/) | Visual search & image-based product discovery | [Retail Trade (44–45)][naics-44-45] | Seed |
| [SAFE-UC-0006](use-cases/SAFE-UC-0006/) | Fleet telematics & vehicle-health monitoring assistant | [Transportation and Warehousing (48–49)][naics-48-49] | Seed |
| [SAFE-UC-0007](use-cases/SAFE-UC-0007/) | Mobile fleet-maintenance dispatch & scheduling assistant | [Other Services (except Public Administration) (81)][naics-81] | Seed |
| [SAFE-UC-0008](use-cases/SAFE-UC-0008/) | Over-the-air vehicle software update orchestration | [Manufacturing (31–33)][naics-31-33] | Seed |
| [SAFE-UC-0009](use-cases/SAFE-UC-0009/) | Manufacturing line visual inspection assistant | [Manufacturing (31–33)][naics-31-33] | Seed |
| [SAFE-UC-0010](use-cases/SAFE-UC-0010/) | In-vehicle voice assistant for local controls | [Manufacturing (31–33)][naics-31-33] | Seed |
| [SAFE-UC-0011](use-cases/SAFE-UC-0011/) | Banking virtual assistant | [Finance and Insurance (52)][naics-52] | Seed |
| [SAFE-UC-0012](use-cases/SAFE-UC-0012/) | Interactive fraud alert & card controls assistant | [Finance and Insurance (52)][naics-52] | Seed |
| [SAFE-UC-0013](use-cases/SAFE-UC-0013/) | Virtual card number generation & checkout assistant | [Finance and Insurance (52)][naics-52] | Seed |
| [SAFE-UC-0014](use-cases/SAFE-UC-0014/) | Digital dispute/chargeback intake assistant | [Finance and Insurance (52)][naics-52] | Seed |
| [SAFE-UC-0015](use-cases/SAFE-UC-0015/) | AML suspicious-activity triage assistant | [Finance and Insurance (52)][naics-52] | Seed |
| [SAFE-UC-0016](use-cases/SAFE-UC-0016/) | IT service-desk virtual agent | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0017](use-cases/SAFE-UC-0017/) | Service request triage assistant | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0018](use-cases/SAFE-UC-0018/) | Work-item summarization assistant (thread + context summaries) | [Information (51)][naics-51]<br>[Software Publishers (513210)][naics-513210] | Starter |
| [SAFE-UC-0019](use-cases/SAFE-UC-0019/) | Post-incident review drafting assistant | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0020](use-cases/SAFE-UC-0020/) | On-call incident context assistant | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0021](use-cases/SAFE-UC-0021/) | Contact-center agent assist | [Administrative and Support and Waste Management and Remediation Services (56)][naics-56] | Seed |
| [SAFE-UC-0022](use-cases/SAFE-UC-0022/) | Security operations investigation assistant | [Professional, Scientific, and Technical Services (54)][naics-54] | Seed |
| [SAFE-UC-0023](use-cases/SAFE-UC-0023/) | Cloud ops troubleshooting assistant | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0024](use-cases/SAFE-UC-0024/) | Terminal-based outage assistant for SRE | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0025](use-cases/SAFE-UC-0025/) | Enterprise agent-building platform | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0026](use-cases/SAFE-UC-0026/) | At-scale content policy enforcement pipeline | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0027](use-cases/SAFE-UC-0027/) | Anti-scam messaging safety assistant | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0028](use-cases/SAFE-UC-0028/) | Fake-account & inauthentic behavior detection assistant | [Information (51)][naics-51] | Seed |
| [SAFE-UC-0029](use-cases/SAFE-UC-0029/) | Automated ad campaign optimization assistant | [Professional, Scientific, and Technical Services (54)][naics-54] | Seed |
| [SAFE-UC-0030](use-cases/SAFE-UC-0030/) | Teen safety & age-assurance enforcement assistant | [Information (51)][naics-51] | Seed |

---

### NAICS links (official U.S. Census Bureau)

[naics-31-33]: https://www.census.gov/data/tables/2022/econ/economic-census/naics-sector-31-33.html
[naics-44-45]: https://www.census.gov/data/tables/2022/econ/economic-census/naics-sector-44-45.html
[naics-48-49]: https://www.census.gov/data/tables/2022/econ/economic-census/naics-sector-48-49.html

[naics-51]: https://www.census.gov/naics/?chart=2022&details=51&input=51
[naics-52]: https://www.census.gov/naics/?chart=2022&details=52&input=52
[naics-54]: https://www.census.gov/naics/?chart=2022&details=54&input=54
[naics-56]: https://www.census.gov/naics/?chart=2022&details=56&input=56
[naics-81]: https://www.census.gov/naics/?chart=2022&details=81&input=81
[naics-513210]: https://www.census.gov/naics/?chart=2022&details=513210&input=513210
