///|
// Test-only FFI declarations: extern "c" fn are file-private in MoonBit,
// so the test file must re-declare FFI entries pointing to the same C symbols.
#borrow(buffer, w_ref, h_ref, c_ref)
extern "c" fn test_load_from_memory(
  buffer : Bytes,
  len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_memory"

///|
#borrow(path, w_ref, h_ref, c_ref)
extern "c" fn test_load_from_path(
  path : Bytes,
  path_len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_path"

///|
// Build 1x1 24-bit BMP: red pixel (R=255, G=0, B=0)
// BMP Header(14) + DIB Header(40) + Pixel data(4, row padded) = 58 bytes
// stb_image decodes to: w=1, h=1, c=3, pixel data=[255, 0, 0] (RGB)
fn make_1x1_red_bmp() -> Bytes {
  // BMP Header(14) + DIB Header(40) + Pixel(4, BGR+pad) = 58 bytes
  // Red pixel: B=0 G=0 R=255, stb_image decodes to RGB [255,0,0]
  b"\x42\x4D\x3A\x00\x00\x00\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00\x01\x00\x18\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\x00"
}

///|
// Build 2x2 24-bit BMP: 4 colored pixels
// Layout: (0,0)=red, (1,0)=white, (0,1)=green, (1,1)=blue
// BMP Header(14) + DIB Header(40) + Pixel data(16, 2 rows * 8 bytes) = 70 bytes
// stb_image decodes to: w=2, h=2, c=3, pixel data=[255,0,0, 255,255,255, 0,255,0, 0,0,255] (RGB)
fn make_2x2_colors_bmp() -> Bytes {
  b"\x42\x4D\x46\x00\x00\x00\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00\x02\x00\x00\x00\x02\x00\x00\x00\x01\x00\x18\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\x00\xFF\x00\x00\x00\x00\x00\x00\xFF\xFF\xFF\xFF\x00\x00"
}

// ============================================================
// stb_image_mbt_load_from_memory behavior contracts
// ============================================================

///|
test "load_from_memory: 1x1 BMP success returns correct dimensions" {
  let bmp = make_1x1_red_bmp()
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_memory(bmp, bmp.length(), w, h, c)
  // Success: non-zero length Bytes returned
  assert_true(pixels.length() > 0)
  // ABI normalization: w/h/c written back to Ref[Int]
  assert_eq(w.val, 1)
  assert_eq(h.val, 1)
  assert_eq(c.val, 3)
  // Ownership transfer: pixel data length = w * h * c
  assert_eq(pixels.length(), 3)
}

///|
test "load_from_memory: 1x1 BMP success returns correct pixel data" {
  let bmp = make_1x1_red_bmp()
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_memory(bmp, bmp.length(), w, h, c)

  // stb_image returns RGB order: R=255, G=0, B=0
  assert_eq(pixels[0].to_int(), 255)
  assert_eq(pixels[1].to_int(), 0)
  assert_eq(pixels[2].to_int(), 0)
}

///|
test "load_from_memory: 2x2 BMP success returns correct dimensions" {
  let bmp = make_2x2_colors_bmp()
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_memory(bmp, bmp.length(), w, h, c)
  assert_true(pixels.length() > 0)
  assert_eq(w.val, 2)
  assert_eq(h.val, 2)
  assert_eq(c.val, 3)
  assert_eq(pixels.length(), 12)
}

///|
test "load_from_memory: 2x2 BMP success returns correct pixel data" {
  let bmp = make_2x2_colors_bmp()
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_memory(bmp, bmp.length(), w, h, c)
  // RGB order, top-to-bottom, left-to-right
  // (0,0)=red:   R=255, G=0,   B=0
  // (1,0)=white: R=255, G=255, B=255
  // (0,1)=green: R=0,   G=255, B=0
  // (1,1)=blue:  R=0,   G=0,   B=255
  assert_eq(pixels[0].to_int(), 255)
  assert_eq(pixels[1].to_int(), 0)
  assert_eq(pixels[2].to_int(), 0)
  assert_eq(pixels[3].to_int(), 255)
  assert_eq(pixels[4].to_int(), 255)
  assert_eq(pixels[5].to_int(), 255)
  assert_eq(pixels[6].to_int(), 0)
  assert_eq(pixels[7].to_int(), 255)
  assert_eq(pixels[8].to_int(), 0)
  assert_eq(pixels[9].to_int(), 0)
  assert_eq(pixels[10].to_int(), 0)
  assert_eq(pixels[11].to_int(), 255)
}

///|
test "load_from_memory: invalid bytes failure returns zero-length and zero dims" {
  let invalid = b"\x00\x01\x02\x03"
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_memory(invalid, invalid.length(), w, h, c)
  // Failure signal: zero-length Bytes
  assert_eq(pixels.length(), 0)
  // Output params actively zeroed
  assert_eq(w.val, 0)
  assert_eq(h.val, 0)
  assert_eq(c.val, 0)
}

///|
test "load_from_memory: empty bytes boundary returns zero-length and zero dims" {
  let empty = b""
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_memory(empty, 0, w, h, c)
  assert_eq(pixels.length(), 0)
  assert_eq(w.val, 0)
  assert_eq(h.val, 0)
  assert_eq(c.val, 0)
}

///|
test "load_from_memory: input buffer unchanged after call" {
  let bmp = make_1x1_red_bmp()
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let _ = test_load_from_memory(bmp, bmp.length(), w, h, c)
  // #borrow semantics: stb reads only, does not modify input Bytes
  assert_eq(bmp, make_1x1_red_bmp())
}

// ============================================================
// stb_image_mbt_load_from_path behavior contracts
// ============================================================

///|
test "load_from_path: 4x4 BMP file success returns correct dimensions" {
  let path = b"testdata/test_4x4_red.bmp"
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_path(path, path.length(), w, h, c)
  assert_true(pixels.length() > 0)
  assert_eq(w.val, 4)
  assert_eq(h.val, 4)
  assert_eq(c.val, 3)
  assert_eq(pixels.length(), 48)
}

///|
test "load_from_path: 4x4 BMP file success returns correct pixel data" {
  let path = b"testdata/test_4x4_red.bmp"
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_path(path, path.length(), w, h, c)
  // stb_image returns RGB order: R=255, G=0, B=0 for all 16 pixels
  assert_eq(pixels[0].to_int(), 255)
  assert_eq(pixels[1].to_int(), 0)
  assert_eq(pixels[2].to_int(), 0)
  assert_eq(pixels[45].to_int(), 255)
  assert_eq(pixels[46].to_int(), 0)
  assert_eq(pixels[47].to_int(), 0)
}

///|
test "load_from_path: 4x4 PNG file success returns correct dimensions" {
  let path = b"testdata/test_4x4_red.png"
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_path(path, path.length(), w, h, c)
  assert_true(pixels.length() > 0)
  assert_eq(w.val, 4)
  assert_eq(h.val, 4)
  assert_eq(c.val, 3)
  assert_eq(pixels.length(), 48)
}

///|
test "load_from_path: 4x4 PNG file success returns correct pixel data" {
  let path = b"testdata/test_4x4_red.png"
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_path(path, path.length(), w, h, c)
  // RGB order: R=255, G=0, B=0
  assert_eq(pixels[0].to_int(), 255)
  assert_eq(pixels[1].to_int(), 0)
  assert_eq(pixels[2].to_int(), 0)
}

///|
test "load_from_path: non-existent file failure returns zero-length and zero dims" {
  let path = b"testdata/nonexistent_file_xyz.bmp"
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_path(path, path.length(), w, h, c)
  assert_eq(pixels.length(), 0)
  assert_eq(w.val, 0)
  assert_eq(h.val, 0)
  assert_eq(c.val, 0)
}

///|
test "load_from_path: empty path boundary returns zero-length and zero dims" {
  let path = b""
  let w = Ref(0)
  let h = Ref(0)
  let c = Ref(0)
  let pixels = test_load_from_path(path, 0, w, h, c)
  assert_eq(pixels.length(), 0)
  assert_eq(w.val, 0)
  assert_eq(h.val, 0)
  assert_eq(c.val, 0)
}
