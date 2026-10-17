// v223: frequency 模块边界/错误路径测试

///|
fn fe_bad_channels() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 2,
    data: Bytes::from_array(Array::make(32, 0)),
  }
}

///|
fn fe_bad_channels_16() -> @types.Image16 {
  @types.Image16::{
    width: 4,
    height: 4,
    channels: 2,
    data: Bytes::from_array(Array::make(64, 0)),
  }
}

///|
fn fe_bad_channels_f() -> @types.ImageF {
  @types.ImageF::{
    width: 4,
    height: 4,
    channels: 2,
    data: Bytes::from_array(Array::make(128, 0)),
  }
}

///|
fn fe_uniform(w : Int, h : Int, v : Int) -> @types.Image {
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
test "fe_edge: fft_2d 无效通道" {
  try {
    let _ = @frequency.fft_2d(fe_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: fft_2d_16 无效通道" {
  try {
    let _ = @frequency.fft_2d_16(fe_bad_channels_16())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: fft_2d_f 无效通道" {
  try {
    let _ = @frequency.fft_2d_f(fe_bad_channels_f())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: freq_filter 无效通道" {
  try {
    let _ = @frequency.freq_filter(
      fe_bad_channels(),
      @frequency.FreqFilterType::LowPass,
      10.0F,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: freq_filter_gaussian 无效通道" {
  try {
    let _ = @frequency.freq_filter_gaussian(
      fe_bad_channels(),
      @frequency.FreqFilterType::LowPass,
      10.0F,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_transform_2d 无效通道" {
  try {
    let _ = @frequency.haar_transform_2d(fe_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_transform_2d levels < 1" {
  try {
    let _ = @frequency.haar_transform_2d(fe_uniform(4, 4, 128), levels=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_transform_2d levels > 10" {
  try {
    let _ = @frequency.haar_transform_2d(fe_uniform(4, 4, 128), levels=11)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_denoise 无效通道" {
  try {
    let _ = @frequency.haar_denoise(fe_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_denoise levels < 1" {
  try {
    let _ = @frequency.haar_denoise(fe_uniform(4, 4, 128), levels=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_denoise levels > 10" {
  try {
    let _ = @frequency.haar_denoise(fe_uniform(4, 4, 128), levels=11)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_transform_2d_16 无效通道" {
  try {
    let _ = @frequency.haar_transform_2d_16(fe_bad_channels_16())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_denoise_16 无效通道" {
  try {
    let _ = @frequency.haar_denoise_16(fe_bad_channels_16())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_transform_2d_f 无效通道" {
  try {
    let _ = @frequency.haar_transform_2d_f(fe_bad_channels_f())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: haar_denoise_f 无效通道" {
  try {
    let _ = @frequency.haar_denoise_f(fe_bad_channels_f())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
