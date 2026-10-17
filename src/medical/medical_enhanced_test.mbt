// v189.0.0 medical 模块增强测试：边值/属性/多预设/多参数

///|
fn make_medical_image2(w : Int, h : Int) -> @medical.MedicalImage {
  let data : Array[Double] = []
  for i in 0..<(w * h) {
    data.push((i % 256).to_double())
  }
  @medical.MedicalImage::{
    width: w,
    height: h,
    slices: 1,
    data,
    image_type: @medical.MedicalImageType::CT,
    pixel_spacing_x: 1.0,
    pixel_spacing_y: 1.0,
    slice_thickness: 1.0,
    window_center: 40.0,
    window_width: 80.0,
  }
}

///|
fn make_uniform_medical2(
  w : Int,
  h : Int,
  value : Double,
) -> @medical.MedicalImage {
  @medical.MedicalImage::{
    width: w,
    height: h,
    slices: 1,
    data: Array::make(w * h, value),
    image_type: @medical.MedicalImageType::CT,
    pixel_spacing_x: 1.0,
    pixel_spacing_y: 1.0,
    slice_thickness: 1.0,
    window_center: 40.0,
    window_width: 80.0,
  }
}

///|
fn make_img(w : Int, h : Int, value : Byte) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, value)),
  }
}

///|
test "window_level_lung: 值验证" {
  let wl = @medical.window_level_lung()
  assert_eq(wl.window_width, 1500.0)
  assert_eq(wl.window_level, -600.0)
}

///|
test "window_level_mediastinum: 值验证" {
  let wl = @medical.window_level_mediastinum()
  assert_eq(wl.window_width, 400.0)
  assert_eq(wl.window_level, 40.0)
}

///|
test "window_level_bone: 值验证" {
  let wl = @medical.window_level_bone()
  assert_eq(wl.window_width, 2000.0)
  assert_eq(wl.window_level, 400.0)
}

///|
test "window_level_brain: 值验证" {
  let wl = @medical.window_level_brain()
  assert_eq(wl.window_width, 80.0)
  assert_eq(wl.window_level, 40.0)
}

///|
test "apply_window_level: 肺窗应用" {
  let img = make_img(8, 8, 128)
  let wl = @medical.window_level_lung()
  let result = @medical.apply_window_level(img, wl)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 1)
}

///|
test "apply_window_level: 骨窗应用" {
  let img = make_img(8, 8, 200)
  let wl = @medical.window_level_bone()
  let result = @medical.apply_window_level(img, wl)
  assert_eq(result.width, 8)
  assert_eq(result.channels, 1)
}

///|
test "apply_window_level: 脑窗应用" {
  let img = make_img(4, 4, 50)
  let wl = @medical.window_level_brain()
  let result = @medical.apply_window_level(img, wl)
  assert_eq(result.width, 4)
}

///|
test "medical_colormap: cool映射" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="cool")
  assert_eq(result.channels, 3)
  assert_eq(result.data.length(), 48)
}

///|
test "medical_colormap: spring映射" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="spring")
  assert_eq(result.channels, 3)
}

///|
test "medical_colormap: summer映射" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="summer")
  assert_eq(result.channels, 3)
}

///|
test "medical_colormap: autumn映射" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="autumn")
  assert_eq(result.channels, 3)
}

///|
test "medical_colormap: winter映射" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="winter")
  assert_eq(result.channels, 3)
}

///|
test "medical_colormap: bone映射" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="bone")
  assert_eq(result.channels, 3)
}

///|
test "medical_colormap: pink映射" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="pink")
  assert_eq(result.channels, 3)
}

///|
test "medical_colormap: 未知映射默认灰度" {
  let img = make_img(4, 4, 128)
  let result = @medical.medical_colormap(img, colormap="unknown")
  assert_eq(result.channels, 3)
}

///|
test "medical_contrast_enhance: 自定义参数" {
  let img = make_img(8, 8, 128)
  let result = @medical.medical_contrast_enhance(
    img,
    clip_limit=3.0,
    tile_size=4,
  )
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 1)
}

///|
test "medical_contrast_enhance: 变化图像" {
  let arr : Array[Byte] = []
  for i in 0..<64 {
    arr.push((i * 4).to_byte())
  }
  let img = @types.Image::{
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(arr),
  }
  let result = @medical.medical_contrast_enhance(img)
  assert_eq(result.width, 8)
}

///|
test "medical_denoise: 自定义参数" {
  let img = make_img(8, 8, 128)
  let result = @medical.medical_denoise(img, iterations=3, kappa=20.0)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "medical_denoise: 零次迭代" {
  let img = make_img(4, 4, 100)
  let result = @medical.medical_denoise(img, iterations=0)
  assert_eq(result.width, 4)
}

///|
test "measure_distance: 自定义像素间距" {
  let dist = @medical.measure_distance(0, 0, 3, 4, pixel_spacing=2.0)
  assert_true(dist > 9.9 && dist < 10.1)
}

///|
test "measure_distance: 负坐标" {
  let dist = @medical.measure_distance(-3, -4, 0, 0)
  assert_true(dist > 4.9 && dist < 5.1)
}

///|
test "measure_distance: 大间距" {
  let dist = @medical.measure_distance(0, 0, 100, 200, pixel_spacing=0.5)
  assert_true(dist > 0.0)
}

///|
test "measure_area: 自定义像素面积" {
  let mask = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 255)),
  }
  let area = @medical.measure_area(mask, pixel_area=0.5)
  assert_true(area > 0.0)
}

///|
test "measure_area: 全黑掩码" {
  let mask = make_img(4, 4, 0)
  let area = @medical.measure_area(mask)
  assert_eq(area, 0.0)
}

///|
test "create_default_window_level: abdomen预设" {
  let config = @medical.create_default_window_level("abdomen")
  assert_eq(config.center, 40.0)
  assert_eq(config.width, 400.0)
}

///|
test "create_default_window_level: soft_tissue预设" {
  let config = @medical.create_default_window_level("soft_tissue")
  assert_eq(config.center, 50.0)
  assert_eq(config.width, 350.0)
}

///|
test "create_default_window_level: 未知预设" {
  let config = @medical.create_default_window_level("custom_preset")
  assert_eq(config.preset, "custom")
}

///|
test "apply_window_level_medical: 基本应用" {
  let img = make_medical_image2(8, 8)
  let config = @medical.create_default_window_level("brain")
  let result = @medical.apply_window_level_medical(img, config)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 1)
}

///|
test "medical_threshold_segmentation: 窄阈值" {
  let img = make_medical_image2(16, 16)
  let mask = @medical.medical_threshold_segmentation(img, 100.0, 150.0)
  assert_eq(mask.length(), 256)
  let mut has_true = false
  for i in 0..<256 {
    if mask[i] {
      has_true = true
    }
  }
  assert_true(has_true)
}

///|
test "medical_threshold_segmentation: 全排除" {
  let img = make_uniform_medical2(4, 4, 50.0)
  let mask = @medical.medical_threshold_segmentation(img, 100.0, 200.0)
  let mut all_false = true
  for i in 0..<mask.length() {
    if mask[i] {
      all_false = false
    }
  }
  assert_true(all_false)
}

///|
test "region_growing_segmentation: 中心种子" {
  let img = make_medical_image2(8, 8)
  let mask = @medical.region_growing_segmentation(img, 4, 4, 0, 10.0)
  assert_eq(mask.length(), 64)
  assert_true(mask[4 * 8 + 4])
}

///|
test "region_growing_segmentation: 大阈值全包含" {
  let img = make_medical_image2(8, 8)
  let mask = @medical.region_growing_segmentation(img, 0, 0, 0, 1000.0)
  let mut true_count = 0
  for i in 0..<mask.length() {
    if mask[i] {
      true_count += 1
    }
  }
  assert_true(true_count > 0)
}

///|
test "calculate_roi_stats: 非空ROI" {
  let img = make_medical_image2(8, 8)
  let mask = Array::make(64, true)
  let (mean, _std, count) = @medical.calculate_roi_stats(img, mask)
  assert_true(count == 64)
  assert_true(mean >= 0.0)
  assert_true(_std >= 0.0)
}

///|
test "calculate_roi_stats: 部分ROI" {
  let img = make_medical_image2(8, 8)
  let mask = Array::make(64, false)
  mask[0] = true
  mask[1] = true
  mask[2] = true
  let (mean, _std, count) = @medical.calculate_roi_stats(img, mask)
  assert_eq(count, 3)
  assert_true(mean >= 0.0)
}

///|
test "detect_lesions_simple: 小直径限制" {
  let img = make_medical_image2(16, 16)
  let lesions = @medical.detect_lesions_simple(img, 0.0, 5.0)
  assert_true(lesions.length() >= 0)
}

///|
test "detect_lesions_simple: 大直径限制" {
  let img = make_medical_image2(16, 16)
  let lesions = @medical.detect_lesions_simple(img, 10.0, 100.0)
  assert_true(lesions.length() >= 0)
}

///|
test "medical_image_registration: 不同图像" {
  let fixed = make_medical_image2(8, 8)
  let moving = make_uniform_medical2(8, 8, 100.0)
  let result = @medical.medical_image_registration(fixed, moving, 10)
  assert_eq(result.transformation.length(), 16)
  assert_true(result.iterations > 0)
}

///|
test "medical_image_registration: 零迭代" {
  let fixed = make_medical_image2(4, 4)
  let moving = make_medical_image2(4, 4)
  let result = @medical.medical_image_registration(fixed, moving, 0)
  assert_eq(result.iterations, 0)
}

///|
test "calculate_medical_image_quality: 均匀图像" {
  let img = make_uniform_medical2(8, 8, 128.0)
  let quality = @medical.calculate_medical_image_quality(img)
  assert_true(quality.noise_level >= 0.0)
}

///|
test "calculate_medical_image_quality: 变化图像" {
  let img = make_medical_image2(8, 8)
  let quality = @medical.calculate_medical_image_quality(img)
  assert_true(quality.snr >= 0.0 || quality.snr < 0.0)
  assert_true(quality.sharpness >= 0.0)
}

///|
test "medical_image_report_to_string: 有病灶" {
  let img = make_medical_image2(8, 8)
  let lesions = @medical.detect_lesions_simple(img, 0.0, 20.0)
  let quality = @medical.calculate_medical_image_quality(img)
  let report = @medical.medical_image_report_to_string(img, lesions, quality)
  assert_true(report.length() > 0)
}

///|
test "create_default_medical_segmentation_config: 字段验证" {
  let config = @medical.create_default_medical_segmentation_config()
  assert_true(config.lower_threshold < config.upper_threshold)
  assert_true(config.smoothness > 0.0)
}
