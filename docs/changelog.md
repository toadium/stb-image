# 变更日志

> 下表为**功能迭代版本**（v0.1 → v5.3.0）演进历史。mooncakes **包版本**为 `0.4.11`（要求 0.x.y 格式），对应最新功能版本 v5.3.0。

## 版本历史

| 版本 | 亮点 | 测试 |
|------|------|------|
| v0.1 | 8位加载（路径+内存），9种格式 | 23 |
| v0.2 | 写入（PNG/BMP/TGA/JPEG）+ req_channels + 翻转 | 32 |
| v0.3 | 16位/浮点加载 + 信息查询 + failure_reason + 配置 | 55 |
| v0.4 | HDR配置 + 动画GIF | 61 |
| v1.0 | API冻结，完整文档，ASan验证 | 61 |
| v1.1 | HDR写入 + 缩放（FFI stb_image_resize2.h） | 75 |
| v1.2 | QOI/ICO/ICNS/GIF编码 + 格式自动检测 | 114 |
| v1.3 | 裁剪/旋转/翻转 + 色彩转换 + 绘制/合成 | 145 |
| v1.4 | 色彩调整 + 滤波器 + 几何 + 直方图 + 量化 | 206 |
| v1.5 | PNM编码 + GIF动画 + EXIF读取 | 229 |
| **v1.6** | **PNG元数据 + 往返测试 + 基准测试** | **254+29** |
| **v1.7** | **pad/border/resize_to_cover/contain + threshold/posterize/extract_channel + 混合模式** | **275+29** |
| **v1.8** | **更多混合模式 + 统计 + pixelate/replace_color/convolve/swap_channels** | **292+29** |
| **v1.9** | **hstack/vstack/tile/transpose + 噪声 + LUT/gradient_map + Alpha操作** | **315+29** |
| **v1.10** | **形态学(erode/dilate/open/close) + Laplacian/Prewitt边缘 + MSE/PSNR/SSIM** | **341+29** |
| **v1.12** | **6种混合模式 + CLAHE + K-means量化 + FFT频域变换** | **369+29** |
| **v1.13** | **频域滤波 + 自适应阈值 + 连通域标记 + 积分图像** | **402+29** |
| **v1.14** | **霍夫变换 + LBP + 图像金字塔 + 双边滤波** | **433+29** |
| **v1.15** | **轮廓提取 + 颜色分割 + NLM 去噪 + Retinex** | **472+29** |
| **v1.16** | **Canny 边缘 + 分水岭 + GLCM 纹理 + Haar 小波** | **501+29** |
| **v1.17** | **Harris 角点 + 去雾 + 距离变换 + Gabor 滤波** | **533+29** |
| **v2.0** | **多目标支持（native/wasm-gc/js 均使用纯 MoonBit），多子包架构（types/pure/{codec,pixel,color,process,util}/lib/process/meta/util），纯 MoonBit 实现** | **872×3** |
| **v2.1** | **形态学衍生/中值滤波/色彩空间(YCbCr/XYZ/Lab/CMYK)/绘图原语/伪彩色/感知哈希/直方图比较/自定义结构元素** | **927** |
| **v2.2** | **透视变换/轮廓分析(凸包/逼近/Hu矩)/霍夫圆/Shi-Tomasi角点/DCT/色调映射/拉普拉斯金字塔融合** | **965** |
| **v2.3** | **TIFF/ICO/CUR/ICNS/APNG 格式编解码，新增12个公开API** | **995** |
| **v3.0** | **EXIF写入/seam carving(内容感知缩放)/SLIC超像素/16-bit float操作泛化(rotate/flip/brightness/contrast)，新增23个API+1类型** | **907×3** |
| **v3.1+** | **DCT O(N³)优化+16-bit/float滤波/边缘检测/统计泛化+wasm目标支持，新增13 API+1类型** | **935×4** |
| **v3.2** | **WebP lossless (VP8L) 解码器 + ImageFormat::Webp，新增1 API+1枚举值** | **942×4** |
| **v4.0** | **ORB特征检测 (FAST-9 + rBRIEF + 汉明匹配)，新增3 API+3类型** | **954×4** |
| **v4.1** | **模板匹配 (SqDiff/CCorr/CCoeff + 归一化变体)，新增2 API+2类型** | **963×4** |
| **v4.2** | **图像修复 inpaint (扩散法 + 距离加权快速法)，新增2 API** | **971×4** |
| **v4.3** | **光流 (Lucas-Kanade稀疏 + Horn-Schunck密集)，新增2 API+1类型** | **979×4** |
| **v4.4** | **SIFT特征检测 (DoG金字塔+关键点定位+方向直方图+128维描述子)，新增1 API+2类型** | **987×4** |
| **v4.5** | **grabCut交互式前景提取 (GMM+ICM优化)，新增1 API** | **994×4** |
| **v4.6** | **SIFT匹配(L2距离+Lowe比率测试) + RANSAC单应性估计(DLT)，新增2 API+1类型** | **1003×4** |
| **v4.7** | **流式解码(逐行/分块/指定通道回调)，新增3 API+1类型** | **1054×4** |
| **v4.8.0** | **WebP lossy(VP8)编码 + PNG/TIFF整数溢出安全修复 + 44项fuzzing审计 + 22项错误路径测试 + 性能基准报告 + 32项示例代码 + 38项边界测试(GIF动画/TIFF错误/PNG错误/zlib高级)，新增1 API** | **1177×4** |

| **v4.9.0** | **诚实性修复：删除流式解码"零内存峰值"虚假声明、修正WebP格式表(解码仅lossless)、添加encode_webp_lossy不可解码警告、修正reexport.mbt虚假Auto-generated注释** | **1177×4** |
| **v4.10.0** | **安全加固：添加MAX_IMAGE_DIMENSION(65535)+check_dims维度溢出守卫、全解码器(PNG/BMP/GIF/TIFF/WebP/JPEG/HDR/QOI/TGA/PNM)入口校验、safe_mul/safe_mul3溢出保护、19项安全测试+5项大尺寸溢出测试、魔法数字清理(read_u32_be替换)、15项高级算法基准测试(SIFT/ORB/grabCut/watershed/NLM/inpaint/seam_carving等)，新增4 API+1常量** | **1196×4** |
| **v5.3.0** | **质量收尾工程：英文README(README.en.md)国际化文档 + CI增强(coverage报告+moon info验证) + 7项错误路径测试补充(multi_band_blend/watershed/kmeans_segment/ihaar_transform_1d) + 语言切换链接** | **1203×4** |
| **v5.8.0** | **覆盖率提升：BMP第二行越界测试+TIFF PackBits扩展模式+PNG palette缺失测试+quantize灰度图/无效k测试+contour孤立点测试+EXIF非APP1标记扫描+PNG无效UTF-8序列测试，新增20项错误路径测试** | **1409×4** |
| **v5.9.0** | **16-bit/float 泛化扩展：新增16个 Image16/ImageF 变体 API（adjust_gamma/invert/to_grayscale/edge_detect_laplacian/edge_detect_prewitt/sharpen/flip_vertical/transpose），色彩调整/边缘检测/滤波/几何变换四类16-bit/float覆盖率达100%，新增20项测试** | **1437×4** |
| **v5.10.0** | **颜色空间转换16-bit/float泛化：新增16个 Image16/ImageF 变体 API（to_rgb/to_rgba/premultiply_alpha/unpremultiply_alpha 图像级 + rgb_to_ycbcr/ycbcr_to_rgb/rgb_to_cmyk/cmyk_to_rgb 像素级），新增15项测试** | **1452** |
| **v5.11.0** | **阈值处理16-bit/float泛化：新增6个 Image16/ImageF 变体 API（adaptive_threshold_mean_16/f、adaptive_threshold_gaussian_16/f、threshold_otsu_16/f），输出二值图像，新增10项测试** | **1462** |
| **v5.12.0** | **形态学操作16-bit/float泛化：新增22个 Image16/ImageF 变体 API（erode/dilate/morph_open/morph_close/morph_gradient/morph_tophat/morph_blackhat + 自定义结构元素版本），新增20项测试** | **1482** |
| **v5.13.0** | **直方图操作16-bit/float泛化：新增8个 Image16/ImageF 变体 API（histogram/histogram_equalize/histogram_normalize/histogram_matching），新增13项测试** | **1495** |
| **v5.14.0** | **特征检测16-bit/float泛化：新增6个 Image16/ImageF 变体 API（lbp/lbp_uniform/canny_edge），LBP输出纹理编码，Canny输出二值边缘，新增13项测试** | **1508** |
| **v5.15.0** | **频域变换16-bit/float泛化：新增17个 Image16/ImageF 变体 API（fft_2d/ifft_2d/fft_magnitude + dct_2d/idct_2d + haar_transform_2d/haar_inverse_transform_2d/haar_denoise），新增17项测试** | **1525** |
| **v5.16.0** | **图像分割16-bit/float泛化：新增10个 Image16/ImageF 变体 API（watershed/watershed_auto + kmeans_segment + slic），输出标签图像/超像素结果，新增10项测试** | **1535** |
| **v5.17.0** | **高级算法16-bit/float泛化：新增12个 Image16/ImageF 变体 API（inpaint/inpaint_fast + nlm_denoise/nlm_denoise_fast + dehaze + guided_filter），新增17项测试** | **1552** |
| **v5.18.0** | **绘制函数16-bit/float泛化：新增8个 Image16/ImageF 变体 API（draw_line/draw_rectangle/draw_circle/draw_polygon），Bresenham直线/中点圆/扫描线填充，新增12项测试** | **1564** |
| **v5.19.0** | **高级几何变换16-bit/float泛化：新增6个 Image16/ImageF 变体 API（warp_affine/warp_perspective/resize），双线性插值，新增9项测试** | **1573** |
| **v5.20.0** | **特征检测高级16-bit/float泛化：新增8个 Image16/ImageF 变体 API（harris_corners/sift_detect/orb_detect/good_features_to_track），新增10项测试** | **1583** |
| **v5.21.0** | **Gabor滤波+模板匹配16-bit/float泛化：新增8个 Image16/ImageF 变体 API（gabor_filter/gabor_filter_bank + template_match/template_match_best），新增8项测试** | **1591** |
| **v5.22.0** | **光流+GLCM 16-bit/float泛化：新增8个 Image16/ImageF 变体 API（lucas_kanade/horn_schunck + compute_glcm/glcm_features_multi_direction），新增8项测试** | **1599** |
| **v5.23.0** | **图像哈希+图像质量+积分图像 16-bit/float泛化：新增16个 Image16/ImageF 变体 API（ahash/dhash/phash + mse/psnr/ssim + integral_image/integral_image_sq），新增12项测试** | **1611** |
| **v5.24.0** | **卷积+双边滤波 16-bit/float泛化：新增6个 Image16/ImageF 变体 API（convolve + bilateral_filter/bilateral_filter_fast），新增8项测试** | **1619** |
| **v5.25.0** | **颜色空间转换 16-bit/float泛化：新增16个像素级变体 API（rgb_to_hsl/hsl_to_rgb + rgb_to_hsv/hsv_to_rgb + rgb_to_xyz/xyz_to_rgb + rgb_to_lab/lab_to_rgb），新增18项测试** | **1637** |
| **v5.26.0** | **色调映射 16-bit/float泛化：新增4个变体 API（gamma_tonemap_16/f + reinhard_tonemap_16/f），输入 ImageF 输出 Image16/ImageF，新增8项测试** | **1645** |
| **v5.27.0** | **多尺度Retinex 16-bit/float泛化：新增6个变体 API（ssr_16/f + msr_16/f + msrcr_16/f），新增8项测试** | **1653** |
| **v5.28.0** | **色彩量化 16-bit/float泛化：新增2个变体 API（kmeans_quantize_16/f），新增6项测试** | **1659** |
| **v5.29.0** | **Floyd-Steinberg抖动 16-bit/float泛化：新增2个变体 API（floyd_steinberg_16/f），新增4项测试** | **1663** |
| **v5.30.0** | **金字塔操作 16-bit/float泛化：新增4个变体 API（pyr_down_16/f + pyr_up_16/f），新增6项测试** | **1669** |
| **v5.31.0** | **Median Cut色彩量化 16-bit/float泛化：新增2个变体 API（median_cut_16/f），新增4项测试** | **1673** |
| **v5.32.0** | **构建金字塔 16-bit/float泛化：新增4个变体 API（build_gaussian_pyramid_16/f + build_laplacian_pyramid_16/f），新增4项测试** | **1677** |
| **v5.33.0** | **多频带融合 16-bit/float泛化：新增2个变体 API（multi_band_blend_16/f），新增4项测试** | **1681** |
| **v5.34.0** | **霍夫直线变换 16-bit/float泛化：新增2个变体 API（hough_lines_16/f），新增4项测试** | **1685** |
| **v5.35.0** | **霍夫圆检测 16-bit/float泛化：新增2个变体 API（hough_circles_16/f），新增4项测试** | **1689** |
| **v5.36.0** | **轮廓提取与绘制 16-bit/float泛化：新增4个变体 API（find_contours_16/f + draw_contours_16/f），新增4项测试** | **1693** |
| **v5.37.0** | **接缝裁剪 16-bit/float泛化：新增8个变体 API（compute_energy_16/f + remove_vertical_seam_16/f + remove_horizontal_seam_16/f + seam_carve_resize_16/f），新增4项测试** | **1697** |
| **v5.38.0** | **WebP lossy VP8 解码：实现 VP8 bitstream 解析、帧头解析、量化参数解析、环路去块滤波、YUV420转RGB，补齐 WebP 全格式支持（lossless VP8L + lossy VP8），新增3项测试** | **1700** |
| **v5.39.0** | **VP8 解码核心算法完善：实现 4x4 IDCT 反变换、16x16 WHT 变换、I16x16 帧内预测（4种模式）、I4x4 帧内预测（10种模式），集成到解码器中** | **1700** |
| **v5.40.0** | **VP8 残差系数解析：实现完整布尔算术解码器（BoolDecoder）、token 解析、zig-zag 扫描、DC/AC 系数分离、概率模型（简化版），集成到解码器完整流水线** | **1700** |
| **v5.41.0** | **VP8 自适应概率模型：实现按系数位置（16个）和 token 类型（零/一/EOB/额外位/符号）的独立概率表、统计计数器、指数加权平均（EMA）概率更新、每8块更新一次、计数器半衰机制** | **1700** |
| **v5.42.0** | **VP8 宏块层预测模式解析：实现 I16x16 预测模式解析（4种）、I4x4 预测模式解析（10种）、色度预测模式解析（4种）、子宏块类型解析、预测模式自适应概率模型（EMA更新），从 bitstream 解析预测模式而非根据位置选择** | **1700** |
| **v5.43.0** | **VP8 I4x4 帧内预测完整实现：完整实现 10 种预测模式（DC/TrueMotion/H/V/LeftDown/RightDown/RightUp/LeftUp/VertRight/HorizDown），每种模式独立的预测公式，支持对角线/组合预测，移除简化实现** | **1700** |
| **v5.44.0** | **VP8 环路去块滤波完善：实现完整的环路滤波算法，包括宏块边界滤波（4抽头滤波）、子宏块内部边界滤波（4x4块边界）、色度平面滤波（U/V 8x8块）、自适应滤波强度（基于segment和模式的增量）、滤波阈值判断、内部滤波级别** | **1700** |
| **v5.45.0** | **VP8 非关键帧支持基础框架：实现运动向量结构（Vp8MotionVector）、宏块类型枚举（Intra/Inter/Skip）、参考帧管理（Vp8ReferenceFrames：last/golden/altref）、运动补偿函数（整数像素精度，16x16 Y + 8x8 UV）、运动向量预测（相邻宏块中值）、运动向量解析框架** | **1700** |
| **v5.46.0** | **VP8 非关键帧完整集成：实现亚像素运动补偿（1/4像素精度，6抽头半像素插值+双线性四分之一像素插值）、运动向量残差解析（Exp-Golomb编码）、参考帧选择（last/golden/altref）、完整非关键帧解码函数（decode_vp8_inter_frame，支持帧内/帧间宏块混合、运动补偿+残差、参考帧更新）、Vp8ReferenceFrames改为公开类型** | **1700** |
| **v5.47.0** | **VP8 Segment 解析：实现完整的 segmentation 特性解析（segmentation_enabled/update_map/update_features/feature_mode）、每个segment的量化器增量和滤波级别增量、宏块segment ID树解析（3个概率的二叉树）、基于segment的自适应量化参数计算、基于segment的自适应滤波级别计算、集成到主解码流程（segment_id_map保存每个宏块的segment ID）** | **1700** |
| **v5.48.0** | **VP8 编码器完整实现：实现完整的 WebP lossy (VP8) 编码器，包括 RGB→YUV420 转换、4x4 DCT 正向变换（VP8特定变换矩阵）、16x16 WHT 正向变换（DC系数）、量化（基于quality的量化参数）、I16x16 DC 帧内预测、布尔算术编码器（Vp8BoolEncoder）、token编码（零/一/EOB/额外位/符号位）、完整VP8 frame header构建、WebP RIFF容器构建、新增公开API encode_webp_lossy_full** | **1700** |
## 上游

- [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) — 提交 `013ac3beddff3dbffafd5177e7972067cd2b5083` (v2.30)
- [stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) — 同一提交 (v1.16)
- [stb_image_resize2.h](https://github.com/nothings/stb/blob/master/stb_image_resize2.h) — v2.07| **v5.49.0** | **VP8 编码器完善 - I16x16 4种预测模式：实现 DC/TrueMotion/H/V 四种 I16x16 帧内预测模式、基于 SAD 代价的预测模式选择（vp8_select_i16x16_mode）、预测模式编码（2 bits）、集成到主编码流程** | **1700** |
