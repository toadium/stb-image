# walkzzz/image/src/process

> 高级图像处理算法集合 — 90 个子包，覆盖计算机视觉全领域

## 子包索引

### 基础视觉

| 子包 | 说明 |
|------|------|
| [`color`](color/) | 色彩转换与调整（CLAHE、自适应阈值、Retinex、去雾） |
| [`edge`](edge/) | 边缘检测（Canny、Sobel、Prewitt、Laplacian）、霍夫变换、轮廓 |
| [`feature`](feature/) | 特征检测（Harris、ORB、SIFT、模板匹配、光流、GLCM、LBP） |
| [`filter`](filter/) | 滤波与去噪（高斯、双边、中值、NLM、BM3D） |
| [`frequency`](frequency/) | 频率域处理（FFT、DCT、Haar 小波、频率滤波） |
| [`segment`](segment/) | 图像分割（分水岭、SLIC、grabCut、形态学、连通域） |
| [`transform`](transform/) | 几何变换（仿射、透视、Seam Carving、金字塔、极坐标） |
| [`detection`](detection/) | 目标检测（ Haar 级联、梯度直方图） |
| [`denoise`](denoise/) | 图像去噪算法集合 |
| [`enhance`](enhance/) | 图像增强（直方图均衡、对比度、锐化） |
| [`quality`](quality/) | 图像质量评估（PSNR、SSIM、MSE、LPIPS） |

### 应用领域

| 子包 | 说明 |
|------|------|
| [`ocr`](ocr/) | OCR 全流程（版面、二值化、倾斜、分割、识别、后处理） |
| [`medical`](medical/) | 医学图像处理（DICOM、CT、MRI、超声、病理） |
| [`encryption`](encryption/) | 图像加密与解密（XOR、Arnold、混沌、LSB 水印） |
| [`watermark`](watermark/) | 数字水印（嵌入、提取、鲁棒性） |
| [`barcode`](barcode/) | 条形码与二维码检测识别 |
| [`face_recognition`](face_recognition/) | 人脸识别与属性分析 |
| [`remote_sensing`](remote_sensing/) | 遥感图像处理 |
| [`forensics`](forensics/) | 图像取证与鉴真 |
| [`security_surveillance_advanced`](security_surveillance_advanced/) | 安防监控高级 |

### 重建与生成

| 子包 | 说明 |
|------|------|
| [`superres`](superres/) | 超分辨率重建 |
| [`inpainting`](inpainting/) | 图像修复与补全 |
| [`fusion`](fusion/) | 图像融合（拉普拉斯金字塔、小波、多曝光） |
| [`stitch`](stitch/) | 图像拼接与全景合成 |
| [`style_transfer`](style_transfer/) | 风格迁移（NST、快速风格化） |
| [`image_generation`](image_generation/) | 图像生成 |
| [`photo_enhance`](photo_enhance/) | 摄影增强（HDR、色调映射） |

### 三维与视频

| 子包 | 说明 |
|------|------|
| [`stereo3d`](stereo3d/) | 立体视觉与三维重建 |
| [`pose_estimation`](pose_estimation/) | 姿态估计 |
| [`slam`](slam/) | SLAM 同步定位与建图 |
| [`scene_understanding`](scene_understanding/) | 场景理解与语义分析 |
| [`video`](video/) | 视频处理（帧差、光流、运动检测） |

### 工具与流程

| 子包 | 说明 |
|------|------|
| [`pipeline`](pipeline/) | 图像处理流水线编排 |
| [`performance`](performance/) | 性能优化与加速工具 |
| [`production_utils`](production_utils/) | 生产环境工具函数 |
| [`compression`](compression/) | 图像压缩算法 |
| [`registration`](registration/) | 图像配准 |
| [`retrieval`](retrieval/) | 图像检索 |
| [`stylize`](stylize/) | 图像风格化处理 |

### AI/ML 高级（55 子包）

`advanced_imaging`、`agriculture_vision_advanced`、`astronomy_imaging_advanced`、`audio_processing`、`automl_advanced`、`automl_nas`、`autonomous_driving_advanced`、`computational_imaging`、`computational_photography_advanced`、`continuous_learning`、`cv_advanced`、`dl_advanced`、`explainable_ai`、`feature_learning_advanced`、`federated_learning`、`forensics_enhanced`、`fusion_enhanced`、`generative_ai_advanced`、`graph_neural`、`image_classification_advanced`、`image_clustering_advanced`、`image_colorization_advanced`、`image_compression_advanced`、`image_dimensionality_reduction`、`image_editing_advanced`、`image_encryption_advanced`、`image_generation_advanced`、`image_restoration_advanced`、`image_retrieval_advanced`、`image_translation_advanced`、`image_watermark_advanced`、`industrial_inspection_advanced`、`intelligent_vision`、`knowledge_graph`、`medical_imaging_advanced`、`meta_learning_advanced`、`model_compression`、`model_compression_advanced`、`multimodal_advanced`、`neural_rendering`、`nlp_advanced`、`registration_advanced`、`reinforcement_learning`、`remote_sensing_advanced`、`representation_learning_advanced`、`robot_vision_advanced`、`segmentation`、`transfer_learning_advanced`、`video_processing_advanced`、`vision_3d_advanced`、`vlm_multimodal`

## 纯 MoonBit 实现

所有子包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
