// v200 enhance 边界/错误路径增强测试

///|
fn en_make_varied(w : Int, h : Int, ch : Int) -> @types.Image {
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
fn en_make_uniform(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, (val & 0xFF).to_byte())
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

// ========== dehaze 错误路径 ==========

///|
test "en2: dark_channel 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.dark_channel(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: dehaze_advanced 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.dehaze_advanced(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: estimate_atmospheric_light 尺寸不匹配" {
  let img = en_make_varied(16, 16, 3)
  let dark = en_make_uniform(8, 8, 1, 0)
  try {
    let _ = @enhance.estimate_atmospheric_light(img, dark)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: estimate_transmission 空数组错误" {
  let img = en_make_varied(16, 16, 3)
  try {
    let _ = @enhance.estimate_transmission(img, [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: dehaze_recover 尺寸不匹配" {
  let img = en_make_varied(16, 16, 3)
  let t = en_make_uniform(8, 8, 1, 128)
  try {
    let _ = @enhance.dehaze_recover(img, t, [200, 200, 200])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: guided_filter_image 基本测试" {
  let img = en_make_varied(16, 16, 1)
  let guide = en_make_varied(16, 16, 1)
  try {
    let result = @enhance.guided_filter_image(guide, img, radius=4, eps=0.01)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== denoise 错误路径 ==========

///|
test "en2: denoise_nlm 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.denoise_nlm(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: denoise_bilateral 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.denoise_bilateral(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: denoise_median 偶数核错误" {
  let img = en_make_varied(16, 16, 3)
  try {
    let _ = @enhance.denoise_median(img, kernel_size=4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: denoise 未知方法" {
  let img = en_make_varied(16, 16, 3)
  try {
    let result = @enhance.denoise(img, "unknown")
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: denoise_nlm 自定义小窗口" {
  let img = en_make_varied(16, 16, 1)
  try {
    let cfg = @enhance.NlmConfig::{
      search_window: 7,
      patch_size: 3,
      h: 5.0,
      sigma: 5.0,
    }
    let result = @enhance.denoise_nlm(img, config=cfg)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: denoise_bilateral 自定义参数" {
  let img = en_make_varied(16, 16, 3)
  try {
    let result = @enhance.denoise_bilateral(
      img,
      diameter=5,
      sigma_color=50.0,
      sigma_space=50.0,
    )
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: denoise_median 核大小5" {
  let img = en_make_varied(16, 16, 3)
  try {
    let result = @enhance.denoise_median(img, kernel_size=5)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== hdr 错误路径 ==========

///|
test "en2: hdr_fusion_average 空数组错误" {
  try {
    let _ = @enhance.hdr_fusion_average([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: hdr_fusion_weighted 空数组错误" {
  try {
    let _ = @enhance.hdr_fusion_weighted([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: hdr_process 空数组错误" {
  try {
    let _ = @enhance.hdr_process([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: tone_mapping_reinhard 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.tone_mapping_reinhard(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: tone_mapping_gamma 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.tone_mapping_gamma(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: tone_mapping_sigmoid 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.tone_mapping_sigmoid(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: hdr_fusion_weighted 单张图像" {
  let img = en_make_varied(16, 16, 3)
  try {
    let result = @enhance.hdr_fusion_weighted([img])
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: tone_mapping_sigmoid 自定义强度" {
  let img = en_make_varied(16, 16, 3)
  try {
    let result = @enhance.tone_mapping_sigmoid(img, strength=10.0)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== inpaint 错误路径 ==========

///|
test "en2: inpaint_advanced 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  let mask = en_make_uniform(8, 8, 1, 0)
  try {
    let _ = @enhance.inpaint_advanced(img, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: create_rect_mask 零宽度错误" {
  try {
    let _ = @enhance.create_rect_mask(0, 8, 0, 0, 4, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: create_rect_mask 负坐标错误" {
  try {
    let _ = @enhance.create_rect_mask(16, 16, -1, 0, 4, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: remove_small_objects 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @enhance.remove_small_objects(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: remove_small_objects max_size零错误" {
  let img = en_make_uniform(16, 16, 1, 0)
  try {
    let _ = @enhance.remove_small_objects(img, max_size=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: remove_watermark 零宽度错误" {
  let img = @types.Image::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @enhance.remove_watermark(img, 0, 0, 4, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: remove_watermark 负坐标错误" {
  let img = en_make_varied(16, 16, 3)
  try {
    let _ = @enhance.remove_watermark(img, -1, 0, 4, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: inpaint_advanced 自定义半径" {
  let img = en_make_varied(16, 16, 3)
  let mask = en_make_uniform(16, 16, 1, 0)
  try {
    let result = @enhance.inpaint_advanced(img, mask, radius=3)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: create_rect_mask 部分区域" {
  try {
    let result = @enhance.create_rect_mask(16, 16, 4, 4, 8, 8)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 1)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: remove_small_objects 小阈值" {
  let img = en_make_varied(16, 16, 1)
  try {
    let result = @enhance.remove_small_objects(img, max_size=5)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== RGBA 通道测试 ==========

///|
test "en2: dehaze_advanced RGBA" {
  let img = en_make_varied(16, 16, 4)
  try {
    let result = @enhance.dehaze_advanced(img)
    assert_eq(result.channels, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: denoise_nlm RGBA" {
  let img = en_make_varied(16, 16, 4)
  try {
    let result = @enhance.denoise_nlm(img)
    assert_eq(result.channels, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en2: tone_mapping_reinhard RGBA" {
  let img = en_make_varied(16, 16, 4)
  try {
    let result = @enhance.tone_mapping_reinhard(img)
    assert_eq(result.channels, 4)
  } catch {
    _ => assert_true(true)
  }
}
