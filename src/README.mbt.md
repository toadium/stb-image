# image

MoonBit pure image library — decode/encode PNG/JPEG/BMP/GIF/TGA/PSD/HDR/PNM/QOI from memory. Pure MoonBit implementation, no C FFI, supports native/wasm-gc/js targets.

## Quick Start

```moonbit nocheck
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
```

## Types

| Type | Description |
|------|-------------|
| `Image { width, height, channels, data : Bytes }` | 8-bit decoded image |
| `Image16 { width, height, channels, data : Bytes }` | 16-bit decoded image (UInt16 little-endian) |
| `ImageF { width, height, channels, data : Bytes }` | HDR float decoded image (IEEE 754 little-endian) |
| `ImageInfo { width, height, channels }` | Image info without pixel data |
| `GifAnimation { frames : Array[Image], delays : Array[Int] }` | Animated GIF (frames + delays in ms) |
| `LoadError { FileIO, UnsupportedFormat, DecodeFailed }` | Load failure error |

## Load API

| Function | Description |
|----------|-------------|
| `load_from_path(path, req_channels?) -> Image` | Load 8-bit from file |
| `load_from_bytes(data, req_channels?) -> Image` | Load 8-bit from memory |
| `load_16_from_path(path, req_channels?) -> Image16` | Load 16-bit from file |
| `load_16_from_bytes(data, req_channels?) -> Image16` | Load 16-bit from memory |
| `loadf_from_path(path, req_channels?) -> ImageF` | Load HDR float from file |
| `loadf_from_bytes(data, req_channels?) -> ImageF` | Load HDR float from memory |
| `load_gif_from_path(path, req_channels?) -> GifAnimation` | Load animated GIF from file |
| `load_gif_from_bytes(data, req_channels?) -> GifAnimation` | Load animated GIF from memory |

## Write API

| Function | Description |
|----------|-------------|
| `write_png_to_path(path, img)` | Write PNG to file |
| `write_bmp_to_path(path, img)` | Write BMP to file |
| `write_tga_to_path(path, img)` | Write TGA to file |
| `write_jpeg_to_path(path, img, quality?)` | Write JPEG to file (quality default 90) |
| `write_png_to_bytes(img) -> Bytes` | Encode PNG to bytes |
| `write_bmp_to_bytes(img) -> Bytes` | Encode BMP to bytes |
| `write_tga_to_bytes(img) -> Bytes` | Encode TGA to bytes |
| `write_jpeg_to_bytes(img, quality?) -> Bytes` | Encode JPEG to bytes |

## Query API

| Function | Description |
|----------|-------------|
| `info_from_path(path) -> ImageInfo?` | Query image info without decoding |
| `info_from_bytes(data) -> ImageInfo?` | Query image info from memory |
| `is_16_bit_from_path(path) -> Bool` | Check if image is 16-bit |
| `is_16_bit_from_bytes(data) -> Bool` | Check if image is 16-bit |
| `is_hdr_from_path(path) -> Bool` | Check if image is HDR |
| `is_hdr_from_bytes(data) -> Bool` | Check if image is HDR |
| `failure_reason() -> String` | Get last stb_image failure reason |

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
  LoadError::DecodeFailed(msg) => println("decode failed: \{msg}")
  LoadError::FileIO(msg) => println("file io error: \{msg}")
}
```

## Backend

Supports **native/wasm-gc/js** targets. Pure MoonBit implementation, no C FFI dependency. 645 tests pass on all three targets.

## Version History

- **v0.1**: 8-bit load (path + bytes), 9 formats
- **v0.2**: write (PNG/BMP/TGA/JPEG) + req_channels + flip
- **v0.3**: 16-bit/float load + info + is_16_bit/is_hdr + failure_reason + config
- **v0.4**: HDR config + animated GIF
- **v1.0**: API freeze, complete documentation, 61 tests, ASan verified
