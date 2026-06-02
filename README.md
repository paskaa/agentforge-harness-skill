# AgentForge Harness Engineering 技能包

> 模型决定上限，Harness 决定底线。

18条铁律 + 15个技能 + 8个智能体定义，一键安装。

## Windows 安装（Win10/11）

```powershell
# PowerShell 一行命令
irm https://raw.githubusercontent.com/paskaa/agentforge-harness-skill/master/scripts/install.ps1 | iex

# 或者手动
git clone https://github.com/paskaa/agentforge-harness-skill.git
.\agentforge-harness-skill\scripts\install.ps1 -GitHub
```

## Linux/Mac 安装

```bash
# 一行命令
CODEX_HOME=~/.codex bash <(curl -s https://raw.githubusercontent.com/paskaa/agentforge-harness-skill/master/scripts/install.sh) --github

# 或者手动
git clone https://github.com/paskaa/agentforge-harness-skill.git
bash agentforge-harness-skill/scripts/install.sh --github
```

## 安装内容

| 组件 | 数量 | 说明 |
|---|---|---|
| 铁律 | 18条 | `IRON_LAWS.md` — 不可违反 |
| Bug修复技能 | 6个 | fix/analyze/test/verify/db-review/archive |
| Harness方法论 | 9个 | harness-engineering/walkinglabs等 |
| 智能体定义 | 8个 | 刘备~陈琳 |

## 铁律速览

1. Bug状态管理 — 已关闭不处理
2. 修复流程 — 一次一个Bug
3. 全链路6环 — 前端→Controller→Service→Mapper→DB→关联
4. 状态值一致性 — 改状态前检查6个地方
5. 影响面分析 — rg搜索所有引用
6. 逆向流程验证 — 退号/取消/停诊都要测
7. 全链路验证 — 数据库→后端→前端→统计
8. 池/统计表同步 — 状态变更必须同步统计
9. 统计变更验证 — 改了统计必须查数据库
10. 禁止删除源文件
11. 禁止改方法签名
12. 搜索代码路径
13. 数据库铁律 — 先查表结构再写SQL
14. 测试铁律 — workers=1，超时120秒
15. 归档铁律 — Git+SQLite+Redis三重写入
16. 禅道交互 — resolve+activate
17. 质量门禁 — L1~L5
18. 禁止硬编码默认值

## GitHub

https://github.com/paskaa/agentforge-harness-skill
