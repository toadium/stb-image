# 任务指令（v5）

## 动作
NEW

## 任务描述
在 `src/pure/{codec,pixel,color,process,util}/` 新增纯 MoonBit QOI 解码器，扩展 pure 包格式覆盖（当前仅 BMP），推进 v2.0 多目标支持的实质功能。预期产出：

1. **`src/pure/{codec,pixel,color,process,util}/qoi_decode.mbt`** — 实现 `pub fn decode_qoi_pure(data : Bytes) -> @types.Image raise @types.LoadError`
   - 支持 QOI 格式 RGB（channels=3）和 RGBA（channels=4）解码
   - 参考逻辑：`src/format/qoi.mbt` 的 `decode_qoi`（第 13-116 行），该实现已是纯 MoonBit（无 FFI 调用），仅将 `@core.Image` → `@types.Image`、`@core.LoadError` → `@types.LoadError`
   - 支持全部 QOI 标签：QOI_OP_INDEX(0x00-0x3F)、QOI_OP_DIFF(0x40-0x7F)、QOI_OP_LUMA(0x80-0xBF)、QOI_OP_RUN(0xC0-0xFF)、QOI_OP_RGB(0xFE)、QOI_OP_RGBA(0xFF)
   - QOI 哈希函数：`(r*3 + g*5 + b*7 + a*11) % 64`
   - 验证 magic "qoif"（0x71 0x6F 0x69 0x66）、宽高（大端）、channels、8 字节结束标记

2. **`src/pure/{codec,pixel,color,process,util}/qoi_decode_test.mbt`** — 纯逻辑测试（全目标，不依赖 @core）
   - 手构造 QOI 字节流验证解码正确性（参考 QOI 规范 https://qoiformat.org/qoi-specification.pdf）
   - 测试用例（共 8 个，覆盖全部 6 种 QOI 标签 + 2 错误路径）：
     - 1x1 RGB 像素（QOI_OP_RGB 标签）
     - 1x1 RGBA 像素（QOI_OP_RGBA 标签）
     - 2x2 RGB 像素（含 QOI_OP_DIFF 差分编码）
     - 2x2 RGB 像素（含 QOI_OP_LUMA 双字节差分编码，覆盖 dg/dr_dg/db_dg 二级差分分支，参考 `src/format/qoi.mbt:73-81`）
     - 2x2 RGB 像素（含 QOI_OP_RUN 游程编码）
     - 2x2 RGBA 像素（含 QOI_OP_INDEX 索引编码）
     - 错误路径：magic 不匹配
     - 错误路径：数据过短
   - 签名断言：`decode_qoi_pure` 返回 `@types.Image`，字段 width/height/channels/data 正确

3. **`src/roundtrip_test.mbt`** — 新增 1 个 pure-format QOI 交叉验证对比测试（native-only）
   - 测试名：`roundtrip: QOI pure vs format`
   - 模式：`@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` → `@format.encode_qoi(img)` 生成 QOI 字节流 → `@codec.decode_qoi_pure(qoi_bytes)` pure 包纯 MoonBit 解码 → `@format.decode_qoi(qoi_bytes)` format 包纯 MoonBit 基准解码（交叉验证） → 断言 width/height/channels/data 完全一致
   - 覆盖 RGB 路径（channels=3）
   - **说明**：`@format.encode_qoi`/`@format.decode_qoi` 均为纯 MoonBit 实现（`src/format/qoi.mbt:13,121`，无 FFI/C stub），stb_image C 库不原生支持 QOI（QOI 为现代格式），故此对比为"pure 包独立实现 vs format 包独立实现"的交叉验证，非 FFI 基准对照。两实现虽同源移植，但独立构造可发现移植错误。根包 `src/moon.pkg` 已 import format（第 11 行），无需新增依赖。

4. **构建验证**
   - `moon check`（全目标）0 errors 0 warnings
   - `moon test --target native` 553→562 通过（新增 1 个根包对比测试 + 8 个 pure 包纯逻辑测试；pure 包全目标化，native 为其目标之一，必运行其测试，与 T3 先例一致——T3 native 552 已含 pure 包 6 测试）
   - v1.0 API 冻结保持，现有 553 测试不破坏

## 选择理由
- T4 已完成 BMP 对比验证收尾，pure 包当前仅 BMP 解码器，格式覆盖不足，需扩展以推进 v2.0 多目标支持的实质功能
- QOI 格式简单（无压缩，索引+差分编码），`src/format/qoi.mbt` 已有纯 MoonBit 解码实现（116 行），移植到 pure 包仅需替换类型引用，技术风险极低
- QOI 是现代格式（qoiformat.org），实用价值高，且项目已有 QOI 纯 MoonBit 实现（`src/format/qoi.mbt`，非 FFI）可作交叉验证基准
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，QOI 解码器仅依赖 @types，全目标可用，无需架构改动
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 和 pure 包格式进一步扩展（PNG/JPEG）奠定基础

## 任务上下文
摘录与当前任务直接相关的需求/约束：
- **ROADMAP.md v2.0 交付物**：`src/native/` + `src/pure/{codec,pixel,color,process,util}/` + `src/lib.mbt`（后端选择层），推荐路径 A（双后端：native 保持 C FFI，wasm/js 用纯 MoonBit fallback）
- **执行约束**：
  1. 保持 v1.0 API 冻结原则：新增功能只添加，不修改已有签名
  2. 遵循五子包架构：core/process/format/meta/util + 新增 types/pure
  3. FFI 优先：stb 库本身支持的功能优先通过 FFI 绑定
  4. 纯 MoonBit 补齐：stb 不支持的功能用纯 MoonBit 实现，放在单独包中
  5. 测试先行：每个新功能必须有测试 + ASan 验证（FFI 部分）
  6. 不破坏现有测试：所有现有 553 测试 + 29 基准测试必须继续通过
  7. 构建验证：每轮完成后必须执行 `moon check --target native` 和 `moon test --target native` 验证

## 已有产出上下文
工作目录中已有的相关产出概述：
- **T1（R3 PASSED）**：`src/pure/{codec,pixel,color,process,util}/` 包创建，BMP 解码器 `decode_bmp_pure`（24/32-bit 无压缩），8 测试
- **T2（R5 PASSED）**：`src/types/` 全目标包，6 类型定义（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError），core 包通过 `pub type X = @types.X` 别名 re-export
- **T3（R6 PASSED）**：`src/pure/{codec,pixel,color,process,util}/moon.pkg` 移除 `supported_targets = "native"`，pure 包全目标化（仅 import types），6 纯逻辑测试
- **T4（R8 PASSED）**：`src/roundtrip_test.mbt` 新增 24-bit RGB pure-FFI BMP 对比测试，`src/moon.pkg` 以 `for "test"` 声明 `@pure` 依赖
- **当前 pure 包结构**：
  - `src/pure/{codec,pixel,color,process,util}/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
  - `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt`：`pub fn decode_bmp_pure(data : Bytes) -> @types.Image raise @types.LoadError`
  - `src/pure/{codec,pixel,color,process,util}/bmp_decode_test.mbt`：6 纯逻辑测试
- **QOI 参考实现**（均纯 MoonBit，无 FFI/C stub）：
  - `src/format/qoi.mbt:13-116`：`pub fn decode_qoi(data : Bytes) -> @core.Image raise @core.LoadError`
  - `src/format/qoi.mbt:121-231`：`pub fn encode_qoi(img : @core.Image) -> Bytes raise @core.LoadError`
  - `src/format/qoi.mbt:7-9`：`fn qoi_hash(r, g, b, a) -> Int` = `(r*3 + g*5 + b*7 + a*11) % 64`
  - `src/format/qoi.mbt:73-81`：QOI_OP_LUMA 解码分支（双字节差分：dg=(tag&0x3F)-32, dr_dg=(b2>>4)-8, db_dg=(b2&0x0F)-8）
- **根包配置**：
  - `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，主 import 列表已含 `@format`（第 11 行），`options(targets: {"roundtrip_test.mbt": ["native"]})`
  - `src/roundtrip_test.mbt:95,96,108,109`：现有 QOI 测试使用 `@format.encode_qoi`/`@format.decode_qoi`（非 `@core`），可参考此调用方式
  - `src/reexport.mbt:824,842`：`decode_qoi`/`encode_qoi` 以 `pub let` re-export 到根包级别（无前缀调用），非 `@core` 命名空间
- **类型兼容**：`@core.Image` 即 `@types.Image` 别名（`src/core/image_types_reexport.mbt`），字段 width/height/channels/data 均 derive(Eq)，直接比较可行

## 审查修订说明（v5 r1 REJECTED 修正）
本任务指令已按审查 v5 r1 的 4 项问题修正：
1. **[严重] API 引用错误**：`@core.encode_qoi`/`@core.decode_qoi` → `@format.encode_qoi`/`@format.decode_qoi`（core 包无此二函数，`src/format/qoi.mbt:13,121` 属 @format 包，根包 reexport.mbt:824,842 以 `pub let` re-export 到根包级别非 @core 命名空间，roundtrip_test.mbt:95,96 现有用法印证）
2. **[严重] "FFI 基准解码"描述失实**：更正为"format 包纯 MoonBit 基准解码（交叉验证）"，如实说明 stb C 库不原生支持 QOI、对比双方均为纯 MoonBit 独立实现、对比价值为交叉校验而非 FFI 基准对照
3. **[一般] 预期 native 测试数遗漏 pure 包测试**：明确 pure 包新增 8 测试（含 LUMA），native 预期 553 + 1 + 8 = 562，不再使用"另计"模糊表述
4. **[一般] QOI_OP_LUMA 测试缺失**：测试用例新增 1 个覆盖 QOI_OP_LUMA（2x2 RGB 含 LUMA 编码），覆盖全部 6 种 QOI 标签
