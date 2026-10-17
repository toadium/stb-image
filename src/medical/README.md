# walkzzz/image/process/medical

> 医学图像处理（DICOM、CT、MRI、超声、病理）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 22 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct Lesion {
pub(all) struct MedicalImage {
pub(all) struct MedicalImageQuality {
pub(all) enum MedicalImageType {
pub(all) struct MedicalRegistrationResult {
pub(all) struct MedicalSegmentationConfig {
pub(all) struct RegionOfInterest {
pub(all) struct WindowLevel {
pub(all) struct WindowLevelConfig {
```

## API

```moonbit
pub fn apply_window_level(@types.Image, WindowLevel) -> @types.Image
pub fn apply_window_level_medical(MedicalImage, WindowLevelConfig) -> @types.Image
pub fn calculate_medical_image_quality(MedicalImage) -> MedicalImageQuality
pub fn calculate_roi_stats(MedicalImage, Array[Bool]) -> (Double, Double, Int)
pub fn create_default_medical_segmentation_config() -> MedicalSegmentationConfig
pub fn create_default_window_level(String) -> WindowLevelConfig
pub fn detect_lesions_simple(MedicalImage, Double, Double) -> Array[Lesion]
pub fn measure_area(@types.Image, pixel_area? : Double) -> Double
pub fn measure_distance(Int, Int, Int, Int, pixel_spacing? : Double) -> Double
pub fn medical_colormap(@types.Image, colormap? : String) -> @types.Image
pub fn medical_contrast_enhance(@types.Image, clip_limit? : Double, tile_size? : Int) -> @types.Image
pub fn medical_denoise(@types.Image, iterations? : Int, kappa? : Double) -> @types.Image
pub fn medical_image_registration(MedicalImage, MedicalImage, Int) -> MedicalRegistrationResult
pub fn medical_image_report_to_string(MedicalImage, Array[Lesion], MedicalImageQuality) -> String
pub fn medical_threshold_segmentation(MedicalImage, Double, Double) -> Array[Bool]
pub fn region_growing_segmentation(MedicalImage, Int, Int, Int, Double) -> Array[Bool]
pub fn window_level_bone() -> WindowLevel
pub fn window_level_brain() -> WindowLevel
pub fn window_level_lung() -> WindowLevel
pub fn window_level_mediastinum() -> WindowLevel
pub fn MedicalImageType::equal(Self, Self) -> Bool
pub fn MedicalImageType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
