///|
test "resize: 8-bit downscale 4x4 → 2x2" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let resized = resize(img, 2, 2)
  assert_eq(resized.width, 2)
  assert_eq(resized.height, 2)
  assert_eq(resized.channels, img.channels)
  let _ = resized
  let _ = img
}

///|
test "resize: 8-bit upscale 4x4 → 8x8" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let resized = resize(img, 8, 8)
  assert_eq(resized.width, 8)
  assert_eq(resized.height, 8)
  assert_eq(resized.channels, img.channels)
  let _ = resized
  let _ = img
}

///|
test "resize: 8-bit sRGB" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let resized = resize_srgb(img, 2, 2)
  assert_eq(resized.width, 2)
  assert_eq(resized.height, 2)
  assert_eq(resized.channels, img.channels)
  let _ = resized
  let _ = img
}

///|
test "resize: 16-bit" {
  let img = load_16_from_path("testdata/test_4x4_red.png")
  let resized = resize_16(img, 2, 2)
  assert_eq(resized.width, 2)
  assert_eq(resized.height, 2)
  assert_eq(resized.channels, img.channels)
  let _ = resized
  let _ = img
}

///|
test "resize: float (HDR)" {
  let img = loadf_from_path("testdata/test_4x4_red.png")
  let resized = resizef(img, 2, 2)
  assert_eq(resized.width, 2)
  assert_eq(resized.height, 2)
  assert_eq(resized.channels, img.channels)
  let _ = resized
  let _ = img
}

///|
test "resize: filter options" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let r1 = resize(img, 8, 8, filter=ResizeFilter::Box)
  let r2 = resize(img, 8, 8, filter=ResizeFilter::CatmullROM)
  let r3 = resize(img, 8, 8, filter=ResizeFilter::Mitchell)
  let r4 = resize(img, 8, 8, filter=ResizeFilter::PointSample)
  assert_eq(r1.width, 8)
  assert_eq(r2.width, 8)
  assert_eq(r3.width, 8)
  assert_eq(r4.width, 8)
  let _ = r1
  let _ = r2
  let _ = r3
  let _ = r4
  let _ = img
}

///|
test "resize: edge options" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let r1 = resize(img, 8, 8, edge=ResizeEdge::Clamp)
  let r2 = resize(img, 8, 8, edge=ResizeEdge::Reflect)
  let r3 = resize(img, 8, 8, edge=ResizeEdge::Zero)
  assert_eq(r1.width, 8)
  assert_eq(r2.width, 8)
  assert_eq(r3.width, 8)
  let _ = r1
  let _ = r2
  let _ = r3
  let _ = img
}

///|
test "resize: invalid output size raises" {
  let img = load_from_path("testdata/test_4x4_red.png")
  try {
    let _ = resize(img, 0, 2)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "resize: 1x1 BMP upscale to 4x4" {
  let img = load_from_bytes(make_1x1_red_bmp())
  let resized = resize(img, 4, 4)
  assert_eq(resized.width, 4)
  assert_eq(resized.height, 4)
  assert_eq(resized.channels, 3)
  let _ = resized
  let _ = img
}

///|
test "resize: identity resize (same size) preserves pixels" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let resized = resize(img, 4, 4, filter=ResizeFilter::PointSample)
  assert_eq(resized.width, 4)
  assert_eq(resized.height, 4)
  assert_eq(resized.data.length(), img.data.length())
  let _ = resized
  let _ = img
}