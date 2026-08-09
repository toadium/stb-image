# 任务指令（v8）

## 动作
NEW

## 任务描述
在 `src/pure/{codec,pixel,color,process,util}/` 新增纯 MoonBit PSD 解码器，扩展 pure 包格式覆盖（BMP+QOI+TGA+PNM → BMP+QOI+TGA+PNM+PSD），推进 v2.0 多目标支持。

### 1. 解码器实现（`src/pure/{codec,pixel,color,process,util}/psd_decode.mbt`）
- **公开签名**：`pub fn decode_psd_pure(data : Bytes) -> @types.Image raise @types.LoadError`，遵循 pure 包解码器惯例（与 BMP/QOI/TGA/PNM 一致）
- **支持范围**：8-bit、RGB（channelCount=3）/RGBA（channelCount=4）、无压缩（compression=0）
- **PSD 文件格式（大端序）**：
  - Header（26 字节）：
    - signature(4 字节)："8BPS"（0x38 0x42 0x50 0x53），不匹配 → `DecodeFailed`
    - version(2 字节 BE)：必须为 1，否则 → `DecodeFailed`
    - reserved(6 字节)：跳过
    - channelCount(2 字节 BE)：通道数，仅支持 3（RGB）和 4（RGBA），其他 → `DecodeFailed`
    - h(4 字节 BE)：高度
    - w(4 字节 BE)：宽度
    - bitdepth(2 字节 BE)：仅支持 8，16 → `DecodeFailed`
    - colorMode(2 字节 BE)：仅支持 3（RGB），其他 → `DecodeFailed`
  - Color mode data：length(4 字节 BE) + 跳过 length 字节
  - Image resources：length(4 字节 BE) + 跳过 length 字节
  - Layer and mask data：length(4 字节 BE) + 跳过 length 字节
  - Image data：
    - compression(2 字节 BE)：仅支持 0（无压缩），1（RLE）→ `DecodeFailed`
    - 像素数据：按通道排列，每通道 w*h 字节，通道顺序 R(0)/G(1)/B(2)/A(3)
- **像素交错**：将按通道排列的数据（RRRGGGBBB）交错为 Image.data 格式（RGBRGBRGB）：
  - `image.data[i * channelCount + c] = raw_channel_data[c * w * h + i]`
  - 其中 `c` 是通道索引（0..channelCount-1），`i` 是像素索引（0..w*h-1）
- **返回**：`@types.Image::{width: w, height: h, channels: channelCount, data: interleaved_data}`
- **错误路径**（均 `raise @types.LoadError::DecodeFailed`）：
  1. 数据过短（无法读取完整 header / 各段 length / 像素数据）
  2. signature 错误（非 "8BPS"）
  3. version 错误（非 1）
  4. 不支持的 channelCount（< 3 或 > 4）
  5. 不支持的 bitdepth（非 8，如 16）
  6. 不支持的 colorMode（非 3，如 1 Grayscale）
  7. 不支持的 compression（非 0，如 1 RLE）
  8. 尺寸无效（w=0 或 h=0）
  9. 像素数据不足（剩余字节 < channelCount * w * h）

### 2. 纯逻辑测试（`src/pure/{codec,pixel,color,process,util}/psd_decode_test.mbt`）
- 全目标可用，不依赖 @core（仅依赖 @types 和 @pure）
- 复用同包已有测试的辅助函数（如 `to_bytes`，参考 `pnm_decode_test.mbt`/`qoi_decode_test.mbt`）
- 新增 PSD 字节流构造辅助函数（大端序写入：`push_be16`/`push_be32`）
- **13 个测试用例（4 正例 + 9 错误路径）**：
  1. `2x2 RGB basic`：构造 2x2 3 通道 PSD（4 像素 R/G/B 值各不同），验证 width=2/height=2/channels=3/data 逐字节正确
  2. `2x2 RGBA basic`：构造 2x2 4 通道 PSD（含 alpha），验证 width=2/height=2/channels=4/data 逐字节正确
  3. `channel interleave verify`：构造 2x1 3 通道 PSD（R=[10,20], G=[30,40], B=[50,60]），验证交错后 data=[10,30,50,20,40,60]（确保交错逻辑正确，非简单拷贝）
  4. `1x1 minimal image`：构造 1x1 3 通道 PSD，验证最小尺寸边界正确
  5. `bad signature raises`：signature 改为 "XXXX"，验证报错
  6. `too short raises`：仅 4 字节 "8BPS"，验证数据过短报错
  7. `bad version raises`：version=2，验证报错
  8. `unsupported channelCount raises`：channelCount=1（灰度），验证报错
  9. `unsupported bitdepth raises`：bitdepth=16，验证报错
  10. `unsupported colorMode raises`：colorMode=1（Grayscale），验证报错
  11. `unsupported compression raises`：compression=1（RLE），验证报错
  12. `invalid dimensions raises`：w=0，验证报错
  13. `pixel data insufficient raises`：像素数据截断（剩余字节 < channelCount * w * h），验证报错

### 3. FFI 基准对比测试（`src/roundtrip_test.mbt`，native-only）
- 新增 2 个 native-only 测试，手构造 PSD 字节流，用 `@core.load_from_bytes` 作为 FFI 基准：
  1. `roundtrip: PSD RGB pure vs FFI`：手构造 2x2 3 通道 RGB PSD（像素值各不同）→ `@codec.decode_psd_pure`（返回 3 通道）vs `@core.load_from_bytes(psd_bytes, req_channels=Some(3))`（强制 3 通道匹配 pure 输出）→ 断言 width/height/channels/data 完全一致
  2. `roundtrip: PSD RGBA pure vs FFI`：手构造 2x2 4 通道 RGBA PSD（alpha 全为 255，避免 stb_image white matte removal 修改 RGB）→ `@codec.decode_psd_pure`（返回 4 通道）vs `@core.load_from_bytes(psd_bytes)`（默认返回 4 通道）→ 断言 width/height/channels/data 完全一致
- **关键**：stb_image PSD 解码总是内部输出 4 通道 RGBA（`stb_image.h:6249` 循环 `channel < 4`），channelCount >= 4 时做 white matte removal（alpha != 0 && alpha != 255 时修改 RGB，`stb_image.h:6282-6297`）。对比测试 1 用 req_channels=Some(3) 让 @core 返回 3 通道匹配 pure；对比测试 2 alpha=255 避免 white matte removal，pure 不实现 white matte removal

### 4. 构建验证
- `moon check --target native`：0 errors 0 warnings
- `moon check --target wasm`：0 errors 0 warnings（pure 包全目标）
- `moon check --target js`：0 errors 0 warnings（pure 包全目标）
- `moon test --target native`：全量通过，预期 582→597（+13 pure 纯逻辑 + 2 根包对比）

## 选择理由
- T7 已完成 PNM 解码器，pure 包当前 BMP+QOI+TGA+PNM 四种格式，需继续扩展格式覆盖以推进 v2.0 多目标支持实质功能
- PSD 是 image 独家格式（ROADMAP.md "PSD/HDR/PNM 独家格式"），补齐 pure 包 PSD 解码使独家格式覆盖更完整，实用价值高
- stb_image C 库原生支持 PSD 解码（`stb_image.h:6126 stbi__psd_load`），`@core.load_from_bytes` 可解码 PSD，对比验证为真正的 FFI 基准
- PSD 无压缩 8-bit 格式简单（header + 跳过 3 个 length 前缀段 + 按通道排列像素），仅需大端序读取 + 通道交错，技术风险低
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，PSD 解码器仅依赖 @types，全目标可用，无需架构改动
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 积累更多格式覆盖基础

## 任务上下文
- ROADMAP.md v2.0 交付物：`src/native/` + `src/pure/{codec,pixel,color,process,util}/` + `src/lib.mbt`（后端选择层）
- T2 产出：types 包全目标（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- T3 产出：pure 包全目标化（仅 import types），全目标可用
- T7 产出：pure 包 BMP+QOI+TGA+PNM 四种解码器，native 582 测试通过
- PSD 文件格式（大端序，参考 Adobe PSD 规范 + `stb_image.h:6126-6280` stbi__psd_load）：
  - Header（26 字节）：signature(4 "8BPS" 0x38425053) + version(2 BE, =1) + reserved(6, =0) + channelCount(2 BE, 3 or 4) + h(4 BE) + w(4 BE) + bitdepth(2 BE, =8) + colorMode(2 BE, =3 RGB)
  - Color mode data：length(4 BE) + data（RGB 模式 length=0）
  - Image resources：length(4 BE) + data
  - Layer and mask data：length(4 BE) + data
  - Image data：compression(2 BE, 0=raw) + 像素数据
  - 无压缩 8-bit 像素：按通道排列（channel[0] 的 w*h 字节，channel[1] 的 w*h 字节，...），通道顺序 R(0)/G(1)/B(2)/A(3)
  - 交错到 Image.data：`data[i*channels + c] = channel_data[c*w*h + i]`
- stb_image PSD 解码行为（`stb_image.h:6126-6280`）：总是内部输出 4 通道 RGBA（channel >= channelCount 时填充默认值：channel 3 = 255，其他 = 0），channelCount >= 4 时做 white matte removal（alpha != 0 && alpha != 255 时修改 RGB）
- `@core.load_from_bytes` 签名（`src/core/image_load_native.mbt:3`）：`pub fn load_from_bytes(data : Bytes, req_channels~ : Option[Int] = None) -> Image raise LoadError`，默认返回 4 通道（PSD），req_channels=Some(3) 返回 3 通道
- pure 包解码器签名惯例：`pub fn decode_xxx_pure(data : Bytes) -> @types.Image raise @types.LoadError`（BMP/QOI/TGA/PNM 一致）
- 根包 `src/moon.pkg`：`for "test"` 已声明 `@pure` 依赖，`options(targets: {"roundtrip_test.mbt": ["native"]})`
- pure 包 `src/pure/{codec,pixel,color,process,util}/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
- 执行约束：保持 v1.0 API 冻结、不破坏现有测试、构建验证

## 已有产出上下文
- `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt`：BMP 解码器（24/32-bit 无压缩），`decode_bmp_pure`
- `src/pure/{codec,pixel,color,process,util}/qoi_decode.mbt`：QOI 解码器（6 种标签），`decode_qoi_pure`
- `src/pure/{codec,pixel,color,process,util}/tga_decode.mbt`：TGA 解码器（type 2/10，含 RLE），`decode_tga_pure`
- `src/pure/{codec,pixel,color,process,util}/pnm_decode.mbt`：PNM 解码器（P5/P6 8-bit），`decode_pnm_pure`
- `src/pure/{codec,pixel,color,process,util}/qoi_decode_test.mbt`：含 `to_bytes` 辅助函数（Array[Byte] → Bytes），可复用
- `src/pure/{codec,pixel,color,process,util}/pnm_decode_test.mbt`：含 `to_bytes` + `push_str` 辅助函数，可复用
- `src/types/`：全目标类型包（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
- `src/roundtrip_test.mbt`：native-only 对比测试文件，已有 BMP/QOI/TGA/PNM pure vs FFI 对比测试
- 当前 native 测试数：582（T7 后）
