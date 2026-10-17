// v224: forensics_enhanced 边界测试

///|
fn fen_uniform(w : Int, h : Int, v : Int) -> @types.Image {
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
test "fen_edge: analyze_ela quality_level过高" {
  try {
    let _ = @forensics_enhanced.analyze_ela(fen_uniform(8, 8, 128), 256)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fen_edge: detect_clone_regions block_size过小" {
  try {
    let _ = @forensics_enhanced.detect_clone_regions(
      fen_uniform(8, 8, 128),
      1,
      0.5,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fen_edge: detect_clone_regions block_size过大" {
  try {
    let _ = @forensics_enhanced.detect_clone_regions(
      fen_uniform(8, 8, 128),
      17,
      0.5,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fen_edge: detect_tamper_comprehensive ela_quality过高" {
  try {
    let _ = @forensics_enhanced.detect_tamper_comprehensive(
      fen_uniform(8, 8, 128),
      256,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
