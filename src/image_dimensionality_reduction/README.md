# walkzzz/image/process/image_dimensionality_reduction

> 图像降维

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum DimensionalityReductionAlgorithmType {
pub(all) struct DimensionalityReductionConfig {
pub(all) struct DimensionalityReductionResult {
pub(all) enum DimensionalityReductionTaskType {
pub(all) enum DistanceMetricTypeDR {
pub(all) struct FeatureSelectionResult {
pub(all) struct ISOMAPResult {
pub(all) enum KernelType {
pub(all) struct LLEResult {
pub(all) struct PCAResult {
pub(all) struct TSNEResult {
pub(all) struct UMAPResult {
```

## API

```moonbit
pub fn create_default_dr_config() -> DimensionalityReductionConfig
pub fn dimensionality_reduction_report_to_string(DimensionalityReductionTaskType, DimensionalityReductionConfig, String) -> String
pub fn pca_reduce(Array[Array[Double]], Int, DimensionalityReductionConfig) -> PCAResult
pub fn reduce_dimensionality(Array[Array[Double]], DimensionalityReductionConfig) -> DimensionalityReductionResult
pub fn select_features(Array[Array[Double]], Double) -> FeatureSelectionResult
pub fn tsne_reduce(Array[Array[Double]], Int, DimensionalityReductionConfig) -> TSNEResult
pub fn umap_reduce(Array[Array[Double]], Int, DimensionalityReductionConfig) -> UMAPResult
pub fn DimensionalityReductionAlgorithmType::equal(Self, Self) -> Bool
pub fn DimensionalityReductionAlgorithmType::not_equal(Self, Self) -> Bool
pub fn DimensionalityReductionTaskType::equal(Self, Self) -> Bool
pub fn DimensionalityReductionTaskType::not_equal(Self, Self) -> Bool
pub fn DistanceMetricTypeDR::equal(Self, Self) -> Bool
pub fn DistanceMetricTypeDR::not_equal(Self, Self) -> Bool
pub fn KernelType::equal(Self, Self) -> Bool
pub fn KernelType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
