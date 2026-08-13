# bench

性能基准测试工具 — 14 项基准覆盖编解码、缩放、滤波、色彩、几何操作。

## 运行

```bash
# native release（推荐，性能数据最准确）
moon run cmd/bench --target native --release

# 其他目标
moon run cmd/bench --target wasm-gc
moon run cmd/bench --target js
```

## 基准项

| 类别 | 基准 | 输入 |
|------|------|------|
| **编解码** | PNG encode/decode, BMP encode, QOI encode/decode | 128×128 RGB / RGBA |
| **缩放** | resize 256→128 | 256×256 → 128×128 |
| **滤波** | gaussian_blur 5×5, box_blur 5×5, sharpen | 128×128 RGB |
| **边缘** | edge_detect_sobel | 128×128 RGB |
| **色彩** | to_grayscale, adjust_brightness | 128×128 RGB |
| **几何** | crop 64×64, rotate_90 | 128×128 RGB |

## 输出

每项基准输出平均/中位数/最小/最大/标准差/吞吐量，格式：

```
png encode 128x128: avg=619us median=618us min=609us max=632us stdev=1.5% 26.6MP/s
```

## 完整报告

最新基准结果与分析见 [docs/performance_report.md](../../docs/performance_report.md)。

## 实现

- 入口：`main.mbt` → 调用 `@src.bench_run()`
- 基准实现：`src/bench.mbt`
- 框架：MoonBit 内置 `@bench.Bench`
