#!/usr/bin/env bash
set -euo pipefail

# ── AgentForge Harness Skill 升级脚本 ──
# 拉取最新版本并更新已安装的 Skills + Plugins

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
PLUGINS_DIR="$CODEX_HOME/plugins"
REPO_URL="https://github.com/paskaa/agentforge-harness-skill.git"
UPGRADE_DIR="${CODEX_HOME}/.upgrade-tmp"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
info() { echo -e "${CYAN}[i]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*" >&2; }

# ── 清理旧的临时目录 ──
cleanup() { rm -rf "$UPGRADE_DIR" 2>/dev/null; }
trap cleanup EXIT

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   AgentForge Harness Skill Upgrader  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# ── 1. 拉取最新版本 ──
info "Fetching latest from $REPO_URL ..."
rm -rf "$UPGRADE_DIR"
git clone --depth 1 "$REPO_URL" "$UPGRADE_DIR" 2>/dev/null
log "Cloned to $UPGRADE_DIR"
echo ""

# ── 2. 对比版本 ──
LOCAL_VER=$(cat "$UPGRADE_DIR/VERSION" 2>/dev/null || echo "unknown")
REMOTE_VER=$(cat "$UPGRADE_DIR/VERSION" 2>/dev/null || echo "unknown")
info "Remote version: $REMOTE_VER"

# ── 3. 更新 Skills ──
info "Updating skills..."
count_new=0
count_updated=0
count_skipped=0

for skill_dir in "$UPGRADE_DIR/skills"/*/; do
  [[ -d "$skill_dir" ]] || continue
  name=$(basename "$skill_dir")
  target="$SKILLS_DIR/$name"

  if [[ -d "$target" ]]; then
    # 已存在 — 检查是否有变化
    if diff -rq "$skill_dir" "$target" &>/dev/null; then
      ((count_skipped++))
    else
      # 保留用户自定义文件，更新核心文件
      cp -r "$skill_dir"* "$target/"
      log "Updated: $name"
      ((count_updated++))
    fi
  else
    # 新安装
    cp -r "$skill_dir" "$target/"
    log "New: $name"
    ((count_new++))
  fi
done

log "Skills: $count_new new, $count_updated updated, $count_skipped unchanged"
echo ""

# ── 4. 更新 Plugins ──
info "Updating plugins..."
count_new=0
count_updated=0
count_skipped=0

for plugin_dir in "$UPGRADE_DIR/plugins"/*/; do
  [[ -d "$plugin_dir" ]] || continue
  name=$(basename "$plugin_dir")
  target="$PLUGINS_DIR/$name"

  if [[ -d "$target" ]]; then
    if diff -rq "$plugin_dir" "$target" &>/dev/null; then
      ((count_skipped++))
    else
      cp -r "$plugin_dir"* "$target/"
      log "Updated: $name"
      ((count_updated++))
    fi
  else
    cp -r "$plugin_dir" "$target/"
    log "New: $name"
    ((count_new++))
  fi
done

log "Plugins: $count_new new, $count_updated updated, $count_skipped unchanged"
echo ""

# ── 5. 更新 Agents ──
if [[ -d "$UPGRADE_DIR/agents" ]]; then
  info "Updating agents..."
  mkdir -p "$CODEX_HOME/agents"
  cp -r "$UPGRADE_DIR/agents"* "$CODEX_HOME/agents/" 2>/dev/null
  log "Agents updated"
  echo ""
fi

# ── 6. 更新 Rules ──
if [[ -d "$UPGRADE_DIR/rules" ]]; then
  info "Updating rules..."
  mkdir -p "$CODEX_HOME/rules"
  cp -r "$UPGRADE_DIR/rules"* "$CODEX_HOME/rules/" 2>/dev/null
  log "Rules updated"
  echo ""
fi

# ── 7. 更新安装脚本 ──
cp "$UPGRADE_DIR/install.sh" "$SCRIPT_DIR/install.sh" 2>/dev/null
cp "$UPGRADE_DIR/upgrade.sh" "$SCRIPT_DIR/upgrade.sh" 2>/dev/null
cp "$UPGRADE_DIR/README.md" "$SCRIPT_DIR/README.md" 2>/dev/null

# ── Done ──
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo -e "${GREEN}  Upgrade complete!${NC}"
echo -e "${GREEN}══════════════════════════════════════${NC}"
echo ""
echo "  Restart Codex CLI / Claude Code to activate new skills."
echo ""
