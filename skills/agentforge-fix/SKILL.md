---
name: bug-fix
description: Bug修复技能 — 全链路修复流程
when_to_use: 修复Bug时自动激活
paths:
  - "*.java"
  - "*.vue"
  - "*.ts"
---

# Bug 修复技能

## 修复流程

### 1. 分析阶段
- 读取禅道 Bug 完整信息（标题、描述、附件图片）
- 使用 OCR 读取图片中的错误信息
- 分析 6 环链路：前端→Controller→Service→Mapper→DB→关联模块
- **状态值一致性检查**（涉及状态流转的 Bug 必做）：
  1. 列出所有相关枚举定义及其数值
  2. 搜索所有引用该枚举的代码路径（`rg "SlotStatus\|OrderStatus\|Status"` )
  3. 确认 Service 层设置值、查询映射、前端显示三者一致
  4. 确认统计/聚合 SQL 包含所有相关状态值

### 2. 定位阶段
- 使用 `rg` 搜索相关代码
- 使用 `git blame` 追溯历史
- 确认根因

### 3. 修复阶段
- 一次只修一个 Bug
- 修改最小范围代码
- 遵守项目编码规范

### 4. 验证阶段
- 后端：`mvn compile`
- 前端：`vue-tsc --noEmit`
- 数据库：`db-query` 验证 SQL
- **全链路验证**（状态流转 Bug 必做）：
  1. 数据库：确认状态值已正确写入（`SELECT status FROM table WHERE id = ?`）
  2. 后端接口：确认返回的状态映射正确（检查所有 `if/switch` 分支）
  3. 前端显示：确认页面显示正确状态文本（检查 `STATUS_CLASS_MAP`）
  4. 前端交互：确认按钮/操作基于正确状态启用/禁用
  5. 统计数据：确认池/报表统计包含新状态值
- **禁止**：只验证编译通过就认为修复完成

### 5. 提交阶段
- `git add` + `git commit`
- commit message 格式：`fix(#bug_id): 简要描述`
- 推送到 develop 分支
