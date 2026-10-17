# ArcGIS Pro 栅格分析与影像分析工具清单：全面核实、补全与结构化

## 摘要

本文以 Esri 官方 ArcGIS Pro 3.7 帮助文档为基准，系统梳理以栅格（像元）数据为输入、以栅格或影像产品为输出的分析工具，覆盖 Spatial Analyst 扩展模块（24 个工具集、200 余工具）、Image Analyst 扩展模块（15 个工具集）以及两类栅格函数体系（局部函数约 150 项、全局函数约 30 项）。核心结论如下：

① **许可口径与矢量清单不同**：栅格与影像分析工具几乎全部依赖扩展模块，核心程序许可级别（Basic/Standard/Advanced）只决定"能否挂上扩展"，实际执行看扩展授权。Spatial Analyst 全工具集统一标注为「需 Spatial Analyst 扩展模块许可」；Image Analyst 全工具集统一标注为「需 Image Analyst 扩展模块许可」；③ **存在两处许可例外**：Image Analyst 的「创建彩色合成」仅需 ArcGIS Pro Desktop Basic 许可；「栅格转矢量」为 Basic 级工具，但因输出为矢量，本文仅作交叉引用、不单列。

② **工具体系的双重性必须区分**：同一算法往往同时存在"地理处理工具"（写入磁盘）与"栅格函数"（按需动态计算）两种形态。例如距离累积既有 Distance Accumulation 工具，也有 Distance Accumulation 函数；核密度既有工具也有函数。本文在第三部分单列栅格函数，避免与工具箱条目重复计数的误解。

③ **版本演进带来工具更替**：距离分析、表面分析在 Pro 2.5—3.4 期间经历大幅重构，旧版工具（成本距离、欧氏距离、路径距离系列，共 14 项）被归入"距离分析（旧版本）"工具集，新版工具（距离累积、距离分配、最佳路径为线/栅格、最佳廊道连接、最佳区域连接）在精度与功能上全面替代。本文保留旧版清单但明确标注"遗留/Legacy"，不建议新工程使用。

④ **原清单式归纳中常见三类错误已在此纠正**：一是把"栅格函数"当"地理处理工具"混列（如 Kernel Density 函数与工具实为两个入口）；二是忽略工具集迁移（如「表面分析」在 Pro 3.x 中归属 Spatial Analyst 而非 3D Analyst 独立工具集）；三是遗漏 Pro 3.0 后新增工具（要素保留平滑、多尺度表面偏差/差异/百分位数、测地线视域的地球/月球双模式、深度学习工具集新增的 5 项工具）。

⑤ **"栅格函数"与"地理处理工具"的许可不完全对称**：部分栅格函数（如 Nibble、Region Group、Shrink、Distance 类函数、Weighted Overlay、Weighted Sum）明确要求 Spatial Analyst 许可；而大量基础函数（Band Arithmetic、Slope、Hillshade、NDVI 等）在 ArcGIS Pro Basic 下即可使用。本文在第三部分逐项标注。

---

## 总说明

### 口径与收录规则

本文仅收录**以栅格数据集、影像数据集、多维栅格或镶嵌数据集为输入，并以栅格、影像或多维栅格为直接输出**的地理处理工具与栅格函数。具体包含三类对象：

1. **Spatial Analyst 工具箱**的全部 24 个工具集中的工具（含"距离分析（旧版本）"遗留工具集）；
2. **Image Analyst 工具箱**的全部 15 个工具集中的工具；
3. **栅格函数**体系，分为局部函数（Local Functions）与全局函数（Global Functions）两类，并按 Analysis、Classification、Data Management、Distance、Distance (Legacy)、Hydrology、Math、Math: Conditional、Math: Logical、Math: Trigonometrical、Reclass、Surface、Statistical 十三个类别归类。

**明确排除项**：① 输出为矢量的工具（如 Stream To Feature、Contour、Cost Path as Polyline、Optimal Path As Line、Derive Stream As Line 等），已在《矢量分析工具清单》收录，本文仅作交叉引用；② 纯数据管理类工具（Raster To Geodatabase、Create Mosaic Dataset 等）不属分析范畴，不收录；③ 地图代数中的 Raster Calculator 表达式本身不单列，仅在数学分析工具集中注明其等价工具；④ 第三方深度学习框架（PyTorch、TensorFlow）训练环节不属 ArcGIS Pro 工具范畴，不收录。

### 许可等级定义

栅格与影像分析的许可结构比矢量分析简单，但存在"双层授权"特征：

| 层级 | 说明 |
|---|---|
| **核心程序许可** | Basic（Creator）/ Standard（Professional）/ Advanced（Professional Plus），决定能否运行 Pro 本身及基础栅格函数 |
| **扩展模块许可** | Spatial Analyst、Image Analyst 两个独立扩展，分别解锁对应工具箱的全部工具与部分栅格函数 |

本文标注规则：
- 「**Spatial Analyst**」= 需 Spatial Analyst 扩展模块许可，核心程序 Basic/Standard/Advanced 任一均可挂接；
- 「**Image Analyst**」= 需 Image Analyst 扩展模块许可，核心程序 Basic/Standard/Advanced 任一均可挂接；
- 「**Basic**」= 无需扩展模块，随核心程序 Basic 许可提供；
- 「**Basic / Spatial Analyst**」= 该工具有两种实现形态，Basic 级可用基础版本，部分增强参数需 Spatial Analyst；
- 「**仅 Basic**」= 极少数例外工具（创建彩色合成），仅需核心程序 Basic 许可。

**重要提示**：扩展模块许可必须由组织管理员分配给用户账户后，工具才在 Pro 中可用。本文不区分具体版本引入情况，若需用于采购决策，建议另行核对各版本新增工具的引入时间。

### 扩展模块定位差异

Esri 官方对两个扩展模块的定位有明确分工，这直接决定了工具分布：

- **Spatial Analyst**：面向栅格数据的通用处理与建模，涵盖分类数据（categorical data）。典型场景包括水文建模、距离（邻近）分析、栅格叠加适宜性建模、重分类、区域统计。工具箱结构稳定，Pro 2.x 至 3.7 工具集框架基本一致。
- **Image Analyst**：面向影像信息提取，服务于影像解译人员。核心能力包括影像分类与对象基影像分析（OBIA）、深度学习目标检测与像素分类、变化检测、多维分析、高光谱/多波段光谱分析、SAR 数据处理、动态视频影像（FMV）、立体测图与影像空间分析。工具箱在 Pro 3.x 期间扩展显著。

### 工具命名说明

工具名采用「中文名（英文名）」格式。中文名为 ArcGIS Pro 中文帮助文档中的正式名称；英文名为工具的系统内部名称（arcpy 调用名，如 `sa.DistanceAccumulation`）。栅格函数英文名与同名工具可能相同，本文在函数部分统一加"函数"后缀区分（如"距离累积函数"）。部分 3.4+ 新增工具中文文档翻译滞后，本文保留英文名并标注"中文名疑似需以实际版本为准"。

---

## 一、Spatial Analyst 工具箱（24 个工具集）

Spatial Analyst 扩展模块提供 24 个工具集、200 余工具，用于栅格（像元）数据与要素数据的空间分析与建模。以下按工具集逐一列出。

### 1.1 条件分析（Conditional）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 1 | 条件函数 | Con | 栅格 | 栅格 | **Spatial Analyst** |
| 2 | 选取函数 | Pick | 栅格 | 栅格 | **Spatial Analyst** |
| 3 | 设为空函数 | Set Null | 栅格 | 栅格 | **Spatial Analyst** |

**说明**：条件函数是地图代数的核心组件。`Con` 等价于 `Con(in_conditional_raster, in_true_raster, in_false_raster)` 表达式；`Pick` 按位置从输入栅格列表中取值；`Set Null` 将满足条件的像元置为 NoData，常用于数据掩膜。三者均有对应的栅格函数实现。

### 1.2 密度分析（Density）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 4 | 计算核密度比 | Calculate Kernel Density Ratio | 点/线要素 | 栅格 | **Spatial Analyst** |
| 5 | 核密度分析 | Kernel Density | 点/线要素 | 栅格 | **Spatial Analyst** |
| 6 | 线密度分析 | Line Density | 线要素 | 栅格 | **Spatial Analyst** |
| 7 | 点密度分析 | Point Density | 点要素 | 栅格 | **Spatial Analyst** |
| 8 | 栅格转加权点 | Raster To Weighted Point | 栅格 | 点要素（加权） | **Spatial Analyst** |
| 9 | 时空核密度 | Space Time Kernel Density | 点要素（含时间） | 栅格/多维栅格 | **Spatial Analyst** |
| 10 | 值百分位等值线 | Value Percentile Contour | 栅格 | 栅格（等值带） | **Spatial Analyst** |
| 11 | 体积百分位等值线 | Volume Percentile Contour | 栅格 | 栅格（等值带） | **Spatial Analyst** |

**关键核实**：密度分析工具集的 8 项工具（Pro 3.4 新增"计算核密度比"，将核密度结果除以某参考栅格得到比率）**输入为矢量要素、输出为栅格**，属"矢量→栅格"转换型分析工具，是本文与《矢量分析工具清单》的交叉地带。其中"栅格转加权点"输出为点要素，已在矢量清单中作为"矢量创建"类工具收录，此处仅作交叉引用。

**版本演进**：时空核密度（Space Time Kernel Density）为 Pro 2.3 引入，Pro 3.4 起支持以体素图层（Voxel Layer）在场景中可视化四百万级点位的时空密度结果。

### 1.3 距离分析（Distance）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 12 | 距离累积 | Distance Accumulation | 栅格/要素（源） | 距离栅格 | **Spatial Analyst** |
| 13 | 距离分配 | Distance Allocation | 栅格/要素（源） | 分配栅格 | **Spatial Analyst** |
| 14 | 最小成本廊道 | Least Cost Corridor | 两个距离累积栅格 | 廊道栅格 | **Spatial Analyst** |
| 15 | 最佳廊道连接 | Optimal Corridor Connections | 距离累积栅格 | 廊道连接栅格 | **Spatial Analyst** |
| 16 | 最佳路径为线 | Optimal Path As Line | 距离累积/分配栅格 + 目的地 | 线要素类 | **Spatial Analyst** |
| 17 | 最佳路径为栅格 | Optimal Path As Raster | 距离累积/分配栅格 + 目的地 | 路径栅格 | **Spatial Analyst** |
| 18 | 最佳区域连接 | Optimal Region Connections | 距离累积/分配栅格 | 连接线要素类 | **Spatial Analyst** |

**核心机制说明**：新版距离分析采用统一的"距离累积 + 垂直系数 + 水平系数"框架。`距离累积` 计算各像元到源的距离累积面（支持欧氏、成本、真实表面距离三种模式）；`距离分配` 输出各像元归属的最近源；`最小成本廊道` 与 `最佳廊道连接` 的区别在于前者输出两源间单一廊道，后者支持多源间成对廊道网络；`最佳路径为线` 与 `最佳路径为栅格` 是同一算法的两种输出形态，前者已在矢量清单收录。

**版本新增（Pro 3.4）**：距离累积与距离分配新增两种垂直系数选项——`Hiking Time`（根据坡度陡缓调整步行速度）与 `Bidirectional Hiking Time`（计算往返徒步的平均时间）。同时，距离累积、距离分配、最佳路径为线、最佳路径为栅格在使用测地线距离方法且数据位于 GCS 或圆柱投影时，可计算绕行全球的最短路径，不再将地图边缘视为障碍。

### 1.4 距离分析（旧版本）（Distance (Legacy)）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 19 | 廊道分析 | Corridor | 两个成本距离栅格 | 廊道栅格 | **Spatial Analyst** |
| 20 | 成本分配 | Cost Allocation | 栅格（源+成本） | 分配栅格 | **Spatial Analyst** |
| 21 | 成本回溯链接 | Cost Back Link | 栅格（源+成本） | 方向栅格 | **Spatial Analyst** |
| 22 | 成本连通性 | Cost Connectivity | 栅格（源+成本） | 连通性栅格 | **Spatial Analyst** |
| 23 | 成本距离 | Cost Distance | 栅格（源+成本） | 距离栅格 | **Spatial Analyst** |
| 24 | 成本路径 | Cost Path | 栅格（目的地+回溯链接） | 路径栅格 | **Spatial Analyst** |
| 25 | 成本路径折线 | Cost Path as Polyline | 栅格（路径） | 线要素类 | **Spatial Analyst** |
| 26 | 欧氏分配 | Euclidean Allocation | 栅格/要素（源） | 分配栅格 | **Spatial Analyst** |
| 27 | 欧氏反向 | Euclidean Back Direction | 栅格/要素（源） | 方向栅格 | **Spatial Analyst** |
| 28 | 欧氏方向 | Euclidean Direction | 栅格/要素（源） | 方向栅格 | **Spatial Analyst** |
| 29 | 欧氏距离 | Euclidean Distance | 栅格/要素（源） | 距离栅格 | **Spatial Analyst** |
| 30 | 路径距离 | Path Distance | 栅格（源+成本+表面） | 距离栅格 | **Spatial Analyst** |
| 31 | 路径距离分配 | Path Distance Allocation | 栅格（源+成本+表面） | 分配栅格 | **Spatial Analyst** |
| 32 | 路径距离回溯链接 | Path Distance Back Link | 栅格（源+成本+表面） | 方向栅格 | **Spatial Analyst** |

**重要提示**：以上 14 项工具属遗留工具集，采用早期距离算法，精度低于新版。Esri 官方建议新工程使用 1.3 中的新版工具。本文保留完整清单以满足"补全"要求，但**不建议新项目使用旧版工具**。其中"成本路径折线"输出为线要素类，已在矢量清单收录，此处交叉引用。

### 1.5 提取分析（Extraction）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 33 | 按属性提取 | Extract By Attributes | 栅格 | 栅格 | **Spatial Analyst** |
| 34 | 按圆提取 | Extract By Circle | 栅格 | 栅格 | **Spatial Analyst** |
| 35 | 按掩膜提取 | Extract By Mask | 栅格 + 栅格/要素（掩膜） | 栅格 | **Spatial Analyst** |
| 36 | 按点提取 | Extract By Points | 栅格 + 点要素 | 栅格 | **Spatial Analyst** |
| 37 | 按多边形提取 | Extract By Polygon | 栅格 + 面要素 | 栅格 | **Spatial Analyst** |
| 38 | 按矩形提取 | Extract By Rectangle | 栅格 | 栅格 | **Spatial Analyst** |
| 39 | 多值提取至点 | Extract Multi Values To Points | 栅格 + 点要素 | 表（点属性追加） | **Spatial Analyst** |
| 40 | 值提取至点 | Extract Values To Points | 栅格 + 点要素 | 点要素类（属性追加） | **Spatial Analyst** |
| 41 | 采样 | Sample | 栅格 + 点/线/面/像元 | 表/点要素类 | **Spatial Analyst** |

**交叉引用**：`多值提取至点`与`值提取至点`的输出主体为矢量要素类（属性表扩展）或表，已在矢量清单"栅格分析接口"类别中收录。`采样`工具在 Image Analyst 工具箱中亦有同名实现（输出表或点要素类），两处为不同工具。

### 1.6 概化（Generalization）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 42 | 聚合 | Aggregate | 栅格 | 栅格 | **Spatial Analyst** |
| 43 | 边界清理 | Boundary Clean | 栅格 | 栅格 | **Spatial Analyst** |
| 44 | 扩展 | Expand | 栅格 | 栅格 | **Spatial Analyst** |
| 45 | 众数滤波 | Majority Filter | 栅格 | 栅格 | **Spatial Analyst** |
| 46 | 蚕食 | Nibble | 栅格 | 栅格 | **Spatial Analyst** |
| 47 | 区域分组 | Region Group | 栅格 | 栅格 | **Spatial Analyst** |
| 48 | 收缩 | Shrink | 栅格 | 栅格 | **Spatial Analyst** |
| 49 | 细化 | Thin | 栅格 | 栅格 | **Spatial Analyst** |

**说明**：概化工具用于清理栅格中的小面积错误数据或概化细节。`Nibble` 用最近邻像元值替换选定像元，常用于修正错误分类的小图斑；`Boundary Clean` 平滑区域间边界；`Thin` 将线状栅格细化至单像元宽度，是栅格河网提取流程的关键步骤。以上工具均有同名栅格函数实现，且 Nibble、Region Group、Shrink、Boundary Clean 函数明确要求 Spatial Analyst 许可。

### 1.7 地下水分析（Groundwater）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 50 | 达西流 | Darcy Flow | 栅格（水头+孔隙率等） | 栅格（流速场） | **Spatial Analyst** |
| 51 | 达西速度 | Darcy Velocity | 栅格（水头+孔隙率等） | 栅格（速度分量） | **Spatial Analyst** |
| 52 | 粒子追踪 | Particle Track | 栅格（速度场） | 栅格/点（轨迹） | **Spatial Analyst** |
| 53 | 孔隙扩散 | Porous Puff | 栅格（速度场+扩散参数） | 栅格（浓度分布） | **Spatial Analyst** |

**说明**：地下水分析工具用于对地下水流中的成分构建对流-扩散模型，典型应用为判断化学泄漏是否可能污染饮用水井。四个工具需按顺序串联使用：达西流 → 达西速度 → 粒子追踪 → 孔隙扩散。

### 1.8 水文分析（Hydrology）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 54 | 盆域 | Basin | 栅格（流向） | 栅格（流域） | **Spatial Analyst** |
| 55 | 派生连续流 | Derive Continuous Flow | 栅格（DEM） | 栅格（连续流） | **Spatial Analyst** |
| 56 | 派生流作为线 | Derive Stream As Line | 栅格（DEM） | 线要素类 | **Spatial Analyst** |
| 57 | 派生流作为栅格 | Derive Stream As Raster | 栅格（DEM） | 栅格（河网） | **Spatial Analyst** |
| 58 | 填洼 | Fill | 栅格（DEM） | 栅格（填洼后 DEM） | **Spatial Analyst** |
| 59 | 流量 | Flow Accumulation | 栅格（流向） | 栅格（累积流量） | **Spatial Analyst** |
| 60 | 流向 | Flow Direction | 栅格（DEM） | 栅格（流向） | **Spatial Analyst** |
| 61 | 流动距离 | Flow Distance | 栅格（流向+距离类型） | 栅格（流动距离） | **Spatial Analyst** |
| 62 | 水流长度 | Flow Length | 栅格（流向） | 栅格（水流长度） | **Spatial Analyst** |
| 63 | 生成溃口线 | Generate Breach Lines | 栅格（DEM） | 线要素类 | **Spatial Analyst** |
| 64 | 测地线流向 | Geodesic Flow Direction | 栅格（DEM，测地线） | 栅格（流向） | **Spatial Analyst** |
| 65 | 定位洼地 | Locate Sinks | 栅格（DEM） | 点/栅格（洼地位置） | **Spatial Analyst** |
| 66 | 汇 | Sink | 栅格（DEM） | 栅格（汇） | **Spatial Analyst** |
| 67 | 捕捉倾泻点 | Snap Pour Point | 栅格（倾泻点+累积流量） | 栅格（修正后倾泻点） | **Spatial Analyst** |
| 68 | 存储容量 | Storage Capacity | 栅格（DEM+水位） | 栅格/表（库容曲线） | **Spatial Analyst** |
| 69 | 河流链 | Stream Link | 栅格（河网+流向） | 栅格（河链分段） | **Spatial Analyst** |
| 70 | 河网分级 | Stream Order | 栅格（河网+流向） | 栅格（分级） | **Spatial Analyst** |
| 71 | 栅格河网矢量化 | Stream To Feature | 栅格（河网+流向） | 线要素类 | **Spatial Analyst** |
| 72 | 验证流向 | Validate Flow Direction | 栅格（流向） | 栅格（验证结果） | **Spatial Analyst** |
| 73 | 集水区 | Watershed | 栅格（流向+倾泻点） | 栅格（汇水区） | **Spatial Analyst** |

**关键核实**：水文分析工具集是"栅格→栅格"与"栅格→矢量"混合最集中的区域。`派生流作为线`、`生成溃口线`、`栅格河网矢量化`三项输出为矢量，已在矢量清单收录，此处交叉引用。`派生连续流`、`测地线流向`、`生成溃口线`为 Pro 2.8+ 新增工具，旧文档常遗漏。

**标准 workflow**：Fill → Flow Direction → Flow Accumulation → 设定阈值提取河网 → Stream Link → Watershed / Stream To Feature。Pro 3.4 起 `派生流作为栅格` 可在 Map Viewer 中直接指定 DEM 生成河网。

### 1.9 插值分析（Interpolation）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 74 | 反距离权重法 | IDW | 点要素 | 栅格（连续表面） | **Spatial Analyst** |
| 75 | 克里金法 | Kriging | 点要素 | 栅格（连续表面+预测误差） | **Spatial Analyst** |
| 76 | 自然邻域法 | Natural Neighbor | 点要素 | 栅格（连续表面） | **Spatial Analyst** |
| 77 | 样条函数法 | Spline | 点要素 | 栅格（连续表面） | **Spatial Analyst** |
| 78 | 含障碍的样条函数 | Spline With Barriers | 点要素 + 线/面（障碍） | 栅格（连续表面） | **Spatial Analyst** |
| 79 | 地形转栅格 | Topo To Raster | 点/线/面/等值线要素 | 栅格（水文一致 DEM） | **Spatial Analyst** |
| 80 | 依据文件实现地形转栅格 | Topo To Raster By File | 点/线/面/等值线要素 | 栅格（水文一致 DEM） | **Spatial Analyst** |
| 81 | 趋势面法 | Trend | 点要素 | 栅格（趋势面） | **Spatial Analyst** |

**说明**：插值工具集以矢量点（及线、面、等值线）为输入、栅格连续表面为输出，属"矢量→栅格"型工具。`地形转栅格` 与 `依据文件实现地形转栅格` 采用基于地形学的插值算法，强制生成水文一致的 DEM（无洼地、河网连贯），优于普通插值方法用于水文建模。`克里金法` 输出包含预测栅格与预测标准误差栅格两个结果。

**与 Geostatistical Analyst 的分工**：本文不收录 Geostatistical Analyst 工具箱（其输出以矢量预测面为主，已在矢量清单收录）。若需地统计高级建模（泛克里金、协同克里金、指示克里金、概率克里金、半变异函数建模），请参照矢量清单的对应章节。

### 1.10 局部分析（Local）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 82 | 像元统计 | Cell Statistics | 多个栅格 | 栅格（统计量） | **Spatial Analyst** |
| 83 | 合并 | Combine | 多个栅格 | 栅格（唯一组合编码） | **Spatial Analyst** |
| 84 | 等于频数 | Equal To Frequency | 多个栅格 | 栅格（相等次数） | **Spatial Analyst** |
| 85 | 大于频数 | Greater Than Frequency | 多个栅格 | 栅格（大于次数） | **Spatial Analyst** |
| 86 | 最高位置 | Highest Position | 多个栅格 | 栅格（最高值来源索引） | **Spatial Analyst** |
| 87 | 小于频数 | Less Than Frequency | 多个栅格 | 栅格（小于次数） | **Spatial Analyst** |
| 88 | 最低位置 | Lowest Position | 多个栅格 | 栅格（最低值来源索引） | **Spatial Analyst** |
| 89 | 频数取值 | Popularity | 多个栅格 | 栅格（众数） | **Spatial Analyst** |
| 90 | 等级 | Rank | 多个栅格 | 栅格（排序等级） | **Spatial Analyst** |

**说明**：局部分析的核心特征是"输出栅格每个位置的值 = 该位置所有输入栅格对应像元值的函数"。`像元统计` 支持众数、最大值、平均值、中值、最小值、少数、百分位数、范围、标准差、总和、变异度等统计量；`合并` 将多个输入栅格的像元值组合编码为唯一值，是分类叠加的常用手段。

### 1.11 地图代数（Map Algebra）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 91 | 栅格计算器 | Raster Calculator | 栅格 + 表达式 | 栅格 | **Spatial Analyst** |

**说明**：地图代数是通过代数语言创建表达式执行空间分析的方法。`栅格计算器` 是唯一工具，但支撑全部数学、逻辑、条件、三角函数运算。本文在 1.12—1.16 中列出的数学工具均可在栅格计算器中以表达式形式调用，两者功能等价，区别仅在于工具形式（对话框参数化）与表达式形式（Python/代数语法）。

**许可交叉**：`Raster Calculator` 函数在 Image Analyst 或 Spatial Analyst 许可下可用；但基础算术函数（Plus、Minus、Times、Divide 等）在 ArcGIS Pro Basic 下即可使用。

### 1.12 数学分析：常规（Math: General）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 92 | 绝对值 | Abs | 栅格 | 栅格 | **Basic**（函数）/ Spatial Analyst（工具） |
| 93 | 除 | Divide | 两个栅格 | 栅格 | 同上 |
| 94 | 自然指数 | Exp | 栅格 | 栅格 | 同上 |
| 95 | 常用指数（10 为底） | Exp10 | 栅格 | 栅格 | 同上 |
| 96 | 2 为底指数 | Exp2 | 栅格 | 栅格 | 同上 |
| 97 | 转为浮点型 | Float | 栅格 | 栅格 | 同上 |
| 98 | 转为整型 | Int | 栅格 | 栅格 | 同上 |
| 99 | 自然对数 | Ln | 栅格 | 栅格 | 同上 |
| 100 | 常用对数 | Log10 | 栅格 | 栅格 | 同上 |
| 101 | 2 为底对数 | Log2 | 栅格 | 栅格 | 同上 |
| 102 | 减 | Minus | 两个栅格 | 栅格 | 同上 |
| 103 | 求模 | Mod | 两个栅格 | 栅格 | 同上 |
| 104 | 取反 | Negate | 栅格 | 栅格 | 同上 |
| 105 | 加 | Plus | 两个栅格 | 栅格 | 同上 |
| 106 | 幂 | Power | 两个栅格 | 栅格 | 同上 |
| 107 | 下舍入 | Round Down | 栅格 | 栅格 | 同上 |
| 108 | 上舍入 | Round Up | 栅格 | 栅格 | 同上 |
| 109 | 平方 | Square | 栅格 | 栅格 | 同上 |
| 110 | 平方根 | Square Root | 栅格 | 栅格 | 同上 |
| 111 | 乘 | Times | 两个栅格 | 栅格 | 同上 |

**许可说明**：常规数学工具集的 20 项工具存在"双轨许可"——作为栅格函数时随 ArcGIS Pro Basic 提供；作为地理处理工具时属 Spatial Analyst 工具箱，需扩展许可。实际使用中两种形态功能一致，本文统一标注为「Basic（函数）/ Spatial Analyst（工具）」。

### 1.13 数学分析：按位运算（Math: Bitwise）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 112 | 按位与 | Bitwise And | 两个栅格 | 栅格 | **Basic / Spatial Analyst** |
| 113 | 按位左移 | Bitwise Left Shift | 两个栅格 | 栅格 | 同上 |
| 114 | 按位非 | Bitwise Not | 栅格 | 栅格 | 同上 |
| 115 | 按位或 | Bitwise Or | 两个栅格 | 栅格 | 同上 |
| 116 | 按位右移 | Bitwise Right Shift | 两个栅格 | 栅格 | 同上 |
| 117 | 按位异或 | Bitwise XOr | 两个栅格 | 栅格 | 同上 |

### 1.14 数学分析：逻辑运算（Math: Logical）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 118 | 布尔与 | Boolean And | 两个栅格 | 栅格 | **Basic / Spatial Analyst** |
| 119 | 布尔非 | Boolean Not | 栅格 | 栅格 | 同上 |
| 120 | 布尔或 | Boolean Or | 两个栅格 | 栅格 | 同上 |
| 121 | 布尔异或 | Boolean XOr | 两个栅格 | 栅格 | 同上 |
| 122 | 组合与 | Combinatorial And | 两个栅格 | 栅格 | 同上 |
| 123 | 组合或 | Combinatorial Or | 两个栅格 | 栅格 | 同上 |
| 124 | 组合异或 | Combinatorial XOr | 两个栅格 | 栅格 | 同上 |
| 125 | 差异 | Diff | 两个栅格 | 栅格 | 同上 |
| 126 | 等于 | Equal To | 两个栅格 | 栅格 | 同上 |
| 127 | 大于 | Greater Than | 两个栅格 | 栅格 | 同上 |
| 128 | 大于等于 | Greater Than Or Equal | 两个栅格 | 栅格 | 同上 |
| 129 | 在列表中 | In List | 栅格 + 值列表 | 栅格 | 同上 |
| 130 | 为空 | Is Null | 栅格 | 栅格 | 同上 |
| 131 | 小于 | Less Than | 两个栅格 | 栅格 | 同上 |
| 132 | 小于等于 | Less Than Or Equal | 两个栅格 | 栅格 | 同上 |
| 133 | 不等于 | Not Equal | 两个栅格 | 栅格 | 同上 |
| 134 | 条件测试 | Test | 栅格 + 条件 | 栅格 | 同上 |
| 135 | 求余覆盖 | Over | 两个栅格 | 栅格 | 同上 |

### 1.15 数学分析：三角函数（Math: Trigonometric）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 136 | 反余弦 | ACos | 栅格 | 栅格 | **Basic / Spatial Analyst** |
| 137 | 反双曲余弦 | ACosH | 栅格 | 栅格 | 同上 |
| 138 | 反正弦 | ASin | 栅格 | 栅格 | 同上 |
| 139 | 反双曲正弦 | ASinH | 栅格 | 栅格 | 同上 |
| 140 | 反正切 | ATan | 栅格 | 栅格 | 同上 |
| 141 | ATan2 | ATan2 | 两个栅格 | 栅格 | 同上 |
| 142 | 反双曲正切 | ATanH | 栅格 | 栅格 | 同上 |
| 143 | 余弦 | Cos | 栅格 | 栅格 | 同上 |
| 144 | 双曲余弦 | CosH | 栅格 | 栅格 | 同上 |
| 145 | 正弦 | Sin | 栅格 | 栅格 | 同上 |
| 146 | 双曲正弦 | SinH | 栅格 | 栅格 | 同上 |
| 147 | 正切 | Tan | 栅格 | 栅格 | 同上 |
| 148 | 双曲正切 | TanH | 栅格 | 栅格 | 同上 |

### 1.16 多元分析（Multivariate）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 149 | 波段集统计 | Band Collection Statistics | 多波段栅格 | 表（协方差/相关矩阵） | **Spatial Analyst** |
| 150 | 类别概率 | Class Probability | 多波段栅格 + 特征文件 | 栅格（概率） | **Spatial Analyst** |
| 151 | 创建特征文件 | Create Signatures | 多波段栅格 + 训练样本 | 特征文件（.gsg） | **Spatial Analyst** |
| 152 | 树状图 | Dendrogram | 特征文件 | 表/图形（聚类树） | **Spatial Analyst** |
| 153 | 编辑特征文件 | Edit Signatures | 特征文件 | 特征文件 | **Spatial Analyst** |
| 154 | Iso 聚类 | Iso Cluster | 多波段栅格 | 特征文件 | **Spatial Analyst** |
| 155 | Iso 聚类非监督分类 | Iso Cluster Unsupervised Classification | 多波段栅格 | 栅格（分类） | **Spatial Analyst** |
| 156 | 最大似然法分类 | Maximum Likelihood Classification | 多波段栅格 + 特征文件 | 栅格（分类） | **Spatial Analyst** |
| 157 | 主成分分析 | Principal Components | 多波段栅格 | 栅格（主成分）+ 表 | **Spatial Analyst** |

**说明**：多元分析提供两种分类范式——监督分类（创建特征文件 → 最大似然法分类）与非监督分类（Iso 聚类）。`主成分分析` 输出主成分栅格及特征值表，常用于数据降维与噪声分离。此工具集是 Image Analyst 分类与模式识别工具集的前身，新工程建议优先使用 Image Analyst 提供的基于 .ecd 分类器的工具链。

### 1.17 邻域分析（Neighborhood）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 158 | 块统计 | Block Statistics | 栅格 | 栅格（不重叠邻域） | **Spatial Analyst** |
| 159 | 滤波器 | Filter | 栅格 | 栅格（低通/高通） | **Spatial Analyst** |
| 160 | 焦点流 | Focal Flow | 栅格（流向） | 栅格（焦点流） | **Spatial Analyst** |
| 161 | 焦点统计 | Focal Statistics | 栅格 | 栅格（移动邻域） | **Spatial Analyst** |
| 162 | 线统计 | Line Statistics | 线要素 | 栅格（统计量） | **Spatial Analyst** |
| 163 | 点统计 | Point Statistics | 点要素 | 栅格（统计量） | **Spatial Analyst** |

**说明**：邻域分析在输入栅格上移动指定邻域（矩形、圆形、环形、楔形、像元列表），计算每个位置的输出值。邻域分重叠（焦点统计、滤波器）与不重叠（块统计）两类。`线统计` 与 `点统计` 输入为矢量要素，属"矢量→栅格"型工具，是本文与矢量清单的交叉点。

### 1.18 叠加分析（Overlay）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 164 | 模糊分类 | Fuzzy Classification | 多个栅格 + 模糊隶属度 | 栅格（模糊分类） | **Spatial Analyst** |
| 165 | 模糊叠加 | Fuzzy Overlay | 多个模糊栅格 | 栅格（模糊叠加） | **Spatial Analyst** |
| 166 | 定位区域 | Locate Regions | 栅格（适宜性） | 栅格/面要素（最佳区域） | **Spatial Analyst** |
| 167 | 加权叠加 | Weighted Overlay | 多个栅格 + 权重 | 栅格（适宜性） | **Spatial Analyst** |
| 168 | 加权总和 | Weighted Sum | 多个栅格 + 权重 | 栅格（加权和） | **Spatial Analyst** |

**关键核实**：叠加分析工具集是适宜性建模（Suitability Modeling）的核心。`加权叠加` 要求输入栅格统一到共同测量尺度并按重要性赋权；`加权总和` 逐像元加权求和，不要求统一尺度。`定位区域` 可输出栅格或面要素，输出为面时已在矢量清单收录。

**许可交叉**：`Weighted Overlay` 与 `Weighted Sum` 的栅格函数实现要求 Spatial Analyst 许可；而 `加权总和` 作为 Image Analyst 工具箱工具时，同样需 Image Analyst 许可。两者算法一致，属两扩展模块的功能重叠区。

### 1.19 栅格创建（Raster Creation）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 169 | 创建常量栅格 | Create Constant Raster | 常量值 + 范围 | 栅格 | **Spatial Analyst** |
| 170 | 创建正态栅格 | Create Normal Raster | 均值+标准差+范围 | 栅格（正态分布随机值） | **Spatial Analyst** |
| 171 | 创建随机栅格 | Create Random Raster | 分布参数+范围 | 栅格（随机数） | **Spatial Analyst** |

### 1.20 重分类（Reclass）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 172 | 查找表 | Lookup | 栅格 + 字段 | 栅格（字段值重映射） | **Spatial Analyst** |
| 173 | 使用 ASCII 文件重分类 | Reclass By ASCII File | 栅格 + ASCII 映射表 | 栅格 | **Spatial Analyst** |
| 174 | 使用表重分类 | Reclass By Table | 栅格 + 映射表 | 栅格 | **Spatial Analyst** |
| 175 | 重分类 | Reclassify | 栅格 + 重映射规则 | 栅格 | **Spatial Analyst** |
| 176 | 按函数重缩放 | Rescale By Function | 栅格 + 变换函数 | 栅格（0–1 连续值） | **Spatial Analyst** |
| 177 | 分割 | Slice | 栅格 + 分割数/方法 | 栅格（分级） | **Spatial Analyst** |

**说明**：重分类是将输入像元值重分类或替换为替代值的方法集合。`按函数重缩放` 将值按指定数学函数（如 MSSmall、MSLarge、Near、Very、Fuzzy 函数族）变换到 0–1 连续区间，是模糊叠加与加权叠加的前置步骤。`分割` 按等面积、等间隔、自然断点、几何间隔等方法将连续值切分为指定级数。

### 1.21 影像分割和分类（Segmentation and Classification）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 178 | 分类栅格 | Classify Raster | 栅格 + .ecd 分类器 | 栅格（分类） | **Spatial Analyst** |
| 179 | 计算混淆矩阵 | Compute Confusion Matrix | 分类栅格 + 参考数据 | 表（精度指标） | **Spatial Analyst** |
| 180 | 计算分割影像属性 | Compute Segment Attributes | 分割栅格 | 栅格/表（属性） | **Spatial Analyst** |
| 181 | 创建精度评估点 | Create Accuracy Assessment Points | 分类栅格 | 点要素类 | **Spatial Analyst** |
| 182 | 从种子点生成训练样本 | Generate Training Samples From Seed Points | 栅格/要素（种子点） | 训练样本数据集 | **Spatial Analyst** |
| 183 | 检查训练样本 | Inspect Training Samples | 训练样本 + .ecd | 栅格/训练样本（精度） | **Spatial Analyst** |
| 184 | 线性光谱解混 | Linear Spectral Unmixing | 多波段栅格 | 栅格（丰度） | **Spatial Analyst** |
| 185 | 移除栅格分割块伪影 | Remove Raster Segment Tiling Artifacts | 分割栅格 | 栅格（修正后） | **Spatial Analyst** |
| 186 | 均值漂移影像分割 | Segment Mean Shift | 多波段栅格 | 栅格（分割） | **Spatial Analyst** |
| 187 | 训练 Iso 聚类分类器 | Train Iso Cluster Classifier | 训练样本 | .ecd 分类器定义文件 | **Spatial Analyst** |
| 188 | 训练 K 最近邻分类器 | Train K-Nearest Neighbor Classifier | 训练样本 | .ecd 分类器定义文件 | **Spatial Analyst** |
| 189 | 训练最大似然法分类器 | Train Maximum Likelihood Classifier | 训练样本 | .ecd 分类器定义文件 | **Spatial Analyst** |
| 190 | 训练随机树分类器 | Train Random Trees Classifier | 训练样本 | .ecd 分类器定义文件 | **Spatial Analyst** |
| 191 | 训练随机树回归模型 | Train Random Trees Regression Model | 训练样本 | .ecd 回归模型文件 | **Spatial Analyst** |
| 192 | 训练支持向量机分类器 | Train Support Vector Machine Classifier | 训练样本 | .ecd 分类器定义文件 | **Spatial Analyst** |
| 193 | 更新精度评估点 | Update Accuracy Assessment Points | 精度评估点 + 分类栅格 | 点要素类（更新后） | **Spatial Analyst** |
| 194 | 为深度学习导出训练数据 | Export Training Data For Deep Learning | 栅格 + 标注矢量/栅格 | 影像片文件夹 + 元数据 | **Spatial Analyst** |

**关键核实**：此工具集与 Image Analyst 的"分类和模式识别"工具集高度重叠（工具名完全一致），属两扩展模块的功能交集。`分类栅格` 工具要求 .ecd 文件中的输入与生成该文件时使用的输入严格匹配，否则报错。`为深度学习导出训练数据` 是连接传统遥感处理与深度学习的桥梁工具。

### 1.22 太阳辐射（Solar Radiation）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 195 | 区域太阳辐射 | Area Solar Radiation | 栅格（DEM） | 栅格（日照量） | **Spatial Analyst** |
| 196 | 要素太阳辐射 | Feature Solar Radiation | 点/面要素 + DEM | 表/要素（日照量） | **Spatial Analyst** |
| 197 | 点太阳辐射 | Point Solar Radiation | 点坐标/表 + DEM | 表（辐射能量） | **Spatial Analyst** |
| 198 | 栅格太阳辐射 | Raster Solar Radiation | 栅格（DEM） | 栅格（日照量） | **Spatial Analyst** |
| 199 | 太阳辐射图 | Solar Radiation Graphics | 点坐标 + DEM | 图形（视域图/太阳图/星空图） | **Spatial Analyst** |

**版本演进（Pro 3.4）**：`要素太阳辐射` 与 `栅格太阳辐射` 新增 `Sun Map Grid Level` 参数控制计算速度与精度，并增强 GPU 处理支持以提升性能与可扩展性。太阳辐射工具支持地球与月球双天体分析模式。

### 1.23 表面分析（Surface）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 200 | 添加表面信息 | Add Surface Information | 要素 + 栅格表面 | 要素类（属性追加） | **Spatial Analyst** / 3D Analyst |
| 201 | 坡向 | Aspect | 栅格（DEM） | 栅格（坡向） | **Spatial Analyst** / 3D Analyst |
| 202 | 等值线 | Contour | 栅格（DEM） | 线要素类 | **Spatial Analyst** / 3D Analyst |
| 203 | 等值线序列 | Contour List | 栅格（DEM） | 线要素类 | **Spatial Analyst** / 3D Analyst |
| 204 | 含障碍的等值线 | Contour With Barriers | 栅格（DEM）+ 障碍要素 | 线要素类 | **Spatial Analyst** / 3D Analyst |
| 205 | 曲率 | Curvature | 栅格（DEM） | 栅格（曲率+剖面/平面曲率） | **Spatial Analyst** / 3D Analyst |
| 206 | 填挖方 | Cut Fill | 两个栅格表面 | 栅格（体积变化） | **Spatial Analyst** / 3D Analyst |
| 207 | 要素保留平滑 | Feature Preserving Smoothing | 栅格（DEM） | 栅格（平滑后表面） | **Spatial Analyst** |
| 208 | 测地线视域 | Geodesic Viewshed | 栅格（DEM）+ 观察点要素 | 栅格（可视性） | **Spatial Analyst** |
| 209 | 地貌类型 | Geomorphon Landforms | 栅格（DEM） | 栅格（地貌类型） | **Spatial Analyst** |
| 210 | 山体阴影 | Hillshade | 栅格（DEM） | 栅格（晕渲） | **Spatial Analyst** / 3D Analyst |
| 211 | 插值 Shape | Interpolate Shape | 要素 + 栅格表面 | 3D 要素类 | **Spatial Analyst** / 3D Analyst |
| 212 | 多尺度表面偏差 | Multiscale Surface Deviation | 栅格（DEM） | 栅格（偏差） | **Spatial Analyst** |
| 213 | 多尺度表面差异 | Multiscale Surface Difference | 栅格（DEM） | 栅格（差异） | **Spatial Analyst** |
| 214 | 多尺度表面百分位数 | Multiscale Surface Percentile | 栅格（DEM） | 栅格（百分位数） | **Spatial Analyst** |
| 215 | 视点分析 | Observer Points | 栅格（DEM）+ 观察点 | 栅格（可见观察点） | **Spatial Analyst** / 3D Analyst |
| 216 | 坡度 | Slope | 栅格（DEM） | 栅格（坡度） | **Spatial Analyst** / 3D Analyst |
| 217 | 表面面积比 | Surface Area Ratio | 栅格（DEM） | 栅格（面积比） | **Spatial Analyst** |
| 218 | 表面参数 | Surface Parameters | 栅格（DEM） | 栅格（坡向/坡度/曲率） | **Spatial Analyst** |
| 219 | 顶帽变换 | Top Hat Transform | 栅格（DEM） | 栅格（空间结构） | **Spatial Analyst** |
| 220 | 地形位置指数 | Topographic Position Index | 栅格（DEM） | 栅格（TPI） | **Spatial Analyst** |
| 221 | 视域 | Viewshed | 栅格（DEM）+ 观察点要素 | 栅格（可视性） | **Spatial Analyst** / 3D Analyst |
| 222 | 可见性 | Visibility | 栅格（DEM）+ 观察点要素 | 栅格（可视性/可见观察点） | **Spatial Analyst** / 3D Analyst |

**关键核实**：表面分析工具集在 Pro 3.x 中统一归属 Spatial Analyst 工具箱，同时标注"需 3D Analyst 许可"（3D Analyst 工具箱内有 Raster Surface 子集，含 Aspect、Contour、Contour List、Contour With Barriers、Curvature、Cut Fill、Hillshade、Slope、Surface Parameters 九项）。因此该工具集是 Spatial Analyst 与 3D Analyst 的功能重叠区。

**版本新增（Pro 3.4）**：`要素保留平滑` 在去除小尺度表面噪声（噪声）的同时保留有意义的地貌特征；`多尺度表面偏差`、`多尺度表面差异`、`多尺度表面百分位数` 用于识别栅格表面在多空间尺度上的特定地貌特征。四者在 Map Viewer 中亦有对应实现并获新参数增强。

**交叉引用**：`等值线`、`等值线序列`、`含障碍的等值线`输出线要素类；`添加表面信息`与`插值 Shape`输出要素类（属性追加或 3D 化），已在矢量清单收录。`测地线视域`与`视域`输出栅格（可视性栅格），属本文收录范围；而 3D Analyst 的 Line Of Sight 输出 3D 线要素，已在矢量清单收录。

### 1.24 区域分析（Zonal）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 223 | 面积制表 | Tabulate Area | 区域栅格/要素 + 值栅格 | 表（面积交叉表） | **Spatial Analyst** |
| 224 | 区域特征描述 | Zonal Characterization | 区域栅格/要素 + 值栅格 | 栅格（特征） | **Spatial Analyst** |
| 225 | 区域填充 | Zonal Fill | 区域栅格（含 NoData 区） | 栅格（填充后） | **Spatial Analyst** |
| 226 | 区域几何 | Zonal Geometry | 区域栅格 | 栅格（几何属性） | **Spatial Analyst** |
| 227 | 区域几何（以表格显示） | Zonal Geometry As Table | 区域栅格/要素 | 表（几何属性） | **Spatial Analyst** |
| 228 | 区域直方图 | Zonal Histogram | 区域栅格/要素 + 值栅格 | 表（直方图） | **Spatial Analyst** |
| 229 | 分区统计 | Zonal Statistics | 区域栅格/要素 + 值栅格 | 栅格（统计量） | **Spatial Analyst** |
| 230 | 分区统计（以表格显示） | Zonal Statistics As Table | 区域栅格/要素 + 值栅格 | 表（统计量） | **Spatial Analyst** |

**说明**：区域分析对属于每个输入区域的所有像元执行分析。区域可定义为具有特定值的单个区域，也可由具有相同值的多个断开元素组成；区域可由栅格（须为整型）或要素数据集（须具整型或字符串属性字段）定义。`面积制表` 是土地利用变化、景观格局指数计算的基础工具。

**交叉引用**：`区域几何（以表格显示）`、`区域直方图`、`分区统计（以表格显示）`、`面积制表`输出为表，已在矢量清单"分区统计"类别中作交叉引用注明。

---

## 二、Image Analyst 工具箱（15 个工具集）

Image Analyst 扩展模块面向影像信息提取，工具按功能相关性分为 15 个工具集。其中数学分析、地图代数、提取分析、插值分析、叠加分析、统计分析、表面分析与 Spatial Analyst 存在功能重叠，本文在对应处注明差异。

### 2.1 变化检测（Change Detection）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 1 | 使用 CCDC 分析变化 | Analyze Changes Using CCDC | 多维栅格（时序影像） | 变化分析栅格（模型结果） | **Image Analyst** |
| 2 | 使用 LandTrendr 分析变化 | Analyze Changes Using LandTrendr | 多维栅格（时序影像） | 变化分析栅格（模型结果） | **Image Analyst** |
| 3 | 计算变化栅格 | Compute Change Raster | 两个栅格数据集 | 栅格（差异） | **Image Analyst** |
| 4 | 使用变化分析栅格检测变化 | Detect Change Using Change Analysis Raster | 变化分析栅格（CCDC/LandTrendr 输出） | 栅格（像素变化信息） | **Image Analyst** |

**说明**：变化检测工具集提供两类方法。① **代数/分类差异法**：`计算变化栅格` 直接计算两时相栅格的绝对、相对、分类或光谱差异，方法简单但受时相、大气条件影响大。② **时序轨迹法**：`使用 CCDC 分析变化` 基于连续变化检测与分类（Continuous Change Detection and Classification）算法，逐像元拟合时序轨迹并识别变化拐点；`使用 LandTrendr 分析变化` 基于 Landsat 干扰与恢复趋势检测（LandTrendr）算法；两者均输出包含模型参数的变化分析栅格，再经 `使用变化分析栅格检测变化` 提取具体变化信息。时序方法对多时相数据（通常 ≥ 6 期）效果显著优于两时相差异法。

### 2.2 分类和模式识别（Classification and Pattern Recognition）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 5 | 分类栅格 | Classify Raster | 栅格 + .ecd 分类器 | 栅格（分类） | **Image Analyst** |
| 6 | 使用光谱对栅格进行分类 | Classify Raster Using Spectra | 多波段栅格 + 点要素类/.json 光谱 | 栅格（分类） | **Image Analyst** |
| 7 | 计算混淆矩阵 | Compute Confusion Matrix | 分类栅格 + 参考数据 | 表（Kappa/IoU/总体精度） | **Image Analyst** |
| 8 | 计算分割影像属性 | Compute Segment Attributes | 分割栅格（单波段或 3 波段 8 位） | 栅格/表（属性） | **Image Analyst** |
| 9 | 创建精度评估点 | Create Accuracy Assessment Points | 分类栅格 | 点要素类 | **Image Analyst** |
| 10 | 从种子点生成训练样本 | Generate Training Samples From Seed Points | 栅格/要素（种子点） | 训练样本数据集 | **Image Analyst** |
| 11 | 检查训练样本 | Inspect Training Samples | 训练样本 + .ecd | 栅格/训练样本（精度分数） | **Image Analyst** |
| 12 | 线性光谱解混 | Linear Spectral Unmixing | 多波段栅格 | 栅格（各类型分数丰度） | **Image Analyst** |
| 13 | 使用回归模型预测 | Predict Using Regression Model | 栅格 + 随机树回归模型 | 栅格（预测值） | **Image Analyst** |
| 14 | 移除栅格分割块伪影 | Remove Raster Segment Tiling Artifacts | 分割栅格 | 栅格（修正后） | **Image Analyst** |
| 15 | 均值漂移影像分割 | Segment Mean Shift | 多波段栅格 | 栅格（分割） | **Image Analyst** |
| 16 | 训练 Iso 聚类分类器 | Train Iso Cluster Classifier | 训练样本 | .ecd 分类器定义文件 | **Image Analyst** |
| 17 | 训练 K 最近邻分类器 | Train K-Nearest Neighbor Classifier | 训练样本 | .ecd 分类器定义文件 | **Image Analyst** |
| 18 | 训练最大似然法分类器 | Train Maximum Likelihood Classifier | 训练样本 | .ecd 分类器定义文件 | **Image Analyst** |
| 19 | 训练随机树分类器 | Train Random Trees Classifier | 训练样本 | .ecd 分类器定义文件 | **Image Analyst** |
| 20 | 训练随机树回归模型 | Train Random Trees Regression Model | 训练样本 | .ecd 回归模型文件 | **Image Analyst** |
| 21 | 训练支持向量机分类器 | Train Support Vector Machine Classifier | 训练样本 | .ecd 分类器定义文件 | **Image Analyst** |
| 22 | 更新精度评估点 | Update Accuracy Assessment Points | 精度评估点 + 分类栅格 | 点要素类（更新后） | **Image Analyst** |

**说明**：此工具集与 Spatial Analyst 的"影像分割和分类"工具集工具名完全一致（21 项中的 20 项重叠，`使用回归模型预测` 与 `使用光谱对栅格进行分类` 为 Image Analyst 独有补充）。完整分类工作流为：生成训练样本 → 训练分类器（得到 .ecd）→ 分类栅格 → 创建精度评估点 → 计算混淆矩阵。

**精度指标**：`计算混淆矩阵` 输出混淆矩阵（含漏分误差与错分误差），并派生一致性 Kappa 指数、交并比（IoU）与总体精度。`检查训练样本` 通过交叉验证评估单个训练样本精度，输出含错分类别值的栅格与带精度分数的训练样本数据集。

**交叉引用**：`创建精度评估点`、`更新精度评估点`输出点要素类，已在矢量清单收录。

### 2.3 深度学习（Deep Learning）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 23 | 使用深度学习分类对象 | Classify Objects Using Deep Learning | 栅格 + 可选要素类 | 要素类/表（对象分类标注） | **Image Analyst** |
| 24 | 使用深度学习分类像素 | Classify Pixels Using Deep Learning | 栅格 | 栅格（像素分类，类地图） | **Image Analyst** |
| 25 | 计算对象检测的精度 | Compute Accuracy For Object Detection | 检测对象 + 地面真实数据 | 表（精度指标） | **Image Analyst** |
| 26 | 计算像素分类的精度 | Compute Accuracy For Pixel Classification | 像素分类结果 + 地面真实数据 | 表（混淆矩阵/IoU） | **Image Analyst** |
| 27 | 使用深度学习检测变化 | Detect Change Using Deep Learning | 两个栅格 | 栅格（变化） | **Image Analyst** |
| 28 | 检测控制点 | Detect Keypoints | 镶嵌数据集 | 点要素类/表（控制点） | **Image Analyst** |
| 29 | 使用深度学习检测对象 | Detect Objects Using Deep Learning | 栅格 | 要素类（边界框/面/中心点） | **Image Analyst** |
| 30 | 导出训练数据进行深度学习 | Export Training Data For Deep Learning | 栅格 + 标注矢量/栅格 | 影像片文件夹 + 元数据文件夹 | **Image Analyst** |
| 31 | 使用 AI 模型提取要素 | Extract Features Using AI Models | 栅格 + 预训练模型 | 要素类（提取结果） | **Image Analyst** |
| 32 | 非极大值抑制 | Non Maximum Suppression | 检测对象结果 | 要素类（去重后） | **Image Analyst** |
| 33 | 训练深度学习模型 | Train Deep Learning Model | 导出训练数据 | 深度学习模型 | **Image Analyst** |
| 34 | 使用 AutoDL 进行训练 | Train Using AutoDL | 影像片 + 标注 | 深度学习模型 | **Image Analyst** |
| 35 | 转换图像形状 | Transform Image Shape | 要素（影像空间↔地图空间） | 要素类（转换后） | **Image Analyst** |
| 36 | 使用深度学习转换像素 | Transform Pixels Using Deep Learning | 栅格 + 深度学习模型 | 栅格（增强后） | **Image Analyst** |

**关键核实**：深度学习工具集在 Pro 3.x 期间扩展显著，本文列出的 14 项是 Pro 3.4+ 完整清单。`使用 AutoDL 进行训练` 自动构建训练管道并执行数据增强、模型选择、超参数调整与批量大小推导，大幅降低深度学习入门门槛。`使用 AI 模型提取要素` 可运行一个或多个预训练模型并自动执行推断后处理。`转换图像形状` 将要素从影像空间转换到地图空间（或反向），是倾斜/透视影像解译成果落地的关键步骤。

**硬件依赖**：深度学习工具集使用 GPU 处理执行分析，需兼容的 NVIDIA GPU 与 CUDA 环境。模型定义文件可为 Esri 模型定义 JSON（.emd）或深度学习模型包，须包含处理每个对象时调用的 Python 栅格函数路径与训练好的二进制模型文件路径。

**输出形态差异**：`使用深度学习检测对象` 输出要素类（对象周围边界框或面，或对象中心点）；`使用深度学习分类对象` 输出要素类或表（每个输入对象/要素分配类别标注）；`使用深度学习分类像素` 输出分类栅格。三者对应"检测—对象分类—像素分类"三个粒度层级。

**交叉引用**：`使用深度学习检测对象`、`使用深度学习分类对象`、`检测控制点`、`使用 AI 模型提取要素`、`非极大值抑制`、`转换图像形状`输出要素类，已在矢量清单收录。

### 2.4 提取分析（Extraction）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 37 | 采样 | Sample | 栅格 + 点/线/面/像元位置 | 表/点要素类 | **Image Analyst** |

**说明**：`采样` 创建表或点要素类，显示从一个栅格或一组栅格在已定义位置（由栅格像元、点、折线或面定义）处提取的像元值。Spatial Analyst 工具箱亦有同名工具，两者功能一致，属扩展模块功能重叠区。

### 2.5 插值分析（Interpolation）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 38 | 从时空点进行插值 | Interpolate From Spatiotemporal Points | 时空点数据 | 多维栅格 | **Image Analyst** |
| 39 | 最优插值 | Optimal Interpolation | 多来源数据 | 栅格（插值结果） | **Image Analyst** |

**说明**：`从时空点进行插值` 将时间点数据插入到多维栅格中；`最优插值` 通过统计方法合并多个来源的数据生成插值输出栅格。此工具集与 Spatial Analyst 插值分析工具集（IDW、克里金、样条等）定位不同——后者面向静态点集的空间插值，前者面向时空数据融合。

### 2.6 地图代数（Map Algebra）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 40 | 栅格计算器 | Raster Calculator | 栅格 + 表达式 | 栅格 | **Image Analyst** / Spatial Analyst |

**说明**：与 Spatial Analyst 的栅格计算器功能等价，使用 Python 语法构建并执行单个地图代数表达式。许可交叉：函数在 Image Analyst 或 Spatial Analyst 许可下可用；基础算术函数 Basic 即可用。

### 2.7 数学分析（Math，含 4 个子类）

Image Analyst 的数学工具集包含 60 余项工具，按功能分为常规、条件、逻辑、三角函数四类。由于工具名与 Spatial Analyst 1.12—1.15 完全一致（函数层面甚至与 Basic 级函数重叠），本文不重复逐项列出，仅说明差异与许可：

- **常规数学（General）**：Abs、Divide、Exp、Exp10、Exp2、Float、Int、Ln、Log10、Log2、Minus、Mod、Negate、Plus、Power、Round Down、Round Up、Square、Square Root、Times —— 许可为「Basic（函数）/ Image Analyst（工具）」；
- **条件数学（Conditional）**：等价于 Spatial Analyst 条件分析工具集（Con、Pick、Set Null）；
- **逻辑数学（Logical）**：含按位（Bitwise And/Left Shift/Not/Or/Right Shift/XOr）、布尔（Boolean And/Not/Or/XOr）、组合（Combinatorial And/Or/XOr）、关系（Diff、EqualTo、GreaterThan、GreaterThanOrEqual、InList、IsNull、LessThan、LessThanOrEqual、NotEqual、Over）—— 许可同常规数学；
- **三角函数（Trigonometric）**：ACos、ACosH、ASin、ASinH、ATan、ATan2、ATanH、Cos、CosH、Sin、SinH、Tan、TanH —— 许可同常规数学。

**许可核心差异**：同一数学运算在三个入口（栅格函数/Basic、Spatial Analyst 工具、Image Analyst 工具）的许可要求不同。栅格函数随 Basic 提供；Spatial Analyst 与 Image Analyst 工具箱中的同名工具分别需对应扩展许可。

### 2.8 动态视频影像（Motion Imagery）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 41 | 转换视频元数据 | Convert Video Metadata | 视频元数据 | 转换后元数据 | **Image Analyst** |
| 42 | 将视频帧提取为图像 | Extract Frames To Images | FMV 兼容视频流 | 图像文件夹 + 元数据 | **Image Analyst** |
| 43 | 生成视频元数据（静态） | Generate Video Metadata (Static) | 视频文件 | 元数据文件 | **Image Analyst** |
| 44 | 视频元数据至要素类 | Video Metadata To Feature Class | FMV 兼容视频 | 要素类（平台/帧中心/帧轮廓/属性） | **Image Analyst** |
| 45 | 视频多路复用器 | Video Multiplexer | 存档视频流 + 同步元数据 | 视频文件 | **Image Analyst** |

**说明**：动态视频影像工具集管理、处理和分析动态影像（含全动态视频 FMV 数据）。FMV 支持存档与实时流媒体，符合 MISB 标准；视频播放器支持 DVR 控制、基于位置或要素的视频存档检索、视频流中特定位置与时间戳的书签、GIS 数据与视频的双向编辑显示，并可在播放器窗口内测量对象的长度、面积与高度。

**交叉引用**：`视频元数据至要素类`输出要素类，已在矢量清单收录。

### 2.9 多维分析（Multidimensional Analysis）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 46 | 聚合多维栅格 | Aggregate Multidimensional Raster | 多维栅格 | 多维栅格（降维） | **Image Analyst** |
| 47 | 维度移动统计数据 | Dimensional Moving Statistics | 多维栅格 | 多维栅格（移动窗口统计） | **Image Analyst** |
| 48 | 查找参数统计信息 | Find Argument Statistics | 多维/多波段栅格 | 栅格（维度值/波段指数） | **Image Analyst** |
| 49 | 生成多维异常 | Generate Multidimensional Anomaly | 多维栅格 | 多维栅格（异常） | **Image Analyst** |
| 50 | 生成趋势栅格 | Generate Trend Raster | 多维栅格 | 趋势栅格（模型参数） | **Image Analyst** |
| 51 | 多维主成分分析 | Multidimensional Principal Components | 多维栅格 | 多维栅格（主成分） | **Image Analyst** |
| 52 | 多维栅格相关性 | Multidimensional Raster Correlation | 一个或两个多维栅格 | 栅格/表（相关系数） | **Image Analyst** |
| 53 | 使用趋势栅格预测 | Predict Using Trend Raster | 趋势栅格 | 多维栅格（预测） | **Image Analyst** |
| 54 | 汇总分类栅格 | Summarize Categorical Raster | 多维分类栅格 | 表（各类像素计数） | **Image Analyst** |

**说明**：多维分析工具集对跨多个变量和维度的科学数据执行分析，典型数据源包括 NetCDF、GRIB、HDF 以及时序卫星影像（如 Landsat 年度合成）。标准工作流为：聚合多维栅格（按需降采样）→ 生成趋势栅格（拟合各像元时序趋势）→ 使用趋势栅格预测（外推未来）→ 生成多维异常（识别偏离趋势的剖切片）。

**交叉引用**：`汇总分类栅格`输出表，已在矢量清单"分区统计"类别中作交叉引用。

### 2.10 叠加分析（Overlay）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 55 | 加权总和 | Weighted Sum | 多个栅格 + 权重 | 栅格（摘要） | **Image Analyst** |

**说明**：`加权总和` 将各栅格乘以其权重后逐像元求和，是适宜性建模的简化手段。与 Spatial Analyst 的 `加权总和`（1.18-168）及 `加权叠加`（1.18-167）功能重叠，区别在于 `加权叠加` 要求输入统一到共同测量尺度。此外 Image Analyst 栅格函数体系还提供 `Weighted Overlay` 函数（需 Spatial Analyst 许可）与 `Weighted Sum` 函数（需 Spatial Analyst 许可）。

### 2.11 光谱分析（Spectral Analysis）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 56 | 使用光谱对栅格进行分类 | Classify Raster Using Spectra | 多波段栅格 + 点要素类/.json | 栅格（分类） | **Image Analyst** |
| 57 | 检测图像异常 | Detect Image Anomalies | 多波段/高光谱影像 | 栅格（异常得分，0–1） | **Image Analyst** |
| 58 | 使用光谱检测目标 | Detect Target Using Spectra | 影像 + 光谱特征 | 栅格（匹配像素） | **Image Analyst** |
| 59 | 从图像中提取光谱 | Extract Spectra From Image | 影像 + 要素数据 | .esl 光谱库文件 | **Image Analyst** |
| 60 | 线性光谱解混 | Linear Spectral Unmixing | 多波段栅格 | 栅格（分数丰度） | **Image Analyst** |
| 61 | 减少光谱波段 | Reduce Spectral Bands | 多波段影像 | 栅格（降维后） | **Image Analyst** |
| 62 | 重采样库光谱 | Resample Library Spectra | 光谱库 | .esl 光谱库文件 | **Image Analyst** |

**说明**：光谱分析工具集面向多波段与高光谱影像。高光谱传感器采集数百乃至数千个连续窄波段，光谱分辨率极高，可依据物体与材料的独特光谱特征进行识别。`减少光谱波段` 采用最小噪声分离（MNF）与主成分分析（PCA）方法降维；`检测图像异常` 输出 0–1 单波段异常得分栅格；`使用光谱检测目标` 识别与给定光谱特征匹配的像素；`从图像中提取光谱` 从要素数据提取光谱特征并创建 Esri 光谱库（.esl）文件。

**交叉引用**：`从图像中提取光谱`、`重采样库光谱`输出 .esl 光谱库文件（非栅格也非矢量），属工具链的辅助产物，本文仅作说明。`线性光谱解混` 同时存在于 Spatial Analyst 影像分割和分类工具集，功能完全一致。

### 2.12 统计分析（Statistical）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 63 | 像元统计 | Cell Statistics | 多个栅格 | 栅格（统计量） | **Image Analyst** |
| 64 | 查找参数统计信息 | Find Argument Statistics | 多维/多波段栅格 | 栅格（维度值/波段指数） | **Image Analyst** |
| 65 | 焦点统计 | Focal Statistics | 栅格 | 栅格（移动邻域） | **Image Analyst** |
| 66 | 分区统计 | Zonal Statistics | 区域 + 值栅格 | 栅格（统计量） | **Image Analyst** |
| 67 | 以表格显示分区统计 | Zonal Statistics As Table | 区域 + 值栅格 | 表（统计量） | **Image Analyst** |

**说明**：统计工具在本地、邻域或分区基础上执行统计栅格运算，与 Spatial Analyst 的局部分析（1.10）、邻域分析（1.17）、区域分析（1.24）工具集高度重叠。`像元统计` 支持众数、最大值、平均值、中值、最小值、少数、百分位数、范围、标准差、总和及变异度等统计量。

### 2.13 表面分析（Surface）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 68 | （工具集容器，具体工具见说明） | — | — | — | **Image Analyst** |

**说明**：Image Analyst 工具箱概览页列出 Surface 工具集，描述为"包含用于分析高程表面的工具"。在 Pro 3.x 中，表面分析的实际工具实现集中在 Spatial Analyst 工具箱的表面分析工具集（1.23，共 23 项）与 3D Analyst 的 Raster Surface 子集（9 项）。Image Analyst 的 Surface 工具集本身不提供独立工具条目，本文列出以保持工具箱结构的完整性，避免与 1.23 重复计数。

### 2.14 合成孔径雷达（Synthetic Aperture Radar）

SAR 工具集包含 25 项工具，分为数据处理链与 SAR 分析两个层次。

#### 2.14.1 SAR 数据处理

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 69 | 应用复杂数据过滤器 | Apply Complex Data Filter | 复数 SAR 数据 | 复数雷达数据（相位平滑后） | **Image Analyst** |
| 70 | 应用配准 | Apply Coregistration | 副 SLC + DEM + 轨道状态矢量 | SLC 栅格（配准后） | **Image Analyst** |
| 71 | 应用几何地形校正 | Apply Geometric Terrain Correction | SAR 数据 + DEM | 栅格（正射校正后） | **Image Analyst** |
| 72 | 应用轨道校正 | Apply Orbit Correction | Sentinel-1 SAR + OSV 文件 | SAR 数据集（轨道更新） | **Image Analyst** |
| 73 | 应用辐射定标 | Apply Radiometric Calibration | SAR 数据 | SAR 数据（物理单位反向散射） | **Image Analyst** |
| 74 | 应用辐射地形扁率 | Apply Radiometric Terrain Flattening | SAR 数据 + DEM | SAR 数据（地形校正后） | **Image Analyst** |
| 75 | 计算相干性 | Compute Coherence | 参考+副复数雷达数据 | 栅格（相干性） | **Image Analyst** |
| 76 | 计算 SAR 指数 | Compute SAR Indices | SAR 数据 | 栅格（RVI/RFDI/CSI 等） | **Image Analyst** |
| 77 | 转换 SAR 单位 | Convert SAR Units | SAR 数据 | SAR 数据（单位转换后） | **Image Analyst** |
| 78 | 创建彩色合成 | Create Color Composite | 多波段栅格 | 三波段栅格 | **仅 Basic** |
| 79 | 去除 Burst | Deburst | Sentinel-1 SLC | 无缝子条带栅格 | **Image Analyst** |
| 80 | 去斑 | Despeckle | SAR 数据 | SAR 数据（去斑后） | **Image Analyst** |
| 81 | 检测亮色海洋对象 | Detect Bright Ocean Objects | SAR 数据 + 区域 | SAR 栅格（掩膜后）+ 对象 | **Image Analyst** |
| 82 | 检测深色海洋区域 | Detect Dark Ocean Areas | SAR 数据 + 区域 | SAR 栅格（掩膜后）+ 聚类 | **Image Analyst** |
| 83 | 下载轨道文件 | Download Orbit File | Sentinel-1 SAR | OSV 文件 | **Image Analyst** |
| 84 | 提取海洋风 | Extract Ocean Winds | SAR 数据 | 栅格（风向/风速） | **Image Analyst** |
| 85 | 提取水体 | Extract Water | SAR 数据 + DEM | 栅格（水体） | **Image Analyst** |
| 86 | 生成干涉图 | Generate Interferogram | 参考+副 SLC | 栅格（干涉图） | **Image Analyst** |
| 87 | 生成掩膜 SAR 栅格 | Generate Masked SAR Raster | SAR 数据 + 感兴趣区 | SAR 数据集（掩膜后） | **Image Analyst** |
| 88 | 生成辐射地形校正数据 | Generate Radiometric Terrain Corrected Data | Level 1 SAR | RTC 数据集 | **Image Analyst** |
| 89 | 生成多时相相干性 | Generate Multitemporal Coherence | 复数雷达产品 | 三波段假彩色合成栅格 | **Image Analyst** |
| 90 | 多视 | Multilook | SAR 数据 | SAR 数据（近似方像素） | **Image Analyst** |
| 91 | 移除热噪声 | Remove Thermal Noise | SAR 数据 | SAR 数据（热噪声校正后） | **Image Analyst** |
| 92 | 解缠相位 | Unwrap Phase | SLC 数据 | 栅格（连续相位） | **Image Analyst** |

**许可例外核实**：`创建彩色合成` 是 Image Analyst 工具集中唯一的例外——**仅需 ArcGIS Pro Desktop Basic 许可**即可使用，无需 Image Analyst 扩展模块。这是本文许可汇总中最需重点标注的差异点。

**标准 InSAR 处理链**：下载轨道文件 → 应用轨道校正 → 应用辐射定标 → 应用辐射地形扁率 → 多视 → 去斑/应用复杂数据过滤器 → 配准（Apply Coregistration，需 DEM）→ 生成干涉图 → 计算相干性 → 解缠相位。`提取海洋风`、`提取水体`、`检测亮色海洋对象`、`检测深色海洋区域`属 SAR 信息提取应用工具，输出主体为栅格（部分含矢量对象结果，已在矢量清单交叉引用）。

**单位转换范围**：`转换 SAR 单位` 支持振幅与强度之间、线性与分贝（dB）之间、复数与强度之间、相位与位移之间的相互转换。

### 2.15 实用工具（Utilities）

| 序号 | 中文名 | 英文名 | 输入类型 | 输出类型 | 许可 |
|---|---|---|---|---|---|
| 93 | 创建二进制掩膜 | Create Binary Mask | 栅格/要素（感兴趣区） | 栅格（二进制掩膜） | **Image Analyst** |

**说明**：实用工具工具集包含对影像和派生产品进行预处理与后处理的工具。截至 Pro 3.7，该工具集仅公开列出 `创建二进制掩膜` 一项。Esri 官方文档将该工具集描述为"包含诸多工具"，但实际可调用条目有限，其余功能可能通过栅格函数或影像选项卡按钮形式提供。本文如实记录，不以推测补充。

---

## 三、栅格函数体系（Raster Functions）

栅格函数与地理处理工具的本质区别在于执行方式：函数直接对影像和栅格数据集的像素执行运算，仅处理屏幕上可见的像素，缩放和平移时动态计算，不创建中间数据集，因此速度快且不占用磁盘空间；地理处理工具则将新栅格写入磁盘。函数可单独应用，也可组合为函数链（Function Chain）并保存为栅格函数模板（.rft.xml）。

### 3.1 局部函数（Local Functions）

局部函数在栅格函数窗格中可直接访问，随 ArcGIS Pro Basic 提供（部分需扩展许可，文中已标注）。按功能分为 13 个类别。

#### 3.1.1 分析类函数（Analysis）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 1 | 核密度 | Kernel Density | 点/线要素 | 栅格（密度面） | **Basic** |
| 2 | 处理栅格集合 | Process Raster Collection | 多维栅格各剖片/镶嵌图层各项 | 栅格 | **Basic** |
| 3 | 加权叠加 | Weighted Overlay | 多个栅格 | 栅格（适宜性） | **Spatial Analyst** |
| 4 | 加权总和 | Weighted Sum | 多个栅格 | 栅格（加权和） | **Spatial Analyst** |

#### 3.1.2 分类类函数（Classification）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 5 | 分类 | Classify | 栅格/分割栅格 + .ecd | 栅格（分类） | **Basic** |
| 6 | 线性光谱解混 | Linear Spectral Unmixing | 多波段栅格 | 栅格（分数丰度） | **Basic** |
| 7 | 最大似然法分类 | Maximum Likelihood Classify | 栅格/镶嵌数据集 | 栅格（分类） | **Basic** |
| 8 | 均值漂移影像分割 | Segment Mean Shift | 多波段栅格 | 栅格（分割） | **Basic** |

#### 3.1.3 数据管理类函数（Data Management）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 9 | 聚合 | Aggregate | 栅格 | 栅格（降分辨率） | **Basic** |
| 10 | 边界清理 | Boundary Clean | 栅格 | 栅格（边界平滑） | **Spatial Analyst** |
| 11 | 扩展 | Expand | 栅格 | 栅格（区域扩展） | **Basic** |
| 12 | 蚕食 | Nibble | 栅格 | 栅格（邻近填充） | **Spatial Analyst** |
| 13 | 区域分组 | Region Group | 栅格 | 栅格（连通区域编码） | **Spatial Analyst** |
| 14 | 收缩 | Shrink | 栅格 | 栅格（区域收缩） | **Spatial Analyst** |

#### 3.1.4 距离类函数（Distance）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 15 | 距离累积 | Distance Accumulation | 源（栅格/要素） | 距离栅格 | **Spatial Analyst** |
| 16 | 距离分配 | Distance Allocation | 源（栅格/要素） | 分配栅格 | **Spatial Analyst** |
| 17 | 最小成本廊道 | Least Cost Corridor | 两个距离累积栅格 | 廊道栅格 | **Spatial Analyst** |
| 18 | 最佳路径为栅格 | Optimal Path As Raster | 距离累积/分配栅格 + 目的地 | 路径栅格 | **Spatial Analyst** |

#### 3.1.5 距离（旧版本）类函数（Distance Legacy）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 19 | 廊道分析 | Corridor | 两个成本距离栅格 | 廊道栅格 | **Spatial Analyst** |
| 20 | 成本分配 | Cost Allocation | 源+成本栅格 | 分配栅格 | **Spatial Analyst** |
| 21 | 成本回溯链接 | Cost Back Link | 源+成本栅格 | 方向栅格 | **Spatial Analyst** |
| 22 | 成本距离 | Cost Distance | 源+成本栅格 | 距离栅格 | **Spatial Analyst** |
| 23 | 成本路径 | Cost Path | 目的地+回溯链接 | 路径栅格 | **Spatial Analyst** |
| 24 | 欧氏分配 | Euclidean Allocation | 源（栅格/要素） | 分配栅格 | **Spatial Analyst** |
| 25 | 欧氏反向 | Euclidean Back Direction | 源（栅格/要素） | 方向栅格 | **Spatial Analyst** |
| 26 | 欧氏方向 | Euclidean Direction | 源（栅格/要素） | 方向栅格 | **Spatial Analyst** |
| 27 | 欧氏距离 | Euclidean Distance | 源（栅格/要素） | 距离栅格 | **Spatial Analyst** |
| 28 | 路径距离 | Path Distance | 源+成本+表面 | 距离栅格 | **Spatial Analyst** |
| 29 | 路径距离分配 | Path Distance Allocation | 源+成本+表面 | 分配栅格 | **Spatial Analyst** |
| 30 | 路径距离回溯链接 | Path Distance Back Link | 源+成本+表面 | 方向栅格 | **Spatial Analyst** |

#### 3.1.6 水文类函数（Hydrology）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 31 | 填洼 | Fill | DEM 栅格 | 栅格（填洼后 DEM） | **Basic** |
| 32 | 流量 | Flow Accumulation | 流向栅格 | 栅格（累积流量） | **Basic** |
| 33 | 流向 | Flow Direction | DEM 栅格 | 栅格（流向） | **Basic** |
| 34 | 流动距离 | Flow Distance | 流向栅格+距离类型 | 栅格（流动距离） | **Basic** |
| 35 | 河流链接 | Stream Link | 河网+流向栅格 | 栅格（河链分段） | **Basic** |
| 36 | 集水区 | Watershed | 流向栅格+倾泻点 | 栅格（汇水区） | **Basic** |

#### 3.1.7 数学类函数（Math）

包含算术（Arithmetic）、幂（Power）、指数（Exponential）、对数（Logarithmic）四类，以及符号转换与整型/浮点型转换工具。具体工具名与 1.12 完全一致：Abs、Divide、Exp、Exp10、Exp2、Float、Int、Ln、Log10、Log2、Minus、Mod、Negate、Plus、Power、Round Down、Round Up、Square、Square Root、Times。**许可：Basic（函数）**。

#### 3.1.8 数学：条件类函数（Math: Conditional）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 37 | 条件函数 | Con | 条件栅格 | 栅格 | **Basic** |
| 38 | 选取函数 | Pick | 栅格列表 | 栅格 | **Basic** |
| 39 | 设为空函数 | Set Null | 栅格 + 条件 | 栅格 | **Basic** |

#### 3.1.9 数学：逻辑类函数（Math: Logical）

按位（Bitwise And/Left Shift/Not/Or/Right Shift/XOr）、布尔（Boolean And/Not/Or/XOr）、组合（Combinatorial And/Or/XOr）、关系（Diff、EqualTo、GreaterThan、GreaterThanOrEqual、InList、IsNull、LessThan、LessThanOrEqual、NotEqual、Over）共 20 项。**许可：Basic（函数）**。

#### 3.1.10 数学：三角函数类函数（Math: Trigonometric）

ACos、ACosH、ASin、ASinH、ATan、ATan2、ATanH、Cos、CosH、Sin、SinH、Tan、TanH 共 13 项。**许可：Basic（函数）**。

#### 3.1.11 重分类类函数（Reclass）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 40 | 查找表 | Lookup | 栅格 + 字段 | 栅格 | **Basic** |
| 41 | 重映射 | Remap | 栅格 + 映射规则 | 栅格 | **Basic** |
| 42 | 按区域重分类 | Zonal Remap | 栅格 + 区域栅格 + 映射表 | 栅格 | **Basic** |

#### 3.1.12 表面类函数（Surface）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 43 | 坡向 | Aspect | DEM 栅格 | 栅格（坡向） | **Basic** |
| 44 | 曲率 | Curvature | DEM 栅格 | 栅格（曲率） | **Basic** |
| 45 | 高程空洞填充 | Elevation Void Fill | DEM 栅格（含空洞） | 栅格（填充后） | **Basic** |
| 46 | 山体阴影 | Hillshade | DEM 栅格 | 栅格（晕渲） | **Basic** |
| 47 | 地貌晕渲 | Shaded Relief | DEM 栅格 | 栅格（彩色 3D 地表） | **Basic** |
| 48 | 坡度 | Slope | DEM 栅格 | 栅格（坡度） | **Basic** |
| 49 | 表面参数 | Surface Parameters | DEM 栅格 | 栅格（坡向/坡度/曲率） | **Basic** |
| 50 | 视域 | Viewshed | DEM 栅格 + 观察点要素 | 栅格（可视性） | **Basic** |

**关键核实**：表面类栅格函数多数随 Basic 提供（与同名地理处理工具需 Spatial Analyst/3D Analyst 许可形成鲜明对比），这是"函数 vs 工具"许可差异的典型例证。`地貌晕渲` 通过合并高程编码法与山体阴影法生成彩色 3D 地表；`表面参数` 使用测地线方法确定坡向、坡度与多种曲率；`视域` 使用测地线方法确定栅格表面对一组观察点要素可见的位置。

#### 3.1.13 统计类函数（Statistical）

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 51 | 参数统计 | ArgStatistics | 多维/多波段栅格 | 栅格（维度值/波段指数） | **Basic** |
| 52 | 众数 | Majority | 多个栅格 | 栅格（众数） | **Basic** |
| 53 | 最大值 | Max | 多个栅格 | 栅格（最大值） | **Basic** |
| 54 | 平均值 | Mean | 多个栅格 | 栅格（平均值） | **Basic** |
| 55 | 中值 | Median | 多个栅格 | 栅格（中值） | **Basic** |
| 56 | 最小值 | Min | 多个栅格 | 栅格（最小值） | **Basic** |
| 57 | 少数 | Minority | 多个栅格 | 栅格（少数） | **Basic** |

### 3.2 全局函数（Global Functions）

全局函数允许以指定的分辨率和范围执行处理，默认在源分辨率和全图范围下处理栅格（与仅处理屏幕可见像素的常规函数相反），因此处理时间可能较长，建议配合分布式栅格分析使用。全局函数在 Pro 3.4+ 文档中按功能归类如下。

#### 3.2.1 数据管理类（Data Management）

| 序号 | 函数名 | 英文名 | 许可 |
|---|---|---|---|
| 58 | 边界清理 | Boundary Clean | **Spatial Analyst** |
| 59 | 区域分组 | Region Group | **Spatial Analyst** |
| 60 | 蚕食 | Nibble | **Spatial Analyst** |
| 61 | 收缩 | Shrink | **Spatial Analyst** |

#### 3.2.2 距离类（Distance）

| 序号 | 函数名 | 英文名 | 许可 |
|---|---|---|---|
| 62 | 距离累积 | Distance Accumulation | **Spatial Analyst** |
| 63 | 距离分配 | Distance Allocation | **Spatial Analyst** |
| 64 | 最小成本廊道 | Least Cost Corridor | **Spatial Analyst** |
| 65 | 最佳路径为栅格 | Optimal Path As Raster | **Spatial Analyst** |

#### 3.2.3 距离（旧版本）类（Distance Legacy）

| 序号 | 函数名 | 英文名 | 许可 |
|---|---|---|---|
| 66 | 廊道分析 | Corridor | **Spatial Analyst** |
| 67 | 成本分配 | Cost Allocation | **Spatial Analyst** |
| 68 | 成本回溯链接 | Cost Back Link | **Spatial Analyst** |
| 69 | 成本距离 | Cost Distance | **Spatial Analyst** |
| 70 | 成本路径 | Cost Path | **Spatial Analyst** |
| 71 | 欧氏分配 | Euclidean Allocation | **Spatial Analyst** |
| 72 | 欧氏反向 | Euclidean Back Direction | **Spatial Analyst** |
| 73 | 欧氏方向 | Euclidean Direction | **Spatial Analyst** |
| 74 | 欧氏距离 | Euclidean Distance | **Spatial Analyst** |
| 75 | 路径距离 | Path Distance | **Spatial Analyst** |
| 76 | 路径距离分配 | Path Distance Allocation | **Spatial Analyst** |
| 77 | 路径距离回溯链接 | Path Distance Back Link | **Spatial Analyst** |

#### 3.2.4 水文类（Hydrology）

| 序号 | 函数名 | 英文名 | 许可 |
|---|---|---|---|
| 78 | 填充 | Fill | **Spatial Analyst** |
| 79 | 流向 | Flow Direction | **Spatial Analyst** |
| 80 | 流动距离 | Flow Distance | **Spatial Analyst** |
| 81 | 河流链接 | Stream Link | **Spatial Analyst** |
| 82 | 集水区 | Watershed | **Spatial Analyst** |

#### 3.2.5 重分类类（Reclass）

| 序号 | 函数名 | 英文名 | 许可 |
|---|---|---|---|
| 83 | 查找表 | Lookup | **Spatial Analyst** |
| 84 | 重映射 | Remap | **Spatial Analyst** |
| 85 | 按区域重分类 | Zonal Remap | **Spatial Analyst** |

#### 3.2.6 统计类（Statistical）

| 序号 | 函数名 | 英文名 | 许可 |
|---|---|---|---|
| 86 | 参数统计 | ArgStatistics | **Spatial Analyst** |
| 87 | 众数 | Majority | **Spatial Analyst** |
| 88 | 最大值 | Max | **Spatial Analyst** |
| 89 | 平均值 | Mean | **Spatial Analyst** |
| 90 | 中值 | Median | **Spatial Analyst** |
| 91 | 最小值 | Min | **Spatial Analyst** |
| 92 | 少数 | Minority | **Spatial Analyst** |

### 3.3 影像分析函数（Image Analysis Functions）

影像分析函数（Image Analyst 扩展模块提供）侧重影像处理链构建，与前两类的差异在于输入多为多波段/多维/镶嵌数据集。主要函数如下（许可标注为 Image Analyst 或 Basic）。

| 序号 | 函数名 | 英文名 | 输入 | 输出 | 许可 |
|---|---|---|---|---|---|
| 93 | 表观反射率 | Apparent Reflectance | 卫星影像 DN 值 | 栅格（反射率） | **Basic** |
| 94 | 算术 | Arithmetic | 两个栅格/栅格与标量 | 栅格 | **Basic** |
| 95 | 波段算术 | Band Arithmetic | 多波段栅格波段 | 栅格 | **Basic** |
| 96 | 波段集统计 | Band Collection Statistics | 多波段栅格 | 表（协方差/相关矩阵） | **Basic** |
| 97 | 计算云栅格掩膜 | Calculate Cloud Raster Composite | 多时相栅格 | 栅格（云掩膜） | **Image Analyst** |
| 98 | 分类 | Classify | 栅格 + .ecd | 栅格（分类） | **Basic** |
| 99 | 分类栅格随机森林 | Classify Raster Random Forest | 栅格 + 随机森林模型 | 栅格（分类） | **Image Analyst** |
| 100 | 分类栅格 SVM | Classify Raster Support Vector Machine | 栅格 + SVM 模型 | 栅格（分类） | **Image Analyst** |
| 101 | 分类栅格监督分类 | Classify Raster Supervised Classification | 栅格 + 训练样本 | 栅格（分类） | **Image Analyst** |
| 102 | 分类栅格无监督分类 | Classify Raster Unsupervised Classification | 栅格 | 栅格（分类） | **Image Analyst** |
| 103 | 分类栅格最大似然法 | Classify Raster Using Maximum Likelihood | 栅格 | 栅格（分类） | **Basic** |
| 104 | 裁剪 | Clip | 栅格 + 范围/面要素 | 栅格（裁剪后） | **Basic** |
| 105 | 色彩映射表 | Colormap | 栅格 | 栅格（色彩映射） | **Basic** |
| 106 | 色彩映射表转 RGB | Colormap To RGB | 栅格 | 栅格（RGB） | **Basic** |
| 107 | 复杂数据转强度 | Complex To Intensity | 复数栅格 | 栅格（强度） | **Basic** |
| 108 | 复合波段 | Composite Band | 多个栅格 | 多波段栅格 | **Basic** |
| 109 | 连通性 | Connectedness | 栅格 | 栅格（连通区域） | **Basic** |
| 110 | 对比度与亮度 | Contrast and Brightness | 栅格 | 栅格（调整） | **Basic** |
| 111 | 卷积 | Convolution | 栅格 + 卷积核 | 栅格（滤波后） | **Basic** |
| 112 | 创建掩膜栅格 | Create Mask Raster | 栅格 + 掩膜规则 | 栅格（掩膜） | **Basic** |
| 113 | 分水岭 | Watershed（函数） | 流向栅格+倾泻点 | 栅格（分水岭） | **Basic** |
| 114 | 去斑 | Despeckle | SAR/影像栅格 | 栅格（去斑后） | **Image Analyst** |
| 115 | 检测异常 | Detect Anomalies | 多维/多波段栅格 | 栅格（异常得分） | **Image Analyst** |
| 116 | 检测变化 | Detect Change | 两个栅格 | 栅格（变化） | **Image Analyst** |
| 117 | 检测控制点 | Detect Keypoints | 影像 | 栅格/点（控制点） | **Image Analyst** |
| 118 | 检测对象 | Detect Objects | 栅格 + 深度学习模型 | 要素类（对象） | **Image Analyst** |
| 119 | 编辑栅格函数 | Edit Raster Function | 栅格函数链 | 修改后的函数链 | **Basic** |
| 120 | 高程空洞填充 | Elevation Void Fill | DEM 栅格 | 栅格（填充后） | **Basic** |
| 121 | 提取波段 | Extract Band | 多波段栅格 | 栅格（波段子集） | **Basic** |
| 122 | 提取类栅格 | Extract Class Raster | 分类栅格 | 栅格（单类） | **Basic** |
| 123 | 提取光谱 | Extract Spectra | 栅格 + 要素 | .esl 光谱库 | **Image Analyst** |
| 124 | 几何校正 | Geometric | 影像 + 传感器定义 + 地形模型 | 栅格（正射校正后） | **Basic** |
| 125 | 几何中位数 | Geometric Median | 多时相多波段影像 | 栅格（中值合成） | **Image Analyst** |
| 126 | 灰度 | Grayscale | 多波段栅格 | 单波段栅格 | **Basic** |
| 127 | 直方图均衡化 | Histogram Equalization | 栅格 | 栅格（均衡化后） | **Basic** |
| 128 | 直方图匹配 | Histogram Match | 栅格 + 参考栅格 | 栅格（匹配后） | **Basic** |
| 129 | 插值不规则数据 | Interpolate Irregular Data | 点云/不规则格网 | 栅格（插值后） | **Image Analyst** |
| 130 | 按维度插值栅格 | Interpolate Raster By Dimension | 多维栅格 + 维度值 | 栅格（插值剖片） | **Image Analyst** |
| 131 | 关键元数据 | Key Metadata | 栅格 | 栅格（元数据插入/覆盖） | **Basic** |
| 132 | 标签坏波段 | Label Bad Bands | 多波段/高光谱栅格 | 栅格（坏波段标记） | **Basic** |
| 133 |  Landsat 质量评估 | Landsat QA | Landsat 栅格 | 栅格（质量掩膜） | **Basic** |
| 134 | 线性光谱解混 | Linear Spectral Unmixing | 多波段栅格 | 栅格（分数丰度） | **Basic** |
| 135 | 掩膜 | Mask | 栅格 + NoData 范围 | 栅格（掩膜后） | **Basic** |
| 136 | 最大似然法分类 | Maximum Likelihood Classify | 栅格 | 栅格（分类） | **Basic** |
| 137 | 均值漂移分割 | Mean Shift Segmentation | 多波段栅格 | 栅格（分割） | **Basic** |
| 138 | 合并栅格 | Merge Raster | 多个栅格 | 栅格（合并集合） | **Basic** |
| 139 | 按波段指数镶嵌 | Mosaic Rasters By Band Indices | 多个影像 | 栅格（镶嵌后） | **Basic** |
| 140 | 镶嵌栅格 | Mosaic Rasters | 多个栅格数据集 | 栅格（镶嵌数据集） | **Basic** |
| 141 | 多维过滤 | Multidimensional Filter | 多维栅格 + 维度切片 | 栅格（子集） | **Basic** |
| 142 | 多维栅格 | Multidimensional Raster | 多维数据集 | 多维栅格图层 | **Basic** |
| 143 | 正射校正 | Orthorectify | 影像 + 传感器模型 + DEM | 栅格（正射影像） | **Basic** |
| 144 | 全景锐化 | Pansharpening | 多光谱+全色栅格 | 栅格（融合后） | **Basic** |
| 145 | 分位数 | Percentile | 多维/多波段栅格 | 栅格（分位数值） | **Basic** |
| 146 | 随机 | Random | — | 栅格（随机像素值） | **Basic** |
| 147 | 栅格信息 | Raster Info | 栅格 | 栅格（属性修改后） | **Basic** |
| 148 | 栅格转多维 | Raster To Multidimensional | 多个栅格 | 多维栅格 | **Basic** |
| 149 | 栅格转矢量 | Raster To Vector | 栅格 | 要素类 | **Basic** |
| 150 | 栅格转 Xarray | RasterToXarray | 多维栅格 | xarray.Dataset | **Basic** |
| 151 | 重计算 | Recast | 镶嵌数据集/影像服务 | 栅格（参数动态调整） | **Basic** |
| 152 | 重映射 | Remap | 栅格 + 映射规则 | 栅格（重分类后） | **Basic** |
| 153 | 重投影 | Reproject | 栅格/镶嵌数据集 | 栅格（重投影后） | **Basic** |
| 154 | 重采样 | Resample | 栅格 | 栅格（分辨率调整） | **Basic** |
| 155 | 重采样光谱库 | Resample Library Spectra | 光谱库 | .esl 光谱库 | **Image Analyst** |
| 156 | 缩放像素值 | Rescale Pixel Values | 栅格 | 栅格（缩放后） | **Basic** |
| 157 | 分割多维栅格 | Segment Multidimensional Raster | 多维栅格 | 多维栅格（分割后） | **Image Analyst** |
| 158 | 分割栅格 | Segment Raster | 栅格 | 栅格（分割） | **Basic** |
| 159 | 选择多维子集 | Select Multidimensional Subset | 多维栅格 | 多维栅格（子集） | **Basic** |
| 160 | 按像元统计 | Statistics | 多维/多波段栅格 | 栅格（统计量） | **Basic** |
| 161 | 统计与直方图 | Statistics and Histogram | 栅格 | 栅格（统计计算后） | **Basic** |
| 162 | 光谱转换 | Spectral Conversion | 多波段栅格 + 转换矩阵 | 栅格（色彩值调整） | **Basic** |
| 163 | 光谱指数 | Spectral Indices | 多波段栅格 | 栅格（指数） | **Basic** |
| 164 | 斑点滤波 | Speckle Filtering（Lee/Frost/Kuan） | SAR 栅格 | 栅格（滤波后） | **Basic** |
| 165 | 拉伸 | Stretch | 栅格 | 栅格（拉伸后） | **Basic** |
| 166 | 子集波段 | Subset Bands | 多波段栅格 | 栅格（波段子集） | **Basic** |
| 167 | 子集多维栅格 | Subset Multidimensional | 多维栅格 | 多维栅格（子集） | **Basic** |
| 168 | 转换波段 | Swap Bands | 多波段栅格 | 栅格（波段重排） | **Basic** |
| 169 | 趋势转 RGB | Trend To RGB | 趋势栅格 | 三波段栅格 | **Basic** |
| 170 | 转置位 | Transpose Bits | 栅格 | 栅格（位重排） | **Basic** |
| 171 | 单位转换 | Unit Conversion | 栅格 | 栅格（距离/速度/温度单位转换） | **Image Analyst** |
| 172 | 向量场 | Vector Field | 两个栅格 | 两波段栅格（Magnitude-Direction 或 U-V） | **Basic** |
| 173 | 矢量转栅格 | Vector To Raster | 要素类 | 栅格 | **Basic** |
| 174 | Xarray 转栅格 | Xarray To Raster | xarray.Dataset | 多维栅格 | **Basic** |

**许可交叉说明**：影像分析函数中绝大多数随 ArcGIS Pro Basic 提供，仅标注 Image Analyst 的 20 余项涉及高级分类、深度学习、多维分析、SAR 处理等场景。`栅格转矢量`（149）输出要素类，已在矢量清单收录；`矢量转栅格`（173）输入为矢量，本文仅作交叉引用。

### 3.4 函数链与自定义函数

**函数链（Function Chain）**：可将多个栅格函数组合为处理链，保存为栅格函数模板（.rft.xml）。函数模板可通过"栅格函数"窗格的自定义与工程选项卡应用，可添加到镶嵌数据集并随发布影像服务一起发布，也可通过"共享到门户"分享给组织内其他用户或导出为磁盘文件供离线分发。

**自定义函数（Custom Functions）**：可使用 Python 编写自定义栅格函数，应用方式与开箱即用函数完全相同。自定义函数支持访问 Raster Info、Key Metadata 等元数据操作，并可集成第三方 Python 库（如 NumPy、SciPy）实现专用算法。

**Portal for ArcGIS 分布式处理**：Portal for ArcGIS 增强了基于服务器的分布式栅格处理能力，可对任意分辨率和范围的数据执行分布式处理，处理结果以 Web 影像图层形式访问。栅格函数模板可部署到企业级门户并在分布式处理环境中执行。

---

## 四、许可汇总

### 4.1 许可结构总览

| 扩展模块 | 核心程序要求 | 工具箱 | 工具数量级 | 典型应用场景 |
|---|---|---|---|---|
| **Spatial Analyst** | Basic/Standard/Advanced 任一 + 扩展许可 | 24 个工具集 | 200+ | 水文建模、距离分析、栅格叠加、重分类、区域统计、表面分析 |
| **Image Analyst** | Basic/Standard/Advanced 任一 + 扩展许可 | 15 个工具集 | 90+ | 影像分类、深度学习、变化检测、多维分析、光谱分析、SAR 处理、动态视频 |
| **无扩展（Basic 函数）** | Basic 核心许可 | 栅格函数体系 | 100+ | 基础表面计算、数学运算、影像增强、波段运算、正射校正 |

### 4.2 许可例外清单

以下工具/函数的许可与所属工具箱默认许可不一致，是实际使用中容易踩坑的点：

| 工具/函数 | 所属工具箱 | 默认许可 | 实际许可 | 说明 |
|---|---|---|---|---|
| 创建彩色合成 | Image Analyst → SAR | Image Analyst | **仅 Basic** | SAR 工具集中唯一无需扩展的工具 |
| 全部数学工具（函数形态） | 栅格函数体系 | — | **Basic** | 同名地理处理工具需对应扩展许可 |
| 表面类函数（坡向/坡度/山体阴影/视域等） | 栅格函数体系 | — | **Basic** | 同名地理处理工具需 Spatial Analyst/3D Analyst |
| 核密度函数 | 栅格函数体系 → Analysis | — | **Basic** | 核密度分析工具需 Spatial Analyst |
| 分类函数 | 栅格函数体系 → Classification | — | **Basic** | Classify Raster 工具需对应扩展许可 |
| 均值漂移分割函数 | 栅格函数体系 → Classification | — | **Basic** | Segment Mean Shift 工具需对应扩展许可 |

### 4.3 "函数 vs 工具"许可差异的本质

同一算法的函数形态与工具形态许可不同，原因在于两者的执行基础设施不同：函数运行于 Pro 的即时渲染管线，随核心程序许可提供；工具运行于地理处理框架，属扩展模块功能。因此实际工作中存在"用函数做快速探索、用工具做生产交付"的常见分工——前者零额外许可成本且响应快，后者可写入磁盘、纳入模型构建器与 Python 自动化流程。

### 4.4 工具集功能重叠矩阵

以下工具集在 Spatial Analyst 与 Image Analyst 之间存在功能重叠，两扩展模块均授权时工具会重复出现：

| 功能领域 | Spatial Analyst 工具集 | Image Analyst 工具集 | 差异要点 |
|---|---|---|---|
| 影像分类 | 影像分割和分类（17 项） | 分类和模式识别（22 项） | 工具名基本一致，IA 多"使用回归模型预测""使用光谱对栅格进行分类" |
| 栅格叠加 | 叠加分析（5 项） | 叠加分析（1 项） | SA 含模糊分类/叠加、定位区域、加权叠加；IA 仅加权总和 |
| 区域统计 | 区域分析（8 项） | 统计分析（5 项） | 工具名与功能一致 |
| 局部统计 | 局部分析（9 项） | 统计分析（含像元统计） | 功能一致 |
| 焦点统计 | 邻域分析（含焦点统计） | 统计分析（含焦点统计） | 功能一致 |
| 采样 | 提取分析（含采样） | 提取分析（采样） | 功能一致 |
| 数学运算 | 数学分析（3 子类，39 项） | 数学分析（4 子类，60+ 项） | IA 多"条件数学"子类独立成集 |
| 表面分析 | 表面分析（23 项） | 表面（工具集容器） | 实际工具集中在 SA |
| 插值 | 插值分析（8 项） | 插值分析（2 项） | SA 面向静态点集；IA 面向时空数据融合 |
| 深度学习 | 无 | 深度学习（14 项） | IA 独有 |
| 变化检测 | 无 | 变化检测（4 项） | IA 独有 |
| 多维分析 | 无 | 多维分析（9 项） | IA 独有 |
| SAR 处理 | 无 | 合成孔径雷达（24 项） | IA 独有 |
| 动态视频 | 无 | 动态视频影像（5 项） | IA 独有 |
| 光谱分析 | 无 | 光谱分析（7 项） | IA 独有 |
| 地下水 | 地下水分析（4 项） | 无 | SA 独有 |
| 太阳辐射 | 太阳辐射（5 项） | 无 | SA 独有 |
| 栅格创建 | 栅格创建（3 项） | 无 | SA 独有 |
| 距离分析 | 距离分析 + 旧版本（20 项） | 无 | SA 独有 |
| 密度分析 | 密度分析（8 项） | 无 | SA 独有 |
| 概化 | 概化（8 项） | 无 | SA 独有 |
| 多元分析 | 多元分析（9 项） | 无 | SA 独有 |

---

## 五、常见误区与核实结论

### 5.1 误区一：把栅格函数当地理处理工具混列

**现象**：部分非官方清单将"Kernel Density 函数"与"核密度分析工具"合并为一项，或将"Weighted Overlay 函数"列为 Spatial Analyst 工具。

**核实结论**：二者是两个独立入口，许可与执行方式均不同。函数随 Basic 提供、即时计算；工具需 Spatial Analyst 许可、写入磁盘。本文在第三部分单列栅格函数体系，避免混淆。

### 5.2 误区二：忽略工具集迁移

**现象**：旧版文档将"表面分析"归入 3D Analyst 独立工具集；部分清单仍按 ArcMap 10.x 结构归类。

**核实结论**：在 ArcGIS Pro 3.x 中，表面分析工具集统一归属 Spatial Analyst 工具箱（1.23），同时标注"需 3D Analyst 许可"，3D Analyst 工具箱内保留 Raster Surface 子集（9 项）作为功能镜像。本文按 Pro 3.7 结构记录。

### 5.3 误区三：遗漏 Pro 3.x 新增工具

**现象**：大量清单停留在 Pro 2.5 时期，缺失以下工具：

**Spatial Analyst 新增（Pro 3.4）**：
- 表面分析：要素保留平滑、多尺度表面偏差、多尺度表面差异、多尺度表面百分位数（4 项）
- 距离分析：距离累积/距离分配新增 Hiking Time 与 Bidirectional Hiking Time 垂直系数；测地线距离 + GCS/圆柱投影支持绕全球计算
- 太阳辐射：要素/栅格太阳辐射新增 Sun Map Grid Level 参数 + GPU 增强
- 水文分析：派生流作为栅格在 Map Viewer 可直接调用

**Image Analyst 新增（Pro 3.2—3.4）**：
- 深度学习：使用 AutoDL 进行训练、使用 AI 模型提取要素、转换图像形状、使用深度学习转换像素（4 项）
- 多维分析：多维主成分分析、多维栅格相关性（2 项）
- 实用工具：创建二进制掩膜

### 5.4 误区四：混淆"栅格输出"与"矢量输出"工具

**现象**：将 Stream To Feature、Contour、Cost Path as Polyline、Optimal Path As Line、Derive Stream As Line、最佳区域连接等工具列入栅格分析清单。

**核实结论**：上述工具输出为矢量要素类，属《矢量分析工具清单》收录范围。本文在第一、二部分仅作交叉引用并标注"已在矢量清单收录"，不重复展开，以保持两份清单的互斥性。

### 5.5 误区五：误判许可等级

**现象**：部分清单标注"某 Spatial Analyst 工具需 Advanced 许可"。

**核实结论**：Spatial Analyst 与 Image Analyst 工具箱内全部工具的许可标注均为统一的"需 [扩展名] 许可"，**不按 Basic/Standard/Advanced 分级**。核心程序级别只决定能否挂接扩展模块，不决定工具可用性。这与矢量清单中"Basic/Standard/Advanced 三级分级"的结构根本不同，是两份清单许可部分最大的差异。

### 5.6 误区六：将遗留工具当作现行工具

**现象**：清单中成本距离、欧氏距离、路径距离系列（14 项）与新版距离累积、距离分配并列推荐。

**核实结论**：旧版距离工具已归入"距离分析（旧版本）"工具集，采用精度较低的早期算法。Esri 官方明确建议新工程使用 Distance Accumulation / Distance Allocation 框架。本文保留旧版清单但标注"遗留/Legacy，不建议新工程使用"。

---

## 六、典型工作流速查

为便于实操，以下列出五类高频分析的推荐工具链（工具名后括号标注所属工具箱）。

### 6.1 水文建模

```
填洼 (SA-水文)
  → 流向 (SA-水文) / 测地线流向 (SA-水文，全球尺度)
  → 流量 (SA-水文)
  → 派生连续流 (SA-水文，Pro 2.8+)
  → 设定累积流量阈值提取河网
  → 河流链接 (SA-水文)
  → 河网分级 (SA-水文)
  → 盆域 (SA-水文) / 集水区 (SA-水文)
  → 捕捉倾泻点 (SA-水文)
  → [可选] 栅格河网矢量化 (SA-水文) → 输出河网线要素
  → [可选] 派生流作为线 (SA-水文) → 输出河网线要素
```

### 6.2 适宜性建模

```
各因子栅格准备（坡度/坡向/距离/土地利用…）
  → 重分类 (SA-重分类) / 按函数重缩放 (SA-重分类)
  → 加权叠加 (SA-叠加) 或 加权总和 (SA-叠加 / IA-叠加)
  → [可选] 模糊分类 + 模糊叠加 (SA-叠加)
  → [可选] 定位区域 (SA-叠加) → 输出最佳区域栅格/面要素
```

### 6.3 影像分类（对象基）

```
多波段影像
  → 均值漂移影像分割 (SA-分割分类 / IA-分类模式识别)
  → 计算分割影像属性 (SA-分割分类 / IA-分类模式识别)
  → 生成训练样本 (从种子点) (SA-分割分类 / IA-分类模式识别)
  → 训练分类器（SVM/随机树/最大似然/KNN/Iso）(SA-分割分类 / IA-分类模式识别)
  → 分类栅格 (SA-分割分类 / IA-分类模式识别)
  → 创建精度评估点 (SA-分割分类 / IA-分类模式识别)
  → 计算混淆矩阵 (SA-分割分类 / IA-分类模式识别)
  → [可选] 移除栅格分割块伪影 (SA-分割分类 / IA-分类模式识别)
```

### 6.4 深度学习目标检测

```
标注矢量/栅格数据
  → 导出训练数据进行深度学习 (SA-分割分类 / IA-深度学习)
  → 训练深度学习模型 (IA-深度学习)
  → [可选] 使用 AutoDL 进行训练 (IA-深度学习，自动化)
  → 使用深度学习检测对象 (IA-深度学习) → 输出对象要素类
  → 非极大值抑制 (IA-深度学习) → 去除重复对象
  → 计算对象检测的精度 (IA-深度学习)
```

### 6.5 成本距离路径分析

```
源要素 + 成本栅格（+ 表面栅格 + 垂直/水平系数）
  → 距离累积 (SA-距离)
  → 距离分配 (SA-距离)
  → 最佳路径为栅格 (SA-距离) / 最佳路径为线 (SA-距离) → 后者输出线要素
  → [可选] 最小成本廊道 (SA-距离) → 廊道栅格
  → [可选] 最佳廊道连接 (SA-距离) → 多源廊道网络
  → [可选] 最佳区域连接 (SA-距离) → 区域连接线要素
```


## 七、官方文档引用

本文所有工具清单、许可标注、工具集归属与版本新增信息均来自 Esri 官方 ArcGIS Pro 帮助文档。主要来源如下：

**Spatial Analyst**
1. Spatial Analyst 工具的完整列表（Pro 3.4/3.7）：<https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/spatial-analyst/complete-listing-of-spatial-analyst-tools.htm>
2. Spatial Analyst 工具箱许可：<https://doc.esri.com/zh-cn/arcgis-pro/latest/tool-reference/spatial-analyst/spatial-analyst-toolbox-license.html>
3. 启用 Spatial Analyst 扩展模块：<https://pro.arcgis.com/zh-cn/pro-app/3.4/help/analysis/spatial-analyst/basics/enabling-the-spatial-analyst-extension.htm>
4. Spatial Analyst 工具箱的功能：<https://pro.arcgis.com/zh-cn/pro-app/latest/help/analysis/spatial-analyst/basics/capabilities-of-the-spatial-analyst-toolbox.htm>
5. 表面分析工具集概览：<https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/spatial-analyst/an-overview-of-the-surface-tools.htm>
6. 太阳辐射工具集概览：<https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/spatial-analyst/an-overview-of-the-solar-radiation-tools.htm>
7. Spatial Analyst 2024 年度功能回顾（Esri Blog）：<https://www.esri.com/arcgis-blog/products/spatial-analyst/analytics/new-functionality-for-spatial-analyst-introduced-in-2024>

**Image Analyst**
8. Image Analyst 工具箱概览：<https://pro.arcgis.com/zh-cn/pro-app/latest/help/analysis/image-analyst/>
9. ArcGIS Image Analyst 扩展模块简介：<https://pro.arcgis.com/zh-cn/pro-app/latest/help/analysis/image-analyst/what-is-the-arcgis-pro-image-analyst-extension-.htm>
10. Image Analyst 地理处理工具列表（中文，Pro 3.5）：<https://pro.arcgis.com/zh-cn/pro-app/3.5/help/analysis/image-analyst/complete-list-of-arcgis-image-analyst-extension-geoprocessing-tools.htm>
11. Image Analyst 地理处理工具列表（英文，Pro 3.6）：<https://pro.arcgis.com/en/pro-app/3.6/help/analysis/image-analyst/complete-list-of-arcgis-image-analyst-extension-geoprocessing-tools.htm>
12. 合成孔径雷达工具集概览：<https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/image-analyst/an-overview-of-the-synthetic-aperture-radar-toolset.htm>
13. 光谱分析工具集概览：<https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/image-analyst/an-overview-of-the-spectral-analysis-toolset-in-image-analyst.html>
14. 深度学习工具集概览：<https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/image-analyst/an-overview-of-the-deep-learning-toolset-in-image-analyst.htm>
15. Image Analyst 扩展模块常见问题（PDF）：<https://content.esri.com/resources/imageanalyst/imageanalystextension_faq_v02.pdf>

**栅格函数**
16. ArcGIS Spatial Analyst 栅格函数列表：<https://pro.arcgis.com/zh-cn/pro-app/3.5/help/analysis/spatial-analyst/basics/list-of-arcgis-spatial-analyst-raster-functions.htm>
17. List of ArcGIS Spatial Analyst raster functions（英文，Pro 3.7）：<https://pro.arcgis.com/en/pro-app/latest/help/analysis/spatial-analyst/basics/list-of-arcgis-spatial-analyst-raster-functions.htm>
18. 栅格函数：<https://doc.esri.com/zh-cn/arcgis-pro/latest/help/analysis/raster-functions/raster-functions.html>
19. 栅格函数（英文，Pro 3.7）：<https://pro.arcgis.com/en/pro-app/latest/help/analysis/raster-functions/raster-functions.htm>
20. 全局函数：<https://pro.arcgis.com/zh-cn/pro-app/latest/help/analysis/raster-functions/global-functions.htm>
21. List of raster functions（Portal 11.3）：<https://env1.arcgis.com/arcgis/help/en/portal/11.3/use/use-raster-functions-to-customize-raster-analysis.htm>
22. An overview of the Image Analysis functions：<https://pro.arcgis.com/en/pro-app/3.4/arcpy/image-analyst/an-overview-of-the-image-analyst-functions.htm>

**许可与扩展模块**
23. 使用扩展模块：<https://pro.arcgis.com/zh-cn/pro-app/3.5/get-started/use-extensions-in-arcgis-pro.htm>

---

## 八、版本与口径声明

1. **文档版本基准**：本文以 ArcGIS Pro 3.7 中文帮助文档为主要基准，辅以 Pro 3.4/3.5/3.6 英文文档交叉核对。工具清单截至 Pro 3.7 发布时的公开条目。
2. **版本引入信息未区分**：本文按用户要求仅标注许可类型，未逐项注明工具首次引入的 Pro 版本。若需用于采购或版本升级决策，建议对照 Esri 各版本发布说明补充版本引入时间。
3. **中文翻译滞后处理**：Pro 3.4+ 新增工具的部分中文文档翻译可能存在滞后或缺失，本文保留英文名并在正文中标注"中文名疑似需以实际版本为准"的条目（主要是 IA 深度学习工具集新增项与 SA 表面分析新增项）。实际使用时请以本机 Pro 的"工具帮助"为准。
4. **工具数量级说明**：本文标注的工具数量级（Spatial Analyst 200+、Image Analyst 90+、栅格函数 170+）为基于官方清单的估算值，因版本差异与工具集归属调整可能存在 ±5% 波动，不宜作为采购席位数量的依据。
5. **清单完整性边界**：本文不收录 Data Management 工具箱中的栅格数据管理工具（如 Raster To Geodatabase、Create Raster Dataset、Mosaic Dataset 相关工具），因其属数据管理而非空间分析；不收录 3D Analyst 的 LAS 数据集工具（属点云处理范畴）；不收录 Geostatistical Analyst 工具箱（其输出以矢量预测面为主，已在《矢量分析工具清单》收录）。
6. **交叉引用约定**：凡输出为矢量要素类或表的工具，本文仅在正文中以"已在矢量清单收录"注明，不重复展开参数与用法，以保持两份清单的互斥性与互补性。

---

*文档生成日期：2026 年 10 月 17 日*
*基准版本：ArcGIS Pro 3.7*
*许可标注粒度：扩展模块级（Basic / Spatial Analyst / Image Analyst / 仅 Basic）*
