# 架构设计

## 子包结构

| 子包 | 路径 | 职责 | 实现性质 |
|------|------|------|----------|
| **types** | `src/types/` | 像素类型与错误类型权威定义 | 纯 MoonBit |
| **core** | `src/core/` | C FFI 交互、加载/写入/缩放/检测/配置/ICO 编码 | C FFI（native-only） |
| **lib** | `src/lib/` | 统一 API 层（pure 侧）：格式自动检测 + 编解码委托 | 纯 MoonBit |
| **pure** | `src/pure/` | wasm/js 纯 MoonBit 后端：6 解码器 + 3 编码器 + 图像处理 | 纯 MoonBit |
| **process** | `src/process/` | 图像处理算法总包（7 个子子包） | 纯 MoonBit |
| **format** | `src/format/` | QOI/GIF/PNM 纯 MoonBit 编解码 | 纯 MoonBit |
| **meta** | `src/meta/` | EXIF 与 PNG 文本块元数据读取 | 纯 MoonBit |
| **util** | `src/util/` | 像素操作、合成、噪声、色彩映射、统计等工具 | 纯 MoonBit |

## process/ 子子包

| 子子包 | 职责 |
|--------|------|
| **transform** | 几何变换（crop/rotate/flip/warp_affine）、绘制、金字塔 |
| **color** | 色彩转换/调整、CLAHE、自适应阈值、Retinex、去雾 |
| **filter** | 滤波器（box/gaussian/sharpen/sobel）、双边滤波、NLM 去噪 |
| **edge** | 边缘检测（Canny/Laplacian/Prewitt）、轮廓、Hough 变换 |
| **feature** | 特征提取（Harris/LBP/Gabor/GLCM）、直方图、质量评估（SSIM/PSNR） |
| **frequency** | 频域分析（FFT/IFFT、频域滤波、Haar 小波） |
| **segment** | 分割（K-means/区域生长/分水岭）、形态学、连通域、距离变换 |

## 数据流

```
用户代码
  ├── native 目标 → src/core/ → C FFI → stb_image.h → memcpy → MoonBit Bytes
  └── wasm/js 目标 → src/lib/ → src/pure/ → 纯 MoonBit 编解码
```

## 向后兼容

`src/reexport.mbt`（969 行，由 `scripts/gen_reexport.py` 自动生成）将 199 个函数 + 29 个类型从子包重导出到根包，用户可直接从 `toadium/image` 导入所有 API。
