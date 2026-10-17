# walkzzz/image/process/barcode

> 条形码与二维码检测识别

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 6 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct BarcodeConfig {
pub(all) struct BarcodeResult {
pub(all) enum BarcodeType {
pub(all) enum Code128Charset {
pub(all) struct QrDecodeResult {
pub(all) struct QrFinderPattern {
```

## API

```moonbit
pub fn barcode_default_config() -> BarcodeConfig
pub fn decode_barcode(@types.Image, config? : BarcodeConfig) -> Array[BarcodeResult] raise @types.LoadError
pub fn decode_code128(@types.Image) -> BarcodeResult? raise @types.LoadError
pub fn decode_code39(@types.Image) -> BarcodeResult? raise @types.LoadError
pub fn decode_ean13(@types.Image, config? : BarcodeConfig) -> BarcodeResult? raise @types.LoadError
pub fn decode_linear_barcode(@types.Image) -> Array[BarcodeResult] raise @types.LoadError
pub fn decode_qrcode(@types.Image, config? : BarcodeConfig) -> BarcodeResult? raise @types.LoadError
pub fn decode_qrcode_full(@types.Image) -> QrDecodeResult? raise @types.LoadError
pub fn decode_upca(@types.Image) -> BarcodeResult? raise @types.LoadError
pub fn detect_qr_finder_patterns(@types.Image) -> Array[QrFinderPattern] raise @types.LoadError
pub fn reed_solomon_decode(Array[Int], Int) -> (Array[Int], Int)
pub fn BarcodeType::equal(Self, Self) -> Bool
pub fn BarcodeType::not_equal(Self, Self) -> Bool
pub fn Code128Charset::equal(Self, Self) -> Bool
pub fn Code128Charset::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
