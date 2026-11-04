///|
test "MotionEstimationMethod: 枚举值" {
  assert_true(@video.FullSearch is @video.FullSearch)
  assert_true(@video.DiamondSearch is @video.DiamondSearch)
  assert_true(@video.HexSearch is @video.HexSearch)
  assert_true(@video.ThreeStep is @video.ThreeStep)
}

///|
test "MotionVector: 构造与字段" {
  let mv : @video.MotionVector = { dx: 3, dy: -2, sad: 150.0, }
  assert_eq(mv.dx, 3)
  assert_eq(mv.dy, -2)
  assert_eq(mv.sad, 150.0)
}

///|
test "SubpixelMotionVector: 构造与字段" {
  let mv : @video.SubpixelMotionVector = { dx: 1.5, dy: -0.5, sad: 80.0, }
  assert_eq(mv.dx, 1.5)
  assert_eq(mv.dy, -0.5)
  assert_eq(mv.sad, 80.0)
}

///|
test "SearchConfig: 构造与字段" {
  let config : @video.SearchConfig = {
    me_method: @video.FullSearch,
    block_size: 16,
    search_range: 32,
    subpixel_refinement: false,
  }
  assert_eq(config.block_size, 16)
  assert_eq(config.search_range, 32)
  assert_eq(config.subpixel_refinement, false)
  assert_true(config.me_method is @video.FullSearch)
}

///|
test "default_search_config: 默认值" {
  let config = @video.default_search_config()
  assert_eq(config.block_size, 8)
  assert_eq(config.search_range, 16)
  assert_eq(config.subpixel_refinement, true)
  assert_true(config.me_method is @video.DiamondSearch)
}

///|
test "estimate_motion_full_search: 相同帧零矢量" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let mv = @video.estimate_motion_full_search(img, img, 0, 0, 8, 4)
  assert_eq(mv.dx, 0)
  assert_eq(mv.dy, 0)
}

///|
test "estimate_motion_diamond: 相同帧零矢量" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let mv = @video.estimate_motion_diamond(img, img, 0, 0, 8, 4)
  assert_eq(mv.dx, 0)
  assert_eq(mv.dy, 0)
}

///|
test "estimate_motion_hex: 相同帧零矢量" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let mv = @video.estimate_motion_hex(img, img, 0, 0, 8, 4)
  assert_eq(mv.dx, 0)
  assert_eq(mv.dy, 0)
}

///|
test "estimate_motion_three_step: 相同帧零矢量" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let mv = @video.estimate_motion_three_step(img, img, 0, 0, 8, 4)
  assert_eq(mv.dx, 0)
  assert_eq(mv.dy, 0)
}

///|
test "refine_subpixel: 基本精化" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let mv : @video.MotionVector = { dx: 0, dy: 0, sad: 0.0, }
  let refined = @video.refine_subpixel(img, img, 0, 0, mv, 8)
  // 精化后应返回有效值
  assert_true(refined.dx >= -1.0 && refined.dx <= 1.0)
  assert_true(refined.dy >= -1.0 && refined.dy <= 1.0)
}

///|
test "compute_motion_field: 基本运动场" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let config = @video.default_search_config()
  let field = @video.compute_motion_field(img, img, config)
  // 8x8 图像，块大小 8，只有 1 个块
  assert_eq(field.length(), 1)
  assert_eq(field[0].dx, 0)
  assert_eq(field[0].dy, 0)
}

///|
test "motion_compensation: 基本补偿" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let field : Array[@video.MotionVector] = [{ dx: 0, dy: 0, sad: 0.0, }]
  let result = @video.motion_compensation(img, field, 8)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.data[0], 100)
}

///|
test "motion_estimate_and_compensate: 相同帧" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let config = @video.default_search_config()
  let result = @video.motion_estimate_and_compensate(img, img, config)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "average_motion_sad: 基本计算" {
  let field : Array[@video.MotionVector] = [
    { dx: 0, dy: 0, sad: 100.0, },
    { dx: 1, dy: 0, sad: 200.0, },
    { dx: 0, dy: 1, sad: 300.0, },
  ]
  let avg = @video.average_motion_sad(field)
  assert_eq(avg, 200.0)
}

///|
test "average_motion_sad: 空场" {
  let field : Array[@video.MotionVector] = []
  let avg = @video.average_motion_sad(field)
  assert_eq(avg, 0.0)
}

///|
test "zero_motion_ratio: 基本计算" {
  let field : Array[@video.MotionVector] = [
    { dx: 0, dy: 0, sad: 0.0, },
    { dx: 1, dy: 0, sad: 100.0, },
    { dx: 0, dy: 0, sad: 0.0, },
    { dx: 0, dy: 1, sad: 100.0, },
  ]
  let ratio = @video.zero_motion_ratio(field)
  assert_eq(ratio, 0.5)
}

///|
test "zero_motion_ratio: 全零" {
  let field : Array[@video.MotionVector] = [
    { dx: 0, dy: 0, sad: 0.0, },
    { dx: 0, dy: 0, sad: 0.0, },
  ]
  let ratio = @video.zero_motion_ratio(field)
  assert_eq(ratio, 1.0)
}

///|
test "zero_motion_ratio: 空场" {
  let field : Array[@video.MotionVector] = []
  let ratio = @video.zero_motion_ratio(field)
  assert_eq(ratio, 0.0)
}
