# walkzzz/image/process/image_translation_advanced

> 图像翻译高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 13 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AdvancedStyleTransferResult {
pub(all) struct DayNightTransferResult {
pub(all) struct DomainAdaptationResult {
pub(all) struct ImageTranslationConfig {
pub(all) struct ImageTranslationResult {
pub(all) enum ImageTranslationTaskType {
pub(all) struct MapToSatelliteResult {
pub(all) struct SeasonTransferResult {
pub(all) enum SeasonType {
pub(all) struct SketchToPhotoResult {
pub(all) enum TranslationModelType {
pub(all) struct WeatherTransferResult {
pub(all) enum WeatherType {
```

## API

```moonbit
pub fn advanced_style_transfer(Array[Double], Array[Double], Int, Int, ImageTranslationConfig) -> AdvancedStyleTransferResult
pub fn create_default_translation_config() -> ImageTranslationConfig
pub fn image_translation_report_to_string(ImageTranslationTaskType, ImageTranslationConfig, String) -> String
pub fn transfer_day_night(Array[Double], Int, Int, ImageTranslationConfig) -> DayNightTransferResult
pub fn transfer_season(Array[Double], Int, Int, ImageTranslationConfig) -> SeasonTransferResult
pub fn transfer_weather(Array[Double], Int, Int, ImageTranslationConfig) -> WeatherTransferResult
pub fn translate_image(Array[Double], Int, Int, ImageTranslationConfig) -> ImageTranslationResult
pub fn ImageTranslationTaskType::equal(Self, Self) -> Bool
pub fn ImageTranslationTaskType::not_equal(Self, Self) -> Bool
pub fn SeasonType::equal(Self, Self) -> Bool
pub fn SeasonType::not_equal(Self, Self) -> Bool
pub fn TranslationModelType::equal(Self, Self) -> Bool
pub fn TranslationModelType::not_equal(Self, Self) -> Bool
pub fn WeatherType::equal(Self, Self) -> Bool
pub fn WeatherType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
