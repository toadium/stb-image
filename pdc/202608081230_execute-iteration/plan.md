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

---

## R5 PASSED v2.0 core 包类型分离（多目标基础） [ID: T2]
结果：创建 `src/types/` 全目标包，从 core 包提取 6 个类型定义（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError），core 包通过 `pub type X = @types.X` 别名 re-export 保持 `@core.Image` 等现有引用不变（69+ 处裸引用无需修改），pure 包主代码改用 @types。types 包全目标可用，core 包 native-only 保留 FFI，pure 包仍 native-only（主代码全目标就绪，测试依赖 @core 对比验证）。
检查：`moon check --target native` 0 errors / 0 warnings；`moon test --target native` 554/554 通过，未破坏现有测试；别名透明性有效，re-export 机制保持向后兼容。

## R5 NEW v2.0 pure 包全目标化（多目标编译） [ID: T3]
任务：移除 `src/pure/moon.pkg` 的 `supported_targets = "native"` 限制，使 pure 包全目标编译（wasm/js 可用）。处理测试中对 @core 的依赖（对比测试 5-6 依赖 native-only 的 @core.load_from_bytes），优先方案 A：分离对比测试到 native-only 文件（参照根包 `options(targets:{...})` 先例）；fallback 方案 B：移除对比测试，对比验证留待后续移至根包 roundtrip_test。
选择理由：
- T2 已完成类型分离，pure 包主代码已只依赖 @types（全目标），但 moon.pkg 仍 `supported_targets = "native"`，是 pure 包全目标的唯一剩余障碍
- T2 修正方向 3 明确声明"pure 包真正脱离 native 留待下轮"
- pure 包全目标化是 v2.0 多目标支持（wasm/js）的关键里程碑，是后端选择层 `src/lib.mbt` 的前提
- 风险可控：仅测试依赖 @core，处理测试依赖即可，主代码已全目标就绪
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`
- T2 产出：types 包全目标，pure 包主代码用 @types，moon.pkg 仍 native-only
- 根包 `src/moon.pkg` 有 `options(targets: {"roundtrip_test.mbt": ["native"]})` 先例
- pure 包测试：1-4 纯逻辑，5-6 对比验证（依赖 @core），7-8 错误路径
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R6 PASSED v2.0 pure 包全目标化（多目标编译） [ID: T3]
结果：移除 `src/pure/moon.pkg` 的 `supported_targets = "native"`，采用方案 B 移除 2 个依赖 @core 的对比测试，pure 包完全脱离 @core 依赖（仅 import types，全目标）。保留 6 个纯逻辑测试（全目标可用）。`moon check`（全目标）0 errors 0 warnings，`moon test --target native` 552/552 通过，`moon test --target wasm`/`--target js` pure 包 6/6 通过。
检查：PASSED。pure 包全目标化达成，wasm/js 可用，v1.0 API 冻结保持，对比验证留待后续移至根包 roundtrip_test.mbt。

## R6 NEW v2.0 pure-FFI BMP 对比验证移至根包 [ID: T4]
任务：将 T3 方案 B 移除的 pure-FFI BMP 对比验证测试移至根包 `src/roundtrip_test.mbt`（已 native-only），恢复纯 MoonBit 解码器与 FFI 解码器的一致性验证。具体：根包 `src/moon.pkg` 添加 `src/pure` 的 import（native 包依赖全目标包可行），在 `roundtrip_test.mbt` 新增 2 个对比测试——用 `@core.write_bmp_to_bytes` 生成 BMP 字节流，分别用 `@core.load_from_bytes`（FFI）和 `@pure.decode_bmp_pure`（纯 MoonBit）解码，断言 width/height/channels/data 完全一致（覆盖 24-bit RGB 与 32-bit RGBA 两种位深）。验证 `moon check --target native` 0 errors 0 warnings，`moon test --target native` 全量通过（预期 552→554，恢复 T3 移除的 2 测试）。
选择理由：
- T3 方案 B 移除 2 个对比测试，do_v3.md 明确规划"对比验证留待后续轮次移至根包 roundtrip_test.mbt"，本轮即执行此规划，属 T3 收尾
- 根包 `roundtrip_test.mbt` 已 native-only（`options(targets: {"roundtrip_test.mbt": ["native"]})`），可自由依赖 @core + @pure，无方案 A 的全目标警告问题
- 恢复对比验证能力（pure vs FFI）是质量保证关键：纯 MoonBit 解码器正确性需有 FFI 基准对照，否则 pure 包仅靠纯逻辑自证
- 风险低：仅新增测试不改现有代码；根包 native-only import 全目标 pure 包语法合法（native 目标下全目标包可用）；测试模式已有先例（roundtrip_test.mbt 现有 `roundtrip: BMP RGB` 用 `@core.write_bmp_to_bytes`）
- 为后续后端选择层 `src/lib.mbt` 和 pure 包格式扩展提供验证基础
上下文：
- T3 产出：pure 包全目标化（仅 import types），6 纯逻辑测试，对比测试已移除，native 552 测试通过
- do_v3.md 规划：对比验证留待后续轮次移至根包 roundtrip_test.mbt（native-only）
- 根包 `src/moon.pkg`：`supported_targets = "native"`，`options(targets: {"roundtrip_test.mbt": ["native"]})`，当前 import 列表含 core/process/format/meta/util，不含 pure
- roundtrip_test.mbt 现有 `roundtrip: BMP RGB` 测试模式：`@core.load_from_path` → `@core.write_bmp_to_bytes` → `@core.load_from_bytes` → 断言 data 一致
- pure 包 `decode_bmp_pure` 签名：`pub fn decode_bmp_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持 24/32-bit 无压缩 BMP
- core 包 re-export types：`@core.Image` 即 `@types.Image`，字段级比较直接可行
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R7 RETRY v2.0 pure-FFI BMP 对比验证移至根包 [ID: T4]
原因：计划审查 v4 r1 REJECTED，2 项问题
- [严重] 测试 2（32-bit RGBA）技术不可行：`@core.write_bmp_to_bytes` 对 4 通道写出 BITMAPV4HEADER（108 字节）+ BI_BITFIELDS（compression=3），`decode_bmp_pure` 仅支持 BITMAPINFOHEADER（40 字节）+ BI_RGB（compression=0），会拒绝解码（`bmp_decode.mbt:21,35`），测试 2 运行时抛异常，违反"不破坏现有测试"约束，预期产出"552→554"无法达成
- [严重] 计划未论证 FFI 生成 BMP 与 pure 解码器能力范围的匹配性：计划改用 `@core.write_bmp_to_bytes` 生成路径（T3 原对比测试用手构造字节），未核实 stb_image_write 输出格式与 `decode_bmp_pure` 输入要求的兼容性
修正方向（采用审查推荐方案 A，已逐一核实源码论证）：
1. **FFI 生成 BMP 格式已核实**（`src/core/stb_image_write.h:492-510`）：`stbi_write_bmp_core` 对 `comp != 4`（24-bit RGB）写出 BITMAPINFOHEADER（40 字节）+ BI_RGB（compression=0）+ 24bpp（header `14+40`，DIB `40, x,y, 1,24, 0,...`）；对 `comp == 4`（32-bit RGBA）写出 BITMAPV4HEADER（108 字节）+ BI_BITFIELDS（compression=3）+ 32bpp（header `14+108`，DIB `108, x,y, 1,32, 3,...`）
2. **pure 解码器能力范围已核实**（`src/pure/bmp_decode.mbt:21,35`）：`decode_bmp_pure` 仅接受 `dib_size == 40` && `compression == 0` && `bpp ∈ {24, 32}`，拒绝其他
3. **兼容性匹配结论**：24-bit RGB 路径兼容（FFI 写出 40 字节 DIB + BI_RGB + 24bpp，pure 接受）；32-bit RGBA 路径不兼容（FFI 写出 108 字节 DIB + BI_BITFIELDS，pure 拒绝）
4. **方案 A：仅保留 24-bit RGB 对比测试**，放弃 32-bit RGBA 对比测试。32-bit 对比验证需先扩展 pure 解码器支持 BITMAPV4HEADER（属后续轮次），不在本轮承担
5. **预期测试数调整为 552→553**（仅新增 1 个 24-bit RGB 对比测试）
选择理由：审查意见技术事实属实（已核实 stb_image_write.h 与 bmp_decode.mbt 源码），方案 A 为审查推荐路径，24-bit RGB 对比已能验证纯 MoonBit 解码器与 FFI 解码器在主要路径上的一致性，32-bit 对比验证留待后续扩展 pure 解码器后补充，风险最低

---

## R8 PASSED v2.0 pure-FFI BMP 对比验证移至根包 [ID: T4]
结果：将 24-bit RGB pure-FFI BMP 对比验证测试移至根包 `src/roundtrip_test.mbt`（native-only），新增 1 个测试 `roundtrip: BMP RGB pure vs FFI`。`src/moon.pkg` 以 `for "test"` 语法声明 `@pure` 测试专用依赖（普通 import 触发 `unused_package` 警告，`for "test"` 语义等价且消除警告）。32-bit RGBA 对比测试因 FFI 写出 BITMAPV4HEADER+BI_BITFIELDS 超出 pure 解码器能力范围而放弃，留待后续扩展 pure 解码器后补充。
检查：`moon check --target native` 0 errors 0 warnings，全目标 `moon check` 0 errors 0 warnings，`moon test --target native` 553/553 通过（552→553，新增 1 测试），v1.0 API 冻结保持，现有测试不破坏。

## R8 NEW v2.0 pure 包 QOI 解码器（纯 MoonBit，全目标） [ID: T5]
任务：在 `src/pure/` 新增 `qoi_decode.mbt`，实现纯 MoonBit QOI 解码器 `pub fn decode_qoi_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持 RGB（channels=3）和 RGBA（channels=4）。参考 `src/format/qoi.mbt` 的 `decode_qoi` 逻辑（已是纯 MoonBit，仅依赖 `@core.Image`/`@core.LoadError`，无 FFI），将类型引用替换为 `@types.Image`/`@types.LoadError`。新增 `src/pure/qoi_decode_test.mbt` 纯逻辑测试（全目标，手构造 QOI 字节流验证解码正确性，不依赖 @core）。在根包 `src/roundtrip_test.mbt` 新增 1 个 pure-FFI QOI 对比测试（native-only，用 `@core.load_from_path` 加载测试图像 → `@core.encode_qoi` 生成 QOI 字节流 → `@pure.decode_qoi_pure` 纯 MoonBit 解码 → `@core.decode_qoi` FFI 基准解码 → 断言 width/height/channels/data 完全一致）。验证 `moon check`（全目标）0 errors 0 warnings，`moon test --target native` 553→554 通过。
选择理由：
- T4 已完成 BMP 对比验证收尾，pure 包当前仅 BMP 解码器，格式覆盖不足，需扩展以推进 v2.0 多目标支持的实质功能
- QOI 格式简单（无压缩，索引+差分编码），`src/format/qoi.mbt` 已有纯 MoonBit 解码实现（116 行），移植到 pure 包仅需替换类型引用，技术风险极低
- QOI 是现代格式（qoiformat.org），实用价值高，且项目已有 QOI FFI 实现（`src/format/qoi.mbt`）可作对比基准
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，QOI 解码器仅依赖 @types，全目标可用，无需架构改动
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 和 pure 包格式进一步扩展（PNG/JPEG）奠定基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），6 纯逻辑测试
- T4 产出：根包 roundtrip_test.mbt 有 pure-FFI BMP 对比测试，`src/moon.pkg` 已 `for "test"` 声明 `@pure` 依赖
- `src/format/qoi.mbt:13-116`：`decode_qoi` 纯 MoonBit 实现，签名 `pub fn decode_qoi(data : Bytes) -> @core.Image raise @core.LoadError`，支持 QOI_OP_INDEX/DIFF/LUMA/RUN/RGB/RGBA 标签
- `src/format/qoi.mbt:121-231`：`encode_qoi` 纯 MoonBit 实现，可用于对比测试生成 QOI 字节流
- pure 包 `src/pure/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R9 RETRY v2.0 pure 包 QOI 解码器（纯 MoonBit，全目标） [ID: T5]
原因：计划审查 v5 r1 REJECTED，4 项问题
- [严重] 对比测试 API 引用错误：`@core.encode_qoi`/`@core.decode_qoi` 不存在，core 包无此二函数（`src/format/qoi.mbt:13,121` 属 @format 包，`src/reexport.mbt:824,842` 以 `pub let` re-export 到根包级别非 @core 命名空间，`roundtrip_test.mbt:95,96` 现有用法用 `@format.encode_qoi`/`@format.decode_qoi`），照搬导致 `unbound function @core.encode_qoi` 编译失败
- [严重] "FFI 基准解码"描述失实：`decode_qoi` 是纯 MoonBit（`src/format/qoi.mbt:13-116` 无 FFI/C stub），stb C 库不原生支持 QOI，对比实为"pure 包独立实现 vs format 包独立实现"交叉验证，非 FFI 基准对照
- [一般] 预期 native 测试数遗漏 pure 包纯逻辑测试：pure 包全目标化（T3 已完成），native 必运行其测试，原"553→554（pure 包纯逻辑测试数另计）"表述与 T3 先例矛盾（T3 native 552 已含 pure 6 测试），Checker 按 554 验证会误判
- [一般] QOI_OP_LUMA 标签测试缺失：明示"支持全部 6 种 QOI 标签"，测试却仅覆盖 5 种（缺 LUMA），LUMA 是最复杂双字节差分分支（`src/format/qoi.mbt:73-81`，dg/dr_dg/db_dg 二级差分），未测试则正确性无保证
修正方向（已逐一核实源码论证）：
1. **API 引用修正**：`@core.encode_qoi` → `@format.encode_qoi`、`@core.decode_qoi` → `@format.decode_qoi`。根包 `src/moon.pkg` 第 11 行已 import format，无需新增依赖。`roundtrip_test.mbt:95,96,108,109` 现有 QOI 测试均用 `@format.` 前缀，印证此为项目正确调用方式。
2. **描述更正**："FFI 基准解码" → "format 包纯 MoonBit 基准解码（交叉验证）"，如实说明对比双方均为纯 MoonBit 独立实现、stb C 库不原生支持 QOI、对比价值为独立实现交叉校验（可发现移植错误）而非 FFI 基准对照。选择理由中"QOI FFI 实现"同步更正为"QOI 纯 MoonBit 实现"。
3. **预期测试数修正**：pure 包新增 8 测试（5 正常标签 + LUMA + 2 错误路径），native 预期 553 + 1（根包对比）+ 8（pure 纯逻辑）= 562，不再使用"另计"模糊表述。
4. **新增 QOI_OP_LUMA 测试用例**：在 pure 包测试中新增 1 个 2x2 RGB 含 LUMA 编码用例，覆盖 dg/dr_dg/db_dg 二级差分解码分支（`src/format/qoi.mbt:73-81`），使测试覆盖全部 6 种 QOI 标签。
选择理由：审查意见 4 项全部属实（已核实 `src/format/qoi.mbt`、`src/reexport.mbt:824,842`、`src/roundtrip_test.mbt:95,96`、`src/moon.pkg:11` 源码），修正后计划 API 引用正确、描述如实、预期数准确、测试覆盖完整，可行性不再留待现场
