# walkzzz/image/process/remote_sensing

> 遥感图像处理

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 25 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ChangeDetectionResult {
pub(all) struct ClassificationResult {
pub(all) enum LandCoverClass {
pub(all) struct MultispectralImage {
pub(all) struct RemoteSensingImage {
pub(all) enum RemoteSensingImageType {
pub(all) struct RemoteSensingQuality {
pub(all) struct SpectralSignature {
pub(all) struct TextureFeatures {
pub(all) struct VegetationIndices {
```

## API

```moonbit
pub fn calculate_all_vegetation_indices(RemoteSensingImage) -> VegetationIndices
pub fn calculate_ndbi(RemoteSensingImage, Int, Int) -> Array[Double]
pub fn calculate_ndvi(RemoteSensingImage, Int, Int) -> Array[Double]
pub fn calculate_ndwi(RemoteSensingImage, Int, Int) -> Array[Double]
pub fn calculate_remote_sensing_quality(RemoteSensingImage) -> RemoteSensingQuality
pub fn calculate_spectral_signature(RemoteSensingImage, Int, Int) -> SpectralSignature
pub fn calculate_texture_features(@types.Image, Int, Int, Int) -> TextureFeatures raise @types.LoadError
pub fn classification_colormap(@types.Image) -> @types.Image raise @types.LoadError
pub fn classify_land_cover_simple(RemoteSensingImage) -> ClassificationResult
pub fn compute_evi(@types.Image, @types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn compute_ndbi(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn compute_ndvi(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn compute_ndwi(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn create_default_remote_sensing_image(Int, Int, Int) -> RemoteSensingImage
pub fn detect_changes_simple(RemoteSensingImage, RemoteSensingImage, Double) -> ChangeDetectionResult
pub fn false_color_composite(@types.Image, @types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn land_cover_classification(@types.Image, @types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn multispectral_new(Int, Int, Array[@types.Image], band_names? : Array[String]) -> MultispectralImage
pub fn remote_sensing_report_to_string(RemoteSensingImage, ClassificationResult, ChangeDetectionResult, RemoteSensingQuality) -> String
pub fn true_color_composite(@types.Image, @types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn vegetation_coverage(@types.Image, ndvi_soil? : Double, ndvi_veg? : Double) -> @types.Image raise @types.LoadError
pub fn LandCoverClass::equal(Self, Self) -> Bool
pub fn LandCoverClass::not_equal(Self, Self) -> Bool
pub fn RemoteSensingImageType::equal(Self, Self) -> Bool
pub fn RemoteSensingImageType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
