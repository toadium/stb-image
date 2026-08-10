# image

MoonBit 纯图像处理库 — 解码/编码 PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM，提供从基础像素操作到高级计算机视觉算法的完整能力。纯 MoonBit 实现，零 C FFI 依赖，native/wasm-gc/js 三目标共用同一代码库。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/tests-1056%20%C3%97%203%20targets-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-89.8%25-brightgreen)]()
[![API](https://img.shields.io/badge/API-197%20fn%20%2B%2028%20types-blueviolet)]()

## Quick Start

```moonbit nocheck
// Decode from memory
let img : Image = load_from_bytes(png_bytes)
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// Decode with forced RGBA
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// Encode to PNG bytes
let out : Bytes = write_png_to_bytes(img)

// Auto-detect format and decode
let any : Image = decode_any(data, req_channels=Some(3))

// Resize (7 filters × 4 edge modes)
let resized : Image = resize(img, 128, 128)

// Load animated GIF
let anim : GifAnimation = load_gif_from_bytes(gif_bytes)
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// Query image info without decoding pixels
let info : ImageInfo? = info_from_bytes(data)
```

## Format Support

| Format | Decode | Encode | Notes |
|:------:|:------:|:------:|-------|
| PNG | ✅ | ✅ | 8/16-bit, Adam7 interlace |
| JPEG | ✅ | ✅ | baseline, adjustable quality |
| BMP | ✅ | ✅ | 1/4/8/16/24/32-bit |
| GIF | ✅ | ✅ | animated GIF decode/encode |
| QOI | ✅ | ✅ | Quite OK Image |
| TGA | ✅ | ✅ | with RLE |
| PSD | ✅ | — | Photoshop document |
| HDR | ✅ | ✅ | IEEE 754 float |
| PNM | ✅ | ✅ | PPM / PGM |
| TIFF | ✅ | ✅ | uncompressed/LZW/PackBits |
| ICO | ✅ | ✅ | single/multi-size |
| CUR | ✅ | ✅ | Windows cursor |
| ICNS | ✅ | ✅ | macOS icon |
| APNG | ✅ | ✅ | animated PNG |

## Types

| Type | Description |
|------|-------------|
| `Image { width, height, channels, data : Bytes }` | 8-bit decoded image |
| `Image16 { width, height, channels, data : Bytes }` | 16-bit decoded image (UInt16 little-endian) |
| `ImageF { width, height, channels, data : Bytes }` | HDR float decoded image (IEEE 754 little-endian) |
| `ImageInfo { width, height, channels }` | Image info without pixel data |
| `GifAnimation { frames : Array[Image], delays : Array[Int] }` | Animated GIF (frames + delays in ms) |
| `SuperpixelResult { labels, centers, num_labels }` | SLIC superpixel segmentation result |
| `LoadError { FileIO, UnsupportedFormat, DecodeFailed }` | Load failure error |

## Load API

| Function | Description |
|----------|-------------|
| `load_from_bytes(data, req_channels?) -> Image` | Load 8-bit from memory |
| `load_16_from_bytes(data, req_channels?) -> Image16` | Load 16-bit from memory |
| `loadf_from_bytes(data, req_channels?) -> ImageF` | Load HDR float from memory |
| `load_gif_from_bytes(data, req_channels?) -> GifAnimation` | Load animated GIF from memory |
| `decode_any(data, req_channels?) -> Image` | Auto-detect format and decode |
| `detect_format(data) -> ImageFormat` | Detect image format |
| `is_supported_format(data) -> Bool` | Check if format is supported |

## Write API

| Function | Description |
|----------|-------------|
| `write_png_to_bytes(img) -> Bytes` | Encode PNG |
| `write_bmp_to_bytes(img) -> Bytes` | Encode BMP |
| `write_tga_to_bytes(img) -> Bytes` | Encode TGA |
| `write_jpeg_to_bytes(img, quality?) -> Bytes` | Encode JPEG (quality default 90) |
| `write_hdr_to_bytes(img) -> Bytes` | Encode HDR |
| `encode_qoi(img) -> Bytes` | Encode QOI |
| `encode_gif(img) -> Bytes` | Encode GIF |
| `encode_gif_animation(anim) -> Bytes` | Encode animated GIF |
| `encode_pnm(img) -> Bytes` | Encode PNM |
| `encode_pgm(img) -> Bytes` | Encode PGM |
| `encode_ppm(img) -> Bytes` | Encode PPM |

## Query API

| Function | Description |
|----------|-------------|
| `info_from_bytes(data) -> ImageInfo?` | Query image info without decoding |
| `is_16_bit_from_bytes(data) -> Bool` | Check if image is 16-bit |
| `is_hdr_from_bytes(data) -> Bool` | Check if image is HDR |
| `failure_reason() -> String` | Get last failure reason |

## Resize API

| Function | Description |
|----------|-------------|
| `resize(img, w, h) -> Image` | Resize with 7 filters × 4 edge modes |

Filters: `Nearest`, `Bilinear`, `Bicubic`, `CatmullRom`, `Mitchell`, `Lanczos3`, `Gaussian`
Edge modes: `Zero`, `Clamp`, `Reflect`, `Wrap`

## Image Processing API (selected)

| Category | Functions |
|----------|-----------|
| Geometry | `crop`, `rotate_90`, `rotate_180`, `rotate_270`, `rotate`, `flip_horizontal`, `warp_affine` |
| Color | `to_grayscale`, `to_rgb`, `to_rgba`, `adjust_brightness`, `adjust_contrast`, `adjust_gamma`, `invert`, `premultiply_alpha` |
| Filter | `gaussian_blur`, `box_blur`, `sharpen`, `edge_detect_sobel`, `bilateral_filter`, `nlm_denoise` |
| Histogram | `histogram`, `histogram_equalize`, `histogram_normalize` |
| Morphology | `erode`, `dilate`, `morph_open`, `morph_close`, `skeletonize` |
| Quality | `mse`, `psnr`, `ssim` |
| Draw | `draw_copy`, `draw_over` |
| EXIF | `read_exif_from_bytes`, `write_exif_to_bytes`, `create_exif_segment` |
| Seam Carving | `seam_carve_resize`, `compute_energy`, `find_vertical_seam`, `remove_vertical_seam` |
| 16-bit/float | `rotate_90_16`, `rotate_90f`, `flip_horizontal_16`, `flip_horizontalf`, `adjust_brightness_16`, `adjust_brightnessf` |

## Advanced Analysis API (selected)

| Category | Functions |
|----------|-----------|
| CLAHE | `clahe` |
| Segmentation | `k_means_quantize`, `region_growing_segment`, `flood_fill`, `watershed`, `watershed_auto`, `slic` |
| FFT | `fft_2d`, `ifft_2d`, `fft_shift`, `fft_magnitude`, `freq_filter`, `freq_filter_gaussian` |
| Edge | `canny_edge`, `hough_lines`, `hough_lines_nms`, `find_contours`, `harris_corners` |
| Threshold | `adaptive_threshold_mean`, `adaptive_threshold_gaussian`, `threshold_otsu` |
| Connected Components | `connected_components` |
| Integral Image | `integral_image`, `integral_sum`, `integral_mean`, `integral_variance` |
| LBP | `lbp`, `lbp_uniform` |
| Pyramid | `build_gaussian_pyramid`, `build_laplacian_pyramid`, `pyr_down`, `pyr_up` |
| Wavelet | `haar_transform_1d`, `haar_transform_2d`, `haar_denoise` |
| Texture (GLCM) | `compute_glcm`, `glcm_features`, `glcm_features_multi_direction` |
| Retinex | `ssr`, `msr`, `msrcr` |
| Dehaze | `dehaze` |
| Gabor | `gabor_filter`, `gabor_filter_bank`, `gabor_kernel` |
| Distance Transform | `distance_transform`, `skeletonize` |

## Config API

| Function | Description |
|----------|-------------|
| `set_flip_vertically_on_load(Bool)` | Flip on load |
| `flip_vertically_on_write(Bool)` | Flip on write |
| `set_unpremultiply_on_load(Bool)` | Unpremultiply alpha on load |
| `convert_iphone_png_to_rgb(Bool)` | Convert iPhone PNG to RGB |
| `hdr_to_ldr_gamma(Float)` | HDR→LDR gamma |
| `hdr_to_ldr_scale(Float)` | HDR→LDR scale |
| `ldr_to_hdr_gamma(Float)` | LDR→HDR gamma |
| `ldr_to_hdr_scale(Float)` | LDR→HDR scale |

## Error Handling

```moonbit nocheck
try {
  let img = load_from_bytes(data)
} catch {
  LoadError::FileIO(msg) => println("file io error: \{msg}")
  LoadError::DecodeFailed(msg) => println("decode failed: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("unsupported: \{msg}")
}
```

## Multi-Target Support

Supports **native / wasm-gc / js** targets. Pure MoonBit implementation, no C FFI dependency. 1056 tests pass on all three targets, 89.8% coverage.

## Version History

- **v0.1**: 8-bit load (path + bytes), 9 formats
- **v0.2**: write (PNG/BMP/TGA/JPEG) + req_channels + flip
- **v0.3**: 16-bit/float load + info + is_16_bit/is_hdr + failure_reason + config
- **v0.4**: HDR config + animated GIF
- **v1.0**: API freeze, complete documentation, 61 tests
- **v2.0**: 纯 MoonBit 重构 — 移除所有 C FFI，三目标支持，pure 拆分为 5 子包，174 API + 27 类型，872 测试，89.8% 覆盖率
- **v2.1**: 中值滤波/形态学补全/色彩空间/绘图/伪彩色/哈希
- **v2.2**: 透视变换/轮廓分析/霍夫圆/DCT/色调映射
- **v2.3**: TIFF/ICO/CUR/ICNS/APNG 格式扩展
- **v3.0**: EXIF 写入/seam carving/SLIC 超像素/16-bit float 操作泛化，197 API + 28 类型，1056 测试
