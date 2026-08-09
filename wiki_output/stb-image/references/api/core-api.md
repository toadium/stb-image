# Core API（native FFI）

路径：`src/core/`（C FFI，native-only）

## 加载

```moonbit
pub fn load_from_bytes(data : Bytes, ~req_channels : Int? = ...) -> Image raise LoadError
pub fn load_from_path(path : String, ~req_channels : Int? = ...) -> Image raise LoadError
pub fn load_16_from_bytes(data : Bytes, ~req_channels : Int? = ...) -> Image16 raise LoadError
pub fn load_16_from_path(path : String, ~req_channels : Int? = ...) -> Image16 raise LoadError
pub fn loadf_from_bytes(data : Bytes, ~req_channels : Int? = ...) -> ImageF raise LoadError
pub fn loadf_from_path(path : String, ~req_channels : Int? = ...) -> ImageF raise LoadError
pub fn load_gif_from_bytes(data : Bytes, ~req_channels : Int? = ...) -> GifAnimation raise LoadError
pub fn load_gif_from_path(path : String, ~req_channels : Int? = ...) -> GifAnimation raise LoadError
```

## 写入

```moonbit
pub fn write_png_to_path(path : String, img : Image) -> Unit raise LoadError
pub fn write_bmp_to_path(path : String, img : Image) -> Unit raise LoadError
pub fn write_tga_to_path(path : String, img : Image) -> Unit raise LoadError
pub fn write_jpeg_to_path(path : String, img : Image, ~quality : Int = ...) -> Unit raise LoadError
pub fn write_png_to_bytes(img : Image) -> Bytes raise LoadError
pub fn write_bmp_to_bytes(img : Image) -> Bytes raise LoadError
pub fn write_tga_to_bytes(img : Image) -> Bytes raise LoadError
pub fn write_jpeg_to_bytes(img : Image, ~quality : Int = ...) -> Bytes raise LoadError
pub fn write_hdr_to_path(path : String, img : ImageF) -> Unit raise LoadError
pub fn write_hdr_to_bytes(img : ImageF) -> Bytes raise LoadError
```

## 缩放

```moonbit
pub fn resize(img : Image, out_w : Int, out_h : Int, ~filter : ResizeFilter = ..., ~edge : ResizeEdge = ...) -> Image raise LoadError
pub fn resize_srgb(img : Image, ...) -> Image raise LoadError
pub fn resize_16(img16 : Image16, ...) -> Image16 raise LoadError
pub fn resizef(imgf : ImageF, ...) -> ImageF raise LoadError
```

## 信息与检测

```moonbit
pub fn info_from_bytes(data : Bytes) -> ImageInfo? raise LoadError
pub fn info_from_path(path : String) -> ImageInfo?
pub fn is_16_bit_from_bytes(data : Bytes) -> Bool
pub fn is_hdr_from_bytes(data : Bytes) -> Bool
pub fn detect_format(data : Bytes) -> ImageFormat
pub fn decode_any(data : Bytes, ~req_channels : Int? = ...) -> Image raise LoadError
pub fn failure_reason() -> String
```

## ICO/ICNS 编码

```moonbit
pub fn encode_ico(img : Image) -> Bytes raise LoadError
pub fn encode_ico_sizes(images : Array[Image]) -> Bytes raise LoadError
pub fn encode_icns(img : Image) -> Bytes raise LoadError
```

## 配置

```moonbit
pub fn set_flip_vertically_on_load(flag : Bool) -> Unit
pub fn flip_vertically_on_write(flag : Bool) -> Unit
pub fn set_unpremultiply_on_load(flag : Bool) -> Unit
pub fn convert_iphone_png_to_rgb(flag : Bool) -> Unit
pub fn hdr_to_ldr_gamma(gamma : Float) -> Unit
pub fn hdr_to_ldr_scale(scale : Float) -> Unit
pub fn ldr_to_hdr_gamma(gamma : Float) -> Unit
pub fn ldr_to_hdr_scale(scale : Float) -> Unit
```
