# 任务计划

任务描述：根据 ROADMAP.md 迭代路线图，逐步实现 stb-image 各版本功能。当前 v1.17.0 已完成，下一目标 v2.0 多目标支持（架构升级）。
工作目录：D:\CodeWorkspace\forTraeCN\stb-image\pdc\202608081230_execute-iteration

---

## R1 NEW v2.0 纯 MoonBit BMP 解码器（概念验证） [ID: T1]
任务：创建 `src/pure/` 目录结构，实现纯 MoonBit 的 BMP 解码器（支持 24-bit/32-bit 无压缩 BMP），包含测试验证，作为 v2.0 多目标支持（路径 A 双后端）的第一步概念验证。
选择理由：
- v1.17 已完成，下一版本为 v2.0 多目标支持（架构升级）
- v2.0 推荐路径 A（双后端）：native 保持 C FFI，wasm/js 用纯 MoonBit fallback
- BMP 格式简单（无压缩 24/32-bit），适合作为纯 MoonBit 后端起点
- 放在新目录 `src/pure/`，不破坏现有五子包架构和 533 测试
- 可验证（有测试），风险低，为后续 wasm/js 后端奠定基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`
- 执行约束：保持 v1.0 API 冻结、遵循五子包架构、不破坏现有测试、构建验证
- 当前 `supported_targets = "native"`，v2.0 目标是扩展到 wasm/js

---

## R2 RETRY v2.0 纯 MoonBit BMP 解码器（概念验证） [ID: T1]
原因：计划审查 REJECTED，4 项问题
- [严重] 架构目标矛盾：pure 包声称服务 wasm/js 但依赖 core 则被锁死 native-only
- [严重] 类型依赖决策未明确：复用 core.Image 与定义等价类型两路径均与目标冲突，计划未做选择
- [一般] 函数签名缺 `raise @core.LoadError`，与 `decode_qoi` 惯例不符
- [一般] 对比测试可行性未论证：对比测试依赖 native-only 的 core，与 pure 包目标平台冲突
修正方向：
1. 明确声明本轮 pure 包暂设 native-only，仅验证解码逻辑正确性，wasm/js 解耦留待后续轮次（需先重构 core 包分离类型与 FFI）
2. 选定复用 `@core.Image` 与 `@core.LoadError`，与 qoi 包同构，承认本轮 native-only
3. 签名改为 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`
4. 对比测试仅在 native 目标运行（pure 包 `for "test"` 依赖 core），纯逻辑测试不依赖 core
选择理由：审查意见属实（核实 `src/format/moon.pkg` 同样 native-only 且依赖 core），复用 core 类型与 qoi 包同构是当前最务实路径，wasm/js 解耦需先做 core 包架构重构，不应在本轮概念验证中承担

---

## R3 PASSED v2.0 纯 MoonBit BMP 解码器（概念验证） [ID: T1]
结果：创建 `src/pure/` 包，实现纯 MoonBit BMP 解码器（24/32-bit 无压缩，行填充+行序处理），含 8 测试（纯逻辑断言 + 与 `@core.load_from_bytes` 对比验证），签名 `pub fn decode_bmp_pure(data : Bytes) -> @core.Image raise @core.LoadError`
检查：`moon check --target native` 通过；`moon test --target native` 全量 554/554 通过（原有 546 + 新增 8），未破坏现有测试；pure 包 native-only 复用 @core 类型与 qoi 包同构

## R3 NEW v2.0 core 包类型分离（多目标基础） [ID: T2]
任务：创建 `src/types/` 包提取 `Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError` 类型定义（无 FFI 依赖、全目标可用），core 包改为 import types 并 re-export 类型保持 `@core.Image` 等现有引用不变，pure 包改为 import types 解除对 core FFI 的依赖，验证 `moon check` + `moon test --target native` 全量 554 测试通过
选择理由：
- T1 已验证纯 MoonBit 解码逻辑可行，但 pure 包仍 native-only（根因：core 包将类型定义与 C stub FFI 耦合在同一 native-only 包中，pure 包依赖 core 获取类型则被锁死 native）
- v2.0 多目标支持（wasm/js）的核心阻塞点即此耦合，分离类型定义是后续所有纯 MoonBit 后端工作（pure 包脱离 native、后端选择层 `src/lib.mbt`）的前提
- 风险可控：core 包 re-export 类型可保持 `@core.Image` 等现有引用不变，现有 554 测试应继续通过
- 当前优先级最高，T1 概念验证已完成，架构重构是 v2.0 的关键基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T1 执行报告：wasm/js 解耦需先拆分 core 包（分离类型定义与 C stub FFI）
- `src/core/image_types.mbt` 含 6 类型定义（无 FFI 依赖），与 FFI 同包 `supported_targets = "native"`
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R4 RETRY v2.0 core 包类型分离（多目标基础） [ID: T2]
原因：计划审查 v2 r1 REJECTED，4 项问题
- [严重] re-export 机制对 core 包内裸引用的可行性未论证，"预期产出"与实际修改范围严重不符
- [一般] pure 包跨类型对比测试可行性未独立论证
- [一般] pure 包是否移除 native 限制表述模糊，与"奠定多目标基础"目标不一致
- [轻微] types 包 import 列表未穷尽
修正方向（已逐一论证）：
1. **re-export 机制透明性已实验验证**：创建临时双包项目 _alias_probe（types 包定义 `pub(all) struct Image` + `pub(all) suberror LoadError`，core 包 `pub type Image = @types.Image` re-export，包内代码用裸 `Image::{...}` / `LoadError::DecodeFailed(...)` / `-> Image raise LoadError` / `catch LoadError::DecodeFailed(_)`），`moon check` + `moon test` 全通过（2/2）。结论：`pub type T = @other.T` 别名对包内裸引用完全透明（struct 字面量构造、suberror 变体构造、模式匹配、函数签名均可行），core 包内 69+ 处裸引用（21 处 struct 字面量 + 53 处 LoadError 构造/匹配 + 15 处函数签名）无需修改，仅新增 re-export 声明文件。语法采用 `pub type Image = @types.Image`（与 `src/reexport.mbt` 先例一致）。实验已清理。
2. **pure 包对比测试保持现状**：别名透明意味着 `@core.Image` 即 `@types.Image`，`pure_img`（@types.Image）与 `ffi_img`（@core.Image）字段级比较 `assert_eq(pure_img.width, ffi_img.width)` / `assert_eq(pure_img.data, ffi_img.data)` 直接可行（字段为 Int/Bytes，不涉类型同一性）。测试 1-6 无需改写；测试 7-8 错误路径 `@core.LoadError::DecodeFailed` 改为 `@types.LoadError::DecodeFailed`（与主代码 `raise @types.LoadError` 一致）。
3. **pure 包暂不移除 native 限制（选项 b）**：pure 包 `moon.pkg` 保留 `supported_targets = "native"`，同时 import core + types（主代码用 @types，测试用 @core 对比）。本轮核心价值是 types 包全目标可用 + core 包 re-export 机制验证 + pure 包主代码改用 types 验证 types 包可用；pure 包真正脱离 native（全目标编译）需确认 moon.pkg 条件依赖语法（主代码 import types 全目标 + 测试 `for "test"` import core native-only），留待下轮。明确声明：本轮 pure 包仍 native-only，多目标落地留待后续轮次。
4. **types 包 import 列表**：仅 `moonbitlang/core/debug`（`derive(Eq, @debug.Debug)` 需要）；`Array[Image]`（GifAnimation.frames）用内置 Array，Int/Bytes/String 内置，无需显式 import。
选择理由：审查意见属实，严重问题通过实验验证已消解（别名透明可行，core 包内裸引用无需修改），其余问题已逐一明确，修订后计划可行性不再留待现场
