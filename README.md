# stb-image

[English](README.md) | [中文](README.zh.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-native-blue)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/tests-546%20passed-brightgreen)]()
[![Bench](https://img.shields.io/badge/bench-75%20passed-brightgreen)]()
[![ASan](https://img.shields.io/badge/ASan-passed-brightgreen)]()

MoonBit native FFI bindings for [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16 + [stb_image_resize2.h](https://github.com/nothings/stb) v2.07.

Full image decode/encode/resize/process capability: 8-bit/16-bit/float load, animated GIF, info query, write PNG/BMP/TGA/JPEG/HDR, resize, format detection, QOI/ICO/ICNS/GIF/PNM codec, EXIF/PNG metadata, image processing (crop/rotate/flip/color/filter/histogram/quantize/morphology/edge detect/quality metrics), roundtrip tests, performance benchmarks.

## Features

- **10+ formats decode**: PNG, JPEG, BMP, GIF, PSD, TGA, HDR, PIC, WebP, PNM (PPM/PGM), QOI
- **8 formats encode**: PNG, BMP, TGA, JPEG, HDR, QOI, GIF, PNM (PPM/PGM)
- **3 pixel types**: 8-bit (`Image`), 16-bit (`Image16`), HDR float (`ImageF`)
- **Resize**: 7 filters × 4 edge modes, 8-bit/16-bit/float/sRGB
- **Format detection**: `detect_format` / `decode_any` / `is_supported_format`
- **Image processing**: crop, rotate, flip, color convert, draw/compositing
- **Color adjustment**: brightness, contrast, gamma, invert, HSV/HSL conversion
- **Filters**: box blur, gaussian blur, sharpen, Sobel/Laplacian/Prewitt edge detect
- **Geometry**: affine warp, arbitrary angle rotate
- **Histogram**: compute, equalize, normalize
- **Quantize**: Floyd-Steinberg dithering, median cut
- **Morphology**: erode, dilate, open, close (3x3 structuring element)
- **Quality metrics**: MSE, PSNR, SSIM
- **Advanced processing**: CLAHE, K-means quantize, FFT frequency domain, frequency domain filtering (low/high/band pass)
- **Adaptive thresholding**: mean, Gaussian-weighted, Otsu
- **Connected components**: labeling with 4/8 connectivity, area/bbox/centroid
- **Integral image**: O(1) rectangle sum/mean/variance query
- **Hough transform**: line detection with NMS
- **LBP**: local binary patterns (basic + uniform)
- **Image pyramids**: Gaussian/Laplacian pyramid build/up/down
- **Bilateral filter**: edge-preserving denoising
- **Contour extraction**: Moore boundary tracking, perimeter, area
- **Color segmentation**: K-means, region growing, flood fill
- **NLM denoise**: non-local means (full + fast)
- **Retinex**: SSR, MSR, MSRCR (multi-scale with color restoration)
- **Canny edge**: Gaussian → Sobel → NMS → hysteresis
- **Watershed**: immersion-based segmentation with auto seeds
- **GLCM texture**: contrast, correlation, energy, homogeneity, entropy (4 directions)
- **Haar wavelet**: 1D/2D transform, multi-level decomposition, denoise
- **Harris corners**: structure tensor + NMS + distance filtering
- **Dehaze**: dark channel prior + guided filter
- **Distance transform**: L1/L2/Linf, skeletonize
- **Gabor filter**: multi-orientation multi-scale texture analysis
- **Blend modes**: 13 modes (multiply, screen, overlay, darken, lighten, difference, exclusion, color dodge, color burn, hard light, soft light, linear dodge, linear burn)
- **Metadata**: EXIF reading, PNG text chunks
- **Animated GIF**: multi-frame decode/encode with per-frame delays
- **Info query**: dimensions without decoding pixels
- **Configurable**: flip, unpremultiply alpha, iPhone PNG, HDR gamma/scale
- **Failure diagnostics**: `failure_reason()` exposes stb_image internal error string
- **533 tests + 29 benchmarks**, all passing under AddressSanitizer

## Installation

```bash
moon add toadium/stb-image
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

## Build & Test

```bash
moon check --target native     # Check compilation
moon test --target native      # Run 546 tests
moon bench --target native     # Run 75 benchmarks
moon info                      # Regenerate API interface
```

## Limitations

- **I/O callbacks** (`stbi_io_callbacks`): not implemented. MoonBit FFI does not support passing closures as C function pointers.
- **Zero-copy**: not implemented. All load paths copy pixel data from C buffer to MoonBit `Bytes` via `memcpy`.
- **Multi-target**: native only. wasm/js support evaluated and deferred.

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.en.md](ARCHITECTURE.en.md) | Architecture diagrams, package dependencies, FFI boundary, data flow, design decisions |
| [API.en.md](API.en.md) | Complete API reference (199 functions, 29 types) |
| [CHANGELOG.md](CHANGELOG.md) | Version history and upstream sources |
| [ROADMAP.md](ROADMAP.md) | Iteration roadmap |
| [COMPARISON.md](COMPARISON.md) | mooncakes.io image library comparison |
| [SKILL.md](SKILL.md) | Package usage guide |

## License

MIT License — see [LICENSE](LICENSE).

stb_image.h, stb_image_write.h, and stb_image_resize2.h are public domain (Sean Barrett).
