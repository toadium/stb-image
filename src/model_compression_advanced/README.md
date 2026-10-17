# walkzzz/image/process/model_compression_advanced

> 模型压缩高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DistillationResult {
pub(all) enum KnowledgeDistillationType {
pub(all) enum LowRankFactorizationType {
pub(all) struct LowRankResult {
pub(all) struct ModelCompressionConfig {
pub(all) struct ModelCompressionResult {
pub(all) enum ModelCompressionTaskType {
pub(all) struct PruningResult {
pub(all) enum PruningType {
pub(all) struct QuantizationResult {
pub(all) enum QuantizationType {
```

## API

```moonbit
pub fn compress_model(Array[Array[Double]], ModelCompressionConfig) -> ModelCompressionResult
pub fn compression_report_to_string(ModelCompressionTaskType, ModelCompressionConfig, String) -> String
pub fn create_default_compression_config() -> ModelCompressionConfig
pub fn distill_model(Array[Array[Double]], Int, Int, ModelCompressionConfig) -> DistillationResult
pub fn low_rank_decomposition(Array[Array[Double]], ModelCompressionConfig) -> LowRankResult
pub fn prune_model(Array[Array[Double]], ModelCompressionConfig) -> PruningResult
pub fn quantize_model(Array[Array[Double]], ModelCompressionConfig) -> QuantizationResult
pub fn KnowledgeDistillationType::equal(Self, Self) -> Bool
pub fn KnowledgeDistillationType::not_equal(Self, Self) -> Bool
pub fn LowRankFactorizationType::equal(Self, Self) -> Bool
pub fn LowRankFactorizationType::not_equal(Self, Self) -> Bool
pub fn ModelCompressionTaskType::equal(Self, Self) -> Bool
pub fn ModelCompressionTaskType::not_equal(Self, Self) -> Bool
pub fn PruningType::equal(Self, Self) -> Bool
pub fn PruningType::not_equal(Self, Self) -> Bool
pub fn QuantizationType::equal(Self, Self) -> Bool
pub fn QuantizationType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
