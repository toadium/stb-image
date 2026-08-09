---
name: image
description: MoonBit 图像处理库 — 纯 MoonBit 实现，多目标支持（native/wasm-gc/js 均使用纯 MoonBit），完整图像解码/编码/缩放/处理能力，645 测试 × 3 目标 (native/wasm-gc/js)，ASan 验证通过。
---

# image 包使用指南

纯 MoonBit 图像处理库，纯 MoonBit 实现，无 C FFI 依赖。

## 用途

纯 MoonBit 图像处理库，提供完整的图像加载/写入/缩放/处理能力。多目标支持：三目标 (native/wasm-gc/js) 均使用纯 MoonBit（`src/pure/{codec,pixel,color,process,util}/`）。覆盖 PNG/JPEG/BMP/GIF/QOI/ICO/ICNS/TGA/PSD/HDR/PIC/PNM 等 10+ 种格式，以及裁剪/旋转/翻转/色彩/滤波/直方图/量化等图像处理操作。

## 快速开始

```moonbit
// 从文件路径加载
let img : Image = load_from_path("photo.png")
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 从内存字节加载，强制 RGBA
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// 缩放
let resized : Image = resize(img, 128, 128)

// 自动检测格式并解码
let any : Image = decode_any(data, req_channels=Some(3))

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_path("animation.gif")
println("frames=\{anim.frames.length()}")

// 读取 EXIF 元数据
let exif : ExifInfo? = read_exif_from_path("photo.jpg")
```

## API 概览

### 类型（27 个）

| 类型 | 说明 |
|------|------|
| `Image` | 8位解码结果 `{ width, height, channels, data : Bytes }` |
| `Image16` | 16位解码结果（UInt16 little-endian） |
| `ImageF` | HDR 浮点解码结果（IEEE 754 little-endian） |
| `ImageInfo` | 图像信息 `{ width, height, channels }`，不含像素数据 |
| `GifAnimation` | 动画 GIF `{ frames : Array[Image], delays : Array[Int] }` |
| `LoadError` | 错误类型 `{ FileIO, UnsupportedFormat, DecodeFailed }` |
| `ImageFormat` | 格式枚举 `{ Png, Jpeg, Bmp, Gif, Tga, Psd, Hdr, Pnm, Qoi, Unknown }` |
| `ResizeFilter` | 缩放滤波器 `{ Default, Box, Triangle, CubicBSPline, CatmullROM, Mitchell, PointSample }` |
| `ResizeEdge` | 缩放边缘模式 `{ Clamp, Reflect, Wrap, Zero }` |
| `ExifInfo` | EXIF 元数据 `{ make, model, date_time : String, orientation : Int }` |
| `PngTextChunk` | PNG 文本块 `{ keyword, text : String }` |

### 加载（8 函数）

`load_from_*`、`load_16_from_*`、`loadf_from_*`、`load_gif_from_*` — 均支持 `req_channels? : Int?` 可选参数

### 写入（10 函数）

`write_png/bmp/tga/jpeg_to_path/bytes` + `write_hdr_to_path/bytes` — JPEG 支持 `quality? : Int`（默认 90）

### 缩放（4 函数）

`resize` / `resize_srgb` / `resize_16` / `resizef` — 支持 `filter? : ResizeFilter` 和 `edge? : ResizeEdge` 可选参数

### 格式检测（3 函数）

`detect_format` / `decode_any` / `is_supported_format`

### 编解码（11 函数）

- QOI：`decode_qoi` / `encode_qoi`
- ICO/ICNS：`encode_ico` / `encode_ico_sizes` / `encode_icns`
- GIF：`encode_gif` / `encode_gif_animation`
- PNM：`encode_ppm` / `encode_pgm` / `encode_pnm`

### 图像处理（19+ 函数）

- 变换：`crop` / `crop_16` / `cropf` / `rotate_90` / `rotate_180` / `rotate_270` / `flip_horizontal`
- 色彩：`to_grayscale` / `to_rgb` / `to_rgba` / `premultiply_alpha` / `unpremultiply_alpha`
- 绘制：`draw_copy` / `draw_over`

### 色彩调整（8 函数）

`adjust_brightness` / `adjust_contrast` / `adjust_gamma` / `invert` / `rgb_to_hsv` / `hsv_to_rgb` / `rgb_to_hsl` / `hsl_to_rgb`

### 滤波（6 函数）

`box_blur` / `gaussian_blur` / `sharpen` / `edge_detect_sobel` / `edge_detect_laplacian` / `edge_detect_prewitt`

### 几何（2 函数）

`warp_affine`（仿射变换+双线性插值）/ `rotate`（任意角度旋转）

### 直方图（3 函数）

`histogram` / `histogram_equalize` / `histogram_normalize`

### 量化（2 函数）

`floyd_steinberg`（误差扩散抖动）/ `median_cut`（中位切分量化）

### 元数据（4 函数）

`read_exif_from_bytes` / `read_exif_from_path` / `read_png_text_chunks` / `read_png_text_chunks_from_path`

### 查询（7 函数）

`info_from_*`、`is_16_bit_from_*`、`is_hdr_from_*`、`failure_reason`

### 配置（8 函数）

`set_flip_vertically_on_load`、`flip_vertically_on_write`、`set_unpremultiply_on_load`、`convert_iphone_png_to_rgb`、`hdr_to_ldr_gamma/scale`、`ldr_to_hdr_gamma/scale`

### 文件 I/O（1 函数）

`read_file_bytes`

## 最小示例

```moonbit
let bmp = b"\x42\x4D\x3A\x00\x00\x00\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x18\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\x00"
let img = load_from_bytes(bmp)
assert_eq(img.width, 1)
assert_eq(img.height, 1)
assert_eq(img.channels, 3)
```

## 错误处理

```moonbit
try {
  let img = load_from_bytes(data)
} catch {
  LoadError::FileIO(msg) => println("文件 IO 错误: \{msg}")
  LoadError::DecodeFailed(msg) => println("解码失败: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("格式不支持: \{msg}")
}
```

`UnsupportedFormat` 与 `DecodeFailed` 不可精确区分，解码失败时 raise LoadError 时默认归类为 `DecodeFailed`。可用 `failure_reason()` 获取解码失败原因字符串。

## 目标后端

多目标支持：native/wasm-gc/js 均使用纯 MoonBit `src/pure/{codec,pixel,color,process,util}/`。三目标各 645 测试通过。

## 架构

八子包分层架构，依赖单向向下：

1. **类型层**：`types/`（全目标类型定义：Image/Image16/ImageF/ImageInfo 等）
2. **纯 MoonBit 后端层**：`pure/{codec,pixel,color,process,util}/`（纯 MoonBit 实现，无 C FFI 依赖，三目标共用）
3. **统一 API 层**：`lib/`（pure 侧统一 API + 格式自动分派）+ `process/`（图像处理）+ `format/`（编解码）+ `meta/`（元数据）+ `util/`（工具函数）
4. **测试与文档层**：`*_test.mbt`（645 测试 × 3 目标）+ `roundtrip_test.mbt`（全格式往返）+ `bench.mbt`（性能基准）

## 版本演进

- **v0.1**：8位加载（路径+内存），9 种格式
- **v0.2**：写入（PNG/BMP/TGA/JPEG）+ req_channels + 翻转
- **v0.3**：16位/浮点加载 + info + is_16_bit/is_hdr + failure_reason + 配置
- **v0.4**：HDR 配置 + 动画 GIF
- **v1.0**：API 冻结，完整文档，61 测试，ASan 验证通过
- **v1.1**：HDR 写入 + 缩放（FFI stb_image_resize2.h），75 测试
- **v1.2**：QOI/ICO/ICNS/GIF 编码 + 格式自动检测，114 测试
- **v1.3**：裁剪/旋转/翻转 + 色彩转换 + 绘制/合成，145 测试
- **v1.4**：色彩调整/滤波/几何变换/直方图/量化，206 测试
- **v1.5**：PNM 编码 + GIF 动画 + EXIF 读取，229 测试
- **v1.6**：PNG 元数据 + 往返测试 + 性能基准，254 测试 + 29 基准测试
- **v1.7-v1.17**：高级图像处理（混合模式/FFT/自适应阈值/连通域/积分图像/霍夫变换/LBP/金字塔/双边滤波/轮廓/分割/NLM/Retinex/Canny/分水岭/GLCM/Haar小波/Harris角点/去雾/距离变换/Gabor滤波），533 测试 + 29 基准测试
- **v2.0**：多目标支持（native/wasm-gc/js 均使用纯 MoonBit），多子包架构，645 测试 × 3 目标 (native/wasm-gc/js)

## 限制

- JPEG progressive 编码未实现：纯 MoonBit 实现成本过高
- 零拷贝未实现：当前所有加载路径通过 Bytes 拷贝传递像素数据
