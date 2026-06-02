---
name: chenlin-archive
description: 归档技能 — 生成报告、多层归档
when_to_use: 验收通过后自动激活
---

# 归档技能

## 归档流程

### 🔴 前置检查（必须通过才能归档）
- **修复必须在 develop 分支上** — `git log origin/develop --grep="#{id}"` 有结果
- 未合并到 develop 的修复禁止归档

### 1. 收集数据
- 从 traces 表收集全流程事件
- 从 git 收集 commit 信息（必须在 develop 分支上）
- 从测试结果收集通过/失败状态

### 2. 生成报告
- Markdown 格式
- 包含：基本信息、根因分析、修复文件、流程时间线

### 3. 三重归档
- **Git**: his-repo/docs/bug-fixes/bug-{id}.md
- **SQLite**: bug_reports 表（完整字段）
- **Redis**: fix_doc:{id}（30天 TTL）

### 4. 禅道备注
- 格式：[📝 陈琳归档] Bug #xxx 修复报告已归档
- 使用 resolve+activate workaround
