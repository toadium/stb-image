# walkzzz/image/process/automl_nas

> 神经架构搜索

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct HPOConfig {
pub(all) struct HyperparameterConfig {
pub(all) enum HyperparameterOptimizationAlgorithm {
pub(all) enum LayerType {
pub(all) struct ModelEvaluationMetrics {
pub(all) enum NASAlgorithm {
pub(all) struct NASConfig {
pub(all) struct NetworkArchitecture {
pub(all) struct SearchResult {
pub(all) enum SearchSpaceType {
```

## API

```moonbit
pub fn automl_report_to_string(SearchResult, NASConfig, ModelEvaluationMetrics) -> String
pub fn create_default_hpo_config() -> HPOConfig
pub fn create_default_nas_config() -> NASConfig
pub fn evaluate_model(NetworkArchitecture, HyperparameterConfig) -> ModelEvaluationMetrics
pub fn generate_random_architecture(Int, Int) -> NetworkArchitecture
pub fn generate_random_hyperparameters() -> HyperparameterConfig
pub fn perform_hpo(HPOConfig, NetworkArchitecture) -> SearchResult
pub fn perform_nas(NASConfig) -> SearchResult
pub fn HyperparameterOptimizationAlgorithm::equal(Self, Self) -> Bool
pub fn HyperparameterOptimizationAlgorithm::not_equal(Self, Self) -> Bool
pub fn LayerType::equal(Self, Self) -> Bool
pub fn LayerType::not_equal(Self, Self) -> Bool
pub fn NASAlgorithm::equal(Self, Self) -> Bool
pub fn NASAlgorithm::not_equal(Self, Self) -> Bool
pub fn SearchSpaceType::equal(Self, Self) -> Bool
pub fn SearchSpaceType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
