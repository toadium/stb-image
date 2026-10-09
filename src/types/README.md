# walkzzz/image/types

> 核心类型定义（Image、Image16、ImageF、LoadError 等全目标共享类型）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 30 |
| 公开类型 | 9 |
| 常量 | 1 |
| 错误类型 | 1 |

## 常量

```moonbit
pub const MAX_IMAGE_DIMENSION : Int = 65535
```

## 错误类型

```moonbit
pub(all) suberror LoadError {
```

## 类型

```moonbit
pub(all) struct GifAnimation {
pub(all) struct Image {
pub(all) struct Image16 {
pub(all) struct ImageF {
pub(all) enum ImageFormat {
pub(all) struct ImageInfo {
pub(all) struct PngAnimation {
pub(all) enum ResizeEdge {
pub(all) enum ResizeFilter {
```

## API

```moonbit
pub fn check_dims(Int, Int, Int) -> Unit raise LoadError
pub fn safe_mul(Int, Int) -> Int?
pub fn safe_mul3(Int, Int, Int) -> Int?
pub fn GifAnimation::equal(Self, Self) -> Bool
pub fn GifAnimation::not_equal(Self, Self) -> Bool
pub fn GifAnimation::to_repr(Self) -> @debug.Repr
pub fn Image::equal(Self, Self) -> Bool
pub fn Image::not_equal(Self, Self) -> Bool
pub fn Image::to_repr(Self) -> @debug.Repr
pub fn Image16::equal(Self, Self) -> Bool
pub fn Image16::not_equal(Self, Self) -> Bool
pub fn Image16::to_repr(Self) -> @debug.Repr
pub fn ImageF::equal(Self, Self) -> Bool
pub fn ImageF::not_equal(Self, Self) -> Bool
pub fn ImageF::to_repr(Self) -> @debug.Repr
pub fn ImageFormat::equal(Self, Self) -> Bool
pub fn ImageFormat::not_equal(Self, Self) -> Bool
pub fn ImageFormat::to_repr(Self) -> @debug.Repr
pub fn ImageInfo::equal(Self, Self) -> Bool
pub fn ImageInfo::not_equal(Self, Self) -> Bool
pub fn ImageInfo::to_repr(Self) -> @debug.Repr
pub fn PngAnimation::equal(Self, Self) -> Bool
pub fn PngAnimation::not_equal(Self, Self) -> Bool
pub fn PngAnimation::to_repr(Self) -> @debug.Repr
pub fn ResizeEdge::equal(Self, Self) -> Bool
pub fn ResizeEdge::not_equal(Self, Self) -> Bool
pub fn ResizeEdge::to_repr(Self) -> @debug.Repr
pub fn ResizeFilter::equal(Self, Self) -> Bool
pub fn ResizeFilter::not_equal(Self, Self) -> Bool
pub fn ResizeFilter::to_repr(Self) -> @debug.Repr
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
