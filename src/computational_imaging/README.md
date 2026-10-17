# walkzzz/image/process/computational_imaging

> 计算成像（去模糊、反卷积）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 18 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CTProjectionData {
pub(all) struct CodedAperturePattern {
pub(all) enum ComputationalImagingAlgorithm {
pub(all) struct Hologram {
pub(all) enum HologramType {
pub(all) struct ImagingReconstructionResult {
pub(all) struct LightFieldCameraParams {
pub(all) struct LightFieldData {
pub(all) enum LightFieldRepresentation {
pub(all) struct PhaseRetrievalConfig {
pub(all) struct RefocusResult {
pub(all) struct ViewSynthesisResult {
```

## API

```moonbit
pub fn coded_aperture_reconstruct(@types.Image, CodedAperturePattern) -> ImagingReconstructionResult
pub fn computational_imaging_report_to_string(ImagingReconstructionResult, String) -> String
pub fn create_default_coded_aperture(Int) -> CodedAperturePattern
pub fn create_default_lightfield_camera() -> LightFieldCameraParams
pub fn create_default_phase_config() -> PhaseRetrievalConfig
pub fn ct_reconstruct_fbp(CTProjectionData, Int) -> ImagingReconstructionResult
pub fn generate_hologram(@types.Image, Double, Double, Double) -> Hologram
pub fn generate_sample_lightfield(@types.Image, LightFieldCameraParams) -> LightFieldData
pub fn lightfield_refocus(LightFieldData, Double, Double) -> RefocusResult
pub fn phase_retrieval(@types.Image, PhaseRetrievalConfig) -> ImagingReconstructionResult
pub fn reconstruct_hologram(Hologram) -> ImagingReconstructionResult
pub fn synthesize_view(LightFieldData, Double, Double) -> ViewSynthesisResult
pub fn ComputationalImagingAlgorithm::equal(Self, Self) -> Bool
pub fn ComputationalImagingAlgorithm::not_equal(Self, Self) -> Bool
pub fn HologramType::equal(Self, Self) -> Bool
pub fn HologramType::not_equal(Self, Self) -> Bool
pub fn LightFieldRepresentation::equal(Self, Self) -> Bool
pub fn LightFieldRepresentation::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
