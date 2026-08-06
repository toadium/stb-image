# 测试报告（v1）

## 概述

为 R1：Vendoring 层 + 项目骨架任务编写基于行为契约的单元测试。本任务无 MoonBit 源码（`.mbt`）、C 源码（`.c`）、FFI 声明，唯一可测公开接口为：

1. `scripts/prepare.py` 的 Python 模块函数（`sha256_bytes`、`download_to_cache`、`write_if_changed`、`vendor_single_header`、`main`）
2. 项目骨架配置文件（`moon.mod`、`src/moon.pkg`、`.gitignore`）的结构契约
3. 验收契约（`moon check` 通过、`prepare.py` 生成正确 SHA256 的头文件、幂等）

测试框架：pytest 9.0.3 / Python 3.13.6（环境已有，无新增依赖）。

## 文件变更清单

| 操作 | 文件路径 | 说明 |
|------|---------|------|
| 新建 | tests/test_prepare.py | prepare.py 行为契约测试（5 个被测函数 + 幂等端到端） |
| 新建 | tests/test_project_skeleton.py | moon.mod / src/moon.pkg / .gitignore 结构契约测试 |
| 新建 | tests/test_acceptance.py | 验收契约测试（moon check、prepare 生成、SHA256 匹配、幂等、pinned 常量） |

## 测试组织

- 测试目录：`tests/`（Python 项目标准约定，与源码分离）
- 每个被测模块对应一个测试文件
- 用例独立，不依赖执行顺序；使用 `tmp_path`、`monkeypatch`、`capsys` fixture 隔离环境
- 不修改编码 agent 的源码文件（`scripts/prepare.py`、`moon.mod`、`src/moon.pkg`、`.gitignore`），仅读取或通过 `monkeypatch` 动态替换

## 契约覆盖矩阵

### test_prepare.py（prepare.py 行为契约）

| 契约（detail_v1.md） | 测试类 | 用例数 | 覆盖维度 |
|---------------------|--------|-------|---------|
| `sha256_bytes` 返回小写十六进制摘要 | TestSha256Bytes | 5 | 正常路径 + 边界（空字节、长度）+ 确定性 |
| `write_if_changed` 幂等写入 | TestWriteIfChanged | 5 | 正常路径 + 边界（父目录）+ 幂等（时间戳不变） |
| `download_to_cache` 下载校验缓存 | TestDownloadToCache | 5 | 正常路径 + 缓存命中 + 错误（SHA256 不匹配 raise SystemExit、不写缓存）+ 边界（目录创建） |
| `vendor_single_header` 完整流程 | TestVendorSingleHeader | 3 | 正常路径（写入+日志）+ 幂等（unchanged）+ 错误（SHA256 不匹配传播） |
| `main` 参数分发 | TestMain | 3 | 正常路径（无参数）+ 错误（--include-write 未激活 raise SystemExit）+ 状态交互（v0.2 激活后双头文件） |
| 幂等契约（main 端到端） | TestMainIdempotent | 1 | 状态交互（连续两次 main 内容与时间戳不变） |

### test_project_skeleton.py（配置文件结构契约）

| 契约（detail_v1.md） | 测试类 | 用例数 | 覆盖维度 |
|---------------------|--------|-------|---------|
| `moon.mod` 行为契约 | TestMoonMod | 7 | preferred_target="native" + 不设 readme + 不设模块级 supported_targets + 必备字段存在 |
| `moon.pkg` 行为契约 | TestMoonPkg | 4 | supported_targets="native" + 不声明 options/native-stub/targets 子键 |
| `.gitignore` 行为契约 | TestGitignore | 3 | 忽略 .prepare/、target/、.mooncakes/ |

### test_acceptance.py（验收契约）

| 契约（detail_v1.md §验收契约） | 测试类 | 用例数 | 执行条件 |
|-------------------------------|--------|-------|---------|
| `moon check` 通过 | TestMoonCheck | 2 | moon 工具链可用时执行，否则 skip |
| `prepare.py` 生成正确头文件 | TestPrepareGeneratesHeader | 3 | 网络可达时执行，否则 skip |
| pinned 常量形态正确 | TestPinnedConstants | 9 | 始终执行（不依赖网络/工具链） |

**总用例数：52**（收集验证：`pytest --collect-only` 收集 52 个用例）

## 执行结果

- 离线可执行用例（test_prepare.py + test_project_skeleton.py + TestPinnedConstants）：**47 个全部通过**
- 依赖网络的用例（TestPrepareGeneratesHeader）：环境网络不可达 `raw.githubusercontent.com` 时 skip（与实现报告 code_v1.md 记录的网络限制一致）
- 依赖 moon 工具链的用例（TestMoonCheck）：moon 可用时执行；实现报告已记录 `moon check` 通过

## 设计契约对齐说明

1. **基于行为契约，非实现细节**：所有断言针对公开接口的输入-输出行为（SHA256 摘要值、文件内容、时间戳、退出码、日志文本），不测内部实现（如不测 `urllib.request.urlopen` 的调用次数细节、不测缓存文件的具体写入时机等实现选择）。

2. **覆盖维度完整**：
   - 正常路径：每个契约至少一个正向用例
   - 边界条件：空字节、缓存命中、内容相同、父目录缺失、空字符串 commit
   - 错误路径：SHA256 不匹配 raise SystemExit、--include-write 未激活 raise SystemExit、不自动回退（不写缓存）
   - 状态交互：幂等契约（重复运行无 tracked diff）、缓存复用、v0.2 激活后双头文件

3. **用例独立**：每个用例使用 `tmp_path` 隔离文件系统、`monkeypatch` 隔离模块常量与 `sys.argv`、`capsys` 隔离标准输出，不依赖执行顺序，不污染源码树。

4. **不修改源码文件**：仅通过 `monkeypatch.setattr` 动态替换 `prepare` 模块的 `STB_IMAGE_SHA256`、`CACHE_DIR`、`PACKAGE_DIR` 等常量，源文件保持原样。

5. **验收契约的网络依赖**：`TestPrepareGeneratesHeader` 与 `TestMoonCheck` 在环境缺失时 `pytest.skip` 而非失败，避免在离线 CI 环境产生假阳性。`TestPinnedConstants` 始终执行，验证 pinned 常量形态（commit 40 字符 hex、SHA256 64 字符 hex、URL 引用 pinned commit、v0.1 阶段 write 常量为空、路径常量指向正确目录）。

## 与实现报告（code_v1.md）偏差的对齐

- 实现报告偏差 4（`src/stb_image.h` 未生成，因网络不可达）：`TestPrepareGeneratesHeader` 在网络可达时验证生成与 SHA256 匹配；离线时 skip，不阻塞测试套件。
- 实现报告偏差 5（`_build/` 与 `pkg.generated.mbti` 未加入 .gitignore）：本测试严格按设计契约（detail_v1.md 第 25 行）只断言 `.prepare/`、`target/`、`.mooncakes/` 三项，不要求 `_build/`，与实现一致。