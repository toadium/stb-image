# walkzzz/image/process/transfer_learning_advanced

> 迁移学习高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 21 |
| 公开类型 | 14 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum DomainAdaptationMethodType {
pub(all) struct DomainAdaptationResult {
pub(all) enum FewShotLearningMethodType {
pub(all) struct FewShotLearningResult {
pub(all) struct FineTuningResult {
pub(all) enum FineTuningStrategyType {
pub(all) struct KnowledgeDistillationResult {
pub(all) enum MultiTaskLearningMethodType {
pub(all) struct MultiTaskLearningResult {
pub(all) enum PretrainedModelType {
pub(all) struct PretrainingResult {
pub(all) struct TransferLearningConfig {
pub(all) struct TransferLearningResult {
pub(all) enum TransferLearningTaskType {
```

## API

```moonbit
pub fn create_default_transfer_learning_config() -> TransferLearningConfig
pub fn domain_adaptation(Array[Array[Double]], TransferLearningConfig) -> DomainAdaptationResult
pub fn few_shot_learning(Array[Array[Double]], Array[Array[Double]], TransferLearningConfig) -> FewShotLearningResult
pub fn fine_tune_model(Array[Array[Double]], Int, TransferLearningConfig) -> FineTuningResult
pub fn knowledge_distillation(Array[Array[Double]], Int, Int, TransferLearningConfig) -> KnowledgeDistillationResult
pub fn load_pretrained_model(PretrainedModelType, Int, Int) -> PretrainingResult
pub fn multi_task_learning(Int, Int, Int, TransferLearningConfig) -> MultiTaskLearningResult
pub fn transfer_learning(Array[Array[Double]], Array[Array[Double]], TransferLearningConfig) -> TransferLearningResult
pub fn transfer_learning_report_to_string(TransferLearningTaskType, TransferLearningConfig, String) -> String
pub fn DomainAdaptationMethodType::equal(Self, Self) -> Bool
pub fn DomainAdaptationMethodType::not_equal(Self, Self) -> Bool
pub fn FewShotLearningMethodType::equal(Self, Self) -> Bool
pub fn FewShotLearningMethodType::not_equal(Self, Self) -> Bool
pub fn FineTuningStrategyType::equal(Self, Self) -> Bool
pub fn FineTuningStrategyType::not_equal(Self, Self) -> Bool
pub fn MultiTaskLearningMethodType::equal(Self, Self) -> Bool
pub fn MultiTaskLearningMethodType::not_equal(Self, Self) -> Bool
pub fn PretrainedModelType::equal(Self, Self) -> Bool
pub fn PretrainedModelType::not_equal(Self, Self) -> Bool
pub fn TransferLearningTaskType::equal(Self, Self) -> Bool
pub fn TransferLearningTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
