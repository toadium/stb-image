# 实现报告（v1）

## 概述

实现了 R1：Vendoring 层 + 项目骨架任务的全部文件：MoonBit 模块配置（`moon.mod` 新 DSL）、包配置（`src/moon.pkg` 新 DSL）、vendoring 脚本（`scripts/prepare.py`）、`.gitignore`。本任务无 MoonBit 源码（`.mbt`）、C 源码（`.c`）、FFI 声明。

## 文件变更清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | moon.mod | 模块配置（新 DSL）：name、version、license、description、keywords、preferred_target="native" |
| 新建 | src/moon.pkg | 包配置（新 DSL）：supported_targets = "native" |
| 新建 | scripts/prepare.py | vendoring 脚本：下载 pinned stb_image.h + SHA256 校验 + 幂等写入 + --include-write 骨架 |
| 新建 | .gitignore | 忽略 .prepare/、target/、.mooncakes/ |
| 未生成 | src/stb_image.h | 需运行 `python scripts/prepare.py` 生成（本次因网络不可达未生成） |

## 编译验证

- `moon check`：通过（Finished. moon: no work to do）
- `moon check --target native`：通过
- `moon info`：通过（ran 1 task）
- `python scripts/prepare.py`：**未成功执行**，环境网络不可达 raw.githubusercontent.com（PowerShell Invoke-WebRequest 与 python urllib 均超时 30-60s）。脚本语法已用 `python -c "import ast; ast.parse(...)"` 验证通过。`src/stb_image.h` 待网络可达后运行脚本生成。
- prepare.py 语法检查：通过（syntax ok）

## 设计偏差说明

1. **`moon.mod` 的 `name` 字段值**：设计规格（detail_v1.md 第 21 行）列出字段名但未给出具体值。tech_v2 §3.2 说 `name`：`<user>/stb-image`（user 待定）。本实现基于项目 LICENSE 的 Copyright "MoonBit-Toadium" 推断为 `MoonBit-Toadium/stb-image`。发布前可由维护者确认修改。

2. **`moon.mod` 的 `license` 字段值**：设计规格未给出具体值，tech_v2 §3.2 建议 "Public Domain 或 MIT"。本实现基于项目根目录 LICENSE 文件（MIT License）采用 `MIT`。

3. **`moon.mod` 的 `description`/`keywords` 字段值**：设计规格未给出具体值。本实现基于 README.md 内容推断：description = "MoonBit native FFI bindings for stb_image.h: decode PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC."，keywords = ["moonbit", "image", "ffi", "native", "stb", "png", "jpeg", "bmp", "gif", "webp"]。

4. **`src/stb_image.h` 未生成**：设计规格要求该文件由运行 `python3 scripts/prepare.py` 生成。因环境网络不可达 GitHub raw 内容，本次未生成。脚本已就绪，网络可达后运行 `python scripts/prepare.py` 即可生成，SHA256 校验将确保内容与设计契约一致。

5. **`_build/` 与 `src/pkg.generated.mbti` 构建产物**：`moon check`/`moon info` 会在项目根目录生成 `_build/` 缓存目录，在 `src/` 生成 `pkg.generated.mbti` 接口文件。设计规格的 `.gitignore` 契约（detail_v1.md 第 25 行）仅要求忽略 `.prepare/`、`target/`、`.mooncakes/`，未提及 `_build/` 与 `pkg.generated.mbti`。本实现严格按设计不追加这两项到 `.gitignore`。后续任务可在 `.gitignore` 追加 `_build/` 与 `*.generated.mbti`。本次已清理工作目录中的这些产物。