# aoci — 符号语义索引（GeoVerse Phase 3）

> **层级**：五层 · AOCI 横切基础设施
> **定位**：为 1338+ 公开函数建立符号语义索引，AI 查询时按需加载模块文档，降低 70%~90% Token 消耗。

## 四大子组件

| 组件 | 职责 |
|------|------|
| AOCI-Builder | 源码/mbti 解析 → 符号坐标 + 依赖图谱 |
| AOCI-Router | 自然语言 → 模块定位 → 按需加载 |
| AOCI-ContextBudget | Token 配额/分区/降级压缩 |
| AOCI-Verifier | 依赖一致性/过期检测/边界冲突 |

## 模块结构

| 文件 | 内容 |
|------|------|
| `aoci_symbol.mbt` | SymbolKind 枚举 + SymbolCoord 结构 + 方法 |
| `aoci_index.mbt` | SymbolIndex 结构 + 关键词倒排表 + 查询方法 |
| `aoci_builder.mbt` | build_index / build_symbol / build_from_mbti / build_dependency_graph |
| `aoci_router.mbt` | route / route_top_k / route_by_package / route_by_kind |
| `aoci_budget.mbt` | ContextBudget + allocate / allocate_with_priority / 降级 |
| `aoci_verifier.mbt` | VerifyResult + verify_consistency / keyword_coverage / dependencies / budget / all |

## 公共 API

### 类型

- `SymbolKind` — 符号类型（Function / Method / Type / TypeAlias / Enum / Struct）
- `SymbolCoord` — 符号坐标（pkg / name / kind / signature / doc / keywords）
- `SymbolIndex` — 符号索引（symbols + keyword_map）
- `ContextBudget` — Token 预算管理
- `VerifyResult` — 验证结果（is_valid + issues）

### Builder

- `build_index(symbols)` → SymbolIndex
- `build_from_mbti(pkg, mbti_content)` → SymbolIndex
- `build_dependency_graph(index)` → Array[(String, Array[String])]

### Router

- `route(index, query)` → Array[SymbolCoord] — 关键词匹配 + 评分排序
- `route_top_k(index, query, k)` → Array[SymbolCoord] — Top-K 返回

### ContextBudget

- `ContextBudget::make(quota)` → ContextBudget
- `budget.allocate(symbols)` → Array[SymbolCoord] — 按预算分配 + 降级

### Verifier

- `verify_consistency(index)` → VerifyResult
- `verify_all(index)` → VerifyResult — 综合验证

## 测试

36 个测试覆盖：Symbol / Index / Builder / Router / Budget / Verifier + E2E。