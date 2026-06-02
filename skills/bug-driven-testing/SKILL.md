---
name: bug-driven-testing
description: Write tests before fixing bugs. Each bug fix must have corresponding Playwright/E2E test cases that verify the fix and prevent regression. Use when fixing bugs, verifying fixes, or setting up regression test suites.
---

# Bug-Driven Testing (BDT) 方法论

> **核心原则：先写测试，再修 Bug。测试是修复的契约，不是修复的附庸。**

## 一、为什么需要 BDT

传统 AI 修 Bug 的问题：
1. 修完不测 → 不知道修没修好
2. 测了但用例不对 → 测了等于没测
3. 修了 A 坏了 B → 没有回归保护
4. 测试和修复脱节 → 无法追溯

BDT 解决：**每个 Bug 有专属测试用例，修复前生成，修复后验证，形成闭环。**

## 二、BDT 工作流（6 步）

```
Step 1: Bug 分析 → 提取测试场景
Step 2: 测试设计 → 生成 Playwright 用例
Step 3: 基线测试 → 确认 Bug 存在（应失败）
Step 4: 修复代码 → 解决根因
Step 5: 回归测试 → 确认修复有效（应通过）
Step 6: 扩展测试 → 检查是否引入新问题
```

### Step 1: Bug 分析 — 提取测试场景

从禅道 Bug 信息中提取 **5 要素**：

| 要素 | 来源 | 用途 |
|------|------|------|
| **模块** | 标题 + module | 确定测试页面和路由 |
| **操作路径** | 复现步骤 | 生成操作序列 |
| **期望结果** | 期望结果字段 | 生成断言 |
| **实际结果** | 实际结果字段 | 确认 Bug 存在 |
| **关联页面** | 标题关键词 | 定位测试目标元素 |

**关键词 → 模块映射表：**

```
门诊医生/诊前/挂号     → /doctorstation
住院医生/医嘱/医嘱录入 → /inpatientDoctor
住院护士/补费/发退药   → /inpatientNurse
分诊/排队/候诊         → /triageandqueuemanage
挂号/预约/签到         → /registration
手术/计费             → /operatingroom
诊断/中医             → /inpatientDoctor
病历/EMR              → /doctorstation
目录/诊疗             → /catalog
药房/发药/库存         → /pharmacy
```

**操作路径 → Playwright 动作映射：**

```
"点击 XXX 按钮"     → page.click('button:has-text("XXX")')
"选择 XXX"         → page.selectOption / page.click('.el-option')
"输入 XXX"         → page.fill('input', 'XXX')
"查看列表"         → page.waitForLoadState('networkidle')
"弹窗确认"         → page.click('.el-message-box button:has-text("确定")')
"检查报错"         → expect(page.locator('.el-message--error')).toBeVisible()
"检查显示"         → expect(page.locator('目标元素')).toBeVisible()
```

### Step 2: 测试设计 — 生成 Playwright 用例

**每个 Bug 测试用例的结构：**

```typescript
test.describe('🐛 Bug#N 模块名', () => {
  // beforeEach: 登录 + 导航到目标页面
  
  test('#N 标题 @bugN @regression', async ({ page }) => {
    // 1. 导航到目标页面
    // 2. 执行复现步骤（操作路径）
    // 3. 断言期望结果
    // 4. 检查无 JS 错误
    // 5. 截图记录
  });
});
```

**测试用例的 7 种检查模式：**

| # | 模式 | 适用场景 | Playwright 写法 |
|---|------|---------|----------------|
| 1 | **页面加载** | 所有 Bug | `expect(page).not.toHaveURL(/.*login.*/)` |
| 2 | **元素可见** | 显示/缺失类 | `expect(locator).toBeVisible()` |
| 3 | **元素可交互** | 按钮/弹窗类 | `await locator.click()` + 等待响应 |
| 4 | **数据正确** | 列表/回显类 | `expect(locator).toHaveText()` |
| 5 | **无报错** | 所有 Bug | `page.on('pageerror')` + `expect(jsErrors).toEqual([])` |
| 6 | **流程完整** | 交互流程类 | 多步骤操作链 + 每步断言 |
| 7 | **状态变更** | 退回/审核类 | 操作前状态 vs 操作后状态对比 |

### Step 3: 基线测试 — 确认 Bug 存在

修复前运行测试，**预期应该失败**，证明 Bug 确实存在：

```bash
npx playwright test --grep @bugN --reporter=line
# 预期: FAIL (证明 Bug 存在)
```

如果基线测试通过了：
- 可能 Bug 已被之前的修复解决 → 检查 develop 分支
- 可能测试用例设计不正确 → 重新分析 Bug
- 可能环境问题 → 检查 dev server / 数据库

### Step 4: 修复代码

按照 Harness Engineering 方法论修复：
1. 全链路 6 环分析
2. 一次只修一个 Bug
3. 只动必要文件

### Step 5: 回归测试 — 确认修复有效

修复后运行测试，**预期应该通过**：

```bash
npx playwright test --grep @bugN --reporter=line
# 预期: PASS (证明修复有效)
```

### Step 6: 扩展测试 — 检查回归

运行相邻模块的测试，检查是否引入新问题：

```bash
npx playwright test --grep @regression --reporter=line
# 预期: 全部 PASS
```

## 三、测试用例生成规则

### 从 Bug 标题推断检查项

| 标题关键词 | 生成的检查项 |
|-----------|-------------|
| 报错/错误/异常 | 检查页面无 JS 错误 + 控制台无报错 |
| 显示/缺失/不规范 | 检查元素正确显示 + 数据完整性 |
| 弹窗/弹框 | 检查弹窗正常弹出 + 内容正确 |
| 保存/提交/写入 | 检查保存操作成功 + 数据持久化 |
| 列表/查询 | 检查列表数据加载 + 分页功能 |
| 按钮/操作 | 检查按钮可点击 + 操作响应 |
| 下拉/选择/字典 | 检查下拉选项加载 + 选项值正确 |
| 退回/撤回/取消 | 检查退回流程 + 状态变更 |

### 从复现步骤生成操作序列

```
复现步骤: "1. 登录 → 2. 进入住院医生站 → 3. 点击医嘱录入 → 4. 保存"
生成代码:
  await page.goto('/inpatientDoctor');
  await page.click('button:has-text("医嘱录入")');
  await page.click('button:has-text("保存")');
```

## 四、质量标准

**好的 Bug 测试用例：**
- ✅ 有 `@bug{N}` 标签（可单独运行）
- ✅ 有 `@regression` 标签（回归测试套件）
- ✅ 操作路径来自禅道复现步骤
- ✅ 断言覆盖期望结果
- ✅ 检查无 JS 错误
- ✅ 有截图记录
- ✅ 独立运行（不依赖其他测试）

**坏的 Bug 测试用例：**
- ❌ 只检查页面加载（太弱）
- ❌ 没有断言（只操作不断言）
- ❌ 依赖特定数据（硬编码）
- ❌ 超时设置过短

## 五、与 Agent 工作流集成

```
Agent 收到 Bug
  │
  ├→ Step 1: 读取禅道 Bug 详情（标题/步骤/截图）
  ├→ Step 2: 生成 Playwright 测试用例（自动生成 spec 文件）
  ├→ Step 3: 运行基线测试（应失败）
  │    └→ 如果通过 → 检查 develop 是否已修复
  ├→ Step 4: 修复代码（全链路 6 环）
  ├→ Step 5: 运行回归测试（应通过）
  │    └→ 如果失败 → 分析失败原因 → 返回 Step 4
  └→ Step 6: 提交代码 + 推远程 + 更新禅道
```

## 六、CLI 命令速查

```bash
# 生成测试用例
bash tests/e2e/utils/generate-bug-test.sh <bug_id> "<bug_title>"

# 运行单个 Bug 测试
npx playwright test --grep @bug630

# 运行全部回归测试
npx playwright test --grep @regression

# 查看测试报告
npx playwright show-report tests/e2e/report
```
