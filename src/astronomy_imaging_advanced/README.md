# walkzzz/image/process/astronomy_imaging_advanced

> 天文图像高级处理

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 14 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AstronomyImagingConfig {
pub(all) enum AstronomyImagingTaskType {
pub(all) enum CelestialObjectType {
pub(all) struct CosmologicalParameterResult {
pub(all) struct DetectedCelestialObject {
pub(all) struct GalaxyClassificationResult {
pub(all) enum GalaxyMorphologyType {
pub(all) struct ImageStackingResult {
pub(all) struct PhotometryResult {
pub(all) enum SpectralType {
pub(all) struct SpectroscopyResult {
pub(all) struct TransitDetectionResult {
```

## API

```moonbit
pub fn astronomy_imaging_report_to_string(AstronomyImagingTaskType, AstronomyImagingConfig, String) -> String
pub fn classify_galaxies(Array[DetectedCelestialObject], AstronomyImagingConfig) -> Array[GalaxyClassificationResult]
pub fn create_default_astronomy_config() -> AstronomyImagingConfig
pub fn detect_celestial_objects(Array[Double], Int, Int, AstronomyImagingConfig) -> Array[DetectedCelestialObject]
pub fn perform_photometry(Array[DetectedCelestialObject], AstronomyImagingConfig) -> Array[PhotometryResult]
pub fn stack_images(Array[Array[Double]], Int, Int, AstronomyImagingConfig) -> ImageStackingResult
pub fn AstronomyImagingTaskType::equal(Self, Self) -> Bool
pub fn AstronomyImagingTaskType::not_equal(Self, Self) -> Bool
pub fn CelestialObjectType::equal(Self, Self) -> Bool
pub fn CelestialObjectType::not_equal(Self, Self) -> Bool
pub fn GalaxyMorphologyType::equal(Self, Self) -> Bool
pub fn GalaxyMorphologyType::not_equal(Self, Self) -> Bool
pub fn SpectralType::equal(Self, Self) -> Bool
pub fn SpectralType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
