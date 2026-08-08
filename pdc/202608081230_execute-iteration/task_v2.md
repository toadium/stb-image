# 任务指令（v2）

## 动作
RETRY

## 任务描述
创建 `src/types/` 包，从 `src/core/image_types.mbt` 提取类型定义到独立的全目标包，解除类型定义与 C FFI 的耦合，为 v2.0 多目标支持（wasm/js）奠定基础。

### 具体要求

1. **创建 `src/types/` 包**
   - `src/types/moon.pkg`：import 列表仅 `moonbitlang/core/debug`（`derive(Eq, @debug.Debug)` 需要；`Array[Image]` 用内置 Array，Int/Bytes/String 内置，无需显式 import），**不设 `supported_targets` 限制**（全目标可用），无 C stub
   - `src/types/image_types.mbt`：迁移 `src/core/image_types.mbt` 的 6 个类型定义（`Image` / `Image16` / `ImageF` / `ImageInfo` / `GifAnimation` / `LoadError`），保持 `pub(all)` 可见性和 `derive(Eq, @debug.Debug)`，保持文档注释

2. **改造 `src/core/` 包**
   - `src/core/moon.pkg`：增加 `import "MoonBit-Toadium/stb-image/src/types"`
   - 删除 `src/core/image_types.mbt`（类型定义已迁移至 types 包）
   - 新增 `src/core/image_types_reexport.mbt`：6 个 re-export 声明，语法 `pub type Image = @types.Image` / `pub type Image16 = @types.Image16` / `pub type ImageF = @types.ImageF` / `pub type ImageInfo = @types.ImageInfo` / `pub type GifAnimation = @types.GifAnimation` / `pub type LoadError = @types.LoadError`（与 `src/reexport.mbt` 先例一致）
   - **core 包内其他文件无需修改**：已实验验证 `pub type T = @other.T` 别名对包内裸引用完全透明（struct 字面量构造 `Image::{...}`、suberror 变体构造 `LoadError::DecodeFailed(...)`、模式匹配 `catch LoadError::DecodeFailed(_)`、函数签名 `-> Image raise LoadError` 均通过别名解析）。core 包内 69+ 处裸引用（21 处 struct 字面量 + 53 处 LoadError 构造/匹配 + 15 处函数签名）保持原样继续编译

3. **改造 `src/pure/` 包**
   - `src/pure/moon.pkg`：增加 `import "MoonBit-Toadium/stb-image/src/types"`（保留现有 `import @core`，因测试 5-6 需 `@core.load_from_bytes` 对比验证），保留 `supported_targets = "native"`（本轮 pure 包仍 native-only，多目标落地留待后续轮次——需先确认 moon.pkg 条件依赖语法以分离主代码全目标 import types 与测试 native-only import core）
   - `src/pure/bmp_decode.mbt`：类型引用 `@core.Image` → `@types.Image`、`@core.LoadError` → `@types.LoadError`（共 4 处：函数签名 1 + raise 构造 3）
   - `src/pure/bmp_decode_test.mbt`：测试 1-6 保持现状（纯逻辑断言不涉类型前缀；对比验证 `assert_eq(pure_img.width, ffi_img.width)` 等字段级比较，别名透明下 `@core.Image` 即 `@types.Image`，字段为 Int/Bytes 直接可比）；测试 7-8 错误路径 `@core.LoadError::DecodeFailed` → `@types.LoadError::DecodeFailed`（与主代码 `raise @types.LoadError` 一致，共 2 处）

4. **构建验证**
   - 执行 `moon check --target native` 必须通过
   - 执行 `moon test --target native` 全量 554 测试必须通过（0 失败）

### 预期产出
- 新建：`src/types/moon.pkg`、`src/types/image_types.mbt`
- 修改：`src/core/moon.pkg`（+ import types）、删除 `src/core/image_types.mbt`、新增 `src/core/image_types_reexport.mbt`（6 个 `pub type X = @types.X` re-export 声明）
- 修改：`src/pure/moon.pkg`（+ import types，保留 import core，保留 supported_targets = "native"）、`src/pure/bmp_decode.mbt`（4 处 @core.* → @types.*）、`src/pure/bmp_decode_test.mbt`（2 处 @core.LoadError → @types.LoadError）
- **不修改**：core 包内其他 20+ 文件（69+ 处裸引用通过别名透明性继续编译）
- 验证：`moon check --target native` 通过；`moon test --target native` 554/554 通过

## 选择理由
T1 已完成纯 MoonBit BMP 解码器概念验证（`src/pure/`，554/554 测试通过），但 pure 包仍为 native-only。根因是 core 包将类型定义（`Image` / `Image16` / `ImageF` / `LoadError` 等）与 C stub FFI 耦合在同一 `supported_targets = "native"` 包中，pure 包依赖 core 获取类型则被锁死 native-only。v2.0 多目标支持（wasm/js）的核心阻塞点即此耦合：分离类型定义到独立的全目标 types 包，是后续所有纯 MoonBit 后端工作（pure 包真正脱离 native、后端选择层 `src/lib.mbt`）的前提。T1 概念验证已完成，此架构重构是 v2.0 的关键基础，当前优先级最高。

## 任务上下文
摘自 ROADMAP.md v2.0：
- 目标：支持 wasm/js 目标，与 mizchi 拉平
- 推荐路径 A（双后端）：native 保持 C FFI，wasm/js 用纯 MoonBit fallback
- 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）

摘自 T1 执行报告（do_v1.md）：
- "wasm/js 目标平台解耦属于架构重构，需先拆分 core 包（分离类型定义与 C stub FFI），留待后续轮次"
- pure 包当前 `import @core`，`supported_targets = "native"`

摘自任务约束（task.md）：
- 保持 v1.0 API 冻结：新增功能只添加，不修改已有签名
- 遵循五子包架构：core / process / format / meta / util
- 不破坏现有测试：所有现有测试必须继续通过
- 构建验证：`moon check --target native` 和 `moon test --target native`

摘自计划审查 v2 r1 修正方向（plan_review_v2_r1.md）：
- [严重] re-export 机制透明性已实验验证（_alias_probe 临时项目，`pub type T = @other.T` 别名对包内裸引用完全透明，2/2 测试通过，已清理）
- [一般] pure 包对比测试保持字段级比较（别名透明，Int/Bytes 字段直接可比）
- [一般] pure 包暂不移除 native 限制（选项 b，核心价值是 types 包全目标 + core re-export 验证）
- [轻微] types 包 import 仅 `moonbitlang/core/debug`

## 已有产出上下文
- **`src/pure/`（T1 产出）**：
  - `moon.pkg`：`import @core`，`supported_targets = "native"`
  - `bmp_decode.mbt`：纯 MoonBit BMP 解码器，签名 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`，支持 24/32-bit 无压缩，行填充 4 字节对齐，行序处理（height>0 自下而上 / height<0 自上而下），BGR(A)→RGB(A) 转换，失败路径统一 `raise @core.LoadError::DecodeFailed(...)` 中文消息
  - `bmp_decode_test.mbt`：8 测试（1x1 24-bit、2x2 24-bit 含行填充、1x1 32-bit、自上而下行序、与 `@core.load_from_bytes` 对比验证 1x1+2x2、invalid magic、too short）
- **`src/core/image_types.mbt`**：6 个类型定义（`Image` / `Image16` / `ImageF` / `ImageInfo` / `GifAnimation` / `LoadError`），`pub(all)`，`derive(Eq, @debug.Debug)`，无 FFI 依赖，纯类型声明
- **`src/core/moon.pkg`**：`supported_targets = "native"`，`native-stub: ["wrapper.c"]`，import `moonbitlang/core/debug` + `moonbitlang/core/encoding/utf8`
- **`src/reexport.mbt`**：根包 re-export 先例，`pub type Image = @core.Image` 等大量使用，554 测试通过
- **core 包内裸引用**（69+ 处，别名透明下无需修改）：21 处 struct 字面量构造（`Image::{...}` 等，分布于 image_load_native / image_resize_native / image_info_native / image_float_native / image_gif_native / image_16_native / icon_encode_test）、53 处 LoadError 构造/模式匹配（分布于 image_write_native / image_load_native / image_resize_native / image_info_native / image_float_native / image_gif_native / image_16_native / file_io_native / icon_encode / 各 test 文件）、15 处函数签名（`-> Image raise LoadError` 等，分布于 image_load_native / image_resize_native / image_info_native / image_float_native / image_gif_native / image_16_native / image_detect）
- **当前全量测试**：554 passed, 0 failed（原有 546 + T1 新增 8）
- **依赖 core 类型的子包**：`src/process/*`（filter/edge/color/frequency/transform/feature/segment）、`src/format`、`src/meta`、`src/util`、根包 `src/moon.pkg`，均通过 `@core.Image` 等引用类型（别名透明下 re-export 保持这些引用不变）

## RETRY 说明
计划审查 v2 r1 REJECTED，4 项问题：
1. **[严重] re-export 机制对 core 包内裸引用的可行性未论证**：已通过临时双包实验验证 `pub type T = @other.T` 别名对包内裸引用完全透明（struct 字面量构造、suberror 变体构造、模式匹配、函数签名均可行），core 包内 69+ 处裸引用无需修改，预期产出已明确仅需新增 re-export 声明文件。
2. **[一般] pure 包跨类型对比测试可行性未独立论证**：别名透明下 `@core.Image` 即 `@types.Image`，字段级比较直接可行，测试 1-6 保持现状，仅测试 7-8 错误路径类型前缀改为 @types。
3. **[一般] pure 包是否移除 native 限制表述模糊**：明确选择暂不移除（选项 b），pure 包保留 `supported_targets = "native"` 同时 import core + types，多目标落地留待后续轮次。
4. **[轻微] types 包 import 列表未穷尽**：明确仅 `moonbitlang/core/debug`。
