# walkzzz/image/process/continuous_learning

> 持续学习

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 18 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ContinualLearningConfig {
pub(all) struct ContinualLearningMetrics {
pub(all) enum ContinualLearningStrategy {
pub(all) struct EWCConfig {
pub(all) enum IncrementalLearningScenario {
pub(all) struct KnowledgeDistillationConfigCL {
pub(all) struct LearningTask {
pub(all) struct MemoryBuffer {
pub(all) enum RegularizationMethod {
pub(all) enum ReplayMethod {
```

## API

```moonbit
pub fn add_to_memory(MemoryBuffer, Array[Double], Int, Int) -> MemoryBuffer
pub fn compute_ewc_loss(Array[Double], EWCConfig) -> Double
pub fn continual_learning_report_to_string(ContinualLearningMetrics, ContinualLearningConfig) -> String
pub fn create_default_continual_config() -> ContinualLearningConfig
pub fn create_default_ewc_config(Int) -> EWCConfig
pub fn create_memory_buffer(Int, String) -> MemoryBuffer
pub fn create_task_sequence(Int, Int, Int) -> Array[LearningTask]
pub fn sample_from_memory(MemoryBuffer, Int) -> (Array[Array[Double]], Array[Int], Array[Int])
pub fn simulate_continual_learning(Array[LearningTask], ContinualLearningConfig, Double) -> ContinualLearningMetrics
pub fn update_fisher_information(EWCConfig, Array[Double]) -> EWCConfig
pub fn ContinualLearningStrategy::equal(Self, Self) -> Bool
pub fn ContinualLearningStrategy::not_equal(Self, Self) -> Bool
pub fn IncrementalLearningScenario::equal(Self, Self) -> Bool
pub fn IncrementalLearningScenario::not_equal(Self, Self) -> Bool
pub fn RegularizationMethod::equal(Self, Self) -> Bool
pub fn RegularizationMethod::not_equal(Self, Self) -> Bool
pub fn ReplayMethod::equal(Self, Self) -> Bool
pub fn ReplayMethod::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
