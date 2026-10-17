# walkzzz/image/process/knowledge_graph

> 知识图谱

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 18 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum EntityLinkingMethod {
pub(all) struct EntityLinkingResult {
pub(all) struct KGConfig {
pub(all) enum KGConstructionMethod {
pub(all) struct KGEmbedding {
pub(all) struct KGEntity {
pub(all) struct KGRelation {
pub(all) struct KnowledgeGraph {
pub(all) enum KnowledgeReasoningMethod {
pub(all) struct KnowledgeReasoningResult {
pub(all) enum RelationExtractionMethod {
pub(all) struct RelationExtractionResult {
```

## API

```moonbit
pub fn add_entity(KnowledgeGraph, KGEntity) -> KnowledgeGraph
pub fn add_relation(KnowledgeGraph, KGRelation) -> KnowledgeGraph
pub fn compute_kg_statistics(KnowledgeGraph) -> (Double, Double, Double)
pub fn create_default_kg_config() -> KGConfig
pub fn create_empty_knowledge_graph(KGConstructionMethod) -> KnowledgeGraph
pub fn extract_relation(String, String, String, KGConfig) -> RelationExtractionResult
pub fn knowledge_graph_report_to_string(KnowledgeGraph, KGConfig, KGEmbedding) -> String
pub fn link_entity(String, KnowledgeGraph, KGConfig) -> EntityLinkingResult
pub fn reason_over_kg(String, KnowledgeGraph, KGConfig) -> KnowledgeReasoningResult
pub fn train_kg_embedding(KnowledgeGraph, KGConfig) -> KGEmbedding
pub fn EntityLinkingMethod::equal(Self, Self) -> Bool
pub fn EntityLinkingMethod::not_equal(Self, Self) -> Bool
pub fn KGConstructionMethod::equal(Self, Self) -> Bool
pub fn KGConstructionMethod::not_equal(Self, Self) -> Bool
pub fn KnowledgeReasoningMethod::equal(Self, Self) -> Bool
pub fn KnowledgeReasoningMethod::not_equal(Self, Self) -> Bool
pub fn RelationExtractionMethod::equal(Self, Self) -> Bool
pub fn RelationExtractionMethod::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
