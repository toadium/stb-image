# walkzzz/image/process/meta_learning_advanced

> 元学习高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct MAMLResult {
pub(all) struct MatchingNetResult {
pub(all) enum MetaLearningAlgorithmType {
pub(all) struct MetaLearningConfig {
pub(all) struct MetaLearningResult {
pub(all) enum MetaLearningTaskType {
pub(all) enum MetaOptimizerType {
pub(all) struct ProtoNetResult {
pub(all) struct RelationNetResult {
pub(all) struct ReptileResult {
pub(all) enum TaskDistributionType {
```

## API

```moonbit
pub fn create_default_meta_learning_config() -> MetaLearningConfig
pub fn meta_learn(Int, MetaLearningConfig) -> MetaLearningResult
pub fn meta_learning_report_to_string(MetaLearningTaskType, MetaLearningConfig, String) -> String
pub fn train_maml(Int, MetaLearningConfig) -> MAMLResult
pub fn train_matching_net(Array[Array[Double]], Array[Array[Double]], MetaLearningConfig) -> MatchingNetResult
pub fn train_protonet(Array[Array[Double]], Array[Array[Double]], MetaLearningConfig) -> ProtoNetResult
pub fn train_relation_net(Array[Array[Double]], Array[Double], MetaLearningConfig) -> RelationNetResult
pub fn train_reptile(Int, MetaLearningConfig) -> ReptileResult
pub fn MetaLearningAlgorithmType::equal(Self, Self) -> Bool
pub fn MetaLearningAlgorithmType::not_equal(Self, Self) -> Bool
pub fn MetaLearningTaskType::equal(Self, Self) -> Bool
pub fn MetaLearningTaskType::not_equal(Self, Self) -> Bool
pub fn MetaOptimizerType::equal(Self, Self) -> Bool
pub fn MetaOptimizerType::not_equal(Self, Self) -> Bool
pub fn TaskDistributionType::equal(Self, Self) -> Bool
pub fn TaskDistributionType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
