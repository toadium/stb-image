# walkzzz/image/process/federated_learning

> 联邦学习

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 20 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum DPMechanism {
pub(all) struct DifferentialPrivacyConfig {
pub(all) struct EncryptedData {
pub(all) struct FederatedClient {
pub(all) enum FederatedLearningAlgorithm {
pub(all) struct FederatedLearningConfig {
pub(all) struct FederatedTrainingResult {
pub(all) struct HomomorphicEncryptionConfig {
pub(all) enum HomomorphicEncryptionType {
pub(all) struct PrivacyProtectionResult {
pub(all) enum PrivacyTechnology {
pub(all) struct SecureMPCConfig {
```

## API

```moonbit
pub fn add_dp_noise(Double, DifferentialPrivacyConfig) -> Double
pub fn create_default_dp_config() -> DifferentialPrivacyConfig
pub fn create_default_federated_config() -> FederatedLearningConfig
pub fn create_default_he_config() -> HomomorphicEncryptionConfig
pub fn create_default_mpc_config() -> SecureMPCConfig
pub fn create_federated_clients(Int, Int, FederatedLearningConfig) -> Array[FederatedClient]
pub fn decrypt_data(EncryptedData, HomomorphicEncryptionConfig) -> Array[Double]
pub fn encrypt_data(Array[Double], HomomorphicEncryptionConfig) -> EncryptedData
pub fn encrypted_add(EncryptedData, EncryptedData, HomomorphicEncryptionConfig) -> EncryptedData
pub fn evaluate_privacy_protection(Double, Double, DifferentialPrivacyConfig) -> PrivacyProtectionResult
pub fn federated_learning_report_to_string(FederatedTrainingResult, PrivacyProtectionResult, FederatedLearningConfig) -> String
pub fn simulate_federated_training(Array[FederatedClient], FederatedLearningConfig, Double) -> FederatedTrainingResult
pub fn DPMechanism::equal(Self, Self) -> Bool
pub fn DPMechanism::not_equal(Self, Self) -> Bool
pub fn FederatedLearningAlgorithm::equal(Self, Self) -> Bool
pub fn FederatedLearningAlgorithm::not_equal(Self, Self) -> Bool
pub fn HomomorphicEncryptionType::equal(Self, Self) -> Bool
pub fn HomomorphicEncryptionType::not_equal(Self, Self) -> Bool
pub fn PrivacyTechnology::equal(Self, Self) -> Bool
pub fn PrivacyTechnology::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
