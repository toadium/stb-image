# walkzzz/image/process/ocr

> OCR 全流程（版面分析、二值化、倾斜校正、字符分割、识别、后处理）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 352 |
| 公开类型 | 142 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AccuracyStats {
pub(all) struct AdaptivePreprocessConfig {
pub(all) struct AdvancedChineseOcrConfig {
pub(all) struct ApiServerConfig {
pub(all) struct AugmentationConfig {
pub(all) enum AugmentationType {
pub(all) struct BatchOcrConfig {
pub(all) struct BatchProgress {
pub(all) struct BatchResultSummary {
pub(all) struct BatchTask {
pub(all) enum BatchTaskStatus {
pub(all) struct CharRecognitionResult {
pub(all) struct CharSegment {
pub(all) struct ChineseCharInfo {
pub(all) struct ChineseCharStructure {
pub(all) struct ChineseOcrConfig {
pub(all) struct ChineseRadical {
pub(all) struct ClassificationResult {
pub(all) struct CliConfig {
pub(all) struct CommonErrorPattern {
pub(all) struct ComplexLayoutAnalysis {
pub(all) enum ComplexLayoutType {
pub(all) struct ConfusionEntry {
pub(all) struct ConfusionMatrix {
pub(all) struct CorrectionEntry {
pub(all) struct CorrectionResult {
pub(all) struct DLCnnModelConfig {
pub(all) struct DLConv2DConfig {
pub(all) struct DLDenseConfig {
pub(all) struct DLFeatureExtractor {
pub(all) struct DLInferenceResult {
pub(all) enum DLLayerType {
pub(all) struct DLNeuralLayer {
pub(all) struct DLTrainingHistory {
pub(all) struct DLTrainingSample {
pub(all) struct DataLoader {
pub(all) enum DeploymentEnvironment {
pub(all) struct DictCharEntry {
pub(all) struct DictCharMatch {
pub(all) enum DictCharStructure {
pub(all) struct DictChineseDict {
pub(all) struct DictComponent {
pub(all) struct DictComponentResult {
pub(all) struct Dictionary {
pub(all) struct DictionaryEntry {
pub(all) struct DigitOcrConfig {
pub(all) enum DistanceMetric {
pub(all) struct DistortionDetectionResult {
pub(all) enum DistortionType {
pub(all) struct DockerConfig {
pub(all) struct DocumentBlock {
pub(all) enum DocumentBlockType {
pub(all) struct DocumentElement {
pub(all) enum DocumentElementType {
pub(all) struct DocumentStructure {
pub(all) struct DocumentTreeNode {
pub(all) struct DocumentUnderstandingEnhancedConfig {
pub(all) struct DropFallResult {
pub(all) struct EnglishOcrConfig {
pub(all) struct EnhancedChineseOcrConfig {
pub(all) struct EnhancedDocument {
pub(all) struct EnhancedDocumentElement {
pub(all) struct EnhancedTableResult {
pub(all) struct EnsembleConfig {
pub(all) struct ErrorAnalysisEntry {
pub(all) struct ErrorAnalysisReport {
pub(all) struct ExtractedImage {
pub(all) struct GridFeatures {
pub(all) struct HandwritingCharFeature {
pub(all) struct HandwritingOcrConfig {
pub(all) struct HandwritingOcrEnhancedConfig {
pub(all) struct HandwritingRecognitionConfig {
pub(all) struct HandwritingRecognitionResult {
pub(all) struct HandwritingStrokeFeatures {
pub(all) enum HandwritingStyle {
pub(all) struct HandwritingTemplate {
pub(all) struct HogFeatures {
pub(all) struct KnnClassifier {
pub(all) struct LRSchedulerConfig {
pub(all) enum LRSchedulerType {
pub(all) struct LanguageDetectionResult {
pub(all) struct LanguageModelState {
pub(all) enum LanguageType {
pub(all) enum LayoutType {
pub(all) struct LbpFeatures {
pub(all) struct ListItemInfo {
pub(all) enum ListItemType {
pub(all) struct MarkdownDocument {
pub(all) struct MarkdownElement {
pub(all) enum MarkdownElementType {
pub(all) struct MarkdownImage {
pub(all) struct MarkdownSymbol {
pub(all) struct MarkdownTable {
pub(all) struct MemoryUsageStats {
pub(all) struct ModelPackageConfig {
pub(all) struct MultilingualOcrConfig {
pub(all) struct MultilingualOcrEnhancedConfig {
pub(all) struct NgramModel {
pub(all) struct OCRPageResult {
pub(all) struct OcrAccuracyEnhancedConfig {
pub(all) struct OcrCharResult {
pub(all) struct OcrConnectedComponent {
pub(all) struct OcrConnectedComponentsResult {
pub(all) enum OcrErrorType {
pub(all) struct OcrResult {
pub(all) struct OptimizerConfig {
pub(all) enum OptimizerType {
pub(all) struct PageRegion {
pub(all) enum PageRegionType {
pub(all) struct PerformanceBenchmark {
pub(all) struct PostProcessConfig {
pub(all) struct ProjectionFeatures {
pub(all) struct ProjectionResult {
pub(all) struct PunctuationTemplate {
pub(all) struct RobustnessReport {
pub(all) struct ScanOCRConfig {
pub(all) struct ScanQuality {
pub(all) enum ScanQualityLevel {
pub(all) struct SimilarCharMapping {
pub(all) struct SplitPoint {
pub(all) struct StatisticalFeatures {
pub(all) struct StrokeFeature {
pub(all) struct StrokeSegmentationResult {
pub(all) enum StrokeType {
pub(all) struct TableCell {
pub(all) struct TableCellContent {
pub(all) struct TableDetectionResult {
pub(all) struct TableLine {
pub(all) enum TableLineType {
pub(all) struct TableStructure {
pub(all) struct TemplateMatcher {
pub(all) struct TextBlock {
pub(all) struct TextLine {
pub(all) struct TextLineAttributes {
pub(all) struct TextLineInfo {
pub(all) struct TextRegion {
pub(all) enum TextRegionType {
pub(all) struct TrainingConfig {
pub(all) struct TrainingDataset {
pub(all) struct TrainingMetrics {
pub(all) struct TrainingSample {
pub(all) struct TrainingState {
```

## API

```moonbit
pub fn adaptive_threshold_ocr(@types.Image, block_size? : Int, c? : Int) -> @types.Image raise @types.LoadError
pub fn advanced_chinese_ocr_default_config() -> AdvancedChineseOcrConfig
pub fn analyze_complex_layout(Array[TextBlock], Int, Int) -> ComplexLayoutAnalysis
pub fn analyze_document_layout(@types.Image) -> DocumentStructure raise @types.LoadError
pub fn analyze_layout_enhanced(@types.Image, config? : DocumentUnderstandingEnhancedConfig) -> Array[DocumentBlock] raise @types.LoadError
pub fn analyze_layout_scan(@types.Image) -> Array[TextBlock] raise @types.LoadError
pub fn analyze_markdown_element_distribution(MarkdownDocument) -> Array[(String, Int)]
pub fn analyze_table_results(Array[EnhancedTableResult]) -> Array[(String, Int)]
pub fn analyze_table_structure(Array[TableLine], Array[TableLine]) -> TableStructure raise @types.LoadError
pub fn apply_augmentation(DLTrainingSample, AugmentationConfig) -> DLTrainingSample
pub fn augment_features(Array[Double], noise_level? : Double) -> Array[Double]
pub fn augment_random_noise(DLTrainingSample, Double) -> DLTrainingSample
pub fn augment_random_rotation(DLTrainingSample, Double) -> DLTrainingSample
pub fn augment_random_scale(DLTrainingSample, Double) -> DLTrainingSample
pub fn augment_random_shift(DLTrainingSample, Double) -> DLTrainingSample
pub fn background_normalization(@types.Image, kernel_size? : Int) -> @types.Image raise @types.LoadError
pub fn batch_correct_texts(Array[String], context_type? : String) -> Array[CorrectionResult] raise @types.LoadError
pub fn batch_recognize_chars(Array[@types.Image], DLCnnModelConfig, Array[String]) -> Array[DLInferenceResult] raise @types.LoadError
pub fn batch_scan_ocr(Array[@types.Image], ScanOCRConfig) -> Array[OCRPageResult] raise @types.LoadError
pub fn batch_summary_to_string(BatchResultSummary) -> String
pub fn build_document_structure_tree(Array[DocumentBlock]) -> Array[DocumentTreeNode]
pub fn build_enhanced_elements(Array[TextLineAttributes], Int, Int) -> EnhancedDocument raise @types.LoadError
pub fn build_gaussian_kernel_lut(Double, Int) -> Array[Double] raise @types.LoadError
pub fn build_grayscale_lut() -> Array[Int]
pub fn build_markdown_document(OCRPageResult, title? : String) -> MarkdownDocument raise @types.LoadError
pub fn build_threshold_lut(Int) -> Array[Int]
pub fn cache_friendly_horizontal_projection(@types.Image) -> Array[Int] raise @types.LoadError
pub fn cache_friendly_vertical_projection(@types.Image) -> Array[Int] raise @types.LoadError
pub fn calculate_accuracy(Array[Int], Array[Int]) -> Double
pub fn calculate_accuracy_improvement(Array[CorrectionResult], Array[String]) -> (Double, Double, Double)
pub fn calculate_accuracy_stats(Array[String], Array[String]) -> AccuracyStats raise @types.LoadError
pub fn calculate_batch_progress(Array[BatchTask], Double) -> BatchProgress raise @types.LoadError
pub fn calculate_char_accuracy(String, String) -> Double
pub fn calculate_chinese_similarity(DictCharEntry, DictCharEntry) -> Double
pub fn calculate_edit_distance(String, String) -> Int
pub fn calculate_learning_rate(LRSchedulerConfig, Int, Double, Double) -> Double raise @types.LoadError
pub fn calculate_word_accuracy(String, String) -> Double
pub fn calibrate_confidence(OcrResult, factor? : Double) -> OcrResult raise @types.LoadError
pub fn calibrate_confidence_enhanced(Double, Array[Double]) -> Double
pub fn chebyshev_distance(Array[Double], Array[Double]) -> Double raise @types.LoadError
pub fn check_accuracy_threshold(AccuracyStats, min_char_accuracy? : Double, min_word_accuracy? : Double, min_f1_score? : Double) -> (Bool, Array[String]) raise @types.LoadError
pub fn check_early_stopping(TrainingState, TrainingConfig, Double) -> (Bool, TrainingState)
pub fn chinese_ocr_default_config() -> ChineseOcrConfig
pub fn classify_markdown_element(TextBlock, avg_font_size? : Double) -> MarkdownElementType
pub fn cnn_confusion_matrix(Array[DLTrainingSample], DLCnnModelConfig, Array[String]) -> Array[Array[Int]] raise @types.LoadError
pub fn cnn_infer(Array[Double], DLCnnModelConfig, Array[String]) -> DLInferenceResult
pub fn cnn_recognize_char(@types.Image, DLCnnModelConfig, Array[String]) -> DLInferenceResult raise @types.LoadError
pub fn cnn_recognize_digits(@types.Image, DLCnnModelConfig) -> DLInferenceResult raise @types.LoadError
pub fn cnn_recognize_letters(@types.Image, DLCnnModelConfig) -> DLInferenceResult raise @types.LoadError
pub fn cnn_train(Array[DLTrainingSample], Array[Double], Array[Double], Array[Double], Array[Double], Int, Int, Int, Int, Int, Int, Double, Int) -> (Array[Double], Array[Double], Array[Double], Array[Double], Array[DLTrainingHistory]) raise @types.LoadError
pub fn cnn_train_step(Array[Double], Int, Array[Double], Array[Double], Array[Double], Array[Double], Int, Int, Int, Int, Int, Int, Double) -> (Array[Double], Array[Double], Array[Double], Array[Double], Double) raise @types.LoadError
pub fn combined_features(@types.Image) -> Array[Double] raise @types.LoadError
pub fn complete_char_segmentation(@types.Image, min_char_width? : Int, max_char_width? : Int) -> Array[(Int, Int, Int, Int)] raise @types.LoadError
pub fn compute_confusion_matrix(Array[Int], Array[Int], Int) -> Array[Array[Int]]
pub fn compute_distance(Array[Double], Array[Double], DistanceMetric) -> Double raise @types.LoadError
pub fn compute_per_class_accuracy(Array[Array[Int]]) -> Array[Double]
pub fn compute_reading_order(Array[DocumentElement]) -> Array[Int] raise @types.LoadError
pub fn connected_components_analysis(@types.Image, connectivity? : Int) -> OcrConnectedComponentsResult raise @types.LoadError
pub fn conv2d(Array[Double], Int, Int, Int, Array[Double], Int, Int, Int, Int) -> Array[Double] raise @types.LoadError
pub fn correct_common_patterns(String) -> CorrectionResult
pub fn correct_similar_chars(String, String) -> CorrectionResult raise @types.LoadError
pub fn correct_slant(@types.Image, max_slant? : Double) -> @types.Image raise @types.LoadError
pub fn cosine_distance(Array[Double], Array[Double]) -> Double raise @types.LoadError
pub fn cosine_similarity(Array[Double], Array[Double]) -> Double
pub fn create_batch_tasks(Array[String], String, String) -> Array[BatchTask] raise @types.LoadError
pub fn create_data_loader(Array[DLTrainingSample], Int, Bool) -> DataLoader raise @types.LoadError
pub fn create_default_api_server_config() -> ApiServerConfig
pub fn create_default_batch_config() -> BatchOcrConfig
pub fn create_default_char_cnn_config(Int) -> DLCnnModelConfig
pub fn create_default_chinese_dictionary() -> DictChineseDict
pub fn create_default_cli_config() -> CliConfig
pub fn create_default_docker_config() -> DockerConfig
pub fn create_default_handwriting_config() -> HandwritingRecognitionConfig
pub fn create_default_language_model() -> LanguageModelState
pub fn create_default_model_package_config() -> ModelPackageConfig
pub fn create_default_training_config() -> TrainingConfig
pub fn create_feature_extractor(String, Int) -> DLFeatureExtractor
pub fn create_handwriting_template(String, HandwritingStyle, Array[@types.Image]) -> HandwritingTemplate raise @types.LoadError
pub fn create_neural_layer(DLLayerType, String, Array[Int]) -> DLNeuralLayer
pub fn create_training_history(Int, Double, Double, Double, Double, Double, Double) -> DLTrainingHistory
pub fn create_training_sample(@types.Image, Int, String) -> DLTrainingSample raise @types.LoadError
pub fn create_training_state() -> TrainingState
pub fn cross_entropy_loss(Array[Double], Int) -> Double
pub fn dataset_add_sample(TrainingDataset, Array[Double], String) -> TrainingDataset
pub fn dataset_create() -> TrainingDataset
pub fn dataset_stats(TrainingDataset) -> (Int, Int, Array[(String, Int)])
pub fn decompose_chinese_char(String) -> ChineseCharStructure raise @types.LoadError
pub fn dense_backward(Array[Double], Array[Double], Int, Int) -> (Array[Double], Array[Double], Array[Double])
pub fn dense_forward(Array[Double], Array[Double], Array[Double], Int, Int, String) -> Array[Double]
pub fn deskew(@types.Image) -> @types.Image raise @types.LoadError
pub fn detect_char_language(@types.Image) -> LanguageType raise @types.LoadError
pub fn detect_column_boundaries(Array[TextLineAttributes], Int, LayoutType) -> Array[Int]
pub fn detect_columns(@types.Image) -> (Int, Array[(Int, Int)]) raise @types.LoadError
pub fn detect_distortions(@types.Image) -> Array[DistortionDetectionResult] raise @types.LoadError
pub fn detect_document_columns(@types.Image) -> Int raise @types.LoadError
pub fn detect_document_language(@types.Image) -> LanguageType raise @types.LoadError
pub fn detect_handwriting_slant(@types.Image) -> Double raise @types.LoadError
pub fn detect_header_footer(Array[TextLineAttributes], Int) -> (Int, Int) raise @types.LoadError
pub fn detect_horizontal_lines(@types.Image, min_length? : Int, max_gap? : Int) -> Array[TableLine] raise @types.LoadError
pub fn detect_horizontal_table_lines(@types.Image, min_length? : Int, max_gap? : Int) -> Array[(Int, Int, Int)] raise @types.LoadError
pub fn detect_image_regions_markdown(@types.Image, min_area? : Int) -> Array[MarkdownImage] raise @types.LoadError
pub fn detect_language_enhanced(@types.Image) -> LanguageDetectionResult raise @types.LoadError
pub fn detect_layout_type(Array[TextLineAttributes], Int, Int) -> LayoutType raise @types.LoadError
pub fn detect_list_item(TextLineAttributes) -> ListItemInfo
pub fn detect_paragraphs(Array[DocumentBlock], max_line_spacing_ratio? : Double) -> Array[Array[Int]]
pub fn detect_skew_angle(@types.Image) -> Double raise @types.LoadError
pub fn detect_skew_angle_robust(@types.Image) -> Double raise @types.LoadError
pub fn detect_table_enhanced(@types.Image, min_table_size? : Int) -> Array[EnhancedTableResult] raise @types.LoadError
pub fn detect_text_lines_projection(@types.Image, min_height? : Int, max_gap? : Int) -> Array[TextLineInfo] raise @types.LoadError
pub fn detect_text_regions(@types.Image) -> Array[TextRegion] raise @types.LoadError
pub fn detect_titles(Array[DocumentBlock], title_font_size_threshold? : Int) -> Array[Int]
pub fn detect_touching_chars(@types.Image, min_char_width? : Int, max_char_width? : Int) -> Array[Int] raise @types.LoadError
pub fn detect_vertical_lines(@types.Image, min_length? : Int, max_gap? : Int) -> Array[TableLine] raise @types.LoadError
pub fn detect_vertical_table_lines(@types.Image, min_length? : Int, max_gap? : Int) -> Array[(Int, Int, Int)] raise @types.LoadError
pub fn determine_reading_order_markdown(Array[MarkdownElement]) -> Array[Int]
pub fn dictionary_create(Array[String]) -> Dictionary raise @types.LoadError
pub fn dictionary_create_common_english() -> Dictionary
pub fn dictionary_match(String, Dictionary, max_distance? : Int) -> Array[(String, Int)] raise @types.LoadError
pub fn digit_ocr_default_config() -> DigitOcrConfig
pub fn document_enhance(@types.Image) -> @types.Image raise @types.LoadError
pub fn document_statistics_enhanced(Array[DocumentBlock]) -> (Int, Int, Int, Int, Int, Int, Int)
pub fn document_structure_stats(DocumentStructure) -> (Int, Int, Int, Int, Int)
pub fn document_understanding_enhanced_default_config() -> DocumentUnderstandingEnhancedConfig
pub fn drop_fall_segmentation(@types.Image, start_x? : Int) -> DropFallResult raise @types.LoadError
pub fn edit_distance(String, String) -> Int raise @types.LoadError
pub fn elastic_match(Array[Double], Array[Double], elasticity? : Double, grid_size? : Int) -> Double
pub fn english_ocr_default_config() -> EnglishOcrConfig
pub fn enhanced_chinese_ocr_default_config() -> EnhancedChineseOcrConfig
pub fn enhanced_document_to_markdown(EnhancedDocument, include_header_footer? : Bool) -> String
pub fn enhanced_element_distribution(EnhancedDocument) -> Array[(String, Int)]
pub fn enhanced_table_to_markdown(EnhancedTableResult) -> String
pub fn ensemble_default_config() -> EnsembleConfig
pub fn ensemble_predict(Array[Double], KnnClassifier, Array[(String, Array[Double])], config? : EnsembleConfig) -> ClassificationResult raise @types.LoadError
pub fn estimate_memory_usage(Int, Int, Int, Int) -> MemoryUsageStats
pub fn euclidean_distance(Array[Double], Array[Double]) -> Double raise @types.LoadError
pub fn evaluate_cnn_model(Array[DLTrainingSample], DLCnnModelConfig, Array[String]) -> (Double, Double) raise @types.LoadError
pub fn evaluate_scan_quality(@types.Image) -> ScanQuality raise @types.LoadError
pub fn extract_all_cells(@types.Image, TableStructure, padding? : Int) -> Array[@types.Image] raise @types.LoadError
pub fn extract_cell_image(@types.Image, TableCell, padding? : Int) -> @types.Image raise @types.LoadError
pub fn extract_char_image(@types.Image, CharSegment, target_size? : Int, padding? : Int) -> @types.Image raise @types.LoadError
pub fn extract_combined_enhanced_features(@types.Image, OcrAccuracyEnhancedConfig) -> Array[Double] raise @types.LoadError
pub fn extract_combined_ocr_features(@types.Image) -> Array[Double] raise @types.LoadError
pub fn extract_directional_features(@types.Image) -> Array[Double]
pub fn extract_document_text(Array[DocumentBlock], include_headers? : Bool, include_footers? : Bool) -> String
pub fn extract_features(DLFeatureExtractor, @types.Image) -> Array[Double]
pub fn extract_gabor_ocr_features(@types.Image, num_orientations? : Int, num_frequencies? : Int) -> Array[Double]
pub fn extract_handwriting_features(@types.Image, String) -> HandwritingCharFeature raise @types.LoadError
pub fn extract_handwriting_stroke_features(@types.Image) -> HandwritingStrokeFeatures raise @types.LoadError
pub fn extract_headings(DocumentStructure) -> Array[DocumentElement]
pub fn extract_hw_stroke_features(@types.Image) -> Array[StrokeFeature]
pub fn extract_images_enhanced(@types.Image, min_area? : Int) -> Array[ExtractedImage]
pub fn extract_paragraphs(DocumentStructure) -> Array[DocumentElement]
pub fn extract_stroke_features(@types.Image) -> Array[Double] raise @types.LoadError
pub fn extract_text_line_image(@types.Image, TextLineInfo, padding? : Int) -> @types.Image raise @types.LoadError
pub fn extract_text_lines(@types.Image) -> Array[@types.Image] raise @types.LoadError
pub fn extract_title(DocumentStructure) -> String
pub fn extract_zernike_moments(@types.Image, max_order? : Int) -> Array[Double] raise @types.LoadError
pub fn fast_connected_components(@types.Image) -> Array[Int] raise @types.LoadError
pub fn fast_downsample_2x(@types.Image) -> @types.Image raise @types.LoadError
pub fn fast_gaussian_blur_1d(@types.Image, Array[Double]) -> @types.Image raise @types.LoadError
pub fn fast_threshold_lut(@types.Image, Array[Int]) -> @types.Image raise @types.LoadError
pub fn filter_components_by_area(OcrConnectedComponentsResult, Int, Int) -> Array[OcrConnectedComponent] raise @types.LoadError
pub fn filter_components_by_aspect_ratio(OcrConnectedComponentsResult, Double, Double) -> Array[OcrConnectedComponent] raise @types.LoadError
pub fn filter_components_by_position(OcrConnectedComponentsResult, Int, Int, Int, Int) -> Array[OcrConnectedComponent] raise @types.LoadError
pub fn filter_noise_segments(Array[(Int, Int, Int, Int)], Int, Int, min_area_ratio? : Double, max_area_ratio? : Double) -> Array[(Int, Int, Int, Int)] raise @types.LoadError
pub fn find_line_intersections(Array[(Int, Int, Int)], Array[(Int, Int, Int)]) -> Array[(Int, Int)]
pub fn find_similar_chinese_chars(DictChineseDict, String, top_n? : Int) -> Array[DictCharMatch] raise @types.LoadError
pub fn full_postprocess_correction(String, context_type? : String) -> CorrectionResult raise @types.LoadError
pub fn generate_3500_chinese_templates(char_set? : String) -> Array[(String, Array[Double])]
pub fn generate_accuracy_report(AccuracyStats, String) -> String
pub fn generate_api_config_json(ApiServerConfig) -> String
pub fn generate_batch_summary(Array[BatchTask], Double) -> BatchResultSummary raise @types.LoadError
pub fn generate_chinese_char_info_db() -> Array[ChineseCharInfo]
pub fn generate_chinese_dictionary_report(DictChineseDict) -> String
pub fn generate_chinese_templates(char_set? : String) -> Array[(String, Array[Double])]
pub fn generate_cli_help() -> String
pub fn generate_correction_report(Array[CorrectionResult]) -> String
pub fn generate_deployment_package(DockerConfig, ApiServerConfig, ModelPackageConfig) -> String
pub fn generate_digit_templates() -> Array[(String, Array[Double])]
pub fn generate_docker_compose(DockerConfig) -> String
pub fn generate_dockerfile(DockerConfig) -> String
pub fn generate_english_templates(case_sensitive? : Bool) -> Array[(String, Array[Double])]
pub fn generate_enhanced_chinese_templates(char_set_size? : Int) -> Array[(String, Array[Double])]
pub fn generate_enhanced_handwriting_templates(char_set? : String, num_variants? : Int) -> Array[(String, Array[Double])]
pub fn generate_env_config(DeploymentEnvironment) -> String
pub fn generate_handwriting_templates(char_set? : String) -> Array[(String, Array[Double])]
pub fn generate_health_check_config(ApiServerConfig) -> String
pub fn generate_image_extraction_report(Array[ExtractedImage]) -> String
pub fn generate_markdown_image_placeholder(MarkdownImage, Int) -> String
pub fn generate_model_manifest(ModelPackageConfig) -> String
pub fn generate_performance_report(PerformanceBenchmark, String) -> String
pub fn generate_punctuation_templates() -> Array[PunctuationTemplate]
pub fn generate_robustness_report(ScanQuality, Array[DistortionDetectionResult], ComplexLayoutAnalysis) -> RobustnessReport
pub fn generate_training_progress_report(TrainingState, TrainingConfig) -> String
pub fn generate_training_report(Array[DLTrainingHistory], DLCnnModelConfig) -> String
pub fn get_elements_in_reading_order(DocumentStructure) -> Array[DocumentElement]
pub fn grid_features(@types.Image, grid_rows? : Int, grid_cols? : Int) -> GridFeatures raise @types.LoadError
pub fn handwriting_feature_similarity(HandwritingCharFeature, HandwritingCharFeature) -> Double
pub fn handwriting_ocr_default_config() -> HandwritingOcrConfig
pub fn handwriting_ocr_enhanced_default_config() -> HandwritingOcrEnhancedConfig
pub fn handwriting_postprocess(String, Double) -> (String, Double)
pub fn handwriting_report_to_string(HandwritingRecognitionResult) -> String
pub fn hog_features(@types.Image, cell_size? : Int, num_bins? : Int) -> HogFeatures raise @types.LoadError
pub fn horizontal_projection(@types.Image) -> ProjectionResult raise @types.LoadError
pub fn hu_moments_features(@types.Image) -> Array[Double] raise @types.LoadError
pub fn is_code_block_line(TextLineAttributes, Int) -> Bool
pub fn is_heading_line(TextLineAttributes, Double) -> (Bool, Int)
pub fn is_quote_line(TextLineAttributes, Int) -> Bool
pub fn knn_add_sample(KnnClassifier, Array[Double], String) -> KnnClassifier raise @types.LoadError
pub fn knn_add_samples(KnnClassifier, Array[(Array[Double], String)]) -> KnnClassifier raise @types.LoadError
pub fn knn_create(k? : Int, distance_metric? : String) -> KnnClassifier raise @types.LoadError
pub fn knn_predict(KnnClassifier, Array[Double]) -> ClassificationResult raise @types.LoadError
pub fn language_model_postprocess(String, Array[String], Array[Double]) -> (String, Array[Double])
pub fn lbp_features(@types.Image, radius? : Int, num_points? : Int, num_bins? : Int) -> LbpFeatures raise @types.LoadError
pub fn load_model(String) -> DLCnnModelConfig?
pub fn lookup_by_pinyin(DictChineseDict, String) -> Array[DictCharEntry] raise @types.LoadError
pub fn lookup_by_radical(DictChineseDict, String) -> Array[DictCharEntry] raise @types.LoadError
pub fn lookup_by_structure(DictChineseDict, DictCharStructure) -> Array[DictCharEntry]
pub fn lookup_char(DictChineseDict, String) -> DictCharEntry? raise @types.LoadError
pub fn manhattan_distance(Array[Double], Array[Double]) -> Double raise @types.LoadError
pub fn mark_task_completed(BatchTask, Int, Double, Double) -> BatchTask
pub fn mark_task_failed(BatchTask, String, Double) -> BatchTask
pub fn markdown_document_to_string(MarkdownDocument) -> String
pub fn markdown_table_to_string(MarkdownTable) -> String
pub fn max_pool2d(Array[Double], Int, Int, Int, Int) -> Array[Double] raise @types.LoadError
pub fn max_pool2d_backward(Array[Double], Array[Double], Int, Int, Int, Int) -> Array[Double]
pub fn merge_adjacent_components(Array[OcrConnectedComponent], Int) -> Array[OcrConnectedComponent] raise @types.LoadError
pub fn merge_small_segments(Array[(Int, Int, Int, Int)], Int, Int) -> Array[(Int, Int, Int, Int)] raise @types.LoadError
pub fn multi_scale_recognize(@types.Image, Array[(String, Array[Double])], Array[Int], distance_metric? : String) -> (String, Double)
pub fn multilingual_ocr_default_config() -> MultilingualOcrConfig
pub fn multilingual_ocr_enhanced_default_config() -> MultilingualOcrEnhancedConfig
pub fn next_batch(DataLoader) -> (Array[DLTrainingSample], DataLoader) raise @types.LoadError
pub fn ngram_create(Array[String], n? : Int) -> NgramModel raise @types.LoadError
pub fn ngram_score(String, NgramModel) -> Double raise @types.LoadError
pub fn niblack_threshold(@types.Image, window_size? : Int, k? : Double) -> @types.Image raise @types.LoadError
pub fn normalize_features(Array[Double]) -> Array[Double] raise @types.LoadError
pub fn normalize_handwriting_size(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn normalize_image(Array[Double], Double, Double) -> Array[Double] raise @types.LoadError
pub fn normalize_punctuation(String, Array[String]) -> String
pub fn ocr_accuracy_enhanced_default_config() -> OcrAccuracyEnhancedConfig
pub fn ocr_pipeline_stats(@types.Image) -> (Int, Int, Double) raise @types.LoadError
pub fn ocr_postprocess(OcrResult, config? : PostProcessConfig, dictionary? : Dictionary, ngram_model? : NgramModel) -> OcrResult raise @types.LoadError
pub fn ocr_preprocess(@types.Image, binarization_method? : String) -> @types.Image raise @types.LoadError
pub fn ocr_result_to_hocr(OCRPageResult) -> String
pub fn ocr_result_to_json(OCRPageResult) -> String
pub fn ocr_result_to_text(OCRPageResult) -> String
pub fn optimize_reading_order(Array[DocumentBlock], Int) -> Array[Int]
pub fn otsu_threshold(@types.Image) -> @types.Image raise @types.LoadError
pub fn parse_cli_args(Array[String]) -> CliConfig raise @types.LoadError
pub fn postprocess_default_config() -> PostProcessConfig
pub fn progress_bar_to_string(Double, width? : Int) -> String
pub fn projection_features(@types.Image) -> ProjectionFeatures raise @types.LoadError
pub fn recognize_by_components(DictChineseDict, DictCharStructure, Array[String], stroke_count_hint? : Int) -> Array[(String, Double)]
pub fn recognize_chinese(@types.Image, config? : ChineseOcrConfig) -> OcrResult raise @types.LoadError
pub fn recognize_chinese_advanced(@types.Image, config? : AdvancedChineseOcrConfig) -> OcrResult raise @types.LoadError
pub fn recognize_digits(@types.Image, config? : DigitOcrConfig) -> OcrResult raise @types.LoadError
pub fn recognize_english(@types.Image, config? : EnglishOcrConfig) -> OcrResult raise @types.LoadError
pub fn recognize_enhanced_chinese(@types.Image, config? : EnhancedChineseOcrConfig) -> OcrResult raise @types.LoadError
pub fn recognize_handwriting(@types.Image, config? : HandwritingOcrConfig) -> OcrResult raise @types.LoadError
pub fn recognize_handwriting_char(@types.Image, Array[HandwritingTemplate], HandwritingRecognitionConfig) -> HandwritingRecognitionResult raise @types.LoadError
pub fn recognize_handwriting_enhanced(@types.Image, config? : HandwritingOcrEnhancedConfig) -> OcrResult raise @types.LoadError
pub fn recognize_multilingual(@types.Image, config? : MultilingualOcrConfig) -> OcrResult raise @types.LoadError
pub fn recognize_multilingual_enhanced(@types.Image, config? : MultilingualOcrEnhancedConfig) -> OcrResult raise @types.LoadError
pub fn recognize_ocr_enhanced(@types.Image, Array[(String, Array[Double])], config? : OcrAccuracyEnhancedConfig) -> OcrResult raise @types.LoadError
pub fn recognize_symbols_markdown(String) -> Array[MarkdownSymbol]
pub fn recognize_table(@types.Image, min_line_length? : Int) -> TableStructure raise @types.LoadError
pub fn record_training_metrics(TrainingState, TrainingMetrics) -> TrainingState
pub fn relu(Double) -> Double
pub fn relu_backward(Array[Double], Array[Double]) -> Array[Double]
pub fn resize_image_for_cnn(@types.Image, Int, Int) -> Array[Double] raise @types.LoadError
pub fn robustness_report_to_string(RobustnessReport) -> String
pub fn rotate_document(@types.Image, Double) -> @types.Image raise @types.LoadError
pub fn sauvola_threshold(@types.Image, window_size? : Int, k? : Double, r? : Double) -> @types.Image raise @types.LoadError
pub fn save_model(DLCnnModelConfig, Array[Double], String) -> Bool
pub fn scan_document_preprocess(@types.Image, ScanOCRConfig) -> @types.Image raise @types.LoadError
pub fn scan_ocr_default_config() -> ScanOCRConfig
pub fn scan_ocr_recognize(@types.Image, ScanOCRConfig) -> OCRPageResult raise @types.LoadError
pub fn segment_by_connected_components(@types.Image, min_area? : Int, max_area? : Int) -> Array[(Int, Int, Int, Int)] raise @types.LoadError
pub fn segment_chars_projection(@types.Image, TextLineInfo, min_width? : Int, max_gap? : Int) -> Array[CharSegment] raise @types.LoadError
pub fn segment_connected_strokes(@types.Image, HandwritingRecognitionConfig) -> StrokeSegmentationResult
pub fn segment_cursive_chars(@types.Image, min_char_width? : Int, max_char_width? : Int) -> Array[(Int, Int, Int, Int)]
pub fn segment_page(@types.Image) -> Array[TextRegion] raise @types.LoadError
pub fn segment_paragraphs(Array[TextLineAttributes]) -> Array[Array[TextLineAttributes]]
pub fn select_adaptive_config(ScanQuality) -> AdaptivePreprocessConfig raise @types.LoadError
pub fn shadow_removal(@types.Image, kernel_size? : Int) -> @types.Image raise @types.LoadError
pub fn sigmoid(Double) -> Double
pub fn sigmoid_backward(Array[Double], Array[Double]) -> Array[Double]
pub fn smart_reading_order(Array[EnhancedDocumentElement], LayoutType, Array[Int]) -> Array[Int] raise @types.LoadError
pub fn smart_segment_chars(@types.Image, MultilingualOcrEnhancedConfig) -> Array[(Int, Int, Int, Int, String)] raise @types.LoadError
pub fn smart_spacing_process(String, Array[String]) -> String
pub fn softmax(Array[Double]) -> Array[Double]
pub fn softmax_cross_entropy_backward(Array[Double], Int) -> Array[Double] raise @types.LoadError
pub fn split_train_validation(Array[DLTrainingSample], Double, Bool) -> (Array[DLTrainingSample], Array[DLTrainingSample])
pub fn standardize_features(Array[Double]) -> Array[Double] raise @types.LoadError
pub fn statistical_features(@types.Image) -> StatisticalFeatures raise @types.LoadError
pub fn structure_based_filter(@types.Image, Array[ChineseCharInfo], max_candidates? : Int) -> Array[ChineseCharInfo]
pub fn template_matcher_add(TemplateMatcher, String, Array[Double]) -> TemplateMatcher raise @types.LoadError
pub fn template_matcher_create(distance_metric? : String) -> TemplateMatcher
pub fn template_matcher_predict(TemplateMatcher, Array[Double]) -> ClassificationResult raise @types.LoadError
pub fn understand_document(@types.Image) -> DocumentStructure raise @types.LoadError
pub fn understand_document_enhanced(@types.Image, config? : DocumentUnderstandingEnhancedConfig) -> (Array[DocumentBlock], Array[DocumentTreeNode], String) raise @types.LoadError
pub fn unrolled_pixel_sum(@types.Image) -> Int raise @types.LoadError
pub fn update_task_progress(BatchTask, Double, Int, Int) -> BatchTask
pub fn update_weights_sgd(Array[Double], Array[Double], Double) -> Array[Double] raise @types.LoadError
pub fn vertical_projection(@types.Image) -> ProjectionResult raise @types.LoadError
pub fn weighted_knn_classify(Array[Double], Array[(String, Array[Double])], k? : Int, distance_metric? : String) -> (String, Double, Array[(String, Double)])
pub fn AugmentationType::equal(Self, Self) -> Bool
pub fn AugmentationType::not_equal(Self, Self) -> Bool
pub fn BatchTaskStatus::equal(Self, Self) -> Bool
pub fn BatchTaskStatus::not_equal(Self, Self) -> Bool
pub fn ComplexLayoutType::equal(Self, Self) -> Bool
pub fn ComplexLayoutType::not_equal(Self, Self) -> Bool
pub fn DLLayerType::equal(Self, Self) -> Bool
pub fn DLLayerType::not_equal(Self, Self) -> Bool
pub fn DeploymentEnvironment::equal(Self, Self) -> Bool
pub fn DeploymentEnvironment::not_equal(Self, Self) -> Bool
pub fn DictCharStructure::equal(Self, Self) -> Bool
pub fn DictCharStructure::not_equal(Self, Self) -> Bool
pub fn DistanceMetric::equal(Self, Self) -> Bool
pub fn DistanceMetric::not_equal(Self, Self) -> Bool
pub fn DistortionType::equal(Self, Self) -> Bool
pub fn DistortionType::not_equal(Self, Self) -> Bool
pub fn DocumentBlockType::equal(Self, Self) -> Bool
pub fn DocumentBlockType::not_equal(Self, Self) -> Bool
pub fn DocumentElementType::equal(Self, Self) -> Bool
pub fn DocumentElementType::not_equal(Self, Self) -> Bool
pub fn HandwritingStyle::equal(Self, Self) -> Bool
pub fn HandwritingStyle::not_equal(Self, Self) -> Bool
pub fn LRSchedulerType::equal(Self, Self) -> Bool
pub fn LRSchedulerType::not_equal(Self, Self) -> Bool
pub fn LanguageType::equal(Self, Self) -> Bool
pub fn LanguageType::not_equal(Self, Self) -> Bool
pub fn LayoutType::equal(Self, Self) -> Bool
pub fn LayoutType::not_equal(Self, Self) -> Bool
pub fn ListItemType::equal(Self, Self) -> Bool
pub fn ListItemType::not_equal(Self, Self) -> Bool
pub fn MarkdownElementType::equal(Self, Self) -> Bool
pub fn MarkdownElementType::not_equal(Self, Self) -> Bool
pub fn OcrErrorType::equal(Self, Self) -> Bool
pub fn OcrErrorType::not_equal(Self, Self) -> Bool
pub fn OptimizerType::equal(Self, Self) -> Bool
pub fn OptimizerType::not_equal(Self, Self) -> Bool
pub fn PageRegionType::equal(Self, Self) -> Bool
pub fn PageRegionType::not_equal(Self, Self) -> Bool
pub fn ScanQualityLevel::equal(Self, Self) -> Bool
pub fn ScanQualityLevel::not_equal(Self, Self) -> Bool
pub fn StrokeType::equal(Self, Self) -> Bool
pub fn StrokeType::not_equal(Self, Self) -> Bool
pub fn TableLineType::equal(Self, Self) -> Bool
pub fn TableLineType::not_equal(Self, Self) -> Bool
pub fn TextRegionType::equal(Self, Self) -> Bool
pub fn TextRegionType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
