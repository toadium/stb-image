# walkzzz/image/process/image_retrieval_advanced

> 图像检索高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum FeatureDescriptorType {
pub(all) struct FeatureExtractionResult {
pub(all) struct ImageRetrievalConfig {
pub(all) enum ImageRetrievalTaskType {
pub(all) struct IndexConstructionResult {
pub(all) enum IndexStructureType {
pub(all) struct QueryExpansionResult {
pub(all) struct RelevanceFeedbackResult {
pub(all) struct RetrievalResult {
pub(all) enum SimilarityMetricType {
pub(all) struct SimilarityResult {
```

## API

```moonbit
pub fn build_index(Array[Array[Double]], IndexStructureType) -> IndexConstructionResult
pub fn calculate_similarity(Array[Double], Array[Double], SimilarityMetricType) -> Double
pub fn create_default_retrieval_config() -> ImageRetrievalConfig
pub fn expand_query(Array[Double], Array[Array[Double]], ImageRetrievalConfig) -> QueryExpansionResult
pub fn extract_features(Array[Double], Int, Int, ImageRetrievalConfig) -> FeatureExtractionResult
pub fn image_retrieval_report_to_string(ImageRetrievalTaskType, ImageRetrievalConfig, String) -> String
pub fn relevance_feedback(Array[Double], Array[Int], Array[Int], Array[Array[Double]], ImageRetrievalConfig) -> RelevanceFeedbackResult
pub fn retrieve_images(Array[Double], Int, Int, Array[Array[Double]], ImageRetrievalConfig) -> RetrievalResult
pub fn FeatureDescriptorType::equal(Self, Self) -> Bool
pub fn FeatureDescriptorType::not_equal(Self, Self) -> Bool
pub fn ImageRetrievalTaskType::equal(Self, Self) -> Bool
pub fn ImageRetrievalTaskType::not_equal(Self, Self) -> Bool
pub fn IndexStructureType::equal(Self, Self) -> Bool
pub fn IndexStructureType::not_equal(Self, Self) -> Bool
pub fn SimilarityMetricType::equal(Self, Self) -> Bool
pub fn SimilarityMetricType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
