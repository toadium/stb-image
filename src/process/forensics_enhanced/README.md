# walkzzz/image/process/forensics_enhanced

> 增强图像取证

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 9 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CfaAnalysisResult {
pub(all) struct CloneDetectionResult {
pub(all) struct DctCoefficientResult {
pub(all) struct ElaAnalysisResult {
pub(all) struct IlluminationConsistencyResult {
pub(all) struct JpegGhostResult {
pub(all) struct MetadataForensicsResult {
pub(all) struct NoiseResidualResult {
pub(all) struct TamperDetectionResult {
```

## API

```moonbit
pub fn analyze_cfa_pattern(@types.Image) -> CfaAnalysisResult
pub fn analyze_dct_coefficients(@types.Image) -> DctCoefficientResult
pub fn analyze_ela(@types.Image, Int) -> ElaAnalysisResult raise @types.LoadError
pub fn analyze_illumination_consistency(@types.Image) -> IlluminationConsistencyResult
pub fn analyze_jpeg_ghost(@types.Image) -> JpegGhostResult
pub fn analyze_metadata_forensics(@types.Image) -> MetadataForensicsResult
pub fn analyze_noise_residual(@types.Image) -> NoiseResidualResult
pub fn detect_clone_regions(@types.Image, Int, Double) -> CloneDetectionResult raise @types.LoadError
pub fn detect_tamper_comprehensive(@types.Image, Int) -> TamperDetectionResult raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
