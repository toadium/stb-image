// v38.0.0 神经渲染测试 — neural_rendering 模块 12 函数

///|
fn create_solid_nr(w : Int, h : Int, v : Int) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "create_default_camera: 默认相机参数" {
  let camera = @neural_rendering.create_default_camera()
  assert_true(camera.image_width > 0)
  assert_true(camera.image_height > 0)
  assert_true(camera.focal_length > 0.0)
  assert_true(camera.near_plane > 0.0)
  assert_true(camera.far_plane > camera.near_plane)
  assert_true(camera.position.length() > 0)
  assert_true(camera.rotation.length() > 0)
}

///|
test "create_default_nerf_config: 默认NeRF配置" {
  let config = @neural_rendering.create_default_nerf_config()
  assert_true(config.num_samples_per_ray > 0)
  assert_true(config.num_importance_samples > 0)
  assert_true(config.near_plane > 0.0)
  assert_true(config.far_plane > config.near_plane)
}

///|
test "create_default_gaussian_config: 默认高斯配置" {
  let config = @neural_rendering.create_default_gaussian_config()
  assert_true(config.num_gaussians > 0)
  assert_true(config.sh_degree >= 0)
  assert_true(config.opacity_threshold >= 0.0)
}

///|
test "generate_rays: 光线生成" {
  let camera = @neural_rendering.create_default_camera()
  let rays = @neural_rendering.generate_rays(camera)
  assert_true(rays.length() > 0)
  for ray in rays {
    assert_true(ray.origin.length() > 0)
    assert_true(ray.direction.length() > 0)
  }
}

///|
test "generate_sample_gaussians: 采样高斯生成" {
  let gaussians = @neural_rendering.generate_sample_gaussians(10)
  assert_true(gaussians.length() == 10)
  for g in gaussians {
    assert_true(g.position.length() > 0)
    assert_true(g.opacity >= 0.0)
  }
}

///|
test "render_nerf: NeRF渲染" {
  let camera = @neural_rendering.create_default_camera()
  let config = @neural_rendering.create_default_nerf_config()
  let result = @neural_rendering.render_nerf(camera, config)
  assert_true(result.rendering_time_ms >= 0.0)
  assert_true(result.psnr >= 0.0)
  assert_true(result.ssim >= -1.0 && result.ssim <= 1.0)
}

///|
test "render_gaussian_splatting: 高斯泼溅渲染" {
  let camera = @neural_rendering.create_default_camera()
  let config = @neural_rendering.create_default_gaussian_config()
  let gaussians = @neural_rendering.generate_sample_gaussians(5)
  let result = @neural_rendering.render_gaussian_splatting(
    camera, gaussians, config,
  )
  assert_true(result.rendering_time_ms >= 0.0)
}

///|
test "visualize_point_cloud: 点云可视化" {
  let points = [
    @neural_rendering.Point3D::{
      position: [0.0, 0.0, 0.0],
      color: [255.0, 0.0, 0.0],
      normal: [0.0, 0.0, 1.0],
      confidence: 1.0,
    },
    @neural_rendering.Point3D::{
      position: [1.0, 1.0, 1.0],
      color: [0.0, 255.0, 0.0],
      normal: [0.0, 1.0, 0.0],
      confidence: 0.8,
    },
  ]
  let image = @neural_rendering.visualize_point_cloud(points, 64, 64)
  assert_true(image.width > 0)
  assert_true(image.height > 0)
}

///|
test "multiview_stereo_reconstruction: 多视图立体重建" {
  let camera = @neural_rendering.create_default_camera()
  let img1 = create_solid_nr(8, 8, 100)
  let img2 = create_solid_nr(8, 8, 150)
  let result = @neural_rendering.multiview_stereo_reconstruction([img1, img2], [
    camera, camera,
  ])
  assert_true(result.num_points >= 0)
  assert_true(result.num_cameras > 0)
  assert_true(result.reconstruction_time_ms >= 0.0)
  assert_true(result.coverage >= 0.0)
}

///|
test "neural_rendering_report_to_string: 渲染报告" {
  let camera = @neural_rendering.create_default_camera()
  let config = @neural_rendering.create_default_nerf_config()
  let result = @neural_rendering.render_nerf(camera, config)
  let report = @neural_rendering.neural_rendering_report_to_string(
    result,
    @neural_rendering.NeuralRenderingAlgorithm::NeRF,
  )
  assert_true(report.length() > 0)
}

///|
test "reconstruction_report_to_string: 重建报告" {
  let camera = @neural_rendering.create_default_camera()
  let img = create_solid_nr(8, 8, 100)
  let result = @neural_rendering.multiview_stereo_reconstruction([img], [camera])
  let report = @neural_rendering.reconstruction_report_to_string(
    result,
    @neural_rendering.ReconstructionAlgorithm::MultiViewStereo,
  )
  assert_true(report.length() > 0)
}
