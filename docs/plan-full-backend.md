# 全后端方案：去除 C FFI 依赖

> 制定日期：2026-08-09 | 目标：支持 native + wasm + js 全后端，不依赖 C FFI

## 现状分析

### 当前架构

```
src/
├── types/     ✅ 全目标（6 类型：Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError）
├── core/      ❌ native only（28 个 FFI 函数，依赖 stb_image.h/write.h/resize2.h）
├── pure/      ✅ 全目标（6 解码器 + 4 编码器 + 77 处理函数）
├── lib/       ✅ 全目标（pure 侧统一 API + 格式自动分派）
├── process/   ❌ native only（7 子子包，纯 MoonBit 但依赖 @core 类型）
├── format/    ❌ native only（纯 MoonBit 但依赖 @core 类型）
├── meta/      ❌ native only（纯 MoonBit 但调用 @core.read_file_bytes）
├── util/      ❌ native only（纯 MoonBit 但调用 @core.resize）
└── reexport.mbt  ❌ native only（未集成 @pure/@lib）
```

### 关键发现

| 发现 | 影响 |
|------|------|
| process/* 和 format 的源代码**仅依赖 @core 类型，不调用任何 @core 函数** | 可零成本切换到 @types |
| @types 缺 3 个枚举（ImageFormat/ResizeFilter/ResizeEdge） | 需补迁 |
| meta 调用 `@core.read_file_bytes`（FFI） | 需纯 MoonBit 文件 IO 替代 |
| util 调用 `@core.resize`（FFI） | 需纯 MoonBit resize 实现 |
| @pure 已有 6 解码器 + 4 编码器 + 77 处理函数 | 基础已具备 |
| @pure 缺 PNG/JPEG/HDR 编解码、resize、Image16/ImageF 处理 | 需补实现 |
| reexport.mbt **完全未集成 @pure/@lib** | 顶层 API 仍全走 FFI |

### FFI 独有功能清单（需纯 MoonBit 替代）

| 类别 | FFI 函数 | 纯 MoonBit 难度 |
|------|---------|----------------|
| PNG 解码/编码 | stbi_load/write_png | **高**（zlib inflate/deflate + PNG 容器） |
| JPEG 解码/编码 | stbi_load/write_jpg | **很高**（DCT/霍夫曼/量化） |
| HDR 解码/编码 | stbi_loadf/write_hdr | **中**（RGBE 格式，相对简单） |
| 16-bit 加载 | stbi_load_16 | **低**（仅数据类型扩展） |
| resize | stbir_resize | **中**（双线性/最近邻插值） |
| 动画 GIF 多帧 | stbi_load_gif | **中**（GIF 容器已实现，需扩展多帧） |
| info 查询 | stbi_info | **低**（读头部即可） |
| 配置函数 | flip/unpremultiply/gamma | **低**（纯数据处理） |
| 文件 IO | read_file_bytes | **低**（MoonBit 标准库替代） |

---

## 改造方案

### 阶段 1：类型补全 + 8 子包解耦（预计 1-2 天）

**目标**：process/* 和 format 解除 native 限制，变为全目标可用

**步骤**：

1. **补迁 3 个枚举到 @types**
   - 将 `ImageFormat` 从 `core/image_detect.mbt` 迁至 `types/image_types.mbt`
   - 将 `ResizeFilter`、`ResizeEdge` 从 `core/image_resize_native.mbt` 迁至 `types/image_types.mbt`
   - @core 改为从 @types re-export 这 3 个枚举

2. **process/* 7 个子子包切换 @core → @types**
   - 每个 `moon.pkg`：`import @core` → `import @types`
   - 每个源文件：`@core.Image` → `@types.Image`、`@core.LoadError` → `@types.LoadError` 等
   - 删除 `supported_targets = "native"` 限制
   - 测试文件保留 @core 导入（测试仍可 native only）

3. **format 切换 @core → @types**
   - 同上操作

**验证**：`moon check --target wasm` 通过，process/format 函数在 wasm 可用

---

### 阶段 2：meta/util 解耦（预计 1-2 天）

**目标**：meta 和 util 解除 native 限制

**步骤**：

1. **meta：替代 read_file_bytes**
   - 在 @types 或 @pure 中新增 `read_file_bytes_pure`（使用 MoonBit `@io`/`@fs` 标准库）
   - `meta/exif.mbt` 和 `meta/png_meta.mbt` 中 `@core.read_file_bytes` → 纯 MoonBit 实现
   - 删除 meta 对 @core 的依赖，改为依赖 @types
   - 删除 `supported_targets = "native"`

2. **util：替代 @core.resize**
   - 在 @pure 中实现 `resize_pure`（最近邻 + 双线性插值）
   - `util/image_util.mbt` 中 `@core.resize` → `@util.resize_pure`
   - util 改为依赖 @types + @pure + @process/transform
   - 删除 `supported_targets = "native"`

**验证**：`moon check --target wasm` 全部通过，meta/util 在 wasm 可用

---

### 阶段 3：@pure 补齐核心能力（预计 3-5 天）

**目标**：@pure 覆盖 FFI 独有的关键功能

**优先级排序**（按难度从低到高）：

1. **配置函数**（低难度）
   - `set_flip_vertically_on_load_pure` / `flip_vertically_on_write_pure`
   - `set_unpremultiply_on_load_pure` / `convert_iphone_png_to_rgb_pure`
   - `hdr_to_ldr_gamma/scale_pure` / `ldr_to_hdr_gamma/scale_pure`
   - 纯数据处理，无 FFI 依赖

2. **info 查询**（低难度）
   - `info_from_bytes_pure`：读各格式头部获取尺寸
   - `is_16_bit_from_bytes_pure` / `is_hdr_from_bytes_pure`
   - `failure_reason_pure`：返回纯 MoonBit 错误字符串

3. **16-bit 支持**（低难度）
   - 扩展 @pure 解码器支持 16-bit 输出
   - `load_16_from_bytes_pure`

4. **resize**（中难度）
   - `resize_pure`：最近邻 + 双线性插值
   - `resize_srgb_pure` / `resize_16_pure` / `resizef_pure`

5. **HDR 解码/编码**（中难度）
   - `decode_hdr_pure`：RGBE 格式解析
   - `encode_hdr_pure`：RGBE 格式编码

6. **动画 GIF 多帧**（中难度）
   - 扩展现有 `decode_gif_pure` 支持多帧
   - `load_gif_from_bytes_pure`：返回 `GifAnimation`

7. **PNG 解码/编码**（高难度）
   - `decode_png_pure`：需实现 zlib inflate + PNG 容器解析
   - `encode_png_pure`：需实现 zlib deflate + PNG 容器编码
   - 可依赖 `moonbitlang/core/encoding` 或第三方 zlib 库

8. **JPEG 解码/编码**（很高难度）
   - `decode_jpeg_pure`：DCT + 霍夫曼解码 + 反量化
   - `encode_jpeg_pure`：DCT + 霍夫曼编码 + 量化
   - 工作量最大，可考虑后期实现或依赖第三方库

---

### 阶段 4：统一 API 重构（预计 1-2 天）

**目标**：reexport.mbt 集成 @pure/@lib，提供全后端统一 API

**步骤**：

1. **reexport.mbt 双路径架构**
   ```
   // 全后端函数（从 @types + @pure + @lib + @process + @format + @meta + @util）
   pub let load_from_bytes = @lib.load_from_bytes_auto  // 纯 MoonBit
   pub let crop = @process/transform.crop               // 纯 MoonBit
   pub let box_blur = @process/filter.box_blur          // 纯 MoonBit
   
   // native 增强函数（仅 native 目标可用，通过条件编译）
   pub fn load_from_path(path : String, req_channels~ : Int? = None) -> Image {
     // native: 调用 @core FFI（高性能）
     // wasm/js: 调用 @pure 纯 MoonBit（文件 IO 通过标准库）
   }
   ```

2. **格式自动分派**
   - `decode_any`：先尝试 @pure 解码器，失败后 fallback 到 @core（native only）
   - 或直接全走 @pure（如果 pure 已覆盖所有需要的格式）

3. **顶层 moon.pkg 调整**
   - 移除 `supported_targets = "native"` 限制
   - @core 改为条件依赖（仅 native 目标）

---

### 阶段 5：完全移除 @core（预计 1 天）

**目标**：彻底删除 C FFI 依赖，项目成为纯 MoonBit 库

**操作**：
- 删除 `src/core/`（ffi.mbt、wrapper.c、stb_image*.h、所有 image_*_native.mbt）
- 删除 `src/core/moon.pkg`
- reexport.mbt 中所有 @core 引用替换为 @pure/@lib 等价函数
- 根包 `moon.pkg` 移除 @core 导入，移除 `supported_targets = "native"` 限制
- 删除 `scripts/prepare.py`（不再需要下载 stb 头文件）
- `moon.mod` 更新 `preferred_target`，移除 FFI 相关 keywords

**收益**：架构简洁、全后端统一、无 FFI 维护负担、无 C 编译器依赖

---

## 实施路线图

```
阶段 1: 类型补全2 + 8子包解耦 ──→ 阶段 2: meta/util解耦
                                        │
                                        ▼
阶段 5: 完全移除@core ←── 阶段 4: 统一API重构 ←── 阶段 3: @pure补齐能力
```

| 阶段 | 目标 | 预计工作量 | 优先级 |
|------|------|-----------|--------|
| 1 | 8 子包解耦 | 1-2 天 | **P0**（立即可做，零风险） |
| 2 | meta/util 解耦 | 1-2 天 | **P0**（依赖阶段 1） |
| 3 | @pure 补齐能力 | 3-5 天 | **P1**（PNG/JPEG 可延后） |
| 4 | 统一 API 重构 | 1-2 天 | **P1**（依赖阶段 2-3） |
| 5 | 完全移除 @core | 1 天 | **P2**（最后执行） |

---

## 风险与对策

| 风险 | 对策 |
|------|------|
| PNG/JPEG 纯 MoonBit 实现复杂度高 | 分阶段实施，先支持 BMP/QOI/TGA/PNM/PSD/GIF，PNG/JPEG 延后 |
| 纯 MoonBit 性能不如 C FFI | 接受性能折损，换取全后端支持；后续可优化热点算法 |
| zlib 依赖（PNG 需要） | 使用 moonbitlang/core/encoding 或第三方 zlib 包 |
| 测试覆盖度 | 每阶段完成后 `moon test --target wasm` + `moon test --target native` 双目标验证 |
| API 兼容性 | reexport.mbt 保持函数签名不变，仅切换内部实现 |

---

## 阶段 1 立即可执行的具体操作清单

1. `src/types/image_types.mbt`：添加 `ImageFormat`、`ResizeFilter`、`ResizeEdge` 三个枚举
2. `src/core/image_detect.mbt`：`ImageFormat` 改为从 @types re-export
3. `src/core/image_resize_native.mbt`：`ResizeFilter`、`ResizeEdge` 改为从 @types re-export
4. `src/process/*/moon.pkg`：`@core` → `@types`，删除 `supported_targets = "native"`
5. `src/process/*/*.mbt`：`@core.Image` → `@types.Image` 等全局替换
6. `src/format/moon.pkg`：`@core` → `@types`，删除 `supported_targets = "native"`
7. `src/format/*.mbt`：`@core.Image` → `@types.Image` 等全局替换
8. 验证：`moon check --target native` + `moon check --target wasm`
9. 验证：`moon test --target native`（847 测试仍通过）
