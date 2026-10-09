# walkzzz/image/process/photo_enhance

> 摄影增强（HDR、色调映射、局部增强）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 22 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DepthOfFieldConfig {
pub(all) enum ExposureType {
pub(all) struct HdrImage {
pub(all) struct LowLightConfig {
pub(all) struct NightEnhanceConfig {
pub(all) struct PanoramaConfig {
pub(all) struct PanoramaResult {
pub(all) struct ToneMappingConfig {
pub(all) enum ToneMappingType {
```

## API

```moonbit
pub fn apply_depth_of_field(@types.Image, DepthOfFieldConfig) -> @types.Image
pub fn batch_photo_enhance(Array[@types.Image], String) -> Array[@types.Image]
pub fn clahe_enhance(@types.Image, clip_limit? : Double, tile_size? : Int) -> @types.Image
pub fn color_enhance(@types.Image, saturation? : Double, contrast? : Double) -> @types.Image
pub fn computational_photography_report(HdrImage, PanoramaResult) -> String
pub fn create_default_dof_config(Int, Int) -> DepthOfFieldConfig
pub fn create_default_hdr_config() -> ToneMappingConfig
pub fn create_default_night_config() -> NightEnhanceConfig
pub fn create_default_panorama_config() -> PanoramaConfig
pub fn deblur_motion(@types.Image, kernel_size? : Int, angle? : Double) -> @types.Image
pub fn detect_exposure_type(@types.Image) -> (ExposureType, Double)
pub fn enhance_night(@types.Image, NightEnhanceConfig) -> @types.Image
pub fn hdr_merge(Array[@types.Image], Array[Double]) -> HdrImage
pub fn low_light_default_config() -> LowLightConfig
pub fn low_light_enhance(@types.Image, config? : LowLightConfig) -> @types.Image
pub fn stitch_panorama(Array[@types.Image], PanoramaConfig) -> PanoramaResult
pub fn tone_map(HdrImage, ToneMappingConfig) -> @types.Image
pub fn white_balance(@types.Image) -> @types.Image
pub fn ExposureType::equal(Self, Self) -> Bool
pub fn ExposureType::not_equal(Self, Self) -> Bool
pub fn ToneMappingType::equal(Self, Self) -> Bool
pub fn ToneMappingType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
