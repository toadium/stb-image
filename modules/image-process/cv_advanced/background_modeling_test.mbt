// 背景建模测试 — GMM/KNN/VIBE
// Background modeling tests

///|
fn make_bg_test_image(v : Int32) -> @types.Image {
  let width = 8
  let height = 8
  let channels = 1
  let data : Array[Byte] = []
  for _ in 0..<(width * height) {
    data.push(v.reinterpret_as_uint().to_byte())
  }
  { width, height, channels, data: Bytes::from_array(data), }
}

///|
fn make_bg_params() -> @cv_advanced.BackgroundParams {
  {
    bg_method: @cv_advanced.BackgroundMethod::GMM,
    threshold: 3.0,
    learning_rate: 0.05,
    history: 100,
    var_init: 100.0,
  }
}

///|
test "形式化: init_background_model 返回正确尺寸" {
  let img = make_bg_test_image(128)
  let params = make_bg_params()
  let model = @cv_advanced.init_background_model(img, params)
  assert_eq(model.width, img.width)
  assert_eq(model.height, img.height)
  assert_eq(model.means.length(), img.width * img.height)
}

///|
test "形式化: subtract_background 返回正确尺寸" {
  let img = make_bg_test_image(128)
  let params = make_bg_params()
  let model = @cv_advanced.init_background_model(img, params)
  let mask = @cv_advanced.subtract_background(model, img)
  assert_eq(mask.width, img.width)
  assert_eq(mask.height, img.height)
  assert_eq(mask.mask.length(), img.width * img.height)
}

///|
test "形式化: update_background_model 增加帧计数" {
  let img = make_bg_test_image(128)
  let params = make_bg_params()
  let model = @cv_advanced.init_background_model(img, params)
  let updated = @cv_advanced.update_background_model(model, img)
  assert_eq(updated.frame_count, 2)
}

///|
test "形式化: clean_foreground_mask 保持尺寸" {
  let mask : @cv_advanced.ForegroundMask = {
    width: 4,
    height: 4,
    mask: [
      true, false, true, false, false, true, false, true, true, false, true, false,
      false, true, false, true,
    ],
  }
  let cleaned = @cv_advanced.clean_foreground_mask(mask)
  assert_eq(cleaned.width, mask.width)
  assert_eq(cleaned.height, mask.height)
}

///|
test "FAKE: gmm_update 更新模型" {
  let img = make_bg_test_image(128)
  let params = make_bg_params()
  let model = @cv_advanced.init_background_model(img, params)
  let updated = @cv_advanced.gmm_update(model, img)
  assert_eq(updated.frame_count, 2)
}

///|
test "MOCK: knn_update 更新模型" {
  let img = make_bg_test_image(128)
  let params = make_bg_params()
  let model = @cv_advanced.init_background_model(img, params)
  let updated = @cv_advanced.knn_update(model, img)
  assert_eq(updated.frame_count, 2)
}

///|
test "E2E: 完整背景建模流程" {
  let bg = make_bg_test_image(100)
  let params = make_bg_params()
  let model = @cv_advanced.init_background_model(bg, params)
  let model2 = @cv_advanced.update_background_model(model, bg)
  let frame = make_bg_test_image(200)
  let mask = @cv_advanced.subtract_background(model2, frame)
  let cleaned = @cv_advanced.clean_foreground_mask(mask)
  assert_eq(cleaned.width, bg.width)
  assert_eq(cleaned.height, bg.height)
}

///|
test "AI: BackgroundMethod 枚举完整" {
  let gmm = @cv_advanced.BackgroundMethod::GMM
  let knn = @cv_advanced.BackgroundMethod::KNN
  let vibe = @cv_advanced.BackgroundMethod::VIBE
  assert_true(gmm != knn)
  assert_true(knn != vibe)
  assert_true(gmm != vibe)
}

///|
test "AI: vibe_update 保持模型尺寸" {
  let img = make_bg_test_image(128)
  let params = make_bg_params()
  let model = @cv_advanced.init_background_model(img, params)
  let updated = @cv_advanced.vibe_update(model, img)
  assert_eq(updated.width, model.width)
  assert_eq(updated.height, model.height)
  assert_eq(updated.means.length(), model.means.length())
}
