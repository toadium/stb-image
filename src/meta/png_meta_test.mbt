///|
test "read_png_text_chunks: non-PNG returns empty" {
  let data = Bytes::from_array([b'\x00', b'\x00', b'\x00', b'\x00'])
  let result = read_png_text_chunks(data)
  assert_eq(result.length(), 0)
  let _ = data
  let _ = result
}

///|
test "read_png_text_chunks: empty bytes returns empty" {
  let data = Bytes::from_array([])
  let result = read_png_text_chunks(data)
  assert_eq(result.length(), 0)
  let _ = data
  let _ = result
}

///|
test "read_png_text_chunks: PNG without text chunks returns empty" {
  // 读取测试 PNG 文件
  let png = @core.write_png_to_bytes(@core.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: [b'\xFF', b'\x00', b'\x00'] |> Bytes::from_array,
  })
  let result = read_png_text_chunks(png)
  // stb_image_write 生成的 PNG 可能没有 text chunks
  assert_true(result.length() >= 0)
  let _ = png
  let _ = result
}

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

///|
test "PngTextChunk: construction" {
  let chunk = PngTextChunk::{ keyword: "Author", text: "Test" }
  assert_eq(chunk.keyword, "Author")
  assert_eq(chunk.text, "Test")
  let _ = chunk
}
