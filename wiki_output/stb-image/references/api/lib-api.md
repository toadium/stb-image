# 统一 API 层（lib）

路径：`src/lib/lib.mbt`

pure 侧统一入口，自动格式检测 + 编解码委托。

## 类型

```moonbit
pub(all) enum ImageFormat { Bmp; Qoi; Pnm; Psd; Gif; Unknown } derive(Eq, @debug.Debug)
```

## 函数

```moonbit
pub fn detect_format(data : Bytes) -> ImageFormat
pub fn load_from_bytes_auto(data : Bytes) -> @types.Image raise @types.LoadError
pub fn encode_qoi_auto(img : @types.Image) -> Bytes raise @types.LoadError
pub fn encode_pnm_auto(img : @types.Image) -> Bytes
pub fn encode_ppm_auto(img : @types.Image) -> Bytes
pub fn encode_pgm_auto(img : @types.Image) -> Bytes
pub fn encode_gif_auto(img : @types.Image) -> Bytes raise @types.LoadError
```

## 用法

```moonbit
let img = @lib.load_from_bytes_auto(data)  // 自动格式分派
let qoi_bytes = @lib.encode_qoi_auto(img)
```
