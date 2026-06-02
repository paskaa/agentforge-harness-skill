# AgentForge Harness Skill

> **模型决定上限，Harness 决定底线。** Codex CLI / Claude Code 全套技能 + 插件 + 工具链。

29 个 Skills · 2 个 Plugins · CodeGraph 语义索引，一键安装。

---

## 📦 组件清单

### AgentForge 全链路（6 个）

| 技能 | 说明 | 触发时机 |
|---|---|---|
| `bug-analyze` | Bug 根因分析 + 修复方案设计 | 分析 Bug 时 |
| `bug-fix` | 全链路修复流程（6 环分析） | 修复 Bug 时 |
| `playwright-test` | Playwright/E2E 回归测试 | 测试修复时 |
| `acceptance` | 最终验收确认 | 测试通过后 |
| `chenlin-archive` | 报告生成 + 多层归档 | 验收通过后 |
| `db-review` | 数据库变更验证 | 涉及 SQL 时 |

### 通用开发（23 个）

| 分类 | 技能 |
|---|---|
| **规划** | `writing-plans` · `executing-plans` · `brainstorming` |
| **测试** | `test-driven-development` · `bug-driven-testing` · `closed-loop-testing` · `verification-before-completion` |
| **调试** | `systematic-debugging` · `full-chain-fix` |
| **审查** | `requesting-code-review` · `receiving-code-review` · `review-audit` |
| **工程** | `harness-engineering` · `constraint-design` · `durable-execution` · `walkinglabs-harness` |
| **协作** | `dispatching-parallel-agents` · `subagent-driven-development` · `using-superpowers` |
| **Git** | `using-git-worktrees` · `finishing-a-development-branch` |
| **元技能** | `writing-skills` · `karpathy-guidelines` |

### Plugins

| 插件 | 说明 |
|---|---|
| `harness-engineering` | Harness Engineering 方法论插件（含 6 个子技能） |
| `understand-anything` | 代码库理解插件（知识图谱 + dashboard + diff 分析） |

### Tools

| 工具 | 说明 |
|---|---|
| `codegraph` | 语义代码索引（25% 省钱 · 62% 少调工具） |

### 8 Agent 定义

| Agent | 角色 |
|---|---|
| `zhugeliang` | 架构师 — 技术方案 + 代码审查 |
| `zhaoyun` | 开发者 — 代码实现 |
| `zhangfei` | 测试官 — 编写测试 + 质量门禁 |
| `huatuo` | 医生 — Bug 诊断 + 修复 |
| `guanyu` | 守卫 — 安全审计 + 依赖管理 |
| `xunyu` | 策略师 — 性能优化 + 架构分析 |
| `liubei` | 协调者 — Agent 间协调 + 任务分派 |
| `chenlin` | 记录官 — 文档 + 归档 + 报告 |

---

## 🚀 一键安装

```bash
git clone https://github.com/paskaa/agentforge-harness-skill.git
cd agentforge-harness-skill
bash install.sh
```

安装脚本会：
1. 复制 29 个 Skills 到 `~/.codex/skills/`
2. 安装 2 个 Plugins 到 `~/.codex/plugins/`
3. 安装 CodeGraph MCP server 到 `~/.codex/config.toml`

---

## 🔧 手动安装

```bash
# Skills
cp -r skills/* ~/.codex/skills/

# Plugins
cp -r plugins/* ~/.codex/plugins/

# CodeGraph
bash tools/codegraph-install.sh
codegraph install --target codex --yes
```

---

## 📁 目录结构

```
agentforge-harness-skill/
├── skills/                   # 29 个技能
│   ├── agentforge-*/         # 6 个全链路技能
│   ├── brainstorming/        # 23 个通用技能
│   └── ...
├── plugins/                  # 2 个插件
│   ├── harness-engineering/
│   └── understand-anything/
├── agents/                   # 8 个 Agent 定义
├── rules/                    # 铁律 + 规则
├── tools/
│   └── codegraph-install.sh  # CodeGraph 安装脚本
├── config/                   # Codex 配置模板
├── scripts/                  # 安装脚本 (bash + PowerShell)
├── install.sh                # 一键安装
└── README.md
```

---

## 🎯 使用场景

### AgentForge Bug 修复流水线

```
收到 Bug → bug-analyze → bug-fix → playwright-test → acceptance → chenlin-archive
```

### 日常开发

```
brainstorming → writing-plans → test-driven-development → code-review → verification
```

### 大规模重构

```
dispatching-parallel-agents → subagent-driven-development → full-chain-fix → review-audit
```

---

## 📋 环境要求

- **Codex CLI** 或 **Claude Code**
- **Node.js** (用于 CodeGraph)
- **Bash** (用于安装脚本)

---

## 📜 License

MIT
