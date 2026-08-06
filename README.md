# stb-image

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-native-blue)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/tests-275%20passed-brightgreen)]()
[![Bench](https://img.shields.io/badge/bench-29%20passed-brightgreen)]()
[![ASan](https://img.shields.io/badge/ASan-passed-brightgreen)]()

MoonBit native FFI bindings for [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16 + [stb_image_resize2.h](https://github.com/nothings/stb) v2.07.

Full image decode/encode/resize/process capability: 8-bit/16-bit/float load, animated GIF, info query, write PNG/BMP/TGA/JPEG/HDR, resize, format detection, QOI/ICO/ICNS/GIF/PNM codec, EXIF/PNG metadata, image processing (crop/rotate/flip/color/filter/histogram/quantize), roundtrip tests, performance benchmarks.

## Features

- **10+ formats decode**: PNG, JPEG, BMP, GIF, PSD, TGA, HDR, PIC, WebP, PNM (PPM/PGM), QOI
- **8 formats encode**: PNG, BMP, TGA, JPEG, HDR, QOI, GIF, PNM (PPM/PGM)
- **3 pixel types**: 8-bit (`Image`), 16-bit (`Image16`), HDR float (`ImageF`)
- **Resize**: 7 filters × 4 edge modes, 8-bit/16-bit/float/sRGB
- **Format detection**: `detect_format` / `decode_any` / `is_supported_format`
- **Image processing**: crop, rotate, flip, color convert, draw/compositing
- **Color adjustment**: brightness, contrast, gamma, invert, HSV/HSL conversion
- **Filters**: box blur, gaussian blur, sharpen, Sobel edge detect
- **Geometry**: affine warp, arbitrary angle rotate
- **Histogram**: compute, equalize, normalize
- **Quantize**: Floyd-Steinberg dithering, median cut
- **Metadata**: EXIF reading, PNG text chunks
- **Animated GIF**: multi-frame decode/encode with per-frame delays
- **Info query**: dimensions without decoding pixels
- **Configurable**: flip, unpremultiply alpha, iPhone PNG, HDR gamma/scale
- **Failure diagnostics**: `failure_reason()` exposes stb_image internal error string
- **254 tests + 29 benchmarks**, all passing under AddressSanitizer

## Installation

```bash
moon add MoonBit-Toadium/stb-image
```

## Quick Start

```moonbit
// Decode from file
let img : Image = load_from_path("photo.png")
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// Decode from memory with forced RGBA
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// Encode to PNG bytes
let out : Bytes = write_png_to_bytes(img)

// Resize with default filter
let resized : Image = resize(img, 128, 128)

// Auto-detect format and decode
let any : Image = decode_any(data, req_channels=Some(3))

// Load animated GIF
let anim : GifAnimation = load_gif_from_path("animation.gif")
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// Read EXIF metadata
let exif : ExifInfo? = read_exif_from_path("photo.jpg")

// Query image info without decoding
let info : ImageInfo? = info_from_path("large.hdr")
```

## Types

| Type | Fields | Description |
|------|--------|-------------|
| `Image` | `width, height, channels : Int; data : Bytes` | 8-bit decoded image |
| `Image16` | `width, height, channels : Int; data : Bytes` | 16-bit decoded image (UInt16 LE, 2 bytes/pixel) |
| `ImageF` | `width, height, channels : Int; data : Bytes` | HDR float decoded image (IEEE 754 LE, 4 bytes/pixel) |
| `ImageInfo` | `width, height, channels : Int` | Image info without pixel data |
| `GifAnimation` | `frames : Array[Image]; delays : Array[Int]` | Animated GIF (delays in milliseconds) |
| `LoadError` | `FileIO(String) \| UnsupportedFormat(String) \| DecodeFailed(String)` | Load failure error |
| `ImageFormat` | `Png \| Jpeg \| Bmp \| Gif \| Tga \| Psd \| Hdr \| Pnm \| Qoi \| Unknown` | Image format enum |
| `ResizeFilter` | `Default \| Box \| Triangle \| CubicBSPline \| CatmullROM \| Mitchell \| PointSample` | Resize filter enum |
| `ResizeEdge` | `Clamp \| Reflect \| Wrap \| Zero` | Resize edge mode enum |
| `ExifInfo` | `make, model, date_time : String; orientation : Int` | EXIF metadata |
| `PngTextChunk` | `keyword, text : String` | PNG tEXt/iTXt chunk |

All types derive `Eq` and `@debug.Debug`.

## API Reference

### Load (8 functions)

All load functions accept optional `req_channels : Int?` (1=gray, 2=gray+alpha, 3=RGB, 4=RGBA). Pass `None` for original channels.

| Function | Signature | Returns |
|----------|-----------|---------|
| `load_from_path` | `(String, req_channels?: Int?) -> Image` | 8-bit from file |
| `load_from_bytes` | `(Bytes, req_channels?: Int?) -> Image` | 8-bit from memory |
| `load_16_from_path` | `(String, req_channels?: Int?) -> Image16` | 16-bit from file |
| `load_16_from_bytes` | `(Bytes, req_channels?: Int?) -> Image16` | 16-bit from memory |
| `loadf_from_path` | `(String, req_channels?: Int?) -> ImageF` | HDR float from file |
| `loadf_from_bytes` | `(Bytes, req_channels?: Int?) -> ImageF` | HDR float from memory |
| `load_gif_from_path` | `(String, req_channels?: Int?) -> GifAnimation` | Animated GIF from file |
| `load_gif_from_bytes` | `(Bytes, req_channels?: Int?) -> GifAnimation` | Animated GIF from memory |

### Write (10 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `write_png_to_path` | `(String, Image) -> Unit` | Write PNG to file |
| `write_bmp_to_path` | `(String, Image) -> Unit` | Write BMP to file |
| `write_tga_to_path` | `(String, Image) -> Unit` | Write TGA to file |
| `write_jpeg_to_path` | `(String, Image, quality?: Int) -> Unit` | Write JPEG (quality default 90) |
| `write_hdr_to_path` | `(String, ImageF) -> Unit` | Write HDR to file |
| `write_png_to_bytes` | `(Image) -> Bytes` | Encode PNG to bytes |
| `write_bmp_to_bytes` | `(Image) -> Bytes` | Encode BMP to bytes |
| `write_tga_to_bytes` | `(Image) -> Bytes` | Encode TGA to bytes |
| `write_jpeg_to_bytes` | `(Image, quality?: Int) -> Bytes` | Encode JPEG to bytes |
| `write_hdr_to_bytes` | `(ImageF) -> Bytes` | Encode HDR to bytes |

### Resize (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `resize` | `(Image, Int, Int, filter?: ResizeFilter, edge?: ResizeEdge) -> Image` | 8-bit resize |
| `resize_srgb` | `(Image, Int, Int, filter?, edge?) -> Image` | sRGB colorspace resize |
| `resize_16` | `(Image16, Int, Int, filter?, edge?) -> Image16` | 16-bit resize |
| `resizef` | `(ImageF, Int, Int, filter?, edge?) -> ImageF` | Float resize |

### Format Detection (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `detect_format` | `(Bytes) -> ImageFormat` | Detect format from magic bytes |
| `decode_any` | `(Bytes, req_channels?: Int?) -> Image` | Auto-detect and decode |
| `is_supported_format` | `(Bytes) -> Bool` | Check if format is supported |

### QOI Codec (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `decode_qoi` | `(Bytes) -> Image` | Decode QOI format |
| `encode_qoi` | `(Image) -> Bytes` | Encode QOI format |

### ICO/ICNS Encode (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `encode_ico` | `(Image) -> Bytes` | Encode single ICO (PNG payload) |
| `encode_ico_sizes` | `(Array[Image]) -> Bytes` | Encode multi-size ICO |
| `encode_icns` | `(Image) -> Bytes` | Encode ICNS (PNG payload) |

### GIF/PNM Encode (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `encode_gif` | `(Image) -> Bytes` | Encode single-frame GIF89a |
| `encode_gif_animation` | `(GifAnimation) -> Bytes` | Encode multi-frame GIF89a |
| `encode_ppm` | `(Image) -> Bytes` | Encode PPM (P6) |
| `encode_pgm` | `(Image) -> Bytes` | Encode PGM (P5) |

### Transform (7 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `crop` | `(Image, Int, Int, Int, Int) -> Image` | Crop region |
| `crop_16` | `(Image16, Int, Int, Int, Int) -> Image16` | Crop 16-bit |
| `cropf` | `(ImageF, Int, Int, Int, Int) -> ImageF` | Crop float |
| `rotate_90` | `(Image) -> Image` | Rotate 90° clockwise |
| `rotate_180` | `(Image) -> Image` | Rotate 180° |
| `rotate_270` | `(Image) -> Image` | Rotate 270° clockwise |
| `flip_horizontal` | `(Image) -> Image` | Flip horizontally |

### Color Conversion (5 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `to_grayscale` | `(Image) -> Image` | Convert to grayscale |
| `to_rgb` | `(Image) -> Image` | Remove alpha channel |
| `to_rgba` | `(Image) -> Image` | Add alpha channel |
| `premultiply_alpha` | `(Image) -> Image` | Premultiply alpha |
| `unpremultiply_alpha` | `(Image) -> Image` | Unpremultiply alpha |

### Color Adjustment (8 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `adjust_brightness` | `(Image, Int) -> Image` | Adjust brightness by delta |
| `adjust_contrast` | `(Image, Float) -> Image` | Adjust contrast by factor |
| `adjust_gamma` | `(Image, Float) -> Image` | Apply gamma correction |
| `invert` | `(Image) -> Image` | Invert colors |
| `rgb_to_hsv` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB to HSV |
| `hsv_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSV to RGB |
| `rgb_to_hsl` | `(Int, Int, Int) -> (Float, Float, Float)` | RGB to HSL |
| `hsl_to_rgb` | `(Float, Float, Float) -> (Int, Int, Int)` | HSL to RGB |

### Filters (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `box_blur` | `(Image, Int) -> Image` | Box blur (sliding window) |
| `gaussian_blur` | `(Image, Int, Float) -> Image` | Gaussian blur (separable kernel) |
| `sharpen` | `(Image, Float) -> Image` | Sharpen (Laplacian) |
| `edge_detect_sobel` | `(Image) -> Image` | Sobel edge detection |

### Geometry (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `warp_affine` | `(Image, (Float,Float,Float,Float,Float,Float), Int, Int) -> Image` | Affine warp (bilinear) |
| `rotate` | `(Image, Float) -> Image` | Rotate by arbitrary angle |

### Histogram (3 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `histogram` | `(Image) -> Array[Int]` | Compute histogram (256 bins) |
| `histogram_equalize` | `(Image) -> Image` | Histogram equalization |
| `histogram_normalize` | `(Image) -> Image` | Histogram normalization |

### Quantize (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `floyd_steinberg` | `(Image, Int) -> Image` | Floyd-Steinberg dithering |
| `median_cut` | `(Image, Int) -> Image` | Median cut quantization |

### Draw (2 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_copy` | `(Image, Image, Int, Int) -> Image` | Copy src onto dst at (x,y) |
| `draw_over` | `(Image, Image, Int, Int) -> Image` | Alpha blend src over dst |

### Metadata (4 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `read_exif_from_bytes` | `(Bytes) -> ExifInfo?` | Read EXIF from JPEG bytes |
| `read_exif_from_path` | `(String) -> ExifInfo?` | Read EXIF from JPEG file |
| `read_png_text_chunks` | `(Bytes) -> Array[PngTextChunk]` | Read PNG tEXt/iTXt chunks |
| `read_png_text_chunks_from_path` | `(String) -> Array[PngTextChunk]` | Read PNG text chunks from file |

### Query (7 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `info_from_path` | `(String) -> ImageInfo?` | Query info from file (no decode) |
| `info_from_bytes` | `(Bytes) -> ImageInfo?` | Query info from memory |
| `is_16_bit_from_path` | `(String) -> Bool` | Check if 16-bit |
| `is_16_bit_from_bytes` | `(Bytes) -> Bool` | Check if 16-bit |
| `is_hdr_from_path` | `(String) -> Bool` | Check if HDR |
| `is_hdr_from_bytes` | `(Bytes) -> Bool` | Check if HDR |
| `failure_reason` | `() -> String` | Get last stb_image failure reason |

### Config (8 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `set_flip_vertically_on_load` | `(Bool) -> Unit` | Flip vertically on load |
| `flip_vertically_on_write` | `(Bool) -> Unit` | Flip vertically on write |
| `set_unpremultiply_on_load` | `(Bool) -> Unit` | Unpremultiply alpha on load |
| `convert_iphone_png_to_rgb` | `(Bool) -> Unit` | Convert iPhone PNG to RGB |
| `hdr_to_ldr_gamma` | `(Float) -> Unit` | HDR to LDR gamma (default 1.0) |
| `hdr_to_ldr_scale` | `(Float) -> Unit` | HDR to LDR scale (default 1.0) |
| `ldr_to_hdr_gamma` | `(Float) -> Unit` | LDR to HDR gamma (default 1.0) |
| `ldr_to_hdr_scale` | `(Float) -> Unit` | LDR to HDR scale (default 1.0) |

### File I/O (1 function)

| Function | Signature | Description |
|----------|-----------|-------------|
| `read_file_bytes` | `(String) -> Bytes` | Read raw file bytes |

## Error Handling

```moonbit
try {
  let img = load_from_bytes(data)
  // use img
} catch {
  LoadError::FileIO(msg) => println("file IO error: \{msg}")
  LoadError::DecodeFailed(msg) => println("decode failed: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("unsupported format: \{msg}")
}
```

`UnsupportedFormat` and `DecodeFailed` are not precisely distinguishable; stb_image returning NULL defaults to `DecodeFailed`. Use `failure_reason()` for the internal stb_image error string.

## Architecture

Four-layer architecture, dependencies flow downward:

```
┌─────────────────────────────────────────────────────┐
│  Test & Docs    *_test.mbt (254 tests + 29 bench)  │
│                  roundtrip_test.mbt, bench.mbt      │
│                  README.mbt.md, SKILL.md            │
├─────────────────────────────────────────────────────┤
│  Safe API       image_*_native.mbt (pub fn)         │
│                  transform/color/filter/geometry    │
│                  histogram/quantize/exif/png_meta   │
│                  qoi/icon_encode/gif_encode         │
│                  pnm_encode/image_detect/draw       │
│                  image_types.mbt (types)            │
├─────────────────────────────────────────────────────┤
│  FFI Boundary   ffi.mbt (extern "c")                │
│                  wrapper.c (ABI normalization)      │
├─────────────────────────────────────────────────────┤
│  Vendoring      stb_image.h v2.30                   │
│                  stb_image_write.h v1.16            │
│                  stb_image_resize2.h v2.07          │
│                  scripts/prepare.py                 │
└─────────────────────────────────────────────────────┘
```

## Target Support

**Native only.** Multi-target (wasm/js) evaluated and deferred:
- Requires Emscripten build chain + `extern "wasm"` / `extern "js"` FFI
- Type definitions (`Image`, `Image16`, `ImageF`, `ImageInfo`, `GifAnimation`, `LoadError`) are target-agnostic

## Limitations

- **I/O callbacks** (`stbi_io_callbacks`): not implemented. MoonBit FFI does not support passing closures as C function pointers (no closure invocation API in `moonbit.h`).
- **Zero-copy**: not implemented. All load paths copy pixel data from C buffer to MoonBit `Bytes` via `memcpy`. Zero-copy would require GC boundary analysis.
- **Multi-target**: deferred (see above).

## Build & Test

```bash
# Check compilation
moon check --target native

# Run tests
moon test --target native

# Run benchmarks
moon bench --target native

# Run ASan validation (requires VS Developer environment)
python scripts/run-asan.py --repo-root . --pkg src/moon.pkg --no-disable-mimalloc

# Regenerate API interface
moon info  # outputs src/pkg.generated.mbti
```

## Project Structure

```
stb-image/
├── moon.mod                  # Module config (v1.6.0, preferred_target = native)
├── ROADMAP.md                # Iteration roadmap
├── COMPARISON.md             # mooncakes.io image library comparison
├── SKILL.md                  # Package usage guide
├── src/
│   ├── moon.pkg              # Package config (native-stub, targets gating)
│   ├── wrapper.c             # C FFI wrapper (ABI normalization)
│   ├── stb_image.h           # Vendored upstream v2.30
│   ├── stb_image_write.h     # Vendored upstream v1.16
│   ├── stb_image_resize2.h   # Vendored upstream v2.07
│   ├── ffi.mbt               # Private extern "c" declarations
│   ├── image_types.mbt       # Image, Image16, ImageF, ImageInfo, GifAnimation, LoadError
│   ├── image_load_native.mbt # load_from_path/bytes
│   ├── image_write_native.mbt# write_*_to_path/bytes, flip, HDR write
│   ├── image_16_native.mbt   # load_16_from_path/bytes
│   ├── image_float_native.mbt# loadf_from_path/bytes
│   ├── image_info_native.mbt # info, is_16_bit, is_hdr, failure_reason, config
│   ├── image_gif_native.mbt  # load_gif_from_path/bytes
│   ├── image_resize_native.mbt# resize/resize_srgb/resize_16/resizef
│   ├── image_detect.mbt      # detect_format/decode_any/is_supported_format
│   ├── qoi.mbt               # decode_qoi/encode_qoi
│   ├── icon_encode.mbt       # encode_ico/encode_ico_sizes/encode_icns
│   ├── gif_encode.mbt        # encode_gif/encode_gif_animation
│   ├── pnm_encode.mbt        # encode_ppm/encode_pgm/encode_pnm
│   ├── transform.mbt         # crop/crop_16/cropf/rotate_*/flip_horizontal
│   ├── color_convert.mbt     # to_grayscale/to_rgb/to_rgba/premultiply/unpremultiply
│   ├── color_adjust.mbt      # adjust_*/invert/rgb_to_hsv/hsv_to_rgb/rgb_to_hsl/hsl_to_rgb
│   ├── filter.mbt            # box_blur/gaussian_blur/sharpen/edge_detect_sobel
│   ├── geometry.mbt          # warp_affine/rotate
│   ├── histogram.mbt         # histogram/histogram_equalize/histogram_normalize
│   ├── quantize.mbt          # floyd_steinberg/median_cut
│   ├── draw.mbt              # draw_copy/draw_over
│   ├── exif.mbt              # read_exif_from_bytes/read_exif_from_path
│   ├── png_meta.mbt          # read_png_text_chunks/read_png_text_chunks_from_path
│   ├── file_io_native.mbt    # read_file_bytes
│   ├── *_test.mbt            # 254 tests
│   ├── roundtrip_test.mbt    # Full format roundtrip tests
│   ├── bench.mbt             # 29 performance benchmarks
│   ├── README.mbt.md         # MoonBit doc-test
│   └── pkg.generated.mbti    # Frozen API interface (88 pub fn + 11 types)
├── scripts/
│   ├── prepare.py            # Vendoring script
│   ├── gen_testdata.py       # Test image generator
│   └── run-asan.py           # ASan validation
└── testdata/                 # Test images (PNG/BMP/GIF/JPG + corrupt)
```

## Version History

| Version | Highlights | Tests |
|---------|-----------|-------|
| v0.1 | 8-bit load (path + bytes), 9 formats | 23 |
| v0.2 | write (PNG/BMP/TGA/JPEG) + req_channels + flip | 32 |
| v0.3 | 16-bit/float load + info + failure_reason + config | 55 |
| v0.4 | HDR config + animated GIF | 61 |
| v1.0 | API freeze, complete docs, ASan verified | 61 |
| v1.1 | HDR write + resize (FFI stb_image_resize2.h) | 75 |
| v1.2 | QOI/ICO/ICNS/GIF encode + format auto-detect | 114 |
| v1.3 | crop/rotate/flip + color convert + draw/compositing | 145 |
| v1.4 | color adjust + filters + geometry + histogram + quantize | 206 |
| v1.5 | PNM encode + GIF animation + EXIF reading | 229 |
| **v1.6** | **PNG metadata + roundtrip tests + benchmarks** | **254+29** |
| **v1.7** | **pad/border/resize_to_cover/contain + threshold/posterize/extract_channel + blend modes** | **275+29** |

## Upstream

- [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) — commit `013ac3beddff3dbffafd5177e7972067cd2b5083` (v2.30)
- [stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) — same commit (v1.16)
- [stb_image_resize2.h](https://github.com/nothings/stb/blob/master/stb_image_resize2.h) — v2.07

## License

MIT License — see [LICENSE](LICENSE).

stb_image.h, stb_image_write.h, and stb_image_resize2.h are public domain (Sean Barrett).
