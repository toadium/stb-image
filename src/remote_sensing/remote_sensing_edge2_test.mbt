// v212 remote_sensing 补充错误路径测试
// 覆盖：无效通道、数据不匹配（已有测试仅覆盖零宽度）

///|
fn rs_mk_img(w : Int, h : Int, ch : Int) -> @types.Image {
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
fn rs_mk_bad_data(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{ width: w, height: h, channels: ch, data: b"\x00\x01\x02", }
}

// ========== compute_ndvi 错误路径 ==========

///|
test "rs3: compute_ndvi nir无效通道" {
  let nir = rs_mk_img(8, 8, 0)
  let red = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndvi(nir, red)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs3: compute_ndvi nir数据不匹配" {
  let nir = rs_mk_bad_data(8, 8, 1)
  let red = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndvi(nir, red)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs3: compute_ndvi red无效通道" {
  let nir = rs_mk_img(8, 8, 1)
  let red = rs_mk_img(8, 8, 0)
  try {
    let _ = @remote_sensing.compute_ndvi(nir, red)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== compute_ndwi 错误路径 ==========

///|
test "rs3: compute_ndwi green无效通道" {
  let green = rs_mk_img(8, 8, 0)
  let nir = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndwi(green, nir)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs3: compute_ndwi green数据不匹配" {
  let green = rs_mk_bad_data(8, 8, 1)
  let nir = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndwi(green, nir)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== compute_ndbi 错误路径 ==========

///|
test "rs3: compute_ndbi 无效通道" {
  let swir = rs_mk_img(8, 8, 0)
  let nir = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_ndbi(swir, nir)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== compute_evi 错误路径 ==========

///|
test "rs3: compute_evi blue无效通道" {
  let nir = rs_mk_img(8, 8, 1)
  let red = rs_mk_img(8, 8, 1)
  let blue = rs_mk_img(8, 8, 0)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs3: compute_evi blue数据不匹配" {
  let nir = rs_mk_img(8, 8, 1)
  let red = rs_mk_img(8, 8, 1)
  let blue = rs_mk_bad_data(8, 8, 1)
  try {
    let _ = @remote_sensing.compute_evi(nir, red, blue)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== false_color_composite 错误路径 ==========

///|
test "rs3: false_color_composite nir无效通道" {
  let nir = rs_mk_img(8, 8, 0)
  let red = rs_mk_img(8, 8, 1)
  let green = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.false_color_composite(nir, red, green)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== true_color_composite 错误路径 ==========

///|
test "rs3: true_color_composite 无效通道" {
  let r = rs_mk_img(8, 8, 0)
  let g = rs_mk_img(8, 8, 1)
  let b = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.true_color_composite(r, g, b)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== vegetation_coverage 错误路径 ==========

///|
test "rs3: vegetation_coverage 无效通道" {
  let img = rs_mk_img(8, 8, 0)
  try {
    let _ = @remote_sensing.vegetation_coverage(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs3: vegetation_coverage 数据不匹配" {
  let img = rs_mk_bad_data(8, 8, 1)
  try {
    let _ = @remote_sensing.vegetation_coverage(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== land_cover_classification 错误路径 ==========

///|
test "rs3: land_cover_classification 无效通道" {
  let ndvi = rs_mk_img(8, 8, 0)
  let ndwi = rs_mk_img(8, 8, 1)
  let ndbi = rs_mk_img(8, 8, 1)
  try {
    let _ = @remote_sensing.land_cover_classification(ndvi, ndwi, ndbi)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== classification_colormap 错误路径 ==========

///|
test "rs3: classification_colormap 无效通道" {
  let img = rs_mk_img(8, 8, 0)
  try {
    let _ = @remote_sensing.classification_colormap(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== calculate_texture_features 错误路径 ==========

///|
test "rs3: calculate_texture_features 无效通道" {
  let img = rs_mk_img(8, 8, 0)
  try {
    let _ = @remote_sensing.calculate_texture_features(img, 0, 0, 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs3: calculate_texture_features 数据不匹配" {
  let img = rs_mk_bad_data(8, 8, 1)
  try {
    let _ = @remote_sensing.calculate_texture_features(img, 0, 0, 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
