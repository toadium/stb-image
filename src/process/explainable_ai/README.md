# walkzzz/image/process/explainable_ai

> 可解释 AI

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 11 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ConfusionMatrix {
pub(all) struct EmbeddingVisualization {
pub(all) enum ExplainabilityMethod {
pub(all) struct ExplainableAIConfig {
pub(all) struct FeatureImportanceResult {
pub(all) struct FeatureMapVisualization {
pub(all) struct ModelPerformanceMetrics {
pub(all) enum ModelVisualizationType {
pub(all) struct ROCCurveData {
pub(all) struct SaliencyMapResult {
```

## API

```moonbit
pub fn compute_feature_importance(@types.Image, ExplainableAIConfig) -> FeatureImportanceResult raise @types.LoadError
pub fn create_default_explainable_ai_config() -> ExplainableAIConfig
pub fn explainable_ai_report_to_string(FeatureImportanceResult, SaliencyMapResult, ModelPerformanceMetrics) -> String
pub fn generate_confusion_matrix(Array[Int], Array[Int], Int, Array[String]) -> ConfusionMatrix
pub fn generate_roc_curve(Array[Double], Array[Int], Int) -> ROCCurveData
pub fn generate_saliency_map(@types.Image, ExplainableAIConfig) -> SaliencyMapResult raise @types.LoadError
pub fn visualize_feature_maps(@types.Image, Int, String) -> FeatureMapVisualization raise @types.LoadError
pub fn ExplainabilityMethod::equal(Self, Self) -> Bool
pub fn ExplainabilityMethod::not_equal(Self, Self) -> Bool
pub fn ModelVisualizationType::equal(Self, Self) -> Bool
pub fn ModelVisualizationType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
