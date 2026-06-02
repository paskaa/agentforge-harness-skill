#!/bin/bash
# AgentForge Harness Engineering 一键安装脚本
# 用法: bash install.sh [目标目录]

set -e

# 默认安装到 ~/.codex
CODEX_HOME="${1:-$HOME/.codex}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🔧 AgentForge Harness Engineering 安装器"
echo "========================================="
echo "安装目录: $CODEX_HOME"
echo "源文件:   $SCRIPT_DIR"
echo ""

# 1. 创建目录
echo "📁 创建目录..."
mkdir -p "$CODEX_HOME/rules"
mkdir -p "$CODEX_HOME/skills"

# 2. 安装铁律
echo "📋 安装铁律 (IRON_LAWS.md)..."
cp "$SCRIPT_DIR/rules/IRON_LAWS.md" "$CODEX_HOME/rules/"
echo "   ✅ $CODEX_HOME/rules/IRON_LAWS.md"

# 3. 安装技能
echo "📦 安装技能..."
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -d "$skill_dir" ]; then
        cp -r "$skill_dir" "$CODEX_HOME/skills/"
        echo "   ✅ $skill_name"
    fi
done

# 4. 验证安装
echo ""
echo "🔍 验证安装..."
errors=0

if [ -f "$CODEX_HOME/rules/IRON_LAWS.md" ]; then
    lines=$(wc -l < "$CODEX_HOME/rules/IRON_LAWS.md")
    echo "   ✅ IRON_LAWS.md ($lines 行)"
else
    echo "   ❌ IRON_LAWS.md 缺失"
    errors=$((errors+1))
fi

for skill in agentforge-fix agentforge-analyze agentforge-test agentforge-verify agentforge-db-review agentforge-archive; do
    if [ -f "$CODEX_HOME/skills/$skill/SKILL.md" ]; then
        echo "   ✅ $skill"
    else
        echo "   ❌ $skill 缺失"
        errors=$((errors+1))
    fi
done

echo ""
if [ $errors -eq 0 ]; then
    echo "🎉 安装完成！所有组件已就位。"
    echo ""
    echo "使用方法："
    echo "  - 在 Codex 中执行任务时，铁律会自动加载"
    echo "  - 修复Bug时会自动激活 agentforge-fix 技能"
    echo "  - 查看铁律: cat $CODEX_HOME/rules/IRON_LAWS.md"
else
    echo "⚠️  安装完成，但有 $errors 个组件缺失。"
fi
