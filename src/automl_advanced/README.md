# walkzzz/image/process/automl_advanced

> AutoML 高级自动化

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AutoMLConfig {
pub(all) struct AutoMLResult {
pub(all) enum AutoMLTaskType {
pub(all) enum FeatureEngineeringMethodType {
pub(all) struct FeatureEngineeringResult {
pub(all) enum HPOAlgorithmType {
pub(all) struct HPOResult {
pub(all) struct ModelSelectionResult {
pub(all) enum ModelSelectionStrategyType {
pub(all) enum NASAlgorithmType {
pub(all) struct NASResult {
```

## API

```moonbit
pub fn automated_feature_engineering(Int, AutoMLConfig) -> FeatureEngineeringResult
pub fn automated_model_selection(Array[String], AutoMLConfig) -> ModelSelectionResult
pub fn automl(Int, AutoMLConfig) -> AutoMLResult
pub fn automl_report_to_string(AutoMLTaskType, AutoMLConfig, String) -> String
pub fn create_default_automl_config() -> AutoMLConfig
pub fn neural_architecture_search(Int, Int, AutoMLConfig) -> NASResult
pub fn optimize_hyperparameters(Int, AutoMLConfig) -> HPOResult
pub fn AutoMLTaskType::equal(Self, Self) -> Bool
pub fn AutoMLTaskType::not_equal(Self, Self) -> Bool
pub fn FeatureEngineeringMethodType::equal(Self, Self) -> Bool
pub fn FeatureEngineeringMethodType::not_equal(Self, Self) -> Bool
pub fn HPOAlgorithmType::equal(Self, Self) -> Bool
pub fn HPOAlgorithmType::not_equal(Self, Self) -> Bool
pub fn ModelSelectionStrategyType::equal(Self, Self) -> Bool
pub fn ModelSelectionStrategyType::not_equal(Self, Self) -> Bool
pub fn NASAlgorithmType::equal(Self, Self) -> Bool
pub fn NASAlgorithmType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
