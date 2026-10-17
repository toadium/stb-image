# walkzzz/image/process/representation_learning_advanced

> 表征学习高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 14 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AutoencoderResult {
pub(all) enum AutoencoderType {
pub(all) enum ContrastiveLearningMethodType {
pub(all) struct ContrastiveLearningResult {
pub(all) struct FineTuningResult {
pub(all) struct GANResult {
pub(all) enum GANType {
pub(all) struct PretrainingResult {
pub(all) struct RepresentationLearningConfig {
pub(all) struct RepresentationLearningResult {
pub(all) enum RepresentationLearningTaskType {
pub(all) struct SelfSupervisedLearningResult {
pub(all) enum SelfSupervisedTaskType {
pub(all) struct VAEResult {
```

## API

```moonbit
pub fn create_default_representation_learning_config() -> RepresentationLearningConfig
pub fn learn_representation(Array[Array[Double]], RepresentationLearningConfig) -> RepresentationLearningResult
pub fn representation_learning_report_to_string(RepresentationLearningTaskType, RepresentationLearningConfig, String) -> String
pub fn train_autoencoder(Array[Array[Double]], RepresentationLearningConfig) -> AutoencoderResult
pub fn train_contrastive(Array[Array[Double]], RepresentationLearningConfig) -> ContrastiveLearningResult
pub fn train_gan(Int, Int, Int, RepresentationLearningConfig) -> GANResult
pub fn train_vae(Array[Array[Double]], RepresentationLearningConfig) -> VAEResult
pub fn AutoencoderType::equal(Self, Self) -> Bool
pub fn AutoencoderType::not_equal(Self, Self) -> Bool
pub fn ContrastiveLearningMethodType::equal(Self, Self) -> Bool
pub fn ContrastiveLearningMethodType::not_equal(Self, Self) -> Bool
pub fn GANType::equal(Self, Self) -> Bool
pub fn GANType::not_equal(Self, Self) -> Bool
pub fn RepresentationLearningTaskType::equal(Self, Self) -> Bool
pub fn RepresentationLearningTaskType::not_equal(Self, Self) -> Bool
pub fn SelfSupervisedTaskType::equal(Self, Self) -> Bool
pub fn SelfSupervisedTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
