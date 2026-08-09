# 任务指令（v6）

## 动作
NEW

## 任务描述
在 `src/pure/{codec,pixel,color,process,util}/` 新增纯 MoonBit TGA 解码器，扩展 pure 包格式覆盖（从 BMP+QOI 扩展到 BMP+QOI+TGA），推进 v2.0 多目标支持的实质功能。具体产出：

1. **`src/pure/{codec,pixel,color,process,util}/tga_decode.mbt`**：实现 `pub fn decode_tga_pure(data : Bytes) -> @types.Image raise @types.LoadError`，支持：
   - image type 2（未压缩 RGB）和 type 10（RLE RGB）
   - 24-bit（comp=3，BGR→RGB）和 32-bit（comp=4，BGRA→RGBA）
   - 18 字节 TGA header 解析（ID length、color map type、image type、width/height LE、bpp、descriptor）
   - RLE 解压（header 1 字节：bit7=1 → RLE packet run=(header&0x7F)+1 读 1 像素重复 run 次；bit7=0 → raw packet count=(header&0x7F)+1 读 count 像素）
   - 行序处理（descriptor bit4=0 → bottom-up 翻转，bit4=1 → top-down 保持）
   - BGR(A)→RGB(A) 像素顺序转换
   - 错误路径：数据过短、不支持的 image type、不支持的 bpp → `raise @types.LoadError::DecodeFailed(...)`

2. **`src/pure/{codec,pixel,color,process,util}/tga_decode_test.mbt`**：纯逻辑测试（全目标，不依赖 @core，手构造 TGA 字节流验证），建议覆盖：
   - type 2 未压缩 24-bit RGB（1x1 或 2x2，验证 BGR→RGB 转换）
   - type 2 未压缩 32-bit RGBA（验证 BGRA→RGBA 转换）
   - type 10 RLE 24-bit RGB（手构造 RLE packet + raw packet，验证 RLE 解压）
   - type 10 RLE 32-bit RGBA
   - bottom-up 行序验证（2x2 图像，验证行序翻转正确性）
   - top-down 行序验证（descriptor bit4=1）
   - 错误路径：数据过短、不支持的 image type（如 type 1 颜色映射）、不支持的 bpp（如 bpp=16 或 bpp=8）
   - 测试数由实现决定（建议 8-10 个），确保覆盖 type 2/type 10/24-bit/32-bit/行序/错误路径（含 3 个错误路径测试：数据过短 + 不支持 image type + 不支持 bpp）

3. **`src/roundtrip_test.mbt`** 新增 1 个 native-only 对比测试 `roundtrip: TGA pure vs FFI`：
   - `@core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))` 加载测试图像
   - `@core.write_tga_to_bytes(img)` 生成 TGA 字节流（FFI 生成，默认 RLE 压缩，image type 10）
   - `@codec.decode_tga_pure(tga_bytes)` 纯 MoonBit 解码
   - `@core.load_from_bytes(tga_bytes, req_channels=Some(3))` FFI 基准解码
   - 断言 width/height/channels/data 完全一致
   - 对比性质：真正的 FFI 基准对比（stb_image C 库原生支持 TGA 读写），非 QOI 的纯 MoonBit 交叉验证

4. **构建验证**：
   - `moon check`（全目标）0 errors 0 warnings
   - `moon test --target native` 全量通过（预期 562 + N_pure_tga + 1 根包对比，N_pure_tga 为 pure 包 TGA 纯逻辑测试数，建议 8-10 个，即预期 571-573）

## 选择理由
- T5 已完成 QOI 解码器（pure 包 BMP+QOI 两种格式），需继续扩展格式覆盖以推进 v2.0 多目标支持实质功能
- TGA 格式简单（18 字节 header + RLE/无压缩像素），stb_image C 库原生支持 TGA 读写，对比验证为真正的 FFI 基准（非 QOI 的纯 MoonBit 交叉验证），价值更高
- `@core.write_tga_to_bytes` 已存在（`src/core/image_write_native.mbt:110`），`@core.load_from_bytes` 支持 TGA 解码，对比测试基础设施完备
- stb_image_write 默认输出 RLE 压缩 TGA（image type 10，`stbi_write_tga_with_rle=1`），pure 解码器须支持 RLE 解压，RLE 算法清晰（1 字节 header + run/raw packet），技术风险可控
- pure 包全目标化（T3）+ types 包全目标（T2）已就绪，TGA 解码器仅依赖 @types，全目标可用，无需架构改动
- 风险可控：新增文件不修改现有代码，v1.0 API 冻结保持，对比测试在根包 native-only 文件中（无全目标警告问题）
- 为后续后端选择层 `src/lib.mbt` 和 pure 包格式进一步扩展积累格式覆盖基础

## 任务上下文
摘录与当前任务直接相关的需求/约束：

**v2.0 多目标支持（ROADMAP.md）**：
- 交付物：`src/native/` + `src/pure/{codec,pixel,color,process,util}/` + `src/lib.mbt`（后端选择层）
- 路径 A（双后端）：native 保持 C FFI，wasm/js 用纯 MoonBit fallback

**stb_image_write TGA 输出格式（已核实源码 `src/core/stb_image_write.h:532-609,418-449`）**：
- 18 字节 header：[0]ID length=0 [1]color map type=0 [2]image type=10（RLE RGB，comp≥2）或 11（RLE 灰度，comp<2） [3-4]color map start=0 LE [5-6]color map length=0 LE [7]color map bits=0 [8-9]x origin=0 LE [10-11]y origin=0 LE [12-13]width LE [14-15]height LE [16]bpp=comp*8（24 或 32） [17]descriptor=has_alpha*8（comp=4→8, comp=3→0）
- 默认 RLE 压缩（`stbi_write_tga_with_rle=1`，line 252/256，MoonBit FFI 未修改此全局变量）
- bottom-up 行序（descriptor bit4=0，stb_image_write 输出 0 或 8 均无 0x10）
- BGR(A) 像素顺序（`stbiw__write_pixel` rgb_dir=-1 → `stbiw__write3(s, d[2], d[1], d[0])` 即 BGR，alpha 追加 d[3]）

**TGA RLE 编码规则**：
- 读 1 字节 header
- bit7=1（header & 0x80 != 0）→ RLE packet：run = (header & 0x7F) + 1，读 1 个像素，重复 run 次
- bit7=0（header & 0x80 == 0）→ raw packet：count = (header & 0x7F) + 1，读 count 个像素

**TGA header 结构（18 字节）**：
| 偏移 | 长度 | 字段 | 说明 |
|------|------|------|------|
| 0 | 1 | ID length | ID 字段长度，stb_image_write 输出 0 |
| 1 | 1 | color map type | 0=无颜色映射，1=有颜色映射 |
| 2 | 1 | image type | 2=未压缩 RGB，3=未压缩灰度，10=RLE RGB，11=RLE 灰度 |
| 3-4 | 2 | color map start (LE) | 颜色映射起始索引 |
| 5-6 | 2 | color map length (LE) | 颜色映射长度 |
| 7 | 1 | color map bits | 颜色映射位深 |
| 8-9 | 2 | x origin (LE) | 图像 x 原点 |
| 10-11 | 2 | y origin (LE) | 图像 y 原点 |
| 12-13 | 2 | width (LE) | 图像宽度 |
| 14-15 | 2 | height (LE) | 图像高度 |
| 16 | 1 | bits per pixel | 8/16/24/32 |
| 17 | 1 | descriptor | bit4=0 bottom-up, bit4=1 top-down; bit3-0=alpha bits |

**执行约束**：
1. 保持 v1.0 API 冻结：新增功能只添加，不修改已有签名
2. 遵循五子包架构：pure 包是新增的全目标包，不影响现有架构
3. 纯 MoonBit 补齐：TGA 解码用纯 MoonBit 实现，放在 pure 包中
4. 测试先行：新功能必须有测试
5. 不破坏现有测试：所有现有 562 测试必须继续通过
6. 构建验证：`moon check`（全目标）+ `moon test --target native`

## 已有产出上下文
工作目录中已有的相关产出概述：

**T2 产出（core 包类型分离）**：
- `src/types/` 全目标包：Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError 类型定义（无 FFI 依赖）
- core 包通过 `pub type X = @types.X` 别名 re-export，`@core.Image` 即 `@types.Image`
- pure 包主代码用 @types，全目标可用

**T3 产出（pure 包全目标化）**：
- `src/pure/{codec,pixel,color,process,util}/moon.pkg`：仅 `import types`，无 `supported_targets`，全目标
- pure 包 6 个 BMP 纯逻辑测试（全目标可用）

**T5 产出（QOI 解码器）**：
- `src/pure/{codec,pixel,color,process,util}/qoi_decode.mbt`：`decode_qoi_pure`，支持全部 6 种 QOI 标签
- `src/pure/{codec,pixel,color,process,util}/qoi_decode_test.mbt`：8 纯逻辑测试
- `src/roundtrip_test.mbt`：QOI pure vs format 交叉验证测试（line 116-132）
- native 562 测试通过

**pure 包现有文件**：
- `src/pure/{codec,pixel,color,process,util}/bmp_decode.mbt` + `bmp_decode_test.mbt`（T1）
- `src/pure/{codec,pixel,color,process,util}/qoi_decode.mbt` + `qoi_decode_test.mbt`（T5）
- `src/pure/{codec,pixel,color,process,util}/moon.pkg`：仅 `import { "Toadium/image/src/types" }`

**根包配置**：
- `src/moon.pkg`：`supported_targets = "native"`，`for "test"` 声明 `@pure` 依赖（line 16-18），`options(targets: {"roundtrip_test.mbt": ["native"]})`（line 26）
- `src/roundtrip_test.mbt`：native-only，现有 TGA 测试模式（line 63-73）：`@core.load_from_path` → `@core.write_tga_to_bytes` → `@core.load_from_bytes` → 断言 data 一致

**FFI 接口**：
- `@core.write_tga_to_bytes(img : Image) -> Bytes raise LoadError`（`src/core/image_write_native.mbt:110`）
- `@core.load_from_bytes(data : Bytes, req_channels~ : Int? = None) -> Image raise LoadError`（`src/core/image_load_native.mbt:3`）
- stb_image 支持 TGA 解码（`src/core/stb_image.h:26,927-930,5735-5887`）

**签名惯例**（与 pure 包现有解码器一致）：
- `pub fn decode_bmp_pure(data : Bytes) -> @types.Image raise @types.LoadError`
- `pub fn decode_qoi_pure(data : Bytes) -> @types.Image raise @types.LoadError`
- 本任务：`pub fn decode_tga_pure(data : Bytes) -> @types.Image raise @types.LoadError`
