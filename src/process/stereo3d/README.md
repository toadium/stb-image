# walkzzz/image/process/stereo3d

> 立体视觉与三维重建

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 16 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct BoundingBox3d {
pub(all) struct CameraExtrinsics3d {
pub(all) struct CameraIntrinsics3d {
pub(all) struct DepthMap3d {
pub(all) struct Mesh3d {
pub(all) struct Point3d {
pub(all) struct PointCloud {
pub(all) struct PointCloud3D {
pub(all) struct RegistrationResult3d {
pub(all) struct StereoConfig3d {
```

## API

```moonbit
pub fn compute_disparity(@types.Image, @types.Image, max_disparity? : Int, block_size? : Int) -> @types.Image
pub fn create_default_camera_intrinsics(Int, Int) -> CameraIntrinsics3d
pub fn create_default_stereo_config() -> StereoConfig3d
pub fn depth_map_to_image(DepthMap3d) -> @types.Image
pub fn depth_to_colormap(@types.Image, colormap? : String) -> @types.Image
pub fn depth_to_point_cloud(DepthMap3d, CameraIntrinsics3d) -> PointCloud3D
pub fn depth_to_pointcloud(@types.Image, fx? : Double, fy? : Double, cx? : Double, cy? : Double, scale? : Double) -> PointCloud
pub fn disparity_to_depth(@types.Image, baseline? : Double, focal_length? : Double) -> @types.Image
pub fn estimate_normals(PointCloud3D, Double) -> Array[(Double, Double, Double)]
pub fn icp_registration(PointCloud3D, PointCloud3D, Int, Double) -> RegistrationResult3d
pub fn point_cloud_new() -> PointCloud
pub fn pointcloud_voxel_downsample(PointCloud, voxel_size? : Double) -> PointCloud
pub fn statistical_outlier_removal(PointCloud3D, Int, Double) -> PointCloud3D
pub fn stereo_match(@types.Image, @types.Image, StereoConfig3d) -> DepthMap3d
pub fn vision_3d_report_to_string(PointCloud3D, DepthMap3d, RegistrationResult3d) -> String
pub fn voxel_downsample(PointCloud3D, Double) -> PointCloud3D
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
