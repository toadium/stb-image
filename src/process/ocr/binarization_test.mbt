// v187.0.0 binarization.mbt 测试：Niblack/Sauvola/自适应/Otsu 二值化

///|
test "niblack_threshold: 基本二值化" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255,
        255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255,
        255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255,
        255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0,
      ]),
    }
    let result = @ocr.niblack_threshold(img)
    assert_eq(result.width, 8)
    assert_eq(result.height, 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "sauvola_threshold: 基本二值化" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        200, 200, 200, 200, 50, 50, 50, 50, 200, 200, 200, 200, 50, 50, 50,
        50, 200, 200, 200, 200, 50, 50, 50, 50, 200, 200, 200, 200, 50, 50,
        50, 50, 200, 200, 200, 200, 50, 50, 50, 50, 200, 200, 200, 200, 50,
        50, 50, 50, 200, 200, 200, 200, 50, 50, 50, 50, 200, 200, 200, 200,
        50, 50, 50, 50,
      ]),
    }
    let result = @ocr.sauvola_threshold(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "adaptive_threshold_ocr: 基本自适应" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128, 128, 128, 128, 128,
      ]),
    }
    let result = @ocr.adaptive_threshold_ocr(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "otsu_threshold: 基本Otsu" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255,
        255, 255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255,
        255, 255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0, 255, 255, 255,
        255, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0,
      ]),
    }
    let result = @ocr.otsu_threshold(img)
    assert_eq(result.width, 8)
    assert_eq(result.height, 8)
  } catch {
    _ => assert_true(false)
  }
}