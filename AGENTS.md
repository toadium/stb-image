# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Project Overview

**stb-image** (walkzzz/image) — 纯 MoonBit 图像处理库，零 C FFI 依赖。

| 属性 | 值 |
|------|-----|
| 版本 | 0.5.0 (mooncakes) / v237.0.0 (功能迭代) |
| 测试 | 5995 × 4 目标 (native/wasm-gc/js/wasm) |
| API | 1338 公开函数 + 491 类型 |
| 格式 | 18 种编解码 (PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM/TIFF/ICO/CUR/ICNS/APNG/WebP/AVIF/HEIF/JPEG-XL) |
| 覆盖率 | 90.4% |

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod` file listing module
  metadata.

### 多子包架构

```
src/
├── types/              # 全目标类型 (Image, Image16, ImageF, LoadError 等)
├── pure/               # 纯 MoonBit 后端 (无 C FFI)
│   ├── codec/          #   格式编解码 (15 种格式)
│   ├── color/          #   颜色操作
│   └── util/           #   工具
├── lib/                # 高层封装 (自动格式分派) + 流式解码
├── meta/               # 元数据 (EXIF, PNG meta)
├── process/            # 高级图像处理算法 (90 子包)
│   ├── color/          #   色彩转换/调整/CLAHE/自适应阈值/Retinex/去雾
│   ├── edge/           #   边缘检测/Canny/霍夫/轮廓
│   ├── feature/        #   特征检测: Harris/ORB/SIFT/模板匹配/光流/GLCM/LBP
│   ├── filter/         #   滤波/去噪/图像修复
│   ├── frequency/      #   FFT/DCT/Haar 小波/频率滤波
│   ├── segment/        #   分水岭/SLIC/grabCut/形态学/连通域
│   ├── transform/      #   几何变换/透视/Seam Carving/金字塔
│   ├── ocr/            #   OCR全流程: 版面/二值化/倾斜/分割/识别/后处理
│   ├── medical/        #   医学图像: DICOM/CT/MRI/超声/病理
│   ├── encryption/     #   图像加密/解密/水印
│   └── ...             #   其余 80 子包 (检测/融合/超分/3D/视频等)
├── util/               # 工具函数 (基于 pure 的上层封装)
├── bench.mbt           # 性能基准测试
└── reexport.mbt        # 顶层 API re-export (1338 pub fn + 491 pub type)
```

## Core Constraints

> [!WARNING]
> 以下约束不可违反：

- **禁止引入 C FFI 依赖** — 所有代码必须纯 MoonBit 实现，确保四目标可用
- **禁止目标条件编译** — 不使用 `target == "native"` 等条件分支，四目标共用代码
- **新增 `pub` 函数须在 `reexport.mbt` 注册** — 保持顶层 API 完整性

## Development Rules（开发规则全集）

> **来源**：`rules.md`，适配 stb-image 项目。优先级：防跑偏规则 > 项目规则 > 个人偏好。

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
没有任务迭代时，自动触发新的路线迭代计划。

### R8 — 文档治理
每次迭代后进行开源项目文档治理：更新根 README、roadmap、CHANGELOG、子包 README。

### R9 — 经验沉淀
开发经验教训沉淀复用：更新 memory（`C:\Users\Administrator\.codeartsdoer\memory\...`）。

### R10 — 一级子包重导出
一级子包（如 `src/kernel`、`src/fieldimg`）也要 README.md 并重导出子包 API。

### R11 — 防跑偏规则（记/锁/回）
每一步做三件事：
1. **记**：把已确认的"规则/负责人/截止时间"写进固定区块；
2. **锁**：遇到与前序约定冲突的新要求，先停下，标注冲突来源，问"谁有权改"；
3. **回**：每完成一环，回写一句"已交付 x，下环依赖 Y"。
禁止在没确认的情况下，把群聊里的某句话当成最终决定。

### R12 — 根包重导出
项目根包（`walkzzz/image`，根目录 `moon.pkg` + `reexport.mbt`）重导出所有一级子包公共 API，对外提供统一入口 `@image`。

### R13 — Warning 治理
每次迭代完成后都要进行 **warning 治理**：运行 `moon check` / `moon test`，对所有 warning 逐一处理（修复根因，禁止注释/ignore 压制），目标 0 warning。

### R14 — 占位 todo 检查
所有的占位 todo 项，每次迭代后都要检查是否具备条件完成。若依赖已满足且资源就绪，立即推进；否则标注阻塞原因。

### R15 — 规则输出复用
所有规则输出到 `rules.md`，供 agent 与人类协作者复用。每次新增规则回写。

### R16 — 迭代清理 ⭐ 新增
每次迭代完成后，清理项目中无关文件和临时文件：
- 删除 `_build/` 下的临时构建产物（`moon clean` 可重建）
- 删除根目录及子包中的 `.tmp`、`.bak`、`*.log`、`uncovered.log` 等临时文件
- 删除调试用的临时测试文件（如 `/tmp/proof_check.mbt` 等）
- 清理 git 未跟踪的无关文件（`git clean -nd` 检查，确认后 `git clean -fd` 删除）
- **注意**：清理前先用 `git status` 确认不会删除有价值的未提交工作

### 迭代流程（每 Sprint 执行步骤）

1. **查架构**：读 `ARCHITECTURE.md` 对应章节，明确范围。
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

## Coding Convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

- New `pub fn`/`pub let`/`pub type` must be re-exported in `src/reexport.mbt`
  to keep the top-level API complete. Ordinary functions use `pub let` alias,
  functions with labeled parameters use `pub fn` wrapper to preserve defaults.
  After adding re-exports, run `moon info` to regenerate `.mbti` and verify the
  new API surface is visible.

- 命名：`snake_case` 函数/变量，`kebab-case` 项目/目录名
- 测试命名：`"函数名: 场景描述"`（测试名称必须唯一，重复会触发 deprecated 警告）
- 错误处理：`raise LoadError::DecodeFailed("msg")`

### MoonBit 关键语法约束

- `@math.atan2/cos/sin/pow/exp/log2/log10` 接受 `Double`，需 `.to_double()` 转入，`Float::from_double()` 转出
- `@math.lnf(Float)` 用于 Float 自然对数；`@math.log` **不存在**
- `@math.sqrt` **不存在**，用 `.sqrt()` 方法
- `not(expr)` 已弃用，用 `!expr`
- `1e10F` / `1e-10F` **无效**，用 `10000000000.0F` / `0.0000000001F`
- `(0..<n).rev()` **不支持**，用手动反向循环
- `is_empty()` 已弃用（Option），用 `x is None`；`is_not_empty()` 不存在，用 `x is Some(_)`
- `clamp` 用标签参数：`.clamp(min=0, max=255)`
- `pub(all) enum/struct` 才允许外部构造
- `Bytes` 不可变，用 `Array[Byte]` 构建后 `Bytes::from_array()`
- 回调中使用 `assert` 需 `raise` 注解，或收集数据在外部断言
- Int × Float 类型不匹配：需 `Float::from_int(n) * float_val`
- `ImageF.data` 是 `Bytes`（IEEE 754 LE），不是 `Array[Float]`；用 `Float::to_le_bytes()` 转换
- `UInt` 与 `Int` 类型不匹配：建议统一用 `Int`
- `<<=` 运算符不支持，用 `x = x << 1`
- Range `.rev()` 在 for 循环中不支持

## Tooling

- `moon fmt` is used to format your code properly.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check tests pass. MoonBit supports snapshot testing; when
  changes affect outputs, run `moon test --update` to refresh snapshots.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. For snapshot tests that record
  structured debugging output, derive `Debug` and use `debug_inspect`, rather
  than deriving `Show` for debugging. For solid, well-defined results (e.g.
  scientific computations), prefer assertion tests. You can use
  `moon coverage analyze > uncovered.log` to see which parts of your code are
  not covered by tests.

## Build & Test

```bash
# 编译检查（四目标）
moon check
moon check --target wasm-gc
moon check --target js
moon check --target wasm

# 运行测试（四目标各 4620）
moon test --target native
moon test --target wasm-gc
moon test --target js
moon test --target wasm

# 重新生成 API 接口
moon info

# 格式化
moon fmt

# 性能基准
moon run --target native
```

## Documents

| 文档 | 说明 |
|------|------|
| [README.md](README.md) | 项目说明（中文） |
| [docs/architecture.md](docs/architecture.md) | 架构图、包依赖关系、设计决策 |
| [docs/api_reference.md](docs/api_reference.md) | 完整 API 参考（1338 函数 + 491 类型） |
| [docs/roadmap.md](docs/roadmap.md) | 迭代路线图 |
| [docs/comparison.md](docs/comparison.md) | mooncakes.io 图像库对比 |
| [docs/performance_report.md](docs/performance_report.md) | 性能基准报告 |
| [docs/skill.md](docs/skill.md) | AI 辅助开发技能描述 |
| [docs/changelog.md](docs/changelog.md) | 版本变更历史 |
