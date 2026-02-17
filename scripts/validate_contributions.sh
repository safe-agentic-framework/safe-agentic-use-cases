#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REGISTRY_FILE="use-cases.naics2022.crosswalk.json"
README_FILE="README.md"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "Required command not found: $1"
  fi
}

check_registry_schema() {
  echo "==> Checking registry schema and required fields"
  jq -e . "$REGISTRY_FILE" >/dev/null

  jq -e '
    type == "array" and length > 0 and
    all(.[]; 
      (.id | type == "string" and test("^SAFE-UC-[0-9]{4}$")) and
      (.title | type == "string" and length > 0) and
      (.status as $s | ($s | type == "string") and (["seed", "draft", "published"] | index($s) != null)) and
      (.repo_path | type == "string" and test("^use-cases/SAFE-UC-[0-9]{4}/README\\.md$")) and
      (.naics_2022 | type == "array" and length > 0 and
        all(.[]; (.code | type == "string" and length > 0) and (.name | type == "string" and length > 0))
      )
    )
  ' "$REGISTRY_FILE" >/dev/null || fail "Registry has invalid shape or unsupported status values."

  local total_ids unique_ids total_paths unique_paths
  total_ids="$(jq 'length' "$REGISTRY_FILE")"
  unique_ids="$(jq '[.[].id] | unique | length' "$REGISTRY_FILE")"
  total_paths="$(jq 'length' "$REGISTRY_FILE")"
  unique_paths="$(jq '[.[].repo_path] | unique | length' "$REGISTRY_FILE")"
  [[ "$total_ids" -eq "$unique_ids" ]] || fail "Duplicate use case IDs found in registry."
  [[ "$total_paths" -eq "$unique_paths" ]] || fail "Duplicate repo_path values found in registry."
}

check_registry_paths() {
  echo "==> Checking registry repo_path values and files"
  while IFS=$'\t' read -r id repo_path; do
    local expected_path
    expected_path="use-cases/${id}/README.md"

    [[ "$repo_path" == "$expected_path" ]] || fail "repo_path mismatch for ${id}: expected ${expected_path}, got ${repo_path}"
    [[ -f "$repo_path" ]] || fail "Missing file referenced by registry: ${repo_path}"
    rg -q "${id}" "$repo_path" || fail "Use case file does not contain its ID (${id}): ${repo_path}"
  done < <(jq -r '.[] | [.id, .repo_path] | @tsv' "$REGISTRY_FILE")
}

check_readme_index_consistency() {
  echo "==> Checking README index consistency with registry"
  local registry_rows readme_rows
  registry_rows="$(mktemp)"
  readme_rows="$(mktemp)"

  jq -r '.[] | [.id, .title, .status] | @tsv' "$REGISTRY_FILE" | LC_ALL=C sort >"$registry_rows"

  awk -F'|' '
    function trim(s) {
      gsub(/^[ \t]+|[ \t]+$/, "", s)
      return s
    }
    /^\| \[SAFE-UC-[0-9][0-9][0-9][0-9]\]\(/ {
      id = ""
      if (match($0, /SAFE-UC-[0-9]{4}/)) {
        id = substr($0, RSTART, RLENGTH)
      }
      title = trim($3)
      status = tolower(trim($5))
      print id "\t" title "\t" status
    }
  ' "$README_FILE" | LC_ALL=C sort >"$readme_rows"

  if ! diff -u "$registry_rows" "$readme_rows"; then
    fail "README index table does not match registry id/title/status values."
  fi

  rm -f "$registry_rows" "$readme_rows"
}

check_readme_index_links() {
  echo "==> Checking README index links"
  while IFS= read -r link_path; do
    [[ -e "$link_path" ]] || fail "README index links to missing path: ${link_path}"
  done < <(
    awk -F'|' '
      function trim(s) {
        gsub(/^[ \t]+|[ \t]+$/, "", s)
        return s
      }
      /^\| \[SAFE-UC-[0-9][0-9][0-9][0-9]\]\(/ {
        col = trim($2)
        if (match(col, /\(([^)]+)\)/)) {
          path = substr(col, RSTART + 1, RLENGTH - 2)
          print path
        }
      }
    ' "$README_FILE"
  )
}

check_markdown_local_links() {
  echo "==> Checking local markdown links"
  local has_errors=0

  while IFS= read -r row; do
    local file line_no match link link_target base_dir resolved
    file="${row%%:*}"
    row="${row#*:}"
    line_no="${row%%:*}"
    match="${row#*:}"
    link="$(printf '%s' "$match" | sed -E 's/.*\(([^)]+)\).*/\1/')"

    case "$link" in
      http://*|https://*|mailto:*|\#*|"")
        continue
        ;;
    esac

    link_target="${link%%#*}"
    [[ -n "$link_target" ]] || continue
    base_dir="$(dirname "$file")"
    resolved="$base_dir/$link_target"

    if [[ ! -e "$resolved" ]]; then
      echo "Broken local inline link: ${file}:${line_no} -> ${link}" >&2
      has_errors=1
    fi
  done < <(rg -n -o '\[[^]]+\]\(([^)]+)\)' --hidden --glob '*.md' --glob '!**/.git/**' || true)

  while IFS= read -r row; do
    local file line_no def target base_dir resolved
    file="${row%%:*}"
    row="${row#*:}"
    line_no="${row%%:*}"
    def="${row#*:}"
    target="$(printf '%s' "$def" | sed -E 's/^\[[^]]+\]:[[:space:]]*<?([^>[:space:]]+).*/\1/')"

    case "$target" in
      http://*|https://*|mailto:*|\#*|"")
        continue
        ;;
    esac

    target="${target%%#*}"
    [[ -n "$target" ]] || continue
    base_dir="$(dirname "$file")"
    resolved="$base_dir/$target"

    if [[ ! -e "$resolved" ]]; then
      echo "Broken local reference link: ${file}:${line_no} -> ${target}" >&2
      has_errors=1
    fi
  done < <(rg -n '^\[[^]]+\]:[[:space:]]+<?[^ >]+' --hidden --glob '*.md' --glob '!**/.git/**' || true)

  [[ "$has_errors" -eq 0 ]] || fail "Found broken local markdown links."
}

main() {
  require_cmd jq
  require_cmd rg
  require_cmd awk
  require_cmd sed
  require_cmd diff

  check_registry_schema
  check_registry_paths
  check_readme_index_consistency
  check_readme_index_links
  check_markdown_local_links

  echo "All contribution validation checks passed."
}

main "$@"
