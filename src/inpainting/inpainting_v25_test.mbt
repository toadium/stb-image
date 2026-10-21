// v25.0.0 图像修复增强测试 - inpainting 模块
// 图像修复/去雾/去雨：Telea/NavierStrokes/FastMarching/PatchMatch、暗通道/CLAHE去雾、形态学去雨

///|
fn make_varied_inpaint_img(w : Int32, h : Int32) -> @types.Image {
  let arr : Array[Byte] = []
  for i in 0..<(w * h) {
    arr.push((i % 256).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(arr),
  }
}

///|
test "create_default_inpainting_config: 默认配置" {
  let config = @inpainting.create_default_inpainting_config()
  assert_true(config.radius > 0)
  assert_true(config.iterations > 0)
  assert_true(config.tolerance > 0.0)
}

///|
test "create_rect_mask: 基本掩膜创建" {
  let mask = @inpainting.create_rect_mask(8, 8, 2, 2, 4, 4)
  assert_eq(mask.width, 8)
  assert_eq(mask.height, 8)
}

///|
test "inpaint_simple: 基本修复" {
  let img = make_varied_inpaint_img(8, 8)
  let mask = @inpainting.create_rect_mask(8, 8, 2, 2, 4, 4)
  let result = @inpainting.inpaint_simple(img, mask, 3)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "inpaint_diffusion: 基本扩散修复" {
  let img = make_varied_inpaint_img(8, 8)
  let mask = @inpainting.create_rect_mask(8, 8, 2, 2, 4, 4)
  let result = @inpainting.inpaint_diffusion(img, mask, 3)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "inpaint: Telea算法" {
  let img = make_varied_inpaint_img(8, 8)
  let mask = @inpainting.create_rect_mask(8, 8, 2, 2, 4, 4)
  let config = @inpainting.create_default_inpainting_config()
  let result = @inpainting.inpaint(img, mask, config)
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
  assert_true(result.algorithm == @inpainting.InpaintingAlgorithm::Telea)
}

///|
test "inpaint: NavierStokes算法" {
  let img = make_varied_inpaint_img(8, 8)
  let mask = @inpainting.create_rect_mask(8, 8, 2, 2, 4, 4)
  let config = @inpainting.InpaintingConfig::{
    algorithm: @inpainting.InpaintingAlgorithm::NavierStokes,
    radius: 3,
    iterations: 10,
    use_edge_preservation: true,
    tolerance: 0.1,
  }
  let result = @inpainting.inpaint(img, mask, config)
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
}

///|
test "dehaze_dark_channel: 基本去雾" {
  let img = make_varied_inpaint_img(8, 8)
  let result = @inpainting.dehaze_dark_channel(img, 0.95, 0.1)
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
}

///|
test "dehaze_clahe: 基本CLAHE去雾" {
  let img = make_varied_inpaint_img(8, 8)
  let result = @inpainting.dehaze_clahe(img, 2.0, 8)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "dehaze: 暗通道先验算法" {
  let img = make_varied_inpaint_img(8, 8)
  let result = @inpainting.dehaze(
    img,
    @inpainting.DehazeAlgorithm::DarkChannelPrior,
  )
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
}

///|
test "dehaze: CLAHE算法" {
  let img = make_varied_inpaint_img(8, 8)
  let result = @inpainting.dehaze(img, @inpainting.DehazeAlgorithm::CLAHE)
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
}

///|
test "derain_morphological: 基本去雨" {
  let img = make_varied_inpaint_img(8, 8)
  let result = @inpainting.derain_morphological(img)
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
}

///|
test "derain: 形态学算法" {
  let img = make_varied_inpaint_img(8, 8)
  let result = @inpainting.derain(
    img,
    @inpainting.DerainAlgorithm::Morphological,
  )
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
}

///|
test "inpainting_report_to_string: 生成报告" {
  let img = make_varied_inpaint_img(8, 8)
  let mask = @inpainting.create_rect_mask(8, 8, 2, 2, 4, 4)
  let config = @inpainting.create_default_inpainting_config()
  let result = @inpainting.inpaint(img, mask, config)
  let report = @inpainting.inpainting_report_to_string(result)
  assert_true(report.length() > 0)
}
