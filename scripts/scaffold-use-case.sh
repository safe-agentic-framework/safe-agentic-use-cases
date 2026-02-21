#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# scaffold-use-case.sh — Create a seed use case (folder, README, registry, index)
#
# Usage:
#   ./scripts/scaffold-use-case.sh \
#     --id SAFE-UC-0034 \
#     --title "Supply chain prediction assistant" \
#     --summary "Predict supply chain disruptions ..." \
#     --naics '[{"code":"48-49","name":"Transportation and Warehousing"}]' \
#     --evidence "https://example.com/1\nhttps://example.com/2" \
#     --author "octocat" \
#     --date "2026-02-21"
###############################################################################

# ── Parse arguments ──────────────────────────────────────────────────────────

SAFE_UC_ID=""
TITLE=""
SUMMARY=""
NAICS_JSON=""
EVIDENCE=""
AUTHOR=""
DATE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id)       SAFE_UC_ID="$2"; shift 2 ;;
    --title)    TITLE="$2";      shift 2 ;;
    --summary)  SUMMARY="$2";    shift 2 ;;
    --naics)    NAICS_JSON="$2"; shift 2 ;;
    --evidence) EVIDENCE="$2";   shift 2 ;;
    --author)   AUTHOR="$2";     shift 2 ;;
    --date)     DATE="$2";       shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ── Validate inputs ──────────────────────────────────────────────────────────

: "${SAFE_UC_ID:?Missing --id}"
: "${TITLE:?Missing --title}"
: "${SUMMARY:?Missing --summary}"
: "${NAICS_JSON:?Missing --naics}"
: "${EVIDENCE:?Missing --evidence}"
: "${AUTHOR:?Missing --author}"
: "${DATE:?Missing --date}"

[[ "$SAFE_UC_ID" =~ ^SAFE-UC-[0-9]{4}$ ]] || { echo "Invalid ID format: $SAFE_UC_ID" >&2; exit 1; }
echo "$NAICS_JSON" | jq -e 'type == "array" and length > 0' >/dev/null 2>&1 || { echo "Invalid NAICS JSON" >&2; exit 1; }

# ── Setup paths ──────────────────────────────────────────────────────────────

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REGISTRY_FILE="use-cases.naics2022.crosswalk.json"
README_FILE="README.md"
UC_DIR="use-cases/${SAFE_UC_ID}"

if [[ -d "$UC_DIR" ]]; then
  echo "Directory already exists: $UC_DIR" >&2
  exit 1
fi

# ── Backup originals for rollback ────────────────────────────────────────────

cp "$REGISTRY_FILE" "${REGISTRY_FILE}.bak"
cp "$README_FILE" "${README_FILE}.bak"

rollback() {
  echo "Rolling back changes..." >&2
  mv -f "${REGISTRY_FILE}.bak" "$REGISTRY_FILE"
  mv -f "${README_FILE}.bak" "$README_FILE"
  rm -rf "$UC_DIR"
}
trap rollback ERR

# ── 1. Create directory ─────────────────────────────────────────────────────

mkdir -p "$UC_DIR"

# ── 2. Build NAICS display string for seed README metadata ───────────────────

NAICS_DISPLAY=""
NAICS_COUNT=$(echo "$NAICS_JSON" | jq 'length')
for i in $(seq 0 $((NAICS_COUNT - 1))); do
  CODE=$(echo "$NAICS_JSON" | jq -r ".[$i].code")
  NAME=$(echo "$NAICS_JSON" | jq -r ".[$i].name")
  if [[ -n "$NAICS_DISPLAY" ]]; then
    NAICS_DISPLAY="${NAICS_DISPLAY}, "
  fi
  NAICS_DISPLAY="${NAICS_DISPLAY}${NAME} (${CODE})"
done

# ── 3. Build evidence bullet list ───────────────────────────────────────────

EVIDENCE_LINES=""
while IFS= read -r line; do
  line="$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
  [[ -z "$line" ]] && continue
  EVIDENCE_LINES="${EVIDENCE_LINES}
- ${line}"
done <<< "$EVIDENCE"
# Remove leading newline
EVIDENCE_LINES="${EVIDENCE_LINES#$'\n'}"

# ── 4. Create seed README ───────────────────────────────────────────────────

cat > "${UC_DIR}/README.md" << SEEDEOF
# ${TITLE}

> Seed page for **SAFE-AUCA**. Expand this into a full analysis using [\`templates/use-case-template.md\`](../../templates/use-case-template.md).

## Metadata

| Field | Value |
|---|---|
| **SAFE Use Case ID** | \`${SAFE_UC_ID}\` |
| **Status** | \`seed\` |
| **NAICS 2022** | \`${NAICS_DISPLAY}\` |
| **Last updated** | \`${DATE}\` |

### Evidence (public links)

${EVIDENCE_LINES}

## Workflow Description (Seed)

${SUMMARY}

## In Scope / Out Of Scope

- **In scope:** TBD
- **Out of scope:** TBD

## SAFE-MCP Mapping (Seed Skeleton)

| Kill-chain stage | Failure/attack pattern | SAFE-MCP technique(s) | Recommended controls | Tests |
|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD |

## Next Steps

- Expand this page to \`draft\` using the full template in \`templates/use-case-template.md\`.
- Add public evidence links and concrete control/test mappings.
SEEDEOF

# ── 5. Append to registry JSON ──────────────────────────────────────────────

REGISTRY_ENTRY=$(jq -n \
  --arg id "$SAFE_UC_ID" \
  --arg title "$TITLE" \
  --arg repo_path "use-cases/${SAFE_UC_ID}/README.md" \
  --argjson naics "$NAICS_JSON" \
  --arg summary "$SUMMARY" \
  '{id: $id, title: $title, status: "seed", repo_path: $repo_path, naics_2022: $naics, summary: $summary}')

jq --argjson entry "$REGISTRY_ENTRY" '. += [$entry]' "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp"
mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"

# ── 6. Insert row in README.md index table ───────────────────────────────────

# Build NAICS column (with en-dash for combined sectors, reference-style links)
NAICS_TABLE_COL=""
for i in $(seq 0 $((NAICS_COUNT - 1))); do
  CODE=$(echo "$NAICS_JSON" | jq -r ".[$i].code")
  NAME=$(echo "$NAICS_JSON" | jq -r ".[$i].name")
  # Use en-dash (–) for display of combined sector codes like 44-45 → 44–45
  DISPLAY_CODE=$(echo "$CODE" | sed 's/-/–/')
  SLUG="naics-${CODE}"
  if [[ -n "$NAICS_TABLE_COL" ]]; then
    NAICS_TABLE_COL="${NAICS_TABLE_COL}<br>"
  fi
  NAICS_TABLE_COL="${NAICS_TABLE_COL}[${NAME} (${DISPLAY_CODE})][${SLUG}]"
done

TABLE_ROW="| [${SAFE_UC_ID}](use-cases/${SAFE_UC_ID}/) | ${TITLE} | ${NAICS_TABLE_COL} | Seed |"

# Insert the new row after the last existing table row
awk -v row="$TABLE_ROW" '
  /^\| \[SAFE-UC-[0-9][0-9][0-9][0-9]\]\(/ { last_line = NR }
  { lines[NR] = $0 }
  END {
    for (i = 1; i <= NR; i++) {
      print lines[i]
      if (i == last_line) {
        print row
      }
    }
  }
' "$README_FILE" > "${README_FILE}.tmp"
mv "${README_FILE}.tmp" "$README_FILE"

# ── 7. Add NAICS reference link definitions if missing ───────────────────────

for i in $(seq 0 $((NAICS_COUNT - 1))); do
  CODE=$(echo "$NAICS_JSON" | jq -r ".[$i].code")
  SLUG="naics-${CODE}"

  if ! grep -q "^\[${SLUG}\]:" "$README_FILE"; then
    # Determine Census Bureau URL based on code format
    case "$CODE" in
      *-*) URL="https://www.census.gov/data/tables/2022/econ/economic-census/naics-sector-${CODE}.html" ;;
      *)   URL="https://www.census.gov/naics/?chart=2022&details=${CODE}&input=${CODE}" ;;
    esac
    echo "[${SLUG}]: ${URL}" >> "$README_FILE"
  fi
done

# ── 8. Clean up backups (success path) ──────────────────────────────────────

trap - ERR
rm -f "${REGISTRY_FILE}.bak" "${README_FILE}.bak"

echo "Scaffold complete for ${SAFE_UC_ID}: ${TITLE}"
