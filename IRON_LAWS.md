# 🔴 AgentForge 铁律（不可违反）

> 所有智能体在处理任何任务时必须遵守。违反任何一条 = 阻断提交。
> 唯一源头文件：修改此文件后所有智能体自动生效。

---

## 一、Bug 状态管理

- **已关闭/已解决的 Bug 禁止处理** — 处理前检查禅道 status，resolved/closed 直接跳过
- **人类提的 Bug 只加备注不改状态** — reporter 是人类账号时，不改 status、不改 assignedTo
- **智能体提的 Bug 可改分配和加备注** — 状态变更等测试通过后由华佗确认
- **每个修复必须有 git commit** — 格式: `fix(#bug_id): 简要描述`
- **🔴 修复完成必须提交** — `git add --all && git commit && git push`，未提交=没修
- **🔴 修复必须合并到 develop** — 工作树 commit ≠ 生效，必须 cherry-pick/merge 到 develop
- **🔴 未合并到 develop 的修复等于没修** — 验收时检查 develop 上是否有该 commit
- **🔴 修复必须编译部署后才算完成** — `mvn package` → `systemctl restart` → 验证启动时间

---

## 二、修复流程

- **一次只修一个 Bug**，不扩大范围
- **修前必须完整获取 Bug 全部信息** — 描述、复现步骤、所有截图/附件、所有备注历史。禁止只看标题就写代码
- **修复前必须读 AGENTS.md**
- **修复后必须验证编译** — `mvn compile` / `vue-tsc --noEmit` 0 error
- **commit 前必须验证** — 编译通过 + 无新增 lint 警告

---

## 三、全链路 6 环分析

涉及数据库字段的 Bug 必须走完整链路：
```
前端/页面 → Controller → Service → Mapper → DB/SQL → 关联模块
 ①录入      ②验证      ③业务     ④持久化    ⑤存储     ⑥联动
```

---

## 四、状态值一致性（来自 Bug #574 教训）

修改任何状态值前，**必须**列出完整链路并逐项检查：
1. 枚举定义（如 `SlotStatus`）的值
2. Service 层设置的状态值是否与枚举一致
3. 查询/列表接口的状态映射是否覆盖所有枚举值
4. 前端 `STATUS_CLASS_MAP` 是否包含新状态
5. 前端过滤条件（`v-if`、`v-for`）是否兼容新状态
6. 池/统计表的聚合 SQL 是否包含新状态值

**禁止**：只改一端不检查其他端。

---

## 五、状态变更影响面分析（来自 Bug #574→575 教训）

改任何状态枚举值前，**必须**执行影响面分析：
1. `rg "原状态枚举名" --type java` 列出所有引用文件
2. 逐个检查：设置值？查询过滤？显示映射？统计聚合？
3. 检查逆向流程：退号、取消、停诊是否兼容新状态
4. 检查 XML mapper 中所有查询过滤条件
5. 检查前端所有 v-if/v-for/disabled 条件

**禁止**：只改正向流程不验逆向流程。

---

## 六、逆向流程验证（来自 Bug #575 教训）

涉及状态流转的 Bug，验证时**必须**覆盖：
- 正向：预约→签到→就诊→完成
- 逆向：退号、取消预约、停诊、退费
- 边界：并发操作、重复操作、异常中断

**禁止**：只测正向流程就标记"修复完成"。

---

## 七、全链路验证（状态流转 Bug 必做）

修复后按以下顺序验证，**编译通过不等于修复完成**：
```
① 数据库：SELECT status FROM table WHERE id = ?  → 确认写入正确
② 后端接口：检查所有 if/switch 分支  → 确认映射正确
③ 前端显示：检查 STATUS_CLASS_MAP  → 确认文本正确
④ 前端交互：检查 v-if/v-for/disabled  → 确认按钮状态正确
⑤ 统计数据：检查聚合 SQL  → 确认统计包含新状态
```

---

## 八、池/统计表同步（来自 Bug #574 反复修复教训）

- **任何状态变更必须同步更新关联统计表**
- 检查清单：
  1. 状态变更后，哪些统计字段需要更新？
  2. 是原子递增/递减，还是全量重算？
  3. 并发安全：用 `SET field = field + 1` 还是先查后改？
  4. 逆向操作（退号/取消）是否正确回滚统计？
- **禁止**：只改状态不改统计，或只改统计不改状态

---

## 九、统计变更必须验证实际值（来自 Bug #575 教训）

- 修改统计逻辑后，**必须查数据库验证实际值**
- `SELECT booked_num, locked_num FROM adm_schedule_pool WHERE id = ?`
- 对比操作前后的值，确认统计正确
- **禁止**：改了统计逻辑不查数据库验证

---

## 十、禁止删除源文件

- **绝对禁止**删除项目中已有的 Java/Vue/SQL 源文件
- 编译错误 → 修复错误，不删除文件
- 重复文件 → 重构合并，不删除文件
- AI 幻觉文件 → 检查 `git ls-tree baseline -- <file>` 确认后再删除
- **唯一例外**：人类明确确认删除

---

## 十一、禁止修改已有公开方法签名

- 不能删除或重命名已有的 public 方法
- 不能修改已有方法的参数列表
- 需要新功能 → 添加重载方法
- 需要改行为 → 修改方法内部实现

---

## 十二、搜索所有相关代码路径

修复前必须用 `rg` 搜索：
```
rg "状态枚举名|相关方法名|相关字段名" --type java --type vue
```
确保不遗漏任何引用路径。

---

## 十三、数据库铁律

- **修前必须查询真实数据库** — 确认表结构、字段约束、索引
- **禁止凭猜测写 SQL** — 先 `\d table_name` 查看表结构
- **修改 SQL 后必须验证** — `EXPLAIN` 或实际查询验证语法
- **NOT NULL 约束必须检查** — INSERT/UPDATE 前先查 `is_nullable`
- **关联表必须查完整** — 涉及 JOIN 查所有关联表结构和外键
- **涉及 SQL 必须先查真实数据库**

---

## 十四、测试铁律

- Playwright 必须 `--workers=1`
- 超时 120 秒，最多重试 3 次
- 测试失败自动重试，超过 3 次通知人工介入
- 测试结果写入禅道备注
- **DB审查失败自动回退** — 路由回原修复智能体

---

## 十五、归档铁律

- **三重写入** — Git + SQLite + Redis
- SQLite 必须使用完整字段
- 禅道备注格式：`[📝 陈琳归档] Bug #xxx`
- 归档报告必须包含：基本信息 + 根因分析 + 修复文件 + 流程时间线

---

## 十六、禅道交互（铁律 — 不可违反）

- **备注必须使用 resolve+activate workaround**
  - `zentao bug update --comment` ❌ 不会创建 comment action
  - `zentao bug update --data '{"comment":"..."}'` ❌ 同样无效
  - ✅ 正确方法：`zentao bug resolve --id <id> --data '{"resolution":"fixed","resolvedBuild":"trunk","comment":"..."}'`
  - ✅ 然后激活：`zentao bug activate --id <id> --data '{"openedBuild":"trunk"}'`
- **不直接调用 comment API（会 404）**
- **图片附件必须 OCR 读取**
- **每个 Bug 修复必须同时写禅道备注 — 代码提交和备注是原子操作，缺一不可**

---

## 十七、质量门禁

- L1: 编译通过
- L2: 测试通过
- L3: DB审查通过
- L4: 验收通过
- L5: 归档完成

---

## 过往教训

| Bug | 教训 | 根因 |
|---|---|---|
| #574 | 状态值 BOOKED(1)→应为 CHECKED_IN(3)，前端映射缺失 | 没走完整状态链路 |
| #574 | AI 看到编译错误直接删文件 | 没检查 git baseline |
| #574 | 多次 fallback 修错文件（OrderServiceImpl） | 没用 rg 搜索所有引用 |
| #574 | 签到后 booked_num 未累加 | 只改状态没改统计 |
| #575 | 改了签到状态没检查退号流程 | 只验正向不验逆向 |
| #575 | booked_num 应在预约时累加而非签到时 | 统计变更未验证实际值 |
| — | 修复完成未提交到 develop | 框架未强制验证提交 |
| — | 退号流程只检查 BOOKED(1) 不兼容 CHECKED_IN(3) | 状态变更影响面分析缺失 |

---

## 十八、禁止硬编码业务默认值（来自 Bug #617 教训）

- **禁止**在提交参数中硬编码业务默认值（如 `contractNo: '0000'`）
- 必须使用用户在表单中选择的值，硬编码值仅作为 fallback
- 检查清单：
  1. 表单字段是否有 `v-model` 绑定？
  2. 构建提交参数时是否使用了绑定值？
  3. 提交后是否覆盖了用户选择？
- **禁止**：用户选了医保，提交时却写死为自费

---

## 过往教训（补充）

| Bug | 教训 | 根因 |
|---|---|---|
| #617 | 费用性质硬编码为 '0000'（自费），用户选医保无效 | 构建参数时写死默认值 |

---

## 十九、前端验证铁律

- **提交前必须编译前端** — `npm run build` 或 `npx vite build` 通过才算完成
- **禁止只改 .vue 文件不验证编译** — 改完必须跑一次编译确认无报错
- **SCSS 括号闭合必须检查** — `<style lang="scss" scoped>` 内的所有 `{}` 必须成对闭合
- **SCSS 嵌套层级不超过 4 层** — 过深嵌套说明结构需要重构
- **编译报错必须当场修复** — 看到 error 立即修，不要留到下一步

### SCSS 检查清单

```bash
# 编译验证
cd openhis-ui-vue3 && npm run build

# 如果编译报错，检查 SCSS
grep -n "{" src/views/xxx/index.vue | wc -l  # 开括号数
grep -n "}" src/views/xxx/index.vue | wc -l  # 闭括号数
# 两者必须相等
```

---

## 二十、提交前验证铁律

- **后端**: `mvn compile` 通过 + 无新增 warning
- **前端**: `npm run build` 通过 + 无 SCSS 错误
- **禁止跳过编译直接提交** — 编译失败的代码不允许进仓库
- **提交信息格式**: `type(scope): description`（如 `fix(charge): 修复退费金额计算`）

### 提交前检查流程

```bash
# 1. 后端编译
cd openhis-server-new && mvn compile -pl openhis-application -am

# 2. 前端编译
cd openhis-ui-vue3 && npm run build

# 3. 两个都通过才提交
git add --all && git commit -m "type(scope): description"
```

---

## 二十六、resolve 前必须验证 develop commit（来自 v0.5.1 修复）

- **禁止**仅凭 worktree 未提交变更就 resolve Bug
- resolve 前必须检查 `git log origin/develop --grep="Bug#{id}"` 是否有 commit
- `comment_bug` 用 resolve+activate workaround，activate 失败会导致 bug 卡在 resolved
- `ok_to_commit` 必须要求 `has_fix_commit = true`（develop 上有实际 commit）
- **验证方式**: `git log origin/develop --grep="Bug#{id}" --oneline -1` 有输出才允许 resolve

---

## 二十七、comment_bug 禁止改状态铁律（来自 v0.5.2 修复）

- **禁止**使用 resolve+activate workaround 添加备注 — activate 失败会导致 bug 卡在 resolved
- 添加备注必须使用不改状态的方式：CLI `zentao bug update --comment` 或 API `PUT /bugs/{id}`
- `comment_bug` 函数必须只写 comment，不触发任何状态变更
- **教训**: 36 个 bug 因 activate 失败被误标为 resolved，无代码提交

### 正确做法

```rust
// ✅ 正确：只加备注，不改状态
zentao bug update --id <BUG_ID> --comment "备注内容"

// ❌ 错误：resolve+activate 会改状态
POST /bugs/{id}/resolve  // 改为 resolved
POST /bugs/{id}/activate  // 如果失败，bug 卡在 resolved
```

---

## 二十八、文件快照禁用覆盖判定铁律（来自 v0.5.2 修复）

- **禁止**用主仓库文件快照 diff 覆盖 success 判定
- success 判定必须基于 agent worktree 的实际变更（`count_changed_files` + `has_fix_commit`）
- 主仓库快照仅用于日志记录，不能影响判定结果
- **教训**: 主仓库快照检测到其他 agent 的变更，误判当前 agent 修复成功

### 根因

```
Agent A cherry-pick 到 develop → 主仓库有变更
Agent B 运行 → 主仓库快照检测到 A 的变更 → 误判 B 修复成功
```

### 正确做法

```rust
// ✅ 正确：基于 worktree 判定
let changes = count_worktree_changes(agent_name);  // 检查 worktree
let has_fix = has_recent_fix_commit(agent_name, bug_id);  // 检查 develop commit

// ❌ 错误：基于主仓库判定
let file_diff = snapshot_and_diff(main_repo_dir, &before);  // 检查主仓库
if has_real_changes { r.success = true; }  // 误判
```

---

## 二十九、Worktree 必须存在且为 Git 仓库铁律

- 每个 agent 的 worktree 目录必须存在且包含 `.git` 文件
- 启动 executor 前必须验证 worktree 存在：`test -d /tmp/agentforge-worktrees/{agent}`
- worktree 不存在时必须创建：`git worktree add /tmp/agentforge-worktrees/{agent} -b {agent}`
- **教训**: 4 个 agent（zhangfei, chenlin, huatuo, liubei）无 worktree，codex 运行失败但仍标记成功

### 验证命令

```bash
# 检查所有 agent worktree
for agent in zhaoyun guanyu xunyu zhangfei huatuo chenlin zhugeliang liubei; do
  if [ -d "/tmp/agentforge-worktrees/$agent/.git" ]; then
    echo "✅ $agent: worktree OK"
  else
    echo "❌ $agent: worktree MISSING"
    cd /root/.openclaw/workspace/his-repo
    git worktree add /tmp/agentforge-worktrees/$agent -b $agent
  fi
done
```

---

## 三十、Bug 状态变更必须双重确认铁律

- resolve Bug 前必须检查当前状态：`zentao bug get --id {id} | grep status`
- 只有 `status: active` 的 Bug 才允许 resolve
- resolve 后必须验证状态：`zentao bug get --id {id} | grep status` 确认为 `resolved`
- activate 后必须验证状态：确认恢复为 `active`
- **教训**: 批量操作 36 个 bug 时，1 个因状态不对失败，需要逐个检查

### 批量操作模板

```bash
source /root/.config/zentao/.env
for id in 711 710 709; do
  # 1. 检查当前状态
  status=$(zentao bug get --id "$id" 2>&1 | grep "status:" | awk '{print $2}')
  if [ "$status" != "active" ]; then
    echo "⚠️ Bug #$id: 当前状态=$status，跳过"
    continue
  fi
  # 2. 执行操作
  zentao bug activate --id "$id" --data '{"openedBuild":"6"}'
  # 3. 验证结果
  new_status=$(zentao bug get --id "$id" 2>&1 | grep "status:" | awk '{print $2}')
  echo "Bug #$id: $status → $new_status"
done
```


## 三十一、修复后必须写禅道备注铁律（来自 v0.6.0 修复）— 不可违反

- **每个 Bug 修复（commit + cherry-pick 到 develop）后，必须立即写禅道备注**
- **禁止只提交代码不写备注 — 代码提交和禅道备注是原子操作，缺一不可**
- **正确方法（铁律 #16）**：
  - `zentao bug resolve --id <id> --data '{"resolution":"fixed","resolvedBuild":"trunk","comment":"..."}'`
  - `zentao bug activate --id <id> --data '{"openedBuild":"trunk"}'`
- 成功修复：调用 `resolve_bug_in_zentao` 写结构化备注（根因 + 变更文件 + 验证结果）
- 修复失败：调用 `comment_in_zentao` 写失败原因备注
- **代码路径**：`run_harness_loop` 的自动提交逻辑必须包含禅道备注调用
- **验证方式**：`curl /api.php/v1/bugs/{id}` 检查 `actions` 字段是否有新 comment
- **教训**: v0.6.0 发现 `run_harness_loop` 路径缺少禅道备注调用；v0.6.1 发现 `zentao bug update --comment` 不创建 comment action，必须用 resolve+activate

## 三十二、DTO 字段类型防御铁律（来自 Bug #632）

- **前端传入的 Boolean 字段 → 改用 String + 业务层转换**
  - Jackson 对 Boolean 严格校验，只接受 `true/false`，非标输入直接崩
  - 前端数据来源多（搜索、分类、详情回填），结构不一致是常态
- **所有接受前端输入的 DTO 加 `@JsonIgnoreProperties(ignoreUnknown = true)`**
  - 防止前端额外字段导致反序列化失败
- **Integer/Long 字段同理** — 前端可能传空字符串，DTO 用 String 接更安全
- **调试反序列化错误第一步**：直接搜 DTO 里的目标类型字段（如 Boolean），不用逐行读代码
- **教训**: Bug #632 因 `isPackage: Boolean` 接收到项目名称 "肝功能12项" 崩溃，排查耗时 30min+

## 三十三、Codex Exec 停滞检测铁律（来自 v0.7.0 测试）

- **codex exec 必须有停滞检测机制** — 进程无输出超过 10 分钟必须杀掉
- **检测范围必须包含 stdout 和 stderr** — codex reasoning 阶段只写 stderr 不写 stdout
- **停滞判定基于最后活动时间**（stdout 或 stderr 最后写入时间），不是进程存活时间
- **停滞杀掉后必须自动重试**（最多 3 次），因为 stall 通常是暂时性问题
- **教训**: v0.7.0 测试中 codex exec 无输出跑 16 分钟才发现，浪费资源

### 正确实现

```rust
// ✅ 正确：stdout + stderr 都追踪活动
let last_activity = Arc::new(Mutex::new(Instant::now()));
// stdout 线程：写入时更新 last_activity
// stderr 线程：写入时也更新 last_activity
// 主循环：检查 last_activity.elapsed() > stall_timeout

// ❌ 错误：只追踪 stdout
// reasoning 阶段只有 stderr 输出，会被误判为 stall
```

---

## 三十四、远程插件同步禁用铁律（来自 v0.7.0 测试）

- **codex exec 启动时必须禁用远程插件同步**
- **根因**：`codex_core_plugins::remote::remote_installed_plugin_sync` 尝试连接 `chatgpt.com` 认证，API key 模式下认证失败后 hang 住
- **解决方案**：
  1. 移除或修复 `~/.agents/plugins/marketplace.json`（格式必须是 JSON 数组）
  2. 设置环境变量 `CODEX_DISABLE_REMOTE_SYNC=1`
- **验证**：启动日志不应出现 `remote installed plugin bundle sync failed`
- **教训**: v0.7.0 测试中 3 次 stall 重试全部卡在插件同步，每次 10 分钟

---

## 三十五、Vision API 超时配置铁律（来自 v0.7.0 测试）

- **多图 Vision 请求必须设置 120 秒以上超时**
- **单图 Vision 请求至少 30 秒**
- **Vision 客户端必须与普通 LLM 客户端分开**（不同超时配置）
- **Vision 失败必须回退到纯文本分析**，不能阻断修复流程
- **教训**: v0.7.0 测试中 3 张图 vision 请求 30 秒超时失败

### 正确实现

```rust
// ✅ 正确：Vision 用独立客户端，120 秒超时
let vision_client = Client::builder()
    .timeout(Duration::from_secs(120))
    .build()?;
let resp = vision_client.post(&url).send().await?;

// ❌ 错误：复用普通客户端（30 秒超时）
let resp = self.client.post(&url).send().await?;  // 3 张图会超时
```

---

## 三十六、附件 FileID 去重铁律（来自 v0.7.0 测试）

- **从 HTML 提取 fileID 时必须去重**
- **根因**：禅道 HTML 中同一图片出现 2 次（`src` 属性和 `alt` 属性各一次）
- **不去重会导致**：同一图片下载 2 次、vision 分析 2 次，浪费 API 配额和时间
- **教训**: Bug #666 提取到 6 个 fileID（实际只有 3 张图）

### 正确实现

```rust
// ✅ 正确：去重
if !file_ids.contains(&fid) {
    file_ids.push(fid);
}

// ❌ 错误：不去重
file_ids.push(fid);  // 同一图片出现 2 次
```

---

## 三十七、Executor 启动清理残留锁铁律（来自 v0.7.0 测试）

- **Executor 启动时必须清理本 agent 的所有 `fix_active:{agent}:*` 残留锁**
- **根因**：进程崩溃或被 kill 后，fix_active 锁（TTL 30 分钟）残留，阻止 Bug 重新入队
- **清理方式**：`SCAN fix_active:{agent}:* → DEL` 每个匹配的 key
- **教训**: v0.7.0 重启 executor 后 Bug #666 被残留锁阻止 30 分钟

### 正确实现

```rust
// ✅ 正确：启动时 SCAN 清理
let pattern = format!("fix_active:{}:*", self.agent_id);
let mut cursor: u64 = 0;
loop {
    let (new_cursor, keys): (u64, Vec<String>) = redis::cmd("SCAN")
        .arg(cursor).arg("MATCH").arg(&pattern).arg("COUNT").arg(100)
        .query_async(&mut conn).await.unwrap_or((0, vec![]));
    for key in &keys {
        let _: RedisResult<()> = conn.del(key).await;
    }
    cursor = new_cursor;
    if cursor == 0 { break; }
}
```

---

## 三十八、Verdict UNKNOWN 降级判定铁律（来自 v0.7.0 测试）

- **Harness Loop 的 verdict 为 UNKNOWN 时，不能直接判失败**
- **必须检查实际代码变更**（`count_changed_files`）
- **有变更 → 降级为编译验证**（`mvn compile` / `vue-tsc`）
- **无变更 → 判失败**
- **教训**: v0.7.0 测试中 codex 修复正确但 verdict 解析失败（UNKNOWN），直接判 success=false

### 正确流程

```
verdict == UNKNOWN
  ├─ changes > 0 → mvn compile → PASS → 继续后续阶段
  ├─ changes > 0 → mvn compile → FAIL → 返回失败
  └─ changes == 0 → 返回失败
```

---

## 三十九、Pipeline 结果必须清理旧数据铁律（来自 v0.7.0 测试）

- **重新提交 Bug 修复前，必须删除 `pipeline:result:{bug_id}` 旧数据**
- **根因**：Redis 中残留旧结果，新结果写入前读到的是旧数据，导致误判
- **教训**: v0.7.0 测试中 Bug #666/#668/#671 读到的是上一轮的失败结果

### 正确实现

```rust
// ✅ 正确：提交前清理旧结果
let result_key = format!("pipeline:result:{}", bug_id);
let _: RedisResult<()> = conn.del(&result_key).await;
// 然后入队
conn.rpush(&queue, task.to_string()).await;
```
