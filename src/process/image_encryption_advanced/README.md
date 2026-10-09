# walkzzz/image/process/image_encryption_advanced

> 图像加密高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ChaoticEncryptionResult {
pub(all) enum ChaoticSystemType {
pub(all) enum DNAEncodingType {
pub(all) struct DNAEncryptionResult {
pub(all) struct DecryptionResult {
pub(all) struct DigitalWatermarkResult {
pub(all) enum EncryptionAlgorithmType {
pub(all) struct EncryptionResult {
pub(all) struct ImageEncryptionConfig {
pub(all) enum ImageEncryptionTaskType {
pub(all) struct SteganographyResult {
pub(all) enum SteganographyType {
```

## API

```moonbit
pub fn chaotic_encrypt(Array[Double], Int, Int, ImageEncryptionConfig) -> ChaoticEncryptionResult
pub fn create_default_encryption_config() -> ImageEncryptionConfig
pub fn decrypt_image(Array[Byte], Int, Int, Array[Byte], ImageEncryptionConfig) -> DecryptionResult
pub fn embed_steganography(Array[Double], Int, Int, Array[Byte], ImageEncryptionConfig) -> SteganographyResult
pub fn embed_watermark(Array[Double], Int, Int, Array[Byte], ImageEncryptionConfig) -> DigitalWatermarkResult
pub fn encrypt_image(Array[Double], Int, Int, Array[Byte], ImageEncryptionConfig) -> EncryptionResult
pub fn image_encryption_report_to_string(ImageEncryptionTaskType, ImageEncryptionConfig, String) -> String
pub fn ChaoticSystemType::equal(Self, Self) -> Bool
pub fn ChaoticSystemType::not_equal(Self, Self) -> Bool
pub fn DNAEncodingType::equal(Self, Self) -> Bool
pub fn DNAEncodingType::not_equal(Self, Self) -> Bool
pub fn EncryptionAlgorithmType::equal(Self, Self) -> Bool
pub fn EncryptionAlgorithmType::not_equal(Self, Self) -> Bool
pub fn ImageEncryptionTaskType::equal(Self, Self) -> Bool
pub fn ImageEncryptionTaskType::not_equal(Self, Self) -> Bool
pub fn SteganographyType::equal(Self, Self) -> Bool
pub fn SteganographyType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
