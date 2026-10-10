# image API 参考

> 版本 v205.0.0 | 1339 公开函数 + 1 常量 + 382 类型 | 4291 测试 × 4 目标 (native/wasm-gc/js/wasm) | 18 种编解码格式

> 本文档由 `src/pkg.generated.mbti`（根包接口，3726 行）自动生成。类型从函数签名引用中提取，按所属包分组；函数按语义大类分组，说明列为基于函数名的启发式摘要。

## 类型总览

共 382 个公开类型，分布于 50 个子包。

| 类型 | 包 | 说明 |
|------|------|------|
| `AdvancedImagingConfig` | advanced_imaging | — |
| `HyperspectralData` | advanced_imaging | — |
| `ImagingModality` | advanced_imaging | — |
| `InfraredImagingType` | advanced_imaging | — |
| `MRIData` | advanced_imaging | — |
| `PETData` | advanced_imaging | — |
| `PolarizationData` | advanced_imaging | — |
| `QuantumImagingAlgorithm` | advanced_imaging | — |
| `ThermalData` | advanced_imaging | — |
| `UltrasoundData` | advanced_imaging | — |
| `XRayData` | advanced_imaging | — |
| `BarcodeConfig` | barcode | — |
| `BarcodeResult` | barcode | — |
| `QrDecodeResult` | barcode | — |
| `QrFinderPattern` | barcode | — |
| `AvifInfo` | codec | — |
| `HeifInfo` | codec | — |
| `JpegXlInfo` | codec | — |
| `Colormap` | color | 伪彩色映射 |
| `CompressionConfig` | compression | — |
| `CompressionQualityMetrics` | compression | — |
| `CompressionResult` | compression | — |
| `CTProjectionData` | computational_imaging | — |
| `CodedAperturePattern` | computational_imaging | — |
| `Hologram` | computational_imaging | — |
| `ImagingReconstructionResult` | computational_imaging | — |
| `LightFieldCameraParams` | computational_imaging | — |
| `LightFieldData` | computational_imaging | — |
| `PhaseRetrievalConfig` | computational_imaging | — |
| `RefocusResult` | computational_imaging | — |
| `ViewSynthesisResult` | computational_imaging | — |
| `DenoiseConfig` | denoise | — |
| `DenoiseResult` | denoise | — |
| `EnhancementAlgorithm` | denoise | — |
| `EnhancementResult` | denoise | — |
| `BoundingBox` | detection | — |
| `YoloBoundingBox` | detection | — |
| `YoloConfig` | detection | — |
| `YoloDetectionMetrics` | detection | — |
| `YoloDetectionResult` | detection | — |
| `YoloTrackedObject` | detection | — |
| `Circle` | edge | 霍夫圆 |
| `Contour` | edge | 轮廓 |
| `ContourPoint` | edge | 轮廓点 |
| `HoughLine` | edge | 霍夫直线 |
| `Moments` | edge | 图像矩 |
| `ArnoldParams` | encryption | — |
| `ChaoticParams` | encryption | — |
| `EncryptionConfig` | encryption | — |
| `EncryptionQuality` | encryption | — |
| `EncryptionResult` | encryption | — |
| `ImageEncryptionQuality` | encryption | — |
| `WatermarkExtractionResult` | encryption | — |
| `WatermarkInfo` | encryption | — |
| `DehazeConfig` | enhance | — |
| `HdrConfig` | enhance | — |
| `InpaintConfig` | enhance | — |
| `NlmConfig` | enhance | — |
| `AgeGenderEstimationResult` | face_recognition | — |
| `ExpressionRecognitionResult` | face_recognition | — |
| `FaceAttributeAnalysis` | face_recognition | — |
| `FaceDatabase` | face_recognition | — |
| `FaceDetectionResult` | face_recognition | — |
| `FaceFeature` | face_recognition | — |
| `FaceRecognitionAlgorithm` | face_recognition | — |
| `FaceRecognitionConfig` | face_recognition | — |
| `FaceRecognitionResult` | face_recognition | — |
| `CornerPoint` | feature | 角点 |
| `DescriptorMatch` | feature | 特征匹配结果 |
| `FlowResult` | feature | 光流结果 |
| `GlcmFeatures` | feature | GLCM特征 |
| `HistCompareMethod` | feature | 直方图比较方法 |
| `IntegralImage` | feature | 积分图像 |
| `IntegralImageSq` | feature | 平方积分图像 |
| `OrbDescriptor` | feature | ORB描述子 |
| `SiftDescriptor` | feature | SIFT描述子 |
| `SiftMatch` | feature | SIFT匹配结果 |
| `TemplateMatchMethod` | feature | 模板匹配方法 |
| `TemplateMatchResult` | feature | 模板匹配结果 |
| `ColorAnalysisResult` | forensics | — |
| `ColorQuantizationResult` | forensics | — |
| `CompressionAnalysisResult` | forensics | — |
| `DetailAnalysisResult` | forensics | — |
| `EdgeAnalysisResult` | forensics | — |
| `EnhancedVerificationConfig` | forensics | — |
| `EnhancedVerificationResult` | forensics | — |
| `FrequencyAnalysisResult` | forensics | — |
| `GeometryAnalysisResult` | forensics | — |
| `NoiseAnalysisResult` | forensics | — |
| `SourceVerificationConfig` | forensics | — |
| `SourceVerificationResult` | forensics | — |
| `TextDetectionResult` | forensics | — |
| `TextureAnalysisResult` | forensics | — |
| `UIDetectionResult` | forensics | — |
| `CfaAnalysisResult` | forensics_enhanced | — |
| `CloneDetectionResult` | forensics_enhanced | — |
| `DctCoefficientResult` | forensics_enhanced | — |
| `ElaAnalysisResult` | forensics_enhanced | — |
| `IlluminationConsistencyResult` | forensics_enhanced | — |
| `JpegGhostResult` | forensics_enhanced | — |
| `MetadataForensicsResult` | forensics_enhanced | — |
| `NoiseResidualResult` | forensics_enhanced | — |
| `TamperDetectionResult` | forensics_enhanced | — |
| `FFTResult` | frequency | FFT结果 |
| `FreqFilterType` | frequency | 频域滤波类型 |
| `HaarWaveletResult` | frequency | Haar小波结果 |
| `FusionConfig` | fusion | — |
| `FusionConfig` | fusion_enhanced | — |
| `FusionResult` | fusion_enhanced | — |
| `RegistrationConfig` | fusion_enhanced | — |
| `RegistrationResult` | fusion_enhanced | — |
| `CompositionConfig` | image_generation | — |
| `EditingConfig` | image_generation | — |
| `EditingResult` | image_generation | — |
| `GenerationConfig` | image_generation | — |
| `GenerationResult` | image_generation | — |
| `LatentVector` | image_generation | — |
| `FeatureExtractionResult` | image_retrieval_advanced | — |
| `ImageRetrievalConfig` | image_retrieval_advanced | — |
| `ImageRetrievalTaskType` | image_retrieval_advanced | — |
| `IndexConstructionResult` | image_retrieval_advanced | — |
| `IndexStructureType` | image_retrieval_advanced | — |
| `QueryExpansionResult` | image_retrieval_advanced | — |
| `RelevanceFeedbackResult` | image_retrieval_advanced | — |
| `RetrievalResult` | image_retrieval_advanced | — |
| `SimilarityMetricType` | image_retrieval_advanced | — |
| `DehazeAlgorithm` | inpainting | — |
| `DehazeResult` | inpainting | — |
| `DerainAlgorithm` | inpainting | — |
| `DerainResult` | inpainting | — |
| `InpaintingConfig` | inpainting | — |
| `InpaintingResult` | inpainting | — |
| `CropDetectionResult` | intelligent_vision | — |
| `DefectDetectionResult` | intelligent_vision | — |
| `DetectionResultIV` | intelligent_vision | — |
| `IntelligentVisionConfig` | intelligent_vision | — |
| `IntrusionDetectionResult` | intelligent_vision | — |
| `LaneDetectionResult` | intelligent_vision | — |
| `StarDetectionResult` | intelligent_vision | — |
| `TrafficSignResult` | intelligent_vision | — |
| `StreamInfo` | lib | 流式解码信息 |
| `Lesion` | medical | — |
| `MedicalImage` | medical | — |
| `MedicalImageQuality` | medical | — |
| `MedicalRegistrationResult` | medical | — |
| `MedicalSegmentationConfig` | medical | — |
| `WindowLevel` | medical | — |
| `WindowLevelConfig` | medical | — |
| `ExifInfo` | meta | EXIF元数据 |
| `PngTextChunk` | meta | PNG文本块 |
| `CameraParams` | neural_rendering | — |
| `Gaussian3D` | neural_rendering | — |
| `GaussianSplattingConfig` | neural_rendering | — |
| `NeRFConfig` | neural_rendering | — |
| `NeuralRenderingAlgorithm` | neural_rendering | — |
| `Point3D` | neural_rendering | — |
| `Ray` | neural_rendering | — |
| `ReconstructionAlgorithm` | neural_rendering | — |
| `ReconstructionResult` | neural_rendering | — |
| `RenderingResult` | neural_rendering | — |
| `AccuracyStats` | ocr | — |
| `AdaptivePreprocessConfig` | ocr | — |
| `AdvancedChineseOcrConfig` | ocr | — |
| `ApiServerConfig` | ocr | — |
| `AugmentationConfig` | ocr | — |
| `BatchOcrConfig` | ocr | — |
| `BatchProgress` | ocr | — |
| `BatchResultSummary` | ocr | — |
| `BatchTask` | ocr | — |
| `CharSegment` | ocr | — |
| `ChineseCharInfo` | ocr | — |
| `ChineseCharStructure` | ocr | — |
| `ChineseOcrConfig` | ocr | — |
| `ClassificationResult` | ocr | — |
| `CliConfig` | ocr | — |
| `ComplexLayoutAnalysis` | ocr | — |
| `CorrectionResult` | ocr | — |
| `DLCnnModelConfig` | ocr | — |
| `DLFeatureExtractor` | ocr | — |
| `DLInferenceResult` | ocr | — |
| `DLLayerType` | ocr | — |
| `DLNeuralLayer` | ocr | — |
| `DLTrainingHistory` | ocr | — |
| `DLTrainingSample` | ocr | — |
| `DataLoader` | ocr | — |
| `DeploymentEnvironment` | ocr | — |
| `DictCharEntry` | ocr | — |
| `DictCharMatch` | ocr | — |
| `DictCharStructure` | ocr | — |
| `DictChineseDict` | ocr | — |
| `Dictionary` | ocr | — |
| `DigitOcrConfig` | ocr | — |
| `DistanceMetric` | ocr | — |
| `DistortionDetectionResult` | ocr | — |
| `DockerConfig` | ocr | — |
| `DocumentBlock` | ocr | — |
| `DocumentElement` | ocr | — |
| `DocumentStructure` | ocr | — |
| `DocumentTreeNode` | ocr | — |
| `DocumentUnderstandingEnhancedConfig` | ocr | — |
| `DropFallResult` | ocr | — |
| `EnglishOcrConfig` | ocr | — |
| `EnhancedChineseOcrConfig` | ocr | — |
| `EnhancedDocument` | ocr | — |
| `EnhancedDocumentElement` | ocr | — |
| `EnhancedTableResult` | ocr | — |
| `EnsembleConfig` | ocr | — |
| `ExtractedImage` | ocr | — |
| `GridFeatures` | ocr | — |
| `HandwritingCharFeature` | ocr | — |
| `HandwritingOcrConfig` | ocr | — |
| `HandwritingOcrEnhancedConfig` | ocr | — |
| `HandwritingRecognitionConfig` | ocr | — |
| `HandwritingRecognitionResult` | ocr | — |
| `HandwritingStrokeFeatures` | ocr | — |
| `HandwritingStyle` | ocr | — |
| `HandwritingTemplate` | ocr | — |
| `HogFeatures` | ocr | — |
| `KnnClassifier` | ocr | — |
| `LRSchedulerConfig` | ocr | — |
| `LanguageDetectionResult` | ocr | — |
| `LanguageModelState` | ocr | — |
| `LanguageType` | ocr | — |
| `LayoutType` | ocr | — |
| `LbpFeatures` | ocr | — |
| `ListItemInfo` | ocr | — |
| `MarkdownDocument` | ocr | — |
| `MarkdownElement` | ocr | — |
| `MarkdownElementType` | ocr | — |
| `MarkdownImage` | ocr | — |
| `MarkdownSymbol` | ocr | — |
| `MarkdownTable` | ocr | — |
| `MemoryUsageStats` | ocr | — |
| `ModelPackageConfig` | ocr | — |
| `MultilingualOcrConfig` | ocr | — |
| `MultilingualOcrEnhancedConfig` | ocr | — |
| `NgramModel` | ocr | — |
| `OCRPageResult` | ocr | — |
| `OcrAccuracyEnhancedConfig` | ocr | — |
| `OcrConnectedComponent` | ocr | — |
| `OcrConnectedComponentsResult` | ocr | — |
| `OcrResult` | ocr | — |
| `PerformanceBenchmark` | ocr | — |
| `PostProcessConfig` | ocr | — |
| `ProjectionFeatures` | ocr | — |
| `ProjectionResult` | ocr | — |
| `PunctuationTemplate` | ocr | — |
| `RobustnessReport` | ocr | — |
| `ScanOCRConfig` | ocr | — |
| `ScanQuality` | ocr | — |
| `StatisticalFeatures` | ocr | — |
| `StrokeFeature` | ocr | — |
| `StrokeSegmentationResult` | ocr | — |
| `TableCell` | ocr | — |
| `TableLine` | ocr | — |
| `TableStructure` | ocr | — |
| `TemplateMatcher` | ocr | — |
| `TextBlock` | ocr | — |
| `TextLineAttributes` | ocr | — |
| `TextLineInfo` | ocr | — |
| `TextRegion` | ocr | — |
| `TrainingConfig` | ocr | — |
| `TrainingDataset` | ocr | — |
| `TrainingMetrics` | ocr | — |
| `TrainingState` | ocr | — |
| `TileConfig` | performance | — |
| `DepthOfFieldConfig` | photo_enhance | — |
| `ExposureType` | photo_enhance | — |
| `HdrImage` | photo_enhance | — |
| `LowLightConfig` | photo_enhance | — |
| `NightEnhanceConfig` | photo_enhance | — |
| `PanoramaConfig` | photo_enhance | — |
| `PanoramaResult` | photo_enhance | — |
| `ToneMappingConfig` | photo_enhance | — |
| `BatchConfig` | pipeline | — |
| `BatchResult` | pipeline | — |
| `BatchTask` | pipeline | — |
| `CliCommand` | pipeline | — |
| `Pipeline` | pipeline | — |
| `ActionRecognitionConfig` | pose_estimation | — |
| `ActionRecognitionResult` | pose_estimation | — |
| `GestureRecognitionResult` | pose_estimation | — |
| `HumanPose` | pose_estimation | — |
| `PoseEstimationConfig` | pose_estimation | — |
| `SkeletonConnection` | pose_estimation | — |
| `QualityMetrics` | quality | — |
| `AffineTransform` | registration | — |
| `RegistrationResult` | registration | — |
| `FeatureMatch` | registration_advanced | — |
| `FeaturePoint` | registration_advanced | — |
| `RegistrationConfigAdvanced` | registration_advanced | — |
| `RegistrationResultAdvanced` | registration_advanced | — |
| `TransformMatrix` | registration_advanced | — |
| `ChangeDetectionResult` | remote_sensing | — |
| `ClassificationResult` | remote_sensing | — |
| `MultispectralImage` | remote_sensing | — |
| `RemoteSensingImage` | remote_sensing | — |
| `RemoteSensingQuality` | remote_sensing | — |
| `SpectralSignature` | remote_sensing | — |
| `TextureFeatures` | remote_sensing | — |
| `VegetationIndices` | remote_sensing | — |
| `CBIRImageFeature` | retrieval | — |
| `CBIRImageIndex` | retrieval | — |
| `CBIRRetrievalResultList` | retrieval | — |
| `ColorHistogramConfig` | retrieval | — |
| `HOGConfig` | retrieval | — |
| `ImageDatabase` | retrieval | — |
| `ImageFeature` | retrieval | — |
| `LBPConfig` | retrieval | — |
| `SearchResult` | retrieval | — |
| `SimilarityMetric` | retrieval | — |
| `ImageCaptioningResult` | scene_understanding | — |
| `SceneClassificationResult` | scene_understanding | — |
| `SceneGraph` | scene_understanding | — |
| `SceneUnderstandingConfig` | scene_understanding | — |
| `VisualQuestionAnsweringResult` | scene_understanding | — |
| `ConnectedComponent` | segment | 连通域 |
| `ConnectedComponentLabelImage` | segment | 连通域标签图 |
| `SegmentLabelImage` | segment | 分割标签图 |
| `SegmentRegion` | segment | 分割区域 |
| `SegmentationResult` | segment | 分割结果 |
| `StructuringElement` | segment | 形态学结构元素 |
| `SuperpixelResult` | segment | SLIC超像素结果 |
| `WatershedConfig` | segment | 分水岭配置 |
| `GrabCutConfig` | segmentation | — |
| `KMeansConfig` | segmentation | — |
| `SegmentationMetrics` | segmentation | — |
| `SemanticSegmentationResult` | segmentation | — |
| `SuperpixelResult` | segmentation | — |
| `WatershedConfig` | segmentation | — |
| `CameraPose` | slam | — |
| `FeatureTrackingResult` | slam | — |
| `KeyFrame` | slam | — |
| `LoopClosureResult` | slam | — |
| `MapPoint` | slam | — |
| `SLAMConfig` | slam | — |
| `SLAMState` | slam | — |
| `FeaturePoint` | stitch | — |
| `Homography` | stitch | — |
| `MatchPair` | stitch | — |
| `StitchConfig` | stitch | — |
| `ColorStatistics` | style_transfer | — |
| `StyleTransferConfig` | style_transfer | — |
| `StyleTransferResult` | style_transfer | — |
| `StyleTransferTextureFeatures` | style_transfer | — |
| `StylizeConfig` | stylize | — |
| `EnhancementConfig` | superres | — |
| `ImageQualityMetrics` | superres | — |
| `InterpolationConfig` | superres | — |
| `SuperResolutionConfig` | superres | — |
| `SuperResolutionResult` | superres | — |
| `AffineMatrix` | transform | 2×3仿射矩阵 |
| `PerspectiveMatrix` | transform | 3×3透视矩阵 |
| `GifAnimation` | types | 动画GIF (frames,delays) |
| `Image` | types | 8位解码图像 (width,height,channels:Int; data:Bytes) |
| `Image16` | types | 16位图像 (UInt16 LE) |
| `ImageF` | types | HDR浮点图像 (IEEE 754 LE) |
| `ImageFormat` | types | 图像格式枚举 |
| `ImageInfo` | types | 图像信息 (无像素) |
| `LoadError` | types | 加载错误枚举 |
| `PngAnimation` | types | 动画PNG (APNG) |
| `ResizeEdge` | types | 缩放边缘模式 |
| `ResizeFilter` | types | 缩放滤波器 |
| `ImageStats` | util | 图像统计 |
| `ImageStatsF` | util | 浮点图像统计 |
| `ActionRecognitionResult` | video | — |
| `Keyframe` | video | — |
| `OpticalFlowField` | video | — |
| `TrackedObject` | video | — |
| `VideoFrames` | video | — |
| `VideoStabilizationConfig` | video | — |
| `VideoSummary` | video | — |
| `DiffusionConfig` | vlm_multimodal | — |
| `DiffusionResult` | vlm_multimodal | — |
| `FusionConfig` | vlm_multimodal | — |
| `FusionResult` | vlm_multimodal | — |
| `GenerativeAIConfig` | vlm_multimodal | — |
| `GenerativeAIResult` | vlm_multimodal | — |
| `VLMConfig` | vlm_multimodal | — |
| `VisionLanguageModelType` | vlm_multimodal | — |
| `VisionTextEmbedding` | vlm_multimodal | — |
| `WatermarkConfig` | watermark | — |

---

## 函数列表

### I/O — 加载（4 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `load_f_from_bytes` | `(Bytes)` | `@types.ImageF raise @types.LoadError` | 从内存加载 |
| `load_from_bytes` | `(Bytes, req_channels? : Int?)` | `@types.Image raise @types.LoadError` | 从内存加载 |
| `load_gif_from_bytes` | `(Bytes)` | `@types.GifAnimation raise @types.LoadError` | 从内存加载 |
| `load_model` | `(String)` | `@ocr.DLCnnModelConfig?` | 从内存加载 |

### I/O — 写入（6 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `write_bmp_to_bytes` | `(@types.Image)` | `Bytes` | 编码为字节 |
| `write_exif_to_bytes` | `(@meta.ExifInfo, Bytes)` | `Bytes raise @types.LoadError` | 编码为字节 |
| `write_hdr_to_bytes` | `(@types.ImageF)` | `Bytes raise @types.LoadError` | 编码为字节 |
| `write_jpeg_to_bytes` | `(@types.Image)` | `Bytes raise @types.LoadError` | 编码为字节 |
| `write_png_to_bytes` | `(@types.Image)` | `Bytes` | 编码为字节 |
| `write_tga_to_bytes` | `(@types.Image)` | `Bytes` | 编码为字节 |

### I/O — 编解码（36 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `avif_decode` | `(Bytes)` | `@types.Image raise @types.LoadError` | — |
| `avif_info` | `(Bytes)` | `@codec.AvifInfo raise @types.LoadError` | — |
| `decode_any` | `(Bytes, req_channels? : Int?)` | `@types.Image raise @types.LoadError` | 解码 |
| `decode_apng` | `(Bytes)` | `@types.PngAnimation raise @types.LoadError` | 解码 |
| `decode_barcode` | `(@types.Image, config? : @barcode.BarcodeConfig)` | `Array[@barcode.BarcodeResult] raise @types.LoadError` | 解码 |
| `decode_code128` | `(@types.Image)` | `@barcode.BarcodeResult? raise @types.LoadError` | 解码 |
| `decode_code39` | `(@types.Image)` | `@barcode.BarcodeResult? raise @types.LoadError` | 解码 |
| `decode_cur` | `(Bytes)` | `@types.Image raise @types.LoadError` | 解码 |
| `decode_ean13` | `(@types.Image, config? : @barcode.BarcodeConfig)` | `@barcode.BarcodeResult? raise @types.LoadError` | 解码 |
| `decode_icns` | `(Bytes)` | `@types.Image raise @types.LoadError` | 解码 |
| `decode_ico` | `(Bytes)` | `@types.Image raise @types.LoadError` | 解码 |
| `decode_linear_barcode` | `(@types.Image)` | `Array[@barcode.BarcodeResult] raise @types.LoadError` | 解码 |
| `decode_qoi` | `(Bytes)` | `@types.Image raise @types.LoadError` | 解码 |
| `decode_qrcode` | `(@types.Image, config? : @barcode.BarcodeConfig)` | `@barcode.BarcodeResult? raise @types.LoadError` | 解码 |
| `decode_qrcode_full` | `(@types.Image)` | `@barcode.QrDecodeResult? raise @types.LoadError` | 解码 |
| `decode_tiff` | `(Bytes)` | `@types.Image raise @types.LoadError` | 解码 |
| `decode_upca` | `(@types.Image)` | `@barcode.BarcodeResult? raise @types.LoadError` | 解码 |
| `decode_vp8_frame` | `(Bytes, Int)` | `@types.Image raise @types.LoadError` | 解码 |
| `decode_webp` | `(Bytes)` | `@types.Image raise @types.LoadError` | 解码 |
| `encode_apng` | `(@types.PngAnimation)` | `Bytes raise @types.LoadError` | 编码 |
| `encode_cur` | `(@types.Image)` | `Bytes` | 编码 |
| `encode_gif` | `(@types.Image)` | `Bytes raise @types.LoadError` | 编码 |
| `encode_gif_animation` | `(@types.GifAnimation)` | `Bytes raise @types.LoadError` | 编码 |
| `encode_icns` | `(@types.Image)` | `Bytes` | 编码 |
| `encode_ico` | `(@types.Image)` | `Bytes` | 编码 |
| `encode_ico_sizes` | `(Array[@types.Image])` | `Bytes` | 编码 |
| `encode_pgm` | `(@types.Image)` | `Bytes` | 编码 |
| `encode_pnm` | `(@types.Image)` | `Bytes` | 编码 |
| `encode_ppm` | `(@types.Image)` | `Bytes` | 编码 |
| `encode_qoi` | `(@types.Image)` | `Bytes raise @types.LoadError` | 编码 |
| `encode_tiff` | `(@types.Image)` | `Bytes raise @types.LoadError` | 编码 |
| `encode_webp_lossy` | `(@types.Image, quality? : Int)` | `Bytes raise @types.LoadError` | 编码 |
| `heif_decode` | `(Bytes)` | `@types.Image raise @types.LoadError` | — |
| `heif_info` | `(Bytes)` | `@codec.HeifInfo raise @types.LoadError` | — |
| `jpegxl_decode` | `(Bytes)` | `@types.Image raise @types.LoadError` | — |
| `jpegxl_info` | `(Bytes)` | `@codec.JpegXlInfo raise @types.LoadError` | — |

### I/O — 格式检测（2 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `detect_format` | `(Bytes)` | `@types.ImageFormat` | 检测 |
| `is_supported_format` | `(Bytes)` | `Bool` | — |

### I/O — 查询（8 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `info_from_bytes` | `(Bytes)` | `@types.ImageInfo? raise @types.LoadError` | — |
| `is_16_bit_from_bytes` | `(Bytes)` | `Bool` | — |
| `is_avif_format` | `(Bytes)` | `Bool` | — |
| `is_hdr_from_bytes` | `(Bytes)` | `Bool` | — |
| `is_heif_format` | `(Bytes)` | `Bool` | — |
| `is_jpegxl_codestream` | `(Bytes)` | `Bool` | — |
| `is_jpegxl_container` | `(Bytes)` | `Bool` | — |
| `is_jpegxl_format` | `(Bytes)` | `Bool` | — |

### I/O — 配置（9 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `convert_iphone_png_to_rgb` | `(Bool)` | `Unit` | 转换 |
| `flip_vertically_on_write` | `(Bool)` | `Unit` | 翻转 |
| `hdr_to_ldr_gamma` | `(Float)` | `Unit` | — |
| `hdr_to_ldr_scale` | `(Float)` | `Unit` | — |
| `ldr_to_hdr_gamma` | `(Float)` | `Unit` | — |
| `ldr_to_hdr_scale` | `(Float)` | `Unit` | — |
| `set_alpha` | `(@types.Image, Byte)` | `@types.Image raise @types.LoadError` | — |
| `set_flip_vertically_on_load` | `(Bool)` | `Unit` | — |
| `set_unpremultiply_on_load` | `(Bool)` | `Unit` | — |

### I/O — 缩放（5 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `resize` | `(@types.Image, Int, Int, filter? : @types.ResizeFilter, edge? : @types.ResizeEdge)` | `@types.Image raise @types.LoadError` | 缩放 |
| `resize_16` | `(@types.Image16, Int, Int)` | `@types.Image16` | 缩放 |
| `resize_f` | `(@types.ImageF, Int, Int)` | `@types.ImageF` | 缩放 |
| `resize_to_contain` | `(@types.Image, Int, Int, Array[Byte])` | `@types.Image raise @types.LoadError` | 缩放 |
| `resize_to_cover` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | 缩放 |

### I/O — 流式解码（3 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `decode_stream` | `(Bytes, (Int, Array[Byte]) -> Unit)` | `@lib.StreamInfo raise @types.LoadError` | 解码 |
| `decode_stream_channels` | `(Bytes, Int, (Int, Array[Byte]) -> Unit)` | `@lib.StreamInfo raise @types.LoadError` | 解码 |
| `decode_stream_chunked` | `(Bytes, Int, (Int, @types.Image) -> Unit)` | `@lib.StreamInfo raise @types.LoadError` | 解码 |

### I/O — 其他（2 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `bench_run` | `()` | `Unit` | — |
| `failure_reason` | `()` | `String` | — |

### 元数据（3 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `create_exif_segment` | `(@meta.ExifInfo)` | `Bytes` | 创建 |
| `read_exif_from_bytes` | `(Bytes)` | `@meta.ExifInfo?` | — |
| `read_png_text_chunks` | `(Bytes)` | `Array[@meta.PngTextChunk]` | — |

### 色彩调整/增强（45 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `adjust_brightness` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | 调整 |
| `adjust_brightness_16` | `(@types.Image16, Int)` | `@types.Image16 raise @types.LoadError` | 调整 |
| `adjust_brightness_f` | `(@types.ImageF, Float)` | `@types.ImageF raise @types.LoadError` | 调整 |
| `adjust_contrast` | `(@types.Image, Float)` | `@types.Image raise @types.LoadError` | 调整 |
| `adjust_contrast_16` | `(@types.Image16, Float)` | `@types.Image16 raise @types.LoadError` | 调整 |
| `adjust_contrast_f` | `(@types.ImageF, Float)` | `@types.ImageF raise @types.LoadError` | 调整 |
| `adjust_gamma` | `(@types.Image, Float)` | `@types.Image raise @types.LoadError` | 调整 |
| `adjust_gamma_16` | `(@types.Image16, Float)` | `@types.Image16 raise @types.LoadError` | 调整 |
| `adjust_gamma_f` | `(@types.ImageF, Float)` | `@types.ImageF raise @types.LoadError` | 调整 |
| `adjust_hue` | `(@types.Image, Float)` | `@types.Image raise @types.LoadError` | 调整 |
| `adjust_saturation` | `(@types.Image, Float)` | `@types.Image raise @types.LoadError` | 调整 |
| `background_normalization` | `(@types.Image, kernel_size? : Int)` | `@types.Image raise @types.LoadError` | — |
| `brightness_value` | `(@types.Image)` | `Float` | — |
| `clahe` | `(@types.Image, Int, Float)` | `@types.Image raise @types.LoadError` | — |
| `clahe_enhance` | `(@types.Image, clip_limit? : Double, tile_size? : Int)` | `@types.Image` | — |
| `color_enhance` | `(@types.Image, saturation? : Double, contrast? : Double)` | `@types.Image` | — |
| `contrast_value` | `(@types.Image)` | `Float` | — |
| `dark_channel` | `(@types.Image, patch_size? : Int)` | `@types.Image raise @types.LoadError` | — |
| `deblur_motion` | `(@types.Image, kernel_size? : Int, angle? : Double)` | `@types.Image` | 模糊 |
| `dehaze` | `(@types.Image, patch_size? : Int, omega? : Float, t0? : Float)` | `@types.Image raise @types.LoadError` | — |
| `dehaze_16` | `(@types.Image16, patch_size? : Int, omega? : Float, t0? : Float)` | `@types.Image16 raise @types.LoadError` | — |
| `dehaze_advanced` | `(@types.Image, config? : @enhance.DehazeConfig)` | `@types.Image raise @types.LoadError` | — |
| `dehaze_clahe_ip` | `(@types.Image, Double, Int)` | `@types.Image` | — |
| `dehaze_dark_channel_ip` | `(@types.Image, Double, Double)` | `@inpainting.DehazeResult` | — |
| `dehaze_default_config` | `()` | `@enhance.DehazeConfig` | — |
| `dehaze_f` | `(@types.ImageF, patch_size? : Int, omega? : Float, t0? : Float)` | `@types.ImageF raise @types.LoadError` | — |
| `dehaze_ip` | `(@types.Image, @inpainting.DehazeAlgorithm)` | `@inpainting.DehazeResult` | — |
| `dehaze_recover` | `(@types.Image, @types.Image, Array[Int], t_min? : Double)` | `@types.Image raise @types.LoadError` | — |
| `derain_ip` | `(@types.Image, @inpainting.DerainAlgorithm)` | `@inpainting.DerainResult` | — |
| `derain_morphological_ip` | `(@types.Image)` | `@inpainting.DerainResult` | — |
| `enhance_night` | `(@types.Image, @photo_enhance.NightEnhanceConfig)` | `@types.Image` | — |
| `estimate_atmospheric_light` | `(@types.Image, @types.Image, top_percent? : Int)` | `Array[Int] raise @types.LoadError` | 估计 |
| `estimate_transmission` | `(@types.Image, Array[Int], omega? : Double, patch_size? : Int)` | `@types.Image raise @types.LoadError` | 估计 |
| `invert` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `invert_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `invert_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `low_light_default_config` | `()` | `@photo_enhance.LowLightConfig` | — |
| `low_light_enhance` | `(@types.Image, config? : @photo_enhance.LowLightConfig)` | `@types.Image` | — |
| `normalize_image` | `(Array[Double], Double, Double)` | `Array[Double] raise @types.LoadError` | — |
| `shadow_removal` | `(@types.Image, kernel_size? : Int)` | `@types.Image raise @types.LoadError` | — |
| `tone_map` | `(@photo_enhance.HdrImage, @photo_enhance.ToneMappingConfig)` | `@types.Image` | — |
| `tone_mapping_gamma` | `(@types.Image, gamma? : Double)` | `@types.Image raise @types.LoadError` | — |
| `tone_mapping_reinhard` | `(@types.Image, key? : Double)` | `@types.Image raise @types.LoadError` | — |
| `tone_mapping_sigmoid` | `(@types.Image, strength? : Double)` | `@types.Image raise @types.LoadError` | — |
| `white_balance` | `(@types.Image)` | `@types.Image` | — |

### 色彩空间转换（58 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `classification_colormap` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `cmyk_to_rgb` | `(Int, Int, Int, Int)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `cmyk_to_rgb_16` | `(Int, Int, Int, Int)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `cmyk_to_rgb_f` | `(Float, Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `false_color_composite` | `(@types.Image, @types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | — |
| `fill_alpha` | `(@types.Image, Int, Byte, Byte, Byte)` | `@types.Image raise @types.LoadError` | — |
| `hsl_to_rgb` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `hsl_to_rgb_16` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `hsl_to_rgb_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `hsv_to_rgb` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `hsv_to_rgb_16` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `hsv_to_rgb_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `lab_to_rgb` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `lab_to_rgb_16` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `lab_to_rgb_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `posterize` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | — |
| `premultiply_alpha` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `premultiply_alpha_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `premultiply_alpha_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `replace_color` | `(@types.Image, Array[Byte], Array[Byte], Int)` | `@types.Image raise @types.LoadError` | — |
| `rgb_to_cmyk` | `(Int, Int, Int)` | `(Int, Int, Int, Int) raise @types.LoadError` | — |
| `rgb_to_cmyk_16` | `(Int, Int, Int)` | `(Int, Int, Int, Int) raise @types.LoadError` | — |
| `rgb_to_cmyk_f` | `(Float, Float, Float)` | `(Float, Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_hsl` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_hsl_16` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_hsl_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_hsv` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_hsv_16` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_hsv_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_lab` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_lab_16` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_lab_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_xyz` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_xyz_16` | `(Int, Int, Int)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_xyz_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `rgb_to_ycbcr` | `(Int, Int, Int)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `rgb_to_ycbcr_16` | `(Int, Int, Int)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `rgb_to_ycbcr_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `swap_channels` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `to_grayscale` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `to_grayscale_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `to_grayscale_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `to_rgb` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `to_rgb_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `to_rgb_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `to_rgba` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `to_rgba_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `to_rgba_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `true_color_composite` | `(@types.Image, @types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | — |
| `unpremultiply_alpha` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `unpremultiply_alpha_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `unpremultiply_alpha_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `xyz_to_rgb` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `xyz_to_rgb_16` | `(Float, Float, Float)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `xyz_to_rgb_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |
| `ycbcr_to_rgb` | `(Int, Int, Int)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `ycbcr_to_rgb_16` | `(Int, Int, Int)` | `(Int, Int, Int) raise @types.LoadError` | — |
| `ycbcr_to_rgb_f` | `(Float, Float, Float)` | `(Float, Float, Float) raise @types.LoadError` | — |

### 伪彩色（2 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `apply_colormap` | `(@types.Image, @color.Colormap)` | `@types.Image raise @types.LoadError` | 应用 |
| `gradient_map` | `(@types.Image, Array[(Int, Byte, Byte, Byte)])` | `@types.Image raise @types.LoadError` | — |

### 感知哈希（9 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `ahash` | `(@types.Image)` | `Array[Int] raise @types.LoadError` | — |
| `ahash_16` | `(@types.Image16)` | `Array[Int] raise @types.LoadError` | — |
| `ahash_f` | `(@types.ImageF)` | `Array[Int] raise @types.LoadError` | — |
| `dhash` | `(@types.Image)` | `Array[Int] raise @types.LoadError` | — |
| `dhash_16` | `(@types.Image16)` | `Array[Int] raise @types.LoadError` | — |
| `dhash_f` | `(@types.ImageF)` | `Array[Int] raise @types.LoadError` | — |
| `phash` | `(@types.Image)` | `Array[Int] raise @types.LoadError` | — |
| `phash_16` | `(@types.Image16)` | `Array[Int] raise @types.LoadError` | — |
| `phash_f` | `(@types.ImageF)` | `Array[Int] raise @types.LoadError` | — |

### 滤波/去噪（54 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `bilateral_filter` | `(@types.Image, Int, Float, Float)` | `@types.Image raise @types.LoadError` | — |
| `bilateral_filter_16` | `(@types.Image16, Int, Float, Float)` | `@types.Image16 raise @types.LoadError` | — |
| `bilateral_filter_denoise_dn` | `(@types.Image, Int, Double, Double)` | `@types.Image raise @types.LoadError` | 去噪 |
| `bilateral_filter_f` | `(@types.ImageF, Int, Float, Float)` | `@types.ImageF raise @types.LoadError` | — |
| `bilateral_filter_fast` | `(@types.Image, Int, Float, Float, Int)` | `@types.Image raise @types.LoadError` | — |
| `bilateral_filter_fast_16` | `(@types.Image16, Int, Float, Float, Int)` | `@types.Image16 raise @types.LoadError` | — |
| `bilateral_filter_fast_f` | `(@types.ImageF, Int, Float, Float, Int)` | `@types.ImageF raise @types.LoadError` | — |
| `box_blur` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | 模糊 |
| `box_blur_16` | `(@types.Image16, Int)` | `@types.Image16 raise @types.LoadError` | 模糊 |
| `box_blur_f` | `(@types.ImageF, Int)` | `@types.ImageF raise @types.LoadError` | 模糊 |
| `calculate_brightness_dn` | `(@types.Image)` | `Double raise @types.LoadError` | 计算 |
| `calculate_contrast_dn` | `(@types.Image)` | `Double raise @types.LoadError` | 计算 |
| `calculate_noise_level_dn` | `(@types.Image)` | `Double raise @types.LoadError` | 计算 |
| `calculate_sharpness_dn` | `(@types.Image)` | `Double raise @types.LoadError` | 计算 |
| `convolve` | `(@types.Image, Array[Float], Float, Float)` | `@types.Image raise @types.LoadError` | 卷积 |
| `convolve_16` | `(@types.Image16, Array[Float], Float, Float)` | `@types.Image16 raise @types.LoadError` | 卷积 |
| `convolve_f` | `(@types.ImageF, Array[Float], Float, Float)` | `@types.ImageF raise @types.LoadError` | 卷积 |
| `create_default_denoise_config_dn` | `()` | `@denoise.DenoiseConfig` | 创建 |
| `denoise` | `(@types.Image, String)` | `@types.Image raise @types.LoadError` | 去噪 |
| `denoise_bilateral` | `(@types.Image, diameter? : Int, sigma_color? : Double, sigma_space? : Double)` | `@types.Image raise @types.LoadError` | 去噪 |
| `denoise_image_dn` | `(@types.Image, @denoise.DenoiseConfig)` | `@denoise.DenoiseResult raise @types.LoadError` | 去噪 |
| `denoise_median` | `(@types.Image, kernel_size? : Int)` | `@types.Image raise @types.LoadError` | 去噪 |
| `denoise_nlm` | `(@types.Image, config? : @enhance.NlmConfig)` | `@types.Image raise @types.LoadError` | 去噪 |
| `denoise_report_to_string_dn` | `(@denoise.DenoiseResult)` | `String` | 去噪 |
| `enhance_image_advanced_dn` | `(@types.Image, @denoise.EnhancementAlgorithm)` | `@denoise.EnhancementResult raise @types.LoadError` | — |
| `fast_gaussian_blur_1d` | `(@types.Image, Array[Double])` | `@types.Image raise @types.LoadError` | 模糊 |
| `filter_noise_segments` | `(Array[(Int, Int, Int, Int)], Int, Int, min_area_ratio? : Double, max_area_ratio? : Double)` | `Array[(Int, Int, Int, Int)] raise @types.LoadError` | — |
| `gamma_correction_enhance_dn` | `(@types.Image, Double)` | `@types.Image raise @types.LoadError` | — |
| `gaussian_blur` | `(@types.Image, Int, Float)` | `@types.Image raise @types.LoadError` | 模糊 |
| `gaussian_blur_16` | `(@types.Image16, Int, Float)` | `@types.Image16 raise @types.LoadError` | 模糊 |
| `gaussian_blur_f` | `(@types.ImageF, Int, Float)` | `@types.ImageF raise @types.LoadError` | 模糊 |
| `gaussian_filter_denoise_dn` | `(@types.Image, Int, Double)` | `@types.Image raise @types.LoadError` | 去噪 |
| `guided_filter` | `(@types.Image, Array[Float], radius? : Int, eps? : Float)` | `Array[Float] raise @types.LoadError` | — |
| `guided_filter_16` | `(@types.Image16, Array[Float], radius? : Int, eps? : Float)` | `Array[Float] raise @types.LoadError` | — |
| `guided_filter_f` | `(@types.ImageF, Array[Float], radius? : Int, eps? : Float)` | `Array[Float] raise @types.LoadError` | — |
| `guided_filter_image` | `(@types.Image, @types.Image, radius? : Int, eps? : Double)` | `@types.Image raise @types.LoadError` | — |
| `histogram_equalization_enhance_dn` | `(@types.Image)` | `@types.Image raise @types.LoadError` | 直方图 |
| `mean_filter_denoise_dn` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | 去噪 |
| `median_blur` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | 模糊 |
| `median_blur_16` | `(@types.Image16, Int)` | `@types.Image16 raise @types.LoadError` | 模糊 |
| `median_blur_f` | `(@types.ImageF, Int)` | `@types.ImageF raise @types.LoadError` | 模糊 |
| `median_filter_denoise_dn` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | 去噪 |
| `nlm_default_config` | `()` | `@enhance.NlmConfig` | — |
| `nlm_denoise` | `(@types.Image, patch_size? : Int, search_size? : Int, h? : Int)` | `@types.Image raise @types.LoadError` | 去噪 |
| `nlm_denoise_16` | `(@types.Image16, patch_size? : Int, search_size? : Int, h? : Int)` | `@types.Image16 raise @types.LoadError` | 去噪 |
| `nlm_denoise_f` | `(@types.ImageF, patch_size? : Int, search_size? : Int, h? : Int)` | `@types.ImageF raise @types.LoadError` | 去噪 |
| `nlm_denoise_fast` | `(@types.Image, patch_size? : Int, search_size? : Int, h? : Int, step? : Int)` | `@types.Image raise @types.LoadError` | 去噪 |
| `nlm_denoise_fast_16` | `(@types.Image16, patch_size? : Int, search_size? : Int, h? : Int, step? : Int)` | `@types.Image16 raise @types.LoadError` | 去噪 |
| `nlm_denoise_fast_f` | `(@types.ImageF, patch_size? : Int, search_size? : Int, h? : Int, step? : Int)` | `@types.ImageF raise @types.LoadError` | 去噪 |
| `sharpen` | `(@types.Image, Float)` | `@types.Image raise @types.LoadError` | — |
| `sharpen_16` | `(@types.Image16, Float)` | `@types.Image16 raise @types.LoadError` | — |
| `sharpen_f` | `(@types.ImageF, Float)` | `@types.ImageF raise @types.LoadError` | — |
| `structure_based_filter` | `(@types.Image, Array[@ocr.ChineseCharInfo], max_candidates? : Int)` | `Array[@ocr.ChineseCharInfo]` | — |
| `unsharp_mask_enhance_dn` | `(@types.Image, Double, Int)` | `@types.Image raise @types.LoadError` | — |

### 边缘检测（12 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `canny_edge` | `(@types.Image, low_threshold? : Int, high_threshold? : Int)` | `@types.Image raise @types.LoadError` | — |
| `canny_edge_16` | `(@types.Image16, low_threshold? : Int, high_threshold? : Int)` | `@types.Image16 raise @types.LoadError` | — |
| `canny_edge_f` | `(@types.ImageF, low_threshold? : Float, high_threshold? : Float)` | `@types.ImageF raise @types.LoadError` | — |
| `edge_detect_laplacian` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `edge_detect_laplacian_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `edge_detect_laplacian_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `edge_detect_prewitt` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `edge_detect_prewitt_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `edge_detect_prewitt_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `edge_detect_sobel` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `edge_detect_sobel_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `edge_detect_sobel_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |

### Gabor滤波（7 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `gabor_filter` | `(@types.Image, Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float)` | `@types.Image raise @types.LoadError` | — |
| `gabor_filter_16` | `(@types.Image16, Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float)` | `@types.Image16 raise @types.LoadError` | — |
| `gabor_filter_bank` | `(@types.Image, Int, Float, num_orientations? : Int, lambda? : Float, gamma? : Float)` | `@types.Image raise @types.LoadError` | — |
| `gabor_filter_bank_16` | `(@types.Image16, Int, Float, num_orientations? : Int, lambda? : Float, gamma? : Float)` | `@types.Image16 raise @types.LoadError` | — |
| `gabor_filter_bank_f` | `(@types.ImageF, Int, Float, num_orientations? : Int, lambda? : Float, gamma? : Float)` | `@types.ImageF raise @types.LoadError` | — |
| `gabor_filter_f` | `(@types.ImageF, Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float)` | `@types.ImageF raise @types.LoadError` | — |
| `gabor_kernel` | `(Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float)` | `Array[Array[Float]] raise @types.LoadError` | — |

### 频域/FFT（12 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `fft_2d` | `(@types.Image)` | `Array[@frequency.FFTResult] raise @types.LoadError` | FFT |
| `fft_2d_16` | `(@types.Image16)` | `Array[@frequency.FFTResult] raise @types.LoadError` | FFT |
| `fft_2d_f` | `(@types.ImageF)` | `Array[@frequency.FFTResult] raise @types.LoadError` | FFT |
| `fft_magnitude` | `(@frequency.FFTResult, Bool)` | `@types.Image` | FFT |
| `fft_magnitude_16` | `(@frequency.FFTResult, Bool)` | `@types.Image16` | FFT |
| `fft_magnitude_f` | `(@frequency.FFTResult, Bool)` | `@types.ImageF` | FFT |
| `fft_shift` | `(@frequency.FFTResult)` | `@frequency.FFTResult` | FFT |
| `freq_filter` | `(@types.Image, @frequency.FreqFilterType, Float, band_width? : Float)` | `@types.Image raise @types.LoadError` | — |
| `freq_filter_gaussian` | `(@types.Image, @frequency.FreqFilterType, Float, band_width? : Float)` | `@types.Image raise @types.LoadError` | — |
| `ifft_2d` | `(@frequency.FFTResult)` | `@types.Image` | — |
| `ifft_2d_16` | `(@frequency.FFTResult)` | `@types.Image16` | — |
| `ifft_2d_f` | `(@frequency.FFTResult)` | `@types.ImageF` | — |

### DCT（6 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `dct_2d` | `(@types.Image)` | `Array[Array[Double]]` | DCT |
| `dct_2d_16` | `(@types.Image16)` | `Array[Array[Double]]` | DCT |
| `dct_2d_f` | `(@types.ImageF)` | `Array[Array[Double]]` | DCT |
| `idct_2d` | `(Array[Array[Double]])` | `@types.Image` | — |
| `idct_2d_16` | `(Array[Array[Double]])` | `@types.Image16` | — |
| `idct_2d_f` | `(Array[Array[Double]])` | `@types.ImageF` | — |

### 小波变换（11 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `haar_denoise` | `(@types.Image, threshold? : Float, soft? : Bool, levels? : Int)` | `@types.Image raise @types.LoadError` | Haar小波 |
| `haar_denoise_16` | `(@types.Image16, threshold? : Float, soft? : Bool, levels? : Int)` | `@types.Image16 raise @types.LoadError` | Haar小波 |
| `haar_denoise_f` | `(@types.ImageF, threshold? : Float, soft? : Bool, levels? : Int)` | `@types.ImageF raise @types.LoadError` | Haar小波 |
| `haar_inverse_transform_2d` | `(@frequency.HaarWaveletResult)` | `@types.Image` | Haar小波 |
| `haar_inverse_transform_2d_16` | `(@frequency.HaarWaveletResult)` | `@types.Image16` | Haar小波 |
| `haar_inverse_transform_2d_f` | `(@frequency.HaarWaveletResult)` | `@types.ImageF` | Haar小波 |
| `haar_transform_1d` | `(Array[Float])` | `Array[Float]` | Haar小波 |
| `haar_transform_2d` | `(@types.Image, levels? : Int)` | `@frequency.HaarWaveletResult raise @types.LoadError` | Haar小波 |
| `haar_transform_2d_16` | `(@types.Image16, levels? : Int)` | `@frequency.HaarWaveletResult raise @types.LoadError` | Haar小波 |
| `haar_transform_2d_f` | `(@types.ImageF, levels? : Int)` | `@frequency.HaarWaveletResult raise @types.LoadError` | Haar小波 |
| `ihaar_transform_1d` | `(Array[Float])` | `Array[Float]` | — |

### 分割（38 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `fast_connected_components` | `(@types.Image)` | `Array[Int] raise @types.LoadError` | — |
| `filter_components_by_area` | `(@ocr.OcrConnectedComponentsResult, Int, Int)` | `Array[@ocr.OcrConnectedComponent] raise @types.LoadError` | — |
| `filter_components_by_aspect_ratio` | `(@ocr.OcrConnectedComponentsResult, Double, Double)` | `Array[@ocr.OcrConnectedComponent] raise @types.LoadError` | — |
| `flood_fill` | `(@types.Image, Int, Int, Array[Byte], threshold? : Int)` | `@types.Image raise @types.LoadError` | — |
| `grab_cut` | `(@types.Image, Int, Int, Int, Int, iterations? : Int)` | `@types.Image raise @types.LoadError` | — |
| `grabcut_segmentation` | `(@types.Image, Int, Int, Int, Int, @segmentation.GrabCutConfig)` | `@segmentation.SemanticSegmentationResult raise @types.LoadError` | — |
| `kmeans_segment` | `(@types.Image, Int, max_iters? : Int)` | `(@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError` | — |
| `kmeans_segment_16` | `(@types.Image16, Int, max_iters? : Int)` | `(@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError` | — |
| `kmeans_segment_f` | `(@types.ImageF, Int, max_iters? : Int)` | `(@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError` | — |
| `kmeans_segmentation` | `(@types.Image, @segmentation.KMeansConfig)` | `@segmentation.SemanticSegmentationResult raise @types.LoadError` | — |
| `merge_adjacent_components` | `(Array[@ocr.OcrConnectedComponent], Int)` | `Array[@ocr.OcrConnectedComponent] raise @types.LoadError` | — |
| `merge_small_segments` | `(Array[(Int, Int, Int, Int)], Int, Int)` | `Array[(Int, Int, Int, Int)] raise @types.LoadError` | — |
| `region_growing` | `(@types.Image, Array[(Int, Int)], threshold? : Double)` | `@segment.SegmentationResult` | — |
| `region_growing_segment` | `(@types.Image, Array[(Int, Int)], threshold? : Int)` | `(@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError` | — |
| `region_growing_segmentation_medical` | `(@medical.MedicalImage, Int, Int, Int, Double)` | `Array[Bool]` | — |
| `remove_small_objects` | `(@types.Image, max_size? : Int)` | `@types.Image raise @types.LoadError` | — |
| `segment_by_connected_components` | `(@types.Image, min_area? : Int, max_area? : Int)` | `Array[(Int, Int, Int, Int)] raise @types.LoadError` | 分割 |
| `segment_connected_strokes` | `(@types.Image, @ocr.HandwritingRecognitionConfig)` | `@ocr.StrokeSegmentationResult` | 分割 |
| `segment_cursive_chars` | `(@types.Image, min_char_width? : Int, max_char_width? : Int)` | `Array[(Int, Int, Int, Int)]` | 分割 |
| `segment_page` | `(@types.Image)` | `Array[@ocr.TextRegion] raise @types.LoadError` | 分割 |
| `segment_paragraphs` | `(Array[@ocr.TextLineAttributes])` | `Array[Array[@ocr.TextLineAttributes]]` | 分割 |
| `segment_to_color` | `(@segment.SegmentLabelImage)` | `@types.Image raise @types.LoadError` | 分割 |
| `segmentation_report_to_string` | `(@segmentation.SemanticSegmentationResult, @segmentation.SegmentationMetrics)` | `String` | 分割 |
| `segmentation_to_color` | `(@segment.SegmentationResult, Int, Int)` | `@types.Image` | 分割 |
| `segmentation_to_image` | `(@segmentation.SemanticSegmentationResult)` | `@types.Image` | 分割 |
| `slic` | `(@types.Image, Int, Int, Int)` | `@segment.SuperpixelResult raise @types.LoadError` | — |
| `slic_16` | `(@types.Image16, Int, Int, Int)` | `@segment.SuperpixelResult raise @types.LoadError` | — |
| `slic_f` | `(@types.ImageF, Int, Int, Int)` | `@segment.SuperpixelResult raise @types.LoadError` | — |
| `superpixel_segmentation` | `(@types.Image, Int)` | `@segmentation.SuperpixelResult raise @types.LoadError` | — |
| `watershed` | `(@types.Image, Array[Int])` | `Array[Int] raise @types.LoadError` | — |
| `watershed_16` | `(@types.Image16, Array[Int])` | `Array[Int] raise @types.LoadError` | — |
| `watershed_auto` | `(@types.Image)` | `(Array[Int], Int) raise @types.LoadError` | — |
| `watershed_auto_16` | `(@types.Image16)` | `(Array[Int], Int) raise @types.LoadError` | — |
| `watershed_auto_f` | `(@types.ImageF)` | `(Array[Int], Int) raise @types.LoadError` | — |
| `watershed_default_config` | `()` | `@segment.WatershedConfig` | — |
| `watershed_f` | `(@types.ImageF, Array[Int])` | `Array[Int] raise @types.LoadError` | — |
| `watershed_segment` | `(@types.Image, config? : @segment.WatershedConfig)` | `@segment.SegmentationResult` | — |
| `watershed_segmentation` | `(@types.Image, @segmentation.WatershedConfig)` | `@segmentation.SemanticSegmentationResult raise @types.LoadError` | — |

### 连通域（2 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `connected_components` | `(@types.Image, Int)` | `(@segment.ConnectedComponentLabelImage, Array[@segment.ConnectedComponent]) raise @types.LoadError` | — |
| `connected_components_analysis` | `(@types.Image, connectivity? : Int)` | `@ocr.OcrConnectedComponentsResult raise @types.LoadError` | — |

### 形态学（36 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `dilate` | `(@types.Image)` | `@types.Image` | 膨胀 |
| `dilate_16` | `(@types.Image16)` | `@types.Image16` | 膨胀 |
| `dilate_custom` | `(@types.Image, @segment.StructuringElement)` | `@types.Image` | 膨胀 |
| `dilate_custom_16` | `(@types.Image16, @segment.StructuringElement)` | `@types.Image16` | 膨胀 |
| `dilate_custom_f` | `(@types.ImageF, @segment.StructuringElement)` | `@types.ImageF` | 膨胀 |
| `dilate_f` | `(@types.ImageF)` | `@types.ImageF` | 膨胀 |
| `erode` | `(@types.Image)` | `@types.Image` | 腐蚀 |
| `erode_16` | `(@types.Image16)` | `@types.Image16` | 腐蚀 |
| `erode_custom` | `(@types.Image, @segment.StructuringElement)` | `@types.Image` | 腐蚀 |
| `erode_custom_16` | `(@types.Image16, @segment.StructuringElement)` | `@types.Image16` | 腐蚀 |
| `erode_custom_f` | `(@types.ImageF, @segment.StructuringElement)` | `@types.ImageF` | 腐蚀 |
| `erode_f` | `(@types.ImageF)` | `@types.ImageF` | 腐蚀 |
| `morph_blackhat` | `(@types.Image)` | `@types.Image` | 形态学 |
| `morph_blackhat_16` | `(@types.Image16)` | `@types.Image16` | 形态学 |
| `morph_blackhat_f` | `(@types.ImageF)` | `@types.ImageF` | 形态学 |
| `morph_close` | `(@types.Image)` | `@types.Image` | 形态学 |
| `morph_close_16` | `(@types.Image16)` | `@types.Image16` | 形态学 |
| `morph_close_custom` | `(@types.Image, @segment.StructuringElement)` | `@types.Image` | 形态学 |
| `morph_close_custom_16` | `(@types.Image16, @segment.StructuringElement)` | `@types.Image16` | 形态学 |
| `morph_close_custom_f` | `(@types.ImageF, @segment.StructuringElement)` | `@types.ImageF` | 形态学 |
| `morph_close_f` | `(@types.ImageF)` | `@types.ImageF` | 形态学 |
| `morph_gradient` | `(@types.Image)` | `@types.Image` | 形态学 |
| `morph_gradient_16` | `(@types.Image16)` | `@types.Image16` | 形态学 |
| `morph_gradient_f` | `(@types.ImageF)` | `@types.ImageF` | 形态学 |
| `morph_open` | `(@types.Image)` | `@types.Image` | 形态学 |
| `morph_open_16` | `(@types.Image16)` | `@types.Image16` | 形态学 |
| `morph_open_custom` | `(@types.Image, @segment.StructuringElement)` | `@types.Image` | 形态学 |
| `morph_open_custom_16` | `(@types.Image16, @segment.StructuringElement)` | `@types.Image16` | 形态学 |
| `morph_open_custom_f` | `(@types.ImageF, @segment.StructuringElement)` | `@types.ImageF` | 形态学 |
| `morph_open_f` | `(@types.ImageF)` | `@types.ImageF` | 形态学 |
| `morph_tophat` | `(@types.Image)` | `@types.Image` | 形态学 |
| `morph_tophat_16` | `(@types.Image16)` | `@types.Image16` | 形态学 |
| `morph_tophat_f` | `(@types.ImageF)` | `@types.ImageF` | 形态学 |
| `se_cross` | `(Int)` | `@segment.StructuringElement` | — |
| `se_ellipse` | `(Int)` | `@segment.StructuringElement` | — |
| `se_rect` | `(Int, Int)` | `@segment.StructuringElement` | — |

### 轮廓分析（14 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `approx_poly_dp` | `(Array[@edge.ContourPoint], Float, closed? : Bool)` | `Array[@edge.ContourPoint] raise @types.LoadError` | — |
| `contour_area` | `(@edge.Contour)` | `Float` | 轮廓 |
| `contour_perimeter` | `(@edge.Contour)` | `Float` | 轮廓 |
| `convex_hull` | `(Array[@edge.ContourPoint])` | `Array[@edge.ContourPoint]` | — |
| `draw_contours` | `(@types.Image, Array[@edge.Contour], Array[Byte])` | `@types.Image raise @types.LoadError` | 绘制 |
| `draw_contours_16` | `(@types.Image16, Array[@edge.Contour], Array[Int])` | `@types.Image16 raise @types.LoadError` | 绘制 |
| `draw_contours_f` | `(@types.ImageF, Array[@edge.Contour], Array[Float])` | `@types.ImageF raise @types.LoadError` | 绘制 |
| `find_contours` | `(@types.Image)` | `Array[@edge.Contour] raise @types.LoadError` | — |
| `find_contours_16` | `(@types.Image16)` | `Array[@edge.Contour] raise @types.LoadError` | — |
| `find_contours_f` | `(@types.ImageF)` | `Array[@edge.Contour] raise @types.LoadError` | — |
| `hu_moments` | `(@edge.Moments)` | `Array[Double] raise @types.LoadError` | — |
| `hu_moments_features` | `(@types.Image)` | `Array[Double] raise @types.LoadError` | — |
| `image_moments` | `(Array[@edge.ContourPoint])` | `@edge.Moments` | — |
| `min_enclosing_circle` | `(Array[@edge.ContourPoint])` | `(@edge.ContourPoint, Float)` | — |

### 霍夫变换（7 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `hough_circles` | `(@types.Image, dp? : Int, min_dist? : Int, param1? : Int, param2? : Int, min_radius? : Int, max_radius? : Int)` | `Array[@edge.Circle] raise @types.LoadError` | 霍夫 |
| `hough_circles_16` | `(@types.Image16, dp? : Int, min_dist? : Int, param1? : Int, param2? : Int, min_radius? : Int, max_radius? : Int)` | `Array[@edge.Circle] raise @types.LoadError` | 霍夫 |
| `hough_circles_f` | `(@types.ImageF, dp? : Int, min_dist? : Int, param1? : Int, param2? : Int, min_radius? : Int, max_radius? : Int)` | `Array[@edge.Circle] raise @types.LoadError` | 霍夫 |
| `hough_lines` | `(@types.Image, Int, theta_resolution? : Float, rho_resolution? : Float)` | `Array[@edge.HoughLine] raise @types.LoadError` | 霍夫 |
| `hough_lines_16` | `(@types.Image16, Int, theta_resolution? : Float, rho_resolution? : Float)` | `Array[@edge.HoughLine] raise @types.LoadError` | 霍夫 |
| `hough_lines_f` | `(@types.ImageF, Int, theta_resolution? : Float, rho_resolution? : Float)` | `Array[@edge.HoughLine] raise @types.LoadError` | 霍夫 |
| `hough_lines_nms` | `(Array[@edge.HoughLine], rho_threshold? : Float, theta_threshold? : Float)` | `Array[@edge.HoughLine] raise @types.LoadError` | 霍夫 |

### 几何变换（63 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `add_border` | `(@types.Image, Int, Int, Int, Int, Array[Byte])` | `@types.Image raise @types.LoadError` | — |
| `affine_apply` | `(@registration.AffineTransform, Double, Double)` | `(Double, Double)` | — |
| `affine_compose` | `(@registration.AffineTransform, @registration.AffineTransform)` | `@registration.AffineTransform` | — |
| `affine_identity` | `()` | `@registration.AffineTransform` | — |
| `affine_rotation` | `(Double)` | `@registration.AffineTransform` | — |
| `affine_scale` | `(Double, Double)` | `@registration.AffineTransform` | — |
| `affine_translation` | `(Double, Double)` | `@registration.AffineTransform` | — |
| `align_images` | `(@types.Image, @types.Image)` | `(@types.Image, @registration.RegistrationResult) raise @types.LoadError` | — |
| `apply_homography` | `(@stitch.Homography, Double, Double)` | `(Double, Double)` | 应用 |
| `build_gaussian_pyramid` | `(@types.Image, Int)` | `Array[@types.Image] raise @types.LoadError` | 构建 |
| `build_gaussian_pyramid_16` | `(@types.Image16, Int)` | `Array[@types.Image16] raise @types.LoadError` | 构建 |
| `build_gaussian_pyramid_f` | `(@types.ImageF, Int)` | `Array[@types.ImageF] raise @types.LoadError` | 构建 |
| `build_laplacian_pyramid` | `(@types.Image, Int)` | `Array[@types.Image] raise @types.LoadError` | 构建 |
| `build_laplacian_pyramid_16` | `(@types.Image16, Int)` | `Array[@types.Image16] raise @types.LoadError` | 构建 |
| `build_laplacian_pyramid_f` | `(@types.ImageF, Int)` | `Array[@types.ImageF] raise @types.LoadError` | 构建 |
| `crop` | `(@types.Image, Int, Int, Int, Int)` | `@types.Image raise @types.LoadError` | 裁剪 |
| `crop_16` | `(@types.Image16, Int, Int, Int, Int)` | `@types.Image16 raise @types.LoadError` | 裁剪 |
| `crop_f` | `(@types.ImageF, Int, Int, Int, Int)` | `@types.ImageF raise @types.LoadError` | 裁剪 |
| `estimate_homography_ransac` | `(Array[@stitch.MatchPair], Array[@stitch.FeaturePoint], Array[@stitch.FeaturePoint], iterations? : Int, threshold? : Double)` | `(@stitch.Homography?, Array[@stitch.MatchPair])` | 估计 |
| `flip_horizontal` | `(@types.Image)` | `@types.Image` | 翻转 |
| `flip_horizontal_16` | `(@types.Image16)` | `@types.Image16` | 翻转 |
| `flip_horizontal_f` | `(@types.ImageF)` | `@types.ImageF` | 翻转 |
| `flip_vertical` | `(@types.Image)` | `@types.Image` | 翻转 |
| `flip_vertical_16` | `(@types.Image16)` | `@types.Image16` | 翻转 |
| `flip_vertical_f` | `(@types.ImageF)` | `@types.ImageF` | 翻转 |
| `get_affine_transform` | `(Array[(Float, Float)], Array[(Float, Float)])` | `@transform.AffineMatrix?` | — |
| `get_perspective_transform` | `(Array[(Float, Float)], Array[(Float, Float)])` | `@transform.PerspectiveMatrix?` | — |
| `get_rotation_matrix_2d` | `((Float, Float), Float, Float)` | `@transform.AffineMatrix` | — |
| `hstack` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | — |
| `identity_homography` | `()` | `@stitch.Homography` | — |
| `invert_homography` | `(@stitch.Homography)` | `@stitch.Homography?` | — |
| `pad` | `(@types.Image, Int, Int, Array[Byte])` | `@types.Image raise @types.LoadError` | — |
| `paste_tile` | `(@types.Image, @types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `pyr_down` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `pyr_down_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `pyr_down_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `pyr_up` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `pyr_up_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `pyr_up_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `ransac_homography` | `(Array[((Float, Float), (Float, Float))], iterations? : Int, threshold? : Float)` | `Array[Float]? raise @types.LoadError` | — |
| `rotate` | `(@types.Image, Float)` | `@types.Image` | 旋转 |
| `rotate_180` | `(@types.Image)` | `@types.Image` | 旋转 |
| `rotate_180_16` | `(@types.Image16)` | `@types.Image16` | 旋转 |
| `rotate_180_f` | `(@types.ImageF)` | `@types.ImageF` | 旋转 |
| `rotate_270` | `(@types.Image)` | `@types.Image` | 旋转 |
| `rotate_270_16` | `(@types.Image16)` | `@types.Image16` | 旋转 |
| `rotate_270_f` | `(@types.ImageF)` | `@types.ImageF` | 旋转 |
| `rotate_90` | `(@types.Image)` | `@types.Image` | 旋转 |
| `rotate_90_16` | `(@types.Image16)` | `@types.Image16` | 旋转 |
| `rotate_90_f` | `(@types.ImageF)` | `@types.ImageF` | 旋转 |
| `tile` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `tile_region` | `(Int, Int, @performance.TileConfig)` | `(Int, Int, Int, Int)` | — |
| `transpose` | `(@types.Image)` | `@types.Image` | — |
| `transpose_16` | `(@types.Image16)` | `@types.Image16` | — |
| `transpose_f` | `(@types.ImageF)` | `@types.ImageF` | — |
| `vstack` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | — |
| `warp_affine` | `(@types.Image, (Float, Float, Float, Float, Float, Float), Int, Int)` | `@types.Image` | 变换 |
| `warp_affine_16` | `(@types.Image16, (Float, Float, Float, Float, Float, Float), Int, Int)` | `@types.Image16` | 变换 |
| `warp_affine_f` | `(@types.ImageF, (Float, Float, Float, Float, Float, Float), Int, Int)` | `@types.ImageF` | 变换 |
| `warp_affine_transform` | `(@types.Image, @registration.AffineTransform, out_width? : Int, out_height? : Int)` | `@types.Image raise @types.LoadError` | 变换 |
| `warp_perspective` | `(@types.Image, @transform.PerspectiveMatrix, Int, Int)` | `@types.Image` | 变换 |
| `warp_perspective_16` | `(@types.Image16, @transform.PerspectiveMatrix, Int, Int)` | `@types.Image16` | 变换 |
| `warp_perspective_f` | `(@types.ImageF, @transform.PerspectiveMatrix, Int, Int)` | `@types.ImageF` | 变换 |

### Seam Carving（12 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `compute_energy` | `(@types.Image)` | `Array[Double]` | 计算 |
| `find_horizontal_seam` | `(Array[Double], Int, Int)` | `Array[Int]` | — |
| `find_vertical_seam` | `(Array[Double], Int, Int)` | `Array[Int]` | — |
| `remove_horizontal_seam` | `(@types.Image, Array[Int])` | `@types.Image` | — |
| `remove_horizontal_seam_16` | `(@types.Image16, Array[Int])` | `@types.Image16` | — |
| `remove_horizontal_seam_f` | `(@types.ImageF, Array[Int])` | `@types.ImageF` | — |
| `remove_vertical_seam` | `(@types.Image, Array[Int])` | `@types.Image` | — |
| `remove_vertical_seam_16` | `(@types.Image16, Array[Int])` | `@types.Image16` | — |
| `remove_vertical_seam_f` | `(@types.ImageF, Array[Int])` | `@types.ImageF` | — |
| `seam_carve_resize` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `seam_carve_resize_16` | `(@types.Image16, Int, Int)` | `@types.Image16 raise @types.LoadError` | — |
| `seam_carve_resize_f` | `(@types.ImageF, Int, Int)` | `@types.ImageF raise @types.LoadError` | — |

### 特征检测/匹配（40 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `combined_features` | `(@types.Image)` | `Array[Double] raise @types.LoadError` | — |
| `estimate_translation` | `(@types.Image, @types.Image, max_offset? : Int)` | `@registration.RegistrationResult raise @types.LoadError` | 估计 |
| `find_line_intersections` | `(Array[(Int, Int, Int)], Array[(Int, Int, Int)])` | `Array[(Int, Int)]` | — |
| `good_features_to_track` | `(@types.Image, Int, Float, min_distance? : Int)` | `Array[@feature.CornerPoint] raise @types.LoadError` | — |
| `good_features_to_track_16` | `(@types.Image16, Int, Float, min_distance? : Int)` | `Array[@feature.CornerPoint] raise @types.LoadError` | — |
| `good_features_to_track_f` | `(@types.ImageF, Int, Float, min_distance? : Int)` | `Array[@feature.CornerPoint] raise @types.LoadError` | — |
| `grid_features` | `(@types.Image, grid_rows? : Int, grid_cols? : Int)` | `@ocr.GridFeatures raise @types.LoadError` | — |
| `harris_corners` | `(@types.Image, k? : Float, threshold? : Float, min_distance? : Int)` | `Array[@feature.CornerPoint] raise @types.LoadError` | — |
| `harris_corners_16` | `(@types.Image16, k? : Float, threshold? : Float, min_distance? : Int)` | `Array[@feature.CornerPoint] raise @types.LoadError` | — |
| `harris_corners_f` | `(@types.ImageF, k? : Float, threshold? : Float, min_distance? : Int)` | `Array[@feature.CornerPoint] raise @types.LoadError` | — |
| `hog_features` | `(@types.Image, cell_size? : Int, num_bins? : Int)` | `@ocr.HogFeatures raise @types.LoadError` | — |
| `horn_schunck` | `(@types.Image, @types.Image, alpha? : Float, iterations? : Int)` | `(Array[Float], Array[Float]) raise @types.LoadError` | — |
| `horn_schunck_16` | `(@types.Image16, @types.Image16, alpha? : Float, iterations? : Int)` | `(Array[Float], Array[Float]) raise @types.LoadError` | — |
| `horn_schunck_f` | `(@types.ImageF, @types.ImageF, alpha? : Float, iterations? : Int)` | `(Array[Float], Array[Float]) raise @types.LoadError` | — |
| `lucas_kanade` | `(@types.Image, @types.Image, Array[(Int, Int)], window_size? : Int, max_iter? : Int)` | `Array[@feature.FlowResult] raise @types.LoadError` | — |
| `lucas_kanade_16` | `(@types.Image16, @types.Image16, Array[(Int, Int)], window_size? : Int, max_iter? : Int)` | `Array[@feature.FlowResult] raise @types.LoadError` | — |
| `lucas_kanade_f` | `(@types.ImageF, @types.ImageF, Array[(Int, Int)], window_size? : Int, max_iter? : Int)` | `Array[@feature.FlowResult] raise @types.LoadError` | — |
| `match_features` | `(Array[@stitch.FeaturePoint], Array[@stitch.FeaturePoint], ratio_threshold? : Double)` | `Array[@stitch.MatchPair]` | 匹配 |
| `normalize_features` | `(Array[Double])` | `Array[Double] raise @types.LoadError` | — |
| `orb_detect` | `(@types.Image, max_features? : Int, threshold? : Int)` | `Array[@feature.OrbDescriptor] raise @types.LoadError` | — |
| `orb_detect_16` | `(@types.Image16, max_features? : Int, threshold? : Int)` | `Array[@feature.OrbDescriptor] raise @types.LoadError` | — |
| `orb_detect_f` | `(@types.ImageF, max_features? : Int, threshold? : Int)` | `Array[@feature.OrbDescriptor] raise @types.LoadError` | — |
| `orb_hamming` | `(@feature.OrbDescriptor, @feature.OrbDescriptor)` | `Int` | — |
| `orb_match` | `(Array[@feature.OrbDescriptor], Array[@feature.OrbDescriptor], max_distance? : Int)` | `Array[@feature.DescriptorMatch] raise @types.LoadError` | — |
| `projection_features` | `(@types.Image)` | `@ocr.ProjectionFeatures raise @types.LoadError` | — |
| `sift_detect` | `(@types.Image, max_features? : Int, contrast_threshold? : Float)` | `Array[@feature.SiftDescriptor] raise @types.LoadError` | — |
| `sift_detect_16` | `(@types.Image16, max_features? : Int, contrast_threshold? : Float)` | `Array[@feature.SiftDescriptor] raise @types.LoadError` | — |
| `sift_detect_f` | `(@types.ImageF, max_features? : Int, contrast_threshold? : Float)` | `Array[@feature.SiftDescriptor] raise @types.LoadError` | — |
| `sift_match` | `(Array[@feature.SiftDescriptor], Array[@feature.SiftDescriptor], max_distance? : Float, ratio_test? : Float)` | `Array[@feature.SiftMatch] raise @types.LoadError` | — |
| `standardize_features` | `(Array[Double])` | `Array[Double] raise @types.LoadError` | — |
| `statistical_features` | `(@types.Image)` | `@ocr.StatisticalFeatures raise @types.LoadError` | — |
| `template_match` | `(@types.Image, @types.Image, match_method? : @feature.TemplateMatchMethod)` | `Array[@feature.TemplateMatchResult] raise @types.LoadError` | — |
| `template_match_16` | `(@types.Image16, @types.Image16, match_method? : @feature.TemplateMatchMethod)` | `Array[@feature.TemplateMatchResult] raise @types.LoadError` | — |
| `template_match_best` | `(@types.Image, @types.Image, match_method? : @feature.TemplateMatchMethod)` | `@feature.TemplateMatchResult? raise @types.LoadError` | — |
| `template_match_best_16` | `(@types.Image16, @types.Image16, match_method? : @feature.TemplateMatchMethod)` | `@feature.TemplateMatchResult? raise @types.LoadError` | — |
| `template_match_best_f` | `(@types.ImageF, @types.ImageF, match_method? : @feature.TemplateMatchMethod)` | `@feature.TemplateMatchResult? raise @types.LoadError` | — |
| `template_match_f` | `(@types.ImageF, @types.ImageF, match_method? : @feature.TemplateMatchMethod)` | `Array[@feature.TemplateMatchResult] raise @types.LoadError` | — |
| `template_matcher_add` | `(@ocr.TemplateMatcher, String, Array[Double])` | `@ocr.TemplateMatcher raise @types.LoadError` | — |
| `template_matcher_create` | `(distance_metric? : String)` | `@ocr.TemplateMatcher` | — |
| `template_matcher_predict` | `(@ocr.TemplateMatcher, Array[Double])` | `@ocr.ClassificationResult raise @types.LoadError` | — |

### LBP纹理（7 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `lbp` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `lbp_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `lbp_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |
| `lbp_features` | `(@types.Image, radius? : Int, num_points? : Int, num_bins? : Int)` | `@ocr.LbpFeatures raise @types.LoadError` | — |
| `lbp_uniform` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `lbp_uniform_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | — |
| `lbp_uniform_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | — |

### GLCM纹理（4 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `glcm_features` | `(Array[Array[Int]])` | `@feature.GlcmFeatures` | — |
| `glcm_features_multi_direction` | `(@types.Image, levels? : Int)` | `Array[@feature.GlcmFeatures] raise @types.LoadError` | — |
| `glcm_features_multi_direction_16` | `(@types.Image16, levels? : Int)` | `Array[@feature.GlcmFeatures] raise @types.LoadError` | — |
| `glcm_features_multi_direction_f` | `(@types.ImageF, levels? : Int)` | `Array[@feature.GlcmFeatures] raise @types.LoadError` | — |

### 直方图（14 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `compare_hist` | `(Array[Int], Array[Int], @feature.HistCompareMethod)` | `Float raise @types.LoadError` | — |
| `histogram` | `(@types.Image)` | `Array[Int] raise @types.LoadError` | 直方图 |
| `histogram_16` | `(@types.Image16)` | `Array[Int] raise @types.LoadError` | 直方图 |
| `histogram_entropy` | `(@types.Image)` | `Double raise @types.LoadError` | 直方图 |
| `histogram_equalize` | `(@types.Image)` | `@types.Image raise @types.LoadError` | 直方图 |
| `histogram_equalize_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | 直方图 |
| `histogram_equalize_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | 直方图 |
| `histogram_f` | `(@types.ImageF)` | `Array[Int] raise @types.LoadError` | 直方图 |
| `histogram_matching` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 直方图 |
| `histogram_matching_16` | `(@types.Image16, @types.Image16)` | `@types.Image16 raise @types.LoadError` | 直方图 |
| `histogram_matching_f` | `(@types.ImageF, @types.ImageF)` | `@types.ImageF raise @types.LoadError` | 直方图 |
| `histogram_normalize` | `(@types.Image)` | `@types.Image raise @types.LoadError` | 直方图 |
| `histogram_normalize_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | 直方图 |
| `histogram_normalize_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | 直方图 |

### 混合模式（14 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `alpha_blend` | `(@types.Image, @types.Image, Float)` | `@types.Image raise @types.LoadError` | — |
| `blend_color_burn` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_color_dodge` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_darken` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_difference` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_exclusion` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_hard_light` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_lighten` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_linear_burn` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_linear_dodge` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_multiply` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_overlay` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_screen` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |
| `blend_soft_light` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 混合 |

### 阈值/量化（26 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `adaptive_threshold_gaussian` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `adaptive_threshold_gaussian_16` | `(@types.Image16, Int, Int)` | `@types.Image16 raise @types.LoadError` | — |
| `adaptive_threshold_gaussian_f` | `(@types.ImageF, Int, Float)` | `@types.ImageF raise @types.LoadError` | — |
| `adaptive_threshold_mean` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `adaptive_threshold_mean_16` | `(@types.Image16, Int, Int)` | `@types.Image16 raise @types.LoadError` | — |
| `adaptive_threshold_mean_f` | `(@types.ImageF, Int, Float)` | `@types.ImageF raise @types.LoadError` | — |
| `fast_threshold_lut` | `(@types.Image, Array[Int])` | `@types.Image raise @types.LoadError` | — |
| `floyd_steinberg` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | — |
| `floyd_steinberg_16` | `(@types.Image16, Int)` | `@types.Image16 raise @types.LoadError` | — |
| `floyd_steinberg_f` | `(@types.ImageF, Int)` | `@types.ImageF raise @types.LoadError` | — |
| `kmeans_quantize` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `kmeans_quantize_16` | `(@types.Image16, Int, Int)` | `@types.Image16 raise @types.LoadError` | — |
| `kmeans_quantize_f` | `(@types.ImageF, Int, Int)` | `@types.ImageF raise @types.LoadError` | — |
| `median_cut` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | — |
| `median_cut_16` | `(@types.Image16, Int)` | `@types.Image16 raise @types.LoadError` | — |
| `median_cut_f` | `(@types.ImageF, Int)` | `@types.ImageF raise @types.LoadError` | — |
| `niblack_threshold` | `(@types.Image, window_size? : Int, k? : Double)` | `@types.Image raise @types.LoadError` | — |
| `otsu_threshold` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `otsu_threshold_value` | `(@types.Image)` | `Double raise @types.LoadError` | — |
| `pixelate` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | — |
| `sauvola_threshold` | `(@types.Image, window_size? : Int, k? : Double, r? : Double)` | `@types.Image raise @types.LoadError` | — |
| `threshold` | `(@types.Image, Int)` | `@types.Image` | 阈值化 |
| `threshold_otsu` | `(@types.Image)` | `@types.Image raise @types.LoadError` | 阈值化 |
| `threshold_otsu_16` | `(@types.Image16)` | `@types.Image16 raise @types.LoadError` | 阈值化 |
| `threshold_otsu_f` | `(@types.ImageF)` | `@types.ImageF raise @types.LoadError` | 阈值化 |
| `threshold_segmentation` | `(@types.Image, Double)` | `@segmentation.SemanticSegmentationResult raise @types.LoadError` | 阈值化 |

### 积分图像（10 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `integral_image` | `(@types.Image)` | `@feature.IntegralImage raise @types.LoadError` | — |
| `integral_image_16` | `(@types.Image16)` | `@feature.IntegralImage raise @types.LoadError` | — |
| `integral_image_f` | `(@types.ImageF)` | `@feature.IntegralImage raise @types.LoadError` | — |
| `integral_image_sq` | `(@types.Image)` | `@feature.IntegralImageSq raise @types.LoadError` | — |
| `integral_image_sq_16` | `(@types.Image16)` | `@feature.IntegralImageSq raise @types.LoadError` | — |
| `integral_image_sq_f` | `(@types.ImageF)` | `@feature.IntegralImageSq raise @types.LoadError` | — |
| `integral_mean` | `(@feature.IntegralImage, Int, Int, Int, Int)` | `Float raise @types.LoadError` | — |
| `integral_sum` | `(@feature.IntegralImage, Int, Int, Int, Int)` | `Int64 raise @types.LoadError` | — |
| `integral_sum_sq` | `(@feature.IntegralImageSq, Int, Int, Int, Int)` | `Int64 raise @types.LoadError` | — |
| `integral_variance` | `(@feature.IntegralImage, @feature.IntegralImageSq, Int, Int, Int, Int)` | `Float raise @types.LoadError` | — |

### 距离变换（1 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `distance_transform` | `(@types.Image, distance_type? : Int)` | `Array[Float] raise @types.LoadError` | — |

### Retinex/色调映射（15 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `gamma_tonemap` | `(@types.ImageF, Float)` | `@types.Image raise @types.LoadError` | — |
| `gamma_tonemap_16` | `(@types.ImageF, Float)` | `@types.Image16 raise @types.LoadError` | — |
| `gamma_tonemap_f` | `(@types.ImageF, Float)` | `@types.ImageF raise @types.LoadError` | — |
| `msr` | `(@types.Image, sigmas? : Array[Float], gain? : Float, offset? : Float)` | `@types.Image raise @types.LoadError` | — |
| `msr_16` | `(@types.Image16, sigmas? : Array[Float], gain? : Float, offset? : Float)` | `@types.Image16 raise @types.LoadError` | — |
| `msr_f` | `(@types.ImageF, sigmas? : Array[Float], gain? : Float, offset? : Float)` | `@types.ImageF raise @types.LoadError` | — |
| `msrcr` | `(@types.Image, sigmas? : Array[Float], gain? : Float, offset? : Float, alpha? : Float, beta? : Float)` | `@types.Image raise @types.LoadError` | — |
| `msrcr_16` | `(@types.Image16, sigmas? : Array[Float], gain? : Float, offset? : Float, alpha? : Float, beta? : Float)` | `@types.Image16 raise @types.LoadError` | — |
| `msrcr_f` | `(@types.ImageF, sigmas? : Array[Float], gain? : Float, offset? : Float, alpha? : Float, beta? : Float)` | `@types.ImageF raise @types.LoadError` | — |
| `reinhard_tonemap` | `(@types.ImageF, key? : Float)` | `@types.Image raise @types.LoadError` | — |
| `reinhard_tonemap_16` | `(@types.ImageF, key? : Float)` | `@types.Image16 raise @types.LoadError` | — |
| `reinhard_tonemap_f` | `(@types.ImageF, key? : Float)` | `@types.ImageF raise @types.LoadError` | — |
| `ssr` | `(@types.Image, sigma? : Float, gain? : Float, offset? : Float)` | `@types.Image raise @types.LoadError` | — |
| `ssr_16` | `(@types.Image16, sigma? : Float, gain? : Float, offset? : Float)` | `@types.Image16 raise @types.LoadError` | — |
| `ssr_f` | `(@types.ImageF, sigma? : Float, gain? : Float, offset? : Float)` | `@types.ImageF raise @types.LoadError` | — |

### 图像修复（12 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `inpaint` | `(@types.Image, @types.Image, iterations? : Int)` | `@types.Image raise @types.LoadError` | — |
| `inpaint_16` | `(@types.Image16, @types.Image16, iterations? : Int)` | `@types.Image16 raise @types.LoadError` | — |
| `inpaint_advanced` | `(@types.Image, @types.Image, radius? : Int)` | `@types.Image raise @types.LoadError` | — |
| `inpaint_default_config` | `()` | `@enhance.InpaintConfig` | — |
| `inpaint_diffusion_ip` | `(@types.Image, @types.Image, Int)` | `@types.Image` | — |
| `inpaint_f` | `(@types.ImageF, @types.ImageF, iterations? : Int)` | `@types.ImageF raise @types.LoadError` | — |
| `inpaint_fast` | `(@types.Image, @types.Image, radius? : Int)` | `@types.Image raise @types.LoadError` | — |
| `inpaint_fast_16` | `(@types.Image16, @types.Image16, radius? : Int)` | `@types.Image16 raise @types.LoadError` | — |
| `inpaint_fast_f` | `(@types.ImageF, @types.ImageF, radius? : Int)` | `@types.ImageF raise @types.LoadError` | — |
| `inpaint_ip` | `(@types.Image, @types.Image, @inpainting.InpaintingConfig)` | `@inpainting.InpaintingResult` | — |
| `inpaint_simple_ip` | `(@types.Image, @types.Image, Int)` | `@types.Image` | — |
| `inpainting_report_to_string_ip` | `(@inpainting.InpaintingResult)` | `String` | — |

### 噪声（2 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `add_noise_gaussian` | `(@types.Image, Float, UInt)` | `@types.Image` | — |
| `add_noise_salt_pepper` | `(@types.Image, Float, UInt)` | `@types.Image` | — |

### 统计（14 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `adjacent_correlation` | `(@types.Image, direction? : String)` | `Double raise @types.LoadError` | — |
| `calculate_accuracy_stats` | `(Array[String], Array[String])` | `@ocr.AccuracyStats raise @types.LoadError` | 计算 |
| `calculate_roi_stats_medical` | `(@medical.MedicalImage, Array[Bool])` | `(Double, Double, Int)` | 计算 |
| `compute_stats` | `(@types.Image)` | `@util.ImageStats` | 计算 |
| `compute_stats_16` | `(@types.Image16)` | `@util.ImageStats` | 计算 |
| `compute_stats_f` | `(@types.ImageF)` | `@util.ImageStatsF` | 计算 |
| `dataset_stats` | `(@ocr.TrainingDataset)` | `(Int, Int, Array[(String, Int)])` | — |
| `entropy_value` | `(@types.Image)` | `Float` | — |
| `mean_value` | `(@types.Image)` | `Float` | — |
| `mean_value_16` | `(@types.Image16)` | `Float` | — |
| `mean_value_f` | `(@types.ImageF)` | `Float` | — |
| `measure_area` | `(@types.Image, pixel_area? : Double)` | `Double` | 测量 |
| `median_value` | `(@types.Image)` | `Int` | — |
| `variance_value` | `(@types.Image)` | `Float` | — |

### 绘制（16 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `draw_circle` | `(@types.Image, Int, Int, Int, Array[Byte], thickness? : Int, fill? : Bool)` | `@types.Image` | 绘制 |
| `draw_circle_16` | `(@types.Image16, Int, Int, Int, Array[Int], thickness? : Int, fill? : Bool)` | `@types.Image16` | 绘制 |
| `draw_circle_f` | `(@types.ImageF, Int, Int, Int, Array[Float], thickness? : Int, fill? : Bool)` | `@types.ImageF` | 绘制 |
| `draw_copy` | `(@types.Image, @types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | 绘制 |
| `draw_corners` | `(@types.Image, Array[@feature.CornerPoint], color? : Array[Byte], radius? : Int)` | `@types.Image raise @types.LoadError` | 绘制 |
| `draw_detections` | `(@types.Image, Array[@detection.BoundingBox])` | `@types.Image raise @types.LoadError` | 绘制 |
| `draw_line` | `(@types.Image, Int, Int, Int, Int, Array[Byte], thickness? : Int)` | `@types.Image` | 绘制 |
| `draw_line_16` | `(@types.Image16, Int, Int, Int, Int, Array[Int], thickness? : Int)` | `@types.Image16` | 绘制 |
| `draw_line_f` | `(@types.ImageF, Int, Int, Int, Int, Array[Float], thickness? : Int)` | `@types.ImageF` | 绘制 |
| `draw_over` | `(@types.Image, @types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | 绘制 |
| `draw_polygon` | `(@types.Image, Array[(Int, Int)], Array[Byte], thickness? : Int, fill? : Bool)` | `@types.Image` | 绘制 |
| `draw_polygon_16` | `(@types.Image16, Array[(Int, Int)], Array[Int], thickness? : Int)` | `@types.Image16` | 绘制 |
| `draw_polygon_f` | `(@types.ImageF, Array[(Int, Int)], Array[Float], thickness? : Int)` | `@types.ImageF` | 绘制 |
| `draw_rectangle` | `(@types.Image, Int, Int, Int, Int, Array[Byte], thickness? : Int, fill? : Bool)` | `@types.Image` | 绘制 |
| `draw_rectangle_16` | `(@types.Image16, Int, Int, Int, Int, Array[Int], thickness? : Int, fill? : Bool)` | `@types.Image16` | 绘制 |
| `draw_rectangle_f` | `(@types.ImageF, Int, Int, Int, Int, Array[Float], thickness? : Int, fill? : Bool)` | `@types.ImageF` | 绘制 |

### 质量评估（17 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `calculate_psnr_sr_api` | `(@types.Image, @types.Image)` | `Double` | 计算 |
| `calculate_ssim_sr_api` | `(@types.Image, @types.Image)` | `Double` | 计算 |
| `check_accuracy_threshold` | `(@ocr.AccuracyStats, min_char_accuracy? : Double, min_word_accuracy? : Double, min_f1_score? : Double)` | `(Bool, Array[String]) raise @types.LoadError` | — |
| `compute_mse` | `(@types.Image, @types.Image)` | `Double` | 计算 |
| `compute_psnr` | `(@types.Image, @types.Image)` | `Double` | 计算 |
| `compute_ssim` | `(@types.Image, @types.Image)` | `Double` | 计算 |
| `evaluate_scan_quality` | `(@types.Image)` | `@ocr.ScanQuality raise @types.LoadError` | 评估 |
| `images_equal` | `(@types.Image, @types.Image)` | `Bool` | — |
| `mse` | `(@types.Image, @types.Image)` | `Double raise @types.LoadError` | — |
| `mse_16` | `(@types.Image16, @types.Image16)` | `Double raise @types.LoadError` | — |
| `mse_f` | `(@types.ImageF, @types.ImageF)` | `Double raise @types.LoadError` | — |
| `psnr` | `(@types.Image, @types.Image)` | `Double raise @types.LoadError` | — |
| `psnr_16` | `(@types.Image16, @types.Image16)` | `Double raise @types.LoadError` | — |
| `psnr_f` | `(@types.ImageF, @types.ImageF)` | `Double raise @types.LoadError` | — |
| `ssim` | `(@types.Image, @types.Image)` | `Double raise @types.LoadError` | — |
| `ssim_16` | `(@types.Image16, @types.Image16)` | `Double raise @types.LoadError` | — |
| `ssim_f` | `(@types.ImageF, @types.ImageF)` | `Double raise @types.LoadError` | — |

### OCR（133 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `adaptive_threshold_ocr` | `(@types.Image, block_size? : Int, c? : Int)` | `@types.Image raise @types.LoadError` | — |
| `advanced_chinese_ocr_default_config` | `()` | `@ocr.AdvancedChineseOcrConfig` | — |
| `analyze_complex_layout` | `(Array[@ocr.TextBlock], Int, Int)` | `@ocr.ComplexLayoutAnalysis` | 分析 |
| `analyze_document_layout` | `(@types.Image)` | `@ocr.DocumentStructure raise @types.LoadError` | 分析 |
| `analyze_layout_enhanced` | `(@types.Image, config? : @ocr.DocumentUnderstandingEnhancedConfig)` | `Array[@ocr.DocumentBlock] raise @types.LoadError` | 分析 |
| `analyze_layout_scan` | `(@types.Image)` | `Array[@ocr.TextBlock] raise @types.LoadError` | 分析 |
| `analyze_markdown_element_distribution` | `(@ocr.MarkdownDocument)` | `Array[(String, Int)]` | 分析 |
| `analyze_table_results` | `(Array[@ocr.EnhancedTableResult])` | `Array[(String, Int)]` | 分析 |
| `analyze_table_structure` | `(Array[@ocr.TableLine], Array[@ocr.TableLine])` | `@ocr.TableStructure raise @types.LoadError` | 分析 |
| `batch_scan_ocr` | `(Array[@types.Image], @ocr.ScanOCRConfig)` | `Array[@ocr.OCRPageResult] raise @types.LoadError` | — |
| `build_document_structure_tree` | `(Array[@ocr.DocumentBlock])` | `Array[@ocr.DocumentTreeNode]` | 构建 |
| `build_markdown_document` | `(@ocr.OCRPageResult, title? : String)` | `@ocr.MarkdownDocument raise @types.LoadError` | 构建 |
| `calculate_edit_distance` | `(String, String)` | `Int` | 计算 |
| `calibrate_confidence` | `(@ocr.OcrResult, factor? : Double)` | `@ocr.OcrResult raise @types.LoadError` | — |
| `calibrate_confidence_enhanced` | `(Double, Array[Double])` | `Double` | — |
| `chinese_ocr_default_config` | `()` | `@ocr.ChineseOcrConfig` | — |
| `classify_markdown_element` | `(@ocr.TextBlock, avg_font_size? : Double)` | `@ocr.MarkdownElementType` | 分类 |
| `cnn_confusion_matrix` | `(Array[@ocr.DLTrainingSample], @ocr.DLCnnModelConfig, Array[String])` | `Array[Array[Int]] raise @types.LoadError` | — |
| `cnn_infer` | `(Array[Double], @ocr.DLCnnModelConfig, Array[String])` | `@ocr.DLInferenceResult` | — |
| `cnn_recognize_char` | `(@types.Image, @ocr.DLCnnModelConfig, Array[String])` | `@ocr.DLInferenceResult raise @types.LoadError` | — |
| `cnn_recognize_digits` | `(@types.Image, @ocr.DLCnnModelConfig)` | `@ocr.DLInferenceResult raise @types.LoadError` | — |
| `cnn_recognize_letters` | `(@types.Image, @ocr.DLCnnModelConfig)` | `@ocr.DLInferenceResult raise @types.LoadError` | — |
| `cnn_train` | `(Array[@ocr.DLTrainingSample], Array[Double], Array[Double], Array[Double], Array[Double], Int, Int, Int, Int, Int, Int, Double, Int)` | `(Array[Double], Array[Double], Array[Double], Array[Double], Array[@ocr.DLTrainingHistory]) raise @types.LoadError` | — |
| `cnn_train_step` | `(Array[Double], Int, Array[Double], Array[Double], Array[Double], Array[Double], Int, Int, Int, Int, Int, Int, Double)` | `(Array[Double], Array[Double], Array[Double], Array[Double], Double) raise @types.LoadError` | — |
| `complete_char_segmentation` | `(@types.Image, min_char_width? : Int, max_char_width? : Int)` | `Array[(Int, Int, Int, Int)] raise @types.LoadError` | — |
| `compute_reading_order` | `(Array[@ocr.DocumentElement])` | `Array[Int] raise @types.LoadError` | 计算 |
| `correct_common_patterns` | `(String)` | `@ocr.CorrectionResult` | — |
| `correct_similar_chars` | `(String, String)` | `@ocr.CorrectionResult raise @types.LoadError` | — |
| `correct_slant` | `(@types.Image, max_slant? : Double)` | `@types.Image raise @types.LoadError` | — |
| `create_default_char_cnn_config` | `(Int)` | `@ocr.DLCnnModelConfig` | 创建 |
| `create_default_chinese_dictionary` | `()` | `@ocr.DictChineseDict` | 创建 |
| `create_default_handwriting_config` | `()` | `@ocr.HandwritingRecognitionConfig` | 创建 |
| `create_default_language_model` | `()` | `@ocr.LanguageModelState` | 创建 |
| `create_handwriting_template` | `(String, @ocr.HandwritingStyle, Array[@types.Image])` | `@ocr.HandwritingTemplate raise @types.LoadError` | 创建 |
| `decompose_chinese_char` | `(String)` | `@ocr.ChineseCharStructure raise @types.LoadError` | — |
| `deskew` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `detect_document_columns` | `(@types.Image)` | `Int raise @types.LoadError` | 检测 |
| `detect_document_language` | `(@types.Image)` | `@ocr.LanguageType raise @types.LoadError` | 检测 |
| `detect_handwriting_slant` | `(@types.Image)` | `Double raise @types.LoadError` | 检测 |
| `detect_image_regions_markdown` | `(@types.Image, min_area? : Int)` | `Array[@ocr.MarkdownImage] raise @types.LoadError` | 检测 |
| `determine_reading_order_markdown` | `(Array[@ocr.MarkdownElement])` | `Array[Int]` | — |
| `dictionary_create` | `(Array[String])` | `@ocr.Dictionary raise @types.LoadError` | — |
| `dictionary_create_common_english` | `()` | `@ocr.Dictionary` | — |
| `dictionary_match` | `(String, @ocr.Dictionary, max_distance? : Int)` | `Array[(String, Int)] raise @types.LoadError` | — |
| `digit_ocr_default_config` | `()` | `@ocr.DigitOcrConfig` | — |
| `document_enhance` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `document_statistics_enhanced` | `(Array[@ocr.DocumentBlock])` | `(Int, Int, Int, Int, Int, Int, Int)` | — |
| `document_structure_stats` | `(@ocr.DocumentStructure)` | `(Int, Int, Int, Int, Int)` | — |
| `document_understanding_enhanced_default_config` | `()` | `@ocr.DocumentUnderstandingEnhancedConfig` | — |
| `drop_fall_segmentation` | `(@types.Image, start_x? : Int)` | `@ocr.DropFallResult raise @types.LoadError` | — |
| `edit_distance` | `(String, String)` | `Int raise @types.LoadError` | — |
| `elastic_match` | `(Array[Double], Array[Double], elasticity? : Double, grid_size? : Int)` | `Double` | — |
| `english_ocr_default_config` | `()` | `@ocr.EnglishOcrConfig` | — |
| `enhanced_chinese_ocr_default_config` | `()` | `@ocr.EnhancedChineseOcrConfig` | — |
| `enhanced_document_to_markdown` | `(@ocr.EnhancedDocument, include_header_footer? : Bool)` | `String` | — |
| `enhanced_element_distribution` | `(@ocr.EnhancedDocument)` | `Array[(String, Int)]` | — |
| `enhanced_table_to_markdown` | `(@ocr.EnhancedTableResult)` | `String` | — |
| `ensemble_default_config` | `()` | `@ocr.EnsembleConfig` | — |
| `ensemble_predict` | `(Array[Double], @ocr.KnnClassifier, Array[(String, Array[Double])], config? : @ocr.EnsembleConfig)` | `@ocr.ClassificationResult raise @types.LoadError` | — |
| `evaluate_cnn_model` | `(Array[@ocr.DLTrainingSample], @ocr.DLCnnModelConfig, Array[String])` | `(Double, Double) raise @types.LoadError` | 评估 |
| `extract_combined_ocr_features` | `(@types.Image)` | `Array[Double] raise @types.LoadError` | 提取 |
| `extract_document_text` | `(Array[@ocr.DocumentBlock], include_headers? : Bool, include_footers? : Bool)` | `String` | 提取 |
| `extract_gabor_ocr_features` | `(@types.Image, num_orientations? : Int, num_frequencies? : Int)` | `Array[Double]` | 提取 |
| `extract_handwriting_features` | `(@types.Image, String)` | `@ocr.HandwritingCharFeature raise @types.LoadError` | 提取 |
| `extract_handwriting_stroke_features` | `(@types.Image)` | `@ocr.HandwritingStrokeFeatures raise @types.LoadError` | 提取 |
| `find_similar_chinese_chars` | `(@ocr.DictChineseDict, String, top_n? : Int)` | `Array[@ocr.DictCharMatch] raise @types.LoadError` | — |
| `full_postprocess_correction` | `(String, context_type? : String)` | `@ocr.CorrectionResult raise @types.LoadError` | — |
| `generate_chinese_dictionary_report` | `(@ocr.DictChineseDict)` | `String` | 生成 |
| `generate_enhanced_handwriting_templates` | `(char_set? : String, num_variants? : Int)` | `Array[(String, Array[Double])]` | 生成 |
| `generate_handwriting_templates` | `(char_set? : String)` | `Array[(String, Array[Double])]` | 生成 |
| `generate_markdown_image_placeholder` | `(@ocr.MarkdownImage, Int)` | `String` | 生成 |
| `get_elements_in_reading_order` | `(@ocr.DocumentStructure)` | `Array[@ocr.DocumentElement]` | — |
| `handwriting_feature_similarity` | `(@ocr.HandwritingCharFeature, @ocr.HandwritingCharFeature)` | `Double` | — |
| `handwriting_ocr_default_config` | `()` | `@ocr.HandwritingOcrConfig` | — |
| `handwriting_ocr_enhanced_default_config` | `()` | `@ocr.HandwritingOcrEnhancedConfig` | — |
| `handwriting_postprocess` | `(String, Double)` | `(String, Double)` | — |
| `handwriting_report_to_string` | `(@ocr.HandwritingRecognitionResult)` | `String` | — |
| `horizontal_projection` | `(@types.Image)` | `@ocr.ProjectionResult raise @types.LoadError` | — |
| `is_code_block_line` | `(@ocr.TextLineAttributes, Int)` | `Bool` | — |
| `is_heading_line` | `(@ocr.TextLineAttributes, Double)` | `(Bool, Int)` | — |
| `is_quote_line` | `(@ocr.TextLineAttributes, Int)` | `Bool` | — |
| `language_model_postprocess` | `(String, Array[String], Array[Double])` | `(String, Array[Double])` | — |
| `lookup_by_pinyin` | `(@ocr.DictChineseDict, String)` | `Array[@ocr.DictCharEntry] raise @types.LoadError` | — |
| `lookup_by_radical` | `(@ocr.DictChineseDict, String)` | `Array[@ocr.DictCharEntry] raise @types.LoadError` | — |
| `lookup_by_structure` | `(@ocr.DictChineseDict, @ocr.DictCharStructure)` | `Array[@ocr.DictCharEntry]` | — |
| `lookup_char` | `(@ocr.DictChineseDict, String)` | `@ocr.DictCharEntry? raise @types.LoadError` | — |
| `markdown_document_to_string` | `(@ocr.MarkdownDocument)` | `String` | — |
| `markdown_table_to_string` | `(@ocr.MarkdownTable)` | `String` | — |
| `multi_scale_recognize` | `(@types.Image, Array[(String, Array[Double])], Array[Int], distance_metric? : String)` | `(String, Double)` | — |
| `multilingual_ocr_default_config` | `()` | `@ocr.MultilingualOcrConfig` | — |
| `multilingual_ocr_enhanced_default_config` | `()` | `@ocr.MultilingualOcrEnhancedConfig` | — |
| `ngram_create` | `(Array[String], n? : Int)` | `@ocr.NgramModel raise @types.LoadError` | — |
| `ngram_score` | `(String, @ocr.NgramModel)` | `Double raise @types.LoadError` | — |
| `normalize_handwriting_size` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | — |
| `normalize_punctuation` | `(String, Array[String])` | `String` | — |
| `ocr_accuracy_enhanced_default_config` | `()` | `@ocr.OcrAccuracyEnhancedConfig` | — |
| `ocr_pipeline_stats` | `(@types.Image)` | `(Int, Int, Double) raise @types.LoadError` | — |
| `ocr_postprocess` | `(@ocr.OcrResult, config? : @ocr.PostProcessConfig, dictionary? : @ocr.Dictionary, ngram_model? : @ocr.NgramModel)` | `@ocr.OcrResult raise @types.LoadError` | — |
| `ocr_preprocess` | `(@types.Image, binarization_method? : String)` | `@types.Image raise @types.LoadError` | — |
| `ocr_result_to_hocr` | `(@ocr.OCRPageResult)` | `String` | — |
| `ocr_result_to_json` | `(@ocr.OCRPageResult)` | `String` | — |
| `ocr_result_to_text` | `(@ocr.OCRPageResult)` | `String` | — |
| `optimize_reading_order` | `(Array[@ocr.DocumentBlock], Int)` | `Array[Int]` | — |
| `postprocess_default_config` | `()` | `@ocr.PostProcessConfig` | — |
| `recognize_action` | `(Array[@types.Image], Int, Int)` | `@video.ActionRecognitionResult` | 识别 |
| `recognize_by_components` | `(@ocr.DictChineseDict, @ocr.DictCharStructure, Array[String], stroke_count_hint? : Int)` | `Array[(String, Double)]` | 识别 |
| `recognize_chinese` | `(@types.Image, config? : @ocr.ChineseOcrConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_chinese_advanced` | `(@types.Image, config? : @ocr.AdvancedChineseOcrConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_digits` | `(@types.Image, config? : @ocr.DigitOcrConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_english` | `(@types.Image, config? : @ocr.EnglishOcrConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_enhanced_chinese` | `(@types.Image, config? : @ocr.EnhancedChineseOcrConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_handwriting` | `(@types.Image, config? : @ocr.HandwritingOcrConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_handwriting_char` | `(@types.Image, Array[@ocr.HandwritingTemplate], @ocr.HandwritingRecognitionConfig)` | `@ocr.HandwritingRecognitionResult raise @types.LoadError` | 识别 |
| `recognize_handwriting_enhanced` | `(@types.Image, config? : @ocr.HandwritingOcrEnhancedConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_multilingual` | `(@types.Image, config? : @ocr.MultilingualOcrConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_multilingual_enhanced` | `(@types.Image, config? : @ocr.MultilingualOcrEnhancedConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_ocr_enhanced` | `(@types.Image, Array[(String, Array[Double])], config? : @ocr.OcrAccuracyEnhancedConfig)` | `@ocr.OcrResult raise @types.LoadError` | 识别 |
| `recognize_symbols_markdown` | `(String)` | `Array[@ocr.MarkdownSymbol]` | 识别 |
| `recognize_table` | `(@types.Image, min_line_length? : Int)` | `@ocr.TableStructure raise @types.LoadError` | 识别 |
| `reed_solomon_decode` | `(Array[Int], Int)` | `(Array[Int], Int)` | — |
| `resize_image_for_cnn` | `(@types.Image, Int, Int)` | `Array[Double] raise @types.LoadError` | 缩放 |
| `rotate_document` | `(@types.Image, Double)` | `@types.Image raise @types.LoadError` | 旋转 |
| `scan_document_preprocess` | `(@types.Image, @ocr.ScanOCRConfig)` | `@types.Image raise @types.LoadError` | — |
| `scan_ocr_default_config` | `()` | `@ocr.ScanOCRConfig` | — |
| `scan_ocr_recognize` | `(@types.Image, @ocr.ScanOCRConfig)` | `@ocr.OCRPageResult raise @types.LoadError` | — |
| `segment_chars_projection` | `(@types.Image, @ocr.TextLineInfo, min_width? : Int, max_gap? : Int)` | `Array[@ocr.CharSegment] raise @types.LoadError` | 分割 |
| `select_adaptive_config` | `(@ocr.ScanQuality)` | `@ocr.AdaptivePreprocessConfig raise @types.LoadError` | — |
| `smart_reading_order` | `(Array[@ocr.EnhancedDocumentElement], @ocr.LayoutType, Array[Int])` | `Array[Int] raise @types.LoadError` | — |
| `smart_segment_chars` | `(@types.Image, @ocr.MultilingualOcrEnhancedConfig)` | `Array[(Int, Int, Int, Int, String)] raise @types.LoadError` | — |
| `smart_spacing_process` | `(String, Array[String])` | `String` | — |
| `understand_document` | `(@types.Image)` | `@ocr.DocumentStructure raise @types.LoadError` | — |
| `understand_document_enhanced` | `(@types.Image, config? : @ocr.DocumentUnderstandingEnhancedConfig)` | `(Array[@ocr.DocumentBlock], Array[@ocr.DocumentTreeNode], String) raise @types.LoadError` | — |
| `vertical_projection` | `(@types.Image)` | `@ocr.ProjectionResult raise @types.LoadError` | — |

### 医学图像（11 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `detect_lesions_simple_medical` | `(@medical.MedicalImage, Double, Double)` | `Array[@medical.Lesion]` | 检测 |
| `medical_colormap` | `(@types.Image, colormap? : String)` | `@types.Image` | — |
| `medical_contrast_enhance` | `(@types.Image, clip_limit? : Double, tile_size? : Int)` | `@types.Image` | — |
| `medical_denoise` | `(@types.Image, iterations? : Int, kappa? : Double)` | `@types.Image` | 去噪 |
| `medical_image_registration_medical` | `(@medical.MedicalImage, @medical.MedicalImage, Int)` | `@medical.MedicalRegistrationResult` | — |
| `medical_image_report_to_string_medical` | `(@medical.MedicalImage, Array[@medical.Lesion], @medical.MedicalImageQuality)` | `String` | — |
| `medical_threshold_segmentation_medical` | `(@medical.MedicalImage, Double, Double)` | `Array[Bool]` | — |
| `window_level_bone` | `()` | `@medical.WindowLevel` | — |
| `window_level_brain` | `()` | `@medical.WindowLevel` | — |
| `window_level_lung` | `()` | `@medical.WindowLevel` | — |
| `window_level_mediastinum` | `()` | `@medical.WindowLevel` | — |

### 加密/解密（23 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `arnold_scramble_enc` | `(@types.Image, @encryption.ArnoldParams)` | `@encryption.EncryptionResult raise @types.LoadError` | — |
| `calculate_correlation_enc` | `(@types.Image, @types.Image)` | `Double raise @types.LoadError` | 计算 |
| `calculate_image_entropy_enc` | `(@types.Image)` | `Double raise @types.LoadError` | 计算 |
| `calculate_psnr_enc` | `(@types.Image, @types.Image)` | `Double raise @types.LoadError` | 计算 |
| `chaotic_encrypt_enc` | `(@types.Image, @encryption.ChaoticParams)` | `@encryption.EncryptionResult raise @types.LoadError` | — |
| `create_default_arnold_params_enc` | `()` | `@encryption.ArnoldParams` | 创建 |
| `create_default_chaotic_params_enc` | `()` | `@encryption.ChaoticParams` | 创建 |
| `decrypt_image_logistic` | `(@types.Image, key? : Double, mu? : Double)` | `@types.Image raise @types.LoadError` | 解密 |
| `decrypt_image_xor` | `(@types.Image, String)` | `@types.Image raise @types.LoadError` | 解密 |
| `embed_text_watermark` | `(@types.Image, String, key? : Int)` | `@types.Image` | 水印 |
| `embed_visible_watermark_enc` | `(@types.Image, String, Int, Int, Double)` | `@types.Image raise @types.LoadError` | 水印 |
| `embed_watermark_lsb` | `(@types.Image, @types.Image, key? : Int)` | `@types.Image` | 水印 |
| `embed_watermark_lsb_enc` | `(@types.Image, Array[Byte], Int)` | `(@types.Image, @encryption.WatermarkInfo) raise @types.LoadError` | 水印 |
| `encrypt_image_logistic` | `(@types.Image, key? : Double, mu? : Double)` | `@types.Image raise @types.LoadError` | 加密 |
| `encrypt_image_xor` | `(@types.Image, String)` | `@types.Image raise @types.LoadError` | 加密 |
| `encryption_default_config` | `()` | `@encryption.EncryptionConfig` | 加密 |
| `encryption_report_to_string_enc` | `(@encryption.EncryptionResult, @encryption.WatermarkInfo, @encryption.ImageEncryptionQuality)` | `String` | 加密 |
| `evaluate_encryption_quality` | `(@types.Image, @types.Image)` | `@encryption.EncryptionQuality raise @types.LoadError` | 评估 |
| `evaluate_image_encryption_quality_enc` | `(@types.Image, @types.Image)` | `@encryption.ImageEncryptionQuality raise @types.LoadError` | 评估 |
| `extract_watermark_lsb_enc` | `(@types.Image, Int, Int)` | `@encryption.WatermarkExtractionResult raise @types.LoadError` | 提取 |
| `key_sensitivity_test` | `(@types.Image, Double, delta? : Double)` | `Double raise @types.LoadError` | — |
| `xor_decrypt_enc` | `(@encryption.EncryptionResult, Array[Byte])` | `@types.Image` | — |
| `xor_encrypt_enc` | `(@types.Image, Array[Byte])` | `@encryption.EncryptionResult raise @types.LoadError` | — |

### 水印（7 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `batch_embed_watermark` | `(Array[@types.Image], @types.Image, key? : Int)` | `Array[@types.Image]` | 水印 |
| `extract_text_watermark` | `(@types.Image, Int, key? : Int)` | `String` | 提取 |
| `extract_watermark_lsb` | `(@types.Image)` | `@types.Image` | 提取 |
| `remove_watermark` | `(@types.Image, Int, Int, Int, Int)` | `@types.Image raise @types.LoadError` | 水印 |
| `watermark_default_config` | `()` | `@watermark.WatermarkConfig` | 水印 |
| `watermark_psnr` | `(@types.Image, @types.Image)` | `Double` | 水印 |
| `watermark_robustness_test` | `(@types.Image, @types.Image, noise_level? : Double)` | `Double` | 水印 |

### 目标检测 (YOLO)（8 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `bbox_iou` | `(@detection.BoundingBox, @detection.BoundingBox)` | `Double raise @types.LoadError` | — |
| `bbox_new` | `(Int, Int, Int, Int, score? : Double, class_id? : Int)` | `@detection.BoundingBox raise @types.LoadError` | — |
| `initialize_object_tracking` | `(@detection.YoloDetectionResult)` | `Array[@detection.YoloTrackedObject] raise @types.LoadError` | — |
| `initialize_tracking` | `(@types.Image, Int, Int, Int, Int, String)` | `@video.TrackedObject` | — |
| `nms` | `(Array[@detection.BoundingBox], iou_threshold? : Double)` | `Array[@detection.BoundingBox] raise @types.LoadError` | — |
| `non_max_suppression` | `(Array[@detection.YoloBoundingBox], Double, Int)` | `Array[@detection.YoloBoundingBox] raise @types.LoadError` | — |
| `update_object_tracking` | `(Array[@detection.YoloTrackedObject], @detection.YoloDetectionResult, Int)` | `Array[@detection.YoloTrackedObject] raise @types.LoadError` | — |
| `update_tracking` | `(@video.TrackedObject, @types.Image)` | `@video.TrackedObject` | — |

### 智能视觉（9 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `create_default_intelligent_vision_config_iv` | `()` | `@intelligent_vision.IntelligentVisionConfig` | 创建 |
| `detect_crops_iv` | `(@types.Image, @intelligent_vision.IntelligentVisionConfig)` | `Array[@intelligent_vision.CropDetectionResult]` | 检测 |
| `detect_defects_iv` | `(@types.Image, @intelligent_vision.IntelligentVisionConfig)` | `Array[@intelligent_vision.DefectDetectionResult]` | 检测 |
| `detect_intrusion_iv` | `(@types.Image, Array[Double], @intelligent_vision.IntelligentVisionConfig)` | `@intelligent_vision.IntrusionDetectionResult` | 检测 |
| `detect_lanes_iv` | `(@types.Image, @intelligent_vision.IntelligentVisionConfig)` | `@intelligent_vision.LaneDetectionResult` | 检测 |
| `detect_objects_iv` | `(@types.Image, @intelligent_vision.IntelligentVisionConfig)` | `Array[@intelligent_vision.DetectionResultIV]` | 检测 |
| `detect_stars_iv` | `(@types.Image, @intelligent_vision.IntelligentVisionConfig)` | `@intelligent_vision.StarDetectionResult` | 检测 |
| `intelligent_vision_report_to_string_iv` | `(String, Int, Double, @intelligent_vision.IntelligentVisionConfig)` | `String` | — |
| `recognize_traffic_signs_iv` | `(@types.Image, @intelligent_vision.IntelligentVisionConfig)` | `Array[@intelligent_vision.TrafficSignResult]` | 识别 |

### 人脸识别（12 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `add_face_to_database_fr` | `(@face_recognition.FaceDatabase, @face_recognition.FaceFeature, String)` | `@face_recognition.FaceDatabase` | — |
| `analyze_face_attributes_fr` | `(@types.Image, @face_recognition.FaceDetectionResult, @face_recognition.FaceDatabase, @face_recognition.FaceRecognitionConfig)` | `@face_recognition.FaceAttributeAnalysis raise @types.LoadError` | 分析 |
| `calculate_cosine_similarity_fr` | `(@face_recognition.FaceFeature, @face_recognition.FaceFeature)` | `Double` | 计算 |
| `create_default_face_config_fr` | `()` | `@face_recognition.FaceRecognitionConfig` | 创建 |
| `create_face_database_fr` | `(@face_recognition.FaceRecognitionAlgorithm, Double)` | `@face_recognition.FaceDatabase` | 创建 |
| `detect_faces_fr` | `(@types.Image, @face_recognition.FaceRecognitionConfig)` | `Array[@face_recognition.FaceDetectionResult] raise @types.LoadError` | 检测 |
| `estimate_age_gender_fr` | `(@types.Image, @face_recognition.FaceDetectionResult)` | `@face_recognition.AgeGenderEstimationResult raise @types.LoadError` | 估计 |
| `evaluate_face_quality_fr` | `(@types.Image, @face_recognition.FaceDetectionResult)` | `Double raise @types.LoadError` | 评估 |
| `extract_face_feature_fr` | `(@types.Image, @face_recognition.FaceDetectionResult, @face_recognition.FaceRecognitionConfig)` | `@face_recognition.FaceFeature raise @types.LoadError` | 提取 |
| `face_recognition_report_to_string_fr` | `(@face_recognition.FaceAttributeAnalysis)` | `String` | — |
| `recognize_expression_fr` | `(@types.Image, @face_recognition.FaceDetectionResult)` | `@face_recognition.ExpressionRecognitionResult raise @types.LoadError` | 识别 |
| `recognize_face_in_database_fr` | `(@face_recognition.FaceDatabase, @face_recognition.FaceFeature, Array[Double])` | `@face_recognition.FaceRecognitionResult` | 识别 |

### 条码（1 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `barcode_default_config` | `()` | `@barcode.BarcodeConfig` | — |

### 图像取证（39 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `analyze_cfa_pattern_fe` | `(@types.Image)` | `@forensics_enhanced.CfaAnalysisResult` | 分析 |
| `analyze_color_distribution_fs` | `(@types.Image)` | `@forensics.ColorAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_color_quantization_fs` | `(@types.Image)` | `@forensics.ColorQuantizationResult raise @types.LoadError` | 分析 |
| `analyze_compression_artifacts_fs` | `(@types.Image)` | `@forensics.CompressionAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_dct_coefficients_fe` | `(@types.Image)` | `@forensics_enhanced.DctCoefficientResult` | 分析 |
| `analyze_details_fs` | `(@types.Image)` | `@forensics.DetailAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_edges_fs` | `(@types.Image)` | `@forensics.EdgeAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_ela_fe` | `(@types.Image, Int)` | `@forensics_enhanced.ElaAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_frequency_domain_fs` | `(@types.Image)` | `@forensics.FrequencyAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_geometry_fs` | `(@types.Image)` | `@forensics.GeometryAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_illumination_consistency_fe` | `(@types.Image)` | `@forensics_enhanced.IlluminationConsistencyResult` | 分析 |
| `analyze_jpeg_ghost_fe` | `(@types.Image)` | `@forensics_enhanced.JpegGhostResult` | 分析 |
| `analyze_metadata_forensics_fe` | `(@types.Image)` | `@forensics_enhanced.MetadataForensicsResult` | 分析 |
| `analyze_noise_pattern_fs` | `(@types.Image)` | `@forensics.NoiseAnalysisResult raise @types.LoadError` | 分析 |
| `analyze_noise_residual_fe` | `(@types.Image)` | `@forensics_enhanced.NoiseResidualResult` | 分析 |
| `analyze_texture_fs` | `(@types.Image)` | `@forensics.TextureAnalysisResult raise @types.LoadError` | 分析 |
| `apply_translation_fe` | `(@types.Image, Int, Int)` | `@types.Image` | 应用 |
| `calculate_fusion_quality_fe` | `(@types.Image)` | `Double` | 计算 |
| `create_default_enhanced_verification_config_fs` | `()` | `@forensics.EnhancedVerificationConfig` | 创建 |
| `create_default_fusion_config_fe` | `()` | `@fusion_enhanced.FusionConfig` | 创建 |
| `create_default_registration_config_fe` | `()` | `@fusion_enhanced.RegistrationConfig` | 创建 |
| `create_default_source_verification_config_fs` | `()` | `@forensics.SourceVerificationConfig` | 创建 |
| `detect_clone_regions_fe` | `(@types.Image, Int, Double)` | `@forensics_enhanced.CloneDetectionResult raise @types.LoadError` | 检测 |
| `detect_tamper_comprehensive_fe` | `(@types.Image, Int)` | `@forensics_enhanced.TamperDetectionResult raise @types.LoadError` | 检测 |
| `detect_text_regions_fs` | `(@types.Image)` | `@forensics.TextDetectionResult raise @types.LoadError` | 检测 |
| `detect_ui_elements_fs` | `(@types.Image)` | `@forensics.UIDetectionResult raise @types.LoadError` | 检测 |
| `enhanced_verification_report_to_string_fs` | `(@forensics.EnhancedVerificationResult)` | `String` | — |
| `fuse_images_fe` | `(Array[@types.Image], @fusion_enhanced.FusionConfig)` | `@fusion_enhanced.FusionResult` | — |
| `fuse_laplacian_pyramid_fe` | `(Array[@types.Image], Int)` | `@types.Image` | — |
| `fuse_maximum_fe` | `(Array[@types.Image])` | `@types.Image` | — |
| `fuse_minimum_fe` | `(Array[@types.Image])` | `@types.Image` | — |
| `fuse_simple_mean_fe` | `(Array[@types.Image])` | `@types.Image` | — |
| `fuse_weighted_average_fe` | `(Array[@types.Image], Array[Double])` | `@types.Image` | — |
| `fusion_report_to_string_fe` | `(@fusion_enhanced.FusionResult, Double)` | `String` | — |
| `register_images_fe` | `(@types.Image, @types.Image, @fusion_enhanced.RegistrationConfig)` | `@fusion_enhanced.RegistrationResult` | — |
| `register_phase_correlation_fe` | `(@types.Image, @types.Image)` | `@fusion_enhanced.RegistrationResult` | — |
| `source_verification_report_to_string_fs` | `(@forensics.SourceVerificationResult)` | `String` | — |
| `verify_image_source_enhanced_fs` | `(@types.Image, @forensics.EnhancedVerificationConfig)` | `@forensics.EnhancedVerificationResult raise @types.LoadError` | — |
| `verify_image_source_fs` | `(@types.Image, @forensics.SourceVerificationConfig)` | `@forensics.SourceVerificationResult raise @types.LoadError` | — |

### 遥感图像（6 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `calculate_spectral_signature_rs` | `(@remote_sensing.RemoteSensingImage, Int, Int)` | `@remote_sensing.SpectralSignature` | 计算 |
| `classify_land_cover_simple_rs` | `(@remote_sensing.RemoteSensingImage)` | `@remote_sensing.ClassificationResult` | 分类 |
| `land_cover_classification` | `(@types.Image, @types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | — |
| `multispectral_new` | `(Int, Int, Array[@types.Image], band_names? : Array[String])` | `@remote_sensing.MultispectralImage` | — |
| `remote_sensing_report_to_string_rs` | `(@remote_sensing.RemoteSensingImage, @remote_sensing.ClassificationResult, @remote_sensing.ChangeDetectionResult, @remote_sensing.RemoteSensingQuality)` | `String` | — |
| `vegetation_coverage` | `(@types.Image, ndvi_soil? : Double, ndvi_veg? : Double)` | `@types.Image raise @types.LoadError` | — |

### 图像检索（36 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `add_to_index_cbir` | `(@retrieval.CBIRImageIndex, @retrieval.CBIRImageFeature)` | `@retrieval.CBIRImageIndex` | — |
| `calculate_similarity_cbir` | `(Array[Double], Array[Double], @retrieval.SimilarityMetric)` | `Double` | 计算 |
| `chebyshev_distance` | `(Array[Double], Array[Double])` | `Double raise @types.LoadError` | — |
| `compute_distance` | `(Array[Double], Array[Double], @ocr.DistanceMetric)` | `Double raise @types.LoadError` | 计算 |
| `cosine_distance` | `(Array[Double], Array[Double])` | `Double raise @types.LoadError` | — |
| `cosine_similarity` | `(Array[Double], Array[Double])` | `Double` | — |
| `cosine_similarity_cbir_api` | `(Array[Double], Array[Double])` | `Double` | — |
| `create_default_color_histogram_config_cbir` | `()` | `@retrieval.ColorHistogramConfig` | 创建 |
| `create_default_hog_config_cbir` | `()` | `@retrieval.HOGConfig` | 创建 |
| `create_default_lbp_config_cbir` | `()` | `@retrieval.LBPConfig` | 创建 |
| `create_default_retrieval_config` | `()` | `@image_retrieval_advanced.ImageRetrievalConfig` | 创建 |
| `create_image_index_cbir` | `()` | `@retrieval.CBIRImageIndex` | 创建 |
| `database_add_image` | `(@retrieval.ImageDatabase, @retrieval.ImageFeature)` | `@retrieval.ImageDatabase` | — |
| `database_remove_image` | `(@retrieval.ImageDatabase, String)` | `@retrieval.ImageDatabase` | — |
| `database_size` | `(@retrieval.ImageDatabase)` | `Int` | — |
| `euclidean_distance` | `(Array[Double], Array[Double])` | `Double raise @types.LoadError` | — |
| `euclidean_distance_cbir_api` | `(Array[Double], Array[Double])` | `Double` | — |
| `expand_query_advanced` | `(Array[Double], Array[Array[Double]], @image_retrieval_advanced.ImageRetrievalConfig)` | `@image_retrieval_advanced.QueryExpansionResult` | — |
| `extract_color_histogram_cbir` | `(@types.Image, @retrieval.ColorHistogramConfig)` | `@retrieval.CBIRImageFeature` | 提取 |
| `extract_combined_features_cbir` | `(@types.Image)` | `@retrieval.CBIRImageFeature` | 提取 |
| `extract_hog_feature_cbir` | `(@types.Image, @retrieval.HOGConfig)` | `@retrieval.CBIRImageFeature` | 提取 |
| `extract_lbp_feature_cbir` | `(@types.Image, @retrieval.LBPConfig)` | `@retrieval.CBIRImageFeature` | 提取 |
| `hamming_distance` | `(Array[Int], Array[Int])` | `Int raise @types.LoadError` | — |
| `histogram_intersection_cbir_api` | `(Array[Double], Array[Double])` | `Double` | 直方图 |
| `image_database_new` | `()` | `@retrieval.ImageDatabase` | — |
| `image_retrieval_report_to_string_advanced` | `(@image_retrieval_advanced.ImageRetrievalTaskType, @image_retrieval_advanced.ImageRetrievalConfig, String)` | `String` | — |
| `image_similarity` | `(@types.Image, @types.Image, method_type? : String)` | `Double` | — |
| `manhattan_distance` | `(Array[Double], Array[Double])` | `Double raise @types.LoadError` | — |
| `manhattan_distance_cbir_api` | `(Array[Double], Array[Double])` | `Double` | — |
| `measure_distance` | `(Int, Int, Int, Int, pixel_spacing? : Double)` | `Double` | 测量 |
| `relevance_feedback_advanced` | `(Array[Double], Array[Int], Array[Int], Array[Array[Double]], @image_retrieval_advanced.ImageRetrievalConfig)` | `@image_retrieval_advanced.RelevanceFeedbackResult` | — |
| `retrieval_report_to_string_cbir` | `(@retrieval.CBIRRetrievalResultList, @retrieval.CBIRImageFeature)` | `String` | — |
| `retrieve_images_advanced` | `(Array[Double], Int, Int, Array[Array[Double]], @image_retrieval_advanced.ImageRetrievalConfig)` | `@image_retrieval_advanced.RetrievalResult` | — |
| `retrieve_images_cbir` | `(@retrieval.CBIRImageFeature, @retrieval.CBIRImageIndex, Int, @retrieval.SimilarityMetric)` | `@retrieval.CBIRRetrievalResultList` | — |
| `search_similar_images` | `(@retrieval.ImageDatabase, @retrieval.ImageFeature, top_k? : Int, method_type? : String)` | `Array[@retrieval.SearchResult]` | — |
| `visualize_distance_transform` | `(Array[Float], Int, Int)` | `@types.Image` | 可视化 |

### 场景理解/VLM（19 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `answer_visual_question_su` | `(@types.Image, String, @scene_understanding.SceneUnderstandingConfig)` | `@scene_understanding.VisualQuestionAnsweringResult` | — |
| `classify_scene_su` | `(@types.Image, @scene_understanding.SceneUnderstandingConfig)` | `@scene_understanding.SceneClassificationResult` | 分类 |
| `compute_image_text_similarity_vlm` | `(@types.Image, String, @vlm_multimodal.VLMConfig)` | `@vlm_multimodal.VisionTextEmbedding` | 计算 |
| `create_default_diffusion_config_vlm` | `()` | `@vlm_multimodal.DiffusionConfig` | 创建 |
| `create_default_fusion_config_vlm` | `()` | `@vlm_multimodal.FusionConfig` | 创建 |
| `create_default_genai_config_vlm` | `()` | `@vlm_multimodal.GenerativeAIConfig` | 创建 |
| `create_default_scene_config_su` | `()` | `@scene_understanding.SceneUnderstandingConfig` | 创建 |
| `create_default_vlm_config_vlm` | `()` | `@vlm_multimodal.VLMConfig` | 创建 |
| `diffusion_generate_vlm` | `(String, String, @vlm_multimodal.DiffusionConfig, Int)` | `@vlm_multimodal.DiffusionResult` | — |
| `fuse_modalities_vlm` | `(Array[Double], Array[Double], @vlm_multimodal.FusionConfig)` | `@vlm_multimodal.FusionResult` | — |
| `fusion_report_to_string_vlm` | `(@vlm_multimodal.FusionResult)` | `String` | — |
| `generate_caption_su` | `(@types.Image, @scene_understanding.SceneUnderstandingConfig)` | `@scene_understanding.ImageCaptioningResult` | 生成 |
| `generate_scene_graph_su` | `(@types.Image, @scene_understanding.SceneUnderstandingConfig)` | `@scene_understanding.SceneGraph` | 生成 |
| `get_common_scene_types_su` | `()` | `Array[String]` | — |
| `image_to_text_vlm` | `(@types.Image, @vlm_multimodal.GenerativeAIConfig)` | `@vlm_multimodal.GenerativeAIResult` | — |
| `scene_understanding_report_to_string_su` | `(@scene_understanding.SceneClassificationResult, @scene_understanding.ImageCaptioningResult, @scene_understanding.VisualQuestionAnsweringResult, @scene_understanding.SceneGraph)` | `String` | — |
| `text_to_image_vlm` | `(String, @vlm_multimodal.GenerativeAIConfig, Int)` | `@vlm_multimodal.GenerativeAIResult` | — |
| `understand_scene_su` | `(@types.Image, @scene_understanding.SceneUnderstandingConfig)` | `(@scene_understanding.SceneClassificationResult, @scene_understanding.ImageCaptioningResult, @scene_understanding.SceneGraph)` | — |
| `vlm_report_to_string_vlm` | `(@vlm_multimodal.VisionTextEmbedding, @vlm_multimodal.VisionLanguageModelType)` | `String` | — |

### 姿态估计（12 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `calculate_joint_angle_pe` | `(@pose_estimation.HumanPose, Int, Int, Int)` | `Double` | 计算 |
| `create_default_action_config_pe` | `()` | `@pose_estimation.ActionRecognitionConfig` | 创建 |
| `create_default_pose_config_pe` | `()` | `@pose_estimation.PoseEstimationConfig` | 创建 |
| `detect_keypoints_pe` | `(@types.Image, @pose_estimation.PoseEstimationConfig)` | `Array[@pose_estimation.HumanPose] raise @types.LoadError` | 检测 |
| `extract_skeleton_pe` | `(@pose_estimation.HumanPose)` | `Array[@pose_estimation.SkeletonConnection]` | 提取 |
| `get_coco_keypoint_names_pe` | `()` | `Array[String]` | — |
| `get_coco_skeleton_connections_pe` | `()` | `Array[Array[Int]]` | — |
| `pose_estimation_report_to_string_pe` | `(Array[@pose_estimation.HumanPose], @pose_estimation.ActionRecognitionResult)` | `String` | — |
| `recognize_action_pe` | `(Array[@pose_estimation.HumanPose], @pose_estimation.ActionRecognitionConfig)` | `@pose_estimation.ActionRecognitionResult` | 识别 |
| `recognize_gesture_pe` | `(@pose_estimation.HumanPose)` | `@pose_estimation.GestureRecognitionResult` | 识别 |
| `skeletonize` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `visualize_pose_pe` | `(@types.Image, @pose_estimation.HumanPose)` | `@types.Image raise @types.LoadError` | 可视化 |

### 图像配准（12 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `apply_affine_transform_ra` | `(@types.Image, @registration_advanced.TransformMatrix)` | `@types.Image` | 应用 |
| `apply_translation_ra` | `(@types.Image, Int, Int)` | `@types.Image` | 应用 |
| `calculate_mutual_information_ra` | `(@types.Image, @types.Image)` | `Double` | 计算 |
| `create_default_registration_config_advanced_ra` | `()` | `@registration_advanced.RegistrationConfigAdvanced` | 创建 |
| `detect_harris_corners_ra` | `(@types.Image, Double)` | `Array[@registration_advanced.FeaturePoint]` | 检测 |
| `estimate_affine_transform_ra` | `(Array[@registration_advanced.FeatureMatch])` | `@registration_advanced.TransformMatrix` | 估计 |
| `feature_based_registration_ra` | `(@types.Image, @types.Image, @registration_advanced.RegistrationConfigAdvanced)` | `@registration_advanced.RegistrationResultAdvanced` | — |
| `match_feature_points_ra` | `(Array[@registration_advanced.FeaturePoint], Array[@registration_advanced.FeaturePoint], Double)` | `Array[@registration_advanced.FeatureMatch]` | 匹配 |
| `normalized_cross_correlation_ra` | `(@types.Image, @types.Image)` | `Double` | — |
| `phase_correlation_registration_ra` | `(@types.Image, @types.Image)` | `@registration_advanced.RegistrationResultAdvanced` | — |
| `register_images_advanced_ra` | `(@types.Image, @types.Image, @registration_advanced.RegistrationConfigAdvanced)` | `@registration_advanced.RegistrationResultAdvanced` | — |
| `registration_report_to_string_advanced_ra` | `(@registration_advanced.RegistrationResultAdvanced)` | `String` | — |

### SLAM（9 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `create_default_slam_config_sl` | `()` | `@slam.SLAMConfig` | 创建 |
| `detect_features_slam_sl` | `(@types.Image, Int, Double)` | `Array[Array[Double]]` | 检测 |
| `detect_loop_closure_sl` | `(Array[Array[Double]], Array[@slam.KeyFrame], Double)` | `@slam.LoopClosureResult` | 检测 |
| `estimate_camera_pose_sl` | `(@slam.FeatureTrackingResult, @slam.SLAMConfig, @slam.CameraPose)` | `@slam.CameraPose` | 估计 |
| `initialize_slam_sl` | `(@slam.SLAMConfig)` | `@slam.SLAMState` | — |
| `process_frame_slam_sl` | `(@slam.SLAMState, @types.Image, @slam.SLAMConfig)` | `@slam.SLAMState` | — |
| `slam_report_to_string_sl` | `(@slam.SLAMState)` | `String` | — |
| `track_features_slam_sl` | `(@types.Image, @types.Image, Array[Array[Double]], Int)` | `@slam.FeatureTrackingResult` | — |
| `triangulate_points_sl` | `(Array[Array[Double]], @slam.CameraPose, @slam.CameraPose, @slam.SLAMConfig)` | `Array[@slam.MapPoint]` | — |

### 立体/3D（13 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `depth_map_to_image_3d` | `(@stereo3d.DepthMap3d)` | `@types.Image` | — |
| `depth_to_colormap` | `(@types.Image, colormap? : String)` | `@types.Image` | — |
| `depth_to_point_cloud_3d` | `(@stereo3d.DepthMap3d, @stereo3d.CameraIntrinsics3d)` | `@stereo3d.PointCloud3D` | — |
| `depth_to_pointcloud` | `(@types.Image, fx? : Double, fy? : Double, cx? : Double, cy? : Double, scale? : Double)` | `@stereo3d.PointCloud` | — |
| `disparity_to_depth` | `(@types.Image, baseline? : Double, focal_length? : Double)` | `@types.Image` | — |
| `estimate_normals_3d` | `(@stereo3d.PointCloud3D, Double)` | `Array[(Double, Double, Double)]` | 估计 |
| `icp_registration_3d` | `(@stereo3d.PointCloud3D, @stereo3d.PointCloud3D, Int, Double)` | `@stereo3d.RegistrationResult3d` | — |
| `point_cloud_new` | `()` | `@stereo3d.PointCloud` | — |
| `pointcloud_voxel_downsample` | `(@stereo3d.PointCloud, voxel_size? : Double)` | `@stereo3d.PointCloud` | — |
| `statistical_outlier_removal_3d` | `(@stereo3d.PointCloud3D, Int, Double)` | `@stereo3d.PointCloud3D` | — |
| `stereo_match_3d` | `(@types.Image, @types.Image, @stereo3d.StereoConfig3d)` | `@stereo3d.DepthMap3d` | — |
| `vision_3d_report_to_string` | `(@stereo3d.PointCloud3D, @stereo3d.DepthMap3d, @stereo3d.RegistrationResult3d)` | `String` | — |
| `voxel_downsample_3d` | `(@stereo3d.PointCloud3D, Double)` | `@stereo3d.PointCloud3D` | — |

### 图像拼接（3 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `stitch_default_config` | `()` | `@stitch.StitchConfig` | — |
| `stitch_images` | `(@types.Image, @types.Image, config? : @stitch.StitchConfig)` | `@types.Image?` | — |
| `stitch_panorama` | `(Array[@types.Image], @photo_enhance.PanoramaConfig)` | `@photo_enhance.PanoramaResult` | — |

### 风格迁移/艺术（15 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `calculate_color_statistics_st` | `(@types.Image)` | `@style_transfer.ColorStatistics raise @types.LoadError` | 计算 |
| `calculate_texture_features_st` | `(@types.Image)` | `@style_transfer.StyleTransferTextureFeatures raise @types.LoadError` | 计算 |
| `cartoon` | `(@types.Image, levels? : Int, edge_threshold? : Double)` | `@types.Image` | — |
| `cartoonize_st` | `(@types.Image, Double)` | `@types.Image raise @types.LoadError` | — |
| `color_transfer_st` | `(@types.Image, @types.Image, Double)` | `@types.Image raise @types.LoadError` | — |
| `create_default_style_transfer_config_st` | `()` | `@style_transfer.StyleTransferConfig` | 创建 |
| `oil_paint` | `(@types.Image, radius? : Int, intensity? : Int)` | `@types.Image` | — |
| `oil_painting_st` | `(@types.Image, Int, Int)` | `@types.Image raise @types.LoadError` | — |
| `sketch` | `(@types.Image, blend? : Double)` | `@types.Image` | — |
| `sketch_effect_st` | `(@types.Image, Double)` | `@types.Image raise @types.LoadError` | — |
| `style_transfer_report_to_string_st` | `(@style_transfer.StyleTransferResult, @style_transfer.ColorStatistics, @style_transfer.ColorStatistics, @style_transfer.StyleTransferTextureFeatures)` | `String` | — |
| `style_transfer_st` | `(@types.Image, @types.Image, @style_transfer.StyleTransferConfig)` | `@style_transfer.StyleTransferResult raise @types.LoadError` | — |
| `stylize` | `(@types.Image, String, config? : @stylize.StylizeConfig)` | `@types.Image` | — |
| `stylize_default_config` | `()` | `@stylize.StylizeConfig` | — |
| `watercolor` | `(@types.Image, blur_radius? : Int)` | `@types.Image` | — |

### 神经渲染（11 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `create_default_camera_nr` | `()` | `@neural_rendering.CameraParams` | 创建 |
| `create_default_gaussian_config_nr` | `()` | `@neural_rendering.GaussianSplattingConfig` | 创建 |
| `create_default_nerf_config_nr` | `()` | `@neural_rendering.NeRFConfig` | 创建 |
| `generate_rays_nr` | `(@neural_rendering.CameraParams)` | `Array[@neural_rendering.Ray]` | 生成 |
| `generate_sample_gaussians_nr` | `(Int)` | `Array[@neural_rendering.Gaussian3D]` | 生成 |
| `multiview_stereo_reconstruction_nr` | `(Array[@types.Image], Array[@neural_rendering.CameraParams])` | `@neural_rendering.ReconstructionResult` | — |
| `neural_rendering_report_to_string_nr` | `(@neural_rendering.RenderingResult, @neural_rendering.NeuralRenderingAlgorithm)` | `String` | — |
| `reconstruction_report_to_string_nr` | `(@neural_rendering.ReconstructionResult, @neural_rendering.ReconstructionAlgorithm)` | `String` | — |
| `render_gaussian_splatting_nr` | `(@neural_rendering.CameraParams, Array[@neural_rendering.Gaussian3D], @neural_rendering.GaussianSplattingConfig)` | `@neural_rendering.RenderingResult` | — |
| `render_nerf_nr` | `(@neural_rendering.CameraParams, @neural_rendering.NeRFConfig)` | `@neural_rendering.RenderingResult` | — |
| `visualize_point_cloud_nr` | `(Array[@neural_rendering.Point3D], Int, Int)` | `@types.Image` | 可视化 |

### 图像生成/扩散（37 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `colorize_image_ig` | `(@types.Image, @image_generation.EditingConfig)` | `@image_generation.EditingResult` | — |
| `compose_images_ig` | `(@types.Image, @types.Image, @types.Image, @image_generation.CompositionConfig)` | `@types.Image` | — |
| `create_default_editing_config_ig` | `()` | `@image_generation.EditingConfig` | 创建 |
| `create_default_generation_config_ig` | `()` | `@image_generation.GenerationConfig` | 创建 |
| `edit_image_ig` | `(@types.Image, @types.Image, @image_generation.EditingConfig)` | `@image_generation.EditingResult` | — |
| `editing_report_to_string_ig` | `(@image_generation.EditingResult)` | `String` | — |
| `generate_3500_chinese_templates` | `(char_set? : String)` | `Array[(String, Array[Double])]` | 生成 |
| `generate_accuracy_report` | `(@ocr.AccuracyStats, String)` | `String` | 生成 |
| `generate_api_config_json` | `(@ocr.ApiServerConfig)` | `String` | 生成 |
| `generate_batch_summary` | `(Array[@ocr.BatchTask], Double)` | `@ocr.BatchResultSummary raise @types.LoadError` | 生成 |
| `generate_chinese_char_info_db` | `()` | `Array[@ocr.ChineseCharInfo]` | 生成 |
| `generate_chinese_templates` | `(char_set? : String)` | `Array[(String, Array[Double])]` | 生成 |
| `generate_cli_help` | `()` | `String` | 生成 |
| `generate_correction_report` | `(Array[@ocr.CorrectionResult])` | `String` | 生成 |
| `generate_deployment_package` | `(@ocr.DockerConfig, @ocr.ApiServerConfig, @ocr.ModelPackageConfig)` | `String` | 生成 |
| `generate_digit_templates` | `()` | `Array[(String, Array[Double])]` | 生成 |
| `generate_docker_compose` | `(@ocr.DockerConfig)` | `String` | 生成 |
| `generate_dockerfile` | `(@ocr.DockerConfig)` | `String` | 生成 |
| `generate_english_templates` | `(case_sensitive? : Bool)` | `Array[(String, Array[Double])]` | 生成 |
| `generate_enhanced_chinese_templates` | `(char_set_size? : Int)` | `Array[(String, Array[Double])]` | 生成 |
| `generate_env_config` | `(@ocr.DeploymentEnvironment)` | `String` | 生成 |
| `generate_from_latent_ig` | `(@image_generation.LatentVector, @image_generation.GenerationConfig)` | `@image_generation.GenerationResult` | 生成 |
| `generate_health_check_config` | `(@ocr.ApiServerConfig)` | `String` | 生成 |
| `generate_image_extraction_report` | `(Array[@ocr.ExtractedImage])` | `String` | 生成 |
| `generate_model_manifest` | `(@ocr.ModelPackageConfig)` | `String` | 生成 |
| `generate_performance_report` | `(@ocr.PerformanceBenchmark, String)` | `String` | 生成 |
| `generate_punctuation_templates` | `()` | `Array[@ocr.PunctuationTemplate]` | 生成 |
| `generate_random_image_ig` | `(@image_generation.GenerationConfig)` | `@image_generation.GenerationResult` | 生成 |
| `generate_random_latent_ig` | `(Int, Int)` | `@image_generation.LatentVector` | 生成 |
| `generate_robustness_report` | `(@ocr.ScanQuality, Array[@ocr.DistortionDetectionResult], @ocr.ComplexLayoutAnalysis)` | `@ocr.RobustnessReport` | 生成 |
| `generate_training_progress_report` | `(@ocr.TrainingState, @ocr.TrainingConfig)` | `String` | 生成 |
| `generate_training_report` | `(Array[@ocr.DLTrainingHistory], @ocr.DLCnnModelConfig)` | `String` | 生成 |
| `generate_video_summary` | `(Array[@types.Image], Double)` | `@video.VideoSummary` | 生成 |
| `generation_report_to_string_ig` | `(@image_generation.GenerationResult)` | `String` | — |
| `inpaint_image_ig` | `(@types.Image, @types.Image, @image_generation.EditingConfig)` | `@image_generation.EditingResult` | — |
| `outpaint_image_ig` | `(@types.Image, Int, Int, @image_generation.EditingConfig)` | `@image_generation.EditingResult` | — |
| `remove_background_ig` | `(@types.Image, @image_generation.EditingConfig)` | `@image_generation.EditingResult` | — |

### 超分辨率（18 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `bicubic_interpolate_sr` | `(@types.Image, Double)` | `@types.Image` | — |
| `bilinear_interpolate_sr` | `(@types.Image, Double)` | `@types.Image` | — |
| `calculate_image_quality_metrics_sr` | `(@types.Image, @types.Image)` | `@superres.ImageQualityMetrics` | 计算 |
| `create_default_enhancement_config_sr` | `()` | `@superres.EnhancementConfig` | 创建 |
| `create_default_interpolation_config_sr` | `()` | `@superres.InterpolationConfig` | 创建 |
| `denoise_image_sr` | `(@types.Image, Double)` | `@types.Image` | 去噪 |
| `enhance_image_sr` | `(@types.Image, @superres.EnhancementConfig)` | `@types.Image` | — |
| `nearest_neighbor_interpolate_sr` | `(@types.Image, Double)` | `@types.Image` | — |
| `sharpen_image_sr` | `(@types.Image, Double)` | `@types.Image` | — |
| `sr_default_config` | `()` | `@superres.SuperResolutionConfig` | — |
| `super_resolution` | `(@types.Image, config? : @superres.SuperResolutionConfig)` | `@types.Image` | — |
| `super_resolution_bicubic` | `(@types.Image, Double)` | `@types.Image` | — |
| `super_resolution_edge_preserving` | `(@types.Image, Double, edge_threshold? : Double, sharpen_amount? : Double)` | `@types.Image` | — |
| `super_resolution_lanczos` | `(@types.Image, Double, a? : Int)` | `@types.Image` | — |
| `super_resolution_report_to_string_sr` | `(@superres.SuperResolutionResult, @superres.ImageQualityMetrics)` | `String` | — |
| `super_resolve_sr` | `(@types.Image, @superres.InterpolationConfig)` | `@superres.SuperResolutionResult` | — |
| `upscale_2x` | `(@types.Image)` | `@types.Image` | — |
| `upscale_4x` | `(@types.Image)` | `@types.Image` | — |

### 视频处理（11 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `interpolate_frames` | `(@types.Image, @types.Image, num_frames? : Int)` | `Array[@types.Image]` | — |
| `stabilize_video` | `(Array[@types.Image], @video.VideoStabilizationConfig)` | `Array[@types.Image]` | — |
| `video_concat` | `(@video.VideoFrames, @video.VideoFrames)` | `@video.VideoFrames` | — |
| `video_fade_in` | `(@video.VideoFrames, duration_frames? : Int)` | `@video.VideoFrames` | — |
| `video_fade_out` | `(@video.VideoFrames, duration_frames? : Int)` | `@video.VideoFrames` | — |
| `video_frame_average` | `(@video.VideoFrames)` | `@types.Image` | — |
| `video_frame_count` | `(@video.VideoFrames)` | `Int` | — |
| `video_frames_new` | `(Array[@types.Image], fps? : Double)` | `@video.VideoFrames` | — |
| `video_get_frame` | `(@video.VideoFrames, Int)` | `@types.Image?` | — |
| `video_reverse` | `(@video.VideoFrames)` | `@video.VideoFrames` | — |
| `video_sample` | `(@video.VideoFrames, interval? : Int)` | `@video.VideoFrames` | — |

### 图像融合（13 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `fuse_alpha` | `(@types.Image, @types.Image, alpha? : Double)` | `@types.Image` | — |
| `fuse_exposure` | `(Array[@types.Image])` | `@types.Image` | — |
| `fuse_images` | `(@types.Image, @types.Image, config? : @fusion.FusionConfig)` | `@types.Image` | — |
| `fuse_multifocus` | `(@types.Image, @types.Image)` | `@types.Image` | — |
| `fusion_default_config` | `()` | `@fusion.FusionConfig` | — |
| `hdr_fusion_average` | `(Array[@types.Image])` | `@types.Image raise @types.LoadError` | — |
| `hdr_fusion_weighted` | `(Array[@types.Image])` | `@types.Image raise @types.LoadError` | — |
| `hdr_merge` | `(Array[@types.Image], Array[Double])` | `@photo_enhance.HdrImage` | — |
| `hdr_process` | `(Array[@types.Image], config? : @enhance.HdrConfig)` | `@types.Image raise @types.LoadError` | — |
| `mask_blend` | `(@types.Image, @types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | — |
| `multi_band_blend` | `(@types.Image, @types.Image, @types.Image, num_bands? : Int)` | `@types.Image raise @types.LoadError` | — |
| `multi_band_blend_16` | `(@types.Image16, @types.Image16, @types.Image16, num_bands? : Int)` | `@types.Image16 raise @types.LoadError` | — |
| `multi_band_blend_f` | `(@types.ImageF, @types.ImageF, @types.ImageF, num_bands? : Int)` | `@types.ImageF raise @types.LoadError` | — |

### 计算成像（13 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `coded_aperture_reconstruct_ci` | `(@types.Image, @computational_imaging.CodedAperturePattern)` | `@computational_imaging.ImagingReconstructionResult` | — |
| `computational_imaging_report_to_string_ci` | `(@computational_imaging.ImagingReconstructionResult, String)` | `String` | — |
| `computational_photography_report` | `(@photo_enhance.HdrImage, @photo_enhance.PanoramaResult)` | `String` | — |
| `create_default_coded_aperture_ci` | `(Int)` | `@computational_imaging.CodedAperturePattern` | 创建 |
| `create_default_lightfield_camera_ci` | `()` | `@computational_imaging.LightFieldCameraParams` | 创建 |
| `create_default_phase_config_ci` | `()` | `@computational_imaging.PhaseRetrievalConfig` | 创建 |
| `ct_reconstruct_fbp_ci` | `(@computational_imaging.CTProjectionData, Int)` | `@computational_imaging.ImagingReconstructionResult` | — |
| `generate_hologram_ci` | `(@types.Image, Double, Double, Double)` | `@computational_imaging.Hologram` | 生成 |
| `generate_sample_lightfield_ci` | `(@types.Image, @computational_imaging.LightFieldCameraParams)` | `@computational_imaging.LightFieldData` | 生成 |
| `lightfield_refocus_ci` | `(@computational_imaging.LightFieldData, Double, Double)` | `@computational_imaging.RefocusResult` | — |
| `phase_retrieval_ci` | `(@types.Image, @computational_imaging.PhaseRetrievalConfig)` | `@computational_imaging.ImagingReconstructionResult` | — |
| `reconstruct_hologram_ci` | `(@computational_imaging.Hologram)` | `@computational_imaging.ImagingReconstructionResult` | — |
| `synthesize_view_ci` | `(@computational_imaging.LightFieldData, Double, Double)` | `@computational_imaging.ViewSynthesisResult` | — |

### 高级成像（11 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `advanced_imaging_report_to_string_ai` | `(@advanced_imaging.ImagingModality, @types.Image, @advanced_imaging.AdvancedImagingConfig)` | `String` | — |
| `analyze_polarization_ai` | `(@types.Image, @types.Image, @types.Image, @types.Image)` | `@advanced_imaging.PolarizationData` | 分析 |
| `create_default_advanced_imaging_config_ai` | `(@advanced_imaging.ImagingModality)` | `@advanced_imaging.AdvancedImagingConfig` | 创建 |
| `generate_hyperspectral_cube_ai` | `(@types.Image, Int, Double, Double)` | `@advanced_imaging.HyperspectralData` | 生成 |
| `infrared_pseudocolor_ai` | `(@types.Image, @advanced_imaging.InfraredImagingType)` | `@types.Image` | — |
| `mri_synthesize_ai` | `(Int, Int, Double)` | `@advanced_imaging.MRIData` | — |
| `pet_synthesize_ai` | `(Int, Int, String)` | `@advanced_imaging.PETData` | — |
| `quantum_ghost_imaging_ai` | `(Int, Int, Int, @advanced_imaging.QuantumImagingAlgorithm)` | `@types.Image` | — |
| `thermal_to_temperature_ai` | `(@types.Image, Double, Double, Double)` | `@advanced_imaging.ThermalData` | — |
| `ultrasound_synthesize_ai` | `(Int, Int, Double, Double)` | `@advanced_imaging.UltrasoundData` | — |
| `xray_enhance_ai` | `(@types.Image, Double)` | `@advanced_imaging.XRayData` | — |

### 压缩（13 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `calculate_bits_per_pixel_cp` | `(Int, Int, Int)` | `Double` | 计算 |
| `calculate_compression_quality_cp` | `(@types.Image, @types.Image, Int, Int)` | `@compression.CompressionQualityMetrics raise @types.LoadError` | 计算 |
| `calculate_compression_ratio_cp` | `(Int, Int)` | `Double` | 计算 |
| `calculate_image_entropy_cp` | `(@types.Image)` | `Double raise @types.LoadError` | 计算 |
| `compress_image_cp` | `(@types.Image, @compression.CompressionConfig)` | `@compression.CompressionResult raise @types.LoadError` | — |
| `compress_jpeg_simple_cp` | `(@types.Image, Double)` | `@compression.CompressionResult raise @types.LoadError` | — |
| `compress_png_simple_cp` | `(@types.Image)` | `@compression.CompressionResult raise @types.LoadError` | — |
| `compression_report_to_string_cp` | `(@compression.CompressionResult, @compression.CompressionQualityMetrics)` | `String` | — |
| `create_default_compression_config_cp` | `()` | `@compression.CompressionConfig` | 创建 |
| `predictive_encode_cp` | `(@types.Image)` | `Bytes raise @types.LoadError` | — |
| `quantize_image_cp` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | — |
| `run_length_decode_cp` | `(Bytes)` | `Bytes` | — |
| `run_length_encode_cp` | `(Bytes)` | `Bytes` | — |

### 批处理（17 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `batch_correct_texts` | `(Array[String], context_type? : String)` | `Array[@ocr.CorrectionResult] raise @types.LoadError` | — |
| `batch_encrypt` | `(Array[@types.Image], Double)` | `Array[@types.Image] raise @types.LoadError` | — |
| `batch_execute` | `(Array[@pipeline.BatchTask])` | `@pipeline.BatchResult` | — |
| `batch_extract_features` | `(Array[(@types.Image, String)])` | `Array[@retrieval.ImageFeature]` | — |
| `batch_photo_enhance` | `(Array[@types.Image], String)` | `Array[@types.Image]` | — |
| `batch_recognize_chars` | `(Array[@types.Image], @ocr.DLCnnModelConfig, Array[String])` | `Array[@ocr.DLInferenceResult] raise @types.LoadError` | — |
| `batch_summary` | `(@pipeline.BatchResult)` | `String` | — |
| `batch_summary_to_string` | `(@ocr.BatchResultSummary)` | `String` | — |
| `calculate_batch_progress` | `(Array[@ocr.BatchTask], Double)` | `@ocr.BatchProgress raise @types.LoadError` | 计算 |
| `create_batch_tasks` | `(Array[String], String, String)` | `Array[@ocr.BatchTask] raise @types.LoadError` | 创建 |
| `create_default_batch_config` | `()` | `@ocr.BatchOcrConfig` | 创建 |
| `default_batch_config` | `()` | `@pipeline.BatchConfig` | — |
| `mark_task_completed` | `(@ocr.BatchTask, Int, Double, Double)` | `@ocr.BatchTask` | — |
| `mark_task_failed` | `(@ocr.BatchTask, String, Double)` | `@ocr.BatchTask` | — |
| `next_batch` | `(@ocr.DataLoader)` | `(Array[@ocr.DLTrainingSample], @ocr.DataLoader) raise @types.LoadError` | — |
| `progress_bar_to_string` | `(Double, width? : Int)` | `String` | — |
| `update_task_progress` | `(@ocr.BatchTask, Double, Int, Int)` | `@ocr.BatchTask` | — |

### 管线/CLI（6 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `cli_help` | `()` | `String` | — |
| `cli_parse` | `(Array[String])` | `@pipeline.CliCommand` | — |
| `parse_cli_args` | `(Array[String])` | `@ocr.CliConfig raise @types.LoadError` | — |
| `pipeline_describe` | `(@pipeline.Pipeline)` | `String` | — |
| `pipeline_len` | `(@pipeline.Pipeline)` | `Int` | — |
| `pipeline_new` | `()` | `@pipeline.Pipeline` | — |

### 数据增强（5 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `augment_features` | `(Array[Double], noise_level? : Double)` | `Array[Double]` | — |
| `augment_random_noise` | `(@ocr.DLTrainingSample, Double)` | `@ocr.DLTrainingSample` | — |
| `augment_random_rotation` | `(@ocr.DLTrainingSample, Double)` | `@ocr.DLTrainingSample` | — |
| `augment_random_scale` | `(@ocr.DLTrainingSample, Double)` | `@ocr.DLTrainingSample` | — |
| `augment_random_shift` | `(@ocr.DLTrainingSample, Double)` | `@ocr.DLTrainingSample` | — |

### 训练/分类（28 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `check_early_stopping` | `(@ocr.TrainingState, @ocr.TrainingConfig, Double)` | `(Bool, @ocr.TrainingState)` | — |
| `conv2d` | `(Array[Double], Int, Int, Int, Array[Double], Int, Int, Int, Int)` | `Array[Double] raise @types.LoadError` | — |
| `create_default_training_config` | `()` | `@ocr.TrainingConfig` | 创建 |
| `create_training_history` | `(Int, Double, Double, Double, Double, Double, Double)` | `@ocr.DLTrainingHistory` | 创建 |
| `create_training_sample` | `(@types.Image, Int, String)` | `@ocr.DLTrainingSample raise @types.LoadError` | 创建 |
| `create_training_state` | `()` | `@ocr.TrainingState` | 创建 |
| `cross_entropy_loss` | `(Array[Double], Int)` | `Double` | — |
| `dataset_add_sample` | `(@ocr.TrainingDataset, Array[Double], String)` | `@ocr.TrainingDataset` | — |
| `dataset_create` | `()` | `@ocr.TrainingDataset` | — |
| `dense_backward` | `(Array[Double], Array[Double], Int, Int)` | `(Array[Double], Array[Double], Array[Double])` | — |
| `dense_forward` | `(Array[Double], Array[Double], Array[Double], Int, Int, String)` | `Array[Double]` | — |
| `knn_add_sample` | `(@ocr.KnnClassifier, Array[Double], String)` | `@ocr.KnnClassifier raise @types.LoadError` | — |
| `knn_add_samples` | `(@ocr.KnnClassifier, Array[(Array[Double], String)])` | `@ocr.KnnClassifier raise @types.LoadError` | — |
| `knn_create` | `(k? : Int, distance_metric? : String)` | `@ocr.KnnClassifier raise @types.LoadError` | — |
| `knn_predict` | `(@ocr.KnnClassifier, Array[Double])` | `@ocr.ClassificationResult raise @types.LoadError` | — |
| `max_pool2d` | `(Array[Double], Int, Int, Int, Int)` | `Array[Double] raise @types.LoadError` | — |
| `max_pool2d_backward` | `(Array[Double], Array[Double], Int, Int, Int, Int)` | `Array[Double]` | — |
| `record_training_metrics` | `(@ocr.TrainingState, @ocr.TrainingMetrics)` | `@ocr.TrainingState` | — |
| `relu` | `(Double)` | `Double` | — |
| `relu_backward` | `(Array[Double], Array[Double])` | `Array[Double]` | — |
| `save_model` | `(@ocr.DLCnnModelConfig, Array[Double], String)` | `Bool` | 保存 |
| `sigmoid` | `(Double)` | `Double` | — |
| `sigmoid_backward` | `(Array[Double], Array[Double])` | `Array[Double]` | — |
| `softmax` | `(Array[Double])` | `Array[Double]` | — |
| `softmax_cross_entropy_backward` | `(Array[Double], Int)` | `Array[Double] raise @types.LoadError` | — |
| `split_train_validation` | `(Array[@ocr.DLTrainingSample], Double, Bool)` | `(Array[@ocr.DLTrainingSample], Array[@ocr.DLTrainingSample])` | — |
| `update_weights_sgd` | `(Array[Double], Array[Double], Double)` | `Array[Double] raise @types.LoadError` | — |
| `weighted_knn_classify` | `(Array[Double], Array[(String, Array[Double])], k? : Int, distance_metric? : String)` | `(String, Double, Array[(String, Double)])` | — |

### 创建/构建/配置（33 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `build_enhanced_elements` | `(Array[@ocr.TextLineAttributes], Int, Int)` | `@ocr.EnhancedDocument raise @types.LoadError` | 构建 |
| `build_gaussian_kernel_lut` | `(Double, Int)` | `Array[Double] raise @types.LoadError` | 构建 |
| `build_grayscale_lut` | `()` | `Array[Int]` | 构建 |
| `build_index_advanced` | `(Array[Array[Double]], @image_retrieval_advanced.IndexStructureType)` | `@image_retrieval_advanced.IndexConstructionResult` | 构建 |
| `build_threshold_lut` | `(Int)` | `Array[Int]` | 构建 |
| `create_animation` | `(Array[@types.Image], fps? : Double)` | `@video.VideoFrames` | 创建 |
| `create_data_loader` | `(Array[@ocr.DLTrainingSample], Int, Bool)` | `@ocr.DataLoader raise @types.LoadError` | 创建 |
| `create_default_api_server_config` | `()` | `@ocr.ApiServerConfig` | 创建 |
| `create_default_camera_intrinsics_3d` | `(Int, Int)` | `@stereo3d.CameraIntrinsics3d` | 创建 |
| `create_default_cli_config` | `()` | `@ocr.CliConfig` | 创建 |
| `create_default_docker_config` | `()` | `@ocr.DockerConfig` | 创建 |
| `create_default_dof_config` | `(Int, Int)` | `@photo_enhance.DepthOfFieldConfig` | 创建 |
| `create_default_grabcut_config` | `()` | `@segmentation.GrabCutConfig` | 创建 |
| `create_default_hdr_config` | `()` | `@photo_enhance.ToneMappingConfig` | 创建 |
| `create_default_inpainting_config_ip` | `()` | `@inpainting.InpaintingConfig` | 创建 |
| `create_default_kmeans_config` | `()` | `@segmentation.KMeansConfig` | 创建 |
| `create_default_medical_segmentation_config` | `()` | `@medical.MedicalSegmentationConfig` | 创建 |
| `create_default_model_package_config` | `()` | `@ocr.ModelPackageConfig` | 创建 |
| `create_default_night_config` | `()` | `@photo_enhance.NightEnhanceConfig` | 创建 |
| `create_default_panorama_config` | `()` | `@photo_enhance.PanoramaConfig` | 创建 |
| `create_default_remote_sensing_image` | `(Int, Int, Int)` | `@remote_sensing.RemoteSensingImage` | 创建 |
| `create_default_stabilization_config` | `()` | `@video.VideoStabilizationConfig` | 创建 |
| `create_default_stereo_config_3d` | `()` | `@stereo3d.StereoConfig3d` | 创建 |
| `create_default_watershed_config` | `()` | `@segmentation.WatershedConfig` | 创建 |
| `create_default_window_level_medical` | `(String)` | `@medical.WindowLevelConfig` | 创建 |
| `create_default_yolo_config` | `()` | `@detection.YoloConfig` | 创建 |
| `create_feature_extractor` | `(String, Int)` | `@ocr.DLFeatureExtractor` | 创建 |
| `create_neural_layer` | `(@ocr.DLLayerType, String, Array[Int])` | `@ocr.DLNeuralLayer` | 创建 |
| `create_rect_mask` | `(Int, Int, Int, Int, Int, Int)` | `@types.Image raise @types.LoadError` | 创建 |
| `create_rect_mask_ip` | `(Int, Int, Int, Int, Int, Int)` | `@types.Image` | 创建 |
| `detection_report_to_string` | `(@detection.YoloDetectionResult, @detection.YoloDetectionMetrics)` | `String` | — |
| `hdr_default_config` | `()` | `@enhance.HdrConfig` | — |
| `robustness_report_to_string` | `(@ocr.RobustnessReport)` | `String` | — |

### 提取（20 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `extract_all_cells` | `(@types.Image, @ocr.TableStructure, padding? : Int)` | `Array[@types.Image] raise @types.LoadError` | 提取 |
| `extract_cell_image` | `(@types.Image, @ocr.TableCell, padding? : Int)` | `@types.Image raise @types.LoadError` | 提取 |
| `extract_channel` | `(@types.Image, Int)` | `@types.Image raise @types.LoadError` | 提取 |
| `extract_char_image` | `(@types.Image, @ocr.CharSegment, target_size? : Int, padding? : Int)` | `@types.Image raise @types.LoadError` | 提取 |
| `extract_combined_enhanced_features` | `(@types.Image, @ocr.OcrAccuracyEnhancedConfig)` | `Array[Double] raise @types.LoadError` | 提取 |
| `extract_directional_features` | `(@types.Image)` | `Array[Double]` | 提取 |
| `extract_features` | `(@ocr.DLFeatureExtractor, @types.Image)` | `Array[Double]` | 提取 |
| `extract_features_advanced` | `(Array[Double], Int, Int, @image_retrieval_advanced.ImageRetrievalConfig)` | `@image_retrieval_advanced.FeatureExtractionResult` | 提取 |
| `extract_headings` | `(@ocr.DocumentStructure)` | `Array[@ocr.DocumentElement]` | 提取 |
| `extract_hw_stroke_features` | `(@types.Image)` | `Array[@ocr.StrokeFeature]` | 提取 |
| `extract_image_features` | `(@types.Image, String)` | `@retrieval.ImageFeature` | 提取 |
| `extract_images_enhanced` | `(@types.Image, min_area? : Int)` | `Array[@ocr.ExtractedImage]` | 提取 |
| `extract_keyframes` | `(Array[@types.Image], Double, method_type? : String)` | `Array[@video.Keyframe]` | 提取 |
| `extract_paragraphs` | `(@ocr.DocumentStructure)` | `Array[@ocr.DocumentElement]` | 提取 |
| `extract_stroke_features` | `(@types.Image)` | `Array[Double] raise @types.LoadError` | 提取 |
| `extract_text_line_image` | `(@types.Image, @ocr.TextLineInfo, padding? : Int)` | `@types.Image raise @types.LoadError` | 提取 |
| `extract_text_lines` | `(@types.Image)` | `Array[@types.Image] raise @types.LoadError` | 提取 |
| `extract_tile` | `(@types.Image, Int, Int, Int, Int)` | `@types.Image raise @types.LoadError` | 提取 |
| `extract_title` | `(@ocr.DocumentStructure)` | `String` | 提取 |
| `extract_zernike_moments` | `(@types.Image, max_order? : Int)` | `Array[Double] raise @types.LoadError` | 提取 |

### 检测（26 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `detect_changes_simple_rs` | `(@remote_sensing.RemoteSensingImage, @remote_sensing.RemoteSensingImage, Double)` | `@remote_sensing.ChangeDetectionResult` | 检测 |
| `detect_char_language` | `(@types.Image)` | `@ocr.LanguageType raise @types.LoadError` | 检测 |
| `detect_column_boundaries` | `(Array[@ocr.TextLineAttributes], Int, @ocr.LayoutType)` | `Array[Int]` | 检测 |
| `detect_columns` | `(@types.Image)` | `(Int, Array[(Int, Int)]) raise @types.LoadError` | 检测 |
| `detect_distortions` | `(@types.Image)` | `Array[@ocr.DistortionDetectionResult] raise @types.LoadError` | 检测 |
| `detect_exposure_type` | `(@types.Image)` | `(@photo_enhance.ExposureType, Double)` | 检测 |
| `detect_features_simple` | `(@types.Image, max_features? : Int)` | `Array[@stitch.FeaturePoint]` | 检测 |
| `detect_header_footer` | `(Array[@ocr.TextLineAttributes], Int)` | `(Int, Int) raise @types.LoadError` | 检测 |
| `detect_horizontal_lines` | `(@types.Image, min_length? : Int, max_gap? : Int)` | `Array[@ocr.TableLine] raise @types.LoadError` | 检测 |
| `detect_horizontal_table_lines` | `(@types.Image, min_length? : Int, max_gap? : Int)` | `Array[(Int, Int, Int)] raise @types.LoadError` | 检测 |
| `detect_language_enhanced` | `(@types.Image)` | `@ocr.LanguageDetectionResult raise @types.LoadError` | 检测 |
| `detect_layout_type` | `(Array[@ocr.TextLineAttributes], Int, Int)` | `@ocr.LayoutType raise @types.LoadError` | 检测 |
| `detect_list_item` | `(@ocr.TextLineAttributes)` | `@ocr.ListItemInfo` | 检测 |
| `detect_objects_simple` | `(@types.Image, @detection.YoloConfig)` | `@detection.YoloDetectionResult raise @types.LoadError` | 检测 |
| `detect_paragraphs` | `(Array[@ocr.DocumentBlock], max_line_spacing_ratio? : Double)` | `Array[Array[Int]]` | 检测 |
| `detect_qr_finder_patterns` | `(@types.Image)` | `Array[@barcode.QrFinderPattern] raise @types.LoadError` | 检测 |
| `detect_scene_change` | `(@types.Image, @types.Image, threshold? : Double)` | `(Bool, Double)` | 检测 |
| `detect_skew_angle` | `(@types.Image)` | `Double raise @types.LoadError` | 检测 |
| `detect_skew_angle_robust` | `(@types.Image)` | `Double raise @types.LoadError` | 检测 |
| `detect_table_enhanced` | `(@types.Image, min_table_size? : Int)` | `Array[@ocr.EnhancedTableResult] raise @types.LoadError` | 检测 |
| `detect_text_lines_projection` | `(@types.Image, min_height? : Int, max_gap? : Int)` | `Array[@ocr.TextLineInfo] raise @types.LoadError` | 检测 |
| `detect_text_regions` | `(@types.Image)` | `Array[@ocr.TextRegion] raise @types.LoadError` | 检测 |
| `detect_titles` | `(Array[@ocr.DocumentBlock], title_font_size_threshold? : Int)` | `Array[Int]` | 检测 |
| `detect_touching_chars` | `(@types.Image, min_char_width? : Int, max_char_width? : Int)` | `Array[Int] raise @types.LoadError` | 检测 |
| `detect_vertical_lines` | `(@types.Image, min_length? : Int, max_gap? : Int)` | `Array[@ocr.TableLine] raise @types.LoadError` | 检测 |
| `detect_vertical_table_lines` | `(@types.Image, min_length? : Int, max_gap? : Int)` | `Array[(Int, Int, Int)] raise @types.LoadError` | 检测 |

### 计算（34 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `calculate_accuracy` | `(Array[Int], Array[Int])` | `Double` | 计算 |
| `calculate_accuracy_improvement` | `(Array[@ocr.CorrectionResult], Array[String])` | `(Double, Double, Double)` | 计算 |
| `calculate_all_vegetation_indices_rs` | `(@remote_sensing.RemoteSensingImage)` | `@remote_sensing.VegetationIndices` | 计算 |
| `calculate_char_accuracy` | `(String, String)` | `Double` | 计算 |
| `calculate_chinese_similarity` | `(@ocr.DictCharEntry, @ocr.DictCharEntry)` | `Double` | 计算 |
| `calculate_detection_metrics` | `(Array[@detection.YoloBoundingBox], Array[@detection.YoloBoundingBox], Double)` | `@detection.YoloDetectionMetrics raise @types.LoadError` | 计算 |
| `calculate_iou` | `(@detection.YoloBoundingBox, @detection.YoloBoundingBox)` | `Double raise @types.LoadError` | 计算 |
| `calculate_learning_rate` | `(@ocr.LRSchedulerConfig, Int, Double, Double)` | `Double raise @types.LoadError` | 计算 |
| `calculate_medical_image_quality_medical` | `(@medical.MedicalImage)` | `@medical.MedicalImageQuality` | 计算 |
| `calculate_ndbi_rs` | `(@remote_sensing.RemoteSensingImage, Int, Int)` | `Array[Double]` | 计算 |
| `calculate_ndvi_rs` | `(@remote_sensing.RemoteSensingImage, Int, Int)` | `Array[Double]` | 计算 |
| `calculate_ndwi_rs` | `(@remote_sensing.RemoteSensingImage, Int, Int)` | `Array[Double]` | 计算 |
| `calculate_remote_sensing_quality_rs` | `(@remote_sensing.RemoteSensingImage)` | `@remote_sensing.RemoteSensingQuality` | 计算 |
| `calculate_segmentation_metrics` | `(Array[Int], Array[Int], Int)` | `@segmentation.SegmentationMetrics` | 计算 |
| `calculate_similarity_advanced` | `(Array[Double], Array[Double], @image_retrieval_advanced.SimilarityMetricType)` | `Double` | 计算 |
| `calculate_texture_features_rs` | `(@types.Image, Int, Int, Int)` | `@remote_sensing.TextureFeatures raise @types.LoadError` | 计算 |
| `calculate_word_accuracy` | `(String, String)` | `Double` | 计算 |
| `compute_confusion_matrix` | `(Array[Int], Array[Int], Int)` | `Array[Array[Int]]` | 计算 |
| `compute_diff_image` | `(@types.Image, @types.Image)` | `@types.Image` | 计算 |
| `compute_disparity` | `(@types.Image, @types.Image, max_disparity? : Int, block_size? : Int)` | `@types.Image` | 计算 |
| `compute_energy_16` | `(@types.Image16)` | `Array[Double]` | 计算 |
| `compute_energy_f` | `(@types.ImageF)` | `Array[Double]` | 计算 |
| `compute_evi` | `(@types.Image, @types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 计算 |
| `compute_frame_difference` | `(@types.Image, @types.Image, threshold? : Double)` | `Double` | 计算 |
| `compute_glcm` | `(@types.Image, Int, Int, levels? : Int)` | `Array[Array[Int]] raise @types.LoadError` | 计算 |
| `compute_glcm_16` | `(@types.Image16, Int, Int, levels? : Int)` | `Array[Array[Int]] raise @types.LoadError` | 计算 |
| `compute_glcm_f` | `(@types.ImageF, Int, Int, levels? : Int)` | `Array[Array[Int]] raise @types.LoadError` | 计算 |
| `compute_mae` | `(@types.Image, @types.Image)` | `Double` | 计算 |
| `compute_ndbi` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 计算 |
| `compute_ndvi` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 计算 |
| `compute_ndwi` | `(@types.Image, @types.Image)` | `@types.Image raise @types.LoadError` | 计算 |
| `compute_optical_flow` | `(@types.Image, @types.Image, block_size? : Int, search_range? : Int)` | `@video.OpticalFlowField` | 计算 |
| `compute_per_class_accuracy` | `(Array[Array[Int]])` | `Array[Double]` | 计算 |
| `compute_quality_metrics` | `(@types.Image, @types.Image)` | `@quality.QualityMetrics` | 计算 |

### 应用（5 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `apply_augmentation` | `(@ocr.DLTrainingSample, @ocr.AugmentationConfig)` | `@ocr.DLTrainingSample` | 应用 |
| `apply_depth_of_field` | `(@types.Image, @photo_enhance.DepthOfFieldConfig)` | `@types.Image` | 应用 |
| `apply_lut` | `(@types.Image, Array[Byte])` | `@types.Image raise @types.LoadError` | 应用 |
| `apply_window_level` | `(@types.Image, @medical.WindowLevel)` | `@types.Image` | 应用 |
| `apply_window_level_medical` | `(@medical.MedicalImage, @medical.WindowLevelConfig)` | `@types.Image` | 应用 |

### 性能优化（9 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `bulk_copy_4x` | `(Bytes, Int, Array[Byte], Int, Int)` | `Unit` | — |
| `bulk_fill_4x` | `(Array[Byte], Int, Int, Byte)` | `Unit` | — |
| `cache_friendly_horizontal_projection` | `(@types.Image)` | `Array[Int] raise @types.LoadError` | — |
| `cache_friendly_vertical_projection` | `(@types.Image)` | `Array[Int] raise @types.LoadError` | — |
| `default_tile_config` | `()` | `@performance.TileConfig` | — |
| `estimate_memory_usage` | `(Int, Int, Int, Int)` | `@ocr.MemoryUsageStats` | 估计 |
| `fast_downsample_2x` | `(@types.Image)` | `@types.Image raise @types.LoadError` | — |
| `num_tiles` | `(Int, Int, @performance.TileConfig)` | `(Int, Int)` | — |
| `unrolled_pixel_sum` | `(@types.Image)` | `Int raise @types.LoadError` | — |

### 安全（3 个函数）

| 函数 | 签名 | 返回 | 说明 |
|------|------|------|------|
| `check_dims` | `(Int, Int, Int)` | `Unit raise @types.LoadError` | — |
| `safe_mul` | `(Int, Int)` | `Int?` | — |
| `safe_mul3` | `(Int, Int, Int)` | `Int?` | — |

---

## 常量

| 常量 | 值 | 说明 |
|------|------|------|
| `MAX_IMAGE_DIMENSION` | `Int = 65535` | 图像维度上限，防止 OOM |

---

## 统计

| 指标 | 值 |
|------|------|
| 公开函数 | 1339 |
| 公开常量 | 1 |
| 公开类型 | 382 |
| 函数分类数 | 78 |
| 已列出函数 | 1339 |
| 测试数 | 4291 × 4 目标 |
| 支持格式 | 18 种 |
| 版本 | v189.0.0 |
