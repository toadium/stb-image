# walkzzz/image/process/multimodal_advanced

> 多模态高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 12 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AudioVisualResult {
pub(all) struct CrossModalRetrievalResult {
pub(all) enum FusionStrategy {
pub(all) struct ImageTextGenerationResult {
pub(all) enum ModalityType {
pub(all) struct MultimodalConfig {
pub(all) struct MultimodalData {
pub(all) struct MultimodalFusionResult {
pub(all) enum MultimodalTaskType {
pub(all) struct VideoUnderstandingResult {
```

## API

```moonbit
pub fn cosine_similarity(Array[Double], Array[Double]) -> Double
pub fn create_default_multimodal_config() -> MultimodalConfig
pub fn create_multimodal_data(String, Int, Array[ModalityType]) -> MultimodalData
pub fn cross_modal_retrieval(MultimodalData, Array[MultimodalData], ModalityType, ModalityType, Int) -> CrossModalRetrievalResult
pub fn fuse_multimodal(MultimodalData, MultimodalConfig) -> MultimodalFusionResult
pub fn multimodal_report_to_string(MultimodalTaskType, MultimodalConfig, String) -> String
pub fn FusionStrategy::equal(Self, Self) -> Bool
pub fn FusionStrategy::not_equal(Self, Self) -> Bool
pub fn ModalityType::equal(Self, Self) -> Bool
pub fn ModalityType::not_equal(Self, Self) -> Bool
pub fn MultimodalTaskType::equal(Self, Self) -> Bool
pub fn MultimodalTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
