// 色彩量化测试：floyd_steinberg / median_cut / kmeans_quantize

///|
test "floyd_steinberg: levels=2 produces binary image" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let result = floyd_steinberg(img, 2)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  // levels=2 → 每通道只有 0 或 255
  for i in 0..<result.data.length() {
    let v = result.data[i].to_int()
    assert_true(v == 0 || v == 255)
  }
  let _ = img
  let _ = result
}

///|
test "floyd_steinberg: levels=1 is identity" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let result = floyd_steinberg(img, 1)
  assert_eq(result.data, img.data)
  let _ = img
  let _ = result
}

///|
test "floyd_steinberg: preserves alpha" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(4),
  )
  let result = floyd_steinberg(img, 4)
  assert_eq(result.data[3].to_int(), img.data[3].to_int())
  let _ = img
  let _ = result
}

///|
test "floyd_steinberg: uniform image produces valid levels" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Array::make(48, b'\x80') |> Bytes::from_array,
  }
  let result = floyd_steinberg(img, 4)
  // levels=4, step=85 → 值应为 0/85/170/255 之一
  for i in 0..<48 {
    let v = result.data[i].to_int()
    assert_true(v == 0 || v == 85 || v == 170 || v == 255)
  }
  let _ = img
  let _ = result
}

///|
test "median_cut: produces RGB output" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let result = median_cut(img, 8)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 3)
  let _ = img
  let _ = result
}

///|
test "median_cut: num_colors=2 reduces colors" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let result = median_cut(img, 2)
  // 最多 2 种不同颜色
  let colors : Array[(Int, Int, Int)] = []
  for i in 0..<(result.width * result.height) {
    let r = result.data[i * 3].to_int()
    let g = result.data[i * 3 + 1].to_int()
    let b = result.data[i * 3 + 2].to_int()
    let mut found = false
    for j in 0..<colors.length() {
      if colors[j] == (r, g, b) {
        found = true
        break
      }
    }
    if !found {
      colors.push((r, g, b))
    }
  }
  assert_true(colors.length() <= 2)
  let _ = img
  let _ = result
}

///|
test "median_cut: handles grayscale input" {
  let img = @types.Image::{
    width: 4,
    height: 1,
    channels: 1,
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array,
  }
  let result = median_cut(img, 4)
  assert_eq(result.channels, 3)
  assert_eq(result.width, 4)
  let _ = img
  let _ = result
}

///|
test "kmeans_quantize: k=1 gives single color" {
  let data : Array[Byte] = [
    b'\xFF', b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\xFF',
    b'\xFF', b'\xFF', b'\x00',
  ]
  let img = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let result = kmeans_quantize(img, 1, 20)
  // k=1 时所有像素应该是同一个颜色（平均值）
  let r0 = result.data[0]
  let g0 = result.data[1]
  let b0 = result.data[2]
  for i in 0..<4 {
    assert_eq(result.data[i * 3], r0)
    assert_eq(result.data[i * 3 + 1], g0)
    assert_eq(result.data[i * 3 + 2], b0)
  }
  let _ = img
  let _ = result
}

///|
test "kmeans_quantize: preserves channels" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Array::make(48, b'\x80') |> Bytes::from_array,
  }
  let result = kmeans_quantize(img, 4, 10)
  assert_eq(result.channels, 3)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  let _ = img
  let _ = result
}

///|
test "kmeans_quantize: RGBA preserves alpha" {
  let data : Array[Byte] = Array::make(4 * 4, b'\x80')
  for i in 0..<4 {
    data[i * 4 + 3] = b'\xFF'
  }
  let img = @types.Image::{
    width: 2,
    height: 2,
    channels: 4,
    data: Bytes::from_array(data),
  }
  let result = kmeans_quantize(img, 2, 10)
  for i in 0..<4 {
    assert_eq(result.data[i * 4 + 3], b'\xFF')
  }
  let _ = img
  let _ = result
}

///|
test "kmeans_quantize: raises on invalid k" {
  let img = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Array::make(12, b'\x80') |> Bytes::from_array,
  }
  try {
    let _ = kmeans_quantize(img, 0, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize: two distinct colors with k=2" {
  let data : Array[Byte] = [
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
    b'\xFF', b'\xFF', b'\xFF',
  ]
  let img = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let result = kmeans_quantize(img, 2, 20)
  // 前两个像素应该是同一个颜色，后两个也是同一个颜色
  assert_eq(result.data[0], result.data[3])
  assert_eq(result.data[6], result.data[9])
  let _ = img
  let _ = result
}
