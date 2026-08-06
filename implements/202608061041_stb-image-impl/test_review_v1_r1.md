# 测试审查报告（v1 r1）

## 审查结果
APPROVED

## 发现
- **[轻微]** tests/test_project_skeleton.py — TestMoonMod 实际 8 个用例（test_has_keywords_field 为第 8 个），测试报告 test_v1.md 声称 7 个；TestPinnedConstants 实际 10 个用例（test_cache_dir_under_repo_root_prepare 为第 10 个），声称 9 个。总数 52 与收集结果一致，仅分布数字偏差，不影响测试有效性。
- **[轻微]** tests/test_acceptance.py — TestMoonCheck 在 REPO_ROOT 运行 `moon check`，会生成 `_build/` 与 `src/pkg.generated.mbti` 构建产物。虽属验收契约合理副作用，但测试未清理，可能污染工作目录。设计契约未要求清理，故仅作改进建议。
- **[轻微]** tests/test_prepare.py — TestDownloadToCache 未覆盖"缓存文件已存在但 SHA256 不匹配时应重新下载"的分支（实现中该分支存在且正确）。当前覆盖已含缓存命中与 SHA256 不匹配两条路径，缺口不影响核心契约。
- **[轻微]** tests/test_acceptance.py — TestPinnedConstants 验证了 STB_IMAGE_WRITE_FILENAME 的值，但未同样断言 STB_IMAGE_FILENAME == "stb_image.h"；test_stb_image_url_references_pinned_commit 仅验证 commit 出现在 URL 且 URL 以 filename 结尾，未验证 host 为 raw.githubusercontent.com。形态校验已足够保证 pinned 语义，host 校验非契约硬性要求。
- **[轻微]** tests/test_prepare.py — TestMain.test_with_include_write_raises_systemexit_when_not_activated 未验证 raise 前已成功 vendoring stb_image.h（实现顺序如此）。错误路径契约已由 SystemExit 断言覆盖，前置副作用验证缺失属轻微。
- **[轻微]** tests/test_project_skeleton.py — TestMoonPkg.test_no_options_block 使用 `"options" not in text` 子串断言，若未来 moon.pkg 注释中出现 "options" 会误判。当前 moon.pkg 仅一行无注释，断言有效。
- **[轻微]** tests/test_acceptance.py — TestPrepareGeneratesHeader.test_generated_header_sha256_matches_pinned 与 test_prepare_generates_stb_image_h 均调用 _run_prepare 触发真实网络下载，前者在 main() 已校验 SHA256 的前提下断言略显冗余；可合并以减少网络依赖，但不影响正确性。

## 修改要求（仅 REJECTED 时）
无