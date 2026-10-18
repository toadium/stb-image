# ArcGIS Pro 3.7 点云、倾斜摄影与正射影像功能完整清单

## 摘要

以 ArcGIS Pro 3.7 为基准，点云、倾斜摄影和正射影像不是三个平行数据模型，而是可串联的一条数据链：无人机或航空影像经 Ortho Mapping 的三角测量、区域网平差、深度图与色彩处理生成正射镶嵌、DEM/DSM；密集匹配点云和倾斜网格通过 I3S/SLPK 发布为 Web 场景图层；LAS/LAZ/ZLAS 点云则通过地面分类、栅格化或 TIN 化成为地形分析输入。正射映射产品生成及无人机/航空密集匹配均要求 Advanced 或 Reality Mapping 扩展；镶嵌数据集创建要求 Standard/Advanced；点云地面分类、LAS 转栅格/TIN 等 3D Analyst 工具需要 3D Analyst；像素/对象深度学习推理要求 Image Analyst。[3][4][7][10]

本报告收录经官方帮助核实的工具、工具集、栅格函数和工作流；对尚未取得同版本官方页面的个别旧名或用户指定名称，均标为「名称需以实际版本帮助为准」，不以近似名替代。算法部分只写公开的计算逻辑，不臆测训练网络结构。

## 总说明

### 版本与范围

本报告以 ArcGIS Pro 3.7 为基准；引用优先采用 3.7 文档。同一工具在不同版本中的名称、许可及参数可能变化，因此跨版本迁移时应重新打开 3.7 帮助页核验。范围包括：LAS/zLAS/LAZ 点云、倾斜摄影与集成网格、无人机和航空正射映射、栅格/镶嵌数据集、场景发布、三维编辑、衍生地形与影像分析。不包括独立产品 Drone2Map、ArcGIS Image Server、Ortho Maker、Reality Mapping Server 的全部服务端功能，也不把第三方倾斜建模软件的输出名称直接写成 ArcGIS 内置工具。

### 许可体系的真实边界

ArcGIS Pro 有 Basic、Standard、Advanced 三级；扩展模块按工具逐项生效，而不是安装后即解锁全部工具。影像与遥感领域，创建和迁移镶嵌数据集、创建与管理 Ortho Mapping 工作空间、从影像集合生成高程和正射产品，均至少要求 Standard 或 Advanced；正射映射工作空间和产品生成明确需要 Advanced 或 Reality Mapping 用户扩展模块。[10] 3D Analyst、Spatial Analyst、Image Analyst、Geostatistical Analyst 提供的是所属工具集和工具的执行许可。某个转换工具虽在 Basic 级可见，也可能因其内部插值而要求 3D Analyst 或 Spatial Analyst。

### 三者不是同类数据，却共享同一套空间参考与产品链

LAS 数据集是对 `.las/.zlas/.laz` 及其表面约束的引用容器；它不复制全部点，但统计、金字塔与渲染由它组织。镶嵌数据集是地理数据库中的影像目录加动态镶嵌规则，适合管理多源、多分辨率、带元数据和函数的影像集合。集成网格场景图层是倾斜建模结果的 I3S 优化传输/可视化表达；点云场景图层是 LAS 点云的 I3S 优化表达。源点云或倾斜网格可以发布，但发布后的场景图层不是原生的可继续摄影测量平差或可完整三维编辑的数据体。[4][5]

| 对象 | 主要输入 | 核心用途 | 常见输出 | 发布/继续编辑 |
|---|---|---|---|---|
| LAS 数据集 | LAS、zLAS、LAZ、约束 | 管理、过滤、分类、渲染、分析 | LAS/TIN/栅格/多面体 | 可生成 SLPK；交互编辑需原始 LAS/zLAS |
| 镶嵌数据集 | 影像、栅格、影像服务 | 目录、动态处理、发布 | 正射镶嵌、函数模板、服务 | 可发布影像服务；不是点云 |
| Ortho Mapping 工作空间 | 无人机、航空、卫星、扫描影像 | 连接点、控制点、平差、色彩、产品 | DEM/DSM/正射影像 | 源影像继续更新；产品可再发布 |
| 集成网格场景图层 | OSGB 等 | 倾斜摄影 Web 三维浏览 | SLPK/I3S | 源多面体用于返修 |
| 点云场景图层 | LAS、zLAS、LAZ、LAS 数据集 | 点云 Web 三维浏览 | SLPK | 点分类在源 LAS/zLAS 上编辑 |

## 主体清单一：点云数据管理、转换与分类

### LAS 数据集工具集以「组织与优化」为主，不是点云分类工具集

ArcGIS Pro 3.7 的 LAS 数据集工具集包含：创建 LAS 数据集、将文件添加到 LAS 数据集、从 LAS 数据集移除文件、构建 LAS 数据集金字塔、LAS 数据集统计数据。[1] 「将 LAS 数据集转为点云场景图层内容」属于数据管理工具箱中的场景图层工具，不应归入 LAS 数据集工具集。Create LAS Dataset 可扫描文件头创建引用，也可选择计算统计；LAS Dataset Statistics 可计算整个数据集和单文件统计并生成报告。[11]

3.7 官方工具集页不再使用旧文档中常见的「Validate LAS」和「Repair LAS」作为该工具集条目；因此不能把旧版或跨产品名称无条件列为 3.7 工具。对 LAS 文件坐标系问题，官方使用 Define Projection、`.prj` 伴随文件、Create LAS Dataset 的创建 PRJ 选项和 Project LAS 处理；不能声称存在仍可用的同名「Repair LAS」工具。名称需以实际版本帮助为准。[6]

| 工具/功能 | 位置 | 已核实能力 | 关键依赖 |
|---|---|---|---|
| Create LAS Dataset | Data Management/LAS Dataset | 创建对 LAS、zLAS、LAZ 及表面约束的引用；可选计算统计、创建 PRJ | 3D Analyst/Spatial Analyst 等具体下游要求另计 |
| Add Files To LAS Dataset | Data Management/LAS Dataset | 增加文件或表面约束 | LAS 数据集可写 |
| Remove Files From LAS Dataset | Data Management/LAS Dataset | 移除引用文件或约束 | 不直接重写源点云几何 |
| Build LAS Dataset Pyramids | Data Management/LAS Dataset | 生成显示缓存，改善浏览 | 适合大体量浏览 |
| LAS Dataset Statistics | Data Management/LAS Dataset | 统计、报告点密度/间距/类别分布 | 全量扫描耗时会随点数增长 |
| Project LAS | Data Management | 对 `.las/.zlas` 重投影；可重组点并选择压缩 | 垂直基准变换需 Coordinate Systems Data 包；只有 LAS/zLAS 可直接写回 |
| Define Projection | Data Management/Projections | 为缺失/错误的点云创建 `.prj` 伴随文件 | 仅纠正元数据，不重投影几何 |
| Convert LAS | Conversion | LAS、zLAS、LAZ 间转换；改版本、记录格式；空间聚类 | 输出格式必须支持原分类/属性 |
| Extract LAS | 3D Analyst/Point Cloud | 按范围、类码、回波等输出 LAS/zLAS；可用环境重投影 | 3D Analyst |
| Thin LAS | 3D Analyst/Point Cloud | 降低点密度 | 3D Analyst |
| Tile LAS | 3D Analyst/Point Cloud | 按规则格网切片 | 3D Analyst |
| Colorize LAS | 3D Analyst/Point Cloud | 将正射影像颜色和近红外值赋给点 | 正射影像已配准 |
| LAS Dataset To Raster | 3D Analyst/Conversion | 用 binning/插值等将 LAS 点转为栅格 | 3D Analyst 或 Spatial Analyst |
| LAS Dataset To TIN | 3D Analyst/Conversion | 将点云三角化生成 TIN | 3D Analyst |
| LAS Dataset To Multipatch | 3D Analyst/Point Cloud | 从地面点、屋顶点和建筑轮廓生成闭合多面体 | 3D Analyst |
| LAS Building Multipatch | 3D Analyst | 用屋顶点、地面高度和建筑轮廓构建规则化屋顶模型 | 3D Analyst；仅支持线段轮廓 |

### 点云分类横跨「工具集」与「深度学习」两类路径

3.7 的点云工具集包含：更改 LAS 类代码、分类 LAS 地面、分类 LAS 建筑物、按高度分类 LAS、分类 LAS 噪声、分类 LAS 重叠、使用要素设置 LAS 类代码、使用栅格设置 LAS 类代码；转换工具集包含从点云提取对象；深度学习部分包含使用训练模型对点云分类、使用深度学习模型检测点云对象、准备点云对象检测训练数据、训练点云对象检测模型。[2] 这与上一轮核实的 3D Analyst LAS Dataset 工具集并不冲突：前者是 3.7 点云分类和对象提取的层级组织，后者覆盖 LAS 数据集容器、栅格化、TIN 和编辑等直接转换管理工具。

分类 LAS 地面要求投影坐标系；只评估类码 0、1、2 中的最后回波，并忽略 withheld/overlap 点。Standard、Conservative、Aggressive、Recover Ridges、Model Key 对应不同的坡度容忍、粗糙地形恢复和下游表面关键点选择。[8] 因此「只有一种地面提取算法」是错误的：同一工具提供多个检测器，算法族群还包括渐进形态学滤波、布料模拟滤波（Cloth Simulation Filter，CSF）等，但在工具实现文档未逐项公开内部算法细节时，应写「官方公开能力可区分这些检测器」，而不写「Esri 已明确所有底层数学」。

### 点云编辑是源文件级操作，LAZ 不能原位编辑

`.las/.zlas` 的 LAS 类代码和标志可通过分类选项卡直接修改，也可通过 3D Analyst 地理处理工具批量修改；修改写入源文件后通常不可自动撤销，试验应使用副本。`.laz` 由 ArcGIS Pro 引用的 LAS 数据集不支持原位修改类码。[9] 支持矩形、多边形、套索、圆、线、三维立方体、球、圆柱，以及电力线、铁路、平面、簇等智能选择。3.7 SDK 新增 LAS 类码编辑 API，意味着外接加载项可以调用分类工作流，但不等于所有场景图层均支持在线原位编辑。

## 主体清单二：倾斜摄影、集成网格与 Web 三维

### 倾斜摄影在 ArcGIS 中的「成果层」是集成网格场景图层

倾斜摄影通常先由外业多视角影像生成密集点云、网格和纹理；ArcGIS Pro 3.7 侧的重点不是重新实现摄影测量建模，而是把 OSGB 等成果转为可发布、可 Web 浏览的集成网格场景图层。Create Integrated Mesh Scene Layer Content 接受 OSGB 文件或文件夹；数据缺投影时需通过锚点建立正确定位。[13] 集成网格输出通常写入 SLPK，也可按新版输出 `.i3srest`；发布时通过 Share Package 上传至 ArcGIS Online 或 Enterprise，形成 Web Scene Layer。[4]

### 点云和网格通过不同场景图层类型承载

| 场景图层类型 | 官方支持输入 | 适合表达 | 是否适合在线直接源编辑 |
|---|---|---|---|
| Point Cloud Scene Layer | LAS、zLAS、LAZ、LAS Dataset | 海量分类点、原始测量与滤波结果 | 不适合；点编辑回源 LAS/zLAS |
| Integrated Mesh Scene Layer | OSGB、OSGB 文件夹 | 倾斜摄影纹理网格 | 不适合；返修回多面体/OSGB 源 |
| 3D Object Scene Layer | 多面体、3D 对象要素、图层文件 | 规则建筑、设施 | 发布后可编辑属性/更新图层，不是摄影测量重平差 |
| Building Scene Layer | 建筑图层 | LOD1/LOD2 等建筑语义 | 可更新场景图层，不是倾斜网格原位建模 |
| Point Scene Layer | 点要素 | 点位置及属性 | 属性场景层 |
| Voxel Scene Layer | 体素图层 | 体积/体数据 | 取决于源 |

创建点云场景图层时，应优先选择 Scene Layer 2.x；输出坐标系和大地基准变换必须核对，否则平移和垂直偏差会直接传导至 Web 浏览。[4] 发布不是数据清洗步骤：地下点、错误类码、坐标偏移、纹理或法线问题应在生成 SLPK 之前处理。

### Local/Global Scene、高程源和底图是三维表现的基础设施

Global Scene 适合大范围连续地球表面，采用 WGS84 等全球基准；Local Scene 适合工程级局部坐标系、城市或校园。Elevation Surface 可叠加多个高程源，类型可为单波段高程栅格、TIN、影像服务、门户高程图层或 WCS；无高程源时场景在零高度平面渲染。[12] 最高分辨率源应排在最前，越界时再使用下一源。在线默认 Terrain 3D 只适合可视化，不宜用于分析；分析应使用本地 DEM/DSM/TIN。底图提供地理参照和视觉背景，高程源决定 draped 图层垂直位置，两者不可混为一谈。

## 主体清单三：正射映射、影像管理与栅格处理

### Ortho Mapping 是引导式摄影测量链，不是单个正射工具

Ortho Mapping 需要 Advanced 或 Reality Mapping 扩展。流程为：创建工作空间；计算相机模型；计算连接点；计算控制点；计算区域网平差；应用区域网平差；需要时计算深度图；最后生成正射产品。无人机影像可自动校准焦距、主点、径向和切向畸变；RTK/PPK 高精度位置时可选固定影像位置、仅调整姿态，此时 GCP 可作为检查点。[3]

区域网平差不是单纯配准：它同时估计相机内方位、外方位、镜头畸变及地面/连接点坐标，使重投影误差和地面控制残差整体最小。控制点过少或分布不当会造成局部翘曲；连接点不足则平差自由度过大。Calculate Control Points 建立影像与参考影像控制点，连接点则建立重叠影像间同名点，两者共同支撑平差。[3]

### 正射产品的立体匹配不是一种固定算法

自定义产品向导可在 Advanced 下生成 DEM、正射镶嵌或两者；点云匹配方法有三种：Extended Terrain Matching（ETM）、Semi-Global Matching（SGM）、Multi-View Matching（MVM）。ETM 基于特征，适合地形变化与细节较少的数据；SGM 输出更密集，适合城市场景，计算量更大；MVM 在 SGM 基础上融合多个立体模型的冗余深度估计，以效率生成较密集三维点。[3]

ETM/SGM/MVM 是正射映射向导中公开的匹配方法名，不能泛称为「唯一的 MVS 算法」。真正射、常规正射与 DSM 生成的区别在于：常规正射通常沿数字高程模型把像素投影到垂直投影平面；真正射还需在可见性/遮挡处理中利用 DSM 隐藏或修正被高大物体遮挡的地面，避免屋顶、墙面落到平面正射位置。

### 色彩平衡、接缝线与区域网平差是同一质量体系

Color Balance Mosaic Dataset 支持 Dodging、Histogram、Standard Deviation 三类方法；Dodging 还需选择目标色面，包括单一颜色、颜色格网、一阶、二阶、三阶面。颜色格网适合大范围、地面覆盖多样；多项式面更平滑但耗时。Global Fit 可利用 DEM 和解决方案点估计影像重叠，适用于重叠不足 50% 的数据；重叠良好时不必启用，否则会增加计算。[14]

接缝线决定重叠区「由谁贡献像素」，色彩平衡决定贡献像素的色调和对比关系。正射映射向导支持 Voronoi 等接缝线生成策略；最佳结果并不总等于接缝最短，还要考虑道路连续性、水体、云影和人工地物边缘。色彩平衡输入必须满足各波段已有统计和直方图、无关联色彩映射；目标栅格波段顺序和输入数据集应一致。

### Data Management 中与影像/点云直接相关的关键工具

| 工具/工具集 | 用途 | 许可/注意 |
|---|---|---|
| Composite Bands | 多单波段合并为多波段 | Basic/Standard/Advanced 通常可用 |
| Split Raster | 按规则分割栅格 | 输出格式、NoData、镶嵌方法逐参数控制 |
| Resample | 改变像元大小/采样 | 分类栅格不能用导致类别混合的方法时须谨慎 |
| Project Raster | 栅格重投影 | 基准变换和像元对齐影响精度 |
| Warp | 基于控制点/连接线做局部几何校正 | 适用于无完整 RPC/相机模型或局部畸变 |
| Mosaic | 合并到现有栅格 | 比创建新文件更适合增量更新 |
| Mosaic To New Raster | 多栅格合并为单个新栅格 | 像元大小、波段、色彩深度必须一致或显式设置 |
| Clip Raster | 矩形/要素裁剪 | 有对应 Clip 栅格函数用于动态处理 |
| Create Ortho Corrected Raster Dataset | 用 DEM 和控制数据生成正射栅格 | 需与 Ortho Mapping 工作空间区分 |
| Create Pansharpened Raster Dataset | 全色与多光谱融合 | 输出更适合目视，分析前核对光谱保真 |
| Generate Raster From Raster Function | 把函数/函数链物化为栅格 | 发布处理模板时常用 |

## 主体清单四：镶嵌数据集全套

### 镶嵌数据集是「影像数据库 + 镶嵌规则 + 处理链」，不是栅格拼接文件

镶嵌数据集创建要求 Standard 或 Advanced。创建后通过 Add Rasters To Mosaic Dataset 添加文件、文件夹、表、服务；添加时选择 Raster Type，栅格类型解释传感器、元数据、地理配准和相机模型。添加后通常需要计算像元大小范围、边界、足迹、统计，并生成 Overviews；统计缺失会触发性能警告。[15]

| 工具 | 作用 |
|---|---|
| Create Mosaic Dataset | 创建地理数据库中的空容器 |
| Create Referenced Mosaic Dataset | 引用既有镶嵌，用于不同发布/视图 |
| Add Rasters To Mosaic Dataset | 按栅格类型导入并应用初始处理 |
| Remove Rasters From Mosaic Dataset | 移除项目 |
| Repair Mosaic Dataset Paths | 数据源迁移后修复路径 |
| Build Boundary | 更新覆盖边界 |
| Build Footprints | 计算每个影像足迹 |
| Build Seamlines | 生成/更新接缝线 |
| Import/Export Mosaic Dataset Geometry | 导入或导出 Footprint/Boundary/Seamline |
| Calculate Cell Size Ranges | 计算可视分辨率层级 |
| Define Mosaic Dataset NoData | 定义 NoData 值 |
| Define Overviews / Build Overviews | 定义和生成概览金字塔 |
| Build Mosaic Dataset Item Cache | 在链尾插入缓存函数 |
| Clear Pixel Cache | 清理像素缓存 |
| Compute Dirty Area | 标记源变化区域 |
| Compute Mosaic Candidates | 寻找最佳镶嵌候选 |
| Color Balance Mosaic Dataset | 色彩平衡 |
| Synchronize Mosaic Dataset | 增量同步源变化 |
| Compact Mosaic Dataset | 压缩地理数据库、减少存储碎片 |
| Analyze Mosaic Dataset | 检查错误、警告、性能问题 |
| Alter Mosaic Dataset Schema | 企业库中为非所有者配置可编辑操作 |
| Set Mosaic Dataset Properties | 设置显示、服务和分析默认值 |
| Edit Raster Function | 添加/替换/删除函数链 |
| Build Multidimensional Info | 多维变量/维度信息 |
| Generate Exclude Area | 生成色彩平衡排除区，如云、水 |
| Compute Block Adjustment/Report | 计算平差或生成报告 |
| Export Mosaic Dataset Items/Geometry/Paths | 导出处理项目、几何或路径清单 |
| Merge/Split Mosaic Dataset Items | 合并或拆分目录项 |
| Delete Mosaic Dataset | 删除数据集及概览、缓存 |
| Mosaic Dataset To Mobile Mosaic Dataset | 生成移动端兼容产品 |

锁机制并不表现为一个独立工具。文件地理数据库镶嵌数据集通过企业库的锁定/版本编辑规则保证一致性；企业库中非所有者需要 Alter Mosaic Dataset Schema 创建侧表并授权 insert/update/delete，且允许新增的栅格类型须预先配置。实际写入时仍受地理数据库事务、服务和用户权限控制。

### LAS 加入镶嵌数据集时使用的是「LAS 栅格类型 + LAS Dataset To Raster 函数」

把 LAS 作为影像浏览时，Add Rasters To Mosaic Dataset 选择 LAS 栅格类型；系统自动加入 LAS Dataset To Raster 函数，按点间距、回波、类码、数据类型和空值填充生成动态栅格。建议像元尺寸约为平均点间距的 4 倍，使每个像元通常获得约 16 个点；过小会保留孔洞，过大会丢失细节。该函数会写缓存，并非每次屏幕刷新都重算全部点。[16]

## 主体清单五：Spatial Analyst、Geostatistical Analyst 与 Conversion

### DEM/DSM 只是输入，不是 Spatial Analyst 地表工具的归属

Spatial Analyst Surface 工具集以栅格高程面为输入，可生成坡度、坡向、曲率、山体阴影、等高线、填挖、视域和汇水相关表面产品。需要 Spatial Analyst 或 3D Analyst 许可；工具输出再可作为三维可视化、规划和水文分析输入。[17]

| 工具 | 输入 | 输出含义 |
|---|---|---|
| Slope | DEM/DSM | 每像元最大高程变化率 |
| Aspect | DEM/DSM | 最陡下坡方向 |
| Surface Parameters | DEM/DSM | 坡度、坡向、曲率等局部表面参数 |
| Curvature | DEM/DSM | 剖面/平面曲率 |
| Hillshade | DEM/DSM | 单源或多方向太阳阴影 |
| Contour/Contour List/Contour With Barriers | DEM/DSM | 等高线；障碍两侧可独立处理 |
| Cut Fill | 两期表面 | 填方与挖方体积 |
| Viewshed/Geodesic Viewshed | DEM + 观察点 | 基于网格或测地距离的可见性 |
| Visibility | DEM + 观察点 | 可见性分析 |
| Observer Points | DEM | 哪些观察点可见 |
| Watershed/Flow Direction/Flow Accumulation 等 | DEM | 流向、汇流、流域等水文表面 |

点云到 DEM 并非「点云工具集直接分析」：典型链是分类地面点 → Extract LAS/LAS Dataset To Raster 或 To TIN → DEM；或用 Geostatistical Analyst 把 XYZ 测量值插值为连续表面。若地面点尚未分类，直接用全部点插值会把建筑、植被和噪声当作地形。

### Geostatistical Analyst 适合稀疏点云生成 DEM，但不能自动识别地物

Geostatistical Analyst 的预测方法包括 IDW、Global Polynomial、Local Polynomial、Radial Basis Functions、Kriging 体系（含 EBK、EBK Regression Prediction、3D EBK）、Kernel Interpolation With Barriers、Diffusion Interpolation With Barriers 等。[18] IDW 不通过已知点，但距离越近权重越高；多项式方法拟合平滑趋势；RBF 精确通过输入点；克里金同时建模空间自相关和预测误差。它们没有「只保留地面」的语义，建筑、车辆和异常点会进入插值。

对于机载 LiDAR，先地面分类再用确定性或地统计方法通常更可控；对于稀疏摄影测量点、地面测量点或无分类点云，Geostatistical Analyst 可作为连续 DEM 生成器。选择时应同时检查交叉验证、搜索邻域、各向异性和屏障，而不是只看渲染平滑度。

### Conversion 中多数栅格/矢量互转可用，但点密度转栅格有许可例外

Raster To Point、Raster To Polygon、Raster To Polyline、Raster To Other Format 在三个基础许可级通常可用；Feature To Raster、Multipatch To Raster 通常可用；Point To Raster、Polygon To Raster、Polyline To Raster 需要 Spatial Analyst 或 3D Analyst，或 Advanced。[19] LAS 与点云相关转换还包括 Convert LAS、Extract LAS、LAS Dataset To Raster、LAS Dataset To TIN、LAS To Multipatch、Point Cloud To Feature Class/Multipatch 等，须按工具页核许可。

## 主体清单六：栅格函数与实时处理链

### 栅格函数处理的是「访问时像素」，不产生完整中间文件

栅格函数可以作用于图层、镶嵌数据集、镶嵌单个项目或影像服务；常规函数默认只处理当前视图可见范围与显示分辨率，适合快速预览。多个函数可组合成函数链，并保存为 Raster Function Template（RFT）。镶嵌数据集的处理模板会随影像服务发布；这意味着发布产品与发布实时处理是两个不同选择。[20]

### 与点云、正射、影像质量直接相关的栅格函数

| 函数 | 官方能力/限制 |
|---|---|
| Geometric | RPC/传感器定义 + 地形模型生成正射；无 DEM 用 Constant Z 不精确，低分辨率 DEM 通常仍优于常数高程 |
| Orthorectify | 与正射映射工作流配合的几何校正能力；参数命名以实际函数页为准 |
| Pansharpen | Brovey、Esri、Gram-Schmidt、IHS、平均值；Gram-Schmidt 可指定传感器以设权重 |
| Color Balance | 对镶嵌数据集或影像服务进行色彩处理；需统计和直方图 |
| Mosaic Rasters | 空间拼接多个栅格 |
| Clip | 矩形或多边形裁剪；仅处理显示范围 |
| Mask | 把指定范围外像素变 NoData |
| Stretch | 亮度、对比度、Gamma |
| Composite Bands | 多波段合并 |
| Extract Bands | 重排或提取波段 |
| Reproject | 重投影和重采样 |
| Resample | 改变像元大小 |
| Apparent Reflectance | 部分卫星影像的表观反射率校正 |
| Band Arithmetic | 波段算术；可用于 NDVI 等自定义指数 |
| Arithmetic | 两栅格/栅格与常量运算 |
| Convolution | 核滤波，含锐化、模糊、边缘 |
| Statistics | 邻域统计 |
| NDVI / Vegetation Index 类函数 | 从红、近红外等波段计算植被指数 |
| Dynamic World | 官方 Esri 培训资料将其列为可用影像/深度学习模型类型；作为栅格函数名称需以实际版本帮助为准 |
| Compute Cloud And Shadow | 用户指定名称；未取得 3.7 官方函数页时，需以实际版本帮助为准，不能确认其参数和输入 |
| Haze Removal / Dark Object Subtraction | 用户指定名称；未取得 3.7 官方函数页时，需以实际版本帮助为准 |

Pansharpen 官方页只明确列出 Brovey、Esri、Gram-Schmidt、IHS、平均值；用户提到的 PCA、SFIM、HPF 需要按实际运行环境核验。即使英文同名算法可用，也应先打开 3.7 帮助确认参数。Pansharpen 会改变辐射度和光谱特性，适合目视产品而非直接当作原始光谱分析输入。[21]

## 重点算法详解

### 块调整以重投影误差和地面约束联合最小化为目标

区域网平差把影像坐标观测、相机模型和控制约束放入统一最小二乘框架。设第 `i` 个点在第 `j` 幅影像中的观测像面坐标为 `u_ij, v_ij`，相机投影为 `p(X; E_j, I, d)`，其中 `E_j` 为外方位、`I` 为内方位、`d` 为畸变参数，则基本目标为

`min Σ w_ij ||[u_ij, v_ij]^T - p(X_i; E_j, I, d)||² + λ_c ||C(GCP - X_gcp)||²`。

第一项让同名像点经校正后的重投影尽可能接近观测；第二项通过权重 `λ_c` 把 GCP/检查点拉向已知坐标。`C` 包含基准、高程和坐标转换。无人机流程可同时标定焦距、主点、K1–K3 径向畸变、P1–P2 切向畸变；RTK/PPK 时影像位置可固定，仅调整姿态。[3]

块调整不是「只要有影像就不需要控制点」。无 GCP 时系统仍能通过连接点、GPS/IMU 和相机模型进行相对/约束平差，但绝对平面和垂直精度取决于传感器质量与元数据；GCP 提供绝对约束，检查点用于独立评估残差。控制点并非越多越好，分布、同名精度和基准一致性更重要。

### 密集匹配由局部对应到多视融合，真正射再处理遮挡

立体匹配先检测跨影像的对应点。ETM 用 Harris 类特征，速度快；SGM 在视差搜索方向对路径代价进行聚合，输出密集且细节丰富；MVM 用 SGM 后融合多立体模型的冗余深度估计。[3] 对每个像素深度 `Z`，正射映射将影像像素沿视线投影到高程面。真正射在此基础上以 DSM 判断可见性：高于地面的建筑物在常规正射中投影后会把屋顶/墙位置压到地面，真正射使用 DSM 与可见性遮蔽处理，减少这类投影位移。

分辨率提升不等于真正射。真正射的质量取决于 DSM 完整性、纹理弱区匹配、遮挡判断、色彩一致性和输出地面采样距离；仅提高输出像元大小会增加插值，不能恢复遮挡区的地面信息。

### 地面提取可表示为从点云中恢复「非物体」地形函数

渐进形态学滤波的核心是以由粗到细的窗口开运算近似地形。对格网高程 `z(x,y)`，用结构元素尺寸 `w_k` 进行开运算得到 `z_k^open`；若某点与当前开运算地形的高差小于阈值 `t_k`，则暂记为地面。窗口 `w_k` 与阈值 `t_k` 逐步增加，使平坦大尺度地形先被捕获，再保留更细的起伏。该族算法适合连续缓变地形，但桥面、堤坝、陡坎和过密植被容易误分为地面或地面漏分。

布料模拟滤波（CSF）把点云看作被柔性布料覆盖的系统。初始化布料于点云上方；迭代中粒子受重力下移，同时受布料内部弹簧和穿透约束，最终形成贴近裸露地面的曲面。用户可调整布料刚度、重力方向、迭代次数和分类阈值。它直观且对渐进起伏有效，但悬挂物、多层立交、墙面和噪声会干扰穿透约束。

分类 LAS 地面不是公开成「调用某一种固定公式」的黑箱：3.7 页面明确给出 Standard、Conservative、Aggressive、Recover Ridges、Model Key 检测模式。[8] 因此更准确的表述是：官方公开了检测器行为，未逐项公开完整源代码或底层公式；不可把 PMF 或 CSF 写成唯一的内部实现。

### 色彩平衡是目标色面/直方图/标准差的约束拟合

Dodging 对像素 `p` 寻找目标色面 `T(p)`，再按增益/偏置把源颜色映射到目标附近。单色目标适合影像少、地物单一；颜色格网适合大范围；一阶、二阶、三阶面用二维多项式拟合目标色。Least squares 拟合阶数越高越灵活，也越容易拟合局部异常并增加耗时。

Histogram 把源累积直方图映射到目标累积直方图；Standard Deviation 在目标影像的一倍标准差范围内调整像素关系。前者要求影像整体直方图相似，后者假设分布近似正态。色彩平衡不能修复云、大面积水面、严重过曝或不同季节植被造成的物理辐射差异；生成排除区可避免这些像素主导统计。

### 全色锐化各算法共享空间注入，但光谱保持策略不同

设全色为 `P`，多光谱各波段为 `M_k`，目标为 `M'_k`。Brovey 为 `M'_k = M_k × P / Σα_j M_j`，归一化权重 `α_j` 避免能量漂移；光谱与全色空间细节乘积直接，但高相关波段和噪声会被放大。IHS 把 RGB 转 IHS，用 `P` 替换强度 `I` 后逆变换；亮度保留好，色相/饱和度可能因 RGB 近似失真。Gram-Schmidt 先对多色波段做 Gram-Schmidt 正交化，用全色估计低分辨率模拟全色，再将细节注入各波段；通常光谱保真优于简单 IHS。Esri 方法为官方实现的另一种光谱建模融合。

PCA 先求多光谱协方差主成分，以全色替换第一主成分并逆变换；SFIM 用 `P / LowPass(P)` 作为调制系数乘以多光谱；HPF 把全色高通细节加到各多光谱波段。三者只有在 3.7 当前英文/中文函数页存在时才应列为可用选项。用户提到的六类名称不应在同一表中全部视为已核实。

### 云影检测、去雾和变化检测都是「条件性模型」而非单一公式

云影检测通常依赖云掩膜、可见光波段亮度关系、多光谱阈值和水体/阴影判别；变化检测也可能需要时间序列或季节归一化。ArcGIS 提供计算变化栅格函数、变化检测向导、分类后比较、像素值差、光谱向量差、CCDC 和 LandTrendr 时间序列方法。[22] 因此「云影检测」或「去雾」若以单一名字出现，应先确认工具/函数页、波段要求和训练数据。

图像差值计算 `Δ = T2 − T1`，对共配准、同传感器、同季节和辐射条件敏感；分类后比较计算类别转移矩阵，语义明确但误差会被两次分类放大；深度学习比较将两期影像或特征输入训练模型，依赖足量标签和代表性样本。三者在精度、解释性和数据准备成本上不可互换。

### DEM 插值、坡面解析和填挖体积对应不同数学层

TIN 线性插值假定三角形内高程沿两个方向线性变化；自然邻域以 Sibson 权重按 Voronoi 邻接关系插值；IDW 用 `Σ w_i z_i / Σ w_i`，常见反距离幂为 2；克里金以变异函数建模空间自相关并最小化预测误差；RBF 用径向基函数精确穿过已知点。采样点密度、类码过滤、断线和搜索邻域比选择插值名字更影响 DEM 质量。

坡度可写为高程梯度幅值 `S = arctan(sqrt((dz/dx)^2 + (dz/dy)^2))`；坡向是梯度方向 `A = atan2(-dz/dy, dz/dx)`；曲率来自 Hessian 二阶导组合，描述表面凸凹。具体工具可能使用 Horn、Zevenbergen-Thorne 或其他有限差分模板，报告时应以工具页面为准，而不是只写数学通式。

填挖体积把两期栅格差值 `Δh = h_after − h_before` 在像元面积 `A` 上求和：`V_cut = Σ max(−Δh, 0)·A`，`V_fill = Σ max(Δh, 0)·A`。积分误差来自垂直基准、投影面积、像元对齐、边界处理、压实系数和单位；TIN 与栅格体积极限也不同。输出体积是计算模型量，不是施工合同量。

### 规则化建筑轮廓提取不是倾斜网格自动转 CAD

LAS Building Multipatch 从建筑轮廓、屋顶点和地面高度构造 TIN，再把底面闭合为多面体。屋顶采样分辨率会在构造 TIN 前按格网稀疏点，每格取最高点以降低侧墙点影响；底面高度可来自地面表面或轮廓属性字段。[23] 输出表达屋顶形态，但不包含完整建筑立面细节。若输入缺少非建筑点，全部点都可能用于屋顶；轮廓含弧段不支持，需先 densify。

从倾斜集成网格提取轮廓，应理解为：对多视角影像或正射/DSM 分类与矢量化、对屋顶点构造多面体、再按长度/角度/面积规则化。ArcGIS 没有在核实资料中提供一个名为「规则化建筑轮廓提取」的通用一键工具，故不能将其列为已核实工具。

## 典型端到端工作流速查

### 无人机影像到正射产品

1. 创建 Ortho Mapping Workspace（Advanced 或 Reality Mapping）；导入无人机影像。
2. 计算相机模型、连接点；添加并检查 GCP/检查点。
3. 计算区域网平差、生成平差报告；必要时修点/重平差。
4. 选择 ETM/SGM/MVM 生成深度图和 DSM/DEM；色彩已一致时可关闭色彩平衡。
5. 生成正射镶嵌（TIFF/CRF）和 DEM/DSM；用 Clip、Split Raster、Export Mosaic Dataset Items 分发。
6. 需要 Web 服务时，将正射镶嵌加入镶嵌数据集，配置处理模板并发布；需要全分辨率动态服务时不应预先烧入全部增强。

### 倾斜影像到 Web 集成网格

1. 外部倾斜摄影建模软件输出 OSGB 等格式；检查坐标、纹理、LOD、空区块和异常浮动。
2. 在 ArcGIS Pro 中修复或确认空间参考；OSGB 缺投影时准备锚点。
3. 使用 Create Integrated Mesh Scene Layer Content 生成 SLPK；设置目标场景图层版本、坐标和属性缓存。
4. 通过 Share Package 上传至 Online/Enterprise 并发布为 Web Scene Layer。
5. 在 Local/Global Scene 配置高程源、底图、日照和图层可见性；返修时回到 OSGB/多面体，不在线编辑场景图层。

### LiDAR 到点云分类、DEM/DSM 与建筑模型

1. 用 Define Projection/Create LAS Dataset 修正坐标；Project LAS 输出 zLAS/LAS 到统一水平和垂直基准。
2. 创建 LAS Dataset，计算统计和金字塔；用分类 LAS 地面、建筑物、噪声、重叠建立基础类码。
3. 交互编辑 `.las/.zlas` 错误点；`.laz` 先转换或用提取副本。
4. LAS Dataset To Raster/TIN 生成 DEM/DSM；或插值生成连续表面。稀疏无分类点可用 Geostatistical Analyst。
5. 用规则化建筑工具从屋顶点、地面高度和建筑轮廓生成多面体；再创建 3D Object/Building Scene Layer。

### 多期正射影像到变化检测

1. 统一坐标系、基准、像元大小、NoData、季节/辐射条件和分类体系。
2. 对每期构建镶嵌数据集；必要时添加正射、云影或色彩函数链。
3. 用变化检测向导选择分类变化、像素值变化、光谱变化或时间序列 CCDC/LandTrendr。
4. 输出变化栅格、面或函数模板；用地表边界、采样点和人工解译验证。
5. 将结果发布为影像/要素服务，或转为专题产品。像素差和分类后比较必须分开记录误差来源。

## 许可汇总表

下表以「功能是否可执行」表示：Y 表示官方页面或许可页明确该级包含/可执行，N 表示明确不提供，`3DA/SA/IA/GA/扩展` 表示需相应扩展；未逐项公开的内容标「待逐项核验」，避免伪造绿色勾选。

| 功能项 | Basic | Standard | Advanced | 3D Analyst | Image Analyst | Spatial Analyst | Geostatistical Analyst | Reality Mapping |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 创建 LAS Dataset | 待逐项核验 | Y | Y | — | — | — | — | — |
| LAS 金字塔/统计 | 待逐项核验 | Y | Y | — | — | — | — | — |
| Project LAS | 待逐项核验 | Y | Y | — | — | — | — | — |
| Extract LAS | 待逐项核验 | 待逐项核验 | 待逐项核验 | Y | — | — | — | — |
| Thin LAS、Tile LAS | 待逐项核验 | 待逐项核验 | 待逐项核验 | Y | — | — | — | — |
| LAS Dataset To Raster | 待逐项核验 | 待逐项核验 | 待逐项核验 | Y 或 SA | — | Y 或 3DA | — | — |
| LAS Dataset To TIN | 待逐项核验 | 待逐项核验 | 待逐项核验 | Y | — | — | — | — |
| LAS Building Multipatch | 待逐项核验 | 待逐项核验 | 待逐项核验 | Y | — | — | — | — |
| 分类 LAS 地面/建筑/噪声 | 待逐项核验 | 待逐项核验 | 待逐项核验 | Y | — | — | — | — |
| 点云深度学习训练/推理 | 待逐项核验 | 待逐项核验 | 待逐项核验 | Y | Y | — | — | — |
| 创建镶嵌数据集 | N | Y | Y | — | — | — | — | — |
| 添加栅格/构建概览/接缝线 | 待逐项核验 | Y | Y | — | — | — | — | — |
| 分析/同步/压缩镶嵌数据集 | 待逐项核验 | Y | Y | — | — | — | — | — |
| 色彩平衡 Dodging/Histogram/SD | 待逐项核验 | Y | Y | — | — | — | — | — |
| Ortho Mapping 工作空间 | N | N | Y | — | — | — | — | 或 RM |
| 生成 DEM/DSM/正射镶嵌 | N | N | Y | — | — | — | — | 或 RM |
| 深度图 ETM/SGM/MVM | N | N | Y | — | — | — | — | 或 RM |
| 几何/正射栅格函数 | 待逐项核验 | Y | Y | — | — | — | — | — |
| 全色锐化函数 | 待逐项核验 | Y | Y | — | — | — | — | — |
| 变化检测向导 | 待逐项核验 | 待逐项核验 | 待逐项核验 | — | Y | — | — | — |
| Detect/Classify Pixels Using DL | 待逐项核验 | 待逐项核验 | 待逐项核验 | — | Y | — | — | — |
| 导出训练样本 | 待逐项核验 | 待逐项核验 | 待逐项核验 | — | Y | — | — | — |
| Slope/Aspect/Curvature/Hillshade | 待逐项核验 | 待逐项核验 | 待逐项核验 | — | — | Y 或 3DA | — | — |
| 等高线/视域/填挖 | 待逐项核验 | 待逐项核验 | 待逐项核验 | — | — | Y 或 3DA | — | — |
| IDW/Kriging/Spline 插值 | 待逐项核验 | 待逐项核验 | 待逐项核验 | — | — | — | Y | — |
| Raster To Polygon/Point/Polyline | Y | Y | Y | — | — | — | — | — |
| Point/Polygon/Polyline To Raster | 待逐项核验 | 待逐项核验 | 待逐项核验 | — | — | Y 或 3DA | — | — |
| 交互编辑 LAS 类码 | 待逐项核验 | Y | Y | — | — | — | — | — |
| 创建 Point Cloud/Integrated Mesh SLPK | 待逐项核验 | Y | Y | — | — | — | — | — |
| Local/Global Scene、底图、高程源 | Y | Y | Y | — | — | — | — | — |
| GeoAnalytics Desktop / Airports | 不适用 | 不适用 | 不适用 | 不适用 | 不适用 | 不适用 | 不适用 | 不适用 |

GeoAnalytics Desktop 和 Airports 与本题点云/倾斜/正射工具清单没有直接交集，不能为了凑模块而填 Y。若工作流涉及要素分析或机场数据，应另查其工具箱许可页。

## 常见说法核实结论

### 1. 「正射校正不需要高程数据」：错

严格正射校正需要高程模型；Geometric 函数可用 Constant Z，但官方明确其结果不准确，低分辨率 DEM 通常也优于常数高程。[7] 正射程度、地形起伏、影像分辨率和相机视角决定高程误差影响大小。

### 2. 「倾斜摄影模型可以直接当正射影像做面积量测」：错

倾斜模型是中心投影的纹理网格，墙面、屋顶和遮挡处没有统一垂直投影平面。只有经真正射校正并验证后的正射产品，才适合平面面积量测；局部仍需检查分辨率和可见性误差。

### 3. 「LAS 数据集和镶嵌数据集是同一类数据」：错

LAS 数据集管理点云文件和表面约束；镶嵌数据集管理影像/栅格项目、元数据、函数与动态镶嵌规则。二者可协同，但不能互换。

### 4. 「点云地面点提取只有一种算法」：错

至少有渐进形态学、布料模拟、基于坡度约束的多种滤波思想；ArcGIS 3.7 也公开 Standard、Conservative、Aggressive、Ridge、Model Key 多种检测器。[8]

### 5. 「真正射就是分辨率更高的正射」：错

真正射的核心是 DSM/可见性遮挡处理和垂直投影修正，不是输出像元更小。超分辨率输出不能恢复被屋顶或墙体遮挡的地面。

### 6. 「Block Adjustment 只需要影像不需要控制点」：错

只有连接点/IMU/GPS 也能平差，但绝对平面和垂直精度受传感器误差约束；GCP 提供绝对基准，检查点用于独立验证。

### 7. 「Integrated Mesh Scene Layer 可以编辑」：不准确

发布后的集成网格场景图层适合 Web 浏览和图层更新，不适合像源多面体一样继续三维建模或摄影测量返修。应改为「可在源数据编辑后重新生成/更新 SLPK」。

### 8. 「全色锐化会损失空间分辨率」：错，但表述反了

全色锐化的目的是把高分辨率全色空间细节注入低分辨率多光谱，输出空间分辨率通常提高或融合；代价是光谱/辐射特性变化。

### 9. 「点云分类可以完全自动化不需要人工干预」：错

自动化可完成大部分任务，但桥面、立交、陡坎、植被、噪声和异常类码仍需要目视检查、交互编辑和质量控制；LAZ 也不能原位编辑。

### 10. 「正射影像镶嵌数据集可以直接发布为影像服务」：有条件正确

镶嵌数据集可以发布为动态或缓存影像服务，并携带处理模板；但需检查统计、概览、接缝线、函数链、NoData、坐标服务能力和权限。发布是服务化，不是自动保证性能或修正数据质量问题。

## 算法与工作流选择图

下图用于快速判断从原始观测到最终产品的路线：无人机/航空影像优先走 Ortho Mapping；LiDAR 走 LAS 分类与表面生成；倾斜成果走 I3S/SLPK；若目标是连续地形且点稀疏，再考虑地统计插值。

![三大数据源的处理分支](fig_workflow.png)
*图 1：点云、倾斜影像与正射影像的主要产品链。数据来源：ArcGIS Pro 3.7 Ortho Mapping、LAS Dataset、Scene Layer 官方帮助 [2][3][4]*

![六类常用全色锐化算法的选择维度](fig_pansharpen.png)
*图 2：全色锐化算法在空间细节注入与光谱保真之间的典型权衡。数据来源：ArcGIS Pro 3.7 Pansharpen 栅格函数官方参数 [21]*

## 官方文档引用

[1] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/data-management/an-overview-of-the-las-dataset-toolset.htm
> 「“LAS 数据集”工具集包含用于创建、管理和优化 LAS 数据集的工具。」

[2] https://pro.arcgis.com/zh-cn/pro-app/3.4/tool-reference/3d-analyst/an-overview-of-the-point-cloud-toolset.htm
> 「点云工具集包含用于分类、转换和管理点云数据的工具集和工具。」

[3] https://pro.arcgis.com/zh-cn/pro-app/latest/help/data/imagery/generate-ortho-mapping-products-using-the-custom-wizard.html
> 「匹配方法指定将用于生成点云的匹配方法：扩展的地形匹配、半全局匹配、多视图匹配。」

[4] https://doc.arcgis.com/en/imagery/workflows/best-practices/sharing-lidar-points-for-visualization-on-the-web.htm
> 「Use the Create Point Cloud Scene Layer Content geoprocessing tool to convert the LAS points… into the optimized I3S format… prepared… as a scene layer package (SLPK).」

[5] https://pro.arcgis.com/zh-cn/pro-app/3.5/help/mapping/layer-properties/create-scene-layer.htm
> 「可通过多种工具创建场景图层内容。」

[6] https://doc.esri.com/en/arcgis-pro/latest/help/analysis/3d-analyst/understand-las-coordinate-system.html
> 「LAS format files may also have missing, incomplete, or improperly defined spatial reference information that will cause them to display in the wrong location.」

[7] https://pro.arcgis.com/en/pro-app/3.7/help/analysis/raster-functions/geometric-function.html
> 「The Geometric function produces an orthorectified image based on a sensor definition and a terrain model.」

[8] https://pro.arcgis.com/zh-cn/pro-app/latest/tool-reference/3d-analyst/classify-las-ground.htm
> 「标准分类方法通常能满足大多数数据集的地面点检测需求。」

[9] https://pro.arcgis.com/en/pro-app/3.7/help/data/las-dataset/interactive-las-class-code-editing.html
> 「You are not able to edit the classification codes of .laz files if they are referenced by a LAS dataset in ArcGIS Pro.」

[10] https://pro.arcgis.com/zh-cn/pro-app/latest/help/data/imagery/ortho-mapping-in-arcgis-pro.htm
> 「正射映射需要 ArcGIS Pro Advanced 许可或 Reality Mapping 用户扩展模块许可。」

[11] https://pro.arcgis.com/en/pro-app/latest/help/data/las-dataset/work-with-las-dataset-statistics.htm
> 「Statistics can be computed for an entire LAS dataset containing several LAS files, or they can be computed for a single file.」

[12] https://pro.arcgis.com/en/pro-app/latest/help/mapping/layer-properties/elevation-source-layers.html
> 「An elevation source layer references the data that contributes height values to the elevation surface layer.」

[13] https://support.esri.com/zh-cn/knowledge-base/error-failed-to-execute-createintegratedmeshscenelayerp-000031846
> 「对于输入数据集，选择要转换的 OSGB 数据。」

[14] https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/color-balance-mosaic-dataset.html
> 「When using the dodging technique, each pixel needs a target color, which is picked up from the target color surface.」

[15] https://pro.arcgis.com/en/pro-app/3.7/help/data/imagery/creating-a-mosaic-dataset-pro-.html
> 「Mosaic datasets are used to manage, display, publish, and distribute imagery.」

[16] https://doc.esri.com/zh-cn/arcgis-pro/latest/help/analysis/raster-functions/las-dataset-to-raster-function.html
> 「选择像素大小时，最好使其既能比平均点间距大几倍，但是又要足够小以便能标识间隙或空白区域。」

[17] https://pro.arcgis.com/ar/pro-app/3.5/tool-reference/spatial-analyst/an-overview-of-the-surface-tools.htm
> 「With the Surface tools, you can quantify and visualize a terrain landform represented by a digital elevation model.」

[18] https://pro.arcgis.com/ar/pro-app/3.5/tool-reference/geostatistical-analyst/an-overview-of-the-interpolation-toolset.htm
> 「The Interpolation toolset contains tools that predict values at unmeasured locations.」

[19] https://pro.arcgis.com/en/pro-app/latest/tool-reference/conversion/conversion-toolbox-license.htm
> 「Raster to Point Included Included Included；Raster to Polygon Included Included Included。」

[20] https://pro.arcgis.com/en/pro-app/latest/help/analysis/raster-functions/raster-functions.htm
> 「Functions can be applied to raster layers, mosaic datasets, raster items in a mosaic dataset, and image service layers.」

[21] https://pro.arcgis.com/zh-cn/pro-app/latest/help/analysis/raster-functions/pansharpening-function.htm
> 「全色锐化类型选择要使用的平移锐化算法：Brovey、Esri、Gram-Schmidt、IHS、平均值。」

[22] https://pro.arcgis.com/zh-cn/pro-app/latest/help/analysis/image-analyst/the-change-detection-wizard.htm
> 「分类变化、像素值变化、光谱变化检测或时间序列变化检测。」

[23] https://pro.arcgis.com/en/pro-app/latest/tool-reference/3d-analyst/las-building-multipatch.htm
> 「Each building model is generated by constructing a TIN from the LAS points that overlap the building footprint polygon.」

[24] https://www.esri.com/arcgis-blog/products/arcgis-pro/3d-gis/whats-new-for-3d-analyst-in-arcgis-pro-3-7
> 「ArcGIS Pro 3.7 continues to strengthen 3D Analyst as a core capability for surface modeling, point cloud analysis, and 3D data production.」

[25] https://pro.arcgis.com/en/pro-app/latest/get-started/license-levels.htm
> 「Create and manage ortho mapping workspaces; generate elevation data and orthomosaics from image collections.」

[26] https://pro.arcgis.com/en/pro-app/2.7/tool-reference/data-management/an-overview-of-the-raster-toolset.htm
> 「Mosaic Dataset Create and edit mosaic datasets. Ortho Mapping Create orthorectified image mosaic from remote sensing images.」
