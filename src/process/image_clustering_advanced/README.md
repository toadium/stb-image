# walkzzz/image/process/image_clustering_advanced

> 图像聚类高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum ClusteringAlgorithmType {
pub(all) struct ClusteringEvaluationResult {
pub(all) struct ClusteringResult {
pub(all) struct DBSCANResult {
pub(all) enum DistanceMetricType {
pub(all) struct FuzzyCMeansResult {
pub(all) struct GMMResult {
pub(all) struct HierarchicalClusteringResult {
pub(all) struct ImageClusteringConfig {
pub(all) enum ImageClusteringTaskType {
pub(all) struct KMeansResult {
pub(all) enum LinkageType {
```

## API

```moonbit
pub fn calculate_silhouette_score(Array[Array[Double]], Array[Int]) -> Double
pub fn cluster_images(Array[Array[Double]], ImageClusteringConfig) -> ClusteringResult
pub fn create_default_clustering_config() -> ImageClusteringConfig
pub fn dbscan_clustering(Array[Array[Double]], Double, Int, ImageClusteringConfig) -> DBSCANResult
pub fn hierarchical_clustering(Array[Array[Double]], Int, ImageClusteringConfig) -> HierarchicalClusteringResult
pub fn image_clustering_report_to_string(ImageClusteringTaskType, ImageClusteringConfig, String) -> String
pub fn kmeans_clustering(Array[Array[Double]], Int, ImageClusteringConfig) -> KMeansResult
pub fn ClusteringAlgorithmType::equal(Self, Self) -> Bool
pub fn ClusteringAlgorithmType::not_equal(Self, Self) -> Bool
pub fn DistanceMetricType::equal(Self, Self) -> Bool
pub fn DistanceMetricType::not_equal(Self, Self) -> Bool
pub fn ImageClusteringTaskType::equal(Self, Self) -> Bool
pub fn ImageClusteringTaskType::not_equal(Self, Self) -> Bool
pub fn LinkageType::equal(Self, Self) -> Bool
pub fn LinkageType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
