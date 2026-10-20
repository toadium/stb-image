///|
test "hdr_plus: 参数构建" {
  let params = @cv_advanced.hdr_plus_build_params(
    @cv_advanced.HdrPlusMode::Mertens,
  )
  assert_eq(params.num_pyramid_levels, 5)
  let params2 = @cv_advanced.hdr_plus_build_params(
    @cv_advanced.HdrPlusMode::DeGhost,
    ghost_threshold=0.5,
  )
  assert_eq(params2.ghost_threshold, 0.5)
}

///|
test "hdr_plus: 鬼影检测" {
  let ref_img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let other : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 200, 100, 100]),
  }
  let ghost = @cv_advanced.hdr_plus_detect_ghost(ref_img, other, 0.3)
  assert_eq(ghost.width, 2)
  assert_eq(ghost.height, 2)
  assert_eq(ghost.mask.length(), 4)
}

///|
test "hdr_plus: 鬼影掩码应用" {
  let ref_img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let other : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let ghost = @cv_advanced.GhostMap::{ width: 1, height: 1, mask: [true], }
  let result = @cv_advanced.hdr_plus_apply_ghost_map(ref_img, other, ghost)
  assert_eq(result.data[0], 100)
}

///|
test "hdr_plus: Mertens 融合" {
  let img1 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (50 : Byte))),
  }
  let img2 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (200 : Byte))),
  }
  let fused = @cv_advanced.hdr_plus_mertens_fusion([img1, img2])
  assert_eq(fused.width, 2)
  assert_eq(fused.height, 2)
  assert_eq(fused.channels, 3)
}

///|
test "hdr_plus: 加权合并" {
  let img1 : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([100, 100, 100]),
  }
  let img2 : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([200, 200, 200]),
  }
  let merged = @cv_advanced.hdr_plus_weighted_merge([img1, img2], [0.0, 1.0])
  assert_eq(merged.width, 1)
  assert_eq(merged.channels, 3)
}

///|
test "hdr_plus: 响应曲线标定" {
  let img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 200, 50]),
  }
  let curve = @cv_advanced.hdr_plus_calibrate_response([img], [0.0])
  assert_eq(curve.length(), 256)
}

///|
test "hdr_plus: 流水线" {
  let img1 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (100 : Byte))),
  }
  let img2 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (150 : Byte))),
  }
  let params = @cv_advanced.hdr_plus_build_params(
    @cv_advanced.HdrPlusMode::Mertens,
  )
  let result = @cv_advanced.hdr_plus_pipeline([img1, img2], params)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.channels, 3)
}

///|
test "hdr_plus: 曝光估计" {
  let img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([128, 128, 128, 128]),
  }
  let exp = @cv_advanced.hdr_plus_estimate_exposure(img)
  assert_true(exp < 0.0)
}

///|
test "hdr_plus: 单图流水线直接返回" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([128]),
  }
  let params = @cv_advanced.hdr_plus_build_params(
    @cv_advanced.HdrPlusMode::Weighted,
  )
  let result = @cv_advanced.hdr_plus_pipeline([img], params)
  assert_eq(result.data[0], 128)
}
