# 变更日志

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
| **v3.0** | **EXIF写入/seam carving(内容感知缩放)/SLIC超像素/16-bit float操作泛化(rotate/flip/brightness/contrast)，新增23个API+1类型** | **887×3** |
| **v3.1** | **架构优化：删除pure/process+pure/pixel+src/format死代码，职责归位(color/segment交换)，命名统一(_f后缀/kmeans/ihaar/EncodeFailed)，API设计修复(req_channels传递/alpha保留)，文档同步** | **887×3** |

## 上游

- [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) — 提交 `013ac3beddff3dbffafd5177e7972067cd2b5083` (v2.30)
- [stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) — 同一提交 (v1.16)
- [stb_image_resize2.h](https://github.com/nothings/stb/blob/master/stb_image_resize2.h) — v2.07