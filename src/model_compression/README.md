# walkzzz/image/process/model_compression

> 模型压缩

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 21 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DeploymentConfig {
pub(all) struct DeploymentResult {
pub(all) enum DeploymentTarget {
pub(all) struct KnowledgeDistillationConfig {
pub(all) struct LowRankConfig {
pub(all) enum ModelCompressionMethod {
pub(all) struct ModelCompressionResult {
pub(all) struct ModelOptimizationConfig {
pub(all) struct PruningConfig {
pub(all) enum PruningType {
pub(all) struct QuantizationConfig {
pub(all) enum QuantizationType {
```

## API

```moonbit
pub fn create_default_deployment_config() -> DeploymentConfig
pub fn create_default_distillation_config() -> KnowledgeDistillationConfig
pub fn create_default_lowrank_config() -> LowRankConfig
pub fn create_default_optimization_config() -> ModelOptimizationConfig
pub fn create_default_pruning_config() -> PruningConfig
pub fn create_default_quantization_config() -> QuantizationConfig
pub fn deploy_model(Double, Double, DeploymentConfig) -> DeploymentResult
pub fn knowledge_distillation(Double, Double, Int, Int, KnowledgeDistillationConfig) -> ModelCompressionResult
pub fn low_rank_factorization(Double, Int, Int, LowRankConfig) -> ModelCompressionResult
pub fn model_compression_report_to_string(ModelCompressionResult, String) -> String
pub fn optimize_model_inference(Double, Double, ModelOptimizationConfig) -> (Double, Double, Double)
pub fn prune_model(Double, Int, Int, PruningConfig) -> ModelCompressionResult
pub fn quantize_model(Double, Int, Int, QuantizationConfig) -> ModelCompressionResult
pub fn DeploymentTarget::equal(Self, Self) -> Bool
pub fn DeploymentTarget::not_equal(Self, Self) -> Bool
pub fn ModelCompressionMethod::equal(Self, Self) -> Bool
pub fn ModelCompressionMethod::not_equal(Self, Self) -> Bool
pub fn PruningType::equal(Self, Self) -> Bool
pub fn PruningType::not_equal(Self, Self) -> Bool
pub fn QuantizationType::equal(Self, Self) -> Bool
pub fn QuantizationType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
