# walkzzz/image/process/image_classification_advanced

> 图像分类高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 14 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ClassificationResult {
pub(all) enum ClassifierType {
pub(all) struct EnsembleClassificationResult {
pub(all) enum EnsembleMethodType {
pub(all) enum FeatureExtractionMethod {
pub(all) struct FineGrainedClassificationResult {
pub(all) struct ImageClassificationConfig {
pub(all) enum ImageClassificationTaskType {
pub(all) struct MultiLabelClassificationResult {
pub(all) struct TrainingResult {
```

## API

```moonbit
pub fn classify_ensemble(Array[Double], Int, Int, ImageClassificationConfig) -> EnsembleClassificationResult
pub fn classify_image(Array[Double], Int, Int, ImageClassificationConfig) -> ClassificationResult
pub fn classify_multi_label(Array[Double], Int, Int, Int, Double, ImageClassificationConfig) -> MultiLabelClassificationResult
pub fn create_default_classification_config() -> ImageClassificationConfig
pub fn image_classification_report_to_string(ImageClassificationTaskType, ImageClassificationConfig, String) -> String
pub fn train_classifier(Array[Array[Double]], Array[Int], ImageClassificationConfig) -> TrainingResult
pub fn ClassifierType::equal(Self, Self) -> Bool
pub fn ClassifierType::not_equal(Self, Self) -> Bool
pub fn EnsembleMethodType::equal(Self, Self) -> Bool
pub fn EnsembleMethodType::not_equal(Self, Self) -> Bool
pub fn FeatureExtractionMethod::equal(Self, Self) -> Bool
pub fn FeatureExtractionMethod::not_equal(Self, Self) -> Bool
pub fn ImageClassificationTaskType::equal(Self, Self) -> Bool
pub fn ImageClassificationTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
