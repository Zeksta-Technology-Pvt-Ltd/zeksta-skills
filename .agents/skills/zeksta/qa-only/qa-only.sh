#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
qa-only.sh — light QA helper that never modifies code

Usage:
  ./.agents/skills/zeksta/qa-only/qa-only.sh
  ./.agents/skills/zeksta/qa-only/qa-only.sh --base origin/main --head HEAD
  ./.agents/skills/zeksta/qa-only/qa-only.sh --base main --head feature-branch --out qa-only-report.md

Options:
  --base REF     Base ref to diff from (default: origin/main, falls back to main, then master)
  --head REF     Head ref to diff to (default: HEAD)
  --out PATH     Output markdown report path (default: ./qa-only-report.md)
  -h, --help     Show help

What it does:
  - Lists changed files from git diff BASE..HEAD
  - Detects stack(s): react, react-native, node, flutter
  - Suggests relevant automated commands but does not run them
  - Writes a Markdown QA-notes template (for use with the /qa-only skill)
EOF
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
OUT="./qa-only-report.md"

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

mkdir -p -- "$(dirname -- "$OUT")"

cat >"$OUT" <<EOF
# QA-only notes

- Range: \`$BASE..$HEAD\`
- Generated: \`$(date -u +"%Y-%m-%dT%H:%M:%SZ")\`
- Detected stacks: \`${stacks[*]}\`

## Changed files

\`\`\`
${changed_files:-<none>}
\`\`\`

## Suggested automated commands (run manually)

EOF

if [[ "$has_package_json" == "1" ]]; then
  cat >>"$OUT" <<'EOF'
JS/TS project detected. Consider:

```bash
npm run lint   # or yarn/pnpm/bun equivalent
npm test
```

EOF
fi

if [[ "$has_pubspec" == "1" ]]; then
  cat >>"$OUT" <<'EOF'
Flutter project detected. Consider:

```bash
flutter analyze
flutter test
```

EOF
fi

{
  echo "## Manual QA notes"
  echo ""
  echo "- Scenario 1:"
  echo "  - Steps:"
  echo "  - Expected:"
  echo "  - Actual:"
  echo ""
  echo "- Scenario 2:"
  echo "  - Steps:"
  echo "  - Expected:"
  echo "  - Actual:"
} >>"$OUT"

echo "Wrote: $OUT"

