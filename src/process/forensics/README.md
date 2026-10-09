# walkzzz/image/process/forensics

> 图像取证与鉴真

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 23 |
| 公开类型 | 18 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ColorAnalysisResult {
pub(all) struct ColorQuantizationResult {
pub(all) struct CompressionAnalysisResult {
pub(all) struct DetailAnalysisResult {
pub(all) struct EdgeAnalysisResult {
pub(all) struct EnhancedVerificationConfig {
pub(all) struct EnhancedVerificationFeatures {
pub(all) struct EnhancedVerificationResult {
pub(all) struct FrequencyAnalysisResult {
pub(all) struct GeometryAnalysisResult {
pub(all) enum ImageSourceType {
pub(all) struct NoiseAnalysisResult {
pub(all) struct SourceVerificationConfig {
pub(all) struct SourceVerificationFeatures {
pub(all) struct SourceVerificationResult {
pub(all) struct TextDetectionResult {
pub(all) struct TextureAnalysisResult {
pub(all) struct UIDetectionResult {
```

## API

```moonbit
pub fn analyze_color_distribution(@types.Image) -> ColorAnalysisResult raise @types.LoadError
pub fn analyze_color_quantization(@types.Image) -> ColorQuantizationResult raise @types.LoadError
pub fn analyze_compression_artifacts(@types.Image) -> CompressionAnalysisResult raise @types.LoadError
pub fn analyze_details(@types.Image) -> DetailAnalysisResult raise @types.LoadError
pub fn analyze_edge_directions(@types.Image) -> Double raise @types.LoadError
pub fn analyze_edges(@types.Image) -> EdgeAnalysisResult raise @types.LoadError
pub fn analyze_frequency_domain(@types.Image) -> FrequencyAnalysisResult raise @types.LoadError
pub fn analyze_geometry(@types.Image) -> GeometryAnalysisResult raise @types.LoadError
pub fn analyze_noise_pattern(@types.Image) -> NoiseAnalysisResult raise @types.LoadError
pub fn analyze_pixel_distribution(@types.Image) -> Double raise @types.LoadError
pub fn analyze_solid_areas(@types.Image) -> Double raise @types.LoadError
pub fn analyze_texture(@types.Image) -> TextureAnalysisResult raise @types.LoadError
pub fn create_default_enhanced_verification_config() -> EnhancedVerificationConfig
pub fn create_default_source_verification_config() -> SourceVerificationConfig
pub fn detect_text_regions(@types.Image) -> TextDetectionResult raise @types.LoadError
pub fn detect_ui_elements(@types.Image) -> UIDetectionResult raise @types.LoadError
pub fn enhanced_verification_report_to_string(EnhancedVerificationResult) -> String
pub fn intelligent_decision(SourceVerificationResult, UIDetectionResult, TextDetectionResult, GeometryAnalysisResult, ColorQuantizationResult, Double, Double, Double, EnhancedVerificationConfig) -> (ImageSourceType, Double, Double, Double, String)
pub fn source_verification_report_to_string(SourceVerificationResult) -> String
pub fn verify_image_source(@types.Image, SourceVerificationConfig) -> SourceVerificationResult raise @types.LoadError
pub fn verify_image_source_enhanced(@types.Image, EnhancedVerificationConfig) -> EnhancedVerificationResult raise @types.LoadError
pub fn ImageSourceType::equal(Self, Self) -> Bool
pub fn ImageSourceType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
