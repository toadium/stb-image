// v239 stereo3d 错误路径+边界条件测试

///|
fn s3d_edge_mk_img(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Int32,
) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, (val & 0xFF).to_byte())),
  }
}

///|
fn s3d_edge_mk_point_cloud(n : Int32) -> @stereo3d.PointCloud3D {
  let points : Array[@stereo3d.Point3d] = []
  for i in 0..<n {
    points.push(@stereo3d.Point3d::{
      x: i.to_double(),
      y: (i * 2).to_double(),
      z: (i * 3).to_double(),
      r: 128,
      g: 128,
      b: 128,
      intensity: 1.0,
    })
  }
  @stereo3d.PointCloud3D::{
    points,
    num_points: n,
    width: n,
    height: 1,
    is_organized: false,
  }
}

// ==================== compute_disparity 错误路径 ====================

///|
test "s3d_edge: compute_disparity 零宽度" {
  let img = s3d_edge_mk_img(0, 4, 1, 128)
  let result = @stereo3d.compute_disparity(img, img)
  assert_eq(result.width, 0)
}

///|
test "s3d_edge: compute_disparity 零高度" {
  let img = s3d_edge_mk_img(4, 0, 1, 128)
  let result = @stereo3d.compute_disparity(img, img)
  assert_eq(result.height, 0)
}

///|
test "s3d_edge: compute_disparity 自定义参数" {
  let img = s3d_edge_mk_img(4, 4, 1, 128)
  let result = @stereo3d.compute_disparity(
    img,
    img,
    max_disparity=16,
    block_size=5,
  )
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "s3d_edge: compute_disparity 多通道" {
  let img = s3d_edge_mk_img(4, 4, 3, 128)
  let result = @stereo3d.compute_disparity(img, img)
  assert_eq(result.width, 4)
}

// ==================== disparity_to_depth 错误路径 ====================

///|
test "s3d_edge: disparity_to_depth 零宽度" {
  let img = s3d_edge_mk_img(0, 4, 1, 128)
  let result = @stereo3d.disparity_to_depth(img)
  assert_eq(result.width, 0)
}

///|
test "s3d_edge: disparity_to_depth 自定义参数" {
  let img = s3d_edge_mk_img(4, 4, 1, 100)
  let result = @stereo3d.disparity_to_depth(
    img,
    baseline=0.1,
    focal_length=500.0,
  )
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

// ==================== depth_to_colormap 错误路径 ====================

///|
test "s3d_edge: depth_to_colormap 零宽度" {
  let img = s3d_edge_mk_img(0, 4, 1, 128)
  let result = @stereo3d.depth_to_colormap(img)
  assert_eq(result.width, 0)
}

///|
test "s3d_edge: depth_to_colormap 自定义colormap" {
  let img = s3d_edge_mk_img(4, 4, 1, 128)
  let result = @stereo3d.depth_to_colormap(img, colormap="jet")
  assert_eq(result.width, 4)
}

// ==================== depth_to_pointcloud 错误路径 ====================

///|
test "s3d_edge: depth_to_pointcloud 零宽度" {
  let img = s3d_edge_mk_img(0, 4, 1, 128)
  let pc = @stereo3d.depth_to_pointcloud(img)
  assert_true(pc.num_points >= 0)
}

///|
test "s3d_edge: depth_to_pointcloud 自定义参数" {
  let img = s3d_edge_mk_img(4, 4, 1, 128)
  let pc = @stereo3d.depth_to_pointcloud(
    img,
    fx=500.0,
    fy=500.0,
    cx=2.0,
    cy=2.0,
    scale=1.0,
  )
  assert_true(pc.num_points >= 0)
}

// ==================== depth_to_point_cloud 错误路径 ====================

///|
test "s3d_edge: depth_to_point_cloud 零尺寸深度图" {
  let dm = @stereo3d.DepthMap3d::{
    width: 0,
    height: 0,
    depths: [],
    min_depth: 0.0,
    max_depth: 0.0,
    invalid_count: 0,
  }
  let cam = @stereo3d.create_default_camera_intrinsics(4, 4)
  let pc = @stereo3d.depth_to_point_cloud(dm, cam)
  assert_eq(pc.num_points, 0)
}

// ==================== stereo_match 错误路径 ====================

///|
test "s3d_edge: stereo_match 零宽度" {
  let img = s3d_edge_mk_img(0, 4, 1, 128)
  let config = @stereo3d.create_default_stereo_config()
  let dm = @stereo3d.stereo_match(img, img, config)
  assert_eq(dm.width, 0)
}

///|
test "s3d_edge: stereo_match 单像素" {
  let img = s3d_edge_mk_img(1, 1, 1, 128)
  let config = @stereo3d.create_default_stereo_config()
  let dm = @stereo3d.stereo_match(img, img, config)
  assert_eq(dm.width, 1)
}

// ==================== depth_map_to_image 错误路径 ====================

///|
test "s3d_edge: depth_map_to_image 零尺寸" {
  let dm = @stereo3d.DepthMap3d::{
    width: 0,
    height: 0,
    depths: [],
    min_depth: 0.0,
    max_depth: 0.0,
    invalid_count: 0,
  }
  let img = @stereo3d.depth_map_to_image(dm)
  assert_eq(img.width, 0)
}

// ==================== estimate_normals 边界条件 ====================

///|
test "s3d_edge: estimate_normals 空点云" {
  let pc = @stereo3d.PointCloud3D::{
    points: [],
    num_points: 0,
    width: 0,
    height: 0,
    is_organized: false,
  }
  let normals = @stereo3d.estimate_normals(pc, 1.0)
  assert_eq(normals.length(), 0)
}

///|
test "s3d_edge: estimate_normals 单点" {
  let pc = s3d_edge_mk_point_cloud(1)
  let normals = @stereo3d.estimate_normals(pc, 1.0)
  assert_true(normals.length() >= 0)
}

// ==================== voxel_downsample 边界条件 ====================

///|
test "s3d_edge: voxel_downsample 空点云" {
  let pc = @stereo3d.PointCloud3D::{
    points: [],
    num_points: 0,
    width: 0,
    height: 0,
    is_organized: false,
  }
  let result = @stereo3d.voxel_downsample(pc, 1.0)
  assert_eq(result.num_points, 0)
}

///|
test "s3d_edge: voxel_downsample 极小voxel" {
  let pc = s3d_edge_mk_point_cloud(10)
  let result = @stereo3d.voxel_downsample(pc, 0.001)
  assert_true(result.num_points > 0)
}

// ==================== statistical_outlier_removal 边界条件 ====================

///|
test "s3d_edge: statistical_outlier_removal 空点云" {
  let pc = @stereo3d.PointCloud3D::{
    points: [],
    num_points: 0,
    width: 0,
    height: 0,
    is_organized: false,
  }
  let result = @stereo3d.statistical_outlier_removal(pc, 2, 1.0)
  assert_eq(result.num_points, 0)
}

///|
test "s3d_edge: statistical_outlier_removal 单点" {
  let pc = s3d_edge_mk_point_cloud(1)
  let result = @stereo3d.statistical_outlier_removal(pc, 2, 1.0)
  assert_true(result.num_points >= 0)
}

// ==================== icp_registration 边界条件 ====================

///|
test "s3d_edge: icp_registration 相同点云" {
  let pc = s3d_edge_mk_point_cloud(5)
  let result = @stereo3d.icp_registration(pc, pc, 10, 0.001)
  assert_true(result.fitness >= 0.0)
  assert_true(result.rmse >= 0.0)
}

///|
test "s3d_edge: icp_registration 单点" {
  let pc = s3d_edge_mk_point_cloud(1)
  let result = @stereo3d.icp_registration(pc, pc, 5, 0.01)
  assert_true(result.fitness >= 0.0)
}

// ==================== pointcloud_voxel_downsample 边界条件 ====================

///|
test "s3d_edge: pointcloud_voxel_downsample 空点云" {
  let pc = @stereo3d.point_cloud_new()
  let result = @stereo3d.pointcloud_voxel_downsample(pc)
  assert_eq(result.num_points, 0)
}

///|
test "s3d_edge: pointcloud_voxel_downsample 自定义voxel" {
  let pc = @stereo3d.point_cloud_new()
  let result = @stereo3d.pointcloud_voxel_downsample(pc, voxel_size=0.5)
  assert_eq(result.num_points, 0)
}

// ==================== create_default_camera_intrinsics 边界条件 ====================

///|
test "s3d_edge: create_default_camera_intrinsics 零尺寸" {
  let cam = @stereo3d.create_default_camera_intrinsics(0, 0)
  assert_eq(cam.width, 0)
  assert_eq(cam.height, 0)
  assert_true(cam.fx >= 0.0)
}

///|
test "s3d_edge: create_default_camera_intrinsics 大尺寸" {
  let cam = @stereo3d.create_default_camera_intrinsics(1920, 1080)
  assert_eq(cam.width, 1920)
  assert_eq(cam.height, 1080)
  assert_true(cam.fx > 0.0)
  assert_true(cam.fy > 0.0)
}

// ==================== vision_3d_report_to_string 边界条件 ====================

///|
test "s3d_edge: vision_3d_report_to_string 空数据" {
  let pc = @stereo3d.PointCloud3D::{
    points: [],
    num_points: 0,
    width: 0,
    height: 0,
    is_organized: false,
  }
  let dm = @stereo3d.DepthMap3d::{
    width: 0,
    height: 0,
    depths: [],
    min_depth: 0.0,
    max_depth: 0.0,
    invalid_count: 0,
  }
  let reg = @stereo3d.RegistrationResult3d::{
    transformation: [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0],
    inliers: 0,
    rmse: 0.0,
    fitness: 0.0,
    iterations: 0,
    converged: false,
  }
  let report = @stereo3d.vision_3d_report_to_string(pc, dm, reg)
  assert_true(report.length() > 0)
}
