# walkzzz/image/process/medical_imaging_advanced

> 医学成像高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DetectedLesion {
pub(all) struct DiseaseClassificationResult {
pub(all) enum LesionType {
pub(all) enum MedicalImageType {
pub(all) struct MedicalImagingConfig {
pub(all) enum MedicalImagingTaskType {
pub(all) struct OrganSegmentationResult {
pub(all) enum OrganType {
pub(all) struct RadiomicsFeatures {
pub(all) struct Reconstruction3DResult {
pub(all) struct RegistrationResult {
pub(all) struct SegmentationResult {
```

## API

```moonbit
pub fn create_default_medical_config() -> MedicalImagingConfig
pub fn detect_lesions(Array[Double], Int, Int, MedicalImagingConfig) -> Array[DetectedLesion]
pub fn extract_radiomics_features(Array[Double], Array[Array[Bool]], MedicalImagingConfig) -> RadiomicsFeatures
pub fn medical_imaging_report_to_string(MedicalImagingTaskType, MedicalImagingConfig, String) -> String
pub fn register_medical_images(Array[Double], Array[Double], Int, Int, MedicalImagingConfig) -> RegistrationResult
pub fn segment_medical_image(Array[Double], Int, Int, MedicalImagingConfig) -> SegmentationResult
pub fn segment_organ(Array[Double], Int, Int, OrganType, MedicalImagingConfig) -> OrganSegmentationResult
pub fn LesionType::equal(Self, Self) -> Bool
pub fn LesionType::not_equal(Self, Self) -> Bool
pub fn MedicalImageType::equal(Self, Self) -> Bool
pub fn MedicalImageType::not_equal(Self, Self) -> Bool
pub fn MedicalImagingTaskType::equal(Self, Self) -> Bool
pub fn MedicalImagingTaskType::not_equal(Self, Self) -> Bool
pub fn OrganType::equal(Self, Self) -> Bool
pub fn OrganType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
