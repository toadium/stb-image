# walkzzz/image/process/dl_advanced

> 深度学习高级模块

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum AttentionType {
pub(all) struct AttentionWeights {
pub(all) enum DLAdvancedTaskType {
pub(all) struct FineTuningConfig {
pub(all) struct PretrainedModelConfig {
pub(all) enum PretrainingTask {
pub(all) struct SelfSupervisedConfig {
pub(all) struct TransferLearningResult {
pub(all) enum TransformerArchitecture {
pub(all) struct TransformerConfig {
pub(all) struct TransformerLayerOutput {
```

## API

```moonbit
pub fn compute_self_attention(Array[Array[Double]], Array[Array[Double]], Array[Array[Double]], Int, Int) -> AttentionWeights
pub fn create_default_finetuning_config() -> FineTuningConfig
pub fn create_default_pretrained_config() -> PretrainedModelConfig
pub fn create_default_transformer_config() -> TransformerConfig
pub fn dl_advanced_report_to_string(DLAdvancedTaskType, TransformerConfig, String) -> String
pub fn simulate_finetuning(FineTuningConfig, Double) -> TransferLearningResult
pub fn transformer_forward(Array[Array[Double]], TransformerConfig) -> TransformerLayerOutput
pub fn AttentionType::equal(Self, Self) -> Bool
pub fn AttentionType::not_equal(Self, Self) -> Bool
pub fn DLAdvancedTaskType::equal(Self, Self) -> Bool
pub fn DLAdvancedTaskType::not_equal(Self, Self) -> Bool
pub fn PretrainingTask::equal(Self, Self) -> Bool
pub fn PretrainingTask::not_equal(Self, Self) -> Bool
pub fn TransformerArchitecture::equal(Self, Self) -> Bool
pub fn TransformerArchitecture::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
