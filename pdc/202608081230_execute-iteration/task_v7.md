# 任务指令（v7）

## 动作
NEW

## 任务描述
在 `src/pure/` 新增纯 MoonBit PNM 解码器，扩展 pure 包格式覆盖（BMP+QOI+TGA → BMP+QOI+TGA+PNM），推进 v2.0 多目标支持。

### 实现要求
1. **解码器文件** `src/pure/pnm_decode.mbt`：
   - 公开函数签名：`pub fn decode_pnm_pure(data : Bytes) -> @types.Image raise @types.LoadError`
   - 支持 P5（PGM 二进制灰度，channels=1）和 P6（PPM 二进制 RGB，channels=3）
   - 支持 8-bit（maxval < 256），不支持 16-bit（maxval ≥ 256 → raise LoadError::DecodeFailed）
   - Header 解析：magic(2 字节) + width(ASCII) + height(ASCII) + maxval(ASCII)，以 whitespace 分隔
   - 处理注释行（`#` 开头至行尾，可出现在 magic 之后 header 任意位置）
   - 处理任意 whitespace（space 0x20 / tab 0x09 / LF 0x0A / CR 0x0D）作为 header 字段分隔
   - maxval 后恰好 1 个 whitespace 后接像素数据
   - P5 像素：width*height 字节灰度；P6 像素：width*height*3 字节 RGB
   - 输出 `@types.Image`（width/height/channels/data）
   - 错误路径（均 `raise @types.LoadError::DecodeFailed`）：
     - 数据过短（header 不完整或像素数据不足）
     - 不支持的 magic（P1-P4 ASCII 格式、P7 PAM、其他无效 magic）
     - 不支持的 maxval（maxval ≥ 256，16-bit PNM）

2. **纯逻辑测试文件** `src/pure/pnm_decode_test.mbt`（全目标，不依赖 @core）：
   - 手构造 PNM 字节流验证解码正确性
   - 测试覆盖建议 7-9 个，含：
     - P6 基本 RGB 解码（2x2，验证 width/height/channels/data）
     - P5 基本灰度解码（2x2，验证 width/height/channels/data）
     - 注释行处理（header 含 `# comment` 行）
     - 不同 whitespace 分隔（space vs tab vs LF 混合）
     - 1x1 最小图像
     - 错误路径 3 个：数据过短、不支持的 magic（如 P3）、不支持的 maxval（maxval=65535）
   - 复用同包已有辅助函数（如 `qoi_decode_test.mbt` 的 `to_bytes`）

3. **FFI 基准对比测试**（根包 `src/roundtrip_test.mbt`，native-only）：
   - 新增 2 个测试：
     - `roundtrip: PPM RGB pure vs FFI`：`@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` → `@format.encode_ppm(img)` → `@pure.decode_pnm_pure(encoded)` vs `@core.load_from_bytes(encoded, req_channels=Some(3))` → 断言 width/height/channels/data 完全一致
     - `roundtrip: PGM grayscale pure vs FFI`：构造 2x2 灰度 Image → `@format.encode_pgm(img)` → `@pure.decode_pnm_pure(encoded)` vs `@core.load_from_bytes(encoded, req_channels=Some(1))` → 断言 width/height/channels/data 完全一致
   - 使用 `@format.encode_ppm`/`encode_pgm`（非 `@core.`，core 包无此二函数，见 `src/format/pnm_encode.mbt:6,37`，根包已 import format）

### 预期产出
- `src/pure/pnm_decode.mbt` 新建
- `src/pure/pnm_decode_test.mbt` 新建
- `src/roundtrip_test.mbt` 修改（新增 2 个对比测试）
- `moon check`（全目标）0 errors 0 warnings
- `moon test --target native` 全量通过，预期 572→581（+7 pure 纯逻辑 + 2 根包对比，建议范围 580-582）

## 选择理由
- T6 已完成 TGA 解码器，pure 包当前 BMP+QOI+TGA 三种格式，需继续扩展格式覆盖以推进 v2.0 多目标支持实质功能
- PNM（P5/P6 二进制）格式最简单（无压缩，header + 原始像素），实现风险极低
- stb_image C 库原生支持 PNM 解码，对比验证为真正的 FFI 基准，价值高
- `@format.encode_ppm`/`encode_pgm` 已有纯 MoonBit 编码，可生成对比测试数据，基础设施完备
- PNM 是项目已有格式（v1.5 PNM 编码），补齐 pure 包解码使格式覆盖更完整
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，PNM 解码器仅依赖 @types，全目标可用
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中

## 任务上下文
- 执行约束：保持 v1.0 API 冻结、遵循五子包架构、不破坏现有测试、构建验证
- pure 包 `src/pure/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，第 11 行已 import format，`options(targets: {"roundtrip_test.mbt": ["native"]})`
- PNM 二进制格式规格：
  - Header：magic(2 字节 "P5"/"P6") + whitespace + width(ASCII) + whitespace + height(ASCII) + whitespace + maxval(ASCII) + 单个 whitespace + 像素
  - 注释行：`#` 开头至行尾，可出现在 magic 后 header 任意位置
  - maxval < 256：每通道 1 字节；maxval ≥ 256：每通道 2 字节 big-endian（本轮不支持）
- `@format.encode_ppm` 输出 "P6\n{w} {h}\n255\n" + RGB 像素（`src/format/pnm_encode.mbt:6`）
- `@format.encode_pgm` 输出 "P5\n{w} {h}\n255\n" + 灰度像素（`src/format/pnm_encode.mbt:37`）
- `@core.load_from_bytes` 支持 PNM 解码（`pnm_encode_test.mbt:23,76` 印证）
- pure 包解码器惯例：`pub fn decode_xxx_pure(data : Bytes) -> @types.Image raise @types.LoadError`（见 BMP/QOI/TGA）

## 已有产出上下文
- T1（R3 PASSED）：pure 包 BMP 解码器 `decode_bmp_pure`，24/32-bit 无压缩
- T2（R5 PASSED）：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError），core 包 re-export types
- T3（R6 PASSED）：pure 包全目标化（仅 import types），6 纯逻辑测试
- T4（R8 PASSED）：根包 roundtrip_test.mbt 有 pure-FFI BMP 对比测试，`src/moon.pkg` 已 `for "test"` 声明 `@pure` 依赖
- T5（R10 PASSED）：pure 包 QOI 解码器 `decode_qoi_pure` + 8 纯逻辑测试，根包 QOI 对比测试
- T6（R12 PASSED）：pure 包 TGA 解码器 `decode_tga_pure` + 9 纯逻辑测试，根包 TGA 对比测试，native 572 测试通过
- pure 包现有文件：`bmp_decode.mbt`/`bmp_decode_test.mbt`/`qoi_decode.mbt`/`qoi_decode_test.mbt`/`tga_decode.mbt`/`tga_decode_test.mbt`/`moon.pkg`
