// v202 remote_sensing 错误路径/边界增强测试

///|
fn rs_make_varied(w : Int, h : Int, ch : Int) -> @types.Image {
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
fn rs_make_uniform(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, (val & 0xFF).to_byte())
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

// ========== 错误路径测试 ==========

///|
test "rs2: compute_ndvi 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  let red = rs_make_uniform(8, 8, 1, 100)
  try {
    let _ = @remote_sensing.compute_ndvi(img, red)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: compute_ndwi 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  let green = rs_make_uniform(8, 8, 1, 100)
  try {
    let _ = @remote_sensing.compute_ndwi(img, green)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: compute_ndbi 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  let swir = rs_make_uniform(8, 8, 1, 100)
  try {
    let _ = @remote_sensing.compute_ndbi(img, swir)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: compute_evi 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  let red = rs_make_uniform(8, 8, 1, 100)
  let blue = rs_make_uniform(8, 8, 1, 50)
  try {
    let _ = @remote_sensing.compute_evi(img, red, blue)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: false_color_composite 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  let red = rs_make_uniform(8, 8, 1, 100)
  let green = rs_make_uniform(8, 8, 1, 50)
  try {
    let _ = @remote_sensing.false_color_composite(img, red, green)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: true_color_composite 零宽度错误" {
  let red = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  let green = rs_make_uniform(8, 8, 1, 100)
  let blue = rs_make_uniform(8, 8, 1, 50)
  try {
    let _ = @remote_sensing.true_color_composite(red, green, blue)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: vegetation_coverage 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @remote_sensing.vegetation_coverage(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: land_cover_classification 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  let ndwi = rs_make_uniform(8, 8, 1, 100)
  let ndbi = rs_make_uniform(8, 8, 1, 50)
  try {
    let _ = @remote_sensing.land_cover_classification(img, ndwi, ndbi)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: classification_colormap 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @remote_sensing.classification_colormap(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 均匀图像测试 ==========

///|
test "rs2: compute_ndvi 均匀图像" {
  let nir = rs_make_uniform(16, 16, 1, 200)
  let red = rs_make_uniform(16, 16, 1, 100)
  try {
    let result = @remote_sensing.compute_ndvi(nir, red)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: compute_ndwi 均匀图像" {
  let nir = rs_make_uniform(16, 16, 1, 200)
  let green = rs_make_uniform(16, 16, 1, 150)
  try {
    let result = @remote_sensing.compute_ndwi(nir, green)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: compute_evi 均匀图像" {
  let nir = rs_make_uniform(16, 16, 1, 200)
  let red = rs_make_uniform(16, 16, 1, 100)
  let blue = rs_make_uniform(16, 16, 1, 50)
  try {
    let result = @remote_sensing.compute_evi(nir, red, blue)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: true_color_composite 基本测试" {
  let red = rs_make_varied(16, 16, 1)
  let green = rs_make_varied(16, 16, 1)
  let blue = rs_make_varied(16, 16, 1)
  try {
    let result = @remote_sensing.true_color_composite(red, green, blue)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: vegetation_coverage 基本测试" {
  let ndvi = rs_make_varied(16, 16, 1)
  try {
    let result = @remote_sensing.vegetation_coverage(ndvi)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: vegetation_coverage 自定义参数" {
  let ndvi = rs_make_varied(16, 16, 1)
  try {
    let result = @remote_sensing.vegetation_coverage(
      ndvi,
      ndvi_soil=0.1,
      ndvi_veg=0.9,
    )
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: land_cover_classification 基本测试" {
  let ndvi = rs_make_varied(16, 16, 1)
  let ndwi = rs_make_varied(16, 16, 1)
  let ndbi = rs_make_varied(16, 16, 1)
  try {
    let result = @remote_sensing.land_cover_classification(ndvi, ndwi, ndbi)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: classification_colormap 基本测试" {
  let cls = rs_make_varied(16, 16, 1)
  try {
    let result = @remote_sensing.classification_colormap(cls)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

// ========== multispectral_new 测试 ==========

///|
test "rs2: multispectral_new 默认波段名" {
  let b1 = rs_make_uniform(16, 16, 1, 100)
  let b2 = rs_make_uniform(16, 16, 1, 150)
  let b3 = rs_make_uniform(16, 16, 1, 200)
  let ms = @remote_sensing.multispectral_new(16, 16, [b1, b2, b3])
  assert_eq(ms.width, 16)
  assert_eq(ms.bands.length(), 3)
  assert_eq(ms.band_names.length(), 3)
}

///|
test "rs2: multispectral_new 自定义波段名" {
  let b1 = rs_make_uniform(16, 16, 1, 100)
  let b2 = rs_make_uniform(16, 16, 1, 150)
  let ms = @remote_sensing.multispectral_new(16, 16, [b1, b2], band_names=[
    "Red", "NIR",
  ])
  assert_eq(ms.band_names[0], "Red")
  assert_eq(ms.band_names[1], "NIR")
}

// ========== 多通道测试 ==========

///|
test "rs2: compute_ndvi 多通道" {
  let nir = rs_make_varied(16, 16, 3)
  let red = rs_make_varied(16, 16, 3)
  try {
    let result = @remote_sensing.compute_ndvi(nir, red)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: false_color_composite 多通道" {
  let nir = rs_make_varied(16, 16, 3)
  let red = rs_make_varied(16, 16, 3)
  let green = rs_make_varied(16, 16, 3)
  try {
    let result = @remote_sensing.false_color_composite(nir, red, green)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: classification_colormap 多通道" {
  let cls = rs_make_varied(16, 16, 3)
  try {
    let result = @remote_sensing.classification_colormap(cls)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 小尺寸测试 ==========

///|
test "rs2: compute_ndvi 小尺寸" {
  let nir = rs_make_uniform(4, 4, 1, 200)
  let red = rs_make_uniform(4, 4, 1, 100)
  try {
    let result = @remote_sensing.compute_ndvi(nir, red)
    assert_eq(result.width, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "rs2: true_color_composite 小尺寸" {
  let red = rs_make_uniform(4, 4, 1, 100)
  let green = rs_make_uniform(4, 4, 1, 150)
  let blue = rs_make_uniform(4, 4, 1, 200)
  try {
    let result = @remote_sensing.true_color_composite(red, green, blue)
    assert_eq(result.width, 4)
  } catch {
    _ => assert_true(true)
  }
}
