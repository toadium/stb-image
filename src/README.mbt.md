# stb-image

MoonBit native FFI bindings for [stb_image.h](https://github.com/nothings/stb) — decode PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC from file path or memory.

## Quick Start

```moonbit
// Decode from memory
let img : Image = load_from_bytes(png_bytes)
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// Decode from file path
let img2 : Image = load_from_path("photo.png")
```

## API

| Function | Description |
|----------|-------------|
| `load_from_path(path : String) -> Image raise LoadError` | Load image from file |
| `load_from_bytes(data : Bytes) -> Image raise LoadError` | Load image from memory |

| Type | Description |
|------|-------------|
| `Image { width, height, channels, data : Bytes }` | Decoded image (8-bit, original channels) |
| `LoadError { FileIO, UnsupportedFormat, DecodeFailed }` | Load failure error |

## Error Handling

```moonbit
try {
  let img = load_from_bytes(data)
  // use img
} catch {
  LoadError::DecodeFailed(msg) => println("decode failed: \{msg}")
  LoadError::FileIO(msg) => println("file io error: \{msg}")
}
```

## Backend

MVP supports **native** target only. `load_from_path`/`load_from_bytes` are gated to `native` via `moon.pkg` `targets`.

## Version Roadmap

- **v0.1 (MVP)**: 8-bit load (path + bytes), 9 formats
- **v0.2**: write (stb_image_write)
- **v0.3**: 16-bit/float, `stbi_failure_reason`, flip/req_channels
- **v0.4**: IO callbacks
- **v1.0**: multi-target (wasm/js)