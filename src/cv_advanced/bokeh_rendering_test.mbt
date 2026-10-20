///|
test "ApertureShape: 枚举值" {
  assert_true(@cv_advanced.ApertureShape::Circular is @cv_advanced.Circular)
  assert_true(@cv_advanced.ApertureShape::Hexagonal is @cv_advanced.Hexagonal)
  assert_true(@cv_advanced.ApertureShape::Octagonal is @cv_advanced.Octagonal)
  assert_true(@cv_advanced.ApertureShape::CatEye is @cv_advanced.CatEye)
}

///|
test "BokehQuality: 枚举值" {
  assert_true(@cv_advanced.BokehQuality::Fast is @cv_advanced.Fast)
  assert_true(@cv_advanced.BokehQuality::Medium is @cv_advanced.Medium)
  assert_true(@cv_advanced.BokehQuality::High is @cv_advanced.High)
}

///|
test "BokehParams: 构造与字段" {
  let p : @cv_advanced.BokehParams = {
    aperture_shape: @cv_advanced.Circular,
    aperture_f_number: 1.4,
    focal_length: 85.0,
    focus_distance: 1000.0,
    blur_strength: 2.0,
    quality: @cv_advanced.High,
    circle_of_confusion: 0.03,
  }
  assert_eq(p.aperture_f_number, 1.4)
  assert_eq(p.focal_length, 85.0)
  assert_eq(p.focus_distance, 1000.0)
  assert_eq(p.blur_strength, 2.0)
  assert_true(p.aperture_shape is @cv_advanced.Circular)
  assert_true(p.quality is @cv_advanced.High)
}

///|
test "compute_circle_of_confusion: 对焦平面处为0" {
  // 物体在对焦距离处 → CoC = 0
  let coc = @cv_advanced.compute_circle_of_confusion(2000.0, 50.0, 2.8, 2000.0)
  assert_true(coc.abs() < 0.001)
}

///|
test "compute_circle_of_confusion: 离焦处非零" {
  // 物体远离对焦距离 → CoC > 0
  let coc = @cv_advanced.compute_circle_of_confusion(2000.0, 50.0, 2.8, 5000.0)
  assert_true(coc > 0.0)
}

///|
test "compute_circle_of_confusion: 零距离返回零" {
  let coc = @cv_advanced.compute_circle_of_confusion(2000.0, 50.0, 2.8, 0.0)
  assert_eq(coc, 0.0)
}

///|
test "generate_aperture_mask: 圆形掩模" {
  let mask = @cv_advanced.generate_aperture_mask(@cv_advanced.Circular, 2)
  assert_eq(mask.length(), 5)
  assert_eq(mask[0].length(), 5)
  // 中心点应为1
  assert_eq(mask[2][2], 1.0)
  // 角落应为0
  assert_eq(mask[0][0], 0.0)
}

///|
test "generate_aperture_mask: 六边形掩模" {
  let mask = @cv_advanced.generate_aperture_mask(@cv_advanced.Hexagonal, 3)
  assert_eq(mask.length(), 7)
  assert_eq(mask[3][3], 1.0)
}

///|
test "generate_aperture_mask: 零半径返回空" {
  let mask = @cv_advanced.generate_aperture_mask(@cv_advanced.Circular, 0)
  assert_eq(mask.length(), 0)
}

///|
test "compute_blur_map: 基本测试" {
  let depth : @cv_advanced.DepthMap = {
    width: 2,
    height: 1,
    depths: [1000.0, 5000.0],
    valid: [true, true],
  }
  let blur = @cv_advanced.compute_blur_map(depth, 2000.0, 50.0, 2.8, 1.0)
  assert_eq(blur.length(), 2)
}

///|
test "bokeh_blur_circular: 零模糊返回原图" {
  let img : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200]),
  }
  let blur_map = [0.0, 0.0]
  let result = @cv_advanced.bokeh_blur_circular(img, blur_map, 5)
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  assert_eq(result.data[0], (100 : Byte))
  assert_eq(result.data[1], (200 : Byte))
}

///|
test "estimate_bokeh_strength: 均匀深度返回1" {
  let depth : @cv_advanced.DepthMap = {
    width: 2,
    height: 1,
    depths: [1000.0, 1000.0],
    valid: [true, true],
  }
  let strength = @cv_advanced.estimate_bokeh_strength(depth)
  assert_eq(strength, 1.0)
}

///|
test "estimate_bokeh_strength: 大范围深度返回较大值" {
  let depth : @cv_advanced.DepthMap = {
    width: 2,
    height: 1,
    depths: [100.0, 10000.0],
    valid: [true, true],
  }
  let strength = @cv_advanced.estimate_bokeh_strength(depth)
  assert_true(strength > 1.0)
}

///|
test "default_bokeh_params: 默认参数" {
  let p = @cv_advanced.default_bokeh_params(
    @cv_advanced.Circular,
    @cv_advanced.Medium,
  )
  assert_eq(p.aperture_f_number, 2.8)
  assert_eq(p.focal_length, 50.0)
  assert_eq(p.focus_distance, 2000.0)
  assert_eq(p.blur_strength, 1.0)
  assert_true(p.aperture_shape is @cv_advanced.Circular)
  assert_true(p.quality is @cv_advanced.Medium)
}

///|
test "simulate_lens_blur: 完整渲染" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      200, 200, 200, 200, 200, 100, 100, 200, 200, 100, 100, 200, 200, 200, 200,
      200,
    ]),
  }
  let depth : @cv_advanced.DepthMap = {
    width: 4,
    height: 4,
    depths: [
      5000.0, 5000.0, 5000.0, 5000.0, 5000.0, 1000.0, 1000.0, 5000.0, 5000.0, 1000.0,
      1000.0, 5000.0, 5000.0, 5000.0, 5000.0, 5000.0,
    ],
    valid: [
      true, true, true, true, true, true, true, true, true, true, true, true, true,
      true, true, true,
    ],
  }
  let params : @cv_advanced.BokehParams = {
    aperture_shape: @cv_advanced.Circular,
    aperture_f_number: 2.8,
    focal_length: 50.0,
    focus_distance: 1000.0,
    blur_strength: 1.0,
    quality: @cv_advanced.Fast,
    circle_of_confusion: 0.02,
  }
  let result = @cv_advanced.simulate_lens_blur(img, depth, params)
  assert_eq(result.image.width, 4)
  assert_eq(result.image.height, 4)
  assert_eq(result.image.channels, 1)
  assert_true(result.max_blur_radius > 0)
  assert_eq(result.blur_map.length(), 16)
}

///|
test "bokeh_pipeline: 流水线测试" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([100, 150, 200, 150, 200, 250, 200, 250, 255]),
  }
  let depth : @cv_advanced.DepthMap = {
    width: 3,
    height: 3,
    depths: [
      1000.0, 3000.0, 5000.0, 3000.0, 1000.0, 3000.0, 5000.0, 3000.0, 1000.0,
    ],
    valid: [true, true, true, true, true, true, true, true, true],
  }
  let params : @cv_advanced.BokehParams = {
    aperture_shape: @cv_advanced.Octagonal,
    aperture_f_number: 4.0,
    focal_length: 50.0,
    focus_distance: 2000.0,
    blur_strength: 0.0,
    quality: @cv_advanced.Fast,
    circle_of_confusion: 0.02,
  }
  let result = @cv_advanced.bokeh_pipeline(img, depth, params)
  assert_eq(result.image.width, 3)
  assert_eq(result.image.height, 3)
  assert_eq(result.image.channels, 1)
}

///|
test "BokehResult: 构造与字段" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([128]),
  }
  let r : @cv_advanced.BokehResult = {
    image: img,
    max_blur_radius: 10,
    blur_map: [0.5],
  }
  assert_eq(r.max_blur_radius, 10)
  assert_eq(r.blur_map.length(), 1)
  assert_eq(r.blur_map[0], 0.5)
}
