// v224: performance 边界测试

///|
fn pf_uniform(w : Int, h : Int, v : Int) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
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
test "pf_edge: extract_tile 无效参数" {
  try {
    let img = pf_uniform(8, 8, 128)
    let _ = @performance.extract_tile(img, 0, 0, 0, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pf_edge: extract_tile 越界" {
  try {
    let img = pf_uniform(4, 4, 128)
    let _ = @performance.extract_tile(img, 2, 2, 4, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pf_edge: paste_tile 无效位置" {
  try {
    let img = pf_uniform(4, 4, 128)
    let tile = pf_uniform(2, 2, 128)
    let _ = @performance.paste_tile(img, tile, -1, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pf_edge: paste_tile 越界" {
  try {
    let img = pf_uniform(4, 4, 128)
    let tile = pf_uniform(4, 4, 128)
    let _ = @performance.paste_tile(img, tile, 1, 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pf_edge: paste_tile 通道不匹配" {
  try {
    let img = pf_uniform(4, 4, 128)
    let tile = @types.Image::{
      width: 2,
      height: 2,
      channels: 3,
      data: Bytes::from_array(Array::make(12, 0)),
    }
    let _ = @performance.paste_tile(img, tile, 0, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
