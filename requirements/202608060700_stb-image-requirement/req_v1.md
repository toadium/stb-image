# `stb-image`：MoonBit 原生 FFI 绑定 `stb_image.h` 的需求文档

本文档是对用户原始需求（`D:\CodeWorkspace\forMoonbit\stb-image\需求文档.md`）的澄清结果。澄清过程中已结合源码仓库 `D:\CodeWorkspace\moonbit_wp` 核实关键事实，并在合理推断处自然标注。下游架构设计与技术设计可据此推进，无需再回查原始表述。

## 一、项目背景与目标

### 目标用户
在 MoonBit 中处理图片资源的前端/游戏/工具开发者，以及希望用 MoonBit 快速读取 PNG/JPEG/BMP/GIF/WebP 等常见格式的个人开发者。

### 要解决的核心问题
MoonBit 生态当前缺少对广泛使用的 `stb_image.h` 的绑定。`stb_image` 是事实上的行业标准单头文件 C 库，API 稳定、支持格式多（含 HDR/PSD/PIC 等其他 MoonBit 库未覆盖的格式），读取路径足够通用。

经源码仓库核实，现状如下（已核实，非推断）：

- **mizchi/image 现状**：本地副本 `D:\CodeWorkspace\forMoonbit\stb-image\image-mbt` 的 `README.md` 与 `src/types.mbt` 确认其能力为：
  - PNG / BMP / JPEG：decode + encode
  - GIF：仅 encode（单帧、≤256 色、alpha 0/255）
  - WebP：仅 encode（无损 still image）
  - ICO：仅 encode；AVIF：仅 encode（仅 js 目标）
  - 所有 decode 结果归一化为 `ImageData { width : Int; height : Int; data : Bytes }`，**不保留原始通道数**（始终 RGBA8）
  - 因此 GIF/WebP 的 decode 路径在 MoonBit 生态中**确实空白**，需求文档的核验结论正确
- **mooncakes stb 绑定空白**：`mooncakes.io-index/user` 下 12 个用户目录（bobzhang、bzy-debug、fantix、Guest0x0、lijunchen、lucifer1004、peter-jerry-ye、test、tonyfettes、wangziling、Yoorkin、Yu-zh）无 stb 相关包；`.mooncakes` 缓存中亦无 stb/image/mizchi 相关包。**stb 绑定完全空白**结论已核实
- **awesome-moonbit 描述**：`mizchi/image` 描述为 "Image codec primitives for PNG, BMP, JPEG, GIF, WebP, ICO, and AVIF, plus resizing"，仅列举支持格式，未声称全部支持 decode，与上述核验不矛盾

### 项目定位
本项目为 MoonBit 原生 FFI 绑定项目，将 `stb_image.h` 的读取能力以 MoonBit 包形式暴露，**仅支持 native 目标**（不暴露 wasm/js 构建，见边界约束）。项目根目录为 `D:\CodeWorkspace\forMoonbit\stb-image`。

## 二、MVP 范围

### 加载入口（已澄清）
原始需求提到"从文件路径、`Bytes`、`InputStream` 加载图片"。经核实，**MoonBit 标准库中不存在 `InputStream` 类型**（`core` 中无此类型；`moonbitlang/async/io` 中有异步 `Reader` trait，但属于异步库且不适用于 MVP 的同步 native 场景）。结合原始需求后文"当前 MVP 限定本地/内存入口，网络流读取可后续扩展"，澄清如下：

- **MVP 暴露两个加载入口**：
  1. `load_from_path(path : String) -> Image raise LoadError`：从本地文件路径加载
  2. `load_from_bytes(data : Bytes) -> Image raise LoadError`：从内存字节序列加载
- **流式接口（`InputStream` 或类似）不在 MVP 范围内**，留作后续扩展。后续如需流式接口，可基于 `moonbitlang/async/io` 的 `Reader` trait 设计异步包装，或自定义同步流 trait，但这是后话

### 支持格式
与 `stb_image` 默认配置一致，支持以下 9 种格式的 decode：
- PNG、JPEG、BMP、GIF、WebP、TGA、PSD、HDR、PIC

（注：stb_image v2.x 默认包含 WebP decode；如 vendoring 的版本对 WebP 有特殊开关需求，应在 vendoring 脚本中显式处理。）

### 返回的 `Image` 值类型
原始需求说"返回图像信息：width、height、channels（灰度/RGB/RGBA）、data（`Bytes`）"。澄清如下：

- `Image` 为值类型（struct），包含四个字段：
  - `width : Int`
  - `height : Int`
  - `channels : Int`：**原始通道数**（1=灰度、3=RGB、4=RGBA），由 stb_image 的 `channels` 输出参数提供，**不做归一化**
  - `data : Bytes`：像素数据，长度为 `width * height * channels`
- **与 mizchi/image 的差异**：mizchi/image 始终归一化为 RGBA8（无 channels 字段）；本项目保留原始通道，让调用者决定是否转换。这是 stb_image 的自然语义，也填补了 mizchi/image 未覆盖的能力
- **是否允许调用者指定 `req_channels` 强制转换**（如 stb_image 的 STBI_rgb_alpha）：MVP **不暴露** `req_channels` 参数，始终返回原始通道。如调用者需要 RGBA 归一化，可在 MoonBit 侧自行转换。此为基于"MVP 保持最小 API 面"的推断，标注供下游审议

### 错误处理（已澄清）
原始需求说"以 MoonBit `Error` 返回'不支持的格式'或'解码失败'，不暴露 C 错误码"。"返回"一词有歧义（`raise` 还是 `Result`），澄清如下：

- **采用 `raise` 抛出错误**（符合 MoonBit 惯例，与 mizchi/image 的 `raise DecodeError` 一致）
- 定义 `suberror LoadError`，至少包含以下构造子（最终命名与层级由技术设计决定）：
  - `UnsupportedFormat(String)`：stb_image 无法识别的格式
  - `DecodeFailed(String)`：解码过程中的损坏数据、不完整文件等
  - 文件路径入口还需处理 `IOError`/文件不存在等情况（可复用标准库错误或并入 LoadError，由技术设计决定）
- **不暴露 C 错误码**：stb_image 本身不返回错误码（仅返回 NULL 指针表示失败），C wrapper 负责将失败转换为 MoonBit 错误

### vendoring
- 将 `stb_image.h` 的稳定版本放入 `native-stub` 目录
- 提供可重复运行的下载脚本（建议 `scripts/prepare.py`，参考 make-moonbit-c-bindings 技能的 `templates/prepare.py`）
- 脚本要求：
  - **固定版本标识**：stb_image.h 无正式版本号，建议固定为上游 `nothings/stb` 仓库的特定 git commit hash（或日期标识），并在脚本中硬编码
  - **校验哈希**：下载后用 SHA256 校验，哈希值硬编码于脚本
  - **失败时报错退出**：下载失败或哈希不匹配时非零退出，**不自动回退**到其他版本
  - **幂等**：重复运行脚本应无 tracked diff

## 三、FFI 实现要点

依据 `moonbit-c-binding` 与 `make-moonbit-c-bindings` 技能（项目 `.codeartsdoer/skills` 下已配置），FFI 方案要点如下（保留用户原意，补充澄清）：

- **包布局**（建议，由技术设计最终确定；依据 MoonBit v0.10.5 规范，使用新格式 `moon.mod`/`moon.pkg`，旧 `moon.mod.json`/`moon.pkg.json` 已在 v0.10.4 弃用）：
  ```
  scripts/prepare.py          # vendoring 脚本
  moon.mod                    # preferred_target = "native"（新格式，非 moon.mod.json）
  src/moon.pkg                # native-stub + targets 门控（新格式，非 moon.pkg.json）
  src/wrapper.c               # ABI 归一化 C wrapper
  src/ffi.mbt                 # 私有 extern "c" 声明（native 门控）
  src/stb_image.h             # vendored 上游头文件
  src/image.mbt               # 安全公开 MoonBit API
  src/image_test.mbt          # 回归测试
  src/README.mbt.md           # 测试过的文档示例
  ```
- **`moon.mod` 配置**（新 DSL 语法）：`preferred_target = "native"`（下划线，非旧 JSON 的 `"preferred-target"`）；可设 `supported_targets = "native"` 声明仅 native
- **`moon.pkg` 配置**（新 DSL 语法）：`options("native-stub": ["wrapper.c"], targets: { "ffi.mbt": ["native"] })`；`stb_image.h` 放入 `native-stub` 同目录
- **`ffi.mbt` 门控**：在 `moon.pkg` 的 `options(targets: { "ffi.mbt": ["native"] })` 中声明，仅 native 后端编译
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

## 五、边界约束

- **不做 `stb_image_write` 绑定**：MVP 仅读取，不提供 encode 能力（与 mizchi/image 的 encode 能力互补，不重复造轮子）
- **不做动态格式扩展钩子**：MVP 只暴露 stb_image 默认配置支持的格式，不提供运行时注册新格式的机制
- **不追求零拷贝**：MVP 允许解码后从 C 分配的缓冲拷贝到 MoonBit `Bytes`（由 GC 接管），C 侧随后释放原始缓冲
- **仅支持 native 目标**：不暴露 wasm/js/wasm-gc 构建。`moon.mod` 设置 `preferred_target = "native"`（新格式，下划线；旧 `"preferred-target"` 已弃用），`ffi.mbt` 通过 `moon.pkg` 的 `targets` 门控到 native，可设 `supported_targets = "native"` 声明包级支持范围
- **不暴露 `req_channels` 参数**：始终返回原始通道数（见 MVP 范围说明）
- **不暴露流式接口**：MVP 不提供 `InputStream` 或类似流式读取（见 MVP 范围说明）

## 六、澄清与推断汇总

以下为澄清过程中对用户原始表述的推断与补充，供下游审议：

| 原始表述 | 澄清结果 | 依据 |
|---------|---------|------|
| "从文件路径、`Bytes`、`InputStream` 加载" | MVP 仅暴露 `load_from_path` + `load_from_bytes`，移除 `InputStream` | MoonBit 标准库无 `InputStream` 类型；原始需求已限定"本地/内存入口" |
| "以 MoonBit `Error` 返回" | 采用 `raise LoadError` 抛出错误 | MoonBit 惯例（mizchi/image 同此）；"返回"一词歧义，选更惯用方式 |
| "channels（灰度/RGB/RGBA）" | 保留原始通道数，不归一化 | stb_image 自然语义；与 mizchi/image 归一化做法互补 |
| "6-10 张测试图片（PNG/JPEG/BMP/GIF/WebP）" | 聚焦 5 种常见格式，每种正常+损坏各 1 张 | 数量与格式数匹配；TGA/PSD/HDR/PIC 可选 |
| "包含 `SKILL.md` 与 minimal example" | `SKILL.md` 为包使用说明文档，minimal example 为 README 示例 | 基于 make-moonbit-c-bindings 技能的 `README.mbt.md` 惯例推断 |
| stb_image.h 版本标识 | 用 git commit hash 固定 | stb_image.h 无正式版本号，此为业界惯例 |
| 是否暴露 `req_channels` | MVP 不暴露 | 基于"MVP 保持最小 API 面"推断，标注供审议 |

## 七、下游设计输入

本需求文档已澄清至可支撑下游架构设计与技术设计的程度。下游设计需重点关注以下决策点（本需求文档不预设答案）：

1. **`LoadError` 的具体构造子与层级**：是否复用标准库 `IOError`，还是全部并入 `LoadError`
2. **C wrapper 的错误信号机制**：通过返回 NULL、输出参数、还是其他方式让 MoonBit 侧感知失败
3. **`Image` struct 的导出级别**：`pub(all)` 还是 `pub`，是否 derive `Eq`/`Show`/`@debug.Debug`
4. **测试图片的取得方式**：脚本生成、公开库下载、还是手工制作并 vendoring
5. **vendoring 的 stb_image.h 具体版本**：选择哪个 commit hash（建议选近期稳定 commit）
6. **`SKILL.md` 的具体内容结构**：是否参照 `.codeartsdoer/skills` 下的 SKILL.md 格式