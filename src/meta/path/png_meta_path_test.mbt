///|
test "read_png_text_chunks: from path" {
  let result = read_png_text_chunks_from_path("testdata/test_4x4_red.png")
  // 测试 PNG 可能没有 text chunks，主要验证不崩溃
  assert_true(result.length() >= 0)
  let _ = result
}

///|
test "read_png_text_chunks: from path non-existent raises" {
  try {
    let _ = read_png_text_chunks_from_path("testdata/nonexistent.png")
    assert_true(false)
  } catch {
    @core.LoadError::FileIO(_) => assert_true(true)
    _ => assert_true(false)
  }
}
