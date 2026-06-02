#!/bin/bash
# AgentForge Harness Engineering 一键安装脚本
# 用法:
#   本地安装: bash install.sh
#   GitHub安装: bash install.sh --github

set -e

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
REPO="paskaa/agentforge-harness-skill"

echo "🔧 AgentForge Harness Engineering 安装器"
echo "========================================="

# 判断安装来源
if [ "$1" = "--github" ]; then
    echo "📥 从 GitHub 下载..."
    TMPDIR=$(mktemp -d)
    curl -sL "https://github.com/$REPO/archive/refs/heads/master.tar.gz" | tar xz -C "$TMPDIR"
    SCRIPT_DIR="$TMPDIR/agentforge-harness-skill-master"
else
    echo "📁 从本地安装..."
    SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fi

echo "安装目录: $CODEX_HOME"
echo ""

# 1. 创建目录
mkdir -p "$CODEX_HOME/rules" "$CODEX_HOME/skills"

# 2. 安装铁律
echo "📋 安装铁律..."
cp "$SCRIPT_DIR/rules/IRON_LAWS.md" "$CODEX_HOME/rules/"
echo "   ✅ IRON_LAWS.md"

# 3. 安装技能
echo "📦 安装技能..."
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    cp -r "$skill_dir" "$CODEX_HOME/skills/"
    echo "   ✅ $skill_name"
done

# 4. 验证
echo ""
errors=0
for f in "$CODEX_HOME/rules/IRON_LAWS.md" "$CODEX_HOME/skills/agentforge-fix/SKILL.md"; do
    if [ -f "$f" ]; then echo "   ✅ $(basename $f)"; else echo "   ❌ $(basename $f) 缺失"; errors=$((errors+1)); fi
done

# 清理
[ "$1" = "--github" ] && rm -rf "$TMPDIR"

echo ""
if [ $errors -eq 0 ]; then
    echo "🎉 安装完成！铁律会在 Codex 执行任务时自动加载。"
else
    echo "⚠️  安装完成，但有 $errors 个问题。"
fi
