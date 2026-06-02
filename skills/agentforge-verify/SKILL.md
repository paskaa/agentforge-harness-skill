---
name: acceptance
description: 验收技能 — 最终确认修复完整性
when_to_use: 测试通过后自动激活
---

# 验收技能

## 验收清单（必须全部通过）

### 🔴 强制检查（任一失败=拒绝验收）
- [ ] **修复已合并到 develop 分支** — `git log origin/develop --grep="#bug_id"` 必须有结果
- [ ] 工作树 commit ≠ 生产生效，必须 merge 到 develop 并 push
- [ ] git commit message 包含 Bug 编号
- [ ] 测试报告通过

### 人类 Bug 处理
- 只加备注，不改状态
- 不改分配

### 智能体 Bug 处理
- 可以改分配
- 可以加备注

## 合并验证命令
```bash
cd /root/.openclaw/workspace/his-repo
git log origin/develop --oneline --grep="#{bug_id}"
# 必须有输出，否则拒绝验收
```
