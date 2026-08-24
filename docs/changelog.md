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
## 上游

- [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) — 提交 `013ac3beddff3dbffafd5177e7972067cd2b5083` (v2.30)
- [stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) — 同一提交 (v1.16)
- [stb_image_resize2.h](https://github.com/nothings/stb/blob/master/stb_image_resize2.h) — v2.07