# 执行报告（v7）

## 概述
在 `src/pure/{codec,pixel,color,process,util}/` 新增纯 MoonBit PNM 解码器 `decode_pnm_pure`，支持 P5（PGM 二进制灰度）和 P6（PPM 二进制 RGB）8-bit 格式，扩展 pure 包格式覆盖（BMP+QOI+TGA → BMP+QOI+TGA+PNM）。新增 8 个纯逻辑测试 + 2 个根包 FFI 基准对比测试，推进 v2.0 多目标支持。

## 产出清单
| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | `src/pure/{codec,pixel,color,process,util}/pnm_decode.mbt` | PNM 解码器，P5/P6 8-bit，含注释行/任意 whitespace 解析 |
| 新建 | `src/pure/{codec,pixel,color,process,util}/pnm_decode_test.mbt` | 8 个纯逻辑测试（全目标，不依赖 @core） |
| 修改 | `src/roundtrip_test.mbt` | 新增 2 个 PNM pure vs FFI 对比测试（PPM RGB + PGM grayscale） |

## 执行过程

### 1. 解码器实现（`src/pure/{codec,pixel,color,process,util}/pnm_decode.mbt`）
- **公开签名**：`pub fn decode_pnm_pure(data : Bytes) -> @types.Image raise @types.LoadError`，遵循 pure 包解码器惯例（与 BMP/QOI/TGA 一致）
- **magic 校验**：仅接受 P5（0x50 0x35）和 P6（0x50 0x36），其他 magic（P1-P4 ASCII、P7 PAM 等）→ `DecodeFailed`
- **Header 解析**：3 个辅助函数
  - `pnm_is_whitespace`：识别 space/tab/LF/CR 四种 whitespace
  - `pnm_skip_ws_and_comments`：跳过 whitespace 和 `#` 注释行（至 LF 行尾），注释行可出现在 magic 后 header 任意位置
  - `pnm_read_ascii_int`：读取 ASCII 数字（'0'-'9'），非数字则停止
- **maxval 校验**：`maxval >= 256` → `DecodeFailed`（不支持 16-bit）；`maxval <= 0` → `DecodeFailed`
- **像素数据**：maxval 后恰好 1 个 whitespace，然后读取 `width*height*channels` 字节像素，直接拷贝（PNM 二进制像素顺序与 Image.data 一致：P6 RGB、P5 灰度）
- **错误路径**：数据过短、不支持的 magic、不支持的 maxval、header 数字解析失败、尺寸无效、像素数据不足，均 `raise @types.LoadError::DecodeFailed`

### 2. 纯逻辑测试（`src/pure/{codec,pixel,color,process,util}/pnm_decode_test.mbt`）
- 复用同包 `qoi_decode_test.mbt` 的 `to_bytes` 辅助函数
- 新增 `push_str` 辅助函数：将 ASCII 字符串逐字节 push 到 Array[Byte]
- **8 个测试用例**：
  1. `P6 2x2 RGB basic`：4 像素 RGB，验证 width/height/channels/data
  2. `P5 2x2 grayscale basic`：4 像素灰度，验证 width/height/channels/data
  3. `comment line in header`：header 含两行 `# comment` 注释，验证注释跳过正确
  4. `mixed whitespace separators`：tab + LF 混合分隔（`P6\t2\n2\t255\n`），验证任意 whitespace 支持
  5. `1x1 minimal image`：最小尺寸 P6，验证边界正确
  6. `too short raises`：仅 "P6" 2 字节，验证数据过短报错
  7. `unsupported magic raises`：P3（ASCII PPM），验证不支持的 magic 报错
  8. `unsupported maxval raises`：maxval=65535，验证 16-bit 不支持报错

### 3. FFI 基准对比测试（`src/roundtrip_test.mbt`）
- 新增 2 个 native-only 测试，使用 `@format.encode_ppm`/`encode_pgm` 生成对比数据：
  1. `roundtrip: PPM RGB pure vs FFI`：加载 test_4x4_red.png → `@format.encode_ppm` → pure 解码 vs `@core.load_from_bytes`，断言 width/height/channels/data 完全一致
  2. `roundtrip: PGM grayscale pure vs FFI`：构造 2x2 灰度 Image → `@format.encode_pgm` → pure 解码 vs `@core.load_from_bytes`，断言完全一致

### 4. 构建验证
- `moon check --target native`：0 errors 0 warnings
- `moon check --target wasm`：0 errors 0 warnings（pure 包全目标）
- `moon check --target js`：0 errors 0 warnings（pure 包全目标）
- `moon test --target native`：**Total tests: 582, passed: 582, failed: 0**
  - 较上轮 572 增加 10（+8 pure 纯逻辑 + 2 根包对比），符合预期范围 580-582

## 偏差说明
无。实现完全遵循 task_v7.md 的要求：
- 解码器签名、P5/P6 支持、8-bit 限制、注释行/whitespace 处理均符合规范
- 测试覆盖 8 个用例（要求 7-9 个），含 5 正例 + 3 错误路径
- FFI 对比测试 2 个，使用 `@format.encode_ppm`/`encode_pgm`（非 `@core.`，core 无此二函数）
- 未修改任何现有代码（仅新增文件 + 追加测试），v1.0 API 冻结保持
- pure 包仅依赖 @types，全目标可用
