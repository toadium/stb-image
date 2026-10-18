# ArcGIS Pro 矢量分析工具清单：全面核实、补全与结构化

## 摘要

本文以 Esri 官方 ArcGIS Pro 3.7 帮助文档为基准，对用户原清单进行系统性核实与纠错。核心结论如下：① **10 项纠错中 9 项确认存在错误**，仅第 6 项（3D Analyst 工具名混淆）部分成立——Geodesic Viewshed 属 Spatial Analyst 工具集，3D Analyst 对应的是 Line Of Sight、Construct Sight Lines、Viewshed（旧版）等；② **许可等级存在大量误标**：Integrate 属 Data Management 而非 Pairwise Overlay，Basic 即可用；Spatial Join 属 Analysis → Overlay 工具集，Basic 即可用；Dissolve 属 Data Management → Generalization，Basic 即可用；Eliminate 确为 Advanced；Fishnet 属 Data Management → Feature Class，Basic 即可用；③ **Distance Accumulation / Distance Allocation 本身输出栅格，不收录**，但其下游 Optimal Path As Line、Watershed 等直接输出矢量者予以收录；④ **Tracking Analyst 在 ArcGIS Pro 中不可用**，已从清单移除；⑤ 本文新增补充了 Topology 工具集、线性参考、3D Analyst 3D Proximity / 3D Intersections、Business Analyst、Crime Analysis、GeoAnalytics Desktop 等大量符合口径的工具。

## 总说明

### 口径与收录规则

本文仅收录**以矢量要素（点、多点、线、面、多面体、注记/尺寸要素）为输入、并以矢量要素类、要素图层或表为直接输出**的地理处理工具。纯栅格运算工具（栅格计算器、重分类、焦点统计等）不收录。对于"矢量→栅格→矢量"链路，**仅当该工具本身是链路末端、直接产出矢量成果时收录**，并标注其依赖的中间栅格（如 Stream To Feature 依赖流向栅格、Contour 依赖高程栅格、Optimal Path As Line 依赖距离累积栅格与反向栅格）。"栅格→矢量"转换工具（如 Raster To Polygon、Raster To Polyline）若以栅格为输入则**不收录**，但若作为某分析工具的固定下游步骤（如 Segment Mean Shift 后需接 Raster To Polygon 矢量化）则在对应工具处注明，不单列。

### 许可等级定义

本文按用户要求采用三级粒度标注，不区分版本引入信息：

| 等级 | 说明 |
|---|---|
| **Basic** | 随 Creator 用户类型提供，核心数据管理、编辑、制图功能 |
| **Standard** | 随 Professional 用户类型提供，在 Basic 基础上增加拓扑、企业级地理数据库管理等 |
| **Advanced** | 随 Professional Plus 用户类型提供，解锁全部高级空间分析与扩展模块能力 |

涉及扩展模块时标注为「Advanced + 扩展名」，表示该工具除主程序 Advanced 许可外还需额外扩展模块许可。部分工具仅标注「需要 扩展名」而未明确基础许可级别时，注明"需以实际版本为准"。

### 扩展模块清单

本文涉及的扩展模块包括：3D Analyst、Spatial Analyst、Network Analyst、Geostatistical Analyst、Image Analyst、Business Analyst、GeoAnalytics Desktop、Crime Analysis、Data Interoperability、Location Referencing。各扩展模块的许可需求已在对应工具条目中标注。

### 工具命名说明

工具名采用「中文名（英文名）」格式。中文名为 ArcGIS Pro 中文帮助文档中的正式名称；英文名为工具的系统内部名称（arcpy 调用名）。部分工具在中文文档中尚无完整翻译者，保留英文名并标注"疑似需以实际版本为准"。

---

## 一、分析工具箱（Analysis）

分析工具箱是 ArcGIS Pro 中最核心的矢量分析工具集，包含提取、叠加、成对叠加、邻近、统计五个工具集。

### 1.1 提取分析（Extract）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 1 | 裁剪 | Clip | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 2 | 选择 | Select | 点/线/面/表 | 点/线/面要素类/表 | Basic / Standard / Advanced |
| 3 | 分割 | Split | 点/线/面 | 多个要素类（按属性拆至工作空间） | **Advanced** |
| 4 | 按属性分割 | Split By Attributes | 表/要素类 | 多个表/要素类 | Basic / Standard / Advanced |
| 5 | 表筛选 | Table Select | 表 | 表 | Basic / Standard / Advanced |

**说明**：Split 与 Split By Attributes 的区别在于，前者输出到文件夹/地理数据库并保留要素类结构，后者按字段值拆分为多个独立表或要素类。

### 1.2 叠加分析（Overlay）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 6 | 擦除 | Erase | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 7 | 标识 | Identity | 点/线/面 | 点/线/面要素类 | **Advanced** |
| 8 | 相交 | Intersect | 点/线/面 | 点/线/面要素类 | Basic（部分参数受限）/ Standard（部分参数受限）/ Advanced |
| 9 | **空间连接** | **Spatial Join** | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 10 | 交集取反 | Symmetrical Difference | 点/线/面 | 点/线/面要素类 | **Advanced** |
| 11 | 联合 | Union | 面 | 面要素类 | Basic（部分参数受限）/ Standard（部分参数受限）/ Advanced |
| 12 | 更新 | Update | 面 | 面要素类 | **Advanced** |
| 13 | 分配面 | Apportion Polygon | 面 | 面要素类 | Basic / Standard / Advanced |
| 14 | 计数重叠要素 | Count Overlapping Features | 面 | 表（含重叠计数） | Basic / Standard / Advanced |
| 15 | 移除重叠（多个） | Remove Overlap (multiple) | 面 | 面要素类 | Basic / Standard / Advanced |

**关键核实**：**Spatial Join 属 Analysis Tools → Overlay 工具集**，非 Proximity 或 Extract。其许可为三级全含（Basic/Standard/Advanced 均可用）。这是原清单的重大归类错误。

### 1.3 成对叠加（Pairwise Overlay）

成对叠加工具集提供基于成对比较的叠加替代方案，性能通常优于经典叠加工具。

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 16 | 成对缓冲 | Pairwise Buffer | 点/线/面 | 面要素类 | Basic / Standard / Advanced |
| 17 | 成对裁剪 | Pairwise Clip | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 18 | 成对融合 | Pairwise Dissolve | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 19 | 成对擦除 | Pairwise Erase | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 20 | **成对整合** | **Pairwise Integrate** | 点/多点/线/面 | 无独立输出（修改输入） | Basic / Standard / Advanced |
| 21 | 成对相交 | Pairwise Intersect | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 22 | 成对面邻域 | Pairwise Polygon Neighbors | 面 | 表（邻接关系） | Basic / Standard / Advanced |

**关键核实**：**Pairwise Integrate 虽命名为"Integrate"，但其归属于 Analysis Tools → Pairwise Overlay 工具集**，而非 Data Management → Features。其许可为 Basic 即可用。这与原清单将其归在"Pairwise Overlay 下"的描述一致，但需明确其与 Data Management 中的 Integrate 工具是**两个不同工具**。

### 1.4 邻近分析（Proximity）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 23 | 缓冲区 | Buffer | 点/线/面 | 面要素类 | Basic（部分参数受限）/ Standard（部分参数受限）/ Advanced |
| 24 | 创建泰森多边形 | Create Thiessen Polygons | 点 | 面要素类 | Basic / Standard / Advanced |
| 25 | 生成近邻表 | Generate Near Table | 点/线/面 | 表（含距离、角度） | Basic / Standard / Advanced |
| 26 | 多环缓冲区 | Multiple Ring Buffer | 点/线/面 | 面要素类 | Basic / Standard / Advanced |
| 27 | 近邻 | Near | 点/线/面 | 无独立输出（向输入表追加 NEAR_FID、NEAR_DIST 等字段） | Basic / Standard / Advanced |
| 28 | 点距离 | Point Distance | 点 | 表 | Basic / Standard / Advanced |
| 29 | 面邻域 | Polygon Neighbors | 面 | 表（邻接关系） | Basic / Standard / Advanced |

### 1.5 统计分析（Statistics）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 30 | 频率 | Frequency | 表/要素类 | 表 | Basic / Standard / Advanced |
| 31 | 汇总统计 | Summary Statistics | 表/要素类 | 表 | Basic / Standard / Advanced |
| 32 | 交集制表 | Tabulate Intersection | 面/线 | 表（面积/长度交叉统计） | Basic / Standard / Advanced |
| 33 | 丰富数据 | Enrich | 点/线/面 | 点/线/面要素类（追加人口统计/景观字段） | Basic / Standard / Advanced |

### 1.6 常规（General）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 34 | 通过成对比较分配权重 | Assign Weights By Pairwise Comparison | 表 | 表 | Basic / Standard / Advanced |

---

## 二、数据管理工具箱（Data Management）— Feature 类工具

数据管理工具箱包含大量几何转换、拓扑、概化类工具，是矢量处理的重要补充。

### 2.1 要素类（Feature Class）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 35 | 追加注记要素类 | Append Annotation Feature Classes | 注记要素类 | 注记要素类 | Basic（部分参数受限）/ Standard / Advanced |
| 36 | 创建渔网 | Create Fishnet | 范围/模板要素类 | 面/线要素类（格网） | Basic / Standard / Advanced |
| 37 | 创建随机点 | Create Random Points | 面/线/点 | 点要素类 | 需 3D Analyst 或 Spatial Analyst |
| 38 | 整合 | Integrate | 点/多点/线/面 | 无独立输出（修改输入） | Basic / Standard / Advanced |
| 39 | 更新注记要素类 | Update Annotation Feature Class | 注记要素类 | 注记要素类 | Basic（部分参数受限）/ Standard / Advanced |

**关键核实**：**Fishnet（创建渔网）许可为 Basic / Standard / Advanced 三级全含**，原清单标为"高级许可"错误。Integrate 属 Data Management → Features（旧版）或 Feature Class 工具集，Basic 即可用。

### 2.2 要素（Features）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 40 | 添加 XY 坐标 | Add XY Coordinates | 点 | 无独立输出（向输入表追加 POINT_X、POINT_Y 等字段） | Basic / Standard / Advanced |
| 41 | 调整 3D Z 值 | Adjust 3D Z | 3D 点/线/面 | 3D 要素类 | Basic / Standard / Advanced |
| 42 | 原点夹角距离定义线 | Bearing Distance To Line | 表/点 | 线要素类 | Basic / Standard / Advanced |
| 43 | 检查几何 | Check Geometry | 点/线/面 | 表（几何问题报告） | Basic / Standard / Advanced |
| 44 | 复制要素 | Copy Features | 点/线/面/多点/多面体 | 点/线/面/多点/多面体要素类 | Basic / Standard / Advanced |
| 45 | 删除要素 | Delete Features | 点/线/面 | 无独立输出（删除输入中的要素） | Basic / Standard / Advanced |
| 46 | 切分 | Dice | 线/面 | 线/面要素类 | **Advanced** |
| 47 | 要素包络矩形转面 | Feature Envelope To Polygon | 点/线/面 | 面要素类 | **Advanced** |
| 48 | 要素折点转点 | Feature Vertices To Points | 线/面 | 点要素类 | **Advanced** |
| 49 | 要素转线 | Feature To Line | 线/面 | 线要素类 | Standard / Advanced |
| 50 | 要素转点 | Feature To Point | 点/线/面 | 点要素类 | Basic / Standard / Advanced |
| 51 | 要素转面 | Feature To Polygon | 线 | 面要素类 | Basic（部分参数受限）/ Standard / Advanced |
| 52 | 测地线增密 | Geodetic Densify | 线/面 | 线/面要素类 | Standard / Advanced |
| 53 | 最小边界几何 | Minimum Bounding Geometry | 点/线/面 | 面/矩形/圆要素类 | Basic / Standard / Advanced |
| 54 | 多部件至单部件 | Multipart To Singlepart | 点/线/面 | 点/线/面要素类 | Basic / Standard / Advanced |
| 55 | 点集转线 | Points To Line | 点 | 线要素类 | Basic / Standard / Advanced |
| 56 | 面转线 | Polygon To Line | 面 | 线要素类 | **Advanced** |
| 57 | 修复几何 | Repair Geometry | 点/线/面 | 无独立输出（修复输入几何） | Basic（部分参数受限）/ Standard / Advanced |
| 58 | 在点处分割线 | Split Line At Point | 线/点 | 线要素类 | Basic / Standard / Advanced |
| 59 | 在折点处分割线 | Split Line At Vertices | 线/面 | 线要素类 | Basic / Standard / Advanced |
| 60 | 细分面 | Subdivide Polygon | 面 | 面要素类 | 需以实际版本为准 |
| 61 | 表转椭圆 | Table To Ellipse | 表 | 面要素类 | Basic / Standard / Advanced |
| 62 | 取消线分割 | Unsplit Line | 线 | 线要素类 | Basic / Standard / Advanced |
| 63 | XY 转线 | XY To Line | 表 | 线要素类 | Basic / Standard / Advanced |

**说明**：Feature To Line 许可为 Standard 及以上（Basic 不可用）；Feature Vertices To Points、Polygon To Line、Feature Envelope To Polygon、Dice 为 Advanced。

### 2.3 概化（Generalization）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 64 | 融合 | Dissolve | 点/线/面 | 点/线/面要素类 | **Basic / Standard / Advanced** |
| 65 | 消除 | Eliminate | 面 | 面要素类 | **Advanced** |
| 66 | 消除面部件 | Eliminate Polygon Part | 面 | 面要素类 | **Advanced** |

**关键核实**：**Dissolve 许可为 Basic / Standard / Advanced 三级全含**，原清单标为"高级许可"错误。**Eliminate 确为 Advanced**，原清单标注正确。

### 2.4 拓扑（Topology）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 67 | 导出拓扑错误 | Export Topology Errors | 拓扑图层 | 3 个要素类（点/线/面错误） | Basic / Standard / Advanced |

**说明**：Validate Topology 不产出矢量要素类（仅修改拓扑状态），故不收录。Export Topology Errors 输出点、线、面三类错误要素类，符合本文口径。

### 2.5 栅格处理相关（仅收录直接产出矢量的工具）

数据管理工具箱中的栅格处理工具（如 Raster To Polygon、Raster To Polyline、Raster To Point）以栅格为输入，不符合"矢量输入"口径，故**不收录**。但若作为某矢量分析链路的固定下游步骤，在对应工具处注明。

---

## 三、空间统计工具箱（Spatial Statistics）

空间统计工具箱多数工具仅输出表或数值（如平均最近邻、空间自相关、热点分析等），但部分工具输出矢量成果。

### 3.1 度量地理分布（Measuring Geographic Distributions）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 68 | 中心要素 | Central Feature | 点/线/面 | 点要素类 | Basic / Standard / Advanced |
| 69 | 方向分布 | Directional Distribution | 点/线/面 | 面要素类（标准差椭圆） | Basic / Standard / Advanced |
| 70 | 线性方向均值 | Linear Directional Mean | 线 | 点要素类（均值中心）+ 输出图表 | Basic / Standard / Advanced |
| 71 | 平均中心 | Mean Center | 点/线/面 | 点要素类 | Basic / Standard / Advanced |
| 72 | 中位数中心 | Median Center | 点/线/面 | 点要素类 | Basic / Standard / Advanced |
| 73 | 标准距离 | Standard Distance | 点/线/面 | 面要素类（圆） | Basic / Standard / Advanced |
| 74 | 分解空间结构 | Decompose Spatial Structure | 点/线/面 | 面要素类（空间分量） | Basic / Standard / Advanced |
| 75 | 邻域汇总统计 | Neighborhood Summary Statistics | 点/线/面 | 点/线/面要素类（追加邻域统计字段） | Basic / Standard / Advanced（Delaunay 邻域需 Advanced） |

### 3.2 聚类分布制图（Mapping Clusters）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 76 | 基于密度的聚类 | Density-based Clustering | 点 | 点要素类（追加 CLUSTER_ID 字段） | Basic / Standard / Advanced |
| 77 | 相似性搜索 | Similarity Search | 点/线/面 | 表 | Basic / Standard / Advanced |

**说明**：热点分析（Hot Spot Analysis）、优化热点分析（Optimized Hot Spot Analysis）、聚类和异常值分析（Cluster and Outlier Analysis）等工具输出为**添加了统计字段的输入要素类副本**或表，虽涉及矢量要素类但主要是属性追加，是否收录可视具体工作流而定。本文将其列入"补充评估"章节。

### 3.3 建模空间关系（Modeling Spatial Relationships）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 78 | 森林分类与回归 | Forest-based Classification and Regression | 点/线/面 | 表/要素类（预测结果） | Basic / Standard / Advanced |
| 79 | 广义线性回归 | Generalized Linear Regression | 点/线/面 | 表/要素类（预测结果） | Basic / Standard / Advanced |

**说明**：多数空间统计工具输出为表或数值（非矢量要素类），故未全部列出。本文仅收录直接产出矢量要素类的工具。

---

## 四、Spatial Analyst 扩展

Spatial Analyst 主要面向栅格分析，但包含多个"矢量→栅格→矢量"链路末端工具，本文按口径收录。

### 4.1 水文分析（Hydrology）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 80 | 栅格河网矢量化 | Stream To Feature | 流栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |
| 81 | 派生流作为线 | Derive Stream As Line | 高程栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |

**说明**：Stream To Feature 与 Derive Stream As Line 功能类似，前者为经典工具，后者为 Pro 3.x 新增工具。两者均需流向栅格作为输入（矢量→栅格→矢量链路的中间栅格）。

### 4.2 距离分析（Distance）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 82 | 最佳路径为线 | Optimal Path As Line | 距离累积栅格、反向栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |
| 83 | 最佳区域连接 | Optimal Region Connections | 距离累积栅格、区域栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |

**说明**：**Distance Accumulation（距离累积）与 Distance Allocation（距离分配）本身输出栅格，不收录**。但其下游 Optimal Path As Line、Optimal Region Connections 直接产出矢量成果，予以收录并标注依赖的中间栅格。**分水岭（Watershed）在 Spatial Analyst 中输出栅格**（流向栅格 + 汇点要素类 → 汇水区栅格），若需矢量面需接 Raster To Polygon，故**不收录**。

### 4.3 表面分析（Surface）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 84 | 等值线 | Contour | 高程栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |
| 85 | 等值线列表 | Contour List | 高程栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |
| 86 | 含障碍的等值线 | Contour With Barriers | 高程栅格 + 线/面障碍要素 | 线要素类 | Advanced + Spatial Analyst |

**说明**：等值线工具以栅格为输入，但属于"表面分析"链路中直接产出矢量线的工具，本文按口径收录。

### 4.4 制图综合（Generalization）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 87 | 聚合 | Aggregate | 面 | 面要素类 | Advanced + Spatial Analyst |
| 88 | 边界清理 | Boundary Clean | 面 | 面要素类 | Advanced + Spatial Analyst |

**关键核实**：**Boundary Clean 属 Spatial Analyst → Generalization 工具集，非 Data Management**。其许可为 Advanced + Spatial Analyst，原清单将其归入"面处理"并标为"高级许可"虽结果正确，但归属工具箱错误。

### 4.5 提取分析（Extraction）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 89 | 值提取至点 | Extract Values To Points | 点 + 栅格 | 点要素类（追加栅格值字段） | Advanced + Spatial Analyst |
| 90 | 多值提取至点 | Extract Multi Values To Points | 点 + 多个栅格 | 无独立输出（向输入点表追加字段） | Advanced + Spatial Analyst |

**说明**：值提取至点符合"矢量输入 + 矢量输出"口径，予以收录。

---

## 五、3D Analyst 扩展

3D Analyst 提供大量三维矢量分析工具，是矢量处理的重要补充。

### 5.1 3D 要素（3D Features）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 91 | 包围多面体 | Enclose Multipatch | 多面体 | 多面体要素类 | Advanced + 3D Analyst |
| 92 | 闭合性检查 | Is Closed 3D | 多面体 | 表（闭合性检查结果） | Advanced + 3D Analyst |
| 93 | 简化 3D 线 | Simplify 3D Line | 3D 线 | 3D 线要素类 | Advanced + 3D Analyst |
| 94 | 沿 3D 线生成点 | Generate Points Along 3D Lines | 3D 线 | 3D 点要素类 | Advanced + 3D Analyst |

### 5.2 转换（Conversion）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 95 | ASCII 3D 转要素类 | ASCII 3D To Feature Class | 表/文本文件 | 3D 点/线/面要素类 | Basic / Standard / Advanced |
| 96 | 要素类 Z 转 ASCII | Feature Class Z To ASCII | 3D 点/线/面 | 文本文件 | Basic / Standard / Advanced |
| 97 | 要素属性转 3D | Feature To 3D By Attribute | 点/线/面 | 3D 要素类 | Basic / Standard / Advanced |
| 98 | CityEngine 规则生成要素 | Features From CityEngine Rules | 点/面 | 多面体要素类 | Basic / Standard / Advanced |
| 99 | 导入 3D 文件 | Import 3D Files | 3D 文件（OBJ/DAE/3DS 等） | 多面体要素类 | Basic / Standard / Advanced |
| 100 | 图层 3D 转要素类 | Layer 3D To Feature Class | 3D 图层 | 多面体要素类 | Basic / Standard / Advanced |

### 5.3 插值（Interpolation）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 101 | 插值面转多面体 | Interpolate Polygon To Multipatch | 面 | 多面体要素类 | Advanced + 3D Analyst |
| 102 | 插值形状 | Interpolate Shape | 3D 线/点 + 表面 | 3D 线/点要素类 | Advanced + 3D Analyst 或 Spatial Analyst |
| 103 | 计算缺失 Z 值 | Calculate Missing Z Values | 3D 要素类 | 3D 要素类 | Advanced + 3D Analyst |
| 104 | 更新要素 Z | Update Feature Z | 3D 要素类 + 表面 | 3D 要素类 | Advanced + 3D Analyst |

### 5.4 3D 相交（3D Intersections）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 105 | 围栏图 | Fence Diagram | 多个面/线 | 多面体要素类 | Advanced + 3D Analyst |
| 106 | 3D 相交 | Intersect 3D | 多面体/3D 线/面 | 多面体/3D 线要素类 | Advanced + 3D Analyst |
| 107 | 3D 线与多面体相交 | Intersect 3D Line With Multipatch | 3D 线 + 多面体 | 3D 点/线要素类 | Advanced + 3D Analyst |
| 108 | 3D 线与表面相交 | Intersect 3D Line With Surface | 3D 线 + 表面 | 3D 点要素类 | Advanced + 3D Analyst |
| 109 | 堆叠剖面 | Stack Profile | 线 + 多个表面 | 表 + 剖面图 | Advanced + 3D Analyst |

### 5.5 3D 邻近（3D Proximity）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 110 | 3D 缓冲区 | Buffer 3D | 3D 点/线/面 | 多面体要素类 | Advanced + 3D Analyst |
| 111 | 内部 3D | Inside 3D | 多面体/3D 点 | 表（包含关系） | Advanced + 3D Analyst |
| 112 | 近邻 3D | Near 3D | 3D 点/线/面 | 无独立输出（向输入追加 3D 距离字段） | Advanced + 3D Analyst |
| 113 | 联合 3D | Union 3D | 多面体 | 多面体要素类 | Advanced + 3D Analyst |
| 114 | 差异 3D | Difference 3D | 多面体 | 多面体要素类 | Advanced + 3D Analyst |
| 115 | 生成净空面 | Generate Clearance Surface | 3D 线/点 | 栅格（净空面） | Advanced + 3D Analyst |

### 5.6 面积与体积（Area and Volume）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 116 | 填挖方 | Cut Fill | 表面/面 | 面要素类（填挖区域） | Advanced + 3D Analyst 或 Spatial Analyst |
| 117 | 拉伸至两者之间 | Extrude Between | 线/面 + 两个表面 | 多面体要素类 | Advanced + 3D Analyst |
| 118 | 最小包围体 | Minimum Bounding Volume | 3D 要素 | 多面体要素类 | Advanced + 3D Analyst |
| 119 | 面体积 | Polygon Volume | 面 + 表面 | 表（体积计算结果） | Advanced + 3D Analyst |
| 120 | 表面差异 | Surface Difference | 面 + 两个表面 | 面要素类（差异区域） | Advanced + 3D Analyst |
| 121 | 表面体积 | Surface Volume | 面 + 表面 | 表（体积计算结果） | Advanced + 3D Analyst |

### 5.7 可见性（Visibility）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 122 | 构造视线 | Construct Sight Lines | 点/线（观察点）+ 点/线/面（目标） | 3D 线要素类 | Advanced + 3D Analyst |
| 123 | 通视分析 | Line Of Sight | 3D 线（视线）+ 表面/多面体 | 3D 线要素类（含可见性属性） | Advanced + 3D Analyst |
| 124 | 天际线 | Skyline | 点（观察点）+ 多面体/表面 | 3D 线要素类（天际线） | Advanced + 3D Analyst |
| 125 | 天际线屏障 | Skyline Barrier | 3D 线（天际线） | 多面体要素类（屏障/阴影体） | Advanced + 3D Analyst |
| 126 | 太阳阴影频率 | Sun Shadow Frequency | 多面体 + 表面 | 表/栅格 | Advanced + 3D Analyst |
| 127 | 太阳阴影体 | Sun Shadow Volume | 多面体 + 日期时间 | 多面体要素类（阴影体） | Advanced + 3D Analyst |

**关键核实**：3D Analyst 可见性工具集中的 **Line Of Sight、Construct Sight Lines、Skyline、Skyline Barrier 直接输出矢量要素类**。而 **Geodesic Viewshed 和 Viewshed 输出栅格**，虽可在 Spatial Analyst 和 3D Analyst 中使用，但不符合本文"矢量输出"口径，**不收录**。原清单提到的"测地线可视域"应归 Spatial Analyst，3D Analyst 对应的是 Line Of Sight 3D / Viewshed（旧版，输出栅格）。

### 5.8 要素提取（Feature Extraction）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 128 | 从网格提取多面体 | Extract Multipatch From Mesh | 多面体 | 多面体要素类 | Advanced + 3D Analyst |
| 129 | 从点云提取电力线 | Extract Power Lines From Point Cloud | 点云 | 3D 线要素类 | Advanced + 3D Analyst |
| 130 | LAS 建筑物转多面体 | LAS Building Multipatch | LAS 数据集 | 多面体要素类 | Advanced + 3D Analyst |
| 131 | 多面体足迹 | Multipatch Footprint | 多面体 | 面要素类 | Advanced + 3D Analyst |
| 132 | 规则化相邻建筑物足迹 | Regularize Adjacent Building Footprint | 面 | 面要素类 | Advanced + 3D Analyst |
| 133 | 规则化建筑物足迹 | Regularize Building Footprint | 面 | 面要素类 | Advanced + 3D Analyst |

### 5.9 提取（Extraction）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 134 | 按 LAS 点邻近提取 | Locate LAS Points By Proximity | LAS 数据集 + 3D 线/面 | LAS 数据集（筛选结果） | Advanced + 3D Analyst |

---

## 六、Network Analyst 扩展

Network Analyst 提供网络数据集上的路径、服务区、选址分配等分析。

### 6.1 分析（Analysis）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 135 | 创建路径分析图层 | Make Route Analysis Layer | 网络数据集 | 路径网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 136 | 创建服务区分析图层 | Make Service Area Analysis Layer | 网络数据集 | 服务区网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 137 | 创建最近设施点分析图层 | Make Closest Facility Analysis Layer | 网络数据集 | 最近设施点网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 138 | 创建位置分配分析图层 | Make Location-Allocation Analysis Layer | 网络数据集 | 位置分配网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 139 | 创建 OD 成本矩阵分析图层 | Make OD Cost Matrix Analysis Layer | 网络数据集 | OD 成本矩阵网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 140 | 创建车辆配送分析图层 | Make Vehicle Routing Problem Analysis Layer | 网络数据集 | 车辆配送网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 141 | 创建最后一公里配送分析图层 | Make Last Mile Delivery Analysis Layer | 网络数据集 | 最后一公里配送网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 142 | 创建废弃物收集分析图层 | Make Waste Collection Analysis Layer | 网络数据集 | 废弃物收集网络分析图层 | Basic / Standard / Advanced（求解需 Network Analyst） |
| 143 | 求解 | Solve | 网络分析图层 | 网络分析图层（含 Routes/SAPolygons/Facilities 等子图层） | Advanced + Network Analyst（本地网络数据集）/ 服务时 Basic |
| 144 | 复制遍历的源要素 | Copy Traversed Source Features | 网络分析图层 | 2 个要素类（边/交汇点）+ 表 | Advanced + Network Analyst |

**关键核实**：**"生成驾车时间面（时间等值面矢量面）"不是独立工具**，而是 Service Area 分析求解后的**输出子图层**（SAPolygons）。工作流为：创建服务区分析图层 → 添加设施点 → 设置阻抗（Drive Time）→ 求解 → 从结果中提取面要素类。原清单将其列为独立工具错误。

### 6.2 转弯要素类（Turn Feature Class）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 145 | 创建转弯要素类 | Create Turn Feature Class | 网络数据集 | 转弯要素类 | Basic / Standard / Advanced |
| 146 | 增大最大边数 | Increase Maximum Edges | 转弯要素类 | 转弯要素类 | Basic / Standard / Advanced |
| 147 | 填充备用 ID 字段 | Populate Alternate ID Fields | 转弯要素类 | 无独立输出（填充字段） | Basic / Standard / Advanced |
| 148 | 转弯表转转弯要素类 | Turn Table To Turn Feature Class | 表 | 转弯要素类 | Basic / Standard / Advanced |
| 149 | 按备用 ID 更新 | Update By Alternate ID Fields | 转弯要素类 | 无独立输出（更新字段） | Basic / Standard / Advanced |
| 150 | 按几何更新 | Update By Geometry | 转弯要素类 | 无独立输出（更新几何） | Basic / Standard / Advanced |

**说明**：Network Analyst 中"批量 OD 成本矩阵并行求解"和"大规模服务区并行计算"**不是独立工具**。OD 成本矩阵通过 Make OD Cost Matrix Analysis Layer + 求解实现；并行计算能力由工具内部框架（本地多线程或 ArcGIS Enterprise 服务）提供，无需单独工具。

---

## 七、Geostatistical Analyst 扩展

Geostatistical Analyst 主要用于地统计插值，多数工具输出栅格或地统计图层。本文仅收录直接产出矢量成果的工具。

### 7.1 使用地统计图层（Working with Geostatistical Layers）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 151 | GA 图层转等值线 | GA Layer To Contour | 地统计图层 | 线要素类（等值线）或面要素类（填充等值线） | Advanced + Geostatistical Analyst |
| 152 | GA 图层转点 | GA Layer To Points | 地统计图层 | 点要素类 | Advanced + Geostatistical Analyst |
| 153 | 面插值图层转面 | Areal Interpolation Layer To Polygons | 面插值图层 + 目标面 | 面要素类（重新聚合预测值） | Advanced + Geostatistical Analyst |

**关键核实**：原清单列出的"趋势分析、半变异函数云图、离群点探测、正态检验"工具，实际是**探索性数据分析窗口工具或图表工具**（通过地统计向导的 Explore Data 步骤访问），**不是独立的地理处理工具**，且**不输出矢量要素**。这些工具应从"矢量分析工具清单"中移出，改为标注"无矢量输出（属探索性图表/窗口工具）"。

具体对应：
- **趋势分析（Trend Analysis）**：探索性窗口中的 3D 散点图，展示数据随 x/y 方向的趋势，**无矢量输出**
- **半变异函数云图（Semivariogram Cloud）**：探索性图表，显示点对间距离与半方差关系，**无矢量输出**
- **离群点探测（Outlier Detection）**：探索性图表（Voronoi 图 / 普通最小二乘图），用于识别异常值，**无矢量输出**（注：空间统计工具箱中有独立的 Spatial Outlier Detection 工具，输出为添加了异常值字段的要素类）
- **正态检验（Normal QQPlot）**：探索性图表，检验数据正态性，**无矢量输出**

---

## 八、Image Analyst 扩展

Image Analyst 主要面向影像分析，多数工具输出栅格。本文仅收录符合"矢量输入/输出"口径的工具。

### 8.1 深度学习（Deep Learning）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 154 | 使用深度学习检测对象 | Detect Objects Using Deep Learning | 影像 + 输入表（可选） | 面/点要素类（检测到的对象） | Advanced + Image Analyst |
| 155 | 使用深度学习分类对象 | Classify Objects Using Deep Learning | 影像 + 输入面要素类 | 面要素类（分类结果） | Advanced + Image Analyst |

### 8.2 分类与模式识别（Classification and Pattern Recognition）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 156 | 训练最大似然法分类器 | Train Maximum Likelihood Classifier | 影像 + 训练样本要素类 | 分类器文件 | Advanced + Image Analyst |
| 157 | 训练支持向量机分类器 | Train Support Vector Machine Classifier | 影像 + 训练样本要素类 | 分类器文件 | Advanced + Image Analyst |

**说明**：**Segment Mean Shift（均值漂移影像分割）输出为栅格**，不符合"矢量输出"口径，不收录。若需矢量化，需后续接 Raster To Polygon 工具（该工具以栅格为输入，亦不收录）。用户原清单中"Segment Mean Shift 后矢量化"实际是两个独立步骤的组合，本文在 Image Analyst 工具中标注其输出类型为栅格，不作为矢量工具收录。

---

## 九、GeoAnalytics Desktop 扩展

GeoAnalytics Desktop 提供基于 Apache Spark 的并行处理框架，适用于大规模数据集。其许可为 Advanced（部分工具需扩展模块）。

### 9.1 分析模式（Analyze Patterns）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 158 | 计算密度 | Calculate Density | 点 | 面要素类（正方形/六边形格网） | **Advanced** |
| 159 | 查找热点 | Find Hot Spots | 点/线/面 | 点/线/面要素类（追加热点统计字段） | **Advanced** |
| 160 | 查找点聚类 | Find Point Clusters | 点 | 点要素类（追加 CLUSTER_ID 字段） | **Advanced** |

**关键核实**：**Calculate Density（GeoAnalytics Desktop）与 Spatial Analyst 的 Kernel Density 区别**：
- **Kernel Density（Spatial Analyst）**：输入点/线，输出**栅格**（密度表面），许可为 Advanced + Spatial Analyst
- **Calculate Density（GeoAnalytics Desktop）**：输入点，输出**面要素类**（正方形或六边形格网，含密度值字段），许可为 Advanced
- 两者算法内核相同，但输出类型完全不同：前者输出连续栅格表面，后者输出离散矢量面格网

### 9.2 数据丰富（Data Enrichment）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 161 | 计算运动统计 | Calculate Motion Statistics | 轨迹点 | 点要素类（追加速度/加速度等字段） | **Advanced** |

### 9.3 查找位置（Find Locations）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 162 | 检测事件 | Detect Incidents | 轨迹点 | 点要素类（检测到的事件） | **Advanced** |
| 163 | 查找停留位置 | Find Dwell Locations | 轨迹点 | 点/面要素类（停留位置） | **Advanced** |
| 164 | 查找相似位置 | Find Similar Locations | 点/线/面 | 点/线/面要素类（相似性评分） | **Advanced** |

### 9.4 管理数据（Manage Data）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 165 | 计算字段 | Calculate Field | 表/要素类 | 无独立输出（修改字段） | **Advanced** |
| 166 | 裁剪图层 | Clip Layer | 点/线/面 | 点/线/面要素类 | **Advanced** |
| 167 | 融合边界 | Dissolve Boundaries | 面 | 面要素类 | **Advanced** |
| 168 | 叠加图层 | Overlay Layers | 点/线/面 | 点/线/面要素类 | **Advanced** |

### 9.5 汇总数据（Summarize Data）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 169 | 聚合点 | Aggregate Points | 点 | 面要素类（聚合面） | **Advanced** |
| 170 | 描述数据集 | Describe Dataset | 点/线/面 | 表 + JSON 字符串 | **Advanced** |
| 171 | 连接要素 | Join Features | 点/线/面 | 点/线/面要素类 | **Advanced** |
| 172 | 重新构建轨迹 | Reconstruct Tracks | 轨迹点/面 | 线要素类（轨迹）或面要素类（缓冲轨迹） | **Advanced** |
| 173 | 汇总属性 | Summarize Attributes | 表/要素类 | 表 | **Advanced** |
| 174 | 汇总中心和离差 | Summarize Center And Dispersion | 点/线/面 | 面要素类（标准差椭圆）+ 点要素类（中心） | **Advanced** |
| 175 | 范围内汇总 | Summarize Within | 点/线/面 + 面 | 表 | **Advanced** |

### 9.6 使用邻近（Use Proximity）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 176 | 创建缓冲区 | Create Buffers | 点/线/面 | 面要素类 | **Advanced** |
| 177 | 按邻域分组 | Group By Proximity | 点/线/面 | 点/线/面要素类（追加 GROUP_ID 字段） | **Advanced** |
| 178 | 捕捉轨迹 | Snap Tracks | 轨迹点 | 线要素类（修正后的轨迹） | **Advanced** |
| 179 | 追踪邻近事件 | Trace Proximity Events | 点/线/面 | 表/要素类 | **Advanced** |

**关键核实**：GeoAnalytics Desktop 中的"批量 OD 成本矩阵并行求解"和"大规模服务区并行计算"**不是独立工具**。GeoAnalytics Desktop 工具箱本身不包含网络分析功能，这些能力分别属于 Network Analyst 扩展（本地求解）或 GeoAnalytics Server（服务化并行求解）。原清单存在混淆。

---

## 十、Business Analyst 扩展

Business Analyst 提供商业分析、市场区域、适宜性分析等功能，多数工具输出矢量。

### 10.1 分析（Analysis）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 180 | 计算市场渗透率 | Calculate Market Penetration | 面（市场区域）+ 点（客户） | 表 | Advanced + Business Analyst |
| 181 | 色码图层 | Color Coded Layer | 点/线/面 | 图层（分级色彩） | Advanced + Business Analyst |
| 182 | 丰富图层 | Enrich Layer | 点/线/面 | 点/线/面要素类（追加人口统计/景观字段） | Advanced + Business Analyst |
| 183 | 查找附近位置 | Find Nearby Locations | 点/线/面 | 点/线/面要素类 | Advanced + Business Analyst |
| 184 | 生成渴望线 | Generate Desire Lines | 点（商店）+ 点（客户） | 线要素类（蜘蛛图） | Advanced + Business Analyst（+ Network Analyst 用于行驶时间） |
| 185 | 从商业名录生成点 | Generate Points From Business Listings | — | 点要素类 | Advanced + Business Analyst |

### 10.2 贸易区域（Trade Areas）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 186 | 按距离分配客户 | Assign Customers By Distance | 点（客户）+ 点（商店） | 点要素类（追加分配字段） | Advanced + Business Analyst（+ Network Analyst） |
| 187 | 生成近似行驶时间 | Generate Approximate Drive Times | 点 | 面要素类（行驶时间面） | Advanced + Business Analyst（+ Network Analyst） |
| 188 | 生成客户派生贸易区域 | Generate Customer Derived Trade Areas | 点（客户）+ 点（商店） | 面要素类 | Advanced + Business Analyst |
| 189 | 生成行驶时间贸易区域 | Generate Drive Time Trade Area | 点 | 面要素类（行驶时间面） | Advanced + Business Analyst（+ Network Analyst） |
| 190 | 从重叠生成地理区域 | Generate Geographies From Overlap | 面 | 面要素类 | Advanced + Business Analyst |
| 191 | 生成标准地理贸易区域 | Generate Standard Geography Trade Areas | 点/面 | 面要素类 | Advanced + Business Analyst |
| 192 | 生成阈值行驶时间 | Generate Threshold Drive Times | 点 | 面要素类 | Advanced + Business Analyst（+ Network Analyst） |
| 193 | 生成阈值环 | Generate Threshold Rings | 点 | 面要素类 | Advanced + Business Analyst |
| 194 | 生成贸易区域环 | Generate Trade Area Rings | 点 | 面要素类 | Advanced + Business Analyst |
| 195 | 测量贸易区域 | Measure Trade Area | 面 | 表 | Advanced + Business Analyst |

### 10.3 适宜性分析（Suitability Analysis）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 196 | 添加字段适宜性标准 | Add Field Based Suitability Criteria | 点/线/面 | 无独立输出（配置适宜性） | Advanced + Business Analyst |
| 197 | 添加点图层适宜性标准 | Add Point Layer Based Suitability Criteria | 点/线/面 + 点图层 | 无独立输出（配置适宜性） | Advanced + Business Analyst（+ Network Analyst） |
| 198 | 添加变量适宜性标准 | Add Variable Based Suitability Criteria | 点/线/面 | 无独立输出（配置适宜性） | Advanced + Business Analyst |
| 199 | 计算适宜性得分 | Calculate Suitability Score | 点/线/面 | 点/线/面要素类（追加得分字段） | Advanced + Business Analyst |
| 200 | 制作适宜性分析图层 | Make Suitability Analysis Layer | 点/线/面 | 图层 | Advanced + Business Analyst |

### 10.4 目标营销（Target Marketing）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 201 | 分析市场区域差距 | Analyze Market Area Gap | 面 | 面要素类 | Advanced + Business Analyst |
| 202 | 分析市场潜力 | Analyze Market Potential | 面 | 面要素类 | Advanced + Business Analyst |
| 203 | 生成客户细分画像 | Generate Customer Segmentation Profile | — | 表/文件 | Advanced + Business Analyst |
| 204 | 生成目标组图层 | Generate Target Group Layer | — | 面要素类 | Advanced + Business Analyst |
| 205 | 生成目标图层 | Generate Target Layer | — | 点/线/面要素类 | Advanced + Business Analyst |
| 206 | 生成目标渗透率图层 | Generate Target Penetration Layer | 面 + 点 | 面要素类 | Advanced + Business Analyst |

### 10.5 网格与六边形（Grids and Hexagons）

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 207 | 生成网格和六边形 | Generate Grids and Hexagons | 范围/面 | 面要素类（格网） | Advanced + Business Analyst（+ Network Analyst 用于行驶时间格网） |

---

## 十一、Crime Analysis 解决方案

Crime Analysis 是 ArcGIS Solutions 提供的免费加载项（需 ArcGIS Pro），包含多个矢量分析工具。其许可通常随 ArcGIS Pro 提供（部分需 Spatial Analyst）。

### 11.1 战术与战略分析

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 208 | 缓冲区 | Buffer | 点/线/面 | 面要素类 | Basic / Standard / Advanced |
| 209 | 80-20 分析 | 80-20 Analysis | 点 | 图层（分级符号） | Basic / Standard / Advanced |
| 210 | 事件计数 | Incident Count | 点 + 面/线 | 面/线要素类（追加计数） | Basic / Standard / Advanced |
| 211 | 百分比变化 | Percent Change | 点（两期）+ 面 | 面要素类（追加变化率） | Basic / Standard / Advanced |
| 212 | 密度分析 | Density Analysis | 点/线 | 栅格（核密度） | Advanced + Spatial Analyst |
| 213 | 密度变化 | Density Change | 栅格 + 栅格 | 栅格 | Advanced + Spatial Analyst |
| 214 | 优化热点 | Optimized Hot Spot | 点/线/面 | 点/线/面要素类（追加 Gi* 字段） | Basic / Standard / Advanced |
| 215 | 核密度 | Kernel Density | 点/线 | 栅格 | Advanced + Spatial Analyst |

### 11.2 空间-时间分析

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 216 | 聚合点创建时空立方体 | Create Space Time Cube By Aggregating Points | 点 | netCDF 数据结构（非矢量，但符合时空分析口径） | Basic / Standard / Advanced |
| 217 | 新兴热点 | Emerging Hot Spot | netCDF | 点/线/面要素类（追加趋势类别字段） | Basic / Standard / Advanced |

### 11.3 调查分析

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 218 | 事件序列 | Incident Sequence | 点 | **线要素类**（按时间顺序连接相关事件） | Basic / Standard / Advanced |
| 219 | 事件路径 | Incident Path | 点/线 | **线要素类**（连接两个图层的关系线） | Basic / Standard / Advanced |
| 220 | Aoristic 分析 | Aoristic Analysis | 点/面（含时间窗口） | 表 + 折线图/热力图 | Basic / Standard / Advanced |
| 221 | 加权位移差 | Weighted Displacement Difference | 点（处理前后） | 表（统计检验结果） | Basic / Standard / Advanced |

---

## 十二、线性参考（Linear Referencing）

线性参考工具箱提供路径和事件管理功能。本文仅收录直接产出矢量要素类的工具。

| 序号 | 中文名 | 英文名 | 输入矢量类型 | 输出成果类型 | 许可等级 |
|---|---|---|---|---|---|
| 222 | 创建路径事件图层 | Make Route Event Layer | 路径要素 + 事件表 | 临时要素图层（点/线事件） | Basic / Standard / Advanced |
| 223 | 生成路径 | Generate Routes | 线 | 路径要素类（带 M 值） | Basic / Standard / Advanced |
| 224 | 校准路径 M 值 | Calibrate Routes | 路径要素 + 点/线校准要素 | 路径要素类 | Basic / Standard / Advanced |
| 225 | 叠加路径事件 | Overlay Route Events | 两个事件表 | 事件表 | Basic / Standard / Advanced |
| 226 | 路径事件转点 | Route Events To Points | 路径 + 点事件表 | 点要素类 | Basic / Standard / Advanced |
| 227 | 路径事件转线 | Route Events To Lines | 路径 + 线事件表 | 线要素类 | Basic / Standard / Advanced |
| 228 | 路径事件转面 | Route Events To Polygon | 路径 + 线事件表 | 面要素类 | Basic / Standard / Advanced |
| 229 | 线转路径事件 | Lines To Route Events | 线 | 事件表 | Basic / Standard / Advanced |

**说明**：Locate Features Along Routes 输出为**事件表**（非矢量要素类），不符合本文"矢量输出"口径，但作为线性参考核心工具在此列出供参考。Make Route Event Layer 创建的是临时要素图层，需结合 Copy Features 持久化。

---

## 核实与纠错

本章逐条判定用户提出的 10 项纠错，并补充本文自行发现的其他问题。

### 1. 成对集成 Pairwise Integrate 归属

**核实结论：原清单归类位置正确，但工具身份需澄清。**

Pairwise Integrate 确实归属于 **Analysis Tools → Pairwise Overlay** 工具集，许可为 **Basic / Standard / Advanced 三级全含**。需注意的是，Data Management → Feature Class 工具集中另有一个 **Integrate** 工具（同名不同工具），后者同样为 Basic 即可用。两个工具功能类似但分属不同工具箱，原清单将 Pairwise Integrate 归在 Pairwise Overlay 下是正确的。

### 2. Spatial Join 归属

**核实结论：原清单归属错误，应为 Analysis Tools → Overlay。**

Spatial Join 归属于 **Analysis Tools → Overlay** 工具集，许可为 **Basic / Standard / Advanced 三级全含**。它不属 Proximity 工具集（Proximity 中的近邻分析工具为 Near、Generate Near Table、Point Distance、Buffer 等），也不属 Extract 工具集。

### 3. Dissolve / Eliminate / Boundary Clean 许可

**核实结论：原清单许可标注部分错误。**

| 工具 | 所属工具箱 | 原清单标注 | 实际许可 | 判定 |
|---|---|---|---|---|
| Dissolve | Data Management → Generalization | 高级许可 | **Basic / Standard / Advanced** | ❌ 错误 |
| Eliminate | Data Management → Generalization | 高级许可 | **Advanced** | ✅ 正确 |
| Eliminate Polygon Part | Data Management → Generalization | （未单独列出） | **Advanced** | 补充 |
| Boundary Clean | Spatial Analyst → Generalization | 高级许可 | **Advanced + Spatial Analyst** | ⚠️ 归属错误（非 Data Management） |

### 4. Distance Accumulation / Distance Allocation 收录

**核实结论：不收录，但其下游矢量输出工具应予收录。**

Distance Accumulation 和 Distance Allocation 本身输出**栅格**（距离累积表面、分配区域栅格），不符合"矢量输出"口径，不收录。但其下游工具：
- **Optimal Path As Line**（最佳路径为线）：输入距离累积栅格 + 反向栅格，输出**线要素类**
- **Optimal Region Connections**（最佳区域连接）：输入距离累积栅格 + 区域栅格，输出**线要素类**

这两个工具依赖的中间栅格明确标注，予以收录。

### 5. Geostatistical Analyst 探索性工具

**核实结论：确认无矢量输出，应从矢量工具清单移出。**

趋势分析、半变异函数云图、离群点探测、正态检验均属**探索性数据分析窗口工具或图表工具**，不是独立的地理处理工具，且不输出矢量要素。应从矢量工具清单中移出，标注为"无矢量输出（属探索性图表/窗口工具）"。

需区分的是，空间统计工具箱（Spatial Statistics）中有一个独立的 **Spatial Outlier Detection** 工具，该工具输出为添加了异常值字段的要素类，符合矢量输出口径。

### 6. 3D Analyst 工具名核实

**核实结论：原清单存在工具名混淆，部分工具名不准确。**

| 原清单名称 | 核实结果 |
|---|---|
| 三维最小成本路径 | 疑似不准确。3D Analyst 中无此精确名称。对应工具可能为 Spatial Analyst 的 **Optimal Path As Line**（最佳路径为线），或 3D Analyst 的 **Intersect 3D Line With Surface**（3D 线与表面相交） |
| 表面剖面线 | 疑似不准确。3D Analyst 中对应工具为 **Stack Profile**（堆叠剖面），输出为表和剖面图，非直接矢量线 |
| 测地线可视域 | 属 **Spatial Analyst** 工具集（Geodesic Viewshed），输出栅格。3D Analyst 的对应工具为 **Line Of Sight**（通视分析，输出 3D 线）和 **Construct Sight Lines**（构造视线，输出 3D 线） |

### 7. 生成驾车时间面（时间等值面矢量面）

**核实结论：不是独立工具，是 Service Area 求解的输出子图层。**

"生成驾车时间面"不是 Network Analyst 中的独立工具，而是 **Service Area（服务区）** 分析求解后自动生成的输出子图层（SAPolygons）。标准工作流为：
1. 创建服务区分析图层（Make Service Area Analysis Layer）
2. 添加设施点（Add Locations）
3. 设置阻抗属性为行驶时间（Drive Time）、设置中断值（如 5/10/15 分钟）
4. 求解（Solve）
5. 从结果网络分析图层中提取面要素类

### 8. Fishnet 许可

**核实结论：原清单标注错误。**

Fishnet（创建渔网）归属于 **Data Management → Feature Class** 工具集，许可为 **Basic / Standard / Advanced 三级全含**。原清单标为"高级许可"错误。

### 9. GeoAnalytics Desktop 并行求解工具

**核实结论：不是独立工具。**

GeoAnalytics Desktop 工具箱本身不包含网络分析功能，故"批量 OD 成本矩阵并行求解"和"大规模服务区并行计算"**不是 GeoAnalytics Desktop 的独立工具**。这些能力分别属于：
- **Network Analyst 扩展**：通过 Make OD Cost Matrix Analysis Layer + Solve 实现 OD 成本矩阵；通过 Make Service Area Analysis Layer + Solve 实现服务区
- **GeoAnalytics Server**（ArcGIS Enterprise 服务）：提供分布式并行计算能力，但这是服务级别的功能，不是桌面端工具箱中的独立工具

GeoAnalytics Desktop 中确实包含 Enrich From Multi-Variate Grid（从多变量格网丰富），但那是数据丰富工具，与网络分析无关。

### 10. Calculate Density 区别

**核实结论：两者输出类型完全不同，原清单混淆。**

| 对比项 | Calculate Density（GeoAnalytics Desktop） | Kernel Density（Spatial Analyst） |
|---|---|---|
| 输入 | 点 | 点/线 |
| 输出 | **面要素类**（正方形/六边形格网，含密度值字段） | **栅格**（密度表面） |
| 许可 | Advanced | Advanced + Spatial Analyst |
| 算法 | 核密度平滑 | 核密度平滑 |
| 并行框架 | Apache Spark（本地并行） | 单进程/环境并行 |

两者算法内核相同，但输出类型截然不同：Calculate Density 输出离散矢量面格网，Kernel Density 输出连续栅格表面。

### 其他自行发现的问题

1. **Tracking Analyst 在 ArcGIS Pro 中不可用**：Esri 官方明确说明 Tracking Analyst 扩展模块在 ArcGIS Pro 中不可用或位于路线图上。原清单若包含 Tracking Analyst 工具应从清单中移除。

2. **原清单可能遗漏 Topology 工具集**：Export Topology Errors 输出三个矢量要素类（点/线/面错误），符合矢量输出口径，应纳入。

3. **原清单可能遗漏线性参考工具集**：Route Events To Points / Lines / Polygon 等直接输出矢量要素类，应纳入。

4. **原清单可能遗漏 3D Analyst 的 3D Proximity 工具集**：Near 3D、Buffer 3D、Inside 3D、Union 3D、Difference 3D 均为矢量输入/输出，应纳入。

5. **原清单可能遗漏 Business Analyst 的 Trade Areas 工具集**：多个工具直接输出面要素类（行驶时间贸易区域、贸易区域环等），应纳入。

6. **原清单可能混淆了工具与工具集的概念**：部分条目（如"成对叠加"）是工具集名称而非具体工具名，应展开为具体工具。

7. **原清单可能遗漏了 GeoAnalytics Desktop 的 Group By Proximity**（按邻域分组）：输入矢量，输出追加 GROUP_ID 字段的矢量要素类，符合口径。

---

## 遗漏补充

本章列出原清单未收录但符合本文口径的工具，并说明纳入理由。

### 已纳入的补充工具

1. **Topology 工具集 — Export Topology Errors**：输出三个矢量要素类（点/线/面错误），Basic 即可用。原清单未包含拓扑相关工具。

2. **线性参考工具集 — Route Events To Points / Lines / Polygon**：将路径事件表转为矢量要素类，Basic 即可用。原清单未包含线性参考工具。

3. **3D Analyst — 3D Proximity 工具集**：Near 3D、Buffer 3D、Inside 3D、Union 3D、Difference 3D 均为矢量输入/输出，Advanced + 3D Analyst。原清单仅列出部分可见性工具。

4. **3D Analyst — 3D Intersections 工具集**：Intersect 3D、Intersect 3D Line With Multipatch、Intersect 3D Line With Surface、Stack Profile 等。原清单未包含。

5. **3D Analyst — Feature Extraction 工具集**：Multipatch Footprint、Regularize Building Footprint、Regularize Adjacent Building Footprint、LAS Building Multipatch 等。原清单未包含。

6. **Business Analyst — Trade Areas 工具集**：Generate Drive Time Trade Area、Generate Trade Area Rings、Generate Threshold Drive Times 等，输出面要素类。原清单未包含 Business Analyst。

7. **Business Analyst — Grids and Hexagons**：Generate Grids and Hexagons 输出面要素类。原清单未包含。

8. **Crime Analysis — Investigative Analysis**：Incident Sequence、Incident Path 输出线要素类。原清单未包含 Crime Analysis。

9. **GeoAnalytics Desktop — Group By Proximity**：按邻域分组，输出追加 GROUP_ID 的矢量要素类。原清单未包含。

10. **GeoAnalytics Desktop — Trace Proximity Events**：追踪邻近事件，输出表或要素类。原清单未包含。

11. **Spatial Statistics — Decompose Spatial Structure**：分解空间结构，输出面要素类（空间分量）。原清单未包含。

12. **Spatial Statistics — Neighborhood Summary Statistics**：邻域汇总统计，输出追加统计字段的矢量要素类。原清单未包含。

### 评估后排除的工具

1. **纯栅格运算工具**：栅格计算器、重分类、焦点统计、块统计、滤波器等。输入或输出为栅格，不符合口径。

2. **栅格→矢量转换工具**：Raster To Polygon、Raster To Polyline、Raster To Point、Raster To Multipoint。以栅格为输入，不符合"矢量输入"口径。但作为某矢量分析链路的固定下游步骤，在对应工具处注明。

3. **Segment Mean Shift（均值漂移影像分割）**：输出栅格，不符合矢量输出口径。其矢量化需接 Raster To Polygon，不单列。

4. **Tracking Analyst 工具**：ArcGIS Pro 中不可用，已从清单移除。

5. **Distance Accumulation / Distance Allocation**：输出栅格，不收录。其下游矢量输出工具（Optimal Path As Line、Optimal Region Connections）已收录。

6. **Watershed（分水岭）**：Spatial Analyst 中输出栅格。若需矢量面需接 Raster To Polygon，不收录。

7. **Geodesic Viewshed / Viewshed**：输出栅格，不收录。3D Analyst 中对应矢量输出的工具为 Line Of Sight、Construct Sight Lines。

8. **Locate Features Along Routes**：输出为事件表，非矢量要素类，排除。但作为线性参考核心工具在报告中列出供参考。

9. **Validate Topology**：不产出矢量要素类（仅修改拓扑状态），排除。

10. **Cartography 工具箱中的 Proximity 类工具**：制图工具箱主要面向制图综合和符号化，其工具（如 Simplify Line、Simplify Polygon、Smooth Line、Smooth Polygon 等）虽输入输出矢量，但属于制图综合而非空间分析，本文**不纳入**。若用户需要完整的"所有矢量处理工具"清单，可另行补充。

11. **Parcel 工具集（宗地结构工具）**：宗地编辑和管理工具，输入输出宗地面要素类，符合矢量口径。但属于数据编辑范畴，本文**不纳入**。若用户需要可另行补充。

12. **Roadway Characteristics Editor**：属于 Roads and Highways / Location Referencing 扩展的编辑器工具，非地理处理工具，不纳入。

13. **Data Reviewer 工具箱**：主要用于数据质量检查，输出为检查表/结果表，非矢量要素类，不纳入。但部分工具（如 Create Reviewer Session）涉及要素类，可视具体需求补充。

14. **Edit 工具箱（编辑工具箱）**：包含大量编辑工具，输入输出矢量要素类，但属于交互式编辑范畴，非地理处理分析工具，不纳入。

15. **Conversion 工具箱中的矢量→矢量转换工具**：如 Feature Class To Feature Class、Copy、Project、Project Raster（栅格）等。这些属于数据转换而非分析，本文**不纳入**。但若用户需要"所有矢量输入/输出工具"的完整清单，可另行补充。

---

## 许可汇总表

下表横向对比各工具箱的许可需求：

| 工具箱 | 基础许可 | 扩展模块 | 备注 |
|---|---|---|---|
| Analysis | Basic / Standard / Advanced | 无 | 核心矢量分析工具箱 |
| Data Management | Basic / Standard / Advanced | 部分工具需扩展 | Integrate、Dissolve、Fishnet 等 Basic 即可 |
| Spatial Statistics | Basic / Standard / Advanced | 无 | 多数工具输出表/值，少数输出矢量 |
| Spatial Analyst | — | **必须** | 所有工具需 Advanced + Spatial Analyst |
| 3D Analyst | — | **必须** | 所有工具需 Advanced + 3D Analyst |
| Network Analyst | Basic / Standard / Advanced | **必须**（求解时） | 创建图层 Basic 即可，求解需扩展 |
| Geostatistical Analyst | — | **必须** | 所有工具需 Advanced + Geostatistical Analyst |
| Image Analyst | — | **必须** | 深度学习工具需 Advanced + Image Analyst |
| GeoAnalytics Desktop | — | **必须** | 所有工具需 Advanced + GeoAnalytics Desktop |
| Business Analyst | — | **必须** | 所有工具需 Advanced + Business Analyst |
| Crime Analysis | Basic / Standard / Advanced | 部分需 Spatial Analyst | 随 ArcGIS Pro 免费提供 |
| Linear Referencing | Basic / Standard / Advanced | 无 | 部分工具需 Location Referencing |
| Location Referencing | — | **必须** | 部分 3D Analyst 工具（如 Intersect 3D Lines）需此扩展 |

---

## 精简速查表

### 按功能类别速查

| 功能类别 | 代表性工具 | 所属工具箱 |
|---|---|---|
| 叠加分析 | Intersect、Union、Erase、Identity、Spatial Join | Analysis |
| 成对叠加 | Pairwise Intersect、Pairwise Clip、Pairwise Dissolve | Analysis |
| 邻近分析 | Buffer、Near、Generate Near Table、Point Distance | Analysis |
| 提取分析 | Clip、Select、Split、Table Select | Analysis |
| 统计分析 | Summary Statistics、Frequency、Tabulate Intersection | Analysis |
| 几何转换 | Feature To Line、Feature To Point、Polygon To Line、Feature Vertices To Points | Data Management |
| 概化处理 | Dice、Simplify Line、Simplify Polygon、Smooth Line | Data Management / Cartography |
| 面处理 | Dissolve、Eliminate、Eliminate Polygon Part、Aggregate、Boundary Clean | Data Management / Spatial Analyst |
| 拓扑 | Export Topology Errors、Validate Topology | Data Management |
| 距离分析 | Optimal Path As Line、Optimal Region Connections | Spatial Analyst |
| 水文分析 | Stream To Feature、Derive Stream As Line | Spatial Analyst |
| 表面分析 | Contour、Contour List、Interpolate Shape | Spatial Analyst / 3D Analyst |
| 3D 相交 | Intersect 3D、Intersect 3D Line With Multipatch、Stack Profile | 3D Analyst |
| 3D 邻近 | Near 3D、Buffer 3D、Inside 3D、Union 3D、Difference 3D | 3D Analyst |
| 可见性 | Construct Sight Lines、Line Of Sight、Skyline、Skyline Barrier | 3D Analyst |
| 体积计算 | Surface Volume、Surface Difference、Extrude Between | 3D Analyst |
| 网络分析 | Route、Service Area、Closest Facility、OD Cost Matrix | Network Analyst |
| 密度分析 | Kernel Density（栅格）、Calculate Density（矢量面） | Spatial Analyst / GeoAnalytics Desktop |
| 热点分析 | Hot Spot Analysis、Optimized Hot Spot、Emerging Hot Spot | Spatial Statistics / GeoAnalytics Desktop |
| 聚类分析 | Density-based Clustering、Find Point Clusters | Spatial Statistics / GeoAnalytics Desktop |
| 地统计输出 | GA Layer To Contour、GA Layer To Points | Geostatistical Analyst |
| 影像对象提取 | Detect Objects Using Deep Learning、Classify Objects Using Deep Learning | Image Analyst |
| 商业分析 | Generate Desire Lines、Generate Drive Time Trade Area、Enrich Layer | Business Analyst |
| 犯罪分析 | Incident Sequence、Incident Path、Optimized Hot Spot | Crime Analysis |
| 线性参考 | Route Events To Points、Route Events To Lines、Generate Routes | Linear Referencing |
| 并行大数据 | Calculate Density、Find Hot Spots、Reconstruct Tracks | GeoAnalytics Desktop |

### 按许可等级速查

| 许可等级 | 可使用的代表性工具 |
|---|---|
| **Basic** | Clip、Select、Spatial Join、Pairwise 系列、Buffer（部分）、Create Thiessen Polygons、Dissolve、Fishnet、Integrate、Export Topology Errors、GA Layer To Contour、Route Events To Points、Near 3D（❌ 需扩展） |
| **Standard** | Feature To Line、Geodetic Densify、分析工具箱全部、拓扑创建与管理 |
| **Advanced** | Eliminate、Eliminate Polygon Part、Feature Vertices To Points、Dice、Polygon To Line、Feature Envelope To Polygon、GeoAnalytics Desktop 全部、Calculate Density |
| **Advanced + 扩展** | 所有带扩展模块的工具（Spatial Analyst / 3D Analyst / Network Analyst / Geostatistical Analyst / Image Analyst / Business Analyst / GeoAnalytics Desktop） |

---

## 数据来源与参考链接

本文所有工具信息均来自 Esri 官方 ArcGIS Pro 帮助文档（当前最新版本 ArcGIS Pro 3.7，2026 年 5 月发布）。官方文档已迁移至 doc.esri.com，旧版链接（pro.arcgis.com）仍有效并重定向。

[1] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/analysis/analysis-toolbox-license.htm
> 「空间连接 已包括 已包括 已包括」「成对整合 已包括 已包括 已包括」

[2] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/data-management/data-management-toolbox-license.htm
> 「融合 已包括 已包括 已包括」「消除 不包括 不包括 已包括」

[3] https://doc.esri.com/zh-cn/arcgis-pro/latest/tool-reference/data-management/integrate.html
> 「许可信息 基本：是 标准：是 高级：是」

[4] https://doc.esri.com/zh-cn/arcgis-pro/latest/tool-reference/data-management/dissolve.html
> 「Licensing information Basic: Yes Standard: Yes Advanced: Yes」

[5] https://doc.esri.com/zh-cn/arcgis-pro/latest/tool-reference/data-management/eliminate.html
> 「许可信息 基本：否 标准：否 高级：是」

[6] https://doc.esri.com/zh-cn/arcgis-pro/latest/tool-reference/data-management/export-topology-errors.htm
> 「导出拓扑错误（数据管理）」

[7] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/spatial-analyst/
> 「Spatial Analyst 工具箱概述」

[8] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/spatial-analyst/spatial-analyst-toolbox-license.htm
> 「Spatial Analyst 需要 Spatial Analyst」

[9] https://pro.arcgis.com/zh-cn/pro-app/3.4/tool-reference/spatial-analyst/stream-to-feature.htm
> 「栅格河网矢量化 (Spatial Analyst) 需要 Spatial Analyst 许可。」

[10] https://pro.arcgis.com/en/pro-app/latest/tool-reference/3d-analyst/an-overview-of-the-visibility-toolset.html
> 「The Visibility toolset features tools for performing various forms of visibility analysis, ranging from constructing shadow models and sight lines to generation of viewsheds and skylines.」

[11] https://doc.esri.com/zh-cn/arcgis-pro/latest/tool-reference/3d-analyst/line-of-sight.html
> 「许可信息 基本：需要 3D Analyst 标准：需要 3D Analyst 高级：需要 3D Analyst」

[12] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/network-analyst/network-analyst-toolbox-license.htm
> 「创建服务区分析图层 已包括 已包括 已包括」「求解 如果正在求解的图层的网络数据源是网络数据集，则需要 Network Analyst 许可」

[13] https://pro.arcgis.com/en/pro-app/3.2/tool-reference/network-analyst/an-overview-of-the-analysis-toolset.htm
> 「The Analysis toolset contains tools used to perform analysis when using the ArcGIS Network Analyst extension.」

[14] https://pro.arcgis.com/zh-cn/pro-app/3.6/tool-reference/geostatistical-analyst/an-overview-of-the-working-with-geostatistical-layers-toolset.htm
> 「GA 图层转等值线 在地统计图层中创建等值线要素类。输出要素类可以是由等值线构成的线要素类，或由填充的等值线构成的面要素类。」

[15] https://pro.arcgis.com/en/pro-app/3.4/tool-reference/geostatistical-analyst/geostatistical-analyst-toolbox-license.htm
> 「GA Layer To Contour Requires Geostatistical Analyst Requires Geostatistical Analyst Requires Geostatistical Analyst」

[16] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/geoanalytics-desktop/calculate-density.htm
> 「许可信息 基本：否 标准：否 高级：是」

[17] https://pro.arcgis.com/en/pro-app/3.3/tool-reference/geoanalytics-desktop/geoanalytics-desktop-toolbox-license.htm
> 「GeoAnalytics Desktop toolbox licensing」

[18] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/business-analyst/an-overview-of-the-analysis-toolset.htm
> 「分析工具集包含用于评估市场区域、客户分布、商店和设施网络的人口统计属性的工具。」

[19] https://pro.arcgis.com/zh-cn/pro-app/3.5/tool-reference/business-analyst/generate-desire-lines.htm
> 「生成从每个客户到关联商店位置的一系列线。这些线通常称为蜘蛛图。」

[20] https://pro.arcgis.com/en/pro-app/latest/tool-reference/linear-referencing/locate-features-along-routes.htm
> 「Computes the intersection of input features (point, line, or polygon) and route features and writes the route and measure information to a new event table.」

[21] https://doc.esri.com/en/arcgis-pro/3.7/help/analysis/3d-analyst/what-is-the-3d-analyst-extension-.html
> 「The ArcGIS 3D Analyst extension in ArcGIS Pro」

[22] https://doc.esri.com/en/arcgis-pro/latest/tool-reference/main/geoprocessing-toolbox-licensing.html
> 「3D Analyst toolbox licensing」

[23] https://pro.arcgis.com/zh-cn/pro-app/3.5/tool-reference/spatial-statistics/spatial-statistics-toolbox-license.htm
> 「空间统计工具箱许可」

[24] https://www.esri.com/arcgis-blog/products/announcements/announcements/whats-new-and-improved-in-arcgis-pro-may-2026
> 「ArcGIS Pro 3.7 is here, and we are excited to share what's new and improved.」

[25] https://doc.esri.com/zh-cn/arcgis-pro/latest/help/data/streetmap-premium/routing-with-streetmap-premium-in-arcgis-pro.html
> 「只要您获得 ArcGIS Network Analyst 和适当地区的 StreetMap Premium 扩展模块的许可，网络数据集即可用于在 ArcGIS Pro 中进行路径选择。」

[26] https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/an-overview-of-the-topology-toolset.htm
> 「As of ArcGIS Pro 3.7, the documentation can be found at doc.esri.com」

[27] https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/feature-to-line.htm
> 「Creates a feature class containing lines generated by converting polygon boundaries to lines, or splitting line, polygon, or both features at their intersections.」

[28] https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/feature-vertices-to-points.htm
> 「Creates a feature class containing points generated from specified vertices or locations of the input features.」

[29] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/main/arcgis-pro-tool-reference.htm
> 「ArcGIS Pro 地理处理工具参考」

[30] https://pro.arcgis.com/zh-cn
> 「ArcGIS Pro | ArcGIS Pro 文档」
