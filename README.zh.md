# stb-image

[English](README.md) | [中文](README.zh.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-native-blue)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/tests-341%20passed-brightgreen)]()
[![Bench](https://img.shields.io/badge/bench-29%20passed-brightgreen)]()
[![ASan](https://img.shields.io/badge/ASan-passed-brightgreen)]()

MoonBit 原生 FFI 绑定库，封装 [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16 + [stb_image_resize2.h](https://github.com/nothings/stb) v2.07。

完整图像解码/编码/缩放/处理能力：8位/16位/浮点加载、动画GIF、信息查询、写入 PNG/BMP/TGA/JPEG/HDR、缩放、格式检测、QOI/ICO/ICNS/GIF/PNM 编解码、EXIF/PNG 元数据、图像处理（裁剪/旋转/翻转/色彩/滤波/直方图/量化/形态学/边缘检测/质量评估）、往返测试、性能基准测试。

## 功能特性

- **10+ 格式解码**：PNG、JPEG、BMP、GIF、PSD、TGA、HDR、PIC、WebP、PNM (PPM/PGM)、QOI
- **8 格式编码**：PNG、BMP、TGA、JPEG、HDR、QOI、GIF、PNM (PPM/PGM)
- **3 种像素类型**：8位 (`Image`)、16位 (`Image16`)、HDR浮点 (`ImageF`)
- **缩放**：7种滤波器 × 4种边缘模式，支持8位/16位/浮点/sRGB
- **格式检测**：`detect_format` / `decode_any` / `is_supported_format`
- **图像处理**：裁剪、旋转、翻转、色彩转换、绘制/合成
- **色彩调整**：亮度、对比度、伽马、反色、HSV/HSL 转换
- **滤波器**：方框模糊、高斯模糊、锐化、Sobel/Laplacian/Prewitt 边缘检测
- **几何变换**：仿射变换、任意角度旋转
- **直方图**：计算、均衡化、归一化
- **量化**：Floyd-Steinberg 抖动、中位切割
- **形态学**：腐蚀、膨胀、开运算、闭运算（3x3 结构元素）
- **质量评估**：MSE、PSNR、SSIM
- **元数据**：EXIF 读取、PNG 文本块
- **动画GIF**：多帧解码/编码，支持逐帧延迟
- **信息查询**：不解码像素即可获取尺寸
- **可配置**：翻转、非预乘Alpha、iPhone PNG、HDR伽马/缩放
- **错误诊断**：`failure_reason()` 获取 stb_image 内部错误字符串
- **341 测试 + 29 基准测试**，全部通过 AddressSanitizer

## 安装

```bash
moon add MoonBit-Toadium/stb-image
```

## 快速上手

```moonbit
// 从文件解码
let img : Image = load_from_path("photo.png")
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 从内存解码，强制 RGBA
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// 使用默认滤波器缩放
let resized : Image = resize(img, 128, 128)

// 自动检测格式并解码
let any : Image = decode_any(data, req_channels=Some(3))

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_path("animation.gif")
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// 读取 EXIF 元数据
let exif : ExifInfo? = read_exif_from_path("photo.jpg")

// 查询图像信息（不解码）
let info : ImageInfo? = info_from_path("large.hdr")
```

## 类型

| 类型 | 字段 | 说明 |
|------|------|------|
| `Image` | `width, height, channels : Int; data : Bytes` | 8位解码图像 |
| `Image16` | `width, height, channels : Int; data : Bytes` | 16位解码图像（UInt16 小端，2字节/像素） |
| `ImageF` | `width, height, channels : Int; data : Bytes` | HDR浮点解码图像（IEEE 754 小端，4字节/像素） |
| `ImageInfo` | `width, height, channels : Int` | 图像信息（无像素数据） |
| `GifAnimation` | `frames : Array[Image]; delays : Array[Int]` | 动画GIF（延迟单位毫秒） |
| `LoadError` | `FileIO(String) \| UnsupportedFormat(String) \| DecodeFailed(String)` | 加载失败错误 |
| `ImageFormat` | `Png \| Jpeg \| Bmp \| Gif \| Tga \| Psd \| Hdr \| Pnm \| Qoi \| Unknown` | 图像格式枚举 |
| `ResizeFilter` | `Default \| Box \| Triangle \| CubicBSPline \| CatmullROM \| Mitchell \| PointSample` | 缩放滤波器枚举 |
| `ResizeEdge` | `Clamp \| Reflect \| Wrap \| Zero` | 缩放边缘模式枚举 |
| `ExifInfo` | `make, model, date_time : String; orientation : Int` | EXIF 元数据 |
| `PngTextChunk` | `keyword, text : String` | PNG tEXt/iTXt 文本块 |

所有类型派生 `Eq` 和 `@debug.Debug`。

## API 参考

### 加载（8个函数）

所有加载函数接受可选参数 `req_channels : Int?`（1=灰度, 2=灰度+Alpha, 3=RGB, 4=RGBA）。传 `None` 保持原始通道数。

| 函数 | 签名 | 返回 |
|------|------|------|
| `load_from_path` | `(String, req_channels?: Int?) -> Image` | 从文件加载8位 |
| `load_from_bytes` | `(Bytes, req_channels?: Int?) -> Image` | 从内存加载8位 |
| `load_16_from_path` | `(String, req_channels?: Int?) -> Image16` | 从文件加载16位 |
| `load_16_from_bytes` | `(Bytes, req_channels?: Int?) -> Image16` | 从内存加载16位 |
| `loadf_from_path` | `(String, req_channels?: Int?) -> ImageF` | 从文件加载HDR浮点 |
| `loadf_from_bytes` | `(Bytes, req_channels?: Int?) -> ImageF` | 从内存加载HDR浮点 |
| `load_gif_from_path` | `(String, req_channels?: Int?) -> GifAnimation` | 从文件加载动画GIF |
| `load_gif_from_bytes` | `(Bytes, req_channels?: Int?) -> GifAnimation` | 从内存加载动画GIF |

### 写入（10个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `write_png_to_path` | `(String, Image) -> Unit` | 写入PNG文件 |
| `write_bmp_to_path` | `(String, Image) -> Unit` | 写入BMP文件 |
| `write_tga_to_path` | `(String, Image) -> Unit` | 写入TGA文件 |
| `write_jpeg_to_path` | `(String, Image, quality?: Int) -> Unit` | 写入JPEG（默认质量90） |
| `write_hdr_to_path` | `(String, ImageF) -> Unit` | 写入HDR文件 |
| `write_png_to_bytes` | `(Image) -> Bytes` | 编码PNG为字节 |
| `write_bmp_to_bytes` | `(Image) -> Bytes` | 编码BMP为字节 |
| `write_tga_to_bytes` | `(Image) -> Bytes` | 编码TGA为字节 |
| `write_jpeg_to_bytes` | `(Image, quality?: Int) -> Bytes` | 编码JPEG为字节 |
| `write_hdr_to_bytes` | `(ImageF) -> Bytes` | 编码HDR为字节 |

### 缩放（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `resize` | `(Image, Int, Int, filter?: ResizeFilter, edge?: ResizeEdge) -> Image` | 8位缩放 |
| `resize_srgb` | `(Image, Int, Int, filter?, edge?) -> Image` | sRGB色彩空间缩放 |
| `resize_16` | `(Image16, Int, Int, filter?, edge?) -> Image16` | 16位缩放 |
| `resizef` | `(ImageF, Int, Int, filter?, edge?) -> ImageF` | 浮点缩放 |

### 格式检测（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `detect_format` | `(Bytes) -> ImageFormat` | 从魔数字节检测格式 |
| `decode_any` | `(Bytes, req_channels?: Int?) -> Image` | 自动检测并解码 |
| `is_supported_format` | `(Bytes) -> Bool` | 检查格式是否支持 |

### QOI 编解码（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `decode_qoi` | `(Bytes) -> Image` | 解码QOI格式 |
| `encode_qoi` | `(Image) -> Bytes` | 编码QOI格式 |

### ICO/ICNS 编码（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `encode_ico` | `(Image) -> Bytes` | 编码单尺寸ICO（PNG载荷） |
| `encode_ico_sizes` | `(Array[Image]) -> Bytes` | 编码多尺寸ICO |
| `encode_icns` | `(Image) -> Bytes` | 编码ICNS（PNG载荷） |

### GIF/PNM 编码（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `encode_gif` | `(Image) -> Bytes` | 编码单帧GIF89a |
| `encode_gif_animation` | `(GifAnimation) -> Bytes` | 编码多帧GIF89a |
| `encode_ppm` | `(Image) -> Bytes` | 编码PPM (P6) |
| `encode_pgm` | `(Image) -> Bytes` | 编码PGM (P5) |

### 变换（7个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `crop` | `(Image, Int, Int, Int, Int) -> Image` | 裁剪区域 |
| `crop_16` | `(Image16, Int, Int, Int, Int) -> Image16` | 裁剪16位 |
| `cropf` | `(ImageF, Int, Int, Int, Int) -> ImageF` | 裁剪浮点 |
| `rotate_90` | `(Image) -> Image` | 顺时针旋转90° |
| `rotate_180` | `(Image) -> Image` | 旋转180° |
| `rotate_270` | `(Image) -> Image` | 顺时针旋转270° |
| `flip_horizontal` | `(Image) -> Image` | 水平翻转 |

### 色彩转换（5个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `to_grayscale` | `(Image) -> Image` | 转为灰度 |
| `to_rgb` | `(Image) -> Image` | 移除Alpha通道 |
| `to_rgba` | `(Image) -> Image` | 添加Alpha通道 |
| `premultiply_alpha` | `(Image) -> Image` | 预乘Alpha |
| `unpremultiply_alpha` | `(Image) -> Image` | 非预乘Alpha |

### 色彩调整（8个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `adjust_brightness` | `(Image, Int) -> Image` | 调整亮度（增量） |
| `adjust_contrast` | `(Image, Float) -> Image` | 调整对比度（因子） |
| `adjust_gamma` | `(Image, Float) -> Image` | 伽马校正 |
| `invert` | `(Image) -> Image` | 颜色反色 |
| `rgb_to_hsv` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB转HSV |
| `hsv_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSV转RGB |
| `rgb_to_hsl` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB转HSL |
| `hsl_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSL转RGB |

### 滤波器（6个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `box_blur` | `(Image, Int) -> Image` | 方框模糊（滑动窗口） |
| `gaussian_blur` | `(Image, Int, Float) -> Image` | 高斯模糊（可分离核） |
| `sharpen` | `(Image, Float) -> Image` | 锐化（拉普拉斯） |
| `edge_detect_sobel` | `(Image) -> Image` | Sobel边缘检测 |
| `edge_detect_laplacian` | `(Image) -> Image` | 拉普拉斯边缘检测 |
| `edge_detect_prewitt` | `(Image) -> Image` | Prewitt边缘检测 |

### 几何变换（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `warp_affine` | `(Image, (Float,Float,Float,Float,Float,Float), Int, Int) -> Image` | 仿射变换（双线性） |
| `rotate` | `(Image, Float) -> Image` | 任意角度旋转 |

### 直方图（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `histogram` | `(Image) -> Array[Int]` | 计算直方图（256箱） |
| `histogram_equalize` | `(Image) -> Image` | 直方图均衡化 |
| `histogram_normalize` | `(Image) -> Image` | 直方图归一化 |

### 量化（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `floyd_steinberg` | `(Image, Int) -> Image` | Floyd-Steinberg抖动 |
| `median_cut` | `(Image, Int) -> Image` | 中位切割量化 |

### 形态学（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `erode` | `(Image) -> Image` | 腐蚀（3x3最小值滤波） |
| `dilate` | `(Image) -> Image` | 膨胀（3x3最大值滤波） |
| `morph_open` | `(Image) -> Image` | 开运算（先腐蚀后膨胀） |
| `morph_close` | `(Image) -> Image` | 闭运算（先膨胀后腐蚀） |

### 质量评估（3个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `mse` | `(Image, Image) -> Double` | 均方误差 |
| `psnr` | `(Image, Image) -> Double` | 峰值信噪比（dB） |
| `ssim` | `(Image, Image) -> Double` | 结构相似性指数 [-1, 1] |

### 绘制（2个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `draw_copy` | `(Image, Image, Int, Int) -> Image` | 将源图复制到目标图(x,y)位置 |
| `draw_over` | `(Image, Image, Int, Int) -> Image` | 源图Alpha混合到目标图上方 |

### 元数据（4个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `read_exif_from_bytes` | `(Bytes) -> ExifInfo?` | 从JPEG字节读取EXIF |
| `read_exif_from_path` | `(String) -> ExifInfo?` | 从JPEG文件读取EXIF |
| `read_png_text_chunks` | `(Bytes) -> Array[PngTextChunk]` | 读取PNG tEXt/iTXt文本块 |
| `read_png_text_chunks_from_path` | `(String) -> Array[PngTextChunk]` | 从文件读取PNG文本块 |

### 查询（7个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `info_from_path` | `(String) -> ImageInfo?` | 从文件查询信息（不解码） |
| `info_from_bytes` | `(Bytes) -> ImageInfo?` | 从内存查询信息 |
| `is_16_bit_from_path` | `(String) -> Bool` | 检查是否16位 |
| `is_16_bit_from_bytes` | `(Bytes) -> Bool` | 检查是否16位 |
| `is_hdr_from_path` | `(String) -> Bool` | 检查是否HDR |
| `is_hdr_from_bytes` | `(Bytes) -> Bool` | 检查是否HDR |
| `failure_reason` | `() -> String` | 获取上次stb_image失败原因 |

### 配置（8个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `set_flip_vertically_on_load` | `(Bool) -> Unit` | 加载时垂直翻转 |
| `flip_vertically_on_write` | `(Bool) -> Unit` | 写入时垂直翻转 |
| `set_unpremultiply_on_load` | `(Bool) -> Unit` | 加载时非预乘Alpha |
| `convert_iphone_png_to_rgb` | `(Bool) -> Unit` | 将iPhone PNG转为RGB |
| `hdr_to_ldr_gamma` | `(Float) -> Unit` | HDR转LDR伽马（默认1.0） |
| `hdr_to_ldr_scale` | `(Float) -> Unit` | HDR转LDR缩放（默认1.0） |
| `ldr_to_hdr_gamma` | `(Float) -> Unit` | LDR转HDR伽马（默认1.0） |
| `ldr_to_hdr_scale` | `(Float) -> Unit` | LDR转HDR缩放（默认1.0） |

### 文件I/O（1个函数）

| 函数 | 签名 | 说明 |
|------|------|------|
| `read_file_bytes` | `(String) -> Bytes` | 读取原始文件字节 |

## 错误处理

```moonbit
try {
  let img = load_from_bytes(data)
  // 使用 img
} catch {
  LoadError::FileIO(msg) => println("文件IO错误: \{msg}")
  LoadError::DecodeFailed(msg) => println("解码失败: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("不支持的格式: \{msg}")
}
```

`UnsupportedFormat` 和 `DecodeFailed` 无法精确区分；stb_image 返回 NULL 时默认为 `DecodeFailed`。使用 `failure_reason()` 获取 stb_image 内部错误字符串。

## 架构

五包架构，依赖向下流动：

```
┌─────────────────────────────────────────────────────────────┐
│  根包           reexport.mbt（向后兼容API表面）             │
│                 bench.mbt, roundtrip_test.mbt               │
├─────────────────────────────────────────────────────────────┤
│  子包           core/    process/  format/  meta/  util/    │
│                 FFI类型   图像操作   编解码  EXIF  工具函数 │
├─────────────────────────────────────────────────────────────┤
│  FFI边界        core/ffi.mbt (extern "c")                   │
│                 core/wrapper.c (ABI标准化)                  │
├─────────────────────────────────────────────────────────────┤
│  第三方代码     core/stb_image.h v2.30                      │
│                 core/stb_image_write.h v1.16                │
│                 core/stb_image_resize2.h v2.07              │
└─────────────────────────────────────────────────────────────┘
```

## 目标平台支持

**仅支持 Native。** 多目标（wasm/js）已评估但暂缓：
- 需要 Emscripten 构建链 + `extern "wasm"` / `extern "js"` FFI
- 类型定义（`Image`、`Image16`、`ImageF`、`ImageInfo`、`GifAnimation`、`LoadError`）与目标无关

## 限制

- **I/O回调**（`stbi_io_callbacks`）：未实现。MoonBit FFI 不支持将闭包作为C函数指针传递（`moonbit.h` 中无闭包调用API）。
- **零拷贝**：未实现。所有加载路径通过 `memcpy` 将像素数据从C缓冲区复制到MoonBit `Bytes`。零拷贝需要GC边界分析。
- **多目标**：暂缓（见上文）。

## 构建与测试

```bash
# 检查编译
moon check --target native

# 运行测试
moon test --target native

# 运行基准测试
moon bench --target native

# 运行ASan验证（需要VS开发者环境）
python scripts/run-asan.py --repo-root . --pkg src/moon.pkg --no-disable-mimalloc

# 重新生成API接口
moon info  # 输出 src/pkg.generated.mbti
```

## 项目结构

```
stb-image/
├── moon.mod                  # 模块配置 (v1.10.0, preferred_target = native)
├── ROADMAP.md                # 迭代路线图
├── COMPARISON.md             # mooncakes.io 图像库对比
├── SKILL.md                  # 包使用指南
├── src/
│   ├── moon.pkg              # 根包：re-export + 基准测试 + 往返测试
│   ├── reexport.mbt          # 向后兼容API（128 pub fn + 12 类型）
│   ├── bench.mbt             # 29个性能基准测试
│   ├── roundtrip_test.mbt    # 全格式往返测试
│   ├── core/                 # 核心：类型 + FFI + 加载/写入/缩放 + 检测 + ICO
│   │   ├── moon.pkg          # native-stub: wrapper.c
│   │   ├── image_types.mbt   # Image, Image16, ImageF, ImageInfo, GifAnimation, LoadError
│   │   ├── ffi.mbt           # 私有 extern "c" 声明
│   │   ├── wrapper.c         # C FFI 包装器（ABI标准化）
│   │   ├── stb_image*.h      # 第三方上游头文件
│   │   ├── image_*_native.mbt# load/write/resize/info/gif/16/float
│   │   ├── image_detect.mbt  # detect_format/decode_any/is_supported_format
│   │   ├── icon_encode.mbt   # encode_ico/encode_ico_sizes/encode_icns
│   │   └── *_test.mbt        # 核心测试
│   ├── process/              # 图像处理（纯MoonBit）
│   │   ├── moon.pkg          # 导入 @core
│   │   ├── transform.mbt     # crop/rotate_*/flip_horizontal
│   │   ├── color_convert.mbt # to_grayscale/to_rgb/to_rgba/premultiply
│   │   ├── color_adjust.mbt  # adjust_*/invert/rgb_to_hsv/hsv_to_rgb/...
│   │   ├── filter.mbt        # box_blur/gaussian_blur/sharpen/edge_detect_sobel
│   │   ├── geometry.mbt      # warp_affine/rotate
│   │   ├── histogram.mbt     # histogram/equalize/normalize
│   │   ├── quantize.mbt      # floyd_steinberg/median_cut
│   │   ├── draw.mbt          # draw_copy/draw_over
│   │   ├── morphology.mbt    # erode/dilate/morph_open/morph_close
│   │   ├── edge_detect.mbt   # edge_detect_laplacian/edge_detect_prewitt
│   │   ├── image_quality.mbt # mse/psnr/ssim
│   │   └── *_test.mbt        # 处理测试
│   ├── format/               # 格式编解码（纯MoonBit）
│   │   ├── moon.pkg          # 导入 @core
│   │   ├── qoi.mbt           # decode_qoi/encode_qoi
│   │   ├── gif_encode.mbt    # encode_gif/encode_gif_animation
│   │   ├── pnm_encode.mbt    # encode_ppm/encode_pgm/encode_pnm
│   │   └── *_test.mbt        # 格式测试
│   ├── meta/                 # 元数据（纯MoonBit）
│   │   ├── moon.pkg          # 导入 @core
│   │   ├── exif.mbt          # read_exif_from_bytes/read_exif_from_path
│   │   ├── png_meta.mbt      # read_png_text_chunks/...
│   │   └── *_test.mbt        # 元数据测试
│   └── util/                 # 工具函数（纯MoonBit）
│       ├── moon.pkg          # 导入 @core, @process
│       ├── image_util.mbt    # pad/border/resize_to_cover/contain/pixelate/...
│       ├── pixel_ops.mbt     # threshold/posterize/extract_channel/swap_channels
│       ├── pixel_advanced.mbt# set_alpha/fill_alpha/replace_color/apply_lut
│       ├── image_stats.mbt   # compute_stats/mean_value
│       ├── image_compose.mbt # hstack/vstack/tile/flip_vertical/transpose
│       ├── image_noise.mbt   # add_noise_gaussian/add_noise_salt_pepper
│       ├── color_map.mbt     # gradient_map/blend_*
│       └── *_test.mbt        # 工具测试
├── scripts/
│   ├── prepare.py            # 第三方代码准备脚本
│   ├── gen_testdata.py       # 测试图像生成器
│   ├── run-asan.py           # ASan验证
│   └── gen_reexport.py       # Re-export文件生成器
└── testdata/                 # 测试图像（PNG/BMP/GIF/JPG + 损坏文件）
```

## 版本历史

| 版本 | 亮点 | 测试 |
|------|------|------|
| v0.1 | 8位加载（路径+内存），9种格式 | 23 |
| v0.2 | 写入（PNG/BMP/TGA/JPEG）+ req_channels + 翻转 | 32 |
| v0.3 | 16位/浮点加载 + 信息查询 + failure_reason + 配置 | 55 |
| v0.4 | HDR配置 + 动画GIF | 61 |
| v1.0 | API冻结，完整文档，ASan验证 | 61 |
| v1.1 | HDR写入 + 缩放（FFI stb_image_resize2.h） | 75 |
| v1.2 | QOI/ICO/ICNS/GIF编码 + 格式自动检测 | 114 |
| v1.3 | 裁剪/旋转/翻转 + 色彩转换 + 绘制/合成 | 145 |
| v1.4 | 色彩调整 + 滤波器 + 几何 + 直方图 + 量化 | 206 |
| v1.5 | PNM编码 + GIF动画 + EXIF读取 | 229 |
| **v1.6** | **PNG元数据 + 往返测试 + 基准测试** | **254+29** |
| **v1.7** | **pad/border/resize_to_cover/contain + threshold/posterize/extract_channel + 混合模式** | **275+29** |
| **v1.8** | **更多混合模式 + 统计 + pixelate/replace_color/convolve/swap_channels** | **292+29** |
| **v1.9** | **hstack/vstack/tile/transpose + 噪声 + LUT/gradient_map + Alpha操作** | **315+29** |
| **v1.10** | **形态学(erode/dilate/open/close) + Laplacian/Prewitt边缘 + MSE/PSNR/SSIM** | **341+29** |

## 上游

- [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) — 提交 `013ac3beddff3dbffafd5177e7972067cd2b5083` (v2.30)
- [stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) — 同一提交 (v1.16)
- [stb_image_resize2.h](https://github.com/nothings/stb/blob/master/stb_image_resize2.h) — v2.07

## 许可证

MIT 许可证 — 详见 [LICENSE](LICENSE)。

stb_image.h、stb_image_write.h 和 stb_image_resize2.h 属于公共领域（Sean Barrett）。