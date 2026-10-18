# ArcGIS Pro 矢量分析工具清单 — 影像相关内容提取

> **来源**：`ArcGIS_Pro_矢量分析工具完整清单.md`（964 行）
> **提取规则**：从矢量分析工具清单中提取所有涉及影像/栅格/点云/LAS/表面/深度学习的内容
> **提取日期**：2026-10-18

---

## 提取总览

矢量分析工具清单中与影像相关的内容分布在 6 个章节，涉及 **17 个工具**，可归纳为 4 类：

| 类别 | 涉及章节 | 工具数 | 说明 |
|------|----------|--------|------|
| 栅格→矢量转换 | 2.5 / 4.3 / 4.5 | 5 | 以栅格/影像为输入或中间产物，输出矢量 |
| 表面/3D 插值 | 5.3 | 2 | 从表面（栅格/TIN）插值到 3D 矢量要素 |
| 点云/LAS 要素提取 | 5.8 / 5.9 | 6 | 从点云、LAS 数据集、网格提取矢量要素 |
| 影像深度学习与分类 | 八、Image Analyst | 4 | 影像上的深度学习目标检测/分类 + 分类器训练 |

---

## 一、栅格处理相关（§2.5）

数据管理工具箱中的栅格处理工具（如 **Raster To Polygon**、**Raster To Polyline**、**Raster To Point**）以栅格为输入，不符合"矢量输入"口径，故不收录。但若作为某矢量分析链路的固定下游步骤，在对应工具处注明。

**与影像的关系**：这些工具是"栅格→矢量"转换的桥梁，常用于影像分类后矢量化。

---

## 二、表面分析 — 等值线（§4.3）

等值线工具以**高程栅格**为输入（中间产物），输出矢量线要素类。

| 序号 | 中文名 | 英文名 | 输入 | 输出 | 许可等级 |
|------|--------|--------|------|------|----------|
| 84 | 等值线 | Contour | 高程栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |
| 85 | 等值线列表 | Contour List | 高程栅格（中间产物） | 线要素类 | Advanced + Spatial Analyst |
| 86 | 含障碍的等值线 | Contour With Barriers | 高程栅格 + 线/面障碍要素 | 线要素类 | Advanced + Spatial Analyst |

**与影像的关系**：等值线是 DEM/DSM 栅格（可视为高程影像）到矢量等高线的转换工具。

---

## 三、提取分析 — 栅格值提取至点（§4.5）

从栅格中提取像元值到矢量点要素的属性字段。

| 序号 | 中文名 | 英文名 | 输入 | 输出 | 许可等级 |
|------|--------|--------|------|------|----------|
| 89 | 值提取至点 | Extract Values To Points | 点 + 栅格 | 点要素类（追加栅格值字段） | Advanced + Spatial Analyst |
| 90 | 多值提取至点 | Extract Multi Values To Points | 点 + 多个栅格 | 无独立输出（向输入点表追加字段） | Advanced + Spatial Analyst |

**与影像的关系**：将影像/栅格波段值采样到矢量点位，常用于多光谱影像采样。

---

## 四、3D 插值 — 表面到 3D 矢量（§5.3）

从表面（栅格/TIN）插值高程到 3D 矢量要素。

| 序号 | 中文名 | 英文名 | 输入 | 输出 | 许可等级 |
|------|--------|--------|------|------|----------|
| 102 | 插值形状 | Interpolate Shape | 3D 线/点 + 表面 | 3D 线/点要素类 | Advanced + 3D Analyst 或 Spatial Analyst |
| 104 | 更新要素 Z | Update Feature Z | 3D 要素类 + 表面 | 3D 要素类 | Advanced + 3D Analyst |

**与影像的关系**：表面可以是高程栅格（DSM/DEM 影像），将 2D 矢量要素"贴"到地形表面。

---

## 五、点云/LAS 要素提取（§5.8 / §5.9）

从点云、LAS 数据集、网格中提取矢量要素。

| 序号 | 中文名 | 英文名 | 输入 | 输出 | 许可等级 |
|------|--------|--------|------|------|----------|
| 128 | 从网格提取多面体 | Extract Multipatch From Mesh | 多面体 | 多面体要素类 | Advanced + 3D Analyst |
| 129 | 从点云提取电力线 | Extract Power Lines From Point Cloud | 点云 | 3D 线要素类 | Advanced + 3D Analyst |
| 130 | LAS 建筑物转多面体 | LAS Building Multipatch | LAS 数据集 | 多面体要素类 | Advanced + 3D Analyst |
| 131 | 多面体足迹 | Multipatch Footprint | 多面体 | 面要素类 | Advanced + 3D Analyst |
| 132 | 规则化相邻建筑物足迹 | Regularize Adjacent Building Footprint | 面 | 面要素类 | Advanced + 3D Analyst |
| 133 | 规则化建筑物足迹 | Regularize Building Footprint | 面 | 面要素类 | Advanced + 3D Analyst |
| 134 | 按 LAS 点邻近提取 | Locate Las Points By Proximity | LAS 数据集 + 3D 线/面 | LAS 数据集（筛选结果） | Advanced + 3D Analyst |

**与影像的关系**：点云/LAS 是 LiDAR 遥感数据，与影像分析配合用于建筑物提取、电力线检测等遥感应用。

---

## 六、Image Analyst 扩展 — 影像深度学习与分类（§八）

Image Analyst 主要面向影像分析，多数工具输出栅格。此处仅收录符合"矢量输入/输出"口径的工具。

### 6.1 深度学习（§8.1）

| 序号 | 中文名 | 英文名 | 输入 | 输出 | 许可等级 |
|------|--------|--------|------|------|----------|
| 154 | 使用深度学习检测对象 | Detect Objects Using Deep Learning | 影像 + 输入表（可选） | 面/点要素类（检测到的对象） | Advanced + Image Analyst |
| 155 | 使用深度学习分类对象 | Classify Objects Using Deep Learning | 影像 + 输入面要素类 | 面要素类（分类结果） | Advanced + Image Analyst |

**与影像的关系**：这是最直接的影像分析工具 — 在影像上运行深度学习模型进行目标检测和对象分类，输出矢量要素。

### 6.2 分类与模式识别（§8.2）

| 序号 | 中文名 | 英文名 | 输入 | 输出 | 许可等级 |
|------|--------|--------|------|------|----------|
| 156 | 训练最大似然法分类器 | Train Maximum Likelihood Classifier | 影像 + 训练样本要素类 | 分类器文件 | Advanced + Image Analyst |
| 157 | 训练支持向量机分类器 | Train Support Vector Machine Classifier | 影像 + 训练样本要素类 | 分类器文件 | Advanced + Image Analyst |

**说明**：**Segment Mean Shift（均值漂移影像分割）输出为栅格**，不符合"矢量输出"口径，不收录。若需矢量化，需后续接 Raster To Polygon 工具。用户原清单中"Segment Mean Shift 后矢量化"实际是两个独立步骤的组合。

**与影像的关系**：影像分类训练工具，从影像 + 训练样本生成分类器模型。

---

## 七、影像相关工具与 stb-image 功能映射

| ArcGIS 工具 | stb-image 对应 | 覆盖状态 |
|------------|---------------|----------|
| Detect Objects Using Deep Learning | `process/detection/yolo` + `process/detection/cnn_char` | ⚠️ 部分（YOLO 检测 + CNN 字符识别，非通用对象检测） |
| Classify Objects Using Deep Learning | `process/segment/kmeans` + `process/classification` | ⚠️ 部分（K-means 分割，非深度学习分类） |
| Train Maximum Likelihood Classifier | 无 | ❌ 未覆盖 |
| Train SVM Classifier | 无 | ❌ 未覆盖 |
| Segment Mean Shift | `process/segment/slic` | ⚠️ 部分（SLIC 超像素，非 Mean Shift） |
| Contour / Contour List | `process/edge/contour` | ✅ 已覆盖（轮廓提取） |
| Extract Values To Points | `process/feature/sampling` | ⚠️ 部分（特征点采样） |
| Interpolate Shape | `process/transform/perspective` | ⚠️ 部分（几何变换，非表面插值） |
| LAS Building Multipatch | 无 | ❌ 未覆盖（LiDAR 专用） |
| Extract Power Lines From Point Cloud | 无 | ❌ 未覆盖（LiDAR 专用） |
| Raster To Polygon | `process/segment/connected_components` + 边界追踪 | ⚠️ 部分（连通域 + 轮廓，非完整栅格矢量化） |

**总结**：stb-image 作为纯 MoonBit 图像处理库，覆盖了影像分析中的**分割**（SLIC/K-means/分水岭）、**检测**（YOLO/CNN）、**轮廓提取**等核心算法，但不覆盖 LiDAR 点云处理、地统计分类器训练、栅格→矢量完整转换链等 GIS 专用功能。