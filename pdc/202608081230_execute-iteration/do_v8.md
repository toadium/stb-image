# 执行报告（v8）

## 概述
在 `src/pure/{codec,pixel,color,process,util}/` 新增纯 MoonBit PSD 解码器，扩展 pure 包格式覆盖（BMP+QOI+TGA+PNM → BMP+QOI+TGA+PNM+PSD），推进 v2.0 多目标支持。新增 3 个文件：解码器、纯逻辑测试、FFI 基准对比测试（追加到既有 roundtrip_test.mbt）。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | `src/pure/{codec,pixel,color,process,util}/psd_decode.mbt` | PSD 解码器 `decode_psd_pure`，支持 8-bit RGB/RGBA 无压缩，大端序读取 + 通道交错 |
| 新建 | `src/pure/{codec,pixel,color,process,util}/psd_decode_test.mbt` | 13 个纯逻辑测试（4 正例 + 9 错误路径），全目标可用 |
| 修改 | `src/roundtrip_test.mbt` | 追加 2 个 native-only FFI 基准对比测试 + `make_psd_bytes` 辅助函数 |

## 执行过程

### 解码器实现（`src/pure/{codec,pixel,color,process,util}/psd_decode.mbt`）
- 公开签名 `pub fn decode_psd_pure(data : Bytes) -> @types.Image raise @types.LoadError`，遵循 pure 包解码器惯例（与 BMP/QOI/TGA/PNM 一致）
- 大端序读取辅助：`read_u16_be` / `read_u32_be`，含越界检查（数据过短 → `DecodeFailed`）
- 解析流程：header(26 字节) 校验 → 跳过 3 个 length 前缀段（color mode / image resources / layer and mask）→ image data(compression + 像素)
- 通道交错：`interleaved[i * channel_count + c] = data[pos + c * w * h + i]`，将按通道排列（RRRGGGBBB）交错为 Image.data 格式（RGBRGBRGB）
- 9 条错误路径全部覆盖：数据过短、signature 错误、version 错误、channelCount 不支持、bitdepth 不支持、colorMode 不支持、compression 不支持、尺寸无效、像素数据不足

### 纯逻辑测试（`src/pure/{codec,pixel,color,process,util}/psd_decode_test.mbt`）
- 复用同包已有 `to_bytes` 辅助函数（定义于 `qoi_decode_test.mbt`，同包共享），新增 `push_be16` / `push_be32` 大端序写入辅助
- 构造辅助 `make_psd_header_and_empty_sections`（header + 3 空段）+ `append_psd_image_data`（compression + 按通道排列像素）
- 13 个测试用例：
  1. `2x2 RGB basic`：4 像素 R/G/B 值各不同，验证 width/height/channels/data 逐字节正确
  2. `2x2 RGBA basic`：含 alpha，验证 16 字节 data 逐字节正确
  3. `channel interleave verify`：2x1 3 通道 R=[10,20] G=[30,40] B=[50,60]，验证交错后 [10,30,50,20,40,60]（确保交错逻辑正确，非简单拷贝）
  4. `1x1 minimal image`：最小尺寸边界
  5-13. 9 个错误路径：bad signature / too short / bad version / unsupported channelCount / unsupported bitdepth / unsupported colorMode / unsupported compression / invalid dimensions / pixel data insufficient
- 全目标可用（仅依赖 @types 和 @pure，不依赖 @core）

### FFI 基准对比测试（`src/roundtrip_test.mbt`，native-only）
- 新增 `make_psd_bytes` 辅助函数（完整 PSD 字节流构造）
- 测试 1 `roundtrip: PSD RGB pure vs FFI`：2x2 3 通道 RGB PSD → `@codec.decode_psd_pure`（3 通道）vs `@core.load_from_bytes(psd_bytes, req_channels=Some(3))`（强制 3 通道匹配 pure 输出，绕过 stb_image 内部 4 通道输出）→ 断言 width/height/channels/data 完全一致
- 测试 2 `roundtrip: PSD RGBA pure vs FFI`：2x2 4 通道 RGBA PSD，alpha 全为 255（避免 stb_image white matte removal 修改 RGB）→ `@codec.decode_psd_pure`（4 通道）vs `@core.load_from_bytes(psd_bytes)`（默认 4 通道）→ 断言完全一致
- 关键技术点：stb_image PSD 解码总是内部输出 4 通道 RGBA（`stb_image.h:6249`），channelCount >= 4 时做 white matte removal（alpha != 0 && alpha != 255 时修改 RGB）。对比测试 1 用 req_channels=Some(3) 让 @core 返回 3 通道匹配 pure；对比测试 2 alpha=255 避免 white matte removal，pure 不实现 white matte removal

### 构建验证
- `moon check --target native`：0 errors 0 warnings（30 tasks）
- `moon check --target wasm`：0 errors 0 warnings（4 tasks，pure 包全目标）
- `moon check --target js`：0 errors 0 warnings（4 tasks，pure 包全目标）
- `moon test --target native`：Total tests: 597, passed: 597, failed: 0（582→597，+13 pure 纯逻辑 + 2 根包对比，符合预期）

### 关键决策
1. **辅助函数复用**：首次编写时在 `psd_decode_test.mbt` 重复定义 `to_bytes`，触发 "toplevel identifier declared twice" 错误（MoonBit 同包内顶层 fn 包内共享），移除重复定义后复用 `qoi_decode_test.mbt` 的 `to_bytes`
2. **交错逻辑独立验证**：专门设计 `channel interleave verify` 测试（2x1 3 通道 R=[10,20] G=[30,40] B=[50,60] → [10,30,50,20,40,60]），确保交错公式 `data[i*channels + c] = channel_data[c*w*h + i]` 正确，非简单拷贝
3. **FFI 对比测试的 stb_image 行为适配**：依据任务上下文 `stb_image.h:6126-6280` 的 stbi__psd_load 行为（内部 4 通道 + white matte removal），对比测试 1 用 req_channels=Some(3) 强制 3 通道，对比测试 2 alpha=255 避免 white matte removal，确保 pure vs FFI 像素级一致

## 偏差说明
无
