# walkzzz/image/process/stitch

> 图像拼接与全景合成

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 8 |
| 公开类型 | 4 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct FeaturePoint {
pub(all) struct Homography {
pub(all) struct MatchPair {
pub(all) struct StitchConfig {
```

## API

```moonbit
pub fn apply_homography(Homography, Double, Double) -> (Double, Double)
pub fn detect_features_simple(@types.Image, max_features? : Int) -> Array[FeaturePoint]
pub fn estimate_homography_ransac(Array[MatchPair], Array[FeaturePoint], Array[FeaturePoint], iterations? : Int, threshold? : Double) -> (Homography?, Array[MatchPair])
pub fn identity_homography() -> Homography
pub fn invert_homography(Homography) -> Homography?
pub fn match_features(Array[FeaturePoint], Array[FeaturePoint], ratio_threshold? : Double) -> Array[MatchPair]
pub fn stitch_default_config() -> StitchConfig
pub fn stitch_images(@types.Image, @types.Image, config? : StitchConfig) -> @types.Image?
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
