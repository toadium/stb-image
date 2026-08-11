# v3.0 需求设计

## 功能清单（4个，按实现顺序）

### 1. EXIF 写入
- **需求**：补齐现有 EXIF 读取，支持将 ExifInfo 写入 JPEG 字节流
- **API**：
  - `write_exif_to_bytes(info : ExifInfo, jpeg_data : Bytes) -> Bytes raise LoadError` — 将 EXIF 插入 JPEG APP1 segment
  - `create_exif_segment(info : ExifInfo) -> Bytes` — 构造 APP1 segment（"Exif\0\0" + TIFF 头 + IFD0）
- **约束**：纯 MoonBit，不破坏现有 JPEG 解码，三目标通过

### 2. 接缝裁剪 seam carving
- **需求**：内容感知缩放，支持缩小和放大
- **API**：
  - `seam_carve_resize(img : Image, new_w : Int, new_h : Int) -> Image raise LoadError`
  - `find_vertical_seam(energy : Array[Double], w : Int, h : Int) -> Array[Int]`
  - `remove_vertical_seam(img : Image, seam : Array[Int]) -> Image`
  - `find_horizontal_seam(energy : Array[Double], w : Int, h : Int) -> Array[Int]`
  - `remove_horizontal_seam(img : Image, seam : Array[Int]) -> Image`
- **约束**：Sobel 能量 + DP 累积 + 回溯，纯 MoonBit

### 3. SLIC 超像素
- **需求**：Simple Linear Iterative Clustering 超像素分割
- **API**：
  - `slic(img : Image, k : Int, m : Int, max_iters : Int) -> SuperpixelResult raise LoadError`
  - `SuperpixelResult` 结构：`labels : Array[Int]`（每个像素的聚类标签）, `centers : Array[(Int, Int)]`（聚类中心坐标）, `num_labels : Int`
- **约束**：Lab 空间距离 + 迭代聚类，复用 @process/color 的 rgb_to_lab

### 4. 16-bit/float 操作泛化
- **需求**：为 Image16/ImageF 补齐 filter/transform/color 常用操作
- **API**（按 `_16`/`f` 命名约定）：
  - filter: `box_blur_16`/`box_blurf`, `gaussian_blur_16`/`gaussian_blurf`, `sharpen_16`/`sharpenf`
  - transform: `rotate_90_16`/`rotate_90f`, `flip_horizontal_16`/`flip_horizontalf`
  - color: `adjust_brightness_16`/`adjust_brightnessf`, `to_grayscale_16`/`to_grayscalef`
- **约束**：按现有 `crop_16`/`cropf` 模式，pure 后端 + reexport 转发

## 非功能需求
- 纯 MoonBit 实现（无 C FFI），三目标（native/wasm-gc/js）均通过
- 每个新功能必须有测试，测试覆盖正常/边界/错误情况
- 不破坏 v1.0 API 冻结，新增功能只添加不修改
- 命名遵循 snake_case，Image16 变体用 `_16` 后缀，ImageF 变体用 `f` 后缀
