///|
test "night: 参数构建" {
  let params = @cv_advanced.night_build_params(
    @cv_advanced.NightShotMode::Temporal,
  )
  assert_eq(params.brightness_boost, 1.5)
  let params2 = @cv_advanced.night_build_params(
    @cv_advanced.NightShotMode::Hybrid,
    brightness_boost=2.0,
  )
  assert_eq(params2.brightness_boost, 2.0)
}

///|
test "night: 时域降噪" {
  let img1 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 110, 90, 105]),
  }
  let img2 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([108, 102, 98, 100]),
  }
  let denoised = @cv_advanced.night_temporal_denoise([img1, img2])
  assert_eq(denoised.width, 2)
  assert_eq(denoised.height, 2)
}

///|
test "night: 运动检测" {
  let ref_img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let cur : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 200, 100, 100]),
  }
  let motion = @cv_advanced.night_detect_motion(ref_img, cur, 0.3)
  assert_eq(motion.length(), 4)
}

///|
test "night: 亮度增强" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let enhanced = @cv_advanced.night_enhance_brightness(img, 2.0)
  assert_eq(enhanced.width, 1)
  assert_true(enhanced.data[0].to_int() > 50)
}

///|
test "night: 对比度增强" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([128]),
  }
  let enhanced = @cv_advanced.night_enhance_contrast(img, 1.5)
  assert_eq(enhanced.data[0], 128)
}

///|
test "night: 色彩校正" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([100, 100, 100]),
  }
  let corrected = @cv_advanced.night_correct_color(img)
  assert_eq(corrected.channels, 3)
}

///|
test "night: 流水线" {
  let img1 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (80 : Byte))),
  }
  let img2 : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (85 : Byte))),
  }
  let params = @cv_advanced.night_build_params(
    @cv_advanced.NightShotMode::Temporal,
  )
  let result = @cv_advanced.night_pipeline([img1, img2], params)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.channels, 3)
}

///|
test "night: 噪声估计" {
  let img : @types.Image = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, (128 : Byte))),
  }
  let noise = @cv_advanced.night_estimate_noise(img)
  assert_true(noise >= 0.0)
}

///|
test "night: 单图流水线" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let params = @cv_advanced.night_build_params(
    @cv_advanced.NightShotMode::Temporal,
  )
  let result = @cv_advanced.night_pipeline([img], params)
  assert_eq(result.width, 1)
  assert_eq(result.height, 1)
}
