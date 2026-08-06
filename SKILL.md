---
name: stb-image
description: MoonBit native FFI bindings for stb_image.h v2.30 + stb_image_write.h v1.16 + stb_image_resize2.h v2.07 — full image decode/encode/resize/process capability: 8-bit/16-bit/float load, animated GIF, info query, write PNG/BMP/TGA/JPEG/HDR, resize, format detection, QOI/ICO/ICNS/GIF/PNM codec, EXIF/PNG metadata, image processing (crop/rotate/flip/color/filter/histogram/quantize), 254 tests + 29 benchmarks, ASan verified.
---

# stb-image

MoonBit native FFI bindings for [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16 + [stb_image_resize2.h](https://github.com/nothings/stb) v2.07.

## 用途

将 C 单头文件库 `stb_image.h` / `stb_image_write.h` / `stb_image_resize2.h` 以 MoonBit 原生 FFI 绑定形式暴露为 MoonBit 包，提供完整的图像 load/write/resize/process 能力。支持 native 目标，覆盖 PNG/JPEG/BMP/GIF/QOI/ICO/ICNS/TGA/PSD/HDR/PIC/PNM 等 10+ 种格式，以及 crop/rotate/flip/color/filter/histogram/quantize 等图像处理操作。

## 快速开始

```moonbit
// 从文件路径加载
let img : Image = load_from_path("photo.png")
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 从内存字节加载，强制 RGBA
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// Resize
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

### 类型（11 个）

| 类型 | 说明 |
|------|------|
| `Image` | 8-bit 解码结果 `{ width, height, channels, data : Bytes }` |
| `Image16` | 16-bit 解码结果（UInt16 little-endian） |
| `ImageF` | HDR float 解码结果（IEEE 754 little-endian） |
| `ImageInfo` | 图像信息 `{ width, height, channels }`，不含像素数据 |
| `GifAnimation` | 动画 GIF `{ frames : Array[Image], delays : Array[Int] }` |
| `LoadError` | 错误类型 `{ FileIO, UnsupportedFormat, DecodeFailed }` |
| `ImageFormat` | 格式枚举 `{ Png, Jpeg, Bmp, Gif, Tga, Psd, Hdr, Pnm, Qoi, Unknown }` |
| `ResizeFilter` | resize 滤波器 `{ Default, Box, Triangle, CubicBSPline, CatmullROM, Mitchell, PointSample }` |
| `ResizeEdge` | resize 边缘模式 `{ Clamp, Reflect, Wrap, Zero }` |
| `ExifInfo` | EXIF 元数据 `{ make, model, date_time : String, orientation : Int }` |
| `PngTextChunk` | PNG text chunk `{ keyword, text : String }` |

### 加载（8 函数）

`load_from_*`、`load_16_from_*`、`loadf_from_*`、`load_gif_from_*` — 均支持 `req_channels? : Int?` 可选参数

### 写入（10 函数）

`write_png/bmp/tga/jpeg_to_path/bytes` + `write_hdr_to_path/bytes` — JPEG 支持 `quality? : Int`（默认 90）

### Resize（4 函数）

`resize` / `resize_srgb` / `resize_16` / `resizef` — 支持 `filter? : ResizeFilter` 和 `edge? : ResizeEdge` 可选参数

### 格式检测（3 函数）

`detect_format` / `decode_any` / `is_supported_format`

### 编解码（11 函数）

- QOI: `decode_qoi` / `encode_qoi`
- ICO/ICNS: `encode_ico` / `encode_ico_sizes` / `encode_icns`
- GIF: `encode_gif` / `encode_gif_animation`
- PNM: `encode_ppm` / `encode_pgm` / `encode_pnm`

### 图像处理（19 函数）

- Transform: `crop` / `crop_16` / `cropf` / `rotate_90` / `rotate_180` / `rotate_270` / `flip_horizontal`
- Color: `to_grayscale` / `to_rgb` / `to_rgba` / `premultiply_alpha` / `unpremultiply_alpha`
- Draw: `draw_copy` / `draw_over`

### 色彩调整（8 函数）

`adjust_brightness` / `adjust_contrast` / `adjust_gamma` / `invert` / `rgb_to_hsv` / `hsv_to_rgb` / `rgb_to_hsl` / `hsl_to_rgb`

### 滤波（4 函数）

`box_blur` / `gaussian_blur` / `sharpen` / `edge_detect_sobel`

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

`UnsupportedFormat` 与 `DecodeFailed` 不可精确区分，stb_image 返回 NULL 时默认归类为 `DecodeFailed`。可用 `failure_reason()` 获取 stb_image 内部失败原因字符串。

## 目标后端

仅支持 **native** 目标。多目标（wasm/js）已评估并暂缓：需 Emscripten 构建链 + `extern "wasm"`/`extern "js"` FFI 机制，成本过高。类型定义（`Image`/`Image16`/`ImageF`/`ImageInfo`/`GifAnimation`/`LoadError`）全后端可用。

## 架构

四层分层架构，依赖单向向下：

1. **Vendoring 层**：`scripts/prepare.py` 下载 pinned `stb_image.h` v2.30 + `stb_image_write.h` v1.16 + `stb_image_resize2.h` v2.07
2. **FFI 边界层**：`wrapper.c`（ABI 归一化）+ `ffi.mbt`（私有 `extern "c"` 声明）
3. **安全 API 层**：`image_types.mbt`（类型）+ `image_*_native.mbt`（FFI API）+ 纯 MoonBit 模块（transform/color/filter/geometry/histogram/quantize/draw/qoi/icon_encode/gif_encode/pnm_encode/exif/png_meta）
4. **测试与文档层**：`*_test.mbt`（254 测试）+ `roundtrip_test.mbt`（全格式 roundtrip）+ `bench.mbt`（29 基准测试）+ `README.mbt.md`

## 版本演进

- **v0.1**：8-bit load（path + bytes），9 种格式
- **v0.2**：write（PNG/BMP/TGA/JPEG）+ req_channels + flip
- **v0.3**：16-bit/float load + info + is_16_bit/is_hdr + failure_reason + config
- **v0.4**：HDR config + animated GIF
- **v1.0**：API 冻结，完整文档，61 测试，ASan 验证通过
- **v1.1**：HDR 写入 + resize（FFI stb_image_resize2.h），75 测试
- **v1.2**：QOI/ICO/ICNS/GIF 编码 + 格式自动检测，114 测试
- **v1.3**：crop/rotate/flip + 色彩转换 + draw/compositing，145 测试
- **v1.4**：色彩调整/滤波/几何变换/直方图/量化，206 测试
- **v1.5**：PNM 编码 + GIF 动画 + EXIF 读取，229 测试
- **v1.6**：PNG 元数据 + roundtrip 测试 + 性能基准，254 测试 + 29 基准测试

## 限制

- I/O callbacks（`stbi_io_callbacks`）未实现：MoonBit FFI 不支持将闭包传递给 C 作为函数指针
- 多目标支持暂缓：需 Emscripten + 不同 FFI 机制
- 零拷贝未实现：当前所有 load 路径通过 `memcpy` 从 C 缓冲区拷贝到 MoonBit `Bytes`
