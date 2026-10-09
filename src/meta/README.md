# walkzzz/image/meta

> 元数据处理（EXIF 读写、PNG 元数据）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 10 |
| 公开类型 | 2 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ExifInfo {
pub(all) struct PngTextChunk {
```

## API

```moonbit
pub fn create_exif_segment(ExifInfo) -> Bytes
pub fn read_exif_from_bytes(Bytes) -> ExifInfo?
pub fn read_png_text_chunks(Bytes) -> Array[PngTextChunk]
pub fn write_exif_to_bytes(ExifInfo, Bytes) -> Bytes raise @types.LoadError
pub fn ExifInfo::equal(Self, Self) -> Bool
pub fn ExifInfo::not_equal(Self, Self) -> Bool
pub fn ExifInfo::to_repr(Self) -> @debug.Repr
pub fn PngTextChunk::equal(Self, Self) -> Bool
pub fn PngTextChunk::not_equal(Self, Self) -> Bool
pub fn PngTextChunk::to_repr(Self) -> @debug.Repr
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
