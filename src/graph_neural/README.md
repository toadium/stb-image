# walkzzz/image/process/graph_neural

> 图神经网络

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 14 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CommunityDetectionResult {
pub(all) struct GNNConfig {
pub(all) enum GNNLayerType {
pub(all) struct GraphData {
pub(all) struct GraphEdge {
pub(all) struct GraphNode {
pub(all) enum GraphTaskType {
pub(all) struct NodeEmbeddingResult {
pub(all) struct RelationPredictionResult {
pub(all) struct RelationReasoningConfig {
pub(all) enum RelationType {
```

## API

```moonbit
pub fn create_default_gnn_config() -> GNNConfig
pub fn create_default_reasoning_config() -> RelationReasoningConfig
pub fn create_random_graph(Int, Int, Int, Bool) -> GraphData
pub fn detect_communities(GraphData, Int) -> CommunityDetectionResult
pub fn graph_attention(GraphData, GNNConfig) -> NodeEmbeddingResult
pub fn graph_convolution(GraphData, GNNConfig) -> NodeEmbeddingResult
pub fn graph_neural_report_to_string(NodeEmbeddingResult, GraphData, GNNConfig) -> String
pub fn predict_relation(GraphData, Int, Int, RelationReasoningConfig) -> RelationPredictionResult
pub fn GNNLayerType::equal(Self, Self) -> Bool
pub fn GNNLayerType::not_equal(Self, Self) -> Bool
pub fn GraphTaskType::equal(Self, Self) -> Bool
pub fn GraphTaskType::not_equal(Self, Self) -> Bool
pub fn RelationType::equal(Self, Self) -> Bool
pub fn RelationType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
