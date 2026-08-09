# 格式检测

基于 magic bytes 的格式检测：

| 格式 | Magic Bytes |
|------|-------------|
| BMP | `BM` |
| QOI | `qoif` |
| PNM | `P5` / `P6` |
| PSD | `8BPS` |
| GIF | `GIF87a` / `GIF89a` |
| TGA | 无固定 magic bytes |

## API

```moonbit
pub fn detect_format(data : Bytes) -> ImageFormat
pub fn decode_any(data : Bytes, ~req_channels : Int? = ...) -> Image raise LoadError
pub fn is_supported_format(data : Bytes) -> Bool
```

> TGA 无固定 magic bytes，`detect_format` 返回 `Unknown`，需显式调用 `@pure.decode_tga_pure`。
