# walkzzz/image/process/registration_advanced

> registration_advanced 图像处理模块

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 7 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct FeatureMatch {
pub(all) struct FeaturePoint {
pub(all) enum RegistrationAlgorithm {
pub(all) struct RegistrationConfigAdvanced {
pub(all) struct RegistrationResultAdvanced {
pub(all) struct TransformMatrix {
pub(all) enum TransformType {
```

## API

```moonbit
pub fn apply_affine_transform(@types.Image, TransformMatrix) -> @types.Image
pub fn apply_translation(@types.Image, Int, Int) -> @types.Image
pub fn calculate_mutual_information(@types.Image, @types.Image) -> Double
pub fn create_default_registration_config_advanced() -> RegistrationConfigAdvanced
pub fn detect_harris_corners(@types.Image, Double) -> Array[FeaturePoint]
pub fn estimate_affine_transform(Array[FeatureMatch]) -> TransformMatrix
pub fn feature_based_registration(@types.Image, @types.Image, RegistrationConfigAdvanced) -> RegistrationResultAdvanced
pub fn match_feature_points(Array[FeaturePoint], Array[FeaturePoint], Double) -> Array[FeatureMatch]
pub fn normalized_cross_correlation(@types.Image, @types.Image) -> Double
pub fn phase_correlation_registration(@types.Image, @types.Image) -> RegistrationResultAdvanced
pub fn register_images_advanced(@types.Image, @types.Image, RegistrationConfigAdvanced) -> RegistrationResultAdvanced
pub fn registration_report_to_string_advanced(RegistrationResultAdvanced) -> String
pub fn RegistrationAlgorithm::equal(Self, Self) -> Bool
pub fn RegistrationAlgorithm::not_equal(Self, Self) -> Bool
pub fn TransformType::equal(Self, Self) -> Bool
pub fn TransformType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
