// v187.0.0 deskew.mbt 测试：倾斜检测/校正/旋转

///|
test "detect_skew_angle: 无倾斜" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255,
        0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255,
        255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0,
        255, 255, 0, 0, 255, 255, 0, 0,
      ]),
    }
    let angle = @ocr.detect_skew_angle(img)
    assert_true(angle >= -15.0 && angle <= 15.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "deskew: 基本校正" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
        128, 128, 128, 128,
      ]),
    }
    let result = @ocr.deskew(img)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "rotate_document: 基本旋转" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        255, 0, 255, 0, 0, 255, 0, 255, 255, 0, 255, 0, 0, 255, 0, 255,
      ]),
    }
    let result = @ocr.rotate_document(img, 5.0)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}
