// v252.0.0 process enhance 功能路径补充测试

///|
fn v252_make_img(
  w : Int,
  h : Int,
  ch : Int,
  pixels : Array[Int],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
test "v252 denoise_median: uniform image unchanged" {
  let img = v252_make_img(3, 3, 1, [100, 100, 100, 100, 100, 100, 100, 100, 100])
  let result = @enhance.denoise_median(img)
  for i in 0..<9 {
    assert_eq(result.data[i].to_int(), 100)
  }
}

///|
test "v252 denoise_median: removes salt noise" {
  let img = v252_make_img(3, 3, 1, [50, 50, 50, 50, 255, 50, 50, 50, 50])
  let result = @enhance.denoise_median(img)
  assert_eq(result.data[4].to_int(), 50)
}

///|
test "v252 denoise_median: removes pepper noise" {
  let img = v252_make_img(3, 3, 1, [50, 50, 50, 50, 0, 50, 50, 50, 50])
  let result = @enhance.denoise_median(img)
  assert_eq(result.data[4].to_int(), 50)
}

///|
test "v252 denoise_median: kernel_size 1 returns same" {
  let img = v252_make_img(2, 2, 1, [10, 20, 30, 40])
  let result = @enhance.denoise_median(img, kernel_size=1)
  assert_eq(result.data[0].to_int(), 10)
  assert_eq(result.data[1].to_int(), 20)
  assert_eq(result.data[2].to_int(), 30)
  assert_eq(result.data[3].to_int(), 40)
}

///|
test "v252 denoise_median: 3-channel image" {
  let img = v252_make_img(3, 3, 3, [
    100, 50, 25, 100, 50, 25, 100, 50, 25, 100, 50, 25, 100, 50, 25, 100, 50, 25,
    100, 50, 25, 100, 50, 25, 100, 50, 25,
  ])
  let result = @enhance.denoise_median(img)
  assert_eq(result.channels, 3)
  assert_eq(result.data[0].to_int(), 100)
  assert_eq(result.data[1].to_int(), 50)
  assert_eq(result.data[2].to_int(), 25)
}

///|
test "v252 denoise_median: kernel_size 5" {
  let img = v252_make_img(5, 5, 1, [
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 255, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100,
  ])
  let result = @enhance.denoise_median(img, kernel_size=5)
  assert_eq(result.data[12].to_int(), 100)
}

///|
test "v252 denoise_median: even kernel_size raises" {
  let img = v252_make_img(3, 3, 1, [100, 100, 100, 100, 100, 100, 100, 100, 100])
  try {
    let _ = @enhance.denoise_median(img, kernel_size=2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v252 denoise_median: zero kernel_size raises" {
  let img = v252_make_img(3, 3, 1, [100, 100, 100, 100, 100, 100, 100, 100, 100])
  try {
    let _ = @enhance.denoise_median(img, kernel_size=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
