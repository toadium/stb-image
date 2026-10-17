# walkzzz/image/process/feature

> 特征检测（Harris、ORB、SIFT、模板匹配、光流、GLCM、LBP）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 91 |
| 公开类型 | 14 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CornerPoint {
pub(all) struct DescriptorMatch {
pub(all) struct FlowResult {
pub struct GlcmFeatures {
pub(all) enum HistCompareMethod {
pub struct IntegralImage {
pub struct IntegralImageSq {
pub(all) struct OrbDescriptor {
pub(all) struct OrbKeyPoint {
pub(all) struct SiftDescriptor {
pub(all) struct SiftKeyPoint {
pub(all) struct SiftMatch {
pub(all) enum TemplateMatchMethod {
pub(all) struct TemplateMatchResult {
```

## API

```moonbit
pub fn ahash(@types.Image) -> Array[Int] raise @types.LoadError
pub fn ahash_16(@types.Image16) -> Array[Int] raise @types.LoadError
pub fn ahash_f(@types.ImageF) -> Array[Int] raise @types.LoadError
pub fn compare_hist(Array[Int], Array[Int], HistCompareMethod) -> Float raise @types.LoadError
pub fn compute_glcm(@types.Image, Int, Int, levels? : Int) -> Array[Array[Int]] raise @types.LoadError
pub fn compute_glcm_16(@types.Image16, Int, Int, levels? : Int) -> Array[Array[Int]] raise @types.LoadError
pub fn compute_glcm_f(@types.ImageF, Int, Int, levels? : Int) -> Array[Array[Int]] raise @types.LoadError
pub fn dhash(@types.Image) -> Array[Int] raise @types.LoadError
pub fn dhash_16(@types.Image16) -> Array[Int] raise @types.LoadError
pub fn dhash_f(@types.ImageF) -> Array[Int] raise @types.LoadError
pub fn draw_corners(@types.Image, Array[CornerPoint], color? : Array[Byte], radius? : Int) -> @types.Image raise @types.LoadError
pub fn gabor_filter(@types.Image, Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float) -> @types.Image raise @types.LoadError
pub fn gabor_filter_16(@types.Image16, Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float) -> @types.Image16 raise @types.LoadError
pub fn gabor_filter_bank(@types.Image, Int, Float, num_orientations? : Int, lambda? : Float, gamma? : Float) -> @types.Image raise @types.LoadError
pub fn gabor_filter_bank_16(@types.Image16, Int, Float, num_orientations? : Int, lambda? : Float, gamma? : Float) -> @types.Image16 raise @types.LoadError
pub fn gabor_filter_bank_f(@types.ImageF, Int, Float, num_orientations? : Int, lambda? : Float, gamma? : Float) -> @types.ImageF raise @types.LoadError
pub fn gabor_filter_f(@types.ImageF, Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float) -> @types.ImageF raise @types.LoadError
pub fn gabor_kernel(Int, Float, Float, lambda? : Float, gamma? : Float, phi? : Float) -> Array[Array[Float]] raise @types.LoadError
pub fn glcm_features(Array[Array[Int]]) -> GlcmFeatures
pub fn glcm_features_multi_direction(@types.Image, levels? : Int) -> Array[GlcmFeatures] raise @types.LoadError
pub fn glcm_features_multi_direction_16(@types.Image16, levels? : Int) -> Array[GlcmFeatures] raise @types.LoadError
pub fn glcm_features_multi_direction_f(@types.ImageF, levels? : Int) -> Array[GlcmFeatures] raise @types.LoadError
pub fn good_features_to_track(@types.Image, Int, Float, min_distance? : Int) -> Array[CornerPoint] raise @types.LoadError
pub fn good_features_to_track_16(@types.Image16, Int, Float, min_distance? : Int) -> Array[CornerPoint] raise @types.LoadError
pub fn good_features_to_track_f(@types.ImageF, Int, Float, min_distance? : Int) -> Array[CornerPoint] raise @types.LoadError
pub fn hamming_distance(Array[Int], Array[Int]) -> Int raise @types.LoadError
pub fn harris_corners(@types.Image, k? : Float, threshold? : Float, min_distance? : Int) -> Array[CornerPoint] raise @types.LoadError
pub fn harris_corners_16(@types.Image16, k? : Float, threshold? : Float, min_distance? : Int) -> Array[CornerPoint] raise @types.LoadError
pub fn harris_corners_f(@types.ImageF, k? : Float, threshold? : Float, min_distance? : Int) -> Array[CornerPoint] raise @types.LoadError
pub fn histogram(@types.Image) -> Array[Int] raise @types.LoadError
pub fn histogram_16(@types.Image16) -> Array[Int] raise @types.LoadError
pub fn histogram_equalize(@types.Image) -> @types.Image raise @types.LoadError
pub fn histogram_equalize_16(@types.Image16) -> @types.Image16 raise @types.LoadError
pub fn histogram_equalize_f(@types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn histogram_f(@types.ImageF) -> Array[Int] raise @types.LoadError
pub fn histogram_matching(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn histogram_matching_16(@types.Image16, @types.Image16) -> @types.Image16 raise @types.LoadError
pub fn histogram_matching_f(@types.ImageF, @types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn histogram_normalize(@types.Image) -> @types.Image raise @types.LoadError
pub fn histogram_normalize_16(@types.Image16) -> @types.Image16 raise @types.LoadError
pub fn histogram_normalize_f(@types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn horn_schunck(@types.Image, @types.Image, alpha? : Float, iterations? : Int) -> (Array[Float], Array[Float]) raise @types.LoadError
pub fn horn_schunck_16(@types.Image16, @types.Image16, alpha? : Float, iterations? : Int) -> (Array[Float], Array[Float]) raise @types.LoadError
pub fn horn_schunck_f(@types.ImageF, @types.ImageF, alpha? : Float, iterations? : Int) -> (Array[Float], Array[Float]) raise @types.LoadError
pub fn integral_image(@types.Image) -> IntegralImage raise @types.LoadError
pub fn integral_image_16(@types.Image16) -> IntegralImage raise @types.LoadError
pub fn integral_image_f(@types.ImageF) -> IntegralImage raise @types.LoadError
pub fn integral_image_sq(@types.Image) -> IntegralImageSq raise @types.LoadError
pub fn integral_image_sq_16(@types.Image16) -> IntegralImageSq raise @types.LoadError
pub fn integral_image_sq_f(@types.ImageF) -> IntegralImageSq raise @types.LoadError
pub fn integral_mean(IntegralImage, Int, Int, Int, Int) -> Float raise @types.LoadError
pub fn integral_sum(IntegralImage, Int, Int, Int, Int) -> Int64 raise @types.LoadError
pub fn integral_sum_sq(IntegralImageSq, Int, Int, Int, Int) -> Int64 raise @types.LoadError
pub fn integral_variance(IntegralImage, IntegralImageSq, Int, Int, Int, Int) -> Float raise @types.LoadError
pub fn lbp(@types.Image) -> @types.Image raise @types.LoadError
pub fn lbp_16(@types.Image16) -> @types.Image16 raise @types.LoadError
pub fn lbp_f(@types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn lbp_uniform(@types.Image) -> @types.Image raise @types.LoadError
pub fn lbp_uniform_16(@types.Image16) -> @types.Image16 raise @types.LoadError
pub fn lbp_uniform_f(@types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn lucas_kanade(@types.Image, @types.Image, Array[(Int, Int)], window_size? : Int, max_iter? : Int) -> Array[FlowResult] raise @types.LoadError
pub fn lucas_kanade_16(@types.Image16, @types.Image16, Array[(Int, Int)], window_size? : Int, max_iter? : Int) -> Array[FlowResult] raise @types.LoadError
pub fn lucas_kanade_f(@types.ImageF, @types.ImageF, Array[(Int, Int)], window_size? : Int, max_iter? : Int) -> Array[FlowResult] raise @types.LoadError
pub fn mse(@types.Image, @types.Image) -> Double raise @types.LoadError
pub fn mse_16(@types.Image16, @types.Image16) -> Double raise @types.LoadError
pub fn mse_f(@types.ImageF, @types.ImageF) -> Double raise @types.LoadError
pub fn orb_detect(@types.Image, max_features? : Int, threshold? : Int) -> Array[OrbDescriptor] raise @types.LoadError
pub fn orb_detect_16(@types.Image16, max_features? : Int, threshold? : Int) -> Array[OrbDescriptor] raise @types.LoadError
pub fn orb_detect_f(@types.ImageF, max_features? : Int, threshold? : Int) -> Array[OrbDescriptor] raise @types.LoadError
pub fn orb_hamming(OrbDescriptor, OrbDescriptor) -> Int
pub fn orb_match(Array[OrbDescriptor], Array[OrbDescriptor], max_distance? : Int) -> Array[DescriptorMatch] raise @types.LoadError
pub fn phash(@types.Image) -> Array[Int] raise @types.LoadError
pub fn phash_16(@types.Image16) -> Array[Int] raise @types.LoadError
pub fn phash_f(@types.ImageF) -> Array[Int] raise @types.LoadError
pub fn psnr(@types.Image, @types.Image) -> Double raise @types.LoadError
pub fn psnr_16(@types.Image16, @types.Image16) -> Double raise @types.LoadError
pub fn psnr_f(@types.ImageF, @types.ImageF) -> Double raise @types.LoadError
pub fn ransac_homography(Array[((Float, Float), (Float, Float))], iterations? : Int, threshold? : Float) -> Array[Float]? raise @types.LoadError
pub fn sift_detect(@types.Image, max_features? : Int, contrast_threshold? : Float) -> Array[SiftDescriptor] raise @types.LoadError
pub fn sift_detect_16(@types.Image16, max_features? : Int, contrast_threshold? : Float) -> Array[SiftDescriptor] raise @types.LoadError
pub fn sift_detect_f(@types.ImageF, max_features? : Int, contrast_threshold? : Float) -> Array[SiftDescriptor] raise @types.LoadError
pub fn sift_match(Array[SiftDescriptor], Array[SiftDescriptor], max_distance? : Float, ratio_test? : Float) -> Array[SiftMatch] raise @types.LoadError
pub fn ssim(@types.Image, @types.Image) -> Double raise @types.LoadError
pub fn ssim_16(@types.Image16, @types.Image16) -> Double raise @types.LoadError
pub fn ssim_f(@types.ImageF, @types.ImageF) -> Double raise @types.LoadError
pub fn template_match(@types.Image, @types.Image, match_method? : TemplateMatchMethod) -> Array[TemplateMatchResult] raise @types.LoadError
pub fn template_match_16(@types.Image16, @types.Image16, match_method? : TemplateMatchMethod) -> Array[TemplateMatchResult] raise @types.LoadError
pub fn template_match_best(@types.Image, @types.Image, match_method? : TemplateMatchMethod) -> TemplateMatchResult? raise @types.LoadError
pub fn template_match_best_16(@types.Image16, @types.Image16, match_method? : TemplateMatchMethod) -> TemplateMatchResult? raise @types.LoadError
pub fn template_match_best_f(@types.ImageF, @types.ImageF, match_method? : TemplateMatchMethod) -> TemplateMatchResult? raise @types.LoadError
pub fn template_match_f(@types.ImageF, @types.ImageF, match_method? : TemplateMatchMethod) -> Array[TemplateMatchResult] raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
