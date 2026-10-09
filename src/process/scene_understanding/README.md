# walkzzz/image/process/scene_understanding

> 场景理解与语义分析

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 14 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum ImageCaptioningAlgorithm {
pub(all) struct ImageCaptioningResult {
pub(all) enum SceneClassificationAlgorithm {
pub(all) struct SceneClassificationResult {
pub(all) struct SceneGraph {
pub(all) struct SceneGraphNode {
pub(all) struct SceneGraphRelation {
pub(all) struct SceneUnderstandingConfig {
pub(all) enum VisualQuestionAnsweringAlgorithm {
pub(all) struct VisualQuestionAnsweringResult {
```

## API

```moonbit
pub fn answer_visual_question(@types.Image, String, SceneUnderstandingConfig) -> VisualQuestionAnsweringResult
pub fn classify_scene(@types.Image, SceneUnderstandingConfig) -> SceneClassificationResult
pub fn create_default_scene_config() -> SceneUnderstandingConfig
pub fn generate_caption(@types.Image, SceneUnderstandingConfig) -> ImageCaptioningResult
pub fn generate_scene_graph(@types.Image, SceneUnderstandingConfig) -> SceneGraph
pub fn get_common_scene_types() -> Array[String]
pub fn scene_understanding_report_to_string(SceneClassificationResult, ImageCaptioningResult, VisualQuestionAnsweringResult, SceneGraph) -> String
pub fn understand_scene(@types.Image, SceneUnderstandingConfig) -> (SceneClassificationResult, ImageCaptioningResult, SceneGraph)
pub fn ImageCaptioningAlgorithm::equal(Self, Self) -> Bool
pub fn ImageCaptioningAlgorithm::not_equal(Self, Self) -> Bool
pub fn SceneClassificationAlgorithm::equal(Self, Self) -> Bool
pub fn SceneClassificationAlgorithm::not_equal(Self, Self) -> Bool
pub fn VisualQuestionAnsweringAlgorithm::equal(Self, Self) -> Bool
pub fn VisualQuestionAnsweringAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
