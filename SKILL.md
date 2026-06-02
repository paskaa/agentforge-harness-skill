---
name: agentforge-harness
description: AgentForge Harness Engineering 完整技能包 — 18条铁律 + 8智能体Bug修复框架 + 全链路验证方法论。安装后自动加载所有约束规则。
when_to_use: 修复Bug、代码审查、开发新功能、任何需要遵循Harness Engineering方法论的任务
---

# AgentForge Harness Engineering 技能包

> 模型决定上限，Harness 决定底线。

## 安装内容

| 组件 | 路径 | 说明 |
|---|---|---|
| 铁律 | `rules/IRON_LAWS.md` | 18条不可违反规则 |
| 修复技能 | `skills/agentforge-fix/` | 全链路Bug修复流程 |
| 分析技能 | `skills/agentforge-analyze/` | 根因分析 |
| 测试技能 | `skills/agentforge-test/` | Playwright回归测试 |
| 验收技能 | `skills/agentforge-verify/` | 最终验收 |
| DB审查 | `skills/agentforge-db-review/` | 数据库变更审查 |
| 归档技能 | `skills/agentforge-archive/` | 三重归档 |
| 方法论 | `skills/harness-engineering/` | Harness Engineering主方法论 |
| 8智能体 | `agents/` | 刘备/诸葛亮/关羽/赵云/荀彧/张飞/华佗/陈琳 |

## 快速使用

### 1. 一键安装（其他电脑）

```bash
# 克隆仓库
git clone https://github.com/paskaa/agentforge-harness-skill.git /tmp/agentforge-harness

# 运行安装脚本
bash /tmp/agentforge-harness/scripts/install.sh
```

### 2. 手动安装

```bash
# 复制铁律
cp rules/IRON_LAWS.md ~/.codex/rules/

# 复制技能
cp -r skills/agentforge-* ~/.codex/skills/

# 复制方法论
cp -r skills/harness-engineering ~/.codex/skills/
```

### 3. 验证安装

```bash
ls ~/.codex/rules/IRON_LAWS.md
ls ~/.codex/skills/agentforge-*/
```

## 铁律摘要（18条）

1. Bug状态管理 — 已关闭不处理，人类Bug只加备注
2. 修复流程 — 一次一个Bug，修前读AGENTS.md
3. 全链路6环 — 前端→Controller→Service→Mapper→DB→关联
4. 状态值一致性 — 改状态前检查6个地方
5. 影响面分析 — rg搜索所有引用，检查逆向流程
6. 逆向流程验证 — 退号/取消/停诊都要测
7. 全链路验证 — 数据库→后端→前端→统计 5步验证
8. 池/统计表同步 — 状态变更必须同步统计
9. 统计变更验证 — 改了统计必须查数据库确认
10. 禁止删除源文件 — 编译错误修错不删文件
11. 禁止改方法签名 — 只能加重载或改内部
12. 搜索代码路径 — rg搜索所有引用
13. 数据库铁律 — 先查表结构再写SQL
14. 测试铁律 — workers=1，超时120秒
15. 归档铁律 — Git+SQLite+Redis三重写入
16. 禅道交互 — resolve+activate workaround
17. 质量门禁 — L1编译→L2测试→L3审查→L4验收→L5归档
18. 禁止硬编码默认值 — 用用户选择的值

## 详细铁律

完整内容见 `rules/IRON_LAWS.md`，安装后自动被Codex加载。
