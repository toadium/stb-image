# v3.0 技术设计

## 架构：在现有八子包架构上扩展

```
src/
├── meta/
│   ├── exif.mbt          # 现有：读取
│   └── exif_write.mbt    # 新增：写入（EXIF 写入）
├── process/
│   ├── transform/
│   │   └── seam_carving.mbt  # 新增（seam carving）
│   └── segment/
│       └── slic.mbt          # 新增（SLIC 超像素）
├── types/
│   └── image_types.mbt      # 新增 SuperpixelResult 结构
├── pure/
│   └── process/             # 16-bit/float 泛化主要工作面
└── reexport.mbt             # 新增 API 转发
```

## 功能 1：EXIF 写入

### 实现位置：`src/meta/exif_write.mbt`

### 算法
1. 构造 APP1 segment：`FF E1` + 长度(2字节) + `"Exif\0\0"` + TIFF 数据
2. TIFF 数据：字节序标记(`"II"` 小端 / `"MM"` 大端) + TIFF magic(0x002A) + IFD0 偏移(0x0008)
3. IFD0：条目数(2字节) + N 个 IFD 条目(每条 12 字节) + 下一 IFD 偏移(4字节)
4. IFD 条目：tag(2) + type(2) + count(4) + value/offset(4)
5. 插入 JPEG：在 SOI(`FF D8`) 之后插入 APP1

### IFD 条目映射
| ExifInfo 字段 | Tag | Type | 
|---------------|------|------|
| make | 0x010F | ASCII(2) |
| model | 0x0110 | ASCII(2) |
| orientation | 0x0112 | SHORT(3) |
| date_time | 0x0132 | ASCII(2) |

## 功能 2：seam carving

### 实现位置：`src/process/transform/seam_carving.mbt`

### 算法
1. **能量计算**：Sobel 梯度幅值 `|Gx| + |Gy|`，复用现有 edge_detect_sobel 逻辑
2. **垂直 seam DP**：`M[i][j] = E[i][j] + min(M[i-1][j-1], M[i-1][j], M[i-1][j+1])`
3. **回溯**：从最后一行最小值开始，向上回溯找 seam 路径
4. **移除 seam**：逐行移除 seam 对应像素，宽度减 1
5. **缩放**：宽度缩小用移除 seam，宽度放大用插入 seam（复制最小能量 seam）

### 依赖
- `@types`：Image 类型
- `moonbitlang/core/math`：数学运算
- 内部实现 Sobel 能量（避免跨包依赖）

## 功能 3：SLIC 超像素

### 实现位置：`src/process/segment/slic.mbt`

### 算法
1. **初始化**：在图像上均匀初始化 K 个聚类中心（网格间距 S = sqrt(N/K)）
2. **Lab 转换**：将中心颜色从 RGB 转为 Lab（复用 @process/color）
3. **迭代聚类**（通常 10 次）：
   - 对每个中心 2S×2S 邻域内的像素，计算距离 `d = sqrt(d_lab^2 + (d_xy/S)^2 * m^2)`
   - 将像素分配到最近中心
   - 更新中心为聚类成员的均值
4. **后处理**：连通域强化（消除小区域）

### 新增类型（`src/types/image_types.mbt`）
```moonbit
pub(all) struct SuperpixelResult {
  labels : Array[Int]      // 每像素的聚类标签（w*h 长度）
  centers : Array[(Int, Int)]  // 聚类中心坐标
  num_labels : Int         // 实际标签数
} derive(Eq, @debug.Debug)
```

### 依赖
- `@types`：Image, SuperpixelResult
- `@process/color`：rgb_to_lab（已有）

## 功能 4：16-bit/float 操作泛化

### 实现策略：按现有 `_16`/`f` 命名约定，为常用操作添加变体

### 优先泛化的操作（按使用频率）
1. **filter**: box_blur, gaussian_blur, sharpen
2. **transform**: rotate_90, rotate_180, rotate_270, flip_horizontal, flip_vertical
3. **color**: adjust_brightness, adjust_contrast, to_grayscale, to_rgb

### 实现模式（参考 crop_16/cropf）
```moonbit
// 8-bit（现有）
pub fn box_blur(img : Image, ksize : Int) -> Image
// 16-bit（新增）
pub fn box_blur_16(img : Image16, ksize : Int) -> Image16
// float（新增）
pub fn box_blurf(img : ImageF, ksize : Int) -> ImageF
```

### 像素读写辅助
- Image: `data[idx]` (1 byte/sample)
- Image16: `data.read_u16_le(idx * 2)` / `data.write_u16_le(idx * 2, v)` (2 bytes/sample)
- ImageF: `data.read_f32_le(idx * 4)` / `data.write_f32_le(idx * 4, v)` (4 bytes/sample)

### reexport.mbt 更新
- 类型别名 + `pub let` 转发（无默认参数的函数）
- `pub fn` 包装转发（有默认参数的函数）

## 测试策略
- 每个功能新增对应 `_test.mbt` 文件
- 测试覆盖：正常输入、边界条件、错误情况、roundtrip 验证
- 三目标测试：`moon test`（默认 native）+ `moon test --target wasm-gc` + `moon test --target js`
- 最终运行 `moon info && moon fmt` 更新接口和格式化
