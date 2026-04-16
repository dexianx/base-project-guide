#!/usr/bin/env bash
# base-project-guide installer
# Copies commands and skills into the right places for your AI agent.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$REPO_DIR/commands"
SKILLS_DIR="$REPO_DIR/skills"

# ── colours ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

# ── helpers ────────────────────────────────────────────────────────────────────
print_header() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${CYAN}║       base-project-guide install     ║${RESET}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════╝${RESET}"
  echo ""
}

ok()   { echo -e "  ${GREEN}✓${RESET}  $1"; }
info() { echo -e "  ${CYAN}→${RESET}  $1"; }
warn() { echo -e "  ${YELLOW}!${RESET}  $1"; }

# ── detection ──────────────────────────────────────────────────────────────────
has_claude()    { command -v claude    &>/dev/null || [ -d "$HOME/.claude" ]; }
has_opencode()  { command -v opencode  &>/dev/null || [ -d "$HOME/.config/opencode" ]; }
has_cursor()    { command -v cursor    &>/dev/null || [ -d "$HOME/.cursor" ]; }
has_windsurf()  { command -v windsurf  &>/dev/null; }
has_git()       { command -v git       &>/dev/null; }

# ── installers ─────────────────────────────────────────────────────────────────

install_claude_code() {
  local target="$1"   # path to the project root (or ~/.claude for global)
  local global="$2"   # "true" | "false"

  if [ "$global" = "true" ]; then
    local dest="$HOME/.claude/commands"
  else
    local dest="$target/.claude/commands"
  fi

  mkdir -p "$dest"
  cp "$COMMANDS_DIR"/*.md "$dest/"
  ok "Claude Code commands → $dest"

  # skills (only for local install — global skills aren't supported yet)
  if [ "$global" = "false" ]; then
    local sdest="$target/.claude/skills"
    mkdir -p "$sdest/agent-browser" "$sdest/e2e-test"
    cp "$SKILLS_DIR/agent-browser/SKILL.md" "$sdest/agent-browser/"
    cp "$SKILLS_DIR/e2e-test/SKILL.md"      "$sdest/e2e-test/"
    ok "Claude Code skills   → $sdest"
  fi
}

install_opencode() {
  local target="$1"
  local global="$2"

  if [ "$global" = "true" ]; then
    local dest="$HOME/.config/opencode/commands"
  else
    local dest="$target/.opencode/commands"
  fi

  mkdir -p "$dest"
  cp "$COMMANDS_DIR"/*.md "$dest/"
  ok "OpenCode commands → $dest"

  # Copy AGENTS.md as the project context file
  if [ "$global" = "false" ] && [ ! -f "$target/AGENTS.md" ]; then
    cp "$REPO_DIR/AGENTS.md" "$target/AGENTS.md"
    ok "AGENTS.md → $target/AGENTS.md"
  fi
}

install_cursor() {
  local target="$1"
  # Cursor only supports local (project-level) rules
  local dest="$target/.cursor/rules"
  mkdir -p "$dest"

  for f in "$COMMANDS_DIR"/*.md; do
    base="$(basename "$f" .md)"
    # Add Cursor-specific frontmatter then append original content
    {
      echo "---"
      # Extract description from existing frontmatter if present
      desc=$(awk '/^---/{p++} p==1 && /^description:/{print; exit}' "$f" | sed 's/^description: *//')
      if [ -n "$desc" ]; then
        echo "description: $desc"
      else
        echo "description: $base"
      fi
      echo "alwaysApply: false"
      echo "---"
      echo ""
      # Strip existing frontmatter block before appending body
      awk 'BEGIN{p=0} /^---/{p++; if(p==2){p=3; next}} p==3{print} p==0{print}' "$f"
    } > "$dest/$base.mdc"
  done

  ok "Cursor rules (.mdc) → $dest"
}

install_windsurf() {
  local target="$1"
  local dest="$target/.windsurf/rules"
  mkdir -p "$dest"
  cp "$COMMANDS_DIR"/*.md "$dest/"
  ok "Windsurf rules → $dest"
}

install_copilot() {
  local target="$1"
  local dest="$target/.github/copilot-instructions.md"
  mkdir -p "$target/.github"

  # Append AGENTS.md content (or create fresh)
  if [ -f "$dest" ]; then
    warn ".github/copilot-instructions.md already exists — appending base-project-guide section"
    echo "" >> "$dest"
    echo "---" >> "$dest"
    echo "## base-project-guide commands" >> "$dest"
    echo "" >> "$dest"
    tail -n +2 "$REPO_DIR/AGENTS.md" >> "$dest"
  else
    cp "$REPO_DIR/AGENTS.md" "$dest"
  fi

  ok "GitHub Copilot → $dest"
}

# ── interactive menu ───────────────────────────────────────────────────────────

print_header

# --- which project? ---
DEFAULT_TARGET="$(pwd)"
if [ "$DEFAULT_TARGET" = "$REPO_DIR" ]; then
  echo -e "${BOLD}Target project directory${RESET}"
  echo -e "  Current dir is the base-project-guide repo itself."
  read -rp "  Enter the path to your project (or press Enter to use current dir): " custom_target
  TARGET="${custom_target:-$DEFAULT_TARGET}"
else
  TARGET="$DEFAULT_TARGET"
fi
echo ""
info "Installing into: $TARGET"
echo ""

# --- which agent(s)? ---
echo -e "${BOLD}Which agent(s) would you like to install for?${RESET}"
echo ""

# Build dynamic list based on what's detected
AGENTS=()
DETECTED=()

has_claude   && DETECTED+=("claude")   || true
has_opencode && DETECTED+=("opencode") || true
has_cursor   && DETECTED+=("cursor")   || true
has_windsurf && DETECTED+=("windsurf") || true

ALL_AGENTS=("claude" "opencode" "cursor" "windsurf" "copilot")
i=1
for a in "${ALL_AGENTS[@]}"; do
  label="$a"
  suffix=""
  for d in "${DETECTED[@]}"; do
    [ "$d" = "$a" ] && suffix=" ${GREEN}(detected)${RESET}"
  done
  echo -e "  $i) $label$suffix"
  AGENTS+=("$a")
  ((i++))
done
echo "  $i) All of the above"
ALL_IDX=$i
echo ""

read -rp "Choice(s) — comma-separated (e.g. 1,3) or single number: " raw_choice
echo ""

# Parse choices
SELECTED=()
IFS=',' read -ra parts <<< "$raw_choice"
for p in "${parts[@]}"; do
  p="${p// /}"   # trim spaces
  if [ "$p" = "$ALL_IDX" ]; then
    SELECTED=("${ALL_AGENTS[@]}")
    break
  elif [[ "$p" =~ ^[0-9]+$ ]] && [ "$p" -ge 1 ] && [ "$p" -le "${#AGENTS[@]}" ]; then
    SELECTED+=("${AGENTS[$((p-1))]}")
  fi
done

if [ "${#SELECTED[@]}" -eq 0 ]; then
  warn "No valid selection. Exiting."
  exit 1
fi

# --- global or local? (not applicable for cursor/copilot) ---
GLOBAL="false"
needs_scope=false
for s in "${SELECTED[@]}"; do
  [ "$s" = "claude" ] || [ "$s" = "opencode" ] && needs_scope=true
done

if $needs_scope; then
  echo -e "${BOLD}Install scope${RESET}"
  echo "  1) Local  — copy into $TARGET (project-level, committed to git)"
  echo "  2) Global — copy into your home config (available in all projects)"
  echo ""
  read -rp "Choice (1/2, default 1): " scope_choice
  [ "$scope_choice" = "2" ] && GLOBAL="true"
  echo ""
fi

# ── run installs ───────────────────────────────────────────────────────────────
echo -e "${BOLD}Installing...${RESET}"
echo ""

for agent in "${SELECTED[@]}"; do
  case "$agent" in
    claude)   install_claude_code "$TARGET" "$GLOBAL" ;;
    opencode) install_opencode    "$TARGET" "$GLOBAL" ;;
    cursor)   install_cursor      "$TARGET" ;;
    windsurf) install_windsurf    "$TARGET" ;;
    copilot)  install_copilot     "$TARGET" ;;
  esac
done

# ── done ───────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}Done.${RESET}"
echo ""
echo "Next steps:"
echo "  1. Open your project in your agent"
if [[ " ${SELECTED[*]} " =~ " claude " ]]; then
  echo "  2. Claude Code: run /prime to load project context"
fi
if [[ " ${SELECTED[*]} " =~ " opencode " ]]; then
  echo "  2. OpenCode: run /prime to load project context"
fi
echo "  3. Try: /plan-feature <describe what you want to build>"
echo ""
