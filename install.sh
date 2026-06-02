#!/usr/bin/env bash
set -euo pipefail

# ── AgentForge Harness Skill 一键安装脚本 ──
# 29 Skills · 2 Plugins · CodeGraph

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
PLUGINS_DIR="$CODEX_HOME/plugins"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
info() { echo -e "${CYAN}[i]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*" >&2; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   AgentForge Harness Skill Installer ║${NC}"
echo -e "${CYAN}║   29 Skills · 2 Plugins · CodeGraph  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# ── 1. Skills ──
info "Installing skills..."
mkdir -p "$SKILLS_DIR"
count=0
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  [[ -d "$skill_dir" ]] || continue
  name=$(basename "$skill_dir")
  if [[ -d "$SKILLS_DIR/$name" ]]; then
    warn "Skill $name already exists, skipping"
    continue
  fi
  cp -r "$skill_dir" "$SKILLS_DIR/"
  log "$name"
  ((count++))
done
log "Installed $count new skills"
echo ""

# ── 2. Plugins ──
info "Installing plugins..."
mkdir -p "$PLUGINS_DIR"
count=0
for plugin_dir in "$SCRIPT_DIR/plugins"/*/; do
  [[ -d "$plugin_dir" ]] || continue
  name=$(basename "$plugin_dir")
  if [[ -d "$PLUGINS_DIR/$name" ]]; then
    warn "Plugin $name already exists, skipping"
    continue
  fi
  cp -r "$plugin_dir" "$PLUGINS_DIR/"
  log "$name"
  ((count++))
done
log "Installed $count new plugins"
echo ""

# ── 3. CodeGraph ──
if command -v codegraph &>/dev/null; then
  ver=$(codegraph --version 2>/dev/null || echo "?")
  warn "CodeGraph already installed (v$ver)"
else
  info "Installing CodeGraph..."
  if [[ -f "$SCRIPT_DIR/tools/codegraph-install.sh" ]]; then
    bash "$SCRIPT_DIR/tools/codegraph-install.sh"
    log "CodeGraph installed"
  else
    warn "Install manually: curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh"
  fi
fi

if command -v codegraph &>/dev/null; then
  info "Configuring CodeGraph MCP for Codex..."
  codegraph install --target codex --yes 2>/dev/null && log "MCP server configured" || warn "MCP config may need manual setup"
fi
echo ""

# ── Done ──
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo ""
echo "  Skills:  $SKILLS_DIR"
echo "  Plugins: $PLUGINS_DIR"
echo ""
echo "  Restart Codex CLI / Claude Code to activate."
echo ""
