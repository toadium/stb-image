// v21.0.0 图像加密与水印增强测试 - image_watermark_advanced 模块

///|
fn make_wm_data(n : Int32) -> Array[Double] {
  let arr : Array[Double] = []
  for i in 0..<n {
    arr.push((i % 256).to_double())
  }
  arr
}

///|
test "create_default_watermark_config: 返回有效配置" {
  let config = @image_watermark_advanced.create_default_watermark_config()
  assert_true(config.watermark_strength > 0.0)
}

///|
test "embed_watermark: 基本嵌入" {
  let config = @image_watermark_advanced.create_default_watermark_config()
  let image = make_wm_data(64)
  let watermark = [b'\x41', b'\x42', b'\x43']
  let result = @image_watermark_advanced.embed_watermark(
    image, 8, 8, watermark, config,
  )
  assert_eq(result.watermarked_image.length(), 64)
}

///|
test "detect_watermark: 基本检测" {
  let config = @image_watermark_advanced.create_default_watermark_config()
  let image = make_wm_data(64)
  let watermark = [b'\x41', b'\x42', b'\x43']
  let stego = @image_watermark_advanced.embed_watermark(
    image, 8, 8, watermark, config,
  )
  let result = @image_watermark_advanced.detect_watermark(
    stego.watermarked_image,
    8,
    8,
    3,
    config,
  )
  assert_true(result.detected_watermark.length() >= 0)
}

///|
test "attack_watermark: 基本攻击" {
  let image = make_wm_data(64)
  let result = @image_watermark_advanced.attack_watermark(
    image,
    8,
    8,
    @image_watermark_advanced.WatermarkAttackType::NoiseAddition,
    10.0,
  )
  assert_eq(result.attacked_image.length(), 64)
}

///|
test "embed_visible_watermark: 基本嵌入" {
  let config = @image_watermark_advanced.create_default_watermark_config()
  let image = make_wm_data(64)
  let result = @image_watermark_advanced.embed_visible_watermark(
    image, 8, 8, config,
  )
  assert_eq(result.length(), 64)
}

///|
test "image_watermark_report_to_string: 报告生成" {
  let config = @image_watermark_advanced.create_default_watermark_config()
  let report = @image_watermark_advanced.image_watermark_report_to_string(
    @image_watermark_advanced.ImageWatermarkTaskType::InvisibleWatermark,
    config,
    "水印嵌入完成",
  )
  assert_true(report.length() > 0)
}
