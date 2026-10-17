# walkzzz/image/process/reinforcement_learning

> 强化学习

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct Experience {
pub(all) enum ExplorationStrategy {
pub(all) struct PolicyEvaluationResult {
pub(all) struct RLAgent {
pub(all) enum RLAlgorithm {
pub(all) struct RLConfig {
pub(all) struct RLEnvironment {
pub(all) struct RLTrainingResult {
pub(all) struct ReplayBuffer {
pub(all) enum ReplayBufferType {
```

## API

```moonbit
pub fn add_experience(ReplayBuffer, Experience) -> ReplayBuffer
pub fn create_default_rl_config() -> RLConfig
pub fn create_q_learning_agent(Int, Int, Double, Double, Double) -> RLAgent
pub fn create_replay_buffer(Int, Int, ReplayBufferType) -> ReplayBuffer
pub fn create_rl_environment(String, Int, Int, Int, Int, Bool, Int) -> RLEnvironment
pub fn evaluate_policy(RLAgent, RLEnvironment, Int) -> PolicyEvaluationResult
pub fn q_learning_update(RLAgent, Int, Int, Double, Int, Bool) -> RLAgent
pub fn reinforcement_learning_report_to_string(RLTrainingResult, RLConfig, RLEnvironment) -> String
pub fn sample_experiences(ReplayBuffer, Int) -> Array[Experience]
pub fn select_action(RLAgent, Int) -> Int
pub fn simulate_rl_training(RLConfig, RLEnvironment) -> RLTrainingResult
pub fn ExplorationStrategy::equal(Self, Self) -> Bool
pub fn ExplorationStrategy::not_equal(Self, Self) -> Bool
pub fn RLAlgorithm::equal(Self, Self) -> Bool
pub fn RLAlgorithm::not_equal(Self, Self) -> Bool
pub fn ReplayBufferType::equal(Self, Self) -> Bool
pub fn ReplayBufferType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
