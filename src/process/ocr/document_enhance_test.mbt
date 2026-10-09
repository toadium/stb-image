// v187.0.0 document_enhance.mbt 测试：文档增强/阴影去除/背景归一化

///|
test "document_enhance: 基本增强" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        100, 150, 200, 250, 50, 100, 150, 200, 200, 150, 100, 50, 250, 200, 150,
        100,
      ]),
    }
    let result = @ocr.document_enhance(img)
    assert_eq(result.width, 4)
    assert_eq(result.height, 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "shadow_removal: 基本去阴影" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        50, 100, 150, 200, 60, 110, 160, 210, 70, 120, 170, 220, 80, 130, 180, 230,
      ]),
    }
    let result = @ocr.shadow_removal(img)
    assert_eq(result.width, 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "background_normalization: 基本归一化" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        200, 210, 220, 230, 200, 210, 220, 230, 200, 210, 220, 230, 200, 210, 220,
        230,
      ]),
    }
    let result = @ocr.background_normalization(img)
    assert_eq(result.width, 4)
  } catch {
    _ => assert_true(false)
  }
}
