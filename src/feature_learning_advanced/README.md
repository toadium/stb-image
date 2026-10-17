# walkzzz/image/process/feature_learning_advanced

> 特征学习高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 19 |
| 公开类型 | 14 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ContrastiveLearningResult {
pub(all) enum FeatureExtractionMethodType {
pub(all) struct FeatureExtractionResult {
pub(all) enum FeatureFusionMethodType {
pub(all) struct FeatureFusionResult {
pub(all) struct FeatureLearningConfig {
pub(all) struct FeatureLearningResult {
pub(all) enum FeatureLearningTaskType {
pub(all) enum FeatureSelectionMethodType {
pub(all) struct FeatureSelectionResult {
pub(all) enum FeatureTransformationMethodType {
pub(all) struct FeatureTransformationResult {
pub(all) enum MetricLearningMethodType {
pub(all) struct MetricLearningResult {
```

## API

```moonbit
pub fn create_default_feature_learning_config() -> FeatureLearningConfig
pub fn extract_features_fl(Array[Array[Double]], Array[Int], Array[Int], FeatureLearningConfig) -> FeatureExtractionResult
pub fn feature_learning_report_to_string(FeatureLearningTaskType, FeatureLearningConfig, String) -> String
pub fn fuse_features_fl(Array[Array[Array[Double]]], FeatureLearningConfig) -> FeatureFusionResult
pub fn learn_features(Array[Array[Double]], FeatureLearningConfig) -> FeatureLearningResult
pub fn select_features_fl(Array[Array[Double]], Int, FeatureLearningConfig) -> FeatureSelectionResult
pub fn transform_features_fl(Array[Array[Double]], FeatureLearningConfig) -> FeatureTransformationResult
pub fn FeatureExtractionMethodType::equal(Self, Self) -> Bool
pub fn FeatureExtractionMethodType::not_equal(Self, Self) -> Bool
pub fn FeatureFusionMethodType::equal(Self, Self) -> Bool
pub fn FeatureFusionMethodType::not_equal(Self, Self) -> Bool
pub fn FeatureLearningTaskType::equal(Self, Self) -> Bool
pub fn FeatureLearningTaskType::not_equal(Self, Self) -> Bool
pub fn FeatureSelectionMethodType::equal(Self, Self) -> Bool
pub fn FeatureSelectionMethodType::not_equal(Self, Self) -> Bool
pub fn FeatureTransformationMethodType::equal(Self, Self) -> Bool
pub fn FeatureTransformationMethodType::not_equal(Self, Self) -> Bool
pub fn MetricLearningMethodType::equal(Self, Self) -> Bool
pub fn MetricLearningMethodType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
