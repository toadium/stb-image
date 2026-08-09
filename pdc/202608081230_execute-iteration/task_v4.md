# 任务指令（v4）

## 动作
RETRY

## 任务描述
将 T3 方案 B 移除的 pure-FFI BMP 对比验证测试移至根包 `src/roundtrip_test.mbt`（已 native-only），恢复纯 MoonBit 解码器与 FFI 解码器的一致性验证。**采用方案 A：仅保留 24-bit RGB 对比测试**（审查 v4 r1 推荐）。

### 具体步骤
1. 根包 `src/moon.pkg` 的 import 列表添加 `"MoonBit-Toadium/stb-image/src/pure"`（native 包依赖全目标包合法）
2. 在 `src/roundtrip_test.mbt` 新增 **1 个** 24-bit RGB 对比测试：
   - 用 `@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` 加载 24-bit RGB 图像
   - 用 `@core.write_bmp_to_bytes(img)` 生成 BMP 字节流（FFI 写出 BITMAPINFOHEADER 40 字节 + BI_RGB + 24bpp，`decode_bmp_pure` 可解码）
   - 用 `@pure.decode_bmp_pure(bmp_bytes)` 解码（纯 MoonBit）
   - 用 `@core.load_from_bytes(bmp_bytes, req_channels=Some(3))` 解码（FFI 基准）
   - 断言两者 width / height / channels / data 完全一致
3. **不新增 32-bit RGBA 对比测试**：`@core.write_bmp_to_bytes` 对 4 通道写出 BITMAPV4HEADER（108 字节）+ BI_BITFIELDS（compression=3），超出 `decode_bmp_pure` 能力范围（仅 BITMAPINFOHEADER 40 字节 + BI_RGB），32-bit 对比验证留待后续轮次扩展 pure 解码器后补充

### 预期产出
- `src/moon.pkg`：import 列表新增 `src/pure`
- `src/roundtrip_test.mbt`：新增 1 个 24-bit RGB pure-FFI 对比测试
- `moon check --target native`：0 errors 0 warnings
- `moon test --target native`：553/553 通过（552→553，新增 1 测试）
- v1.0 API 冻结保持，现有测试不破坏

## 选择理由
- T3 方案 B 移除 2 个对比测试，do_v3.md 明确规划"对比验证留待后续轮次移至根包 roundtrip_test.mbt"，本轮即执行此规划，属 T3 收尾
- 审查 v4 r1 REJECTED 指出原计划 32-bit RGBA 测试技术不可行（FFI 写出 BITMAPV4HEADER+BI_BITFIELDS，pure 解码器仅支持 BITMAPINFOHEADER+BI_RGB），推荐方案 A 仅保留 24-bit RGB 对比测试
- 已核实源码兼容性：`stb_image_write.h:494-500` 24-bit 路径写出 BITMAPINFOHEADER(40)+BI_RGB(0)+24bpp，`bmp_decode.mbt:21,35` pure 解码器接受 dib_size==40 && compression==0 && bpp∈{24,32}，24-bit 路径兼容确认
- 根包 `roundtrip_test.mbt` 已 native-only（`options(targets: {"roundtrip_test.mbt": ["native"]})`），可自由依赖 @core + @pure，无全目标警告问题
- 恢复 24-bit RGB 对比验证能力（pure vs FFI）是质量保证关键：纯 MoonBit 解码器正确性需有 FFI 基准对照
- 风险低：仅新增 1 个测试不改现有代码；native 包 import 全目标 pure 包语法合法；测试模式已有先例（roundtrip_test.mbt 现有 `roundtrip: BMP RGB` 用 `@core.write_bmp_to_bytes`）
- 32-bit 对比验证留待后续轮次扩展 pure 解码器支持 BITMAPV4HEADER 后补充

## 任务上下文
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证（`moon check --target native` + `moon test --target native`）
- T3 产出：pure 包全目标化（仅 import types），6 纯逻辑测试，对比测试已移除，native 552 测试通过
- 审查 v4 r1 修正要求：方案 A（推荐）仅保留 24-bit RGB，预期 552→553；或方案 B 32-bit 改用手构造字节（需额外验证 stb_image reader 支持 32-bit BI_RGB，复杂度高）。本轮采用方案 A
- FFI 生成 BMP 格式（`src/core/stb_image_write.h:492-510`）：comp!=4 → BITMAPINFOHEADER(40)+BI_RGB(0)+24bpp；comp==4 → BITMAPV4HEADER(108)+BI_BITFIELDS(3)+32bpp
- pure 解码器能力（`src/pure/bmp_decode.mbt:21,35`）：仅 dib_size==40 && compression==0 && bpp∈{24,32}
- 根包 `src/moon.pkg`：`supported_targets = "native"`，`options(targets: {"roundtrip_test.mbt": ["native"]})`，当前 import 列表含 core/process/format/meta/util，不含 pure
- roundtrip_test.mbt 现有 `roundtrip: BMP RGB` 测试模式：`@core.load_from_path` → `@core.write_bmp_to_bytes` → `@core.load_from_bytes` → 断言 data 一致
- pure 包 `decode_bmp_pure` 签名：`pub fn decode_bmp_pure(data : Bytes) -> @types.Image raise @types.LoadError`
- core 包 re-export types：`@core.Image` 即 `@types.Image`，字段级比较直接可行

## 已有产出上下文
- T1（R3 PASSED）：`src/pure/` 包，纯 MoonBit BMP 解码器（24/32-bit 无压缩），8 测试
- T2（R5 PASSED）：`src/types/` 全目标包，core 包 re-export types，pure 包主代码改用 @types
- T3（R6 PASSED）：pure 包全目标化（移除 `supported_targets`，移除 2 个 @core 对比测试），6 纯逻辑测试，native 552 测试通过，wasm/js pure 包 6/6 通过
- 当前 `src/moon.pkg` import 不含 pure，`src/roundtrip_test.mbt` 无 pure-FFI 对比测试

## RETRY 说明
上一轮 T4 计划审查 v4 r1 REJECTED，2 项严重问题：
1. 测试 2（32-bit RGBA）技术不可行：`@core.write_bmp_to_bytes` 对 4 通道写出 BITMAPV4HEADER（108 字节）+ BI_BITFIELDS（compression=3），`decode_bmp_pure` 仅支持 BITMAPINFOHEADER（40 字节）+ BI_RGB（compression=0），会拒绝解码，测试 2 运行时抛异常导致 `moon test` 失败
2. 计划未论证 FFI 生成 BMP 与 pure 解码器能力范围的匹配性

修正方向（方案 A）：仅保留 24-bit RGB 对比测试（FFI 24-bit 路径写出 BITMAPINFOHEADER+BI_RGB 与 pure 解码器兼容），放弃 32-bit RGBA 对比测试（留待后续扩展 pure 解码器支持 BITMAPV4HEADER），预期测试数 552→553。已核实 `stb_image_write.h:492-510` 与 `bmp_decode.mbt:21,35` 源码确认兼容性。
