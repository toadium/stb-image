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

---

## R10 PASSED v2.0 pure 包 QOI 解码器（纯 MoonBit，全目标） [ID: T5]
结果：在 `src/pure/` 新增 `qoi_decode.mbt`（`decode_qoi_pure`，支持全部 6 种 QOI 标签 INDEX/DIFF/LUMA/RUN/RGB/RGBA）+ `qoi_decode_test.mbt`（8 纯逻辑测试，覆盖全部 6 标签 + 2 错误路径），根包 `roundtrip_test.mbt` 新增 1 个 native-only QOI pure vs format 交叉验证测试。`moon check` 全目标 0 errors 0 warnings，`moon test --target native` 562 通过（553→562，+8 pure 纯逻辑 + 1 根包对比）。
检查：PASSED。QOI 解码器移植正确（仅 @core→@types 类型引用替换，逻辑与 `src/format/qoi.mbt` 一致），8 测试覆盖全部 6 标签 + 2 错误路径且编码值经手算验证，1 native-only 交叉验证测试使用正确的 `@format` API，v1.0 API 冻结保持，现有测试不破坏。

## R10 NEW v2.0 pure 包 TGA 解码器（纯 MoonBit，全目标，含 RLE） [ID: T6]
任务：在 `src/pure/` 新增 `tga_decode.mbt`，实现纯 MoonBit TGA 解码器 `pub fn decode_tga_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持 image type 2（未压缩 RGB）和 type 10（RLE RGB），24-bit（comp=3）和 32-bit（comp=4），含 18 字节 header 解析、RLE 解压、bottom-up 行序翻转、BGR(A)→RGB(A) 转换。新增 `src/pure/tga_decode_test.mbt` 纯逻辑测试（全目标，手构造 TGA 字节流验证 type 2/type 10/24-bit/32-bit/行序/错误路径）。在根包 `src/roundtrip_test.mbt` 新增 1 个 native-only pure-FFI TGA 对比测试（`@core.write_tga_to_bytes` 生成 RLE TGA → `@pure.decode_tga_pure` vs `@core.load_from_bytes` 断言 width/height/channels/data 完全一致）。验证 `moon check` 全目标 0 errors 0 warnings，`moon test --target native` 全量通过。
选择理由：
- T5 已完成 QOI 解码器，pure 包当前 BMP+QOI 两种格式，需继续扩展格式覆盖以推进 v2.0 多目标支持实质功能
- TGA 格式简单（18 字节 header + RLE/无压缩像素），stb_image C 库原生支持 TGA 读写，对比验证为真正的 FFI 基准（非 QOI 的纯 MoonBit 交叉验证），价值更高
- `@core.write_tga_to_bytes` 已存在（`src/core/image_write_native.mbt:110`），`@core.load_from_bytes` 支持 TGA 解码，对比测试基础设施完备
- stb_image_write 默认输出 RLE 压缩 TGA（image type 10，`stbi_write_tga_with_rle=1`），pure 解码器须支持 RLE 解压，RLE 算法清晰（1 字节 header + run/raw packet），技术风险可控
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，TGA 解码器仅依赖 @types，全目标可用
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中
- 为后续后端选择层 `src/lib.mbt` 积累格式覆盖基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），6 纯逻辑测试（BMP）
- T5 产出：pure 包 QOI 解码器 + 8 纯逻辑测试，根包 QOI 对比测试，native 562 测试通过
- stb_image_write TGA 输出格式（`src/core/stb_image_write.h:532-609`）：18 字节 header（ID length=0, color map type=0, image type=10 RLE RGB, width/height LE, bpp=comp*8, descriptor=has_alpha*8），RLE 压缩，bottom-up 行序，BGR(A) 像素顺序（`stbiw__write_pixel` rgb_dir=-1 → 输出 d[2],d[1],d[0] 即 BGR）
- TGA RLE 编码：header 1 字节，bit7=1 → RLE packet（run=(header&0x7F)+1，读 1 像素重复 run 次），bit7=0 → raw packet（count=(header&0x7F)+1，读 count 像素）
- TGA header 结构（18 字节）：[0]ID length [1]color map type [2]image type [3-4]color map start LE [5-6]color map length LE [7]color map bits [8-9]x origin LE [10-11]y origin LE [12-13]width LE [14-15]height LE [16]bpp [17]descriptor（bit4=0 bottom-up, bit4=1 top-down）
- `@core.write_tga_to_bytes` 签名（`src/core/image_write_native.mbt:110`）：`pub fn write_tga_to_bytes(img : Image) -> Bytes raise LoadError`
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`
- `roundtrip_test.mbt` 现有 TGA 测试模式（line 63-73）：`@core.load_from_path` → `@core.write_tga_to_bytes` → `@core.load_from_bytes` → 断言 data 一致
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R11 RETRY v2.0 pure 包 TGA 解码器（纯 MoonBit，全目标，含 RLE） [ID: T6]
原因：计划审查 v6 r1 REJECTED，1 项问题
- [一般] 错误路径测试覆盖与实现要求不一致：task_v6.md line 16 明确要求 pure 解码器实现三种错误路径（数据过短、不支持的 image type、不支持的 bpp），但 line 25 测试覆盖建议仅列两种（数据过短、不支持的 image type），遗漏"不支持的 bpp"。line 16 与 line 25 同一文档内对错误路径枚举不一致，Doer 按 line 25 实现会遗漏"不支持的 bpp"错误路径测试，该分支（`if bpp != 24 && bpp != 32`）未被验证。TGA 格式存在多种位深（8/15/16 灰度/索引），错误拒绝逻辑是解码器健壮性关键组成，未测试则正确性无保证。
修正方向（已覆写 task_v6.md）：
1. **line 25 错误路径枚举补充**：原"数据过短、不支持的 image type（如 type 1 颜色映射）" → "数据过短、不支持的 image type（如 type 1 颜色映射）、不支持的 bpp（如 bpp=16 或 bpp=8）"，与 line 16 的三种错误路径一致
2. **line 26 测试数建议调整**：原"建议 7-9 个" → "建议 8-10 个"，并明确"含 3 个错误路径测试：数据过短 + 不支持 image type + 不支持 bpp"
3. **line 38 预期 native 测试数同步调整**：原"建议 7-9 个，即预期 570-572" → "建议 8-10 个，即预期 571-573"
选择理由：审查意见属实（line 16 与 line 25 同文档内不一致，"不支持的 bpp"错误路径测试缺失），修正仅补充测试覆盖建议不涉实现逻辑变更，风险极低，修正后 line 16 与 line 25 一致、测试覆盖完整

---

## R12 PASSED v2.0 pure 包 TGA 解码器（纯 MoonBit，全目标，含 RLE） [ID: T6]
结果：在 `src/pure/` 新增 `tga_decode.mbt`（`decode_tga_pure`，支持 image type 2/10、24/32-bit、RLE 解压、bottom-up/top-down 行序、BGR(A)→RGB(A) 转换）+ `tga_decode_test.mbt`（9 纯逻辑测试，覆盖 type 2/type 10/24-bit/32-bit/行序/3 错误路径），根包 `roundtrip_test.mbt` 新增 1 个 native-only TGA pure vs FFI 对比测试。`moon check` 全目标 0 errors 0 warnings，`moon test --target native` 572 通过（562→572，+9 pure 纯逻辑 + 1 根包对比）。
检查：PASSED。TGA 解码器实现完整（18 字节 header 解析、RLE 解压、行序翻转、BGR→RGB 转换、5 错误路径），9 测试覆盖所有功能点含 3 错误路径测试，1 FFI 基准对比测试（stb_image C 库原生支持 TGA 读写），v1.0 API 冻结保持，现有测试不破坏。

## R12 NEW v2.0 pure 包 PNM 解码器（纯 MoonBit，全目标） [ID: T7]
任务：在 `src/pure/` 新增 `pnm_decode.mbt`，实现纯 MoonBit PNM 解码器 `pub fn decode_pnm_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持 P5（PGM 二进制灰度，channels=1）和 P6（PPM 二进制 RGB，channels=3），8-bit（maxval < 256），含 header 解析（magic + width + height + maxval，处理注释行 `#` 和任意 whitespace）、像素读取、错误路径（数据过短、不支持的 magic 如 P1-P4 ASCII、不支持的 maxval ≥ 256）。新增 `src/pure/pnm_decode_test.mbt` 纯逻辑测试（全目标，手构造 PNM 字节流验证 P5/P6 解码、注释行、错误路径）。在根包 `src/roundtrip_test.mbt` 新增 2 个 native-only pure-FFI PNM 对比测试（PPM RGB + PGM 灰度，用 `@format.encode_ppm`/`encode_pgm` 生成 PNM 字节流 → `@pure.decode_pnm_pure` 纯解码 vs `@core.load_from_bytes` FFI 基准解码 → 断言 width/height/channels/data 完全一致）。验证 `moon check` 全目标 0 errors 0 warnings，`moon test --target native` 572→581 通过。
选择理由：
- T6 已完成 TGA 解码器，pure 包当前 BMP+QOI+TGA 三种格式，需继续扩展格式覆盖以推进 v2.0 多目标支持实质功能
- PNM（P5/P6 二进制）格式最简单（无压缩，header + 原始像素），实现风险极低，适合继续积累 pure 包格式覆盖
- stb_image C 库原生支持 PNM 解码（`@core.load_from_bytes` 可加载 PPM/PGM，见 `pnm_encode_test.mbt:23,76`），对比验证为真正的 FFI 基准（非 QOI 的纯 MoonBit 交叉验证），价值高
- `@format.encode_ppm`/`encode_pgm` 已有纯 MoonBit 编码（`src/format/pnm_encode.mbt:6,37`），可生成对比测试数据，基础设施完备
- PNM 是项目已有格式（v1.5 PNM 编码），补齐 pure 包解码使格式覆盖更完整
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，PNM 解码器仅依赖 @types，全目标可用，无需架构改动
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 积累更多格式覆盖基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），全目标可用
- T6 产出：pure 包 BMP+QOI+TGA 三种解码器，native 572 测试通过
- PNM 二进制格式规格（P5/P6）：
  - Header：magic(2 字节 "P5" 或 "P6") + whitespace + width(ASCII 十进制) + whitespace + height(ASCII 十进制) + whitespace + maxval(ASCII 十进制) + 单个 whitespace + 像素数据
  - whitespace：space(0x20)/tab(0x09)/LF(0x0A)/CR(0x0D)，header 中 width/height/maxval 间任意 whitespace 分隔，maxval 后恰好 1 个 whitespace（通常 LF）
  - 注释行：`#` 开头至行尾，可出现在 header 任意位置（magic 后）
  - maxval < 256：每通道 1 字节；maxval ≥ 256：每通道 2 字节 big-endian（本轮不支持）
  - P5：width*height 字节灰度像素；P6：width*height*3 字节 RGB 像素
- `@format.encode_ppm` 签名（`src/format/pnm_encode.mbt:6`）：`pub fn encode_ppm(img : @core.Image) -> Bytes`，输出 "P6\n{w} {h}\n255\n" + RGB 像素
- `@format.encode_pgm` 签名（`src/format/pnm_encode.mbt:37`）：`pub fn encode_pgm(img : @core.Image) -> Bytes`，输出 "P5\n{w} {h}\n255\n" + 灰度像素
- `@core.load_from_bytes` 支持 PNM 解码（`pnm_encode_test.mbt:23,76` 现有 roundtrip 测试印证）
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`，第 11 行已 import format
- `roundtrip_test.mbt` 现有 PNM 测试模式（line 148-174）：`@format.encode_ppm`/`encode_pgm` → `@core.load_from_bytes` → 断言 data 一致
- pure 包 `src/pure/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R8 PASSED v2.0 pure 包 PNM 解码器（纯 MoonBit，全目标） [ID: T7]
结果：在 `src/pure/` 新增 `pnm_decode.mbt`（`decode_pnm_pure`，支持 P5/P6 8-bit，含注释行/任意 whitespace 解析）+ `pnm_decode_test.mbt`（8 纯逻辑测试），根包 `roundtrip_test.mbt` 新增 2 个 native-only PNM pure vs FFI 对比测试（PPM RGB + PGM grayscale）。`moon check` 全目标 0 errors 0 warnings，`moon test --target native` 582 通过（572→582，+8 pure 纯逻辑 + 2 根包对比）。
检查：PASSED。PNM 解码器实现完整（P5/P6 magic、注释行、whitespace、maxval 校验、错误路径），8 测试覆盖所有功能点含 3 错误路径，2 FFI 基准对比测试，v1.0 API 冻结保持，现有测试不破坏。

## R8 NEW v2.0 pure 包 PSD 解码器（纯 MoonBit，全目标，无压缩 8-bit） [ID: T8]
任务：在 `src/pure/` 新增 `psd_decode.mbt`，实现纯 MoonBit PSD 解码器 `pub fn decode_psd_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持 8-bit、RGB（channels=3）/RGBA（channels=4）、无压缩（compression=0）。解析 PSD header（大端序：signature "8BPS" + version=1 + reserved(6) + channels + h + w + depth=8 + colorMode=3），跳过 color mode data/image resources/layer and mask data（各含 4 字节 BE length 前缀），读取无压缩像素数据按通道交错（RRRGGGBBB → RGBRGBRGB），返回原始通道数。新增 `src/pure/psd_decode_test.mbt` 8 个纯逻辑测试（RGB/RGBA/交错验证/1x1/4 错误路径）。在根包 `src/roundtrip_test.mbt` 新增 2 个 native-only pure-FFI PSD 对比测试（3 通道 RGB 用 req_channels=Some(3) 匹配 + 4 通道 RGBA alpha=255 避免 white matte removal，手构造 PSD 字节流 → @pure.decode_psd_pure vs @core.load_from_bytes 断言 width/height/channels/data 完全一致）。验证 `moon check` 全目标 0 errors 0 warnings，`moon test --target native` 582→592 通过。
选择理由：
- T7 已完成 PNM 解码器，pure 包当前 BMP+QOI+TGA+PNM 四种格式，需继续扩展格式覆盖以推进 v2.0 多目标支持实质功能
- PSD 是 stb-image 独家格式（ROADMAP.md "PSD/HDR/PNM 独家格式"），补齐 pure 包 PSD 解码使独家格式覆盖更完整，实用价值高
- stb_image C 库原生支持 PSD 解码（`stb_image.h:6126 stbi__psd_load`，8/16-bit、RGB、raw/RLE），`@core.load_from_bytes` 可解码 PSD，对比验证为真正的 FFI 基准
- PSD 无压缩 8-bit 格式简单（header + 跳过 3 个 length 前缀段 + 按通道排列像素），仅需大端序读取 + 通道交错，技术风险低
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，PSD 解码器仅依赖 @types，全目标可用，无需架构改动
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 积累更多格式覆盖基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），全目标可用
- T7 产出：pure 包 BMP+QOI+TGA+PNM 四种解码器，native 582 测试通过
- PSD 文件格式（大端序，参考 Adobe PSD 规范 + `stb_image.h:6126-6280` stbi__psd_load）：
  - Header（26 字节）：signature(4 "8BPS" 0x38425053) + version(2 BE, =1) + reserved(6, =0) + channelCount(2 BE, 1-16) + h(4 BE) + w(4 BE) + bitdepth(2 BE, 8 or 16) + colorMode(2 BE, =3 RGB)
  - Color mode data：length(4 BE) + data（RGB 模式 length=0）
  - Image resources：length(4 BE) + data
  - Layer and mask data：length(4 BE) + data
  - Image data：compression(2 BE, 0=raw, 1=RLE) + 像素数据
  - 无压缩 8-bit 像素：按通道排列（channel[0] 的 w*h 字节，channel[1] 的 w*h 字节，...），通道顺序 R(0)/G(1)/B(2)/A(3)
  - 交错到 Image.data：`data[i*channels + c] = channel_data[c*w*h + i]`
- stb_image PSD 解码行为（`stb_image.h:6126-6280`）：总是内部输出 4 通道 RGBA（channel >= channelCount 时填充默认值：channel 3 = 255，其他 = 0），channelCount >= 4 时做 white matte removal（alpha != 0 && alpha != 255 时修改 RGB）。@core.load_from_bytes 默认返回 4 通道，req_channels=Some(3) 返回 3 通道
- 对比测试策略：3 通道 PSD 用 req_channels=Some(3) 匹配 pure 的 3 通道输出；4 通道 PSD alpha=255 避免 white matte removal（stb_image 不修改 RGB），pure 不实现 white matte removal
- `@core.load_from_bytes` 签名（`src/core/image_load_native.mbt:3`）：`pub fn load_from_bytes(data : Bytes, req_channels~ : Option[Int] = None) -> Image raise LoadError`
- pure 包解码器签名惯例：`pub fn decode_xxx_pure(data : Bytes) -> @types.Image raise @types.LoadError`（BMP/QOI/TGA/PNM 一致）
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`
- pure 包 `src/pure/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R14 RETRY v2.0 pure 包 PSD 解码器（纯 MoonBit，全目标，无压缩 8-bit） [ID: T8]
原因：计划审查 v8 r1 REJECTED，2 项问题
- [一般] 错误路径测试覆盖与实现要求不一致：task_v8.md line 32-41 列出 9 种错误路径，但 line 47-55 仅 8 测试覆盖 4 种错误路径（signature、too short、bitdepth、compression），遗漏 5 种（version、channelCount、colorMode、尺寸无效、像素数据不足）。4 正例 + 9 错误路径 = 13 测试 > 8，line 47 硬性限定"8 个测试用例"与 9 种错误路径无法兼容
- [轻微] 预期测试数与错误路径测试扩充后不一致：line 67 预期 582→592 基于 8 测试，补充错误路径测试后需同步调整
修正方向（已覆写 task_v8.md）：
1. **pure 包纯逻辑测试数从 8 增加到 13**（4 正例 + 9 错误路径），覆盖 line 32-41 列出的全部 9 种错误路径。参考 T6 R11 RETRY 修正先例（plan.md line 202-205，测试数建议从 7-9 调整到 8-10）
2. **line 47-55 测试用例补充 5 个错误路径测试**：bad version raises（version=2）、unsupported channelCount raises（channelCount=1 灰度）、unsupported colorMode raises（colorMode=1 Grayscale）、invalid dimensions raises（w=0）、pixel data insufficient raises（像素数据截断）
3. **line 67 预期 native 测试数同步调整**：原"582→592（+8 pure 纯逻辑 + 2 根包对比）" → "582→597（+13 pure 纯逻辑 + 2 根包对比）"
4. **line 47 测试数表述调整**：原"8 个测试用例" → "13 个测试用例（4 正例 + 9 错误路径）"
选择理由：审查意见属实（line 32-41 列 9 种错误路径而 line 47-55 仅覆盖 4 种，同文档内不一致，与 T6 R11 RETRY 同类），修正仅补充测试覆盖不涉实现逻辑变更，风险极低，修正后 line 32-41 与 line 47-55 一致、测试覆盖完整

---

## R15 PASSED v2.0 pure 包 PSD 解码器（纯 MoonBit，全目标，无压缩 8-bit） [ID: T8]
结果：在 `src/pure/` 新增 `psd_decode.mbt`（`decode_psd_pure`，支持 8-bit RGB/RGBA 无压缩，大端序读取 + 通道交错）+ `psd_decode_test.mbt`（13 纯逻辑测试，4 正例 + 9 错误路径），根包 `roundtrip_test.mbt` 新增 2 个 native-only PSD pure vs FFI 对比测试。`moon check` 全目标 0 errors 0 warnings，`moon test --target native` 597 通过（582→597，+13 pure 纯逻辑 + 2 根包对比）。
检查：PASSED。PSD 解码器实现完整（大端序解析 + 通道交错公式与规范一致，9 条错误路径全覆盖），13 纯逻辑测试 + 2 FFI 基准对比测试全部通过，三目标构建零错误零警告，v1.0 API 冻结保持，现有测试未破坏。

## R15 NEW v2.0 pure 包 GIF 解码器（纯 MoonBit，全目标，单帧，LZW） [ID: T9]
任务：在 `src/pure/` 新增 `gif_decode.mbt`，实现纯 MoonBit GIF 解码器 `pub fn decode_gif_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持 GIF89a/GIF87a 单帧解码（RGB，channels=3），含 header + Logical Screen Descriptor + Global/Local Color Table + Extension block 跳过 + LZW 解压（变长码 LSB 优先 + 字典重建 + 子块结构），暂不支持 interlace。新增 `src/pure/gif_decode_test.mbt` 10 个纯逻辑测试（3 正例 + 7 错误路径，全目标）。在根包 `src/roundtrip_test.mbt` 新增 1 个 native-only pure-FFI GIF 对比测试（`@format.encode_gif` 生成 GIF → `@pure.decode_gif_pure` vs `@core.load_from_bytes(req_channels=Some(3))` 断言 width/height/channels/data 完全一致）。验证 `moon check` 全目标 0 errors 0 warnings，`moon test --target native` 597→608 通过。
选择理由：
- T8 已完成 PSD 解码器，pure 包当前 BMP+QOI+TGA+PNM+PSD 五种格式，需继续扩展格式覆盖以推进 v2.0 多目标支持实质功能
- GIF 是最常用的图像格式之一（Web 早期标准格式），实用价值最高，补齐 GIF 解码使 pure 包格式覆盖更完整
- stb_image C 库原生支持 GIF 解码（stbi__gif_load），`@core.load_from_bytes` 可解码 GIF，对比验证为真正的 FFI 基准
- `@format.encode_gif` 已有纯 MoonBit 编码（`src/format/gif_encode.mbt:119`），可生成对比测试数据，基础设施完备
- GIF LZW 解码是经典算法（变长码 + 字典重建），算法清晰，技术风险可控
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，GIF 解码器仅依赖 @types，全目标可用，无需架构改动
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中
- 为后续后端选择层 `src/lib.mbt` 积累更多格式覆盖基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），全目标可用
- T8 产出：pure 包 BMP+QOI+TGA+PNM+PSD 五种解码器，native 597 测试通过
- GIF89a 格式：header(6) + LSD(7) + GCT(可选) + blocks(0x2C Image / 0x21 Extension / 0x3B Trailer)
- LZW 解码：变长码 LSB 优先 + 字典重建 + 子块结构，code_width 上限 12
- `@format.encode_gif`（`src/format/gif_encode.mbt:119`）：GIF89a，3-3-2 量化 256 色 GCT，LZW min code size=8，不使用交错
- `@core.load_from_bytes` 支持 GIF 解码，`req_channels=Some(3)` 强制 3 通道
- roundtrip_test.mbt 现有 GIF 测试模式（line 135-146）
- pure 包解码器签名惯例：`pub fn decode_xxx_pure(data : Bytes) -> @types.Image raise @types.LoadError`
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`，第 11 行已 import format
- pure 包 `src/pure/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R16 RETRY v2.0 pure 包 GIF 解码器（纯 MoonBit，全目标，单帧，LZW） [ID: T9]
原因：计划审查 v9 r1 REJECTED，4 项问题
- [一般] 纯逻辑测试缺少 Local Color Table（LCT）覆盖：3 个正例均使用 GCT，无 LCT 测试用例，`@format.encode_gif` 不输出 LCT（`src/format/gif_encode.mbt:167` packed=0x00，bit7=0）故根包对比测试也无法覆盖，LCT 解析和 LCT 优先于 GCT 查找逻辑未测试则正确性无保证，与 T6 R11 RETRY、T8 R14 RETRY 修正的测试覆盖标准不一致
- [轻微] Plain Text Extension（0x01）跳过逻辑描述不完全正确：GIF89a 规范中 Plain Text Extension 在 label 之后有 8 字节固定 header（left/top/grid width/grid height/cell width/cell height/text fg/text bg），然后才是子块，原描述统一按子块跳过会误将 header 当子块 length 解析
- [轻微] LZW min code size 有效范围与 GIF 规范不一致：原定义无效条件为"> 8 或 == 0"即接受 min code size=1，但 GIF89a 规范要求 min code size >= 2（即使颜色表仅 2 色也须为 2 以容纳 clear_code 和 end_code）
- [轻微] interlace 错误路径未列入错误路径列表：实现要求 line 30 要求 interlace 时 raise LoadError，但 7 种错误路径列表未包含 interlace，该拒绝分支未被测试覆盖
修正方向（已逐一修正，覆写 task_v9.md）：
1. **新增 LCT 测试用例**：正例 4 含 Local Color Table 的 GIF（2x2，Image Descriptor packed bit7=1，LCT 4 色，GCT 2 色，LCT 索引与 GCT 不同），验证 LCT 解析正确且 LCT 优先于 GCT 查找
2. **Plain Text Extension 跳过描述修正**：明确 Plain Text Extension（0x01）先跳过 8 字节固定 header，再读子块；其他 Extension 直接读子块跳过
3. **LZW min code size 有效范围修正**：无效条件从"> 8 或 == 0"修正为"> 8 或 < 2"，与 GIF89a 规范一致
4. **interlace 错误路径列入列表**：错误路径新增第 8 种"interlace 不支持"，测试数从 10 调整到 12（4 正例 + 8 错误路径），预期 native 测试数从 597→608 调整为 597→610
选择理由：审查意见 4 项全部属实（LCT 是 GIF 格式核心可选功能未测试则实现正确性无保证；Plain Text Extension 8 字节 header 是 GIF89a 规范明确要求；LZW min code size >= 2 是 GIF89a 规范约束；interlace 拒绝分支未测试则健壮性无保证），修正仅补充测试覆盖与描述精确化不涉实现逻辑变更，风险极低，修正后测试覆盖完整、描述与规范一致

---

## R17 RETRY v2.0 pure 包 GIF 解码器（纯 MoonBit，全目标，单帧，LZW） [ID: T9]
原因：计划审查 v9 r2 REJECTED，3 项问题
- [一般] Plain Text Extension（0x01）跳过逻辑未测试覆盖：实现要求 line 17 明确区分 Plain Text Extension（0x01）的特殊跳过逻辑（先跳 8 字节固定 header，再读子块），与其他 Extension（直接读子块跳过）不同，但测试用例正例 3 仅覆盖 Graphic Control Extension（0xF9，属"其他 Extension"直接读子块分支），未覆盖 Plain Text Extension（0x01）的特殊跳过分支。若 Doer 误将所有 Extension 统一按子块跳过（忽略 Plain Text 的 8 字节 header），会误将 header 首字节当子块 length 解析，导致后续数据错位，但测试不会发现此错误
- [轻微] 未知 Extension label 处理未明确：line 17 列出 4 种已知 label，但未明确遇到未知 label（如 0x00 或其他未定义值）时的处理方式。GIF89a 规范要求解码器跳过未知 Extension 以保持前向兼容
- [轻微] Image Descriptor 的 left/top 非 0 情况处理未明确：line 15 解析 Image Descriptor 的 left/top 字段，但未说明 left/top 非 0 时如何处理（单帧 GIF 子图像定位）。输出要求 line 31 仅说 `@types.Image` with channels=3，未明确 width/height 取 Logical Screen Descriptor 的还是 Image Descriptor 的
修正方向（已逐一修正，覆写 task_v9.md）：
1. **新增 Plain Text Extension 测试用例**：正例 5 含 Plain Text Extension（0x01）的 GIF（1x1，字节流：header + LSD + GCT + 0x21 + 0x01 + 8 字节固定 header + 子块数据 + 0x2C Image Separator + Image Descriptor + LZW data + 0x3B），验证 Plain Text Extension 的 8 字节固定 header 被正确跳过且后续 Image Descriptor 正确解析。测试数从 12 调整到 13（5 正例 + 8 错误路径），预期 native 测试数从 597→610 调整为 597→611
2. **未知 Extension label 处理明确声明**：line 17 补充"其他 Extension（含未知 label，如 0x00 或其他未定义值，按子块结构跳过以保持前向兼容）直接读子块跳过"，显式声明未知 label 按子块结构跳过
3. **Image Descriptor left/top 处理明确声明**：line 31 输出要求补充"width/height 取 Image Descriptor 的 width/height，忽略 left/top（单帧 GIF 子图像定位无意义；`@format.encode_gif` 输出 left=top=0 且 Image w/h = Logical Screen w/h，对比测试不受影响；纯逻辑测试不构造 left/top 非 0 用例）"
选择理由：审查意见 3 项全部属实（Plain Text Extension 8 字节 header 跳过是与"直接读子块"不同的实现分支，未测试则正确性无保证，与此前 RETRY 修正的"测试覆盖与实现要求一致"标准一致；未知 label 处理需显式声明以保持前向兼容；left/top 非 0 处理需明确避免行为未定义），修正仅补充 1 个测试用例与 2 处描述精确化不涉实现逻辑变更，风险极低，修正后测试覆盖完整、描述与规范一致、行为定义明确

---

## R18 PASSED v2.0 pure 包 GIF 解码器（纯 MoonBit，全目标，单帧，LZW） [ID: T9]
结果：在 `src/pure/` 新增 `gif_decode.mbt`（`decode_gif_pure`，支持 GIF89a/GIF87a 单帧解码，含 LZW 解压、GCT/LCT、Extension 跳过含 Plain Text 8 字节 header 特殊处理）+ `gif_decode_test.mbt`（13 纯逻辑测试，5 正例 + 8 错误路径），根包 `roundtrip_test.mbt` 新增 1 个 native-only GIF pure vs FFI 对比测试。`moon check` 全目标 0 errors 0 warnings，`moon test --target native` 611 通过（597→611，+13 pure 纯逻辑 + 1 根包对比）。
检查：PASSED。GIF 解码器实现完整（Header/LSD/GCT/LCT/Blocks/LZW/颜色表查找优先级），Plain Text Extension 8 字节 header 跳过逻辑正确且有测试覆盖，未知 Extension label 按子块结构跳过保持前向兼容，输出 width/height 取 Image Descriptor 且忽略 left/top，8 条错误路径全部覆盖，13 纯逻辑测试 + 1 FFI 基准对比测试全部通过，v1.0 API 冻结保持，现有测试未破坏。

## R18 NEW v2.0 pure 包 QOI + PNM 编码器（纯 MoonBit，全目标） [ID: T10]
任务：在 `src/pure/` 新增 `qoi_encode.mbt`（移植 `src/format/qoi.mbt:121-231` 的 `encode_qoi` + `qoi_hash` 辅助函数，签名 `pub fn encode_qoi_pure(img : @types.Image) -> Bytes raise @types.LoadError`，支持 RGB channels=3 / RGBA channels=4）和 `pnm_encode.mbt`（移植 `src/format/pnm_encode.mbt` 的 `encode_ppm`/`encode_pgm`/`encode_pnm`，签名 `pub fn encode_ppm_pure(img : @types.Image) -> Bytes` / `encode_pgm_pure` / `encode_pnm_pure`），将 `@core.Image`/`@core.LoadError` 引用替换为 `@types.Image`/`@types.LoadError`，`@encoding/utf8` 依赖保持（pure 包 moon.pkg 新增 `moonbitlang/core/encoding/utf8` import，全目标可用）。新增 `src/pure/qoi_encode_test.mbt`（5 纯逻辑测试：RGB 编码 + RGBA 编码 + run-length 编码 + 索引编码 + 错误路径 channels=2）和 `src/pure/pnm_encode_test.mbt`（5 纯逻辑测试：PPM RGB 编码 + PGM 灰度编码 + PNM 自动选择 + RGBA 丢弃 alpha + 灰度输入转 RGB），全目标仅依赖 @types/@pure。在根包 `src/roundtrip_test.mbt` 新增 3 个 native-only roundtrip 测试（QOI pure encode→pure decode + PPM pure encode→pure decode + PGM pure encode→pure decode，断言 roundtrip 后 width/height/channels/data 与原始图像一致）。验证 `moon check` 全目标 0 errors 0 warnings，`moon test --target native` 611→624 通过（+10 pure 纯逻辑 + 3 根包 roundtrip）。
选择理由：
- T9 已完成 GIF 解码器，pure 包已有 6 种格式解码器（BMP/QOI/TGA/PNM/PSD/GIF），但仅有解码器无编码器，无法构成完整编解码能力
- v2.0 后端选择层 `src/lib.mbt` 需要 pure 包具备与 native 对等的编解码能力，当前 pure 包只有解码是核心缺口
- QOI 和 PNM 编码器移植技术风险极低：`src/format/qoi.mbt:121-231` 和 `src/format/pnm_encode.mbt` 均为纯 MoonBit 实现（无 FFI/C stub），仅需替换 @core→@types 类型引用，与 T5（QOI 解码器移植）同构
- QOI 编码器需一并移植 `qoi_hash` 辅助函数（`src/format/qoi.mbt:7`，私有函数 `(r*3+g*5+b*7+a*11)%64`）
- PNM 编码器依赖 `@encoding/utf8`（`src/format/pnm_encode.mbt:23` `@encoding/utf8.encode(header)`），该依赖为 moonbitlang/core 标准库全目标可用，pure 包 moon.pkg 新增 import 即可
- 一轮完成 QOI + PNM 两个编码器合理：编码器比解码器简单（纯输出无解析），代码量小（encode_qoi 111 行 + pnm_encode 76 行），且使 pure 包立即具备 QOI 和 PNM 完整 roundtrip 能力
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，roundtrip 测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 和 pure 包更多编码器（GIF/TGA/BMP）奠定基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），全目标可用
- T9 产出：pure 包 BMP+QOI+TGA+PNM+PSD+GIF 六种解码器，native 611 测试通过
- `src/format/qoi.mbt:7`：`fn qoi_hash(r,g,b,a) -> Int`，私有辅助 `(r*3+g*5+b*7+a*11)%64`
- `src/format/qoi.mbt:121-231`：`pub fn encode_qoi(img : @core.Image) -> Bytes raise @core.LoadError`，纯 MoonBit，支持 QOI_OP_INDEX/DIFF/LUMA/RUN/RGB/RGBA 编码，8 字节 header + 像素编码 + 8 字节 padding
- `src/format/pnm_encode.mbt:6`：`pub fn encode_ppm(img : @core.Image) -> Bytes`，输出 "P6\n{w} {h}\n255\n" + RGB 像素
- `src/format/pnm_encode.mbt:37`：`pub fn encode_pgm(img : @core.Image) -> Bytes`，输出 "P5\n{w} {h}\n255\n" + 灰度像素（BT.601）
- `src/format/pnm_encode.mbt:70`：`pub fn encode_pnm(img : @core.Image) -> Bytes`，channels<=1 → PGM else → PPM
- `src/format/moon.pkg:3`：import `moonbitlang/core/encoding/utf8` @encoding/utf8（全目标标准库）
- pure 包 `src/pure/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标；本轮新增 `@encoding/utf8` import
- pure 包解码器签名惯例：`pub fn decode_xxx_pure(data : Bytes) -> @types.Image raise @types.LoadError`（BMP/QOI/TGA/PNM/PSD/GIF 一致）
- pure 包已有 `decode_qoi_pure`（T5）和 `decode_pnm_pure`（T7），可构成 roundtrip
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`，第 11 行已 import format
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R19 RETRY v2.0 pure 包 QOI + PNM 编码器（纯 MoonBit，全目标） [ID: T10]
原因：计划审查 v10 r1 REJECTED，4 项问题
- [严重] qoi_hash 同包同名顶层函数冲突：task_v10.md 要求在 qoi_encode.mbt 新增 qoi_hash，但 `src/pure/qoi_decode.mbt:9` 已定义同名函数 `fn qoi_hash(r : Int, g : Int, b : Int, a : Int) -> Int`，MoonBit 中 `fn`（无 `pub`）是包私有而非文件私有，同包内同名顶层函数冲突，`moon check` 会报 duplicate definition（与 do_v9.md line 49 记录的 `read_u16_le` 命名冲突同类，v9 已遇并处理过此问题）
- [一般] QOI 编码器纯逻辑测试缺失 DIFF 和 LUMA 标签覆盖：6 种编码标签仅覆盖 3-4 种（INDEX/RUN/RGBA），DIFF（0x40-0x7F，`src/format/qoi.mbt:185-188`）和 LUMA（0x80-0xBF，`src/format/qoi.mbt:189-196`）核心差分编码分支未测试，roundtrip 测试用全红图像不触发这些分支无法补救，与 T5 R9 RETRY 修正的"QOI_OP_LUMA 标签测试缺失"同类
- [轻微] roundtrip 测试未明确 req_channels=Some(3)：与现有测试惯例不一致（`roundtrip_test.mbt` line 119, 138, 152, 325, 344 均显式 req_channels=Some(3)）
- [轻微] roundtrip 测试 3 PGM data 验证描述不够具体 + QOI 编码器测试 3 run-length 构造描述模糊
修正方向（已逐一修正，覆写 task_v10.md）：
1. **qoi_hash 命名冲突**：qoi_encode.mbt 不重复定义 qoi_hash，直接复用 `qoi_decode.mbt:9` 已有的 qoi_hash（同包私有函数跨文件可见）。修正产出清单 line 14 和实现要求 line 25-27
2. **DIFF/LUMA 标签测试补充**：新增 2 个测试用例：(a) DIFF 标签测试——2x2 RGB，像素 (10,20,30)/(11,21,31)/(12,22,32)/(13,23,33)，首像素与 prev (0,0,0,255) 差异过大走 RGB 标签，后续 3 像素差分 (1,1,1) ∈ [-2,1] 触发 DIFF 标签 0x7F；(b) LUMA 标签测试——2x2 RGB，像素 (100,100,100)/(105,110,105)/(100,100,100)/(105,110,105)，像素 1 差分 dr=5/dg=10/db=5，dg=10 ∈ [-32,31] 但 dr=5 ∉ [-2,1] 触发 LUMA 标签 0xAA+0x33。测试数从 5 调整到 7，预期 native 测试数从 611→624 调整为 611→626
3. **roundtrip req_channels=Some(3) 明确**：3 个 roundtrip 测试均显式 `@core.load_from_path(path, req_channels=Some(3))`，与现有测试惯例一致
4. **PGM data 验证描述具体化 + run-length 构造描述明确化**：PGM data 验证明确"对原始 RGB 像素 (r,g,b) 计算 (r*299+g*587+b*114)/1000，与 decode_pnm_pure 输出的 data 逐字节比较"；run-length 测试明确"4 像素均为 (0,0,0)，与 prev (0,0,0,255) 相同，全触发 RUN 编码，输出 1 个 RUN 标签 0xC3"
选择理由：审查意见 4 项全部属实（已核实 `src/pure/qoi_decode.mbt:9` 确有 qoi_hash 定义、`src/format/qoi.mbt:185-196` 确有 DIFF/LUMA 分支、`roundtrip_test.mbt` 现有测试均显式 req_channels=Some(3)），修正仅消除命名冲突、补充测试覆盖、精确化描述不涉实现逻辑变更，风险极低，修正后计划可行性不再留待现场

---

## R20 PASSED v2.0 pure 包 QOI + PNM 编码器（纯 MoonBit，全目标） [ID: T10]
结果：在 `src/pure/` 新增 `qoi_encode.mbt`（`encode_qoi_pure`，复用 `qoi_decode.mbt` 的 `qoi_hash`，支持全部 6 种 QOI 标签）+ `pnm_encode.mbt`（`encode_ppm_pure`/`encode_pgm_pure`/`encode_pnm_pure`）+ 12 纯逻辑测试（7 QOI + 5 PNM，全目标），根包 `roundtrip_test.mbt` 新增 3 个 native-only roundtrip 测试（QOI/PPM/PGM pure encode→decode）。`moon.pkg` 新增 `@encoding/utf8` import。
检查：`moon check` 全目标 0 errors 0 warnings，`moon test --target native` 626 通过（611→626，+12 pure 纯逻辑 + 3 根包 roundtrip），v1.0 API 冻结保持，现有测试不破坏。

## R21 NEW v2.0 pure 包 GIF 编码器（纯 MoonBit，全目标，单帧） [ID: T11]
任务：在 `src/pure/` 新增 `gif_encode.mbt`，移植 `src/format/gif_encode.mbt:1-177` 的单帧 GIF 编码器（`quantize_332` + `build_332_palette` + `lzw_compress` + `encode_gif`），签名 `pub fn encode_gif_pure(img : @types.Image) -> Bytes raise @types.LoadError`，将 `@core.Image`/`@core.LoadError` 引用替换为 `@types.Image`/`@types.LoadError`，`@encoding/utf8` 依赖已在 pure 包 moon.pkg（T10 新增）。新增 `src/pure/gif_encode_test.mbt` 纯逻辑测试（全目标，覆盖 3-3-2 量化、LZW 压缩、RGB/RGBA 编码、header 结构、错误路径 channels=2）。在根包 `src/roundtrip_test.mbt` 新增 1 个 native-only GIF pure roundtrip 测试（`@pure.encode_gif_pure` → `@pure.decode_gif_pure`，断言 width/height/channels/data 一致；另新增 1 个 pure encode vs FFI 对比测试 `@pure.encode_gif_pure` → `@core.load_from_bytes(req_channels=Some(3))` 断言 width/height/channels/data 一致）。验证 `moon check` 全目标 0 errors 0 warnings，`moon test --target native` 626→636 通过。
选择理由：
- T10 已完成 QOI + PNM 编码器，pure 包当前 6 解码器 + 2 编码器（QOI/PNM），GIF 编码器是最后一个可低风险移植的编码器（BMP/TGA/PSD 编码器均为 FFI 实现无纯 MoonBit 版本可移植）
- `src/format/gif_encode.mbt:1-177` 单帧 GIF 编码器为纯 MoonBit 实现（3-3-2 量化 + LZW 压缩，177 行），仅依赖 `@core.Image`/`@core.LoadError`/`@encoding/utf8`，移植到 pure 包仅需替换类型引用，与 T10（QOI+PNM 编码器移植）同构，技术风险极低
- GIF 是 Web 早期标准格式，实用价值高，补齐 GIF 编码器使 pure 包具备 GIF 完整 roundtrip 能力（pure encode→pure decode + pure encode vs FFI 对比）
- pure 包已有 `decode_gif_pure`（T9），移植 `encode_gif_pure` 后可构成 roundtrip 验证
- `@encoding/utf8` 依赖已在 pure 包 moon.pkg（T10 新增），无需新增依赖
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，GIF 编码器仅依赖 @types + @encoding/utf8，全目标可用
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，roundtrip 测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 积累更完整的 pure 包编解码能力（6 解码 + 3 编码）
- 暂不移植 `encode_gif_animation`（多帧动画编码，line 184-291），单帧编码已能验证 GIF 编码核心逻辑（3-3-2 量化 + LZW 压缩），多帧动画编码留待后续轮次
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），全目标可用
- T9 产出：pure 包 GIF 解码器 `decode_gif_pure`（单帧，GIF89a/GIF87a，LZW 解压，GCT/LCT）
- T10 产出：pure 包 QOI+PNM 编码器，`@encoding/utf8` 依赖已在 pure 包 moon.pkg，native 626 测试通过
- `src/format/gif_encode.mbt:1-177`：单帧 GIF 编码器，纯 MoonBit 实现
  - `quantize_332(r,g,b)` (line 7-12)：3-3-2 量化，R 8 levels + G 8 levels + B 4 levels = 256 colors
  - `build_332_palette()` (line 17-28)：构建 256 色 3-3-2 调色板（768 字节）
  - `lzw_compress(indices, min_code_size)` (line 34-113)：LZW 压缩，变长码 + 字典 + sub-block 包装
  - `encode_gif(img)` (line 119-177)：GIF89a header + LSD + GCT + Image Descriptor + LZW data + Trailer
- `src/format/gif_encode.mbt:184-291`：`encode_gif_animation`（多帧动画编码），本轮暂不移植
- pure 包 `src/pure/moon.pkg`：import types + @encoding/utf8（T10 新增），无 `supported_targets`，全目标
- pure 包已有 `decode_gif_pure`（T9），可构成 roundtrip
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`，第 11 行已 import format
- `roundtrip_test.mbt` 现有 GIF 测试模式（line 135-146）：`@format.encode_gif` → `@core.load_from_bytes` → 断言 data 一致
- pure 包解码器/编码器签名惯例：`pub fn decode_xxx_pure(data : Bytes) -> @types.Image raise @types.LoadError` / `pub fn encode_xxx_pure(img : @types.Image) -> Bytes raise @types.LoadError`
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R21 RETRY v2.0 pure 包 GIF 编码器（纯 MoonBit，全目标，单帧） [ID: T11]
原因：计划审查 v11 r1 REJECTED，2 项严重问题
- [严重] 测试 5 "data 一致" 比较双方不明确且技术不可行：测试 5 用 2x2 RGB 像素 (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)，`encode_gif_pure` → `decode_gif_pure` 后断言 "data 一致"。但 `encode_gif_pure` 内部做 3-3-2 量化（`src/format/gif_encode.mbt:154`），roundtrip 后 data 是量化后颜色而非原始颜色。经核实源码量化逻辑：(10,20,30)→(0,0,0)；(40,50,60)→(36,36,0)；(70,80,90)→(72,72,85)；(100,110,120)→(108,108,85)。roundtrip 后 data=[0,0,0,36,36,0,72,72,85,108,108,85] 与原始 [10,20,30,...] 不一致。描述未给出量化后预期 data 也未说明 "一致" 的比较双方，Doer 按 "与原始 data 一致" 实现则测试必然失败
- [严重] 测试 2 "data 逐像素比较" 比较双方不明确且技术不可行：测试 2 数据流描述为 `@core.load_from_path` → `@pure.encode_gif_pure` → `@core.load_from_bytes(req_channels=Some(3))`，断言 "data 逐像素比较"。数据流中仅有 orig_img、gif_bytes、ffi_img 三个变量，"data 逐像素比较" 的双方未明确。若比较 ffi_img vs orig_img：(255,0,0) 经 3-3-2 量化为 (252,0,0) 不一致，测试失败。若比较 ffi_img vs pure_img：描述数据流缺少 `@pure.decode_gif_pure` 步骤，Doer 无法从描述推断此比较方向
修正方向（已逐一修正，覆写 task_v11.md）：
1. **测试 5 修正（采用审查推荐方案 b）**：明确给出量化后预期 data 并断言 roundtrip 结果与之一致。原"断言 width/height/channels/data 一致" → "断言 width=2, height=2, channels=3, data == [0,0,0, 36,36,0, 72,72,85, 108,108,85]"，并列出 4 像素量化后预期值的逐级计算（r_level/g_level/b_level → 调色板值），参照测试 7 给出 (252,252,255) 量化预期的先例，显式声明不与原始 data 比较因量化改变颜色
2. **测试 2 修正**：明确完整数据流和比较双方。数据流补充 `@pure.decode_gif_pure` 步骤：orig_img = `@core.load_from_path(path, req_channels=Some(3))` → gif_bytes = `@pure.encode_gif_pure(orig_img)` → pure_img = `@pure.decode_gif_pure(gif_bytes)` + ffi_img = `@core.load_from_bytes(gif_bytes, req_channels=Some(3))`。断言改为 pure_img vs ffi_img 完全一致（width/height/channels/data），显式声明不与 orig_img 比较因 orig_img 未量化
选择理由：审查意见 2 项全部属实（已核实 `src/format/gif_encode.mbt:7-12` 量化逻辑，3-3-2 量化确会改变颜色，roundtrip 后 data 与原始不一致；测试 2 数据流缺 pure decode 步骤致比较双方歧义），修正采用审查推荐方案 b（给出量化预期 data，与测试 7 先例一致）和补充数据流步骤，仅精确化测试描述不涉实现逻辑变更，风险极低，修正后测试 5/2 比较双方明确且技术可行

---

## R22 PASSED v2.0 pure 包 GIF 编码器（纯 MoonBit，全目标，单帧） [ID: T11]
结果：在 `src/pure/` 新增 `gif_encode.mbt`（`encode_gif_pure`，含 `quantize_332` + `build_332_palette` + `lzw_compress` 辅助函数，移植自 `src/format/gif_encode.mbt:1-177`，仅替换 @core→@types 类型引用）+ `gif_encode_test.mbt`（8 纯逻辑测试，全目标），根包 `roundtrip_test.mbt` 新增 2 个 native-only 测试（pure roundtrip 稳定性 + pure encode vs FFI decode 对比）。pure 包由此具备 GIF 完整 roundtrip 能力（6 解码 + 3 编码）。
检查：`moon check` 全目标 0 errors 0 warnings，`moon test --target native` 636/636 通过（626→636，+8 pure 纯逻辑 + 2 根包 roundtrip），v1.0 API 冻结保持，现有测试不破坏。

## R22 NEW v2.0 后端选择层 `src/lib/` 包（pure 侧统一 API + 自动格式分派） [ID: T12]
任务：创建 `src/lib/` 全目标包（import @types + @pure），实现 pure 后端统一 API 层：`detect_format`（magic bytes 检测，参照 `src/core/image_detect.mbt:18-82`，覆盖 pure 包支持的 5 种格式 BMP/QOI/PNM/PSD/GIF，TGA 无 magic 不自动分派）、`load_from_bytes_auto`（根据检测结果分派到 @pure 对应解码器，Unknown raise LoadError）、`encode_qoi_auto`/`encode_pnm_auto`/`encode_ppm_auto`/`encode_pgm_auto`/`encode_gif_auto`（委托 @pure 已有编码器）。新增 `src/lib/lib_test.mbt` 10 个纯逻辑测试（全目标，detect_format 各格式 + load_from_bytes_auto 各格式 + 错误路径 + encode 委托验证）。根包 `src/roundtrip_test.mbt` 新增 2 个 native-only 对比测试（@lib.load_from_bytes_auto vs @core.load_from_bytes，BMP + QOI 格式，断言 width/height/channels/data 完全一致）。根包 `src/moon.pkg` 新增 `@lib` 的 `for "test"` 依赖。验证 `moon check` 全目标 0 errors 0 warnings，`moon test --target native` 636→648 通过。
选择理由：
- T11 已完成 GIF 编码器，pure 包当前 6 解码器 + 3 编码器（BMP/QOI/TGA/PNM/PSD/GIF 解码 + QOI/PNM/GIF 编码），格式覆盖已较完整，具备构建统一 API 层的基础
- ROADMAP.md v2.0 交付物 `src/lib.mbt` 后端选择层是 v2.0 的关键交付物，pure 侧统一 API 是后端选择层的第一步
- MoonBit 不支持目标条件依赖（`for "native"` 语法不存在，仅支持 `for "test"`/`for "wbtest"`，已查阅官方文档确认），无法在单包内条件 import @core（native-only）+ @pure（全目标）；故后端选择层分两步：本轮 pure 侧统一 API（@lib 全目标，仅依赖 @pure + @types），后续 native 侧统一 API（@core/reexport 已提供）+ 目标分派机制
- `@core.detect_format`（`src/core/image_detect.mbt:18-82`）已有 magic bytes 检测逻辑先例，移植到 @lib 仅需覆盖 pure 包支持的格式子集，技术风险极低
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，@lib 包仅依赖 @pure + @types，全目标可用，无需架构改动
- 风险可控：新增包不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中（无全目标警告问题）
- 为后续 native 侧统一 API + 真正的后端选择（根据目标分派 native/pure）奠定基础
上下文：
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types + @encoding/utf8），全目标可用
- T11 产出：pure 包 6 解码器 + 3 编码器，native 636 测试通过
- pure 包可用解码器：`decode_bmp_pure`/`decode_qoi_pure`/`decode_tga_pure`/`decode_pnm_pure`/`decode_psd_pure`/`decode_gif_pure`（签名 `pub fn decode_xxx_pure(data : Bytes) -> @types.Image raise @types.LoadError`）
- pure 包可用编码器：`encode_qoi_pure`/`encode_ppm_pure`/`encode_pgm_pure`/`encode_pnm_pure`/`encode_gif_pure`
- `@core.detect_format`（`src/core/image_detect.mbt:18-82`）：magic bytes 检测，支持 PNG/JPEG/BMP/GIF/PSD/HDR/PNM/QOI，TGA 无 magic 标记 Unknown
- magic bytes 对照：BMP "BM"(0x42,0x4D)、QOI "qoif"(0x71,0x6F,0x69,0x66)、PNM "P5"/"P6"(0x50,0x35/0x36)、PSD "8BPS"(0x38,0x42,0x50,0x53)、GIF "GIF87a"/"GIF89a"(0x47,0x49,0x46,...)
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`，第 11 行已 import format
- pure 包 `src/pure/moon.pkg`：import types + @encoding/utf8，无 `supported_targets`，全目标
- MoonBit 条件编译：文件级 `options(targets: {"file.mbt": ["native"]})` 支持，包级 `supported_targets` 支持，但 import 仅支持 `for "test"`/`for "wbtest"`，不支持目标条件依赖
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

---

## R23 RETRY v2.0 后端选择层 `src/lib/` 包（pure 侧统一 API + 自动格式分派） [ID: T12]
原因：计划审查 v12 r1 REJECTED，7 项问题
- [严重] 测试 2 "lib vs core: QOI auto decode" 用 `@core.load_from_bytes` 作为 QOI 解码基准，技术不可行。`@core.load_from_bytes` 是纯 FFI 调用 `stb_image_mbt_load_from_memory`，stb_image C 库不原生支持 QOI（T5 R9 RETRY 已确认），解码 QOI 字节流会返回 NULL → raise `LoadError::DecodeFailed`，测试运行时抛异常，违反"不破坏现有测试"约束，预期产出"636→648"无法达成。现有 QOI 测试（`roundtrip_test.mbt:90-124`）全部使用 `@format.decode_qoi`，印证此为项目 QOI 解码的正确调用方式。
- [一般] `src/lib/moon.pkg` import 列表仅列 @types + @pure，未列 `moonbitlang/core/debug`，但 `ImageFormat` 枚举 `derive(Eq, @debug.Debug)` 需要此依赖。Doer 按产出规格生成 moon.pkg 会遗漏此 import，导致 `moon check` 报 `unbound package @debug` 编译失败。参照 `src/types/moon.pkg:2` 同样因 `derive(Eq, @debug.Debug)` import `moonbitlang/core/debug`。
- [一般] `detect_format` 检测 PNM 范围为 P1-P6（`data[1]>=0x31 && data[1]<=0x36`），但 `load_from_bytes_auto` 对 `Pnm` 分派到 `@pure.decode_pnm_pure`，而 `decode_pnm_pure` 仅支持 P5/P6（`src/pure/pnm_decode.mbt:71` 拒绝 P1-P4）。`detect_format` 与 `load_from_bytes_auto` 能力不匹配：用户对 P1-P4 字节流调用 `detect_format` 返回 `Pnm`，再调用 `load_from_bytes_auto` 期望成功解码，实际 raise `LoadError::DecodeFailed`。此限制未在计划任何位置声明，行为不一致会误导用户。
- [一般] `load_from_bytes_auto` 分派测试覆盖不足：10 个纯逻辑测试中仅测试 7 "BMP 分派"覆盖 1 种格式，缺 QOI/PNM/PSD/GIF 分派测试。5 种格式仅测 1 种（覆盖率 20%）。若 Doer 误将 QOI 分派到 `decode_bmp_pure`、PNM 分派到 `decode_qoi_pure` 等，纯逻辑测试不会发现，错误流入后续轮次。
- [一般] 编码器委托验证不足：5 个编码器仅测试 `encode_qoi_auto` 和 `encode_gif_auto`（测试 9-10），缺 `encode_pnm_auto`/`encode_ppm_auto`/`encode_pgm_auto` 委托验证。5 个编码器仅测 2 个（覆盖率 40%）。PNM 3 个编码器逻辑相近，委托目标易混淆，未测试则正确性无保证。
- [轻微] 测试 3 "detect_format: PNM" 仅构造 "P6" 开头字节流，未覆盖 P1-P4 边界。当前测试无法发现 `detect_format` 检测范围错误。
- [轻微] 测试 5 "detect_format: GIF" 仅构造 "GIF89a" 开头字节流，未覆盖 "GIF87a"。仅测 GIF89a 无法发现 Doer 误增 `data[3]==0x38 && data[4]==0x39 && data[5]==0x61`（硬编码 "89a"）的错误。
修正方向（已逐一修正，覆写 task_v12.md）：
1. **测试 2 QOI 基准修正**：`@core.load_from_bytes` → `@format.decode_qoi`（`src/format/qoi.mbt:13`，纯 MoonBit 基准）。完整数据流：`orig_img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` → `qoi_bytes = @format.encode_qoi(orig_img)` → `lib_img = @lib.load_from_bytes_auto(qoi_bytes)` + `format_img = @format.decode_qoi(qoi_bytes)` → 断言 `lib_img` vs `format_img` width/height/channels/data 完全一致。测试名改为 "lib vs format: QOI auto decode"（如实反映 format 包纯 MoonBit 基准，非 FFI 基准）。参照 T5 产出（plan.md line 171）及 `roundtrip_test.mbt:116-124` 现有 "roundtrip: QOI pure vs format" 测试模式。
2. **moon.pkg import 列表补充 `moonbitlang/core/debug`**：`src/lib/moon.pkg` import 列表新增 `"moonbitlang/core/debug"`，与 `src/types/moon.pkg:2` 先例一致。修正后 moon.pkg import 三项：@types + @pure + `moonbitlang/core/debug`。
3. **PNM 检测范围收窄为仅 P5/P6**（采用审查推荐方案 (a)）：`detect_format` PNM 检测从 `data[1]>=0x31 && data[1]<=0x36`（P1-P6）收窄为 `data[1]>=0x35 && data[1]<=0x36`（仅 P5/P6），与 `decode_pnm_pure` 能力匹配，P1-P4 检测为 `Unknown`，避免 `detect_format` 返回 `Pnm` 但 `load_from_bytes_auto` raise 错误的行为不一致。
4. **`load_from_bytes_auto` 分派测试补充**：10 个测试基础上新增 4 个分派测试（QOI/PNM/PSD/GIF 各 1 个，测试 9-12），构造各格式最小有效字节流，`load_from_bytes_auto` 解码后断言 width/height/channels 符合预期，覆盖全部 5 种支持格式（覆盖率 100%）。
5. **编码器委托验证补充**：新增 2 个测试验证 `encode_ppm_auto`/`encode_pgm_auto` 委托正确性（测试 15-16，构造 1x1 RGB Image，编码后断言 magic bytes "P6"/"P5" 与对应 `@pure.encode_xxx_pure` 结果一致）。`encode_pnm_auto` 通过 ppm/pgm 间接验证不单独测试（pnm_auto 对 RGB 委托 ppm、对灰度委托 pgm）。
6. **测试 3 PNM 边界补充**：测试 3 补充 P5/P6 检测为 `Pnm` + P4 检测为 `Unknown` 边界用例，验证检测范围收窄后 P1-P4 不再检测为 `Pnm`。
7. **测试 5 GIF87a 补充**：测试 5 补充 "GIF87a" 开头字节流用例，验证 `detect_format` 返回 `ImageFormat::Gif`，覆盖 GIF87a/GIF89a 两种版本，验证未硬编码 "89a"。
选择理由：审查意见 7 项全部属实（已核实 `src/format/qoi.mbt:13` `@format.decode_qoi` 存在、`src/pure/pnm_decode.mbt:71` 仅支持 P5/P6、`src/types/moon.pkg:2` import debug、`roundtrip_test.mbt:116-132` 现有 QOI pure vs format 测试模式印证推荐方案），修正采用审查推荐方案（测试 2 改用 @format.decode_qoi、PNM 检测收窄方案 (a)、补充分派/委托测试覆盖），仅精确化测试描述与补充测试覆盖不涉实现逻辑变更，风险极低，修正后计划 API 引用正确、moon.pkg import 完整、检测范围与能力匹配、测试覆盖完整（5 格式分派 100% + 4 编码器委托验证）、边界覆盖（P4/P5/P6 + GIF87a/GIF89a），可行性不再留待现场。测试数从 10 调整到 17，预期 native 测试数从 636→648 调整为 636→655。
