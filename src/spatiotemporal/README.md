# spatiotemporal — 时空图像系统（GeoVerse Phase 2）

> **层级**：四层 · 领域高阶算法层
> **定位**：四维（X, Y, C, T）原生时空图像系统，统一管理静态图像 + 动态图像 + 时变场。

## 核心思想

时间不是属性标签，是**原生第 3 维**。静态图像 = 单帧 TImage；动画/视频 = 多帧 TImage。

## 模块结构

| 文件 | 内容 |
|------|------|
| `primitives.mbt` | TInterval / TFrame / TImage / TVideo 时空原语 |
| `temporal_ctx.mbt` | TContext 时态控制器（播放/暂停/循环/速度） |
| `st_predicates.mbt` | 时空拓扑谓词（Allen's Interval Algebra 子集） |
| `st_interpolate.mbt` | 帧间线性插值 + 指定时间取帧 |
| `st_snapshot.mbt` | 时序快照 / 子片段截取 / GIF 转换 |

## 公共 API

### 类型

- `TInterval` — 时间区间 [start, end)
- `TFrame` — 时空帧（image + timestamp + duration）
- `TImage` — 时变图像（多帧序列 + fps）
- `TVideo` — 时空视频（TImage + 元数据）
- `TContext` — 时态控制器（current_time / fps / is_loop / paused / speed）

### 时空拓扑谓词（Allen's Interval Algebra）

- `st_contains(a, b)` — a 包含 b
- `st_within(a, b)` — a 在 b 内
- `st_intersects(a, b)` — a 与 b 相交
- `st_overlaps(a, b)` — a 与 b 有实质重叠
- `st_during(a, b)` — a 严格在 b 期间
- `st_before(a, b)` — a 在 b 之前
- `st_after(a, b)` — a 在 b 之后
- `st_meets(a, b)` — a 紧接 b
- `st_equals(a, b)` — a 等于 b

### 插值与快照

- `st_interpolate_linear(f1, f2, alpha)` — 线性插值
- `st_interpolate_at(timage, time)` — 指定时间插值取帧
- `st_snapshot(timage, time)` — 取最近帧
- `st_subclip(timage, start, end)` — 截取子片段
- `st_extract_frame(timage, index)` — 按索引取帧
- `st_from_gif_animation(gif)` — GIF 动画转 TImage

## 测试

50 个测试（4 个测试文件），四目标全绿（native/wasm-gc/js/wasm）。