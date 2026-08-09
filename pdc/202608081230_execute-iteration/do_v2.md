# 执行报告（v2）

## 概述
创建 `src/types/` 全目标包，从 `src/core/image_types.mbt` 提取 6 个类型定义（`Image` / `Image16` / `ImageF` / `ImageInfo` / `GifAnimation` / `LoadError`）到独立包，解除类型定义与 C FFI 的耦合。core 包通过 `pub type X = @types.X` 别名 re-export 保持 `@core.Image` 等现有引用不变（别名透明性已实验验证，core 包内 69+ 处裸引用无需修改）。pure 包主代码改用 `@types.*`，测试对比验证保留 `@core.load_from_bytes`。构建验证通过：`moon check --target native` 0 errors / 0 warnings，`moon test --target native` 554/554 通过。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | `src/types/moon.pkg` | types 包配置，import 仅 `moonbitlang/core/debug`，无 `supported_targets` 限制（全目标可用），无 C stub |
| 新建 | `src/types/image_types.mbt` | 迁移 6 个类型定义（`Image` / `Image16` / `ImageF` / `ImageInfo` / `GifAnimation` / `LoadError`），保持 `pub(all)` 可见性和 `derive(Eq, @debug.Debug)`，保持文档注释 |
| 修改 | `src/core/moon.pkg` | 增加 `import "Toadium/image/src/types"`，保留 `supported_targets = "native"` 和 `native-stub` |
| 删除 | `src/core/image_types.mbt` | 类型定义已迁移至 types 包 |
| 新建 | `src/core/image_types_reexport.mbt` | 6 个 re-export 声明（`pub type Image = @types.Image` 等），保持 `@core.Image` 等现有引用不变 |
| 修改 | `src/pure/{codec,pixel,color,process,util}/moon.pkg` | 增加 `import "Toadium/image/src/types"`（主代码依赖），`@core` 改为 `for "test"` 条件依赖（测试对比验证用），保留 `supported_targets = "native"` |
| 修改 | `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt` | 4 处 `@core.*` → `@types.*`（函数签名 1 + raise 构造 3） |
| 修改 | `src/pure/{codec,pixel,color,process,util}/bmp_decode_test.mbt` | 2 处 `@core.LoadError::DecodeFailed` → `@types.LoadError::DecodeFailed`（测试 7-8 错误路径，与主代码 `raise @types.LoadError` 一致） |

## 执行过程

### 1. 创建 types 包
- `src/types/moon.pkg`：仅 import `moonbitlang/core/debug`（`derive(Eq, @debug.Debug)` 需要），不设 `supported_targets`（全目标可用），无 C stub
- `src/types/image_types.mbt`：原样迁移 6 个类型定义，保持 `pub(all)` 可见性、`derive(Eq, @debug.Debug)`、文档注释

### 2. 改造 core 包
- `src/core/moon.pkg`：增加 `import "Toadium/image/src/types"`
- 删除 `src/core/image_types.mbt`
- 新增 `src/core/image_types_reexport.mbt`：6 个 `pub type X = @types.X` re-export 声明，语法与 `src/reexport.mbt` 先例一致
- **core 包内其他 20+ 文件未修改**：别名透明性已实验验证（plan_review_v2_r1.md 记划审查记录），`pub type T = @types.T` 别名对包内裸引用完全透明（struct 字面量构造 `Image::{...}`、suberror 变体构造 `LoadError::DecodeFailed(...)`、模式匹配 `catch LoadError::DecodeFailed(_)`、函数签名 `-> Image raise LoadError` 均通过别名解析），69+ 处裸引用保持原样继续编译

### 3. 改造 pure 包
- `src/pure/{codec,pixel,color,process,util}/moon.pkg`：增加 `import "Toadium/image/src/types"`（主代码依赖），`@core` 改为 `for "test"` 条件依赖（测试对比验证用），保留 `supported_targets = "native"`
- `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt`：4 处 `@core.*` → `@types.*`（函数签名 `-> @types.Image raise @types.LoadError` 1 处 + raise 构造 3 处）
- `src/pure/{codec,pixel,color,process,util}/bmp_decode_test.mbt`：测试 1-6 保持现状（纯逻辑断言不涉类型前缀；对比验证字段级比较 `assert_eq(pure_img.width, ffi_img.width)` 别名透明下直接可行）；测试 7-8 错误路径 `@core.LoadError::DecodeFailed` → `@types.LoadError::DecodeFailed`（2 处）

### 4. 构建验证
- `moon check --target native`：通过（0 errors, 0 warnings）
- `moon test --target native`：554/554 通过（0 失败），未破坏现有测试

### 关键决策
1. **pure 包 @core 依赖改为 `for "test"`**：任务指令预期"保留现有 import @core"，但主代码改用 @types 后 @core 仅在测试文件使用（对比验证），不分离会产生 `unused_package` warning。参考 `src/format/moon.pkg` 先例（`import ... } for "test"`），将 @core 标记为测试专用依赖，更准确表达依赖关系，消除 warning。详见偏差说明。
2. **core 包内裸引用不修改**：别名透明性已在计划审查阶段通过临时双包实验验证（_alias_probe，2/2 测试通过，已清理），本轮直接应用，69+ 处裸引用保持原样。

## 偏差说明
1. **pure 包 `@core` 依赖改为 `for "test"` 条件依赖**：任务指令预期"修改 `src/pure/{codec,pixel,color,process,util}/moon.pkg`（+ import types，保留 import core，保留 supported_targets = "native"）"，实际将 `@core` 从主 import 列表移至 `for "test"` 条件依赖块。原因：主代码已改为使用 `@types.*`，`@core` 仅在测试文件中使用（`@core.load_from_bytes` 对比验证），若保留在主 import 列表会触发 `unused_package` warning（实测确认）。`src/format/moon.pkg` 有相同先例（`import "Toadium/image/src/process/color" } for "test"`），语法正确。此修改更准确地表达了依赖关系（主代码全目标依赖 types，测试 native-only 依赖 core 对比验证），消除了 warning，不破坏功能，是对任务指令的改进。
