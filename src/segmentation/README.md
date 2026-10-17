# walkzzz/image/process/segmentation

> 图像分割算法集合

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 12 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct GrabCutConfig {
pub(all) struct InstanceSegmentationResult {
pub(all) struct KMeansConfig {
pub(all) struct SegmentationLabel {
pub(all) struct SegmentationMetrics {
pub(all) struct SemanticSegmentationResult {
pub(all) struct Superpixel {
pub(all) struct SuperpixelResult {
pub(all) struct WatershedConfig {
```

## API

```moonbit
pub fn calculate_segmentation_metrics(Array[Int], Array[Int], Int) -> SegmentationMetrics
pub fn create_default_grabcut_config() -> GrabCutConfig
pub fn create_default_kmeans_config() -> KMeansConfig
pub fn create_default_watershed_config() -> WatershedConfig
pub fn grabcut_segmentation(@types.Image, Int, Int, Int, Int, GrabCutConfig) -> SemanticSegmentationResult raise @types.LoadError
pub fn kmeans_segmentation(@types.Image, KMeansConfig) -> SemanticSegmentationResult raise @types.LoadError
pub fn otsu_threshold_value(@types.Image) -> Double raise @types.LoadError
pub fn segmentation_report_to_string(SemanticSegmentationResult, SegmentationMetrics) -> String
pub fn segmentation_to_image(SemanticSegmentationResult) -> @types.Image
pub fn superpixel_segmentation(@types.Image, Int) -> SuperpixelResult raise @types.LoadError
pub fn threshold_segmentation(@types.Image, Double) -> SemanticSegmentationResult raise @types.LoadError
pub fn watershed_segmentation(@types.Image, WatershedConfig) -> SemanticSegmentationResult raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
