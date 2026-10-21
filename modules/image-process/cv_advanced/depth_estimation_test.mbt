///|
test "MonocularDepthMethod: 枚举值" {
  assert_true(
    @cv_advanced.MonocularDepthMethod::FromFocus is @cv_advanced.FromFocus,
  )
  assert_true(
    @cv_advanced.MonocularDepthMethod::FromDefocus is @cv_advanced.FromDefocus,
  )
  assert_true(
    @cv_advanced.MonocularDepthMethod::RelativeBlur is @cv_advanced.RelativeBlur,
  )
  assert_true(@cv_advanced.MonocularDepthMethod::Hybrid is @cv_advanced.Hybrid)
}

///|
test "DepthPostProcessParams: 构造与字段" {
  let p : @cv_advanced.DepthPostProcessParams = {
    smooth_radius: 2,
    fill_holes: true,
    normalize: true,
    edge_refine: false,
    min_depth: 0.5,
    max_depth: 10.0,
  }
  assert_eq(p.smooth_radius, 2)
  assert_true(p.fill_holes)
  assert_true(p.normalize)
  assert_eq(p.min_depth, 0.5)
  assert_eq(p.max_depth, 10.0)
}

///|
test "DepthEstimationParams: 构造与字段" {
  let p : @cv_advanced.DepthEstimationParams = {
    est_method: @cv_advanced.FromFocus,
    focal_length: 50.0,
    aperture: 8.0,
    focus_distance: 2.0,
    post_process: {
      smooth_radius: 1,
      fill_holes: true,
      normalize: false,
      edge_refine: false,
      min_depth: 0.0,
      max_depth: 0.0,
    },
  }
  assert_eq(p.focal_length, 50.0)
  assert_eq(p.aperture, 8.0)
  assert_eq(p.focus_distance, 2.0)
  assert_true(p.est_method is FromFocus)
}

///|
test "estimate_depth_from_focus: 基本测试" {
  // 2x2 图像，3 个焦距位置
  let sharpness_maps = [
    [0.1, 0.9, 0.2, 0.1],
    [0.5, 0.1, 0.8, 0.3],
    [0.2, 0.3, 0.4, 0.7],
  ]
  let focus_positions = [1.0, 5.0, 10.0]
  let depth = @cv_advanced.estimate_depth_from_focus(
    sharpness_maps, focus_positions, 2, 2,
  )
  assert_eq(depth.width, 2)
  assert_eq(depth.height, 2)
  // 像素0: 最清晰在位置1 (0.5) → depth=5.0
  assert_eq(depth.depths[0], 5.0)
  // 像素1: 最清晰在位置0 (0.9) → depth=1.0
  assert_eq(depth.depths[1], 1.0)
  // 像素2: 最清晰在位置1 (0.8) → depth=5.0
  assert_eq(depth.depths[2], 5.0)
  // 像素3: 最清晰在位置2 (0.7) → depth=10.0
  assert_eq(depth.depths[3], 10.0)
}

///|
test "estimate_depth_from_defocus: 基本测试" {
  let blur_map = [0.0, 0.1, 0.5, 1.0]
  let depth = @cv_advanced.estimate_depth_from_defocus(
    blur_map, 2, 2, 50.0, 8.0, 2.0,
  )
  assert_eq(depth.width, 2)
  assert_eq(depth.height, 2)
  assert_true(depth.valid[0])
  assert_true(depth.valid[1])
}

///|
test "estimate_depth_relative_blur: 基本测试" {
  let near_image = [0.9, 0.3, 0.8, 0.2]
  let far_image = [0.2, 0.8, 0.3, 0.9]
  let depth = @cv_advanced.estimate_depth_relative_blur(
    near_image, far_image, 2, 2, 1.0, 10.0,
  )
  assert_eq(depth.width, 2)
  assert_eq(depth.height, 2)
  // 像素0: near > far → 近处
  assert_true(depth.depths[0] < 5.5)
  // 像素1: far > near → 远处
  assert_true(depth.depths[1] > 5.5)
}

///|
test "smooth_depth_map: 平滑后保持有效像素数" {
  let depth : @cv_advanced.DepthMap = {
    width: 3,
    height: 3,
    depths: [1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0],
    valid: [true, true, true, true, true, true, true, true, true],
  }
  let smoothed = @cv_advanced.smooth_depth_map(depth, 1)
  assert_eq(smoothed.width, 3)
  assert_eq(smoothed.height, 3)
  let mut valid_count = 0
  for i in 0..<9 {
    if smoothed.valid[i] {
      valid_count = valid_count + 1
    }
  }
  assert_eq(valid_count, 9)
}

///|
test "fill_depth_holes: 填充空洞" {
  let depth : @cv_advanced.DepthMap = {
    width: 3,
    height: 3,
    depths: [1.0, 0.0, 3.0, 0.0, 5.0, 0.0, 7.0, 0.0, 9.0],
    valid: [true, false, true, false, true, false, true, false, true],
  }
  let filled = @cv_advanced.fill_depth_holes(depth)
  let mut valid_count = 0
  for i in 0..<9 {
    if filled.valid[i] {
      valid_count = valid_count + 1
    }
  }
  // 填充后所有像素应有效
  assert_eq(valid_count, 9)
}

///|
test "normalize_depth_map: 归一化到 [0,1]" {
  let depth : @cv_advanced.DepthMap = {
    width: 2,
    height: 2,
    depths: [10.0, 20.0, 30.0, 40.0],
    valid: [true, true, true, true],
  }
  let norm = @cv_advanced.normalize_depth_map(depth)
  assert_eq(norm.depths[0], 0.0)
  assert_eq(norm.depths[3], 1.0)
  assert_true((norm.depths[1] - 0.3333333333333333).abs() < 0.000000000000001)
  assert_true((norm.depths[2] - 0.6666666666666667).abs() < 0.000000000000001)
}

///|
test "compute_depth_of_field: 光学公式" {
  // f=50mm, N=2.8, s=2000mm, c=0.02mm
  let dof = @cv_advanced.compute_depth_of_field(50.0, 2.8, 2000.0, 0.02)
  assert_true(dof.near > 0.0)
  assert_true(dof.far > dof.near)
  assert_eq(dof.focal_plane, 2000.0)
  assert_true(dof.hyperfocal > 0.0)
}

///|
test "depth_to_grayscale_image: 转换为图像" {
  let depth : @cv_advanced.DepthMap = {
    width: 2,
    height: 1,
    depths: [0.0, 10.0],
    valid: [true, true],
  }
  let img = @cv_advanced.depth_to_grayscale_image(depth)
  assert_eq(img.width, 2)
  assert_eq(img.height, 1)
  assert_eq(img.channels, 1)
  assert_eq(img.data.length(), 2)
}

///|
test "depth_post_process: 完整后处理流水线" {
  let depth : @cv_advanced.DepthMap = {
    width: 3,
    height: 3,
    depths: [5.0, 0.0, 8.0, 0.0, 6.0, 0.0, 3.0, 0.0, 7.0],
    valid: [true, false, true, false, true, false, true, false, true],
  }
  let params : @cv_advanced.DepthPostProcessParams = {
    smooth_radius: 1,
    fill_holes: true,
    normalize: true,
    edge_refine: false,
    min_depth: 0.0,
    max_depth: 0.0,
  }
  let result = @cv_advanced.depth_post_process(depth, params)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  // 归一化后所有值在 [0, 1]
  for i in 0..<9 {
    if result.valid[i] {
      assert_true(result.depths[i] >= 0.0)
      assert_true(result.depths[i] <= 1.0)
    }
  }
}

///|
test "DepthOfFieldRange: 构造与字段" {
  let r : @cv_advanced.DepthOfFieldRange = {
    near: 1.5,
    far: 5.0,
    focal_plane: 2.0,
    hyperfocal: 10.0,
  }
  assert_eq(r.near, 1.5)
  assert_eq(r.far, 5.0)
  assert_eq(r.focal_plane, 2.0)
  assert_eq(r.hyperfocal, 10.0)
}
