///|
test "raw: BayerPattern 通道索引" {
  assert_eq(
    @cv_advanced.bayer_channel_at(@cv_advanced.BayerPattern::RGGB, 0, 0),
    0,
  )
  assert_eq(
    @cv_advanced.bayer_channel_at(@cv_advanced.BayerPattern::RGGB, 1, 0),
    1,
  )
  assert_eq(
    @cv_advanced.bayer_channel_at(@cv_advanced.BayerPattern::RGGB, 0, 1),
    1,
  )
  assert_eq(
    @cv_advanced.bayer_channel_at(@cv_advanced.BayerPattern::RGGB, 1, 1),
    2,
  )
  assert_eq(
    @cv_advanced.bayer_channel_at(@cv_advanced.BayerPattern::BGGR, 0, 0),
    2,
  )
  assert_eq(
    @cv_advanced.bayer_channel_at(@cv_advanced.BayerPattern::BGGR, 1, 1),
    0,
  )
}

///|
test "raw: 解马赛克基本功能" {
  let raw : @types.Image = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      100, 120, 100, 120, 130, 80, 130, 80, 100, 120, 100, 120, 130, 80, 130, 80,
    ]),
  }
  let rgb = @cv_advanced.raw_demosaic_bilinear(
    raw,
    @cv_advanced.BayerPattern::RGGB,
  )
  assert_eq(rgb.width, 4)
  assert_eq(rgb.height, 4)
  assert_eq(rgb.channels, 3)
}

///|
test "raw: Bayer 抽取后解马赛克恢复宽高" {
  let img : @types.Image = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(48, (128 : Byte))),
  }
  let raw = @cv_advanced.raw_extract_bayer(img, @cv_advanced.BayerPattern::RGGB)
  assert_eq(raw.width, 4)
  assert_eq(raw.height, 4)
  assert_eq(raw.channels, 1)
  let recovered = @cv_advanced.raw_demosaic_bilinear(
    raw,
    @cv_advanced.BayerPattern::RGGB,
  )
  assert_eq(recovered.width, 4)
  assert_eq(recovered.height, 4)
  assert_eq(recovered.channels, 3)
}

///|
test "raw: 灰度世界白平衡" {
  let img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array([
      200, 100, 50, 200, 100, 50, 200, 100, 50, 200, 100, 50,
    ]),
  }
  let balanced = @cv_advanced.raw_white_balance_grayworld(img)
  assert_eq(balanced.width, 2)
  assert_eq(balanced.height, 2)
  assert_eq(balanced.channels, 3)
}

///|
test "raw: 手动白平衡" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([100, 100, 100]),
  }
  let balanced = @cv_advanced.raw_white_balance_manual(img, 2.0, 1.0, 0.5)
  assert_eq(balanced.data[0], 200)
  assert_eq(balanced.data[1], 100)
  assert_eq(balanced.data[2], 50)
}

///|
test "raw: 色彩校正单位矩阵" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([100, 150, 200]),
  }
  let identity = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
  let corrected = @cv_advanced.raw_color_correction(img, identity)
  assert_eq(corrected.data[0], 100)
  assert_eq(corrected.data[1], 150)
  assert_eq(corrected.data[2], 200)
}

///|
test "raw: 电平校正" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([128]),
  }
  let corrected = @cv_advanced.raw_level_correction(img, 0, 255)
  assert_eq(corrected.data[0], 128)
}

///|
test "raw: 流水线完整运行" {
  let raw : @types.Image = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, (128 : Byte))),
  }
  let params = @cv_advanced.raw_build_params(
    @cv_advanced.BayerPattern::RGGB,
    @cv_advanced.WhiteBalanceMethod::GrayWorld,
  )
  let result = @cv_advanced.raw_pipeline(raw, params)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 3)
}

///|
test "raw: 参数构建" {
  let params = @cv_advanced.raw_build_params(
    @cv_advanced.BayerPattern::GBRG,
    @cv_advanced.WhiteBalanceMethod::Manual,
    wb_r_gain=1.5,
    wb_g_gain=1.0,
    wb_b_gain=1.2,
    black_level=16,
    white_level=240,
  )
  assert_eq(params.wb_r_gain, 1.5)
  assert_eq(params.black_level, 16)
}
