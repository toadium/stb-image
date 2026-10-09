# walkzzz/image/process/face_recognition

> 人脸识别与属性分析

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 18 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AgeGenderEstimationResult {
pub(all) struct ExpressionRecognitionResult {
pub(all) enum ExpressionType {
pub(all) struct FaceAttributeAnalysis {
pub(all) struct FaceDatabase {
pub(all) enum FaceDetectionAlgorithm {
pub(all) struct FaceDetectionResult {
pub(all) struct FaceFeature {
pub(all) enum FaceRecognitionAlgorithm {
pub(all) struct FaceRecognitionConfig {
pub(all) struct FaceRecognitionResult {
```

## API

```moonbit
pub fn add_face_to_database(FaceDatabase, FaceFeature, String) -> FaceDatabase
pub fn analyze_face_attributes(@types.Image, FaceDetectionResult, FaceDatabase, FaceRecognitionConfig) -> FaceAttributeAnalysis raise @types.LoadError
pub fn calculate_cosine_similarity(FaceFeature, FaceFeature) -> Double
pub fn create_default_face_config() -> FaceRecognitionConfig
pub fn create_face_database(FaceRecognitionAlgorithm, Double) -> FaceDatabase
pub fn detect_faces(@types.Image, FaceRecognitionConfig) -> Array[FaceDetectionResult] raise @types.LoadError
pub fn estimate_age_gender(@types.Image, FaceDetectionResult) -> AgeGenderEstimationResult raise @types.LoadError
pub fn evaluate_face_quality(@types.Image, FaceDetectionResult) -> Double raise @types.LoadError
pub fn extract_face_feature(@types.Image, FaceDetectionResult, FaceRecognitionConfig) -> FaceFeature raise @types.LoadError
pub fn face_recognition_report_to_string(FaceAttributeAnalysis) -> String
pub fn recognize_expression(@types.Image, FaceDetectionResult) -> ExpressionRecognitionResult raise @types.LoadError
pub fn recognize_face_in_database(FaceDatabase, FaceFeature, Array[Double]) -> FaceRecognitionResult
pub fn ExpressionType::equal(Self, Self) -> Bool
pub fn ExpressionType::not_equal(Self, Self) -> Bool
pub fn FaceDetectionAlgorithm::equal(Self, Self) -> Bool
pub fn FaceDetectionAlgorithm::not_equal(Self, Self) -> Bool
pub fn FaceRecognitionAlgorithm::equal(Self, Self) -> Bool
pub fn FaceRecognitionAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
