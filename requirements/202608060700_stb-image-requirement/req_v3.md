# `stb-image`：MoonBit 原生 FFI 绑定 `stb_image.h` 的需求文档

本文档是对用户原始需求（`D:\CodeWorkspace\forMoonbit\stb-image\需求文档.md`）的澄清结果，并在 v1 基础上按用户"我需要一个完整的库"的指示重新审视边界约束、补充版本迭代计划。澄清过程中已结合源码仓库 `D:\CodeWorkspace\moonbit_wp` 核实关键事实，并在合理推断处自然标注。下游架构设计与技术设计可据此推进，无需再回查原始表述。

## 一、项目背景与目标

### 目标用户
在 MoonBit 中处理图片资源的前端/游戏/工具开发者，以及希望用 MoonBit 快速读取 PNG/JPEG/BMP/GIF/WebP 等常见格式的个人开发者。

### 要解决的核心问题
MoonBit 生态当前缺少对广泛使用的 `stb_image.h` 的绑定。`stb_image` 是事实上的行业标准单头文件 C 库，API 稳定、支持格式多（含 HDR/PSD/PIC/PNM 等 MoonBit 生态较少覆盖的格式），读取路径足够通用，且其姊妹库 `stb_image_write.h` 提供 PNG/BMP/TGA/JPEG/HDR 的写入能力。将这两个头文件以 MoonBit 包形式绑定，可自包含地提供完整的图像 load/write 能力，作为 MoonBit 生态中独立的图像处理基础库。

经源码仓库核实，现状如下（已核实，非推断）：

- **mooncakes stb 绑定空白**：`mooncakes.io-index/user` 下 12 个用户目录（bobzhang、bzy-debug、fantix、Guest0x0、lijunchen、lucifer1004、peter-jerry-ye、test、tonyfettes、wangziling、Yoorkin、Yu-zh）无 stb 相关包；`.mooncakes` 缓存中亦无 stb/image 相关包。**stb 绑定完全空白**结论已核实
- **本地工作区无现成通用图像 codec 参考实现**：`moonbit_wp` 内仅有 mbtpdf/graphics/pdfimage、office.mbt/pdflite/image（PDF 专用图像处理），非通用图像 codec，无可直接复用的 PNG/JPEG 解码参考实现

### 项目定位
本项目为 MoonBit 原生 FFI 绑定项目，将 `stb_image.h`（及后续 `stb_image_write.h`）的能力以 MoonBit 包形式暴露。**最终目标是提供一个完整的图像处理库**，覆盖 load/write/info/16-bit/float/flip/回调入口等 stb_image 全部能力。MVP 阶段先以 native 目标 + load 路径落地，后续按版本迭代计划逐步演进到完整库（见第六节）。项目根目录为 `D:\CodeWorkspace\forMoonbit\stb-image`。

## 二、MVP 范围

MVP 是完整库演进路径的第一步，聚焦最常用的 load 路径，以最小 API 面验证 FFI 可行性与工具链配合。完整能力集见第六节"版本迭代计划"。

### 加载入口（已澄清）
原始需求提到"从文件路径、`Bytes`、`InputStream` 加载图片"。经核实，**MoonBit 标准库中不存在 `InputStream` 类型**（`core` 中无此类型；`moonbitlang/async/io` 中有异步 `Reader` trait，但属于异步库且不适用于 MVP 的同步 native 场景）。结合原始需求后文"当前 MVP 限定本地/内存入口，网络流读取可后续扩展"，澄清如下：

- **MVP 暴露两个加载入口**：
  1. `load_from_path(path : String) -> Image raise LoadError`：从本地文件路径加载
  2. `load_from_bytes(data : Bytes) -> Image raise LoadError`：从内存字节序列加载
- **流式接口（`InputStream` 或类似）不在 MVP 范围内**，留作后续扩展。后续如需流式接口，可基于 `moonbitlang/async/io` 的 `Reader` trait 设计异步包装，或自定义同步流 trait，或直接绑定 stb_image 的 `stbi_io_callbacks`（read/skip/eof）机制，但这是后话

### 支持格式
与 `stb_image` 默认配置一致，支持以下 9 种格式的 decode：
- PNG、JPEG、BMP、GIF、WebP、TGA、PSD、HDR、PIC

（注：stb_image v2.30 默认还包含 PNM（PPM/PGM）decode；MVP 暂不暴露 PNM，留作后续版本增量。stb_image v2.x 默认包含 WebP decode；如 vendoring 的版本对 WebP 有特殊开关需求，应在 vendoring 脚本中显式处理。）

### 返回的 `Image` 值类型
原始需求说"返回图像信息：width、height、channels（灰度/RGB/RGBA）、data（`Bytes`）"。澄清如下：

- `Image` 为值类型（struct），包含四个字段：
  - `width : Int`
  - `height : Int`
  - `channels : Int`：**原始通道数**（1=灰度、2=灰度+alpha、3=RGB、4=RGBA），由 stb_image 的 `channels` 输出参数提供，**不做归一化**
  - `data : Bytes`：像素数据，长度为 `width * height * channels`
- **设计决策**：本项目保留原始通道，让调用者决定是否转换。这是 stb_image 的自然语义，也是完整库应有的灵活性——完整库后续版本会暴露 `req_channels` 参数（对应 stb_image 的 `desired_channels`），让调用者可选强制转换到指定通道数
- **MVP 不暴露 `req_channels` 参数**：始终返回原始通道。此为 MVP 保持最小 API 面的阶段性限制，完整库版本会解锁（见第五节边界约束与第六节版本迭代计划）

### 错误处理（已澄清）
原始需求说"以 MoonBit `Error` 返回'不支持的格式'或'解码失败'，不暴露 C 错误码"。"返回"一词有歧义（`raise` 还是 `Result`），澄清如下：

- **采用 `raise` 抛出错误**（符合 MoonBit 惯例）
- 定义 `suberror LoadError`，至少包含以下构造子（最终命名与层级由技术设计决定）：
  - `UnsupportedFormat(String)`：stb_image 无法识别的格式
  - `DecodeFailed(String)`：解码过程中的损坏数据、不完整文件等
  - 文件路径入口还需处理 `IOError`/文件不存在等情况（可复用标准库错误或并入 LoadError，由技术设计决定）
- **不暴露 C 错误码**：stb_image 本身不返回错误码（仅返回 NULL 指针表示失败），C wrapper 负责将失败转换为 MoonBit 错误。完整库版本可考虑暴露 `stbi_failure_reason()` 的简要原因字符串供调试，但 MVP 不做

### vendoring
- 将 `stb_image.h` 的稳定版本放入 `native-stub` 目录
- 提供可重复运行的下载脚本（建议 `scripts/prepare.py`，参考 make-moonbit-c-bindings 技能的 `templates/prepare.py`）
- 脚本要求：
  - **固定版本标识**：stb_image.h 无正式版本号，建议固定为上游 `nothings/stb` 仓库的特定 git commit hash（或日期标识），并在脚本中硬编码
  - **校验哈希**：下载后用 SHA256 校验，哈希值硬编码于脚本
  - **失败时报错退出**：下载失败或哈希不匹配时非零退出，**不自动回退**到其他版本
  - **幂等**：重复运行脚本应无 tracked diff
- **完整库版本会追加 vendoring `stb_image_write.h`**（同仓库姊妹头文件），脚本应预留扩展能力。建议脚本支持一次性 vendoring 多个头文件（如 `--include-write` 参数），避免 v0.2 纳入 write 时修改脚本结构

## 三、FFI 实现要点

依据 `moonbit-c-binding` 与 `make-moonbit-c-bindings` 技能（项目 `.codeartsdoer/skills` 下已配置），FFI 方案要点如下（保留用户原意，补充澄清）：

- **包布局**（建议，由技术设计最终确定；依据 MoonBit v0.10.5 规范，使用新格式 `moon.mod`/`moon.pkg`，旧 `moon.mod.json`/`moon.pkg.json` 已在 v0.10.4 弃用）：
  ```
  scripts/prepare.py          # vendoring 脚本
  moon.mod                    # preferred_target = "native"（新格式，非 moon.mod.json）
  src/moon.pkg                # native-stub + targets 门控（新格式，非 moon.pkg.json）
  src/wrapper.c               # ABI 归一化 C wrapper
  src/ffi.mbt                 # 私有 extern "c" 声明（native 门控；小写形式，与 skill 模板一致）
  src/stb_image.h             # vendored 上游头文件
  src/image.mbt               # 安全公开 MoonBit API
  src/image_test.mbt          # 回归测试
  src/README.mbt.md           # 测试过的文档示例
  ```
- **`moon.mod` 配置**（新 DSL 语法）：`preferred_target = "native"`（下划线，非旧 JSON 的 `"preferred-target"`）；可设 `supported_targets = "native"` 声明仅 native
- **`moon.pkg` 配置**（新 DSL 语法）：`options("native-stub": ["wrapper.c"], targets: { "ffi.mbt": ["native"], "README.mbt.md": ["native"] })`；`stb_image.h` 放入 `native-stub` 同目录。`README.mbt.md` 含 native FFI 示例故门控到 native；`image.mbt`（安全公开 API）是否门控由技术设计确定（其类型定义应在所有后端可用，但调用 FFI 的部分需条件编译），完整门控列表可参考 make-moonbit-c-bindings skill 模板
- **`ffi.mbt` 门控**：在 `moon.pkg` 的 `options(targets: { "ffi.mbt": ["native"] })` 中声明，仅 native 后端编译
- **`extern "c"` 大小写**：本项目使用小写 `extern "c"`（与 make-moonbit-c-bindings skill 模板一致）；MoonBit 官方 FFI 文档示例用大写 `extern "C"`，两者均接受，技术设计阶段可统一为官方大写形式
- **C wrapper 负责 ABI 归一化**：
  - `stbi_load_from_memory` 返回的 `unsigned char*` 拷贝到 `moonbit_make_bytes` 后由 MoonBit GC 接管
  - C 侧用 `stbi_image_free` 释放原始指针（避免泄漏）
  - 失败时（返回 NULL）转换为 MoonBit 错误信号（如返回 NULL 让 MoonBit 侧 raise）
- **数据返回统一用 `Bytes`**：避免 `FixedArray[Byte]` 二选一歧义；像素数据为二进制，无需 `@utf8` 字符串转换
- **所有权**：输入 `Bytes` 用 `#borrow`（stb 仅在调用期间读取，不存储引用）
- **`moonbit_make_bytes` 已核实存在**：`moonbit-native-runtime/include/moonbit.h:343` 声明 `moonbit_make_bytes(int32_t size, int value) -> moonbit_bytes_t`，方案可行

## 四、验收标准

- `moon check` 通过
- `moon test --target native` 通过
- 提供 **6-10 张测试图片**的自动回归测试，覆盖 happy path + 损坏文件 error path：
  - 测试格式聚焦 **PNG/JPEG/BMP/GIF/WebP** 5 种常见格式（基于"6-10 张"数量与 5 格式的合理匹配推断；TGA/PSD/HDR/PIC 为可选测试，如方便取得可一并纳入）
  - 每种格式至少 1 张正常图片 + 至少 1 张损坏图片用于 error path
  - 测试图片建议为小尺寸样本，vendoring 到仓库 `testdata/` 目录（或类似位置），来源可在脚本中生成或从公开测试图片库下载并固定哈希
- 通过 `moonbit-c-binding` 的 ASan 验证脚本（`scripts/run-asan.py`，从 `moonbit-c-binding/scripts/run-asan.py` 复制或调用），无内存泄漏/越界
- `moon info --target native` 正常
- 发布到 mooncakes.io 的包包含 `SKILL.md`（包使用说明/技能文档）与 minimal example（README 中的最小可用示例）

## 五、边界约束（重新审视）

用户明确声明"我需要一个完整的库"，不再满足于 MVP 仅读取的定位。本节重新审视 v1 中所有限制，区分**完整库目标**（最终应达成）与**MVP 阶段性限制**（当前不做但给出解锁计划）。阶段性限制均非永久边界，而是为控制 MVP 复杂度而设；完整库目标在第六节"版本迭代计划"中规划演进路径。

### 完整库目标（最终应达成）

以下能力属于完整库应有范畴，MVP 不做但后续版本会逐步纳入：

- **`stb_image_write` 绑定**：完整库应提供 PNG/BMP/TGA/JPEG/HDR 的 write 能力（vendoring `stb_image_write.h` v1.16）。这是"完整库"的核心增量之一
- **`req_channels` 参数**：完整库应暴露 `desired_channels` 参数，让调用者可选强制转换到 1/2/3/4 通道（对应 stb_image 的 STBI_grey/STBI_grey_alpha/STBI_rgb/STBI_rgb_alpha）
- **16-bit 接口**：完整库应暴露 `stbi_load_16*` 系列，返回 `UInt16` 像素数据（对应 16-bit PNG/PSD/TGA/PNM）
- **float 接口（HDR）**：完整库应暴露 `stbi_loadf*` 系列，返回 `Float` 像素数据（HDR 线性域）
- **info 接口**：完整库应暴露 `stbi_info*` 系列，不解码仅查询 width/height/channels；以及 `stbi_is_16_bit*`、`stbi_is_hdr*` 查询
- **flip 配置**：完整库应暴露 `stbi_set_flip_vertically_on_load`（及 write 端的 `stbi_flip_vertically_on_write`）
- **回调入口（I/O callbacks）**：完整库应暴露 `stbi_io_callbacks`（read/skip/eof）机制，支持从任意数据源加载（打包文件、自定义存储等）；这是 stb_image 的流式能力载体
- **动画 GIF**：完整库应暴露 `stbi_load_gif_from_memory`，返回多帧 + delays
- **PNM 格式**：完整库应暴露 PNM（PPM/PGM）decode
- **HDR 配置**：完整库应暴露 `stbi_hdr_to_ldr_gamma/scale`、`stbi_ldr_to_hdr_gamma/scale`
- **iPhone PNG / unpremultiply 配置**：完整库应暴露 `stbi_convert_iphone_png_to_rgb`、`stbi_set_unpremultiply_on_load`（含 thread-local 版本）
- **多目标支持**：完整库应考虑 wasm/js 目标支持（见第六节演进考量）

### MVP 阶段性限制（当前不做，给出解锁计划）

以下为 MVP 阶段为控制复杂度而设的限制，均非永久边界：

- **不做 `stb_image_write` 绑定**：MVP 仅读取。解锁计划：v0.2 纳入 write 能力（见第六节）
- **不暴露 `req_channels` 参数**：MVP 始终返回原始通道。解锁计划：v0.2 暴露 `req_channels` 可选参数
- **不暴露 16-bit / float 接口**：MVP 仅 8-bit。解锁计划：v0.3 纳入 16-bit 与 float（HDR）
- **不暴露 info / is_16_bit / is_hdr 查询**：MVP 仅完整解码。解锁计划：v0.3 纳入 info 系列
- **不暴露 flip / iPhone PNG / unpremultiply / HDR 配置**：MVP 不做加载期变换。解锁计划：v0.3 纳入配置 API
- **不暴露回调入口（I/O callbacks）**：MVP 仅 path + bytes 入口。解锁计划：v0.4 纳入 callbacks（流式能力）
- **不暴露动画 GIF**：MVP 仅单帧。解锁计划：v0.4 纳入 `stbi_load_gif_from_memory`
- **不暴露 PNM 格式**：MVP 支持 9 种格式（PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC），不含 PNM。解锁计划：v0.3 纳入 PNM
- **不暴露 `stbi_failure_reason`**：MVP 不暴露 C 错误字符串。解锁计划：v0.3 可选暴露供调试
- **不追求零拷贝**：MVP 允许解码后从 C 分配的缓冲拷贝到 MoonBit `Bytes`（由 GC 接管），C 侧随后释放原始缓冲。此为性能优化阶段的限制，完整库可在后续版本评估零拷贝可行性（需权衡 MoonBit GC 与 C 分配的边界安全）
- **仅支持 native 目标**：MVP 不暴露 wasm/js/wasm-gc 构建。`moon.mod` 设置 `preferred_target = "native"`（新格式，下划线；旧 `"preferred-target"` 已弃用），`ffi.mbt` 通过 `moon.pkg` 的 `targets` 门控到 native，可设 `supported_targets = "native"` 声明模块级支持范围（`supported_targets` 可在 `moon.mod` 模块级与 `moon.pkg` 包级两处设置，两者并存时取交集；此处指模块级）。解锁计划：v1.0 评估多目标支持（见第六节演进考量）

## 六、版本迭代计划

本节规划从 MVP 到完整库的演进路径。各版本目标、范围、关键 API 增量与验收标准概要如下。版本号非承诺，仅表达演进顺序与相对节奏。

### stb_image 完整能力梳理（规划基准）

依据上游 `stb_image.h` v2.30 与 `stb_image_write.h` v1.16 的完整 API 列表（已 webfetch 核实），完整库的能力矩阵如下：

**load 端（stb_image.h）**：
- 8-bit load：from path / from memory / from file / from callbacks
- 16-bit load：from path / from memory / from file / from callbacks（返回 `UInt16`）
- float load（HDR）：from path / from memory / from file / from callbacks（返回 `Float`）
- info（不完整解码）：from path / from memory / from file / from callbacks
- is_16_bit / is_hdr 查询：from path / from memory / from file / from callbacks
- 动画 GIF：`stbi_load_gif_from_memory`（多帧 + delays）
- 配置：flip_vertically_on_load、set_unpremultiply_on_load、convert_iphone_png_to_rgb（含 thread-local 版本）
- HDR 配置：hdr_to_ldr_gamma/scale、ldr_to_hdr_gamma/scale
- failure_reason、image_free
- I/O callbacks（read/skip/eof）
- desired_channels（req_channels）参数
- 支持格式：PNG、JPEG、BMP、GIF、WebP、TGA、PSD、HDR、PIC、PNM（PPM/PGM）

**write 端（stb_image_write.h）**：
- write PNG/BMP/TGA/JPEG/HDR to file
- write PNG/BMP/TGA/JPEG/HDR to func（callback）
- write PNG to mem
- flip_vertically_on_write
- 配置：tga_with_rle、png_compression_level、force_png_filter

### v0.1 — MVP（load 路径落地）

**目标**：验证 FFI 可行性，落地最常用的 load 路径，native 目标。

**范围**：
- 加载入口：`load_from_path`、`load_from_bytes`（8-bit）
- 支持格式：PNG、JPEG、BMP、GIF、WebP、TGA、PSD、HDR、PIC（9 种）
- 返回 `Image { width, height, channels, data : Bytes }`，保留原始通道，不暴露 `req_channels`
- 错误处理：`raise LoadError`（UnsupportedFormat / DecodeFailed）
- vendoring `stb_image.h`，native 目标

**关键 API 增量**：`load_from_path`、`load_from_bytes`、`Image`、`LoadError`

**验收标准概要**：见第四节（`moon check` / `moon test --target native` / ASan / 6-10 张测试图片 / `moon info` / SKILL.md + minimal example）

### v0.2 — write 能力 + req_channels

**目标**：补齐 write 路径，暴露通道强制转换，使库具备基本读写闭环。

**范围**：
- vendoring `stb_image_write.h` v1.16
- write 入口：`write_png_to_path`、`write_jpeg_to_path`（含 quality 参数）、`write_bmp_to_path`、`write_tga_to_path`、`write_hdr_to_path`（float 数据）；以及对应的 `*_to_bytes` 版本（基于 `stbi_write_*_to_func`）
- `req_channels` 可选参数：`load_from_path(path, req_channels~? : Int?)`、`load_from_bytes(data, req_channels~? : Int?)`，对应 stb_image 的 `desired_channels`
- flip 配置：`set_flip_vertically_on_load`、`flip_vertically_on_write`
- write 端配置：`set_png_compression_level`、`set_tga_with_rle`

**关键 API 增量**：`write_*_to_path`、`write_*_to_bytes`、`req_channels` 参数、flip 配置、write 端配置

**验收标准概要**：load → write round-trip 测试（decode 后 re-encode 比对）、req_channels 转换测试、flip 测试、ASan 通过

### v0.3 — 16-bit / float / info / 配置 API / PNM

**目标**：覆盖 stb_image 的全部数据类型与查询能力，补齐 HDR 与 16-bit 路径。

**范围**：
- 16-bit load：`load_16_from_path`、`load_16_from_bytes`（返回 `Image16 { width, height, channels, data : Bytes }`，data 为 `UInt16` 序列）
- float load（HDR）：`loadf_from_path`、`loadf_from_bytes`（返回 `ImageF { width, height, channels, data : Bytes }`，data 为 `Float` 序列）
- info 接口：`info_from_path`、`info_from_bytes`（返回 `{ width, height, channels }`，不解码）
- 查询接口：`is_16_bit_from_path`、`is_16_bit_from_bytes`、`is_hdr_from_path`、`is_hdr_from_bytes`
- HDR 配置：`hdr_to_ldr_gamma`、`hdr_to_ldr_scale`、`ldr_to_hdr_gamma`、`ldr_to_hdr_scale`
- iPhone PNG / unpremultiply 配置：`convert_iphone_png_to_rgb`、`set_unpremultiply_on_load`（含 thread-local 版本）
- PNM 格式支持（PPM/PGM decode）
- 可选暴露 `failure_reason` 供调试

**关键 API 增量**：`Image16`、`ImageF`、`load_16_*`、`loadf_*`、`info_*`、`is_16_bit_*`、`is_hdr_*`、HDR/iPhone/unpremultiply 配置、PNM

**验收标准概要**：16-bit PNG/PSD/TGA/PNM 测试、HDR float round-trip 测试、info 不解码测试、PNM 测试、ASan 通过

### v0.4 — 回调入口 / 动画 GIF / 流式能力

**目标**：暴露 stb_image 的 I/O callbacks 机制，支持从任意数据源加载；纳入动画 GIF。

**范围**：
- I/O callbacks：定义 MoonBit 侧的 `IoCallbacks` trait（read/skip/eof），绑定 `stbi_load_from_callbacks` / `stbi_load_16_from_callbacks` / `stbi_loadf_from_callbacks` / `stbi_info_from_callbacks`
- 动画 GIF：`load_gif_from_bytes`（返回多帧 `Array[Image]` + `Array[Int]` delays）
- 基于 callbacks 的流式读取包装（可基于 `moonbitlang/async/io` 的 `Reader` trait 设计异步包装，或自定义同步流 trait）

**关键 API 增量**：`IoCallbacks` trait、`load_*_from_callbacks`、`load_gif_from_bytes`

**验收标准概要**：自定义回调源（如 in-memory 包装、分块读取）测试、动画 GIF 多帧 + delays 测试、ASan 通过

### v1.0 — 多目标支持 / 完整库

**目标**：评估并纳入 wasm/js 目标支持，达成完整库定位。

**范围**：
- 多目标支持演进考量（见下节）
- API 面冻结，文档完整，SKILL.md 完善
- 性能优化评估（含零拷贝可行性评估）

**关键 API 增量**：多目标构建（如可行）

**验收标准概要**：多目标 `moon test` 通过、API 文档完整、性能基准测试

### 多目标支持（wasm/js）演进考量

MVP 仅 native 目标，因 `stb_image.h` 是 C 头文件，FFI 通过 `extern "c"` + native-stub 实现。多目标支持的演进需评估以下路径（由技术设计最终确定，本需求文档不预设答案）：

- **wasm 目标**：MoonBit wasm 后端可通过 Emscripten 将 `stb_image.h` 编译为 wasm 模块，再以 MoonBit extern wasm 导入。需评估 Emscripten 构建链集成、wasm 模块 vendoring、ABI 差异
- **js 目标**：可通过 Emscripten 编译为 js + wasm，或直接绑定浏览器原生 Image API（但后者偏离 stb_image 绑定初衷）。需评估哪种路径更符合项目定位
- **wasm-gc 目标**：stb_image 是 C 库，wasm-gc 后端对 C FFI 的支持需核实 MoonBit 工具链最新能力
- **替代路径**：若多目标 FFI 成本过高，可考虑在 wasm/js 目标提供纯 MoonBit 实现的 decode 路径（但此为重大设计决策，超出 FFI 绑定项目范畴，需独立评估）

多目标支持是 v1.0 的核心评估项，而非承诺交付。若评估表明某目标成本过高或收益过低，可在 v1.0 暂缓该目标并继续后续版本。

## 七、澄清与推断汇总

以下为澄清过程中对用户原始表述的推断与补充，供下游审议：

| 原始表述 | 澄清结果 | 依据 |
|---------|---------|------|
| "从文件路径、`Bytes`、`InputStream` 加载" | MVP 仅暴露 `load_from_path` + `load_from_bytes`，移除 `InputStream` | MoonBit 标准库无 `InputStream` 类型；原始需求已限定"本地/内存入口" |
| "以 MoonBit `Error` 返回" | 采用 `raise LoadError` 抛出错误 | MoonBit 惯例；"返回"一词歧义，选更惯用方式 |
| "channels（灰度/RGB/RGBA）" | 保留原始通道数，不归一化 | stb_image 自然语义；完整库应有的灵活性 |
| "6-10 张测试图片（PNG/JPEG/BMP/GIF/WebP）" | 聚焦 5 种常见格式，每种正常+损坏各 1 张 | 数量与格式数匹配；TGA/PSD/HDR/PIC 可选 |
| "包含 `SKILL.md` 与 minimal example" | `SKILL.md` 为包使用说明文档，minimal example 为 README 示例 | 基于 make-moonbit-c-bindings 技能的 `README.mbt.md` 惯例推断 |
| stb_image.h 版本标识 | 用 git commit hash 固定 | stb_image.h 无正式版本号，此为业界惯例 |
| 是否暴露 `req_channels` | MVP 不暴露，完整库 v0.2 暴露 | 基于"MVP 保持最小 API 面"推断；用户"完整库"诉求要求最终暴露 |
| "我需要一个完整的库" | 重新审视边界约束，区分完整库目标与 MVP 阶段性限制，新增版本迭代计划 | 用户 v2 修订指令明确要求 |
| stb_image 完整能力范围 | 涵盖 load/write/info/16-bit/float/flip/回调/动画 GIF/HDR 配置/PNM | webfetch 核实 stb_image.h v2.30 + stb_image_write.h v1.16 完整 API |
| PNM 格式 | MVP 不暴露，v0.3 纳入 | stb_image v2.30 默认支持 PNM，但原始需求仅列 9 种格式 |

## 八、下游设计输入

本需求文档已澄清至可支撑下游架构设计与技术设计的程度。下游设计需重点关注以下决策点（本需求文档不预设答案）：

1. **`LoadError` 的具体构造子与层级**：是否复用标准库 `IOError`，还是全部并入 `LoadError`
2. **C wrapper 的错误信号机制**：通过返回 NULL、输出参数、还是其他方式让 MoonBit 侧感知失败
3. **`Image` struct 的导出级别**：`pub(all)` 还是 `pub`，是否 derive `Eq`/`Show`/`@debug.Debug`
4. **测试图片的取得方式**：脚本生成、公开库下载、还是手工制作并 vendoring
5. **vendoring 的 stb_image.h 具体版本**：选择哪个 commit hash（建议选近期稳定 commit）
6. **`SKILL.md` 的具体内容结构**：是否参照 `.codeartsdoer/skills` 下的 SKILL.md 格式
7. **版本迭代的包结构策略**：v0.2 纳入 write 后，write API 放在同一包还是拆子包（如 `stb-image/write`）
8. **16-bit / float 数据的 `Bytes` 编码**：`Image16.data` 的 `UInt16` 序列以 little-endian 还是 native endian 存放于 `Bytes`；`ImageF.data` 的 `Float` 同理
9. **`IoCallbacks` trait 的设计**：read/skip/eof 的签名如何映射 MoonBit 语义（read 返回实际读取字节数、skip 支持负值 unget、eof 返回 Bool）
10. **多目标支持的路径选择**：Emscripten + wasm 导入、js + wasm、还是纯 MoonBit 实现；wasm-gc 后端 C FFI 可行性核实
11. **零拷贝可行性评估**：是否在 v1.0 或之后版本提供零拷贝路径（如直接暴露 C 指针包装的 `Bytes` 视图），需权衡 GC 边界安全
12. **write 端回调设计**：v0.2 的 `write_*_to_bytes` 基于 `stbi_write_*_to_func` 回调写入，MoonBit 侧需设计回调机制将 C 侧的写入回调转换为 `Bytes` 累积（如动态缓冲 + 容量扩展策略）；此设计与决策点 9 的 load 端 `IoCallbacks` trait 对偶，但方向相反（read vs write），需独立设计

## 修订说明（v2）

本轮修订基于用户明确指令"我需要一个完整的库"及"只参考，不引用已有库"的约束，在 v1 基础上修订如下：

| 审查/修订项 | 处理方式 |
|---------|---------|
| 用户声明"我需要一个完整的库"，不满足于 MVP 仅读取定位 | 重新审视第五节"边界约束"全部 6 条限制，区分"完整库目标"与"MVP 阶段性限制"，每条阶段性限制均给出解锁计划 |
| 新增"版本迭代计划" | 新增第六节，规划 v0.1（MVP）→ v0.2（write + req_channels）→ v0.3（16-bit/float/info/配置/PNM）→ v0.4（callbacks/动画 GIF/流式）→ v1.0（多目标/完整库）演进路径，含各版本目标、范围、关键 API 增量、验收标准概要 |
| stb_image 完整能力梳理 | webfetch 核实 stb_image.h v2.30 + stb_image_write.h v1.16 完整 API，作为版本迭代计划基准；发现 stb_image.h 默认含 PNM（v1 漏列），在版本迭代中补齐 |
| 移除所有 mizchi/image 引用 | 移除 v1 第 11 行"含 HDR/PSD/PIC 等其他 MoonBit 库未覆盖的格式"中的对比表述、第 15-23 行 mizchi/image 现状核实段落、第 52 行"与 mizchi/image 的差异"、第 58 行"与 mizchi/image 的 raise DecodeError 一致"、第 115 行"与 mizchi/image 的 encode 能力互补"、第 130 行"与 mizchi/image 归一化做法互补"；改为独立陈述 stb-image 自身的设计决策与价值 |
| 项目定位更新 | 第一节"项目定位"从"仅支持 native 目标"改为"最终目标是提供一个完整的图像处理库"，MVP 为演进路径第一步 |
| MVP 范围说明调整 | 第二节明确 MVP 是"完整库演进路径的第一步"，`req_channels` 不暴露从"完整库应有"角度重新定性为阶段性限制 |
| 下游设计输入补充 | 第八节新增 5 个决策点（版本迭代的包结构策略、16-bit/float 数据的 Bytes 编码、IoCallbacks trait 设计、多目标路径选择、零拷贝可行性评估） |
| 澄清与推断汇总更新 | 第七节移除 mizchi/image 相关推断，新增"完整库"诉求、stb_image 完整能力范围、PNM 格式三条推断 |

## 修订说明（v3）

本轮修订基于 req_v2.md 审查报告（`deliberations/202608060736_req-v2-review/output_v1.md`）的独立审查结论。审查结论为 **[APPROVED]**，6 个维度均通过，发现 3 项轻微问题与 2 项建议优化。本轮逐项独立判断并修订如下：

| 审查问题/建议 | 处理方式 | 修订位置 |
|---------|---------|---------|
| **问题 1（轻微）**：`extern "c"` 大小写——req_v2.md 用小写，官方文档示例用大写 `extern "C"` | **修订**：保持小写形式（与 make-moonbit-c-bindings skill 模板一致），在包布局注释中标注"小写形式，与 skill 模板一致"，并在 FFI 方案要点中新增一条说明，注明两者均接受、技术设计阶段可统一为官方大写形式 | 第 80 行（包布局注释）+ 第 88-89 行（新增 `extern "c"` 大小写说明条目） |
| **问题 2（轻微）**：`supported_targets` 声明级别表述——原文"包级"在 `moon.mod` 上下文中应为"模块级" | **修订**：将"声明包级支持范围"改为"声明模块级支持范围"，并补充说明 `supported_targets` 可在 `moon.mod` 模块级与 `moon.pkg` 包级两处设置、两者并存时取交集 | 第 144 行（第五节边界约束） |
| **问题 3（轻微）**：moon.pkg 配置示例未展示 `README.mbt.md` 门控 | **修订**：在 `moon.pkg` 配置示例中补全 `README.mbt.md` 的 native 门控（含 native FFI 示例），并说明 `image.mbt` 的门控由技术设计确定（类型定义应跨后端可用，但 FFI 调用部分需条件编译），完整门控列表可参考 skill 模板 | 第 87 行（FFI 方案要点 moon.pkg 配置） |
| **建议 1（优化）**：vendoring 脚本可考虑 `stb_image_write.h` 预留方式 | **采纳**：在 vendoring 部分补充建议脚本支持一次性 vendoring 多个头文件（如 `--include-write` 参数），避免 v0.2 时修改脚本结构 | 第 68 行（第二节 vendoring） |
| **建议 2（优化）**：v0.2 write 入口 `write_png_to_bytes` 的内存管理——write 端回调设计未列为决策点 | **采纳**：在第八节"下游设计输入"新增第 12 个决策点"write 端回调设计"，说明 `stbi_write_*_to_func` 回调写入机制、MoonBit 侧回调到 `Bytes` 累积的设计需求，及其与决策点 9 load 端 `IoCallbacks` 的对偶关系 | 第 293 行（第八节决策点 12） |

**未修订部分**：审查报告确认无问题的部分（6 个维度均通过的核心内容）均保留，未引入无关变更。既有约束（"完整库"定位、"只参考不引用已有库"、MoonBit v0.10.5 规范、版本迭代计划）全部保留。