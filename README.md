# stb-image

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-native-blue)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/tests-61%20passed-brightgreen)]()
[![ASan](https://img.shields.io/badge/ASan-passed-brightgreen)]()

MoonBit native FFI bindings for [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16.

Full image decode/encode capability: 8-bit/16-bit/float load, animated GIF, info query, write PNG/BMP/TGA/JPEG, HDR config, flip/unpremultiply/iPhone PNG config.

## Features

- **9+ formats decode**: PNG, JPEG, BMP, GIF, PSD, TGA, HDR, PIC, WebP, PNM (PPM/PGM)
- **4 formats encode**: PNG, BMP, TGA, JPEG
- **3 pixel types**: 8-bit (`Image`), 16-bit (`Image16`), HDR float (`ImageF`)
- **Animated GIF**: multi-frame decode with per-frame delays
- **Info query**: dimensions without decoding pixels
- **Format detection**: `is_16_bit`, `is_hdr`
- **Configurable**: flip, unpremultiply alpha, iPhone PNG, HDR gamma/scale
- **Failure diagnostics**: `failure_reason()` exposes stb_image internal error string
- **61 tests**, all passing under AddressSanitizer

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

// Load animated GIF
let anim : GifAnimation = load_gif_from_path("animation.gif")
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

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

### Write (8 functions)

| Function | Signature | Description |
|----------|-----------|-------------|
| `write_png_to_path` | `(String, Image) -> Unit` | Write PNG to file |
| `write_bmp_to_path` | `(String, Image) -> Unit` | Write BMP to file |
| `write_tga_to_path` | `(String, Image) -> Unit` | Write TGA to file |
| `write_jpeg_to_path` | `(String, Image, quality?: Int) -> Unit` | Write JPEG (quality default 90) |
| `write_png_to_bytes` | `(Image) -> Bytes` | Encode PNG to bytes |
| `write_bmp_to_bytes` | `(Image) -> Bytes` | Encode BMP to bytes |
| `write_tga_to_bytes` | `(Image) -> Bytes` | Encode TGA to bytes |
| `write_jpeg_to_bytes` | `(Image, quality?: Int) -> Bytes` | Encode JPEG to bytes |

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
┌─────────────────────────────────────────────────┐
│  Test & Docs    *_test.mbt (61 tests)           │
│                  README.mbt.md, SKILL.md        │
├─────────────────────────────────────────────────┤
│  Safe API       image_*_native.mbt (pub fn)     │
│                  image_types.mbt (types)        │
├─────────────────────────────────────────────────┤
│  FFI Boundary   ffi.mbt (extern "c")            │
│                  wrapper.c (ABI normalization)  │
├─────────────────────────────────────────────────┤
│  Vendoring      stb_image.h v2.30               │
│                  stb_image_write.h v1.16        │
│                  scripts/prepare.py             │
└─────────────────────────────────────────────────┘
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

# Run ASan validation (requires VS Developer environment)
python scripts/run-asan.py --repo-root . --pkg src/moon.pkg --no-disable-mimalloc

# Regenerate API interface
moon info  # outputs src/pkg.generated.mbti
```

## Project Structure

```
stb-image/
├── moon.mod                  # Module config (preferred_target = native)
├── SKILL.md                  # Package usage guide
├── src/
│   ├── moon.pkg              # Package config (native-stub, targets gating)
│   ├── wrapper.c             # C FFI wrapper (ABI normalization)
│   ├── stb_image.h           # Vendored upstream v2.30
│   ├── stb_image_write.h     # Vendored upstream v1.16
│   ├── ffi.mbt               # Private extern "c" declarations
│   ├── image_types.mbt       # Image, Image16, ImageF, ImageInfo, GifAnimation, LoadError
│   ├── image_load_native.mbt # load_from_path/bytes
│   ├── image_write_native.mbt# write_*_to_path/bytes, flip
│   ├── image_16_native.mbt   # load_16_from_path/bytes
│   ├── image_float_native.mbt# loadf_from_path/bytes
│   ├── image_info_native.mbt # info, is_16_bit, is_hdr, failure_reason, config
│   ├── image_gif_native.mbt  # load_gif_from_path/bytes
│   ├── *_test.mbt            # 61 tests
│   ├── README.mbt.md         # MoonBit doc-test
│   └── pkg.generated.mbti    # Frozen API interface
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
| **v1.0** | **API freeze, complete docs, ASan verified** | **61** |

## Upstream

- [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) — commit `013ac3beddff3dbffafd5177e7972067cd2b5083` (v2.30)
- [stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) — same commit (v1.16)

## License

MIT License — see [LICENSE](LICENSE).

stb_image.h and stb_image_write.h are public domain (Sean Barrett).
