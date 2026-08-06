# 实现计划

任务描述：将 stb_image.h 以 MoonBit 原生 FFI 绑定形式暴露为 MoonBit 包，MVP 聚焦 8-bit load 路径（native 目标），提供 load_from_path/load_from_bytes 两个入口 + Image + LoadError，覆盖 9 种格式解码。
项目根目录：D:\CodeWorkspace\forMoonbit\stb-image

---

## R1 NEW Vendoring 层 + 项目骨架

任务：创建项目配置（moon.mod 新 DSL、src/moon.pkg 新 DSL）+ vendoring 脚本（scripts/prepare.py）+ 运行脚本下载 pinned stb_image.h 到 src/stb_image.h + .gitignore。预期文件路径：
- `moon.mod`（模块配置，preferred_target = "native"，不设 readme 行）
- `src/moon.pkg`（包配置，supported_targets = "native"，渐进式声明——本任务仅声明 supported_targets，options 块待后续任务追加）
- `scripts/prepare.py`（vendoring 脚本：下载 pinned stb_image.h + SHA256 校验 + 幂等 + 预留 --include-write）
- `src/stb_image.h`（vendored 上游头文件，由脚本生成）
- `.gitignore`（忽略 .prepare/ 缓存目录）

选择理由：Vendoring 层是四层架构的最底层依赖，FFI 边界层（wrapper.c/ffi.mbt）与所有上层都依赖 vendored 的 stb_image.h 与项目配置。没有项目骨架（moon.mod/moon.pkg）与 vendored 头文件，后续任何 MoonBit 代码都无法编译。底层优先，一次一个任务。

上下文：项目根目录当前为空（仅有 image-mbt 参考实现与文档目录，无任何 MoonBit 项目文件），需从零搭建。技术方案 §3.1 文件布局、§3.2 moon.mod 配置、§3.3 moon.pkg 配置、§4 Vendoring 方案已给出完整决策。stb_image.h 是单头文件库（header-only），vendoring 策略与一般多文件 C 库不同：只需下载单个 .h 文件，wrapper.c 中 #define STB_IMAGE_IMPLEMENTATION + #include 生成实现，stb_image.h 不列入 native-stub（通过 wrapper.c 的 #include 纯入）。

---

## 后续任务路线图

R1 完成后，按"底层优先、依赖单向向下"原则推进：

- **R2 FFI 边界层**：创建 `src/wrapper.c`（ABI 归一化、`moonbit_make_bytes` 拷贝、`stbi_image_free` 释放、NULL→失败信号）+ `src/ffi.mbt`（私有 `extern "c"` 声明，native 门控）；同步向 `moon.pkg` 的单一 `options(...)` 块追加 `"native-stub": ["wrapper.c"]` 与 `targets: { "ffi.mbt": ["native"] }`（两者合并到同一 `options` 块，非两个独立块）
- **R3 安全 API 层**：创建 `src/image_types.mbt`（`Image` struct + `LoadError` suberror 类型定义，不门控，全后端可用）+ `src/image_load_native.mbt`（`load_from_path`/`load_from_bytes` 公开 API 实现 + 错误映射，native 门控）；同步向 `moon.pkg` 的 `options` 块 `targets` 追加 `"image_load_native.mbt": ["native"]` 条目（`image_types.mbt` 不门控）
- **R4 测试与文档层**：创建 `src/image_test.mbt`（回归测试，happy + error path）+ `testdata/`（vendored 测试图片）+ `src/README.mbt.md`（测试过的文档示例）+ `SKILL.md` + `scripts/run-asan.py`（从 `moonbit-c-binding` skill 复制 ASan 验证脚本）；同步向 `moon.pkg` 的 `options` 块 `targets` 追加对应条目，向 `moon.mod` 追加 `readme = "README.mbt.md"` 行；运行 ASan 验证

各轮任务粒度与具体拆分由计划 agent 在对应轮次决定，本路线图仅给出方向与依赖顺序。
