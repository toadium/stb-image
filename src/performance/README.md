# walkzzz/image/process/performance

> 性能优化与加速工具

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 9 |
| 公开类型 | 1 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct TileConfig {
```

## API

```moonbit
pub fn bulk_copy_4x(Bytes, Int, Array[Byte], Int, Int) -> Unit
pub fn bulk_fill_4x(Array[Byte], Int, Int, Byte) -> Unit
pub fn default_tile_config() -> TileConfig
pub fn extract_tile(@types.Image, Int, Int, Int, Int) -> @types.Image raise @types.LoadError
pub fn num_tiles(Int, Int, TileConfig) -> (Int, Int)
pub fn paste_tile(@types.Image, @types.Image, Int, Int) -> @types.Image raise @types.LoadError
pub fn process_row_major(@types.Image, (Int, Array[Byte]) -> Array[Byte]) -> @types.Image
pub fn process_tiled(@types.Image, TileConfig, (@types.Image) -> @types.Image) -> @types.Image raise @types.LoadError
pub fn tile_region(Int, Int, TileConfig) -> (Int, Int, Int, Int)
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
