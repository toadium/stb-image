# 审查进度跟踪

## R1: 顶层架构 + types + reexport — 严重 3 / 一般 7 / 轻微 5 — 分层清晰但 reexport 有参数丢弃 bug、util/pure.process 大量重复、命名文档失修 → `review_v1.md`

> 决定：T1-T15 全部记入待办，本轮不处理，继续 R2-R6

## R2: pure/codec + pure/pixel — 严重 1 / 一般 12 / 軽微 7 — 功能完整但 pure/pixel 死代码、API 一致性失修、辅助函数多处重复 → `review_v2.md`

> 决定：T16-T36 全部记入待办，继续 R3

## R3: pure/color + pure/process — 严重 3 / 一般 5 / 軽微 2 — pure 层（除 codec 外）整体死代码，架构性缺陷 → `review_v3.md`

> 决定：T37-T46 全部记入待办，继续 R4

## R4: lib/format + lib/meta — 严重 2 / 一般 6 / 軽微 3 — format 与 pure/codec 重复、lib 包名模糊、meta 命名不对称 → `review_v4.md`

> 决定：T47-T57 全部记入待办，继续 R5

## R5: lib/process + lib/util — 严重 3 / 一般 8 / 軽微 4 — 职责交叉错位、层次倒置、命名不一致、职责过宽 → `review_v5.md`

> 决定：T58-T72 全部记入待办，继续 R6

## R6: 文档与下游可用性 — 严重 6 / 一般 9 / 軽微 4 — 文档与代码系统性失效，19 幽灵 API + 54 隐形 API → `review_v6.md`

> 决定：T73-T91 全部记入待办，进入阶段三审查总结
