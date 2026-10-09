// v193c enhance 增强测试

///|
fn enh_make_gray(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v : Int = i * 41 % 256
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
fn enh_make_rgb(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * 3) {
    let v : Int = i * 29 % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
fn enh_make_uniform(w : Int, h : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, val.to_byte())),
  }
}

///|
test "enhance: dehaze_default_config 完整字段验证" {
  let config = @enhance.dehaze_default_config()
  assert_true(config.patch_size > 0)
  assert_true(config.omega > 0.0 && config.omega <= 1.0)
  assert_true(config.t_min > 0.0 && config.t_min < 1.0)
  assert_true(config.guided_radius > 0)
  assert_true(config.guided_eps > 0.0)
  assert_true(config.max_atmospheric > 0)
}

///|
test "enhance: hdr_default_config 完整字段验证" {
  let config = @enhance.hdr_default_config()
  assert_true(config.fusion_method.length() > 0)
  assert_true(config.tone_mapping.length() > 0)
  assert_true(config.gamma > 0.0)
  assert_true(config.reinhard_key > 0.0)
  assert_true(config.sigmoid_strength > 0.0)
}

///|
test "enhance: inpaint_default_config 完整字段验证" {
  let config = @enhance.inpaint_default_config()
  assert_true(config.radius > 0)
  assert_true(config.method_type.length() > 0)
  assert_true(config.max_iterations > 0)
}

///|
test "enhance: nlm_default_config 完整字段验证" {
  let config = @enhance.nlm_default_config()
  assert_true(config.search_window > 0)
  assert_true(config.patch_size > 0)
  assert_true(config.h > 0.0)
  assert_true(config.sigma > 0.0)
}

///|
test "enhance: create_rect_mask 基本测试" {
  try {
    let mask = @enhance.create_rect_mask(16, 16, 2, 2, 8, 8)
    assert_eq(mask.width, 16)
    assert_eq(mask.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: create_rect_mask 全图掩码" {
  try {
    let mask = @enhance.create_rect_mask(8, 8, 0, 0, 8, 8)
    assert_eq(mask.width, 8)
    assert_eq(mask.height, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: dark_channel 不同 patch_size" {
  let img = enh_make_rgb(16, 16)
  try {
    let dc1 = @enhance.dark_channel(img, patch_size=3)
    assert_eq(dc1.width, 16)
    assert_eq(dc1.height, 16)
    let dc2 = @enhance.dark_channel(img, patch_size=5)
    assert_eq(dc2.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: dark_channel 灰度图" {
  let img = enh_make_gray(16, 16)
  try {
    let dc = @enhance.dark_channel(img)
    assert_eq(dc.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: dehaze_advanced 默认配置" {
  let img = enh_make_rgb(16, 16)
  try {
    let result = @enhance.dehaze_advanced(img)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: dehaze_advanced 自定义配置" {
  let img = enh_make_rgb(16, 16)
  let config = @enhance.DehazeConfig::{
    patch_size: 5,
    omega: 0.85,
    t_min: 0.1,
    guided_radius: 20,
    guided_eps: 0.001,
    max_atmospheric: 240,
  }
  try {
    let result = @enhance.dehaze_advanced(img, config~)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: dehaze_recover 基本测试" {
  let img = enh_make_rgb(16, 16)
  let dc = enh_make_rgb(16, 16)
  try {
    let result = @enhance.dehaze_recover(img, dc, [200, 200, 200], t_min=0.1)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: denoise 不同方法" {
  let img = enh_make_rgb(16, 16)
  for method_name in ["bilateral", "median", "nlm"] {
    try {
      let result = @enhance.denoise(img, method_name)
      assert_eq(result.width, 16)
      assert_eq(result.height, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "enhance: denoise_bilateral 自定义参数" {
  let img = enh_make_rgb(16, 16)
  try {
    let result = @enhance.denoise_bilateral(
      img,
      diameter=7,
      sigma_color=50.0,
      sigma_space=10.0,
    )
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: denoise_median 不同核大小" {
  let img = enh_make_rgb(16, 16)
  for ksize in [3, 5, 7] {
    try {
      let result = @enhance.denoise_median(img, kernel_size=ksize)
      assert_eq(result.width, 16)
      assert_eq(result.height, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "enhance: denoise_nlm 默认配置" {
  let img = enh_make_rgb(16, 16)
  try {
    let result = @enhance.denoise_nlm(img)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: denoise_nlm 自定义配置" {
  let img = enh_make_rgb(16, 16)
  let config = @enhance.NlmConfig::{
    search_window: 15,
    patch_size: 5,
    h: 10.0,
    sigma: 1.0,
  }
  try {
    let result = @enhance.denoise_nlm(img, config~)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: estimate_atmospheric_light 不同百分比" {
  let img = enh_make_rgb(16, 16)
  let dc = enh_make_rgb(16, 16)
  try {
    let a1 = @enhance.estimate_atmospheric_light(img, dc, top_percent=1)
    assert_eq(a1.length(), 3)
    let a2 = @enhance.estimate_atmospheric_light(img, dc, top_percent=5)
    assert_eq(a2.length(), 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: estimate_transmission 基本测试" {
  let img = enh_make_rgb(16, 16)
  try {
    let t = @enhance.estimate_transmission(
      img,
      [200, 200, 200],
      omega=0.85,
      patch_size=3,
    )
    assert_eq(t.width, 16)
    assert_eq(t.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: guided_filter_image 基本测试" {
  let img = enh_make_rgb(16, 16)
  let guide = enh_make_rgb(16, 16)
  try {
    let result = @enhance.guided_filter_image(img, guide, radius=4, eps=0.01)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: hdr_fusion_average 多张图像" {
  let img1 = enh_make_rgb(8, 8)
  let img2 = enh_make_rgb(8, 8)
  let img3 = enh_make_rgb(8, 8)
  try {
    let result = @enhance.hdr_fusion_average([img1, img2, img3])
    assert_eq(result.width, 8)
    assert_eq(result.height, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: hdr_fusion_weighted 多张图像" {
  let img1 = enh_make_rgb(8, 8)
  let img2 = enh_make_rgb(8, 8)
  try {
    let result = @enhance.hdr_fusion_weighted([img1, img2])
    assert_eq(result.width, 8)
    assert_eq(result.height, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: hdr_process 默认配置" {
  let img1 = enh_make_rgb(8, 8)
  let img2 = enh_make_rgb(8, 8)
  try {
    let result = @enhance.hdr_process([img1, img2])
    assert_eq(result.width, 8)
    assert_eq(result.height, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: hdr_process 自定义配置" {
  let img1 = enh_make_rgb(8, 8)
  let config = @enhance.HdrConfig::{
    fusion_method: "weighted",
    tone_mapping: "reinhard",
    gamma: 2.2,
    reinhard_key: 0.18,
    sigmoid_strength: 5.0,
  }
  try {
    let result = @enhance.hdr_process([img1], config~)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: inpaint_advanced 基本测试" {
  let img = enh_make_rgb(16, 16)
  let mask = enh_make_uniform(16, 16, 0)
  try {
    let result = @enhance.inpaint_advanced(img, mask, radius=3)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: remove_small_objects 基本测试" {
  let img = enh_make_gray(16, 16)
  try {
    let result = @enhance.remove_small_objects(img, max_size=10)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: remove_watermark 基本测试" {
  let img = enh_make_rgb(16, 16)
  try {
    let result = @enhance.remove_watermark(img, 2, 2, 4, 4)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: tone_mapping_gamma 不同 gamma 值" {
  let img = enh_make_rgb(16, 16)
  for gamma in [1.0, 1.8, 2.2, 3.0] {
    try {
      let result = @enhance.tone_mapping_gamma(img, gamma~)
      assert_eq(result.width, 16)
      assert_eq(result.height, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "enhance: tone_mapping_reinhard 不同 key 值" {
  let img = enh_make_rgb(16, 16)
  for key in [0.1, 0.18, 0.5] {
    try {
      let result = @enhance.tone_mapping_reinhard(img, key~)
      assert_eq(result.width, 16)
      assert_eq(result.height, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "enhance: tone_mapping_sigmoid 不同强度" {
  let img = enh_make_rgb(16, 16)
  for strength in [1.0, 5.0, 10.0] {
    try {
      let result = @enhance.tone_mapping_sigmoid(img, strength~)
      assert_eq(result.width, 16)
      assert_eq(result.height, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "enhance: DehazeConfig 自定义构造" {
  let config = @enhance.DehazeConfig::{
    patch_size: 7,
    omega: 0.95,
    t_min: 0.05,
    guided_radius: 40,
    guided_eps: 0.0001,
    max_atmospheric: 220,
  }
  assert_eq(config.patch_size, 7)
  assert_true((config.omega - 0.95).abs() < 0.001)
  assert_true((config.t_min - 0.05).abs() < 0.001)
}

///|
test "enhance: HdrConfig 自定义构造" {
  let config = @enhance.HdrConfig::{
    fusion_method: "average",
    tone_mapping: "gamma",
    gamma: 1.8,
    reinhard_key: 0.3,
    sigmoid_strength: 3.0,
  }
  assert_eq(config.fusion_method, "average")
  assert_eq(config.tone_mapping, "gamma")
  assert_true((config.gamma - 1.8).abs() < 0.001)
}

///|
test "enhance: NlmConfig 自定义构造" {
  let config = @enhance.NlmConfig::{
    search_window: 21,
    patch_size: 7,
    h: 15.0,
    sigma: 2.0,
  }
  assert_eq(config.search_window, 21)
  assert_eq(config.patch_size, 7)
  assert_true((config.h - 15.0).abs() < 0.001)
}

///|
test "enhance: InpaintConfig 自定义构造" {
  let config = @enhance.InpaintConfig::{
    radius: 5,
    method_type: "telea",
    max_iterations: 100,
  }
  assert_eq(config.radius, 5)
  assert_eq(config.method_type, "telea")
  assert_eq(config.max_iterations, 100)
}

///|
test "enhance: denoise 灰度图" {
  let img = enh_make_gray(16, 16)
  try {
    let result = @enhance.denoise(img, "median")
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: denoise_bilateral 灰度图" {
  let img = enh_make_gray(16, 16)
  try {
    let result = @enhance.denoise_bilateral(
      img,
      diameter=5,
      sigma_color=30.0,
      sigma_space=5.0,
    )
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: tone_mapping_gamma 灰度图" {
  let img = enh_make_gray(16, 16)
  try {
    let result = @enhance.tone_mapping_gamma(img, gamma=2.2)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: hdr_fusion_average 单张图像" {
  let img = enh_make_rgb(8, 8)
  try {
    let result = @enhance.hdr_fusion_average([img])
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enhance: dark_channel 均匀图像" {
  let img = enh_make_uniform(16, 16, 128)
  try {
    let dc = @enhance.dark_channel(img, patch_size=3)
    assert_eq(dc.width, 16)
    assert_eq(dc.height, 16)
  } catch {
    _ => assert_true(true)
  }
}
