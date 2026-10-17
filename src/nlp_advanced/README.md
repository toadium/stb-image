# walkzzz/image/process/nlp_advanced

> 自然语言处理高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct MachineTranslationResult {
pub(all) enum NEREntityType {
pub(all) struct NERResult {
pub(all) struct NLPConfig {
pub(all) enum NLPTaskType {
pub(all) struct QuestionAnsweringResult {
pub(all) struct SentimentAnalysisResult {
pub(all) enum SentimentType {
pub(all) enum TextClassificationModel {
pub(all) struct TextClassificationResult {
pub(all) struct TextEmbedding {
pub(all) struct TextSummarizationResult {
```

## API

```moonbit
pub fn analyze_sentiment(String) -> SentimentAnalysisResult
pub fn classify_text(String, Array[String], NLPConfig) -> TextClassificationResult
pub fn create_default_nlp_config() -> NLPConfig
pub fn embed_text(String, Int) -> TextEmbedding
pub fn nlp_report_to_string(NLPTaskType, NLPConfig, String) -> String
pub fn recognize_entities(String) -> NERResult
pub fn summarize_text(String, Int) -> TextSummarizationResult
pub fn tokenize(String) -> Array[String]
pub fn NEREntityType::equal(Self, Self) -> Bool
pub fn NEREntityType::not_equal(Self, Self) -> Bool
pub fn NLPTaskType::equal(Self, Self) -> Bool
pub fn NLPTaskType::not_equal(Self, Self) -> Bool
pub fn SentimentType::equal(Self, Self) -> Bool
pub fn SentimentType::not_equal(Self, Self) -> Bool
pub fn TextClassificationModel::equal(Self, Self) -> Bool
pub fn TextClassificationModel::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
