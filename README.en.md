<div align="center">

# image

**Pure MoonBit Image Library** · Zero C Dependencies · Four-Target Native Support

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-0.1.20260713-blue)](https://www.moonbitlang.com/)
[![Targets](https://img.shields.io/badge/targets-native%20%7C%20wasm--gc%20%7C%20js%20%7C%20wasm-success)]()
[![Tests](https://img.shields.io/badge/tests-1203%20%C3%97%204%20targets-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-90.4%25-brightgreen)]()
[![Functions](https://img.shields.io/badge/API-286%20functions%20%2B%201%20const%20%2B%2047%20types-blueviolet)]()
[![Version](https://img.shields.io/badge/version-0.4.11-orange)]()

[Highlights](#-highlights) · [Format Support](#-format-support) · [Quick Start](#-quick-start) · [Features](#-features) · [Multi-Target](#-multi-target-support) · [Package Structure](#-package-structure) · [Docs](#-documentation) · [Build](#-build--test) · [Contributing](#-contributing)

</div>

---

## 📖 Introduction

`image` is a pure MoonBit image processing library with **zero C FFI dependencies**. It covers decoding and encoding of 15 formats, providing complete capabilities from basic pixel operations to advanced computer vision algorithms. Install: `moon add walkzzz/image`.

> For detailed notes (version mapping, format detection, multi-target, core constraints), see [docs/notes.md](docs/notes.md).

---

## ✨ Highlights

| | Feature | Description |
|---|---|---|
| 🟢 | **Zero C deps** | Fully pure MoonBit, no C compiler needed, minimal deployment |
| 🟢 | **Four targets** | native / wasm-gc / js / wasm share one codebase, no conditional compilation |
| 🟢 | **Broad format coverage** | PNG / JPEG / BMP / GIF / QOI / TGA / PSD / HDR / PNM / TIFF / ICO / CUR / ICNS / APNG / WebP — includes exclusive PSD, HDR |
| 🟢 | **Full pixel depth** | 8-bit `Image`, 16-bit `Image16`, HDR float `ImageF` |
| | 🟢 | **287 APIs** | From basic I/O to FFT, Canny, watershed, SLIC, ORB, SIFT, SIFT matching, RANSAC homography, grabCut, streaming decode, optical flow, template matching, WebP lossy encoding |
| 🟢 | **Streaming decode** | Row-by-row / chunked / channel-specified callbacks (currently full decode then row dispatch; incremental decode planned for v5.0) |
| 🟢 | **Safety hardening** | MAX_IMAGE_DIMENSION(65535) guard + check_dims validation at all decoder entry points + safe_mul overflow protection |
| 🟢 | **Multi-package architecture** | 8 sub-packages with clear responsibilities, parallel compilation, independent testing |

---

## 🖼️ Format Support

| Format | Decode | Encode | Notes |
|:------:|:------:|:------:|-------|
| PNG | ✅ | ✅ | 8/16-bit, Adam7 interlacing |
| JPEG | ✅ | ✅ | baseline, adjustable quality |
| BMP | ✅ | ✅ | 1/4/8/16/24/32-bit |
| GIF | ✅ | ✅ | animated GIF decode/encode |
| QOI | ✅ | ✅ | Quite OK Image |
| TGA | ✅ | ✅ | with RLE |
| PSD | ✅ | — | Photoshop document (exclusive) |
| HDR | ✅ | ✅ | IEEE 754 float (exclusive) |
| PNM | ✅ | ✅ | PPM / PGM |
| TIFF | ✅ | ✅ | uncompressed/LZW/PackBits |
| ICO | ✅ | ✅ | single/multi-size |
| CUR | ✅ | ✅ | Windows cursor |
| ICNS | ✅ | ✅ | macOS icon |
| APNG | ✅ | ✅ | animated PNG |
| WebP | ✅ (lossless) | ✅ (lossy VP8) | lossless (VP8L) decode + lossy (VP8) encode; note: lossy encode output cannot be decoded by this library |

---

## 🚀 Quick Start

### Installation

```bash
moon add walkzzz/image
```

### Minimal Example

```moonbit
// Decode from bytes
let img : Image = load_from_bytes(png_bytes)
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// Encode to PNG bytes
let out : Bytes = write_png_to_bytes(img)

// Resize (7 filters × 4 edge modes)
let resized : Image = resize(img, 128, 128)

// Auto-detect format and decode
let any : Image = decode_any(data, req_channels=Some(3))

// Load animated GIF
let anim : GifAnimation = load_gif_from_bytes(gif_bytes)
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// Query image info without decoding pixels
let info : ImageInfo? = info_from_bytes(data)

// Streaming decode: row callback (currently full decode then row dispatch)
decode_stream(data, fn(row, y) {
  // Process row y pixels: row : Array[Array[Int]]
})
```

### Error Handling

```moonbit
try {
  let img = load_from_bytes(data)
} catch {
  LoadError::FileIO(msg) => println("File IO error: \{msg}")
  LoadError::DecodeFailed(msg) => println("Decode failed: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("Unsupported format: \{msg}")
}
```

### Advanced Example: SIFT Feature Matching

```moonbit
// Detect SIFT features
let kp1 = sift_detect(img1)
let kp2 = sift_detect(img2)

// L2 distance + Lowe ratio test matching
let matches = sift_match(kp1, kp2, ratio_threshold=0.75)

// RANSAC robust homography estimation
let homography = ransac_homography(matches, threshold=5.0, iterations=1000)
```

### Complete Examples

`src/examples/` contains **32 examples** covering all API scenarios. See [docs/examples.md](docs/examples.md).

---

## 🧰 Features

287 public APIs by category. See [docs/features.md](docs/features.md) for overview and [docs/api_reference.md](docs/api_reference.md) for full signatures.

## 🎯 Multi-Target Support

| Target | Backend | Tests | Status |
|:------:|:-------:|:-----:|:------:|
| **native** | Pure MoonBit | 1203 | ✅ |
| **wasm-gc** | Pure MoonBit | 1203 | ✅ |
| **js** | Pure MoonBit | 1203 | ✅ |
| **wasm** | Pure MoonBit | 1203 | ✅ |

---

## 📦 Package Structure

```
src/
├── types/              # All-target types (Image, Image16, ImageF, LoadError, etc.)
├── pure/               # Pure MoonBit backend (no C FFI)
│   ├── codec/          #   Format codecs (15 formats)
│   ├── color/          #   Color operations
│   └── util/           #   Utilities
├── lib/                # High-level wrapper (auto format dispatch)
├── meta/               # Metadata (EXIF, PNG meta)
├── process/            # Advanced image processing (7 sub-packages)
│   ├── color/          #   Color conversion/adjust/CLAHE/adaptive threshold/Retinex/dehaze
│   ├── edge/           #   Edge detection/Canny/Hough/contours
│   ├── feature/        #   Feature detection: Harris/ORB/SIFT/template matching/optical flow/GLCM/LBP
│   ├── filter/         #   Filtering/denoising/inpainting
│   ├── frequency/      #   FFT/DCT/Haar wavelet/frequency filtering
│   ├── segment/        #   Watershed/SLIC/grabCut/morphology/connected components
│   └── transform/      #   Geometric transforms/perspective/Seam Carving/pyramids
├── examples/           # Example code (32 examples, all API coverage)
├── util/               # Utility functions (built on pure)
├── bench.mbt           # Performance benchmarks
└── reexport.mbt        # Top-level API re-export (283 pub fn + 47 pub type)
```

---

## 📄 Documentation

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | Architecture diagram, package dependencies, design decisions |
| [docs/api_reference.md](docs/api_reference.md) | Full API reference (286 functions + 1 const + 47 types) |
| [docs/roadmap.md](docs/roadmap.md) | Iteration roadmap |
| [docs/comparison.md](docs/comparison.md) | mooncakes.io image library comparison |
| [docs/performance_report.md](docs/performance_report.md) | Performance benchmark report (46 benchmarks) |
| [docs/notes.md](docs/notes.md) | Usage notes and core constraints |
| [docs/examples.md](docs/examples.md) | Complete examples (32 examples) |
| [docs/features.md](docs/features.md) | Feature overview (287 APIs by category) |
| [docs/contributing.md](docs/contributing.md) | Contributing guide (dev setup/workflow/conventions) |
| [docs/changelog.md](docs/changelog.md) | Version changelog |

---

## 🔧 Build & Test

```bash
# Compile check (four targets)
moon check
moon check --target wasm-gc
moon check --target js
moon check --target wasm

# Run tests (1203 each target)
moon test --target native
moon test --target wasm-gc
moon test --target js
moon test --target wasm

# Run benchmarks
moon run --target native

# Regenerate API interface
moon info

# Code coverage analysis
moon coverage analyze
```

---

## 🤝 Contributing

Issues and Pull Requests are welcome! See [docs/contributing.md](docs/contributing.md).

---

## 📄 License

[MIT](LICENSE) — Free to use, modify, and distribute.

---

## 🔗 Porting Notes

### Original Project

| Attribute | Value |
|-----------|-------|
| Original | [stb](https://github.com/nothings/stb) — `stb_image.h` |
| Author | Sean Barrett (@nothings) |
| Original License | MIT / Public Domain |
| Original Language | C (single-header library) |
| Port Target | MoonBit (pure language, zero C FFI) |

### Porting Scope

This project uses `stb_image.h` as a reference base, re-implementing its core image codec capabilities in pure MoonBit:

- **Format codecs**: PNG / JPEG / BMP / GIF / QOI / TGA / PSD / HDR / PNM / TIFF / ICO / CUR / ICNS / APNG / WebP — 15 formats
- **Pixel depth**: 8-bit `Image`, 16-bit `Image16`, HDR float `ImageF`
- **Basic operations**: resize / crop / rotate / flip / color conversion / channel ops / draw / composite

### Extensions Beyond Original

On top of the port, this project adds many advanced capabilities **not in `stb_image.h`**:

- **Streaming decode** — Row-by-row / chunked callback interface
- **Computer vision algorithms** — Canny / Harris / ORB / SIFT / template matching / optical flow / RANSAC / grabCut
- **Frequency domain analysis** — FFT / DCT / Haar wavelet / frequency filtering
- **Image segmentation** — Watershed / SLIC superpixels / K-means / connected components
- **Advanced filtering** — Bilateral / NLM denoising / CLAHE / Retinex / dehazing / inpainting
- **Feature descriptors** — LBP / GLCM texture / Hu moments / perceptual hash
- **WebP lossy (VP8) encoding** — Original does not support WebP
- **Safety hardening** — Dimension overflow guards + overflow-safe multiplication + decoder entry validation

### Differences from Original

| Aspect | stb_image.h | This Project |
|--------|-------------|--------------|
| Language | C | MoonBit |
| Dependencies | C compiler | Zero C deps |
| Targets | native | native / wasm-gc / js / wasm |
| Formats | 7 | 15 |
| APIs | ~30 | 287 |
| Advanced algorithms | None | 50+ |
| Memory safety | Manual | GC managed |

---

## 🙏 Acknowledgments

- **[stb](https://github.com/nothings/stb)** — Reference for the original C implementation
- **[MoonBit](https://www.moonbitlang.com/)** — Pure MoonBit language and toolchain
- **[OpenCV](https://opencv.org/)** — Reference for advanced algorithms (ORB/Canny/Harris/optical flow etc.)

---

<div align="center">

If this project helps you, please consider ⭐ Starring it!

</div>
