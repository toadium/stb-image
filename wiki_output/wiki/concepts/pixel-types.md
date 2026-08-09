# 像素类型

三种像素类型，均含 `width/height/channels/data:Bytes` 字段：

| 类型 | 位深 | 字节/像素 | 用途 |
|------|------|-----------|------|
| `Image` | 8-bit 无符号 | 1 | 常规图像（LDR） |
| `Image16` | 16-bit 无符号 | 2 | 高位深图像（little-endian） |
| `ImageF` | 32-bit IEEE float | 4 | HDR 图像（little-endian） |

## 辅助类型

- `ImageInfo`：含 `width/height/channels`，用于不解码像素仅读取信息
- `GifAnimation`：含 `frames: Array[Image]` + `delays: Array[Int]`（毫秒）
- `LoadError`：suberror 含 `FileIO(String)` / `UnsupportedFormat(String)` / `DecodeFailed(String)`
