# fieldimg — 图像场几何（GeoVerse Phase 1）

> **层级**：四层 · 领域高阶算法层
> **定位**：将图像提升为场实体，标量场（灰度）/矢量场（RGB）/张量场；场是一等几何对象。

## 核心思想

图像不是像素数组，是**二维场实体**。本模块将图像处理算子统一为场算子的特例：

| 场算子 | 图像处理含义 |
|--------|-------------|
| `field_gradient` | 边缘检测（Sobel/Canny 的数学本质） |
| `field_laplacian` | 模糊/锐化（LoG） |
| `field_integrate` | 直方图/总量积分 |
| `field_clamp` | 阈值分割 |
| `field_isosurface` | 等值线提取 → 分割 |

## 模块结构

| 文件 | 内容 |
|------|------|
| `scalar_field.mbt` | 标量场：2D 标量场类型 + 求值/设值/最值 |
| `vector_field.mbt` | 矢量场：2D 矢量场类型 + 求值/幅值 |
| `tensor_field.mbt` | 张量场：结构张量 + 特征值分解 |
| `field_ops.mbt` | 场算子：梯度/散度/旋度/拉普拉斯/积分/阈值/代数/等值/直方图 |
| `field_bind.mbt` | Image ↔ ScalarField / VectorField 双向转换 |

## 公共 API

### 类型

- `ScalarField` — 标量场（width × height，Float 数据）
- `VectorField` — 矢量场（width × height × dim，Float 数据）
- `TensorField` — 张量场（width × height × rows × cols，Float 数据）

### 场算子

- `field_gradient(f)` → 矢量场 [gx, gy]
- `field_divergence(v)` → 标量场 div = du/dx + dv/dy
- `field_curl(v)` → 标量场 curl = dv/dx - du/dy
- `field_laplacian(f)` → 标量场 Δf
- `field_integrate(f)` → Float 全场积分
- `field_clamp(f, lo, hi)` → 钳制场值
- `field_mask(f, threshold)` → 二值掩码
- `field_add / field_sub / field_mul / field_blend` → 场代数
- `field_isosurface(f, level, epsilon)` → 等值线提取
- `field_histogram(f, min, max, bins)` → 直方图

### Image 双向转换

- `image_to_scalar_field(img)` → 标量场（灰度归一化 [0,1]）
- `scalar_field_to_image(field)` → 灰度图
- `image_to_vector_field(img)` → 矢量场（RGB）
- `vector_field_to_image(field)` → RGB 图

## 数学恒等式（属性测试验证）

- `gradient(constant) = 0` — 常量场梯度为零
- `laplacian(constant) = 0` — 常量场拉普拉斯为零
- `curl(gradient(f)) = 0` — 梯度场无旋
- `field_sub(field_add(a, b), b) = a` — 加法逆元

## 测试

64 个测试（5 个测试文件），四目标全绿（native/wasm-gc/js/wasm）。