# stb-image 迭代计划

> 制定日期：2026-08-08 | 当前版本基线：v1.17.0 | 审查报告：`deliberations/202608081101_project-review/output_v1.md`
>
> 本计划基于 2026-08-08 项目审查报告的 P0-P8 迭代方向建议与 Top 5 推荐行动顺序制定，旨在将审查结论转化为按版本号组织的可执行、可审阅、可追踪的迭代计划。

## 计划概述

### 制定背景

本计划是对现有 `ROADMAP.md` 的重构与补充。现有 ROADMAP 对 v1.0-v1.17 已完成工作记录详实，但对 v2.0+ 的规划过于粗略（v2.0 仅给出双后端 vs 全纯两个方向无工作量估算，v2.1 将 WebP/stream/TIFF/APNG 混在一起无优先级排序），且遗漏了文档同步、CI/CD 增强、测试数据扩充、API 人体工程学、性能优化等审查报告指出的重要方向。

2026-08-08 的项目审查识别出 5 类不足（A 文档与实现严重不一致 / B 错误处理设计缺陷 / C 代码质量问题 / D 测试与基准不足 / E CI/CD 缺失），并提出 P0-P8 共 9 个迭代方向，按优先级排序给出 Top 5 推荐行动。本计划将该结论转化为 6 个版本（v1.18 - v2.1）的具体规划。

### 总目标

在保持 v1.0 API 冻结原则（只增不改）和五子包架构（core/process/format/meta/util）约束的前提下，按"先治标后治本、先低风险后高风险"的顺序，逐步消除审查报告指出的 5 类不足，并在中期补齐 EXIF 写入等差异化功能，长期推进 wasm 目标支持和性能优化。

### 阶段性愿景

| 时间尺度 | 版本范围 | 愿景 |
|---------|---------|------|
| 短期（下 1-2 版本） | v1.18 - v1.19 | 消除文档可信度风险，建立 CI/CD 安全网和真实测试基线，为后续重构提供准确基线 |
| 中期（3-5 版本） | v1.20 - v1.21 | 修正错误处理设计缺陷，消除代码重复，补齐 EXIF 写入等差异化功能 |
| 长期（v2.0+） | v2.0 - v2.1 | 突破 native-only 架构限制，探索性能优化和 API 人体工程学改进 |

### 工作量评估口径

| 等级 | 人日范围 |
|------|---------|
| S | ≤ 2 人日 |
| M | 3-5 人日 |
| L | 6-10 人日 |
| XL | > 10 人日 |

**口径说明**：S/M/L/XL 标记的是**单项工作量的等级上限**，而非精确人日。功能项拆分粒度远细于审查报告的 P 级估算（一个 P 拆为多个功能项），每个功能项的实际工作量通常远小于其等级上限（如一个 S 级"修正单个文档字段"项实际可能只需 0.3-0.5 人日）。因此**功能项逐项加总不等于 P 级估算**：加总按等级上限会偏高，按实际工作量则与 P 级估算接近。合并原则的论证以 P 级估算（粗粒度）为决策依据，功能项加总（细粒度）用于可执行性和可追踪性，两者用途不同。

---

## v1.18 — 文档同步与治理

**版本目标**：消除所有文档与实现的不一致，恢复项目对外可信度，为后续版本提供准确基线。

**对应审查方向**：P0 文档同步与治理

**工作量说明**：P0 原估算 2-3 人日（M）。功能项拆分为 7 个 S 项，按等级上限加总 7-14 人日偏高，但各 S 项为单文档字段修正（实际 0.3-0.5 人日/项），实际总工作量与 P0 原估算接近（见"工作量评估口径"口径说明）。

**功能项**：

| # | 功能名称 | 实现方式 | 涉及子包 | 工作量 | 优先级 | 风险点 |
|---|---------|---------|---------|--------|--------|--------|
| 1 | 重写 `src/README.mbt.md`（mooncakes.io 展示页）补全 v1.1-v1.17 全部功能、Version History、类型列表至 29 个 | 文档 | 无（根包文档） | S | 高 | 低：纯文档，需确保与 `.mbti` 一致 |
| 2 | 重写 `COMPARISON.md` 功能矩阵，重新拉取 5 个竞品库当前版本数据，stb-image 列全标 ✅，更新定位差异节 | 文档 | 无（顶层文档） | S | 高 | 低：需核实竞品库最新状态 |
| 3 | 更新 `SKILL.md` frontmatter（533 tests + 29 benchmarks）和 API 概览至 199 函数/29 类型 | 文档 | 无（顶层文档） | S | 高 | 低 |
| 4 | 修正 `ARCHITECTURE.md`：补充 process/ 的 7 个子子包结构（color/edge/feature/filter/frequency/segment/transform）及内部依赖（filter→transform、segment→color、util→transform） | 文档 | process | S | 高 | 低：需核实实际依赖关系 |
| 5 | 修正 `API.md` 中 `SegmentRegion` 字段为实际代码字段（label/area/mean_r/mean_g/mean_b/bbox_x/bbox_y/bbox_w/bbox_h） | 文档 | process | S | 高 | 低 |
| 6 | 统一 `README.md` badge 数字为 533 tests + 29 benchmarks（消除 546/75 与 533/29 的矛盾） | 文档 | 无（顶层文档） | S | 高 | 低 |
| 7 | 评估文档自动生成：从 `.mbti` 提取 API 签名生成 API.md 的可行性 | 工具脚本 | 无 | S | 中 | 低：仅评估，不强制落地 |

**测试与验证要求**：
- 无新增测试（纯文档工作）
- 运行 `moon info` 确认 `pkg.generated.mbti` 与代码同步
- 人工核验所有更新文档与 v1.17.0 实际状态一致

**交付物清单**：
- 修改：`src/README.mbt.md`、`COMPARISON.md`、`SKILL.md`、`ARCHITECTURE.md`、`API.md`、`README.md`
- 新增（可选）：`scripts/gen_api_doc.py`（若评估通过）
- 公开函数数变化：0（不涉及代码）
- 类型数变化：0

**依赖关系**：无前置依赖，可立即开始。为 v1.19+ 提供准确文档基线。

---

## v1.19 — CI/CD 增强 + 测试数据扩充

**版本目标**：建立 CI/CD 安全网（ASan 自动验证 + 多平台覆盖 + 发布流程），扩充测试数据至真实尺寸，使测试和基准能真实反映正确性与性能。

**对应审查方向**：P1 CI/CD 增强 + P2 测试数据扩充与测试增强

**合并理由**：P1 与 P2 同属短期低风险方向，CI 与测试相互支撑（CI 需要测试 job，测试需要 CI 运行）。以 P 级粗粒度估算，P1（3-5 人日）+ P2（3-5 人日）= 6-10 人日落在 L 范围内，符合合并原则。功能项细粒度拆分后 9 项（8S+M）按等级上限加总偏高，但各 S 项实际工作量远小于 2 人日上限（见"工作量评估口径"口径说明），实际总工作量与 P 级估算接近。

**功能项**：

| # | 功能名称 | 实现方式 | 涉及子包 | 工作量 | 优先级 | 风险点 |
|---|---------|---------|---------|--------|--------|--------|
| 1 | CI 添加 ASan job：`python scripts/run-asan.py src/core` 接入 `.github/workflows/ci.yml` | CI 配置 | core | S | 高 | 低：`run-asan.py` 已存在，仅需接入 |
| 2 | CI 添加多平台矩阵：ubuntu-22.04 + macos-14 + windows-latest，验证 `wrapper.c` 平台分支 | CI 配置 | core | S | 高 | 低：可能发现平台特定问题需修复 |
| 3 | 新建 `.github/workflows/release.yml`：tag push 触发 `moon publish` | CI 配置 | 无 | S | 中 | 低 |
| 4 | CI 添加 `moon info` 校验步骤，防止 `.mbti` 失同步 | CI 配置 | 无 | S | 中 | 低 |
| 5 | 扩展 `scripts/gen_testdata.py` 生成 64×64/256×256/512×512 多色彩多格式测试图（PNG/JPEG/BMP/GIF） | 工具脚本 | 无 | M | 高 | 低：仅增加测试数据 |
| 6 | resize 测试增加像素值断言：对已知输入和滤波器断言输出像素值（非仅尺寸） | 测试 | core | S | 高 | 低：需计算已知正确结果 |
| 7 | 添加解码器 fuzz 测试：随机字节流 → `try load_from_bytes` → 不 crash，循环 1000 次 | 测试 | core | S | 高 | 低 |
| 8 | 基准测试改用 256×256 图像，使耗时在毫秒级有区分度 | 测试 | 无（根包 bench） | S | 中 | 低：需更新 bench 数据 |
| 9 | 添加跨格式 pipeline 测试：load → process → write → load → 验证 | 测试 | 无（根包 roundtrip） | S | 中 | 低 |

**测试与验证要求**：
- 新增测试数：约 15-25（fuzz + resize 像素断言 + pipeline）
- ASan 验证范围：core/ 全子包（通过 CI 自动运行）
- 基准测试：改用 256×256 图像，更新 29 个 bench 的基线数据
- 多平台验证：CI 矩阵在 ubuntu/macos/windows 上均通过

**交付物清单**：
- 修改：`.github/workflows/ci.yml`、`scripts/gen_testdata.py`、`src/core/image_resize_test.mbt`、`src/bench.mbt`、`src/roundtrip_test.mbt`
- 新增：`.github/workflows/release.yml`、`src/core/fuzz_test.mbt`、`testdata/test_64x64_multi.png` 等多尺寸测试图
- 公开函数数变化：0
- 类型数变化：0

**依赖关系**：建议在 v1.18 完成后开始（文档基线准确后，CI badge 数字才有意义）。P1 和 P2 无相互阻塞，可并行开发。

---

## v1.20 — 错误处理修正 + 代码质量重构

**版本目标**：修正 `LoadError` 三变体各司其职（消除 `UnsupportedFormat` 死代码、`FileIO` 分类不准、`info_from_path` 签名不一致），消除 GIF 解码重复代码和低效帧复制。

**对应审查方向**：P3 错误处理修正 + P4 代码质量重构

**合并理由**：P3 错误处理修正为 P4 代码重构提供安全网（错误分类正确后重构更有信心），两者同属中期方向。以 P 级粗粒度估算，P3（2-3 人日）+ P4（3-5 人日）= 5-8 人日，上限不超过 L（≤10 人日），符合合并原则。功能项细粒度拆分后 7 项（7S）按等级上限加总偏高，但各 S 项实际工作量远小于 2 人日上限（见"工作量评估口径"口径说明），实际总工作量与 P 级估算接近。

**功能项**：

| # | 功能名称 | 实现方式 | 涉及子包 | 工作量 | 优先级 | 风险点 |
|---|---------|---------|---------|--------|--------|--------|
| 1 | `load_from_path` 系列在 FFI 调用前检查文件存在性，不存在则 raise `FileIO`（而非 `DecodeFailed`） | 纯 MoonBit | core | S | 高 | 中：需 `@fs` 或 stat，可能影响现有错误处理测试 |
| 2 | `decode_any` 先调 `detect_format`，若 `Unknown` 则 raise `UnsupportedFormat`（激活死代码变体） | 纯 MoonBit | core | S | 高 | 中：改变 `decode_any` 对未知格式的错误类型 |
| 3 | `info_from_path` 添加 `raise LoadError` 声明，文件不存在时 raise（与 `info_from_bytes` 签名一致） | 纯 MoonBit | core | S | 高 | 中：API 契约变更（增加 raise 声明），属修正使与 `info_from_bytes` 一致，归入错误处理修正范畴，需在 CHANGELOG 标注，调用方需更新错误处理 |
| 4 | 评估 `failure_reason` 是否可改为在 `LoadError` 变体中携带 stb 错误字符串（消除全局状态依赖） | 架构改动 | core | S | 中 | 中：可能涉及 API 变更，需评估向后兼容 |
| 5 | 提取 GIF 帧解析公共函数 `parse_gif_result(combined, w, h, c, z, delays_size) -> GifAnimation`，`load_gif_from_bytes` 和 `load_gif_from_path` 共用 | 纯 MoonBit | core | S | 高 | 低：纯重构，有测试保护 |
| 6 | GIF 帧复制改用 `Bytes::blit` 或切片操作替代逐字节循环（O(n) 常数差 5-10x） | 纯 MoonBit | core | S | 中 | 低：需调研 MoonBit `Bytes` API |
| 7 | 评估 load 系列是否可提取 `load_common` 高阶函数（受 MoonBit 泛型限制可能阻碍） | 架构改动 | core | S | 低 | 低：仅评估，不强制落地 |

**测试与验证要求**：
- 新增测试数：约 5-10（文件不存在场景、UnsupportedFormat 场景、info_from_path 错误场景）
- ASan 验证范围：core/ 全子包
- 基准测试：GIF 帧复制优化后验证性能提升
- 回归测试：所有现有 533 测试通过（错误类型变更可能影响部分测试，需更新）

**交付物清单**：
- 修改：`src/core/image_load_native.mbt`、`src/core/image_detect.mbt`、`src/core/image_info_native.mbt`、`src/core/image_gif_native.mbt`、`src/core/image_types.mbt`（若 failure_reason 改造）
- 修改：`CHANGELOG.md`（标注"错误分类改进，可能影响 LoadError 模式匹配"）
- 公开函数数变化：0（只改实现和错误契约，不改函数签名；`info_from_path` 增加 raise 声明属 API 契约修正使与 `info_from_bytes` 一致，需在 CHANGELOG 标注）
- 类型数变化：0

**依赖关系**：建议在 v1.19 完成后开始（CI/CD 安全网和扩充的测试数据为重构提供保护）。

---

## v1.21 — EXIF 写入与元数据扩展

**版本目标**：补齐 EXIF 写入能力（最常见用例：旋转后更新 orientation），评估 ICC profile 读取作为色彩管理基础。

**对应审查方向**：P5 EXIF 写入与元数据扩展

**功能项**：

| # | 功能名称 | 实现方式 | 涉及子包 | 工作量 | 优先级 | 风险点 |
|---|---------|---------|---------|--------|--------|--------|
| 1 | 实现 `write_exif_to_bytes(data, exif_info) -> Bytes`：解析 JPEG segment 结构，修改 APP1 segment 写入 EXIF | 纯 MoonBit | meta | M | 高 | 中：JPEG segment 操作需谨慎，错误可能损坏文件 |
| 2 | 实现 `write_exif_orientation(data, orientation) -> Bytes`：最常见用例的便捷函数（旋转后更新 orientation） | 纯 MoonBit | meta | S | 高 | 中 |
| 3 | 实现 `read_icc_profile_from_bytes(data) -> Bytes?`：读取 JPEG/PNG 中的 ICC profile（色彩管理基础） | 纯 MoonBit | meta | M | 中 | 中：需解析 JPEG APP2 / PNG iCCP chunk |
| 4 | 更新 `API.md`、`SKILL.md`、`src/README.mbt.md` 同步新增函数 | 文档 | 无 | S | 高 | 低 |

**测试与验证要求**：
- 新增测试数：约 8-12（EXIF 写入 roundtrip、orientation 写入、ICC profile 读取、错误处理）
- ASan 验证范围：无（纯 MoonBit，无 FFI）
- 基准测试：EXIF 写入性能基准（可选）
- roundtrip 测试：write_exif → read_exif → 验证字段一致

**交付物清单**：
- 新增：`src/meta/exif_write.mbt`（EXIF 写入逻辑）、`src/meta/icc_profile.mbt`（ICC profile 读取逻辑，独立于 EXIF）
- 修改：`src/meta/exif.mbt`（可能共享 JPEG segment 解析逻辑）、`src/reexport.mbt`（重新生成）、`API.md`、`SKILL.md`、`src/README.mbt.md`
- 公开函数数变化：+2~3（write_exif_to_bytes、write_exif_orientation、read_icc_profile_from_bytes）
- 类型数变化：0

**依赖关系**：建议在 v1.20 完成后开始（错误处理修正后，EXIF 写入的错误处理更健壮）。`src/meta/exif.mbt` 已有 EXIF 解析基础，写入为逆向操作。

---

## v2.0 — wasm 目标渐进支持

**版本目标**：突破 native-only 架构限制，通过渐进路径（先支持 wasm 的纯 MoonBit 子集 fallback）而非二元选择（双后端 vs 全纯）实现多目标支持。

**对应审查方向**：P6 wasm 目标渐进支持

**工作量说明**：P6 原估算 10-15 人日（XL）。功能项拆分后含 3 个 L 项（条件编译架构设计、纯 MoonBit PNG/JPEG 解码）和 2 个 M 项，按等级上限加总约 26-44 人日偏高，但 L 项的复杂度子集（baseline 子集渐进实现）实际工作量接近 P6 原估算，且可分阶段交付（见"工作量评估口径"口径说明）。

**功能项**：

| # | 功能名称 | 实现方式 | 涉及子包 | 工作量 | 优先级 | 风险点 |
|---|---------|---------|---------|--------|--------|--------|
| 1 | 评估 MoonBit wasm 目标成熟度和 stb 功能子集边界（哪些 core 功能有纯 MoonBit 替代） | 调研 | core | M | 高 | 高：MoonBit wasm 目标可能不成熟 |
| 2 | 设计 `src/core/native/` + `src/core/wasm/` 条件编译结构，保持五子包架构 | 架构改动 | core | L | 高 | 高：架构级变更，需保持向后兼容 |
| 3 | 实现纯 MoonBit PNG 解码作为 wasm fallback（参考 mizchi 方案） | 纯 MoonBit | core（wasm 子包） | L | 高 | 高：PNG 解码复杂度（zlib + filter + interlace） |
| 4 | 实现纯 MoonBit JPEG baseline 解码作为 wasm fallback | 纯 MoonBit | core（wasm 子包） | L | 中 | 高：JPEG 解码复杂度（Huffman + DCT + YCbCr） |
| 5 | 实现纯 MoonBit resize（已有 stb_image_resize2 算法参考） | 纯 MoonBit | core（wasm 子包） | M | 中 | 中 |
| 6 | 更新 `moon.mod` 的 `supported_targets`，添加 wasm 目标 | 配置 | 无 | S | 高 | 中：需验证所有子包兼容 |
| 7 | 更新 `ARCHITECTURE.md`、`ROADMAP.md`、`COMPARISON.md` 反映多目标支持 | 文档 | 无 | S | 中 | 低 |

**测试与验证要求**：
- 新增测试数：约 20-40（wasm fallback 解码正确性、native 与 wasm 结果一致性）
- ASan 验证范围：native 后端（wasm 后端为纯 MoonBit，无需 ASan）
- 基准测试：native vs wasm 性能对比
- 跨格式 roundtrip：wasm 后端全格式验证

**交付物清单**：
- 新增：`src/core/native/`（现有 C FFI 迁移）、`src/core/wasm/`（纯 MoonBit fallback）
- 修改：`src/core/moon.pkg`（条件编译配置）、`src/lib.mbt`（后端选择层）、`moon.mod`、`ARCHITECTURE.md`（多目标架构说明）、`ROADMAP.md`（版本规划同步）、`COMPARISON.md`（多目标能力对比）
- 公开函数数变化：0（API 不变，仅后端切换）
- 类型数变化：0

**依赖关系**：必须在 v1.21 完成后开始（所有 v1.x 修正和功能扩展完成后再做架构级变更）。这是架构级变更，需独立版本。

---

## v2.1 — 性能优化探索 + API 人体工程学改进

**版本目标**：在 v2.0 架构稳定后，探索性能优化（SIMD/并行化/零拷贝）和 API 人体工程学改进（方法式 API、builder 模式、消除全局状态），通过新增而非修改保持向后兼容。

**对应审查方向**：P7 性能优化探索 + P8 API 人体工程学改进

**合并理由**：P7 和 P8 同属长期优化方向，v2.0 架构稳定后无更高优先级待办，作为探索性版本可合并。以 P 级粗粒度估算，P7（10-15 人日）+ P8（5-7 人日）= 15-22 人日超 L，但同属长期优化且 v2.0 后无更高优先级待办，作为探索性版本可接受（可分阶段交付）。功能项细粒度拆分后按等级上限加总更高，但各功能项实际工作量远小于等级上限（见"工作量评估口径"口径说明）。

**功能项**：

| # | 功能名称 | 实现方式 | 涉及子包 | 工作量 | 优先级 | 风险点 |
|---|---------|---------|---------|--------|--------|--------|
| 1 | 基准测试改用大图（4K+）后识别热点（预计为 gaussian_blur、bilateral_filter、nlm_denoise、fft_2d） | 调研 + 测试 | 无（根包 bench） | M | 高 | 低 |
| 2 | 评估 MoonBit 并行原语可用性，对热点算法尝试并行化 | 纯 MoonBit | process | L | 中 | 中：并行化可能引入平台依赖 |
| 3 | FFT 改用迭代式替代递归式减少分配 | 纯 MoonBit | process（frequency） | M | 中 | 低 |
| 4 | 评估零拷贝可行性（MoonBit FFI 是否支持 `Bytes` 视图零拷贝） | 调研 | core | M | 低 | 高：可能需要语言层面支持 |
| 5 | 新增方法式 API：`Image.load(path)` / `Image.from_bytes(data)`（不删除现有函数） | 纯 MoonBit | core | M | 高 | 高：需确保不破坏 v1.0 API 冻结 |
| 6 | 评估 builder 模式：`ImageBuilder::new().with_channels(4).with_flip(true).load(path)` | 纯 MoonBit | core | M | 中 | 高：需评估 MoonBit 方法链语法支持度 |
| 7 | 配置函数改为 `LoadConfig` struct 传参（消除 `set_flip_vertically_on_load` 等全局状态） | 纯 MoonBit | core | M | 中 | 高：API 变更，需通过新增而非修改 |
| 8 | `failure_reason` 改造：在 `LoadError` 变体中携带 stb 错误字符串，消除全局状态依赖（对应 v1.20 功能项 4 评估结论的落地，决策点 2 建议推迟至此版本） | 架构改动 | core | M | 中 | 高：LoadError 变体变更，需通过新增字段而非修改现有变体保持兼容 |
| 9 | 链式 API：`img.brightness(10).contrast(1.2).blur(3)`（评估 MoonBit 方法链语法支持度） | 纯 MoonBit | process | M | 低 | 高：需评估语言支持 |
| 10 | 更新 `API.md`、`SKILL.md`、`src/README.mbt.md` 同步新增 API | 文档 | 无 | S | 高 | 低 |

**测试与验证要求**：
- 新增测试数：约 15-30（新 API 正确性、性能对比、并行化正确性、LoadError 携带错误字符串验证）
- ASan 验证范围：core/ 全子包
- 基准测试：优化前后的性能对比基准（大图 4K+）
- 回归测试：所有现有测试通过（新 API 为新增，不影响现有 API）

**交付物清单**：
- 修改：`src/core/image_config.mbt`（新增 LoadConfig）、`src/core/image_types.mbt`（LoadError 变体携带错误字符串）、`src/process/frequency/fft.mbt`（迭代式优化）、`src/bench.mbt`（基准测试改用大图 4K+ 并添加优化前后对比基准，对应功能项 1 和测试要求）
- 新增：`src/core/image_builder.mbt`（builder 模式）、`src/core/image_methods.mbt`（方法式 API）、`src/process/image_chain.mbt`（链式 API 方法，定义在 process 子包以避免 core→process 循环依赖）
- 修改（条件性，功能项 2 若落地）：`src/process/filter/bilateral_filter.mbt`、`src/process/filter/filter.mbt`（gaussian_blur）、`src/process/segment/nlm_denoise.mbt`（热点算法并行化预判，实际文件视功能项 1 热点识别结果而定）
- 修改：`src/reexport.mbt`（重新生成）、`API.md`、`SKILL.md`、`src/README.mbt.md`
- 公开函数数变化：+5~10（新方法式 API、builder、LoadConfig、链式 API 相关）
- 类型数变化：+1~2（LoadConfig、ImageBuilder）

**依赖关系**：必须在 v2.0 完成后开始（架构稳定后才能做性能优化和 API 改进）。作为探索性版本，可根据实际进展分阶段交付（如先交付 P8 API 改进，再交付 P7 性能优化）。

---

## 优先级排序说明

### 排序动机

本计划的优先级排序遵循"先治标后治本、先低风险后高风险、先基线后扩展"的原则，具体权衡如下：

| 排序决策 | 价值 | 风险 | 成本 | 权衡说明 |
|---------|------|------|------|---------|
| v1.18 文档同步（P0）排第一 | 极高：消除最大项目风险（文档与实现差 16 个版本，误导用户） | 极低：纯文档 | 低（M） | 价值/风险比最高，且为后续版本提供准确基线 |
| v1.19 CI/CD + 测试（P1+P2）排第二 | 高：建立安全网和真实测试基线 | 低：CI 改动不影响代码 | 中（L） | CI 与测试相互支撑，合并提升效率；需在重构前建立 |
| v1.20 错误处理 + 重构（P3+P4）排第三 | 中：修正 API 可用性和代码质量 | 中：错误类型变更可能影响下游 | 中（L） | 需在 CI/CD 和测试扩充后进行（有安全网保护） |
| v1.21 EXIF 写入（P5）排第四 | 中：差异化功能扩展 | 中：JPEG segment 操作 | 中（L） | 独立功能扩展，不阻塞后续架构升级 |
| v2.0 wasm 支持（P6）排第五 | 高：突破最大架构限制 | 高：架构级变更 | 高（XL） | 需在所有 v1.x 修正和扩展完成后进行 |
| v2.1 性能 + API（P7+P8）排第六 | 中：性能和 API 人体工程学 | 高：API 变更、并行化平台依赖 | 高（XL+L） | 探索性版本，v2.0 架构稳定后进行，可分阶段交付 |

### 与审查报告"推荐的下一步行动 Top 5"的对应关系

| 审查报告 Top 5 行动 | 本计划对应版本 | 说明 |
|---------------------|--------------|------|
| 行动 1：文档同步（P0，立即，2-3 人日） | v1.18 | 完全对应，v1.18 即 P0 的完整实现 |
| 行动 2：CI/CD 增强（P1，1 周，3-5 人日） | v1.19（与 P2 合并） | P1 与 P2 合并为 v1.19，因 CI 与测试相互支撑 |
| 行动 3：测试数据扩充（P2，1 周，5-7 人日） | v1.19（与 P1 合并） | 同上 |
| 行动 4：错误处理修正（P3，3-5 天，2-3 人日） | v1.20（与 P4 合并） | P3 与 P4 合并为 v1.20，因错误处理为重构提供安全网 |
| 行动 5：GIF 解码重构 + 代码质量（P4，1 周，3-5 人日） | v1.20（与 P3 合并） | 同上 |

审查报告的 P5-P8（未列入 Top 5 但仍建议执行）对应本计划的 v1.21 - v2.1，按中期和长期时间尺度安排。

### 合并原则

仅当两个 P 满足以下条件时方合并到同一版本：
1. 处于同一优先级区间（Top 5 内 / 中期 / 长期）
2. 以 P 级粗粒度估算，合并后总工作量不超过 L（≤ 10 人日）
3. 无相互阻塞风险

工作量论证以 P 级粗粒度估算为决策依据（见"工作量评估口径"口径说明），功能项细粒度加总用于可执行性和可追踪性，两者用途不同。v2.1 中 P7+P8 以 P 级估算 15-22 人日超 L，但同属长期优化且 v2.0 后无更高优先级待办，作为探索性版本可接受（可分阶段交付）。

---

## 风险与缓解措施

### 各版本主要风险汇总

| 版本 | 主要风险 | 风险等级 | 缓解措施 |
|------|---------|---------|---------|
| v1.18 | 文档更新后与代码再次失同步 | 低 | 评估文档自动生成（从 `.mbti` 提取），CI 添加 `moon info` 校验（v1.19 落地） |
| v1.19 | 多平台 CI 可能发现平台特定问题（如 Windows UTF-8 路径） | 低 | 发现问题及时修复；初始可先添加 macOS，Windows 待验证后再启用 |
| v1.19 | 基准测试改用大图后基线数据失效 | 低 | 更新基线数据，记录新旧对比；大图 bench 可能需调整 CI 超时 |
| v1.20 | `UnsupportedFormat` 激活后改变 `decode_any` 错误类型，可能破坏下游模式匹配 | 中 | 在 CHANGELOG 显著标注；通过新增而非修改方式激活（`decode_any` 对未知格式从 `DecodeFailed` 改为 `UnsupportedFormat`，下游需更新 catch 逻辑） |
| v1.20 | `info_from_path` 添加 `raise LoadError` 影响调用方 | 中 | 在 CHANGELOG 标注；此为签名修正（与 `info_from_bytes` 一致），下游应已处理 |
| v1.20 | `failure_reason` 改造可能涉及 API 变更 | 中 | 先评估，若改造复杂则推迟到 v2.1 API 人体工程学改进时统一处理 |
| v1.21 | EXIF 写入错误可能损坏 JPEG 文件 | 中 | 严格的 segment 解析和校验；roundtrip 测试验证写入后可正确读回；先实现 orientation 写入（最简单用例）再扩展 |
| v1.21 | ICC profile 解析复杂度（JPEG APP2 / PNG iCCP chunk） | 中 | 先实现 JPEG ICC，PNG ICC 后续；参考 libpng/libjpeg 实现 |
| v2.0 | MoonBit wasm 目标可能不成熟 | 高 | 先做调研评估（功能项 1），若不成熟则推迟；渐进路径而非全量切换 |
| v2.0 | 纯 MoonBit PNG/JPEG 解码复杂度（zlib + filter + interlace / Huffman + DCT） | 高 | 参考 mizchi/image 实现；先支持 baseline 子集，渐进扩展；保持 native 后端为默认 |
| v2.0 | 架构级变更可能引入回归 | 高 | v1.19 的 CI/CD 安全网和扩充测试提供保护；分阶段迁移（先 PNG 再 JPEG） |
| v2.1 | API 变更破坏 v1.0 冻结承诺 | 高 | 严格通过新增而非修改（方法式 API 与现有函数并存，builder 模式为新增）；CHANGELOG 明确标注新增项 |
| v2.1 | 并行化可能引入平台依赖 | 中 | 评估 MoonBit 并行原语可用性后再决定；若不可用则保持单线程 |
| v2.1 | 零拷贝可能需要 MoonBit 语言层面支持 | 高 | 先评估可行性，若不可行则标记为长期探索项，不阻塞 v2.1 其他功能 |

### 跨版本风险

| 风险 | 缓解措施 |
|------|---------|
| FFI 单点风险（所有 I/O 依赖 stb_image.h） | v2.0 wasm fallback 将减少对 stb 的硬依赖；长期可评估 stb 自动升级流程 |
| 全局状态线程安全（`failure_reason` + stb 配置函数） | v1.20 评估 `failure_reason` 改造；v2.1 通过 `LoadConfig` struct 消除全局状态 |
| reexport 维护负担（969 行自动生成） | 保持 `gen_reexport.py` 同步，每次新增 API 后重新生成；v1.19 功能项 4 添加 `moon info` 校验可间接发现 `.mbti` 失同步进而暴露 reexport 遗漏（非直接 reexport 校验，但提供兜底） |

---

## 不做的事情（明确排除项）

以下功能明确不在计划内，沿用并更新 ROADMAP.md 的排除清单：

| 排除项 | 排除理由 |
|--------|---------|
| **AVIF 编码** | 需要外部编解码器（libaom/svt-av1），与"零 C 依赖"理念冲突。mizchi/image 已覆盖此功能（js 目标） |
| **JPEG progressive 编码** | stb_image_write.h 不支持，纯 MoonBit 实现成本过高且需求有限。bikallem/image 已支持 progressive 解码 |
| **I/O callbacks（`stbi_io_callbacks`）** | MoonBit FFI 不支持闭包传递给 C，已评估。流式解码（v2.1 远期）通过纯 MoonBit 实现绕过此限制 |
| **Go 风格 API** | bikallem/image 和 gmlewis/image 已覆盖此定位，不重复。本库保持 FFI 绑定定位，差异化于纯 MoonBit Go 移植 |
| **全量切换到纯 MoonBit（路径 B）** | 会失去 stb 的格式覆盖（PSD/HDR/PNM）、失去 ASan 验证、工作量巨大。v2.0 采用渐进路径（路径 A 双后端），保留 native 后端 |
| **WebP 编码（短期）** | 纯 MoonBit WebP 编码复杂度高，mizchi/image 已覆盖。远期可考虑，但不在 v1.18-v2.1 范围内 |
| **TIFF 解码（短期）** | stb 不支持 TIFF，需独立实现或绑定 libtiff（引入 C 依赖）。远期可考虑纯 MoonBit 实现，但不在 v1.18-v2.1 范围内 |
| **APNG 解码（短期）** | 需求有限，远期可考虑。不在 v1.18-v2.1 范围内 |
| **色彩管理（完整链路）** | v1.21 仅评估 ICC profile 读取作为基础。完整的色彩空间转换/gamma 校正链路不在 v1.18-v2.1 范围内，需独立版本规划 |

---

## 与现有 ROADMAP.md 的差异说明

### 主要差异点

| 差异点 | 现有 ROADMAP | 本计划 | 调整原因 |
|--------|-------------|--------|---------|
| v1.18 | 未规划 | 新增：文档同步与治理（P0） | 审查报告发现文档与实现差 16 个版本，是最大项目风险 |
| v1.19 | 未规划 | 新增：CI/CD 增强 + 测试数据扩充（P1+P2） | 审查报告发现 CI 未运行 ASan、单平台、无发布流程；测试数据仅 4×4 |
| v1.20 | 未规划 | 新增：错误处理修正 + 代码质量重构（P3+P4） | 审查报告发现 UnsupportedFormat 死代码、FileIO 分类不准、GIF 解码重复 |
| v1.21 | 未规划 | 新增：EXIF 写入与元数据扩展（P5） | 审查报告建议补齐 EXIF 写入（旋转后更新 orientation 等场景） |
| v2.0 | 粗略：双后端 vs 全纯二元选择，无工作量估算 | 具体化：渐进路径（先 wasm fallback 子集），含工作量估算（XL）、功能项、风险点 | 审查报告指出二元选择过于刚性，渐进路径更可行 |
| v2.1 | 粗略：WebP/stream/TIFF/APNG 混在一起，无优先级 | 重新定义：性能优化探索 + API 人体工程学改进（P7+P8） | 审查报告指出 v2.1 过粗略；WebP/TIFF/APNG 移至"不做的事情"（短期排除） |
| v1.11 缺失 | v1.10 直接跳到 v1.12，未说明原因 | 本计划不补充（属已完成历史，非迭代计划范畴） | 建议在 CHANGELOG.md 中补充说明 |
| "不做的事情" | 4 项（AVIF/JPEG progressive/I/O callbacks/Go 风格 API） | 扩展至 9 项（新增全量切换路径 B、WebP/TIFF/APNG 短期排除、完整色彩管理） | 明确短期排除项，避免审阅者误以为遗漏 |

### 优先级调整

| 项目 | 现有 ROADMAP 优先级 | 本计划优先级 | 调整原因 |
|------|---------------------|-------------|---------|
| 文档同步 | 未列入 | 最高（v1.18） | 审查报告识别为最大项目风险 |
| CI/CD 增强 | 未列入 | 高（v1.19） | ASan 是核心卖点但 CI 不验证 |
| 测试数据扩充 | 未列入 | 高（v1.19） | 4×4 测试图无法支撑质量保障 |
| wasm 多目标支持 | 中（v2.0 架构升级） | 高（v2.0，但排在 v1.x 修正之后） | 确认为最大架构限制，但需先完成低风险修正 |
| WebP 编码 | 低（v2.1 远期） | 排除（短期） | 需求有限，mizchi 已覆盖 |
| 流式解码 | 低（v2.1 远期） | 排除（短期） | 架构改动大，I/O callbacks 受 FFI 限制 |
| TIFF 解码 | 低（v2.1 远期） | 排除（短期） | 需引入 C 依赖或大量纯 MoonBit 工作 |

### 新增项

- v1.18 文档同步与治理（全新）
- v1.19 CI/CD 增强 + 测试数据扩充（全新）
- v1.20 错误处理修正 + 代码质量重构（全新）
- v1.21 EXIF 写入与元数据扩展（全新）
- v2.1 性能优化探索 + API 人体工程学改进（重新定义，替换原 WebP/stream/TIFF/APNG）

### 移除或推迟项

- WebP 编码：从 v2.1 移至"不做的事情"（短期排除，远期可考虑）
- 流式解码：从 v2.1 移至"不做的事情"（短期排除，受 I/O callbacks 限制）
- TIFF 解码：从 v2.1 移至"不做的事情"（短期排除，需 C 依赖）
- APNG 解码：从 v2.1 移至"不做的事情"（短期排除，需求有限）

---

## 审阅检查清单

### 关键决策点

请用户确认以下关键决策点：

| # | 决策点 | 选项 | 建议 | 需确认内容 |
|---|--------|------|------|-----------|
| 1 | v2.0 wasm 路径选择 | A. 渐进路径（先 wasm fallback 子集，保留 native 默认）<br>B. 双后端并行（native + wasm 同时维护）<br>C. 全纯 MoonBit（移除 C FFI） | A | 是否同意采用渐进路径 A？路径 B 维护成本高，路径 C 失去 stb 格式覆盖和 ASan 验证 |
| 2 | v1.20 `failure_reason` 改造时机 | A. v1.20 完成（消除全局状态）<br>B. 推迟到 v2.1 在功能项 8 中落地 | B | 是否同意推迟到 v2.1？v1.20 聚焦错误分类修正，`failure_reason` 改造涉及 LoadError 变体变更更适合 v2.1 与 API 人体工程学改进一同处理 |
| 3 | v1.21 ICC profile 读取范围 | A. 仅 JPEG ICC（APP2 segment）<br>B. JPEG + PNG ICC（APP2 + iCCP chunk）<br>C. 暂不实现 ICC，仅做 EXIF 写入 | A | 是否同意先仅做 JPEG ICC？PNG ICC 可后续补充 |
| 4 | v2.1 API 人体工程学改进方式 | A. 新增方法式 API（`Image.load`）+ builder 模式 + LoadConfig struct<br>B. 仅新增方法式 API，不引入 builder<br>C. 暂不改进，保持现有函数式 API | A | 是否同意采用方案 A？需确认 builder 模式和链式 API 在 MoonBit 中的可行性 |
| 5 | v2.1 性能优化范围 | A. 全面探索（并行化 + SIMD + 零拷贝 + FFT 迭代式）<br>B. 仅低风险优化（FFT 迭代式 + 可分离滤波常数因子）<br>C. 暂不优化，待 MoonBit 语言生态成熟 | B | 是否同意先做低风险优化？并行化/SIMD/零拷贝可能引入平台依赖或需语言层面支持 |
| 6 | "不做的事情"扩展 | A. 同意将 WebP/TIFF/APNG/流式解码移至短期排除<br>B. 保留为远期规划（v2.2+），不列入排除 | A | 是否同意将 WebP/TIFF/APNG/流式解码明确为短期排除？ |

### 优先级排序确认项

请用户确认以下优先级排序：

| # | 排序项 | 当前排序 | 需确认内容 |
|---|--------|---------|-----------|
| 1 | 文档同步（v1.18）是否应排第一 | 是 | 是否同意文档同步优先于 CI/CD 和测试扩充？理由：文档风险最高且为后续提供基线 |
| 2 | CI/CD + 测试扩充（v1.19）合并 | 合并 | 是否同意 P1 和 P2 合并为 v1.19？理由：CI 与测试相互支撑 |
| 3 | 错误处理 + 代码重构（v1.20）合并 | 合并 | 是否同意 P3 和 P4 合并为 v1.20？理由：错误处理为重构提供安全网 |
| 4 | EXIF 写入（v1.21）排在 wasm 支持（v2.0）之前 | 是 | 是否同意 EXIF 写入优先于 wasm 支持？理由：EXIF 是低风险功能扩展，wasm 是高风险架构变更 |
| 5 | 性能 + API（v2.1）合并 | 合并 | 是否同意 P7 和 P8 合并为 v2.1？理由：同属长期探索性方向，可分阶段交付 |
| 6 | v2.0 wasm 支持排在 v1.21 EXIF 之后 | 是 | 是否同意 wasm 支持排在所有 v1.x 修正和扩展之后？理由：架构级变更需在稳定基线上进行 |

### 其他需确认项

| # | 确认项 | 需确认内容 |
|---|--------|-----------|
| 1 | 工作量估算口径 | 是否同意 S/M/L/XL 对应 ≤2/3-5/6-10/>10 人日的口径？ |
| 2 | 版本号编排 | 是否同意 v1.18 - v2.1 的版本号编排？v1.x 为修正和扩展，v2.x 为架构级变更 |
| 3 | 产出作为 ROADMAP.md 候选 | 是否同意将本计划作为新的 ROADMAP.md 候选内容（格式兼容，可替换）？ |
| 4 | v1.11 缺失说明 | 是否需要在 CHANGELOG.md 中补充 v1.11 缺失原因？（非本计划范畴，但审查报告提及） |
