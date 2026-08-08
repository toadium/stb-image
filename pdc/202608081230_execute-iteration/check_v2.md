# 检查报告（v2）

## 结果
PASSED

## 检查项
| 检查项 | 方法 | 结果 |
|--------|------|------|
| types 包创建 | 读取 `src/types/moon.pkg` 和 `src/types/image_types.mbt` | 通过：moon.pkg import 仅 `moonbitlang/core/debug`，无 `supported_targets` 限制，无 C stub；image_types.mbt 含 6 个类型定义（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError），保持 `pub(all)` 可见性、`derive(Eq, @debug.Debug)`、文档注释 |
| core 包 image_types.mbt 删除 | glob 搜索 `src/core/image_types.mbt` | 通过：文件已删除（无匹配） |
| core 包 moon.pkg 改造 | 读取 `src/core/moon.pkg` | 通过：增加 `import "MoonBit-Toadium/stb-image/src/types"`，保留 `supported_targets = "native"` 和 `native-stub: ["wrapper.c"]` |
| core 包 re-export 声明 | 读取 `src/core/image_types_reexport.mbt` | 通过：6 个 `pub type X = @types.X` 声明（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError），语法与 `src/reexport.mbt` 先例一致 |
| core 包内裸引用未修改 | 构建验证间接确认 | 通过：`moon check` 通过证明 69+ 处裸引用（struct 字面量/suberror 构造/模式匹配/函数签名）通过别名透明性继续编译 |
| pure 包 moon.pkg 改造 | 读取 `src/pure/moon.pkg` | 通过：增加 `import types`，`@core` 改为 `for "test"` 条件依赖（偏差已说明，有 `src/format/moon.pkg` 先例），保留 `supported_targets = "native"` |
| pure 包 bmp_decode.mbt 改造 | grep `@types\.` 和 `@core\.` | 通过：主代码所有 `@core.*` 已改为 `@types.*`（实际 9 处：函数签名 1 + raise 构造 7 + struct 字面量 1），无残留 `@core.` 引用 |
| pure 包 bmp_decode_test.mbt 改造 | grep `@types.LoadError` | 通过：测试 7-8 错误路径 2 处 `@core.LoadError::DecodeFailed` → `@types.LoadError::DecodeFailed`；测试 1-6 保持现状（字段级比较） |
| 根包 reexport 引用未受影响 | grep `@core.(Image\|Image16\|...)` in `src/reexport.mbt` | 通过：203 处 `@core.Image` 等引用通过 core 包 re-export 别名继续有效，构建通过间接验证 |
| 构建验证 | `moon check --target native` | 通过：0 errors, 0 warnings，30 tasks 完成 |
| 全量测试验证 | `moon test --target native` | 通过：554/554 passed, 0 failed，未破坏现有测试 |
| 偏差合理性评估 | 读取 `src/format/moon.pkg` 先例 + grep pure 目录 @core 引用 | 通过：`for "test"` 条件依赖有 `src/format/moon.pkg` 先例；pure 目录下 `@core.` 仅出现在测试文件（对比验证用），主代码已无 @core 引用，偏差说明合理且为改进 |

## 总结
任务要求创建 `src/types/` 全目标包分离类型定义、改造 core 包通过 re-export 别名保持向后兼容、改造 pure 包主代码改用 @types，并验证构建和全量测试通过。Doer 产出完整满足所有要求：types 包配置正确（全目标、无 C stub）、6 个类型定义完整迁移、core 包 re-export 机制有效（69+ 处裸引用通过别名透明性继续编译）、pure 包主代码已切换至 @types。一项偏差（pure 包 @core 改为 `for "test"` 条件依赖）有充分先例支持且为改进（消除 unused_package warning），偏差说明已明确记录。构建验证 `moon check` 0 errors / 0 warnings，全量测试 554/554 通过，未破坏现有功能。v2.0 多目标支持的关键架构基础（类型定义与 C FFI 解耦）已奠定。
