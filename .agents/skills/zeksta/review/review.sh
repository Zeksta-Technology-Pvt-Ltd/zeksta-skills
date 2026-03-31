#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
review.sh — generate a review-ready report from a git range

Usage:
  ./.agents/skills/zeksta/review/review.sh
  ./.agents/skills/zeksta/review/review.sh --base origin/main --head HEAD
  ./.agents/skills/zeksta/review/review.sh --base main --head feature-branch --out review-report.md
  ./.agents/skills/zeksta/review/review.sh --run

Options:
  --base REF     Base ref to diff from (default: origin/main, falls back to main, then master)
  --head REF     Head ref to diff to (default: HEAD)
  --out PATH     Output markdown report path (default: ./review-report.md)
  --run          Actually run detected lint/test commands when available
  --no-run       Do not run commands (default)
  -h, --help     Show help

What it does:
  - Detects changed files from git diff BASE..HEAD
  - Detects stack(s): react, react-native, node, flutter
  - Suggests (and optionally runs) common lint/test commands if tools exist
  - Writes a Markdown report you can paste into a PR

Notes:
  - This script never modifies code.
  - It does not install dependencies; it only runs commands if the tool exists.
EOF
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1
}

pick_default_base() {
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    echo "origin/main"
  elif git show-ref --verify --quiet refs/heads/main; then
    echo "main"
  elif git show-ref --verify --quiet refs/heads/master; then
    echo "master"
  else
    echo "HEAD~1"
  fi
}

BASE="$(pick_default_base)"
HEAD="HEAD"
OUT="./review-report.md"
RUN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      BASE="${2:-}"; [[ -n "$BASE" ]] || { echo "ERROR: --base requires REF" >&2; exit 1; }
      shift 2
      ;;
    --head)
      HEAD="${2:-}"; [[ -n "$HEAD" ]] || { echo "ERROR: --head requires REF" >&2; exit 1; }
      shift 2
      ;;
    --out)
      OUT="${2:-}"; [[ -n "$OUT" ]] || { echo "ERROR: --out requires PATH" >&2; exit 1; }
      shift 2
      ;;
    --run)
      RUN="1"
      shift
      ;;
    --no-run)
      RUN="0"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not inside a git repo." >&2
  exit 1
fi

changed_files="$(git diff --name-only "$BASE..$HEAD" || true)"
if [[ -z "$changed_files" ]]; then
  echo "No changes detected for range: $BASE..$HEAD"
fi

has_package_json="0"
has_pubspec="0"
if [[ -f "package.json" ]]; then has_package_json="1"; fi
if [[ -f "pubspec.yaml" ]]; then has_pubspec="1"; fi

detect_react="0"
detect_react_native="0"
detect_node="0"
detect_flutter="0"

if [[ "$has_pubspec" == "1" ]]; then
  detect_flutter="1"
fi

if [[ "$has_package_json" == "1" ]]; then
  # Very lightweight detection: do not parse JSON with jq (not guaranteed).
  if rg -q "\"react-native\"" package.json 2>/dev/null; then
    detect_react_native="1"
  fi
  if rg -q "\"react\"" package.json 2>/dev/null; then
    detect_react="1"
  fi
  detect_node="1"
fi

if echo "$changed_files" | rg -q '\.(tsx|jsx)$' 2>/dev/null; then
  detect_react="1"
fi
if echo "$changed_files" | rg -q '(^|/)(android|ios)/' 2>/dev/null; then
  detect_react_native="1"
fi
if echo "$changed_files" | rg -q '\.dart$' 2>/dev/null; then
  detect_flutter="1"
fi

stacks=()
[[ "$detect_react" == "1" ]] && stacks+=("react")
[[ "$detect_react_native" == "1" ]] && stacks+=("react-native")
[[ "$detect_node" == "1" ]] && stacks+=("node")
[[ "$detect_flutter" == "1" ]] && stacks+=("flutter")

if [[ ${#stacks[@]} -eq 0 ]]; then
  stacks+=("unknown")
fi

run_section() {
  local title="$1"
  local cmd="$2"
  {
    echo ""
    echo "#### ${title}"
    echo ""
    echo '```bash'
    echo "$cmd"
    echo '```'
    echo ""
  } >>"$OUT"

  if [[ "$RUN" != "1" ]]; then
    return 0
  fi

  {
    echo ""
    echo "Output:"
    echo ""
    echo '```'
  } >>"$OUT"

  # shellcheck disable=SC2086
  if bash -lc "$cmd" >>"$OUT" 2>&1; then
    echo "" >>"$OUT"
  else
    echo "" >>"$OUT"
    echo "(command failed; see output above)" >>"$OUT"
  fi

  echo '```' >>"$OUT"
}

mkdir -p -- "$(dirname -- "$OUT")"

cat >"$OUT" <<EOF
# Code review report

- Range: \`$BASE..$HEAD\`
- Generated: \`$(date -u +"%Y-%m-%dT%H:%M:%SZ")\`
- Detected stacks: \`${stacks[*]}\`

## Changed files

\`\`\`
${changed_files:-<none>}
\`\`\`

## Diff stats

\`\`\`
$(git diff --stat "$BASE..$HEAD" || true)
\`\`\`

## Suggested validation commands

> Tip: re-run with \`--run\` to execute these (when possible).
EOF

if [[ "$has_package_json" == "1" ]]; then
  pkg_mgr="npm"
  if require_cmd pnpm && [[ -f "pnpm-lock.yaml" ]]; then pkg_mgr="pnpm"; fi
  if require_cmd yarn && ([[ -f "yarn.lock" ]] || [[ -f ".yarnrc.yml" ]]); then pkg_mgr="yarn"; fi
  if require_cmd bun && [[ -f "bun.lock" ]]; then pkg_mgr="bun"; fi

  run_section "JS/TS: install (if needed)" "$pkg_mgr install"
  run_section "JS/TS: lint (if configured)" "$pkg_mgr run lint"
  run_section "JS/TS: typecheck (if configured)" "$pkg_mgr run typecheck"
  run_section "JS/TS: tests (if configured)" "$pkg_mgr test"
fi

if [[ "$has_pubspec" == "1" ]]; then
  if require_cmd flutter; then
    run_section "Flutter: pub get" "flutter pub get"
    run_section "Flutter: analyze (if used)" "flutter analyze"
    run_section "Flutter: tests" "flutter test"
  else
    {
      echo ""
      echo "#### Flutter commands"
      echo ""
      echo "Flutter detected but \`flutter\` is not on PATH. Suggested:"
      echo ""
      echo '```bash'
      echo "flutter pub get"
      echo "flutter analyze"
      echo "flutter test"
      echo '```'
    } >>"$OUT"
  fi
fi

{
  echo ""
  echo "## Reviewer checklist"
  echo ""
  echo "- [ ] Goal matches diff"
  echo "- [ ] No obvious security issues at boundaries (authz, input validation, injection)"
  echo "- [ ] Error handling and logging follow project conventions"
  echo "- [ ] UI flows validated (happy/error/loading/empty states)"
  echo "- [ ] Tests/lints passing (see above)"
  echo ""
  echo "## Notes"
  echo ""
  echo "- This report is evidence for review; it does not replace human judgment."
} >>"$OUT"

echo "Wrote: $OUT"

