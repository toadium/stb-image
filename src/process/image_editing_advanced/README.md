# walkzzz/image/process/image_editing_advanced

> 图像编辑高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 14 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AgeTransformationResult {
pub(all) struct BackgroundReplacementResult {
pub(all) struct BeautyRetouchResult {
pub(all) enum BeautyType {
pub(all) enum CutoutMethod {
pub(all) struct CutoutResult {
pub(all) struct ExpressionEditingResult {
pub(all) struct FaceEditingResult {
pub(all) struct ImageEditingConfig {
pub(all) enum ImageEditingTaskType {
pub(all) struct MakeupResult {
pub(all) enum MakeupType {
pub(all) enum ObjectRemovalMethod {
pub(all) struct ObjectRemovalResult {
```

## API

```moonbit
pub fn beauty_retouch(Array[Double], Int, Int, ImageEditingConfig) -> BeautyRetouchResult
pub fn create_default_editing_config() -> ImageEditingConfig
pub fn image_editing_report_to_string(ImageEditingTaskType, ImageEditingConfig, String) -> String
pub fn remove_objects(Array[Double], Array[Bool], Int, Int, ImageEditingConfig) -> ObjectRemovalResult
pub fn replace_background(Array[Double], Array[Double], Array[Double], Int, Int, ImageEditingConfig) -> BackgroundReplacementResult
pub fn smart_cutout(Array[Double], Int, Int, ImageEditingConfig) -> CutoutResult
pub fn BeautyType::equal(Self, Self) -> Bool
pub fn BeautyType::not_equal(Self, Self) -> Bool
pub fn CutoutMethod::equal(Self, Self) -> Bool
pub fn CutoutMethod::not_equal(Self, Self) -> Bool
pub fn ImageEditingTaskType::equal(Self, Self) -> Bool
pub fn ImageEditingTaskType::not_equal(Self, Self) -> Bool
pub fn MakeupType::equal(Self, Self) -> Bool
pub fn MakeupType::not_equal(Self, Self) -> Bool
pub fn ObjectRemovalMethod::equal(Self, Self) -> Bool
pub fn ObjectRemovalMethod::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
