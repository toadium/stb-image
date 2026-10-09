# walkzzz/image/pure/util

> 纯 MoonBit 工具函数（缩放、裁剪、基础操作）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 24 |
| 公开类型 | 0 |
| 常量 | 0 |
| 错误类型 | 0 |

## API

```moonbit
pub fn adler32(Bytes) -> Int
pub fn convert_iphone_png_to_rgb_pure(Bool) -> Unit
pub fn crc32(Bytes) -> Int
pub fn failure_reason_pure() -> String
pub fn flip_vertically_on_write_pure(Bool) -> Unit
pub fn get_convert_iphone_png_to_rgb_pure() -> Bool
pub fn get_flip_vertically_on_load_pure() -> Bool
pub fn get_flip_vertically_on_write_pure() -> Bool
pub fn get_hdr_to_ldr_gamma_pure() -> Float
pub fn get_hdr_to_ldr_scale_pure() -> Float
pub fn get_ldr_to_hdr_gamma_pure() -> Float
pub fn get_ldr_to_hdr_scale_pure() -> Float
pub fn get_unpremultiply_on_load_pure() -> Bool
pub fn hdr_to_ldr_gamma_pure(Float) -> Unit
pub fn hdr_to_ldr_scale_pure(Float) -> Unit
pub fn info_from_bytes_pure(Bytes) -> @types.ImageInfo? raise @types.LoadError
pub fn is_16_bit_from_bytes_pure(Bytes) -> Bool
pub fn is_hdr_from_bytes_pure(Bytes) -> Bool
pub fn ldr_to_hdr_gamma_pure(Float) -> Unit
pub fn ldr_to_hdr_scale_pure(Float) -> Unit
pub fn resize_pure(@types.Image, Int, Int, filter? : @types.ResizeFilter, edge? : @types.ResizeEdge) -> @types.Image raise @types.LoadError
pub fn set_flip_vertically_on_load_pure(Bool) -> Unit
pub fn set_unpremultiply_on_load_pure(Bool) -> Unit
pub fn zlib_inflate(Bytes) -> Bytes raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
