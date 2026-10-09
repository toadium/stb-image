# walkzzz/image/lib

> 高层封装（自动格式分派、流式解码、模糊测试）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 1 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct StreamInfo {
```

## API

```moonbit
pub fn decode_stream(Bytes, (Int, Array[Byte]) -> Unit) -> StreamInfo raise @types.LoadError
pub fn decode_stream_channels(Bytes, Int, (Int, Array[Byte]) -> Unit) -> StreamInfo raise @types.LoadError
pub fn decode_stream_chunked(Bytes, Int, (Int, @types.Image) -> Unit) -> StreamInfo raise @types.LoadError
pub fn detect_format(Bytes) -> @types.ImageFormat
pub fn encode_bmp(@types.Image) -> Bytes
pub fn encode_gif(@types.Image) -> Bytes raise @types.LoadError
pub fn encode_hdr(@types.ImageF) -> Bytes raise @types.LoadError
pub fn encode_jpeg(@types.Image) -> Bytes raise @types.LoadError
pub fn encode_pgm_auto(@types.Image) -> Bytes
pub fn encode_png(@types.Image) -> Bytes
pub fn encode_pnm_auto(@types.Image) -> Bytes
pub fn encode_ppm_auto(@types.Image) -> Bytes
pub fn encode_qoi(@types.Image) -> Bytes raise @types.LoadError
pub fn encode_tga(@types.Image) -> Bytes
pub fn load_16_from_bytes_auto(Bytes, req_channels? : Int?) -> @types.Image16 raise @types.LoadError
pub fn load_from_bytes_auto(Bytes, req_channels? : Int?) -> @types.Image raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
