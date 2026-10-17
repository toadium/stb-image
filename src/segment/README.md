# walkzzz/image/process/segment

> 图像分割（分水岭、SLIC、grabCut、形态学、连通域）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 64 |
| 公开类型 | 8 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub struct ConnectedComponent {
pub struct ConnectedComponentLabelImage {
pub(all) struct SegmentLabelImage {
pub struct SegmentRegion {
pub(all) struct SegmentationResult {
pub(all) struct StructuringElement {
pub(all) struct SuperpixelResult {
pub(all) struct WatershedConfig {
```

## API

```moonbit
pub fn connected_components(@types.Image, Int) -> (ConnectedComponentLabelImage, Array[ConnectedComponent]) raise @types.LoadError
pub fn dilate(@types.Image) -> @types.Image
pub fn dilate_16(@types.Image16) -> @types.Image16
pub fn dilate_custom(@types.Image, StructuringElement) -> @types.Image
pub fn dilate_custom_16(@types.Image16, StructuringElement) -> @types.Image16
pub fn dilate_custom_f(@types.ImageF, StructuringElement) -> @types.ImageF
pub fn dilate_f(@types.ImageF) -> @types.ImageF
pub fn distance_transform(@types.Image, distance_type? : Int) -> Array[Float] raise @types.LoadError
pub fn erode(@types.Image) -> @types.Image
pub fn erode_16(@types.Image16) -> @types.Image16
pub fn erode_custom(@types.Image, StructuringElement) -> @types.Image
pub fn erode_custom_16(@types.Image16, StructuringElement) -> @types.Image16
pub fn erode_custom_f(@types.ImageF, StructuringElement) -> @types.ImageF
pub fn erode_f(@types.ImageF) -> @types.ImageF
pub fn flood_fill(@types.Image, Int, Int, Array[Byte], threshold? : Int) -> @types.Image raise @types.LoadError
pub fn grab_cut(@types.Image, Int, Int, Int, Int, iterations? : Int) -> @types.Image raise @types.LoadError
pub fn kmeans_segment(@types.Image, Int, max_iters? : Int) -> (SegmentLabelImage, Array[SegmentRegion]) raise @types.LoadError
pub fn kmeans_segment_16(@types.Image16, Int, max_iters? : Int) -> (SegmentLabelImage, Array[SegmentRegion]) raise @types.LoadError
pub fn kmeans_segment_f(@types.ImageF, Int, max_iters? : Int) -> (SegmentLabelImage, Array[SegmentRegion]) raise @types.LoadError
pub fn morph_blackhat(@types.Image) -> @types.Image
pub fn morph_blackhat_16(@types.Image16) -> @types.Image16
pub fn morph_blackhat_f(@types.ImageF) -> @types.ImageF
pub fn morph_close(@types.Image) -> @types.Image
pub fn morph_close_16(@types.Image16) -> @types.Image16
pub fn morph_close_custom(@types.Image, StructuringElement) -> @types.Image
pub fn morph_close_custom_16(@types.Image16, StructuringElement) -> @types.Image16
pub fn morph_close_custom_f(@types.ImageF, StructuringElement) -> @types.ImageF
pub fn morph_close_f(@types.ImageF) -> @types.ImageF
pub fn morph_gradient(@types.Image) -> @types.Image
pub fn morph_gradient_16(@types.Image16) -> @types.Image16
pub fn morph_gradient_f(@types.ImageF) -> @types.ImageF
pub fn morph_open(@types.Image) -> @types.Image
pub fn morph_open_16(@types.Image16) -> @types.Image16
pub fn morph_open_custom(@types.Image, StructuringElement) -> @types.Image
pub fn morph_open_custom_16(@types.Image16, StructuringElement) -> @types.Image16
pub fn morph_open_custom_f(@types.ImageF, StructuringElement) -> @types.ImageF
pub fn morph_open_f(@types.ImageF) -> @types.ImageF
pub fn morph_tophat(@types.Image) -> @types.Image
pub fn morph_tophat_16(@types.Image16) -> @types.Image16
pub fn morph_tophat_f(@types.ImageF) -> @types.ImageF
pub fn region_growing(@types.Image, Array[(Int, Int)], threshold? : Double) -> SegmentationResult
pub fn region_growing_segment(@types.Image, Array[(Int, Int)], threshold? : Int) -> (SegmentLabelImage, Array[SegmentRegion]) raise @types.LoadError
pub fn se_cross(Int) -> StructuringElement
pub fn se_ellipse(Int) -> StructuringElement
pub fn se_rect(Int, Int) -> StructuringElement
pub fn segment_to_color(SegmentLabelImage) -> @types.Image raise @types.LoadError
pub fn segmentation_to_color(SegmentationResult, Int, Int) -> @types.Image
pub fn skeletonize(@types.Image) -> @types.Image raise @types.LoadError
pub fn slic(@types.Image, Int, Int, Int) -> SuperpixelResult raise @types.LoadError
pub fn slic_16(@types.Image16, Int, Int, Int) -> SuperpixelResult raise @types.LoadError
pub fn slic_f(@types.ImageF, Int, Int, Int) -> SuperpixelResult raise @types.LoadError
pub fn threshold_otsu(@types.Image) -> @types.Image
pub fn visualize_distance_transform(Array[Float], Int, Int) -> @types.Image
pub fn watershed(@types.Image, Array[Int]) -> Array[Int] raise @types.LoadError
pub fn watershed_16(@types.Image16, Array[Int]) -> Array[Int] raise @types.LoadError
pub fn watershed_auto(@types.Image) -> (Array[Int], Int) raise @types.LoadError
pub fn watershed_auto_16(@types.Image16) -> (Array[Int], Int) raise @types.LoadError
pub fn watershed_auto_f(@types.ImageF) -> (Array[Int], Int) raise @types.LoadError
pub fn watershed_default_config() -> WatershedConfig
pub fn watershed_f(@types.ImageF, Array[Int]) -> Array[Int] raise @types.LoadError
pub fn watershed_segment(@types.Image, config? : WatershedConfig) -> SegmentationResult
pub fn SuperpixelResult::equal(Self, Self) -> Bool
pub fn SuperpixelResult::not_equal(Self, Self) -> Bool
pub fn SuperpixelResult::to_repr(Self) -> @debug.Repr
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
