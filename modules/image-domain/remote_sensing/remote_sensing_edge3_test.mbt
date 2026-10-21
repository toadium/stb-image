// remote_sensing 第三轮错误路径测试：第二/三参数错误 + 尺寸不匹配

///|
fn rs3_img(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for i in 0..<(w * h * ch) {
    data[i] = ((i * 137 + 42) % 256).to_byte()
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn rs3_bad(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  @types.Image::{ width: w, height: h, channels: ch, data: b"\x00\x01\x02", }
}

// ========== compute_ndvi 第二参数错误 ==========

///|
test "rs4: compute_ndvi red零宽度 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(0, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndvi(nir, red)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndvi red数据不匹配 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_bad(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndvi(nir, red)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndvi 尺寸不匹配返回nir" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(10, 8, 1)
  let result = @remote_sensing.compute_ndvi(nir, red)
  assert_eq(result.width, 8)
}

// ========== compute_ndwi 第二参数错误 ==========

///|
test "rs4: compute_ndwi nir零宽度 raise" {
  let green = rs3_img(8, 8, 1)
  let nir = rs3_img(0, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndwi(green, nir)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndwi nir无效通道 raise" {
  let green = rs3_img(8, 8, 1)
  let nir = rs3_img(8, 8, 0)
  try {
    let _ = @remote_sensing.compute_ndwi(green, nir)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndwi nir数据不匹配 raise" {
  let green = rs3_img(8, 8, 1)
  let nir = rs3_bad(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndwi(green, nir)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndwi 尺寸不匹配返回green" {
  let green = rs3_img(8, 8, 1)
  let nir = rs3_img(8, 10, 1)
  let result = @remote_sensing.compute_ndwi(green, nir)
  assert_eq(result.width, 8)
}

// ========== compute_ndbi 错误路径 ==========

///|
test "rs4: compute_ndbi swir数据不匹配 raise" {
  let swir = rs3_bad(8, 8, 1)
  let nir = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndbi(swir, nir)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndbi nir零宽度 raise" {
  let swir = rs3_img(8, 8, 1)
  let nir = rs3_img(0, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndbi(swir, nir)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndbi nir无效通道 raise" {
  let swir = rs3_img(8, 8, 1)
  let nir = rs3_img(8, 8, 5)
  try {
    let _ = @remote_sensing.compute_ndbi(swir, nir)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndbi nir数据不匹配 raise" {
  let swir = rs3_img(8, 8, 1)
  let nir = rs3_bad(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndbi(swir, nir)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_ndbi 尺寸不匹配返回swir" {
  let swir = rs3_img(8, 8, 1)
  let nir = rs3_img(10, 8, 1)
  let result = @remote_sensing.compute_ndbi(swir, nir)
  assert_eq(result.width, 8)
}

// ========== compute_evi 错误路径 ==========

///|
test "rs4: compute_evi nir无效通道 raise" {
  let nir = rs3_img(8, 8, 0)
  let red = rs3_img(8, 8, 1)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_evi nir数据不匹配 raise" {
  let nir = rs3_bad(8, 8, 1)
  let red = rs3_img(8, 8, 1)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_evi red零宽度 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(0, 8, 1)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_evi red无效通道 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(8, 8, 5)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_evi red数据不匹配 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_bad(8, 8, 1)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_evi blue零宽度 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(8, 8, 1)
  let blue = rs3_img(0, 8, 1)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: compute_evi 尺寸不匹配返回nir" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(10, 8, 1)
  let blue = rs3_img(8, 8, 1)
  let result = @remote_sensing.compute_evi(nir, red, blue)
  assert_eq(result.width, 8)
}

// ========== false_color_composite 错误路径 ==========

///|
test "rs4: false_color nir数据不匹配 raise" {
  let nir = rs3_bad(8, 8, 1)
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: false_color red零宽度 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(0, 8, 1)
  let green = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: false_color red无效通道 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(8, 8, 0)
  let green = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: false_color red数据不匹配 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_bad(8, 8, 1)
  let green = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: false_color green零宽度 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(0, 8, 1)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: false_color green无效通道 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(8, 8, 5)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: false_color green数据不匹配 raise" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(8, 8, 1)
  let green = rs3_bad(8, 8, 1)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: false_color 尺寸不匹配返回nir" {
  let nir = rs3_img(8, 8, 1)
  let red = rs3_img(10, 8, 1)
  let green = rs3_img(8, 8, 1)
  let result = @remote_sensing.false_color_composite(nir, red, green)
  assert_eq(result.width, 8)
}

// ========== true_color_composite 错误路径 ==========

///|
test "rs4: true_color red数据不匹配 raise" {
  let red = rs3_bad(8, 8, 1)
  let green = rs3_img(8, 8, 1)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: true_color green零宽度 raise" {
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(0, 8, 1)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: true_color green无效通道 raise" {
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(8, 8, 0)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: true_color green数据不匹配 raise" {
  let red = rs3_img(8, 8, 1)
  let green = rs3_bad(8, 8, 1)
  let blue = rs3_img(8, 8, 1)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: true_color blue零宽度 raise" {
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(8, 8, 1)
  let blue = rs3_img(0, 8, 1)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: true_color blue无效通道 raise" {
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(8, 8, 1)
  let blue = rs3_img(8, 8, 5)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: true_color blue数据不匹配 raise" {
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(8, 8, 1)
  let blue = rs3_bad(8, 8, 1)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "rs4: true_color 尺寸不匹配返回red" {
  let red = rs3_img(8, 8, 1)
  let green = rs3_img(10, 8, 1)
  let blue = rs3_img(8, 8, 1)
  let result = @remote_sensing.true_color_composite(red, green, blue)
  assert_eq(result.width, 8)
}
