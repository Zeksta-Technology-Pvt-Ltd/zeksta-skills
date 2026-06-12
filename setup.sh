#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Zeksta Skills setup

Installs the Zeksta skills (SKILL.md files) for agent hosts that discover skills in:
  - Repo-local: <repo>/.agents/skills/<skill-name>
  - User-global (Codex): ~/.codex/skills/<skill-name>
  - User-global (VS Code Copilot): ~/.copilot/skills/<skill-name>

Usage:
  ./setup.sh [--global]
  ./setup.sh --vscode
  ./setup.sh --repo <path-to-target-repo>
  ./setup.sh --global --force
  ./setup.sh --vscode --force
  ./setup.sh --repo <path> --force

Options:
  --global        Install to ~/.codex/skills/<skill-name> (default)
  --vscode        Install to ~/.copilot/skills/<skill-name>
  --repo PATH     Vendor into PATH/.agents/skills/
  --force         Overwrite existing install (otherwise errors if target exists)
  -h, --help      Show help

Examples:
  ./setup.sh
  ./setup.sh --vscode
  ./setup.sh --repo ../my-app
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_SKILLS_DIR="$SCRIPT_DIR/.agents/skills"
SKILLS=(zeksta-review zeksta-qa zeksta-qa-only)

if [[ ! -d "$SRC_SKILLS_DIR" ]]; then
  echo "ERROR: Source skills not found at: $SRC_SKILLS_DIR" >&2
  exit 1
fi

mode="global"
target_repo=""
force="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      mode="global"
      shift
      ;;
    --vscode)
      mode="vscode"
      shift
      ;;
    --repo)
      mode="repo"
      target_repo="${2:-}"
      if [[ -z "$target_repo" ]]; then
        echo "ERROR: --repo requires a path" >&2
        exit 1
      fi
      shift 2
      ;;
    --force)
      force="1"
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

if [[ "$mode" == "global" ]]; then
  dest="$HOME/.codex/skills"
elif [[ "$mode" == "vscode" ]]; then
  dest="$HOME/.copilot/skills"
else
  if [[ ! -d "$target_repo" ]]; then
    echo "ERROR: Target repo not found: $target_repo" >&2
    exit 1
  fi
  dest="$target_repo/.agents/skills"
fi

mkdir -p -- "$dest"

for skill in "${SKILLS[@]}"; do
  src="$SRC_SKILLS_DIR/$skill"
  if [[ ! -d "$src" ]]; then
    echo "ERROR: Missing source skill directory: $src" >&2
    exit 1
  fi

  target="$dest/$skill"
  if [[ -e "$target" ]]; then
    if [[ "$force" == "1" ]]; then
      rm -rf -- "$target"
    else
      echo "ERROR: Destination already exists: $target" >&2
      echo "Re-run with --force to overwrite." >&2
      exit 1
    fi
  fi

  mkdir -p -- "$target"
  cp -R -- "$src/"* "$target/"
  echo "Installed: $target"
done

if [[ "$mode" == "global" ]]; then
  echo "Done (Codex). Commands: /zeksta-review, /zeksta-qa, /zeksta-qa-only"
elif [[ "$mode" == "vscode" ]]; then
  echo "Done (VS Code Copilot). Commands: /zeksta-review, /zeksta-qa, /zeksta-qa-only"
else
  echo "Installed Zeksta skills to: $dest"
  echo "Commands: /zeksta-review, /zeksta-qa, /zeksta-qa-only"
fi
