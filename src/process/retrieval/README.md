# walkzzz/image/process/retrieval

> 图像检索（特征索引、相似度匹配）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 28 |
| 公开类型 | 13 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CBIRImageFeature {
pub(all) struct CBIRImageIndex {
pub(all) struct CBIRRetrievalResult {
pub(all) struct CBIRRetrievalResultList {
pub(all) struct ColorHistogramConfig {
pub(all) enum FeatureType {
pub(all) struct GaborConfig {
pub(all) struct HOGConfig {
pub(all) struct ImageDatabase {
pub(all) struct ImageFeature {
pub(all) struct LBPConfig {
pub(all) struct SearchResult {
pub(all) enum SimilarityMetric {
```

## API

```moonbit
pub fn add_to_index(CBIRImageIndex, CBIRImageFeature) -> CBIRImageIndex
pub fn batch_extract_features(Array[(@types.Image, String)]) -> Array[ImageFeature]
pub fn calculate_similarity(Array[Double], Array[Double], SimilarityMetric) -> Double
pub fn cosine_similarity_cbir(Array[Double], Array[Double]) -> Double
pub fn create_default_color_histogram_config() -> ColorHistogramConfig
pub fn create_default_hog_config() -> HOGConfig
pub fn create_default_lbp_config() -> LBPConfig
pub fn create_image_index() -> CBIRImageIndex
pub fn database_add_image(ImageDatabase, ImageFeature) -> ImageDatabase
pub fn database_remove_image(ImageDatabase, String) -> ImageDatabase
pub fn database_size(ImageDatabase) -> Int
pub fn euclidean_distance_cbir(Array[Double], Array[Double]) -> Double
pub fn extract_color_histogram(@types.Image, ColorHistogramConfig) -> CBIRImageFeature
pub fn extract_combined_features(@types.Image) -> CBIRImageFeature
pub fn extract_hog_feature(@types.Image, HOGConfig) -> CBIRImageFeature
pub fn extract_image_features(@types.Image, String) -> ImageFeature
pub fn extract_lbp_feature(@types.Image, LBPConfig) -> CBIRImageFeature
pub fn histogram_intersection_cbir(Array[Double], Array[Double]) -> Double
pub fn image_database_new() -> ImageDatabase
pub fn image_similarity(@types.Image, @types.Image, method_type? : String) -> Double
pub fn manhattan_distance_cbir(Array[Double], Array[Double]) -> Double
pub fn retrieval_report_to_string(CBIRRetrievalResultList, CBIRImageFeature) -> String
pub fn retrieve_images(CBIRImageFeature, CBIRImageIndex, Int, SimilarityMetric) -> CBIRRetrievalResultList
pub fn search_similar_images(ImageDatabase, ImageFeature, top_k? : Int, method_type? : String) -> Array[SearchResult]
pub fn FeatureType::equal(Self, Self) -> Bool
pub fn FeatureType::not_equal(Self, Self) -> Bool
pub fn SimilarityMetric::equal(Self, Self) -> Bool
pub fn SimilarityMetric::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
