# walkzzz/image/pure/codec

> 纯 MoonBit 图像编解码（18 种格式：PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM/TIFF/ICO/CUR/ICNS/APNG/WebP/AVIF/HEIF/JPEG-XL）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 54 |
| 公开类型 | 4 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub struct AvifInfo {
pub struct HeifInfo {
pub struct JpegXlInfo {
pub struct Vp8ReferenceFrames {
```

## API

```moonbit
pub fn avif_decode(Bytes) -> @types.Image raise @types.LoadError
pub fn avif_info(Bytes) -> AvifInfo raise @types.LoadError
pub fn decode_apng_pure(Bytes) -> @types.PngAnimation raise @types.LoadError
pub fn decode_bmp_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_cur_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_gif_animation_pure(Bytes) -> @types.GifAnimation raise @types.LoadError
pub fn decode_gif_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_hdr_pure(Bytes) -> @types.ImageF raise @types.LoadError
pub fn decode_icns_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_ico_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_jpeg_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_png_16_pure(Bytes, req_channels? : Int?) -> @types.Image16 raise @types.LoadError
pub fn decode_png_pure(Bytes, req_channels? : Int?) -> @types.Image raise @types.LoadError
pub fn decode_pnm_16_pure(Bytes) -> @types.Image16 raise @types.LoadError
pub fn decode_pnm_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_psd_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_qoi_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_tga_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_tiff_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn decode_vp8_frame(Bytes, Int) -> @types.Image raise @types.LoadError
pub fn decode_vp8_inter_frame(Bytes, Int, Vp8ReferenceFrames) -> (@types.Image, Vp8ReferenceFrames) raise @types.LoadError
pub fn decode_webp_pure(Bytes) -> @types.Image raise @types.LoadError
pub fn encode_apng_pure(@types.PngAnimation) -> Bytes raise @types.LoadError
pub fn encode_bmp_pure(@types.Image) -> Bytes
pub fn encode_cur_pure(@types.Image) -> Bytes
pub fn encode_cur_with_hotspot_pure(@types.Image, Int, Int) -> Bytes
pub fn encode_gif_animation_pure(@types.GifAnimation) -> Bytes raise @types.LoadError
pub fn encode_gif_pure(@types.Image) -> Bytes raise @types.LoadError
pub fn encode_hdr_pure(@types.ImageF) -> Bytes raise @types.LoadError
pub fn encode_icns_pure(@types.Image) -> Bytes
pub fn encode_ico_pure(@types.Image) -> Bytes
pub fn encode_ico_with_sizes_pure(Array[@types.Image]) -> Bytes
pub fn encode_jpeg_pure(@types.Image) -> Bytes raise @types.LoadError
pub fn encode_pgm_pure(@types.Image) -> Bytes
pub fn encode_png_pure(@types.Image) -> Bytes
pub fn encode_pnm_pure(@types.Image) -> Bytes
pub fn encode_ppm_pure(@types.Image) -> Bytes
pub fn encode_qoi_pure(@types.Image) -> Bytes raise @types.LoadError
pub fn encode_tga_pure(@types.Image) -> Bytes
pub fn encode_tiff_pure(@types.Image) -> Bytes raise @types.LoadError
pub fn encode_webp_lossy_full(@types.Image, quality? : Int) -> Bytes raise @types.LoadError
pub fn encode_webp_lossy_pure(@types.Image, quality? : Int) -> Bytes raise @types.LoadError
pub fn heif_decode(Bytes) -> @types.Image raise @types.LoadError
pub fn heif_info(Bytes) -> HeifInfo raise @types.LoadError
pub fn is_avif_format(Bytes) -> Bool
pub fn is_heif_format(Bytes) -> Bool
pub fn is_jpegxl_codestream(Bytes) -> Bool
pub fn is_jpegxl_container(Bytes) -> Bool
pub fn is_jpegxl_format(Bytes) -> Bool
pub fn jpegxl_decode(Bytes) -> @types.Image raise @types.LoadError
pub fn jpegxl_info(Bytes) -> JpegXlInfo raise @types.LoadError
pub fn tiff_deflate_decode(Bytes) -> Array[Byte] raise @types.LoadError
pub fn tiff_lzw_decode(Bytes) -> Array[Byte] raise @types.LoadError
pub fn tiff_packbits_decode(Bytes) -> Array[Byte] raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
