# walkzzz/image/process/neural_rendering

> 神经渲染

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CameraParams {
pub(all) struct Gaussian3D {
pub(all) struct GaussianSplattingConfig {
pub(all) struct NeRFConfig {
pub(all) enum NeuralRenderingAlgorithm {
pub(all) struct Point3D {
pub(all) struct Ray {
pub(all) enum ReconstructionAlgorithm {
pub(all) struct ReconstructionResult {
pub(all) struct RenderingResult {
pub(all) struct Voxel {
```

## API

```moonbit
pub fn create_default_camera() -> CameraParams
pub fn create_default_gaussian_config() -> GaussianSplattingConfig
pub fn create_default_nerf_config() -> NeRFConfig
pub fn generate_rays(CameraParams) -> Array[Ray]
pub fn generate_sample_gaussians(Int) -> Array[Gaussian3D]
pub fn multiview_stereo_reconstruction(Array[@types.Image], Array[CameraParams]) -> ReconstructionResult
pub fn neural_rendering_report_to_string(RenderingResult, NeuralRenderingAlgorithm) -> String
pub fn reconstruction_report_to_string(ReconstructionResult, ReconstructionAlgorithm) -> String
pub fn render_gaussian_splatting(CameraParams, Array[Gaussian3D], GaussianSplattingConfig) -> RenderingResult
pub fn render_nerf(CameraParams, NeRFConfig) -> RenderingResult
pub fn visualize_point_cloud(Array[Point3D], Int, Int) -> @types.Image
pub fn volume_render(Ray, Array[Voxel], NeRFConfig) -> (Array[Double], Double)
pub fn NeuralRenderingAlgorithm::equal(Self, Self) -> Bool
pub fn NeuralRenderingAlgorithm::not_equal(Self, Self) -> Bool
pub fn ReconstructionAlgorithm::equal(Self, Self) -> Bool
pub fn ReconstructionAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
