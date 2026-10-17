# walkzzz/image/process/advanced_imaging

> 高级成像算法

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AdvancedImagingConfig {
pub(all) struct HyperspectralData {
pub(all) enum ImagingModality {
pub(all) enum InfraredImagingType {
pub(all) struct MRIData {
pub(all) struct PETData {
pub(all) struct PolarizationData {
pub(all) enum QuantumImagingAlgorithm {
pub(all) struct ThermalData {
pub(all) struct UltrasoundData {
pub(all) struct XRayData {
```

## API

```moonbit
pub fn advanced_imaging_report_to_string(ImagingModality, @types.Image, AdvancedImagingConfig) -> String
pub fn analyze_polarization(@types.Image, @types.Image, @types.Image, @types.Image) -> PolarizationData
pub fn create_default_advanced_imaging_config(ImagingModality) -> AdvancedImagingConfig
pub fn generate_hyperspectral_cube(@types.Image, Int, Double, Double) -> HyperspectralData
pub fn infrared_pseudocolor(@types.Image, InfraredImagingType) -> @types.Image
pub fn mri_synthesize(Int, Int, Double) -> MRIData
pub fn pet_synthesize(Int, Int, String) -> PETData
pub fn quantum_ghost_imaging(Int, Int, Int, QuantumImagingAlgorithm) -> @types.Image
pub fn thermal_to_temperature(@types.Image, Double, Double, Double) -> ThermalData
pub fn ultrasound_synthesize(Int, Int, Double, Double) -> UltrasoundData
pub fn xray_enhance(@types.Image, Double) -> XRayData
pub fn ImagingModality::equal(Self, Self) -> Bool
pub fn ImagingModality::not_equal(Self, Self) -> Bool
pub fn InfraredImagingType::equal(Self, Self) -> Bool
pub fn InfraredImagingType::not_equal(Self, Self) -> Bool
pub fn QuantumImagingAlgorithm::equal(Self, Self) -> Bool
pub fn QuantumImagingAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
