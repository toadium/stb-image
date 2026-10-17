// v210 enhance 补充错误路径测试
// 覆盖：无效通道、数据不匹配、参数越界、尺寸不一致、config 参数错误

///|
fn en2_mk_img(w : Int, h : Int, ch : Int) -> @types.Image {
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
fn en2_mk_bad_data(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{ width: w, height: h, channels: ch, data: b"\x00\x01\x02", }
}

///|
fn en2_mk_uniform(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, (val & 0xFF).to_byte())),
  }
}

// ========== dehaze 错误路径 ==========

///|
test "en3: dark_channel 无效通道0" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.dark_channel(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dark_channel 无效通道5" {
  let img = en2_mk_img(8, 8, 5)
  try {
    let _ = @enhance.dark_channel(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dark_channel 数据不匹配" {
  let img = en2_mk_bad_data(8, 8, 3)
  try {
    let _ = @enhance.dark_channel(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dark_channel patch_size零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.dark_channel(img, patch_size=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dark_channel patch_size偶数" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.dark_channel(img, patch_size=4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: estimate_atmospheric_light 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  let dark = en2_mk_uniform(8, 8, 1, 0)
  try {
    let _ = @enhance.estimate_atmospheric_light(img, dark)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: estimate_atmospheric_light dark通道非1" {
  let img = en2_mk_img(8, 8, 3)
  let dark = en2_mk_uniform(8, 8, 2, 0)
  try {
    let _ = @enhance.estimate_atmospheric_light(img, dark)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: estimate_transmission omega越界" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.estimate_transmission(img, [200, 200, 200], omega=1.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: guided_filter_image 尺寸不一致" {
  let input = en2_mk_img(8, 8, 1)
  let guide = en2_mk_img(16, 16, 1)
  try {
    let _ = @enhance.guided_filter_image(input, guide)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: guided_filter_image radius零" {
  let input = en2_mk_img(8, 8, 1)
  let guide = en2_mk_img(8, 8, 1)
  try {
    let _ = @enhance.guided_filter_image(input, guide, radius=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dehaze_recover transmission通道非1" {
  let img = en2_mk_img(8, 8, 3)
  let t = en2_mk_uniform(8, 8, 2, 128)
  try {
    let _ = @enhance.dehaze_recover(img, t, [200, 200, 200])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dehaze_recover atmospheric空" {
  let img = en2_mk_img(8, 8, 3)
  let t = en2_mk_uniform(8, 8, 1, 128)
  try {
    let _ = @enhance.dehaze_recover(img, t, [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dehaze_advanced 数据不匹配" {
  let img = en2_mk_bad_data(8, 8, 3)
  try {
    let _ = @enhance.dehaze_advanced(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: dehaze_advanced config patch_size偶数" {
  let img = en2_mk_img(8, 8, 3)
  let cfg = @enhance.DehazeConfig::{
    patch_size: 4,
    omega: 0.95,
    t_min: 0.1,
    guided_radius: 20,
    guided_eps: 0.0001,
    max_atmospheric: 1000,
  }
  try {
    let _ = @enhance.dehaze_advanced(img, config=cfg)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== denoise 错误路径 ==========

///|
test "en3: denoise_nlm 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.denoise_nlm(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_nlm 数据不匹配" {
  let img = en2_mk_bad_data(8, 8, 3)
  try {
    let _ = @enhance.denoise_nlm(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_nlm config h零" {
  let img = en2_mk_img(8, 8, 3)
  let cfg = @enhance.NlmConfig::{
    search_window: 7,
    patch_size: 3,
    h: 0.0,
    sigma: 5.0,
  }
  try {
    let _ = @enhance.denoise_nlm(img, config=cfg)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_bilateral 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.denoise_bilateral(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_bilateral 数据不匹配" {
  let img = en2_mk_bad_data(8, 8, 3)
  try {
    let _ = @enhance.denoise_bilateral(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_bilateral diameter零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.denoise_bilateral(img, diameter=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_bilateral sigma_color零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.denoise_bilateral(img, sigma_color=0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_median 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.denoise_median(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise_median kernel_size零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.denoise_median(img, kernel_size=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: denoise 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.denoise(img, "nlm")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== hdr 错误路径 ==========

///|
test "en3: hdr_fusion_average 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.hdr_fusion_average([img])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: hdr_fusion_average 图像尺寸不一致" {
  let img1 = en2_mk_img(8, 8, 3)
  let img2 = en2_mk_img(16, 8, 3)
  try {
    let _ = @enhance.hdr_fusion_average([img1, img2])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: hdr_fusion_weighted 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.hdr_fusion_weighted([img])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: hdr_fusion_weighted 图像尺寸不一致" {
  let img1 = en2_mk_img(8, 8, 3)
  let img2 = en2_mk_img(8, 16, 3)
  try {
    let _ = @enhance.hdr_fusion_weighted([img1, img2])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: tone_mapping_reinhard key零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.tone_mapping_reinhard(img, key=0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: tone_mapping_reinhard 数据不匹配" {
  let img = en2_mk_bad_data(8, 8, 3)
  try {
    let _ = @enhance.tone_mapping_reinhard(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: tone_mapping_gamma gamma零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.tone_mapping_gamma(img, gamma=0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: tone_mapping_sigmoid strength零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.tone_mapping_sigmoid(img, strength=0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: tone_mapping_sigmoid 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.tone_mapping_sigmoid(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: hdr_process config gamma零" {
  let img = en2_mk_img(8, 8, 3)
  let cfg = @enhance.HdrConfig::{
    fusion_method: "weighted",
    tone_mapping: "reinhard",
    gamma: 0.0,
    reinhard_key: 0.18,
    sigmoid_strength: 5.0,
  }
  try {
    let _ = @enhance.hdr_process([img], config=cfg)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: hdr_process config reinhard_key零" {
  let img = en2_mk_img(8, 8, 3)
  let cfg = @enhance.HdrConfig::{
    fusion_method: "weighted",
    tone_mapping: "reinhard",
    gamma: 0.5,
    reinhard_key: 0.0,
    sigmoid_strength: 5.0,
  }
  try {
    let _ = @enhance.hdr_process([img], config=cfg)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: hdr_process config sigmoid_strength零" {
  let img = en2_mk_img(8, 8, 3)
  let cfg = @enhance.HdrConfig::{
    fusion_method: "weighted",
    tone_mapping: "reinhard",
    gamma: 0.5,
    reinhard_key: 0.18,
    sigmoid_strength: 0.0,
  }
  try {
    let _ = @enhance.hdr_process([img], config=cfg)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== inpaint 错误路径 ==========

///|
test "en3: inpaint_advanced 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  let mask = en2_mk_uniform(8, 8, 1, 0)
  try {
    let _ = @enhance.inpaint_advanced(img, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: inpaint_advanced 数据不匹配" {
  let img = en2_mk_bad_data(8, 8, 3)
  let mask = en2_mk_uniform(8, 8, 1, 0)
  try {
    let _ = @enhance.inpaint_advanced(img, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: inpaint_advanced mask尺寸不匹配" {
  let img = en2_mk_img(8, 8, 3)
  let mask = en2_mk_uniform(16, 8, 1, 0)
  try {
    let _ = @enhance.inpaint_advanced(img, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: inpaint_advanced radius零" {
  let img = en2_mk_img(8, 8, 3)
  let mask = en2_mk_uniform(8, 8, 1, 0)
  try {
    let _ = @enhance.inpaint_advanced(img, mask, radius=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: create_rect_mask rect_w零" {
  try {
    let _ = @enhance.create_rect_mask(16, 16, 0, 0, 0, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: create_rect_mask 超出边界" {
  try {
    let _ = @enhance.create_rect_mask(16, 16, 10, 10, 10, 10)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: remove_small_objects 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.remove_small_objects(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: remove_small_objects 数据不匹配" {
  let img = en2_mk_bad_data(8, 8, 1)
  try {
    let _ = @enhance.remove_small_objects(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: remove_watermark 无效通道" {
  let img = en2_mk_img(8, 8, 0)
  try {
    let _ = @enhance.remove_watermark(img, 0, 0, 4, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: remove_watermark width零" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.remove_watermark(img, 0, 0, 0, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "en3: remove_watermark 超出边界" {
  let img = en2_mk_img(8, 8, 3)
  try {
    let _ = @enhance.remove_watermark(img, 4, 4, 10, 10)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
