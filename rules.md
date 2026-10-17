# GeoVerse 开发规则全集 / Development Rules

> **用途**：本文件是 GeoVerse 项目所有开发规则的权威汇总，供 agent 与人类协作者复用。  
> **维护**：每次新增规则时回写本文件。  
> **优先级**：防跑偏规则 > 项目规则 > 个人偏好。

---

## 一、项目规则 / Project Rules

### R1 — 源码目录
全部源代码放在 `src/` 目录下。

### R2 — 多手段测试
MoonBit 形式化证明 + AI/FAKE/MOCK/E2E 多手段测试，确保无 bug。每个 Sprint 交付前 `moon check` 0 error、`moon test` 全通过。

### R3 — 代码文档注释
代码三级文档注释中英文（包级、类型级、方法级）。

### R4 — README 规范
README 中英文，美化，默认中文；每个子包也要 README.md。

### R5 — 迭代路线
先制定 `docs/roadmap.md` 迭代路线，按 Sprint 推进。

### R6 — 提交查证
提交历史有迹可循——每个 Sprint 完成回写 `roadmap.md` 状态 + commit hash。

### R7 — 自动迭代触发
没有任务迭代时，自动触发新的路线迭代计划（定时任务 `090586a2`，每日 9 点）。

### R8 — 文档治理
每次迭代后进行开源项目文档治理：更新根 README、roadmap、CHANGELOG、子包 README。

### R9 — 经验沉淀
开发经验教训沉淀复用：更新 memory（`C:\Users\Administrator\.codeartsdoer\memory\...`）。

### R10 — 一级子包重导出
一级子包（如 `src/kernel`、`src/fieldgeom`）也要 README.md 并重导出子包 API。

### R11 — 防跑偏规则（记/锁/回）
每一步做三件事：
1. **记**：把已确认的"规则/负责人/截止时间"写进固定区块；
2. **锁**：遇到与前序约定冲突的新要求，先停下，标注冲突来源，问"谁有权改"；
3. **回**：每完成一环，回写一句"已交付 x，下环依赖 Y"。
禁止在没确认的情况下，把群聊里的某句话当成最终决定。

### R12 — 根包重导出
项目根包（`geoverse/geoverse`，根目录 `moon.pkg` + `geoverse.mbt`）重导出所有一级子包公共 API，对外提供统一入口 `@geoverse`。

### R13 — Warning 治理 ⭐ 新增
每次迭代完成后都要进行 **warning 治理**：运行 `moon check` / `moon test`，对所有 warning 逐一处理（修复或显式抑制），目标 0 warning。

### R14 — 占位 todo 检查 ⭐ 新增
所有的占位 todo 项，每次迭代后都要检查是否具备条件完成。若依赖已满足且资源就绪，立即推进；否则标注阻塞原因。

### R15 — 规则输出复用 ⭐ 新增
所有规则输出到本文件 `docs/rules.md`，供 agent 与人类协作者复用。每次新增规则回写。

### R16 — 迭代清理 ⭐ 新增
每次迭代完成后，清理项目中无关文件和临时文件：
- 删除 `_build/` 下的临时构建产物（`moon clean` 可重建）
- 删除根目录及子包中的 `.tmp`、`.bak`、`*.log`、`uncovered.log` 等临时文件
- 删除调试用的临时测试文件（如 `/tmp/proof_check.mbt` 等）
- 清理 git 未跟踪的无关文件（`git clean -nd` 检查，确认后 `git clean -fd` 删除）
- **注意**：清理前先用 `git status` 确认不会删除有价值的未提交工作

---

## 二、MoonBit 技术要点 / Technical Notes

| 要点 | 说明 |
| --- | --- |
| 工具链版本 | MoonBit v0.1.20260920 |
| 配置文件 | `moon.mod` / `moon.pkg`（TOML，无 .json 后缀） |
| 科学计数法 | 不支持 `1e-13` 字面量，用 `0.000000000001` |
| pub enum 跨包 | 构造子跨包不可构造，需提供 `pub fn` 构造函数 |
| 字符串插值 | `{}` 不生效，用 `+` 拼接 |
| 关键字 | `var` 是关键字，不能做函数名 |
| 白盒测试 | `_wbtest.mbt` 后缀（避免 `@pkg` 前缀要求） |
| 布尔取反 | 用 `!expr`，`not(x)` 已 deprecated |
| 闭包调用 | record field 调用需 `(self.func)(x, y)` 而非 `self.func(x, y)` |
| trait 方法调用 | 跨包用 `Trait::method(obj, args)`，隐式提升已 deprecated |
| range 循环 | `for i in 0..<n`（字面量 OK）；表达式边界加括号 `0..<(n-1)`；返回值函数内用 C 风格 `for i = 0; i < n; i = i + 1` |
| Double sqrt | `value.sqrt()` 方法（非 `@math.sqrt`） |

### 重导出语法
```
pub using @pkg { type T, name1, trait Trait1 }
```
- 必须带 `{}`；`pub using @pkg` 不带花括号报错 "expect `{`"。
- 只能列类型/trait/顶层标识符，不能列方法 `Type::method`。
- 重导出类型后，其 pub 方法自动随类型可见。
- `moon.pkg` 不支持 `export` 段；`pub use` 非有效语法，应为 `pub using`。

### 根包
项目根目录加 `moon.pkg` + `<name>.mbt` 即为模块根包，可重导出一级子包对外统一入口。

---

## 三、迭代流程 / Iteration Workflow

每个 Sprint 执行步骤：

1. **查架构**：读 `GeoVerse-ARCHITECTURE.md` 对应章节，明确范围。
2. **实现**：写源码 + 白盒测试（`_wbtest.mbt`）。
3. **验证**：`moon check` 0 error + `moon test` 全通过。
4. **Warning 治理**（R13）：逐一处理 warning，目标 0 warning。
5. **重导出**（R10/R12）：一级子包聚合 + 根包重导出。
6. **文档治理**（R8）：更新 README / roadmap / CHANGELOG / 子包 README。
7. **经验沉淀**（R9）：更新 memory。
8. **占位检查**（R14）：检查占位 todo 是否可推进。
9. **迭代清理**（R16）：清理无关文件和临时文件。
10. **提交**（R6）：git commit + 回写 roadmap commit hash。
11. **回写**（R11 回）：回写"已交付 x，下环依赖 Y"。

---

## 四、进度查证 / Progress Audit

| Sprint | 内容 | 状态 | commit |
|--------|------|------|--------|
| S0.1 | 项目骨架 + Roadmap | ✅ | 001afd6 |
| S0.2 | kernel 四层数值内核 + 重导出 | ✅ | b9396af |
| S0.3 | geom2d/geom3d BRep 原语 | ✅ | 37a86be |
| S0.4 | fieldgeom 标量场接口定型 | ✅ | 23af0da |
| S0.5 | spatiotemporal 数据结构定型 | 🔧 进行中 | — |
| S0.6 | GeoIR 基础语法定义 | ⏸ | — |
| S0.7 | AOCI 基础设施原型 | ⏸ | — |

**当前测试**：137 passed · **当前 API**：~140（kernel 82 + geom 30 + scalar_field ~20 + 重导出）

---

> **文件结束** | GeoVerse Rules v1.0 | 2026-10-17