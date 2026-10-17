# stb-image 架构设计文档（GeoVerse 思想重构版）

> **版本**：v2.0 GeoVerse Architecture  
> **日期**：2026-10-17  
> **状态**：终版（融合 GeoVerse 七层架构 + 图像场几何 + 时空图像 + AOCI 符号索引）  
> **基线**：v264.0.0, 6394×4 测试全绿, 1338 pub fn + 491 type

> **项目定位**：下一代**统一图像处理引擎**，融合 GeoVerse 七层架构思想，将图像提升为一等场实体，支持时空图像（视频/动画）原生处理；所有图像算子、场算子、时空拓扑全部下沉到内核，而非上层业务封装。
> **核心原则**：图像不是像素数组，是**二维场实体**；时间不是属性标签，是**原生第 3 维**；所有图像算子、场算子、时空分析算子全部统一编码到 ImgIR，支持 JIT、GPU 并行、分布式计算。

---

## 目录

1. [项目概述与顶层目标](#1-项目概述与顶层目标)
2. [顶层约束与非目标边界](#2-顶层约束与非目标边界)
3. [七层整体架构总览](#3-七层整体架构总览)
4. [内核模块详细定义](#4-内核模块详细定义)
5. [源码目录结构](#5-源码目录结构)
6. [迭代路线图 Roadmap](#6-迭代路线图-roadmap)
7. [能力清单与边界校验](#7-能力清单与边界校验)
8. [与旧架构的映射关系](#8-与旧架构的映射关系)

---

## 1. 项目概述与顶层目标

### 现有架构短板

- **扁平包结构**：`src/process/` 下 90+ 子包平铺，无层次分离，依赖关系不清晰
- **图像非一等实体**：Image/Image16/ImageF 三类型割裂，无统一泛型抽象
- **无时空维度**：APNG/GIF 动画仅作为多帧序列处理，无时空拓扑谓词
- **无统一 IR**：算子直接执行，无中间表示，无法 JIT/并行优化
- **无 AI 索引**：1338 个公开函数无符号语义索引，AI 查询需全量上下文

### GeoVerse 思想重构目标

> 建立一套统一数学框架，同时容纳：
> ① 基础图像像素操作；② **图像即场**——灰度图=2D标量场、RGB图=2D矢量场；③ **时空图像**——视频/动画=时变图像场；
> 把图像处理算子——边缘检测、滤波、分割、特征检测——统一为**场算子**的特例。
> 支持场的求值、微分（梯度=边缘）、积分（直方图）、等值提取（阈值分割）、时空演化（视频处理）。

### 核心能力要点

1. **图像与场双向互通**：Image 可视为标量场/矢量场；场可提取等值线生成 Image
2. **图像可随时间演化**：视频帧序列、APNG/GIF 动画 = 时变图像场 TImage
3. **场运算原生支持**：梯度（边缘检测）、拉普拉斯（模糊）、散度、旋度、积分（直方图）
4. **时空图像系统**：统一管理静态图像、动态图像、时变场的时序状态、版本、回放
5. **所有算子统一编码到 ImgIR**，支持 JIT、GPU 并行、分布式计算

---

## 2. 顶层约束与非目标边界

### 顶层原则

1. **鲁棒优先**：处理退化图像、场间断面、边界溢出；自动切换整数/定点/浮点/区间算术
2. **单向依赖**：上层模块依赖下层，禁止循环依赖（七层严格分层）
3. **跨环境一致性**：native / wasm-gc / js / wasm 四目标，计算结果可复现
4. **纯 MoonBit**：零 C FFI 依赖，四目标全可用
5. **可序列化**：图像、场、时空上下文全部可序列化到 ImgIR

### 非目标（严格划界）

1. **不做完整视频编解码器**（不替代 FFmpeg）；只提供帧级图像处理 + 时空拓扑
2. **不做完整物理求解器**；图像场算子仅做几何层面的场操作
3. **不做上层 GUI 渲染界面**；仅提供 IO 接口对接外部存储
4. **不实现完整深度学习框架**；OCR/检测等仅提供传统算法实现

---

## 3. 七层整体架构总览

```
┌───────────────────────────────────────────────────────────────┐
│ 七层：自演化智能层（图像算法自动发现、测试用例自动生成）          │
├───────────────────────────────────────────────────────────────┤
│ 六层：Agent-Kit 自然语言图像处理 API                            │
├───────────────────────────────────────────────────────────────┤
│ 五层：ImgIR 统一图像中间表示（静态图像IR / 场IR / 时空图像IR）    │
├───────────────────────────────────────────────────────────────┤
│ 四层：领域高阶算法层                                            │
│        codec · color · filter · transform · feature · segment  │
│        ✅ fieldimg 图像场几何（标量场/矢量场/张量场）             │
│        ✅ spatiotemporal 时空图像系统（视频/动画/时变图像）        │
│        ✅ analysis 图像综合分析（质量/对比/检索/理解）            │
│        ✅ frequency 频域处理（FFT/DCT/小波）                     │
│        ✅ ocr · medical · encryption · detection ...           │
├───────────────────────────────────────────────────────────────┤
│ 三层：基础图像层（Image / Image16 / ImageF / Pixel / geom2d）   │
├───────────────────────────────────────────────────────────────┤
│ 二层：硬件调度 & 并行层（SIMD / GPU / 多线程）                   │
├───────────────────────────────────────────────────────────────┤
│ 一层：kernel 四层数值内核（整数、定点、浮点、区间算术）           │
└───────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────┐
  │  AOCI 符号语义索引基础设施（独立于主栈）  │
  │  面向 AI 的上下文管控 · 降低 Token 消耗   │
  │  贯穿二层 ~ 六层，双向联动所有模块         │
  └─────────────────────────────────────────┘
```

---

## 4. 内核模块详细定义

### 4.1 kernel 数值内核（一层）

底层数学基座，提供四种数值模式：

| 模式 | 用途 | 映射 |
|------|------|------|
| 整数算术 | 溢出安全像素运算 | Image (uint8) |
| 定点算术 | 高精度中间计算 | Image16 (uint16) |
| 浮点算术 | HDR/科学计算 | ImageF (float32) |
| 区间算术 | 捕获数值不确定性 | 误差传播分析 |

### 4.2 parallel 硬件调度层（二层）

| 子模块 | 能力 |
|--------|------|
| simd | SIMD 向量化（行级并行） |
| gpu | GPU 加速（wasm 目标降级为 CPU） |
| thread | 多线程（native 目标可用） |

> **约束**：四目标一致性——GPU/SIMD 结果必须与 CPU 串行结果位精确一致

### 4.3 image 基础图像层（三层）

| 子模块 | 内容 |
|--------|------|
| types | Image / Image16 / ImageF / Pixel / LoadError / ImageFormat |
| pixel | 像素读写、通道提取、混合 |
| geom2d | 2D 几何原语（Rect / Point / Line / Affine） |
| io | 图像文件读写接口（对接 codec） |

> **关键设计**：Image/Image16/ImageF 三类型通过 `trait ImageLike` 统一接口，支持泛型算法

### 4.4 领域高阶算法层（四层）

#### 4.4.1 codec — 18 种格式编解码

```
codec/
├── png/ jpeg/ bmp/ gif/ qoi/ tga/ psd/ hdr/ pnm/
├── tiff/ ico/ cur/ icns/ apng/ webp/ avif/ heif/ jpegxl/
└── detect/          # 格式检测 + 自动分派
```

#### 4.4.2 color — 色彩处理

```
color/
├── convert/         # 色彩空间转换（RGB/HSV/Lab/YCbCr）
├── adjust/          # 亮度/对比度/Gamma/白平衡
├── clahe/           # CLAHE 自适应直方图均衡
├── retinex/         # Retinex/去雾
└── threshold/       # 阈值化（Otsu/自适应/Sauvola/Niblack）
```

#### 4.4.3 filter — 滤波/去噪

```
filter/
├── blur/            # 高斯/均值/中值/双边
├── sharpen/         # 锐化/Unsharp Mask
├── denoise/         # BM3D/NLM/小波去噪
└── inpaint/         # 图像修复
```

#### 4.4.4 transform — 几何变换

```
transform/
├── geometric/       # 缩放/旋转/翻转/裁剪/仿射
├── perspective/     # 透视变换/单应矩阵
├── seam/            # Seam Carving
├── pyramid/         # 高斯/拉普拉斯金字塔
└── warp/            # 畸变/极坐标
```

#### 4.4.5 feature — 特征检测

```
feature/
├── edge/            # Sobel/Prewitt/Canny/Laplacian
├── corner/          # Harris/Shi-Tomasi/FAST
├── blob/            # LoG/DoG/MSER
├── orb/             # ORB 特征
├── sift/            # SIFT 特征
├── hough/           # 霍夫变换（线/圆）
├── contour/         # 轮廓提取
├── template_match/  # 模板匹配
├── optical_flow/    # 光流
├── glcm/            # 灰度共生矩阵
└── lbp/             # 局部二值模式
```

#### 4.4.6 segment — 图像分割

```
segment/
├── watershed/       # 分水岭
├── slic/            # SLIC 超像素
├── grabcut/         # GrabCut
├── morphology/      # 形态学操作
├── connected/       # 连通域
├── kmeans/          # K-means 分割
└── levelset/        # 水平集
```

#### 4.4.7 fieldimg — 图像场几何（NEW: GeoVerse 核心创新）

> **定位**：将图像提升为场实体，标量场（灰度）/矢量场（RGB）/张量场；场是一等几何对象

```
fieldimg/
├── scalar_field/    # 标量场：灰度图=2D标量场
├── vector_field/    # 矢量场：RGB图=2D矢量场
├── tensor_field/    # 张量场：结构张量/梯度张量
├── field_ops/       # 场通用算子
│   ├── evaluate     #   场值求值
│   ├── gradient     #   梯度 → 边缘检测
│   ├── divergence   #   散度
│   ├── curl         #   旋度
│   ├── laplacian    #   拉普拉斯 → 模糊/锐化
│   ├── integrate    #   积分 → 直方图/总量
│   ├── field_clamp  #   阈值裁剪 → 二值化
│   ├── field_mask   #   掩码 → ROI
│   ├── field_add/sub/mul/blend  #   场代数运算
│   └── isosurface/isoline       #   等值提取 → 分割
└── field_bind/      # 场与 Image 双向转换
```

> **关键映射**：
> - `gradient` = 边缘检测（Sobel/Canny）
> - `laplacian` = 模糊/锐化（LoG）
> - `integrate` = 直方图/面积积分
> - `field_clamp` = 阈值分割
> - `isosurface` = 等值线提取

#### 4.4.8 spatiotemporal — 时空图像系统（NEW: GeoVerse 核心创新）

> **定位**：四维（X, Y, C, T）原生时空图像系统，统一管理静态图像 + 动态图像 + 时变场

```
spatiotemporal/
├── primitives/      # 时空原语
│   ├── TImage       #   时变图像
│   ├── TFrame       #   时空帧
│   ├── TVideo       #   时空视频
│   └── TInterval    #   时间区间
├── temporal_ctx/    # TContext 时态控制器
├── st_predicates/   # 时空拓扑谓词
│   ├── st_contains/within/intersects/overlaps
│   └── st_during/before/after/meets
├── st_interpolate/  # 帧间插值（光流/线性）
├── st_snapshot/     # 时序快照/版本/回溯
└── st_field_bind/   # 时变图像场管理
```

> **应用场景**：APNG/GIF 动画处理、视频帧分析、运动检测、时变滤镜

#### 4.4.9 analysis — 图像综合分析

```
analysis/
├── quality/         # 质量评估（PSNR/SSIM/MS-SSIM）
├── compare/         # 图像对比/差异
├── retrieval/       # 图像检索（CBIR/HOG/LBP）
├── understanding/   # 图像理解（场景/物体）
└── statistics/      # 图像统计（直方图/矩/熵）
```

#### 4.4.10 frequency — 频域处理

```
frequency/
├── fft/             # 快速傅里叶变换
├── dct/             # 离散余弦变换
├── wavelet/         # 小波变换（Haar/DB）
└── filter/          # 频域滤波（低通/高通/带通）
```

#### 4.4.11 其他领域模块

```
ocr/                 # OCR 全流程
medical/             # 医学图像（DICOM/CT/MRI/超声/病理）
encryption/         # 图像加密/解密/水印
detection/          # 目标检测（YOLO/Haar）
superres/           # 超分辨率
stylize/            # 风格迁移/艺术效果
stitch/             # 图像拼接/全景
fusion/             # 图像融合
3d/                 # 3D 视觉
video/              # 视频处理
...
```

### 4.5 ImgIR 统一中间表示（五层）

| IR 类型 | 内容 |
|---------|------|
| 图像 IR | Image 表达式、像素操作节点 |
| 场 IR | 标量/矢量/张量场表达式；场运算节点（梯度/积分/等值） |
| 时空 IR | 时间区间、TImage 时序节点 |

> **能力**：算子序列化、JIT 编译、GPU 向量化执行、分布式任务分发

### 4.6 AOCI 符号语义索引（独立基础设施）

> **定位**：为 stb-image 的 1338+ 公开函数建立符号语义索引，AI 查询时按需加载模块文档，降低 70%~90% Token 消耗

#### 四大子组件

| 组件 | 职责 |
|------|------|
| AOCI-Builder | 源码/mbti 解析 → 符号坐标 + 依赖图谱 |
| AOCI-Router | 自然语言 → 模块定位 → 按需加载 |
| AOCI-ContextBudget | Token 配额/分区/降级压缩 |
| AOCI-Verifier | 依赖一致性/过期检测/边界冲突 |

### 4.7 Agent-Kit / 自演化层（六层/七层）

> **定位**：六层 Agent-Kit 将自然语言图像处理意图编译为 ImgIR 管道；七层自演化层在工程闭环中自动发现退化场景、生成测试、优化算法。本节嵌入 mattpocock/skills 五套工程工作流，构成"拷问→导航→规格→实现→文档→变更追踪"完整闭环。

#### 4.7.1 Agent-Kit 自然语言 API（六层）

| 组件 | 职责 |
|------|------|
| Intent | 意图枚举（去噪/边缘/分割/增强/变换/融合/识别…） |
| nl_parse | 自然语言 → Intent（关键词匹配） |
| compile | Intent → IRPipeline（意图 → 算子序列） |
| nl_process | 高层 API：自然语言 → 执行结果 |

> **示例**："给这张图去噪并检测边缘" → compile(去噪 + 边缘) → IRPipeline[gaussian_blur, sobel_edge] → Executor 执行

#### 4.7.2 工程工作流嵌入（mattpocock/skills 范式适配）

将通用软件工程工作流适配为 GeoVerse 领域工程闭环：

| 工作流 | 原版职责 (mattpocock/skills) | GeoVerse 适配 |
|--------|------------------------------|----------------|
| grill-me | 架构拷问 / 可行性校验 | 新增算子或架构变更前的领域拷问：依赖冲突？数值鲁棒性？退化几何（除零 / 奇异矩阵）？场间断（边界不连续）？四目标兼容？ |
| wayfinder | 项目导航 | 对接 AOCI-Router，按符号坐标按需加载 1338+ 函数文档片段，控制 Token |
| to-spec | 需求 → 规格 | 自然语言需求 → GeoIR 算子规格（ImgIR pipeline 规格），衔接 Agent-Kit compile |
| docs | 文档一致性 | 校验 ARCHITECTURE.md / 模块 README / roadmap / changelog 之间的一致性 |
| changeset | 变更追踪 | 记录架构 / 算子变更，分析影响范围（下游包 / 测试 / 重导出） |

#### 4.7.3 自演化层（七层）

- **测试用例自动生成**：基于算子签名 + 边界条件自动生成白盒 / 黑盒测试
- **退化场景自动发现**：grill-me 拷问规则扫描数值退化（除零 / 溢出 / 奇异 / 场间断）
- **算法优化**：基准对比 + 算子替换搜索

#### 4.7.4 风险与领域规则注入

> **风险**：mattpocock/skills 原版为通用软件工程范式，不含计算几何 / 场 / 时空拓扑领域知识。直接套用 grill-me 拷问规则无法覆盖 stb-image 的数值与几何退化。

**须注入的领域规则**（写入 grill-me 拷问规则集）：

1. **数值鲁棒性**：浮点除法须检查分母 ≈ 0；矩阵须检查行列式 ≈ 0（奇异）；IEEE 754 须检查 NaN / Inf
2. **退化几何**：除零、共线点、退化三角形、零面积区域
3. **场间断**：场边界不连续、梯度不存在、插值外推
4. **时空拓扑**：Allen 区间代数一致性、时间区间空集、TContext 时间戳单调性
5. **四目标兼容**：纯 MoonBit 无 C FFI，native / wasm-gc / js / wasm 共用代码

#### 4.7.5 收益

- Agent-Kit 从"自然语言 → IR"升级为完整工程闭环：拷问 → 导航 → 规格 → 实现 → 文档 → 变更追踪
- AOCI 符号索引被 wayfinder 复用，Token 消耗降低 70%~90%
- 自演化层的退化发现依赖 grill-me 领域规则，形成"拷问 → 发现 → 生成测试 → 验证"自闭环

---

## 5. 源码目录结构

```
src/
├── kernel/              # 一层：四层数值内核
│   ├── integer/         #   整数算术（溢出安全）
│   ├── fixedpoint/      #   定点算术
│   ├── floating/        #   浮点算术（IEEE 754）
│   └── interval/        #   区间算术
├── parallel/            # 二层：硬件调度 & 并行
│   ├── simd/            #   SIMD 向量化
│   ├── gpu/             #   GPU 加速
│   └── thread/          #   多线程
├── image/               # 三层：基础图像层
│   ├── types/           #   Image/Image16/ImageF/Pixel/LoadError/ImageFormat
│   ├── pixel/           #   像素操作
│   ├── geom2d/          #   2D 几何原语
│   └── io/              #   文件读写接口
├── codec/               # 四层：18 种格式编解码
│   ├── png/ jpeg/ bmp/ gif/ qoi/ tga/ psd/ hdr/ pnm/
│   ├── tiff/ ico/ cur/ icns/ apng/ webp/ avif/ heif/ jpegxl/
│   └── detect/
├── color/               # 四层：色彩处理
├── filter/              # 四层：滤波/去噪
├── transform/           # 四层：几何变换
├── feature/             # 四层：特征检测
├── segment/             # 四层：图像分割
├── fieldimg/            # 四层：图像场几何（NEW）
├── spatiotemporal/      # 四层：时空图像系统（NEW）
├── analysis/            # 四层：图像综合分析
├── frequency/           # 四层：频域处理
├── ocr/                 # 四层：OCR
├── medical/             # 四层：医学图像
├── encryption/          # 四层：加密/水印
├── detection/           # 四层：目标检测
├── superres/            # 四层：超分辨率
├── stylize/             # 四层：风格迁移
├── stitch/              # 四层：图像拼接
├── fusion/              # 四层：图像融合
├── video/               # 四层：视频处理
├── ...                  #   其余领域模块
├── geoir/               # 五层：统一图像中间表示
│   ├── ir_core/
│   ├── ir_image/
│   ├── ir_field/
│   └── ir_spatiotemporal/
├── aoci/                # AOCI 符号语义索引
│   ├── builder/
│   ├── router/
│   ├── context_budget/
│   └── verifier/
├── agent_kit/           # 六层：自然语言 API
├── self_evolve/         # 七层：自演化智能层
├── meta/                # 元数据（EXIF/XMP/IPTC/PNG text）
├── util/                # 通用工具
└── reexport.mbt         # 顶层 API re-export
```

---

## 6. 迭代路线图 Roadmap

### Phase 0｜架构定型期

> **风险等级**：✅ 低风险 | **交付性质**：核心交付基线

**目标**：七层目录结构建立，现有代码迁移完成，四目标全绿

1. 创建七层目录结构
2. 迁移 types → image/types
3. 迁移 pure/codec → codec/
4. 迁移 pure/color → color/
5. 迁移 pure/util → transform/ + filter/
6. 迁移 process/* → 对应四层模块
7. 更新所有 moon.pkg 依赖
8. 更新 reexport.mbt
9. 四目标测试全绿

> **交付物**：新架构下 6394×4 全绿，API 表面不变

### Phase 1｜场几何落地期

> **风险等级**：✅ 低风险 | **交付性质**：核心增强

**目标**：fieldimg 图像场几何模块完整实现

1. scalar_field / vector_field 基础类型
2. field_ops 通用算子（gradient/divergence/laplacian/integrate）
3. field_bind 场与 Image 双向转换
4. 验证：gradient = 边缘检测，laplacian = 模糊

### Phase 2｜时空图像落地期

> **风险等级**：⚠️ 中等风险 | **交付性质**：核心增强

**目标**：spatiotemporal 时空图像系统完整实现

1. TImage/TFrame/TVideo 时空原语
2. TContext 时态控制器
3. 时空拓扑谓词
4. APNG/GIF → TImage 转换
5. 时变滤镜、运动检测

### Phase 3｜ImgIR + AOCI 落地期

> **风险等级**：⚠️ 中等风险 | **交付性质**：基础设施

1. ImgIR 统一中间表示
2. AOCI 符号语义索引
3. Agent-Kit 自然语言 API

### Phase 4｜自演化预研期

> **风险等级**：🔴 高风险 | **交付性质**：前沿预研

1. self-evolve 自动测试用例生成
2. 算法自动优化

---

## 7. 能力清单与边界校验

- ✅ 18 种格式编解码（PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM/TIFF/ICO/CUR/ICNS/APNG/WebP/AVIF/HEIF/JPEG-XL）
- ✅ 基础图像操作（Image/Image16/ImageF 三类型统一）
- ✅ 色彩处理（转换/调整/CLAHE/Retinex/阈值）
- ✅ 滤波去噪（高斯/均值/中值/双边/锐化/修复）
- ✅ 几何变换（缩放/旋转/翻转/裁剪/仿射/透视/Seam/金字塔）
- ✅ 特征检测（边缘/角点/斑点/ORB/SIFT/霍夫/轮廓/模板匹配/光流）
- ✅ 图像分割（分水岭/SLIC/GrabCut/形态学/连通域）
- ✅ 频域处理（FFT/DCT/小波）
- ✅ OCR 全流程
- ✅ 医学图像处理
- ✅ 加密/水印
- ✅ 图像场几何（标量场/矢量场/场算子）— NEW
- ✅ 时空图像系统（TImage/时空谓词/时序快照）— NEW
- ✅ ImgIR 统一中间表示 — NEW
- ✅ AOCI 符号语义索引 — NEW
- ✅ 四目标全绿（native/wasm-gc/js/wasm）
- ✅ 纯 MoonBit，零 C FFI

---

## 8. 与旧架构的映射关系

| 旧路径 | 新路径 | 层级 |
|--------|--------|------|
| src/types/ | src/image/types/ | 三层 |
| src/pure/codec/ | src/codec/ | 四层 |
| src/pure/color/ | src/color/ | 四层 |
| src/pure/util/ | src/transform/ + src/filter/ | 四层 |
| src/lib/ | src/image/io/ + src/codec/detect/ | 三层+四层 |
| src/meta/ | src/meta/ | 横切 |
| src/process/color/ | src/color/ | 四层 |
| src/process/filter/ | src/filter/ | 四层 |
| src/process/transform/ | src/transform/ | 四层 |
| src/process/edge/ | src/feature/edge/ | 四层 |
| src/process/feature/ | src/feature/ | 四层 |
| src/process/segment/ | src/segment/ | 四层 |
| src/process/frequency/ | src/frequency/ | 四层 |
| src/process/ocr/ | src/ocr/ | 四层 |
| src/process/medical/ | src/medical/ | 四层 |
| src/process/encryption/ | src/encryption/ | 四层 |
| src/process/quality/ | src/analysis/quality/ | 四层 |
| src/process/detection/ | src/detection/ | 四层 |
| src/process/superres/ | src/superres/ | 四层 |
| src/process/stylize/ | src/stylize/ | 四层 |
| src/process/stitch/ | src/stitch/ | 四层 |
| src/process/fusion/ | src/fusion/ | 四层 |
| src/process/video/ | src/video/ | 四层 |
| src/process/... | src/对应模块/ | 四层 |
| src/util/ | src/util/ | 横切 |
| src/reexport.mbt | src/reexport.mbt | 顶层 |
| (不存在) | src/kernel/ | 一层 NEW |
| (不存在) | src/parallel/ | 二层 NEW |
| (不存在) | src/fieldimg/ | 四层 NEW |
| (不存在) | src/spatiotemporal/ | 四层 NEW |
| (不存在) | src/geoir/ | 五层 NEW |
| (不存在) | src/aoci/ | AOCI NEW |
| (不存在) | src/agent_kit/ | 六层 NEW |
| (不存在) | src/self_evolve/ | 七层 NEW |

---

> **文档结束** | stb-image ARCHITECTURE.md v2.0 | 2026-10-17 | GeoVerse 思想重构版