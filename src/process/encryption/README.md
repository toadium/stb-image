# walkzzz/image/process/encryption

> 图像加密与解密（XOR、Arnold、混沌、LSB 水印）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 29 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ArnoldParams {
pub(all) struct ChaoticParams {
pub(all) enum EncryptionAlgorithm {
pub(all) struct EncryptionConfig {
pub(all) struct EncryptionQuality {
pub(all) struct EncryptionResult {
pub(all) struct ImageEncryptionQuality {
pub(all) struct WatermarkExtractionResult {
pub(all) struct WatermarkInfo {
pub(all) enum WatermarkType {
```

## API

```moonbit
pub fn adjacent_correlation(@types.Image, direction? : String) -> Double raise @types.LoadError
pub fn arnold_scramble(@types.Image, ArnoldParams) -> EncryptionResult raise @types.LoadError
pub fn batch_encrypt(Array[@types.Image], Double) -> Array[@types.Image] raise @types.LoadError
pub fn calculate_correlation(@types.Image, @types.Image) -> Double raise @types.LoadError
pub fn calculate_image_entropy(@types.Image) -> Double raise @types.LoadError
pub fn calculate_psnr(@types.Image, @types.Image) -> Double raise @types.LoadError
pub fn chaotic_encrypt(@types.Image, ChaoticParams) -> EncryptionResult raise @types.LoadError
pub fn create_default_arnold_params() -> ArnoldParams
pub fn create_default_chaotic_params() -> ChaoticParams
pub fn decrypt_image_logistic(@types.Image, key? : Double, mu? : Double) -> @types.Image raise @types.LoadError
pub fn decrypt_image_xor(@types.Image, String) -> @types.Image raise @types.LoadError
pub fn embed_visible_watermark(@types.Image, String, Int, Int, Double) -> @types.Image raise @types.LoadError
pub fn embed_watermark_lsb(@types.Image, Array[Byte], Int) -> (@types.Image, WatermarkInfo) raise @types.LoadError
pub fn encrypt_image_logistic(@types.Image, key? : Double, mu? : Double) -> @types.Image raise @types.LoadError
pub fn encrypt_image_xor(@types.Image, String) -> @types.Image raise @types.LoadError
pub fn encryption_default_config() -> EncryptionConfig
pub fn encryption_report_to_string(EncryptionResult, WatermarkInfo, ImageEncryptionQuality) -> String
pub fn evaluate_encryption_quality(@types.Image, @types.Image) -> EncryptionQuality raise @types.LoadError
pub fn evaluate_image_encryption_quality(@types.Image, @types.Image) -> ImageEncryptionQuality raise @types.LoadError
pub fn extract_watermark_lsb(@types.Image, Int, Int) -> WatermarkExtractionResult raise @types.LoadError
pub fn generate_chaotic_sequence_enc(ChaoticParams, Int) -> Array[Double]
pub fn histogram_entropy(@types.Image) -> Double raise @types.LoadError
pub fn key_sensitivity_test(@types.Image, Double, delta? : Double) -> Double raise @types.LoadError
pub fn xor_decrypt(EncryptionResult, Array[Byte]) -> @types.Image
pub fn xor_encrypt(@types.Image, Array[Byte]) -> EncryptionResult raise @types.LoadError
pub fn EncryptionAlgorithm::equal(Self, Self) -> Bool
pub fn EncryptionAlgorithm::not_equal(Self, Self) -> Bool
pub fn WatermarkType::equal(Self, Self) -> Bool
pub fn WatermarkType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
