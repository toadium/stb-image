// 纯 MoonBit 色彩调整测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 adjust_brightness_pure / adjust_contrast_pure / adjust_gamma_pure / invert_pure
// 及 rgb_to_hsv_pure / hsv_to_rgb_pure / rgb_to_hsl_pure / hsl_to_rgb_pure 正确性

///|
fn ca_make_image(
  width : Int,
  height : Int,
  channels : Int,
  data : Array[Byte],
) -> @types.Image {
  @types.Image::{
    width,
    height,
    channels,
    data: Bytes::from_array(data),
  }
}

///|
test "adjust_brightness_pure: delta=50" {
  // 2x2 RGB，delta=50，逐像素验证 clamp_byte(orig+50)
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = adjust_brightness_pure(img, 50)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 像素 (100,200,50) → (150,250,100)
  // 像素 (10,20,30)   → (60,70,80)
  // 像素 (255,0,128)  → (255,50,178)
  // 像素 (0,255,0)    → (50,255,50)
  assert_eq(out.data[0].to_int(), 150)
  assert_eq(out.data[1].to_int(), 250)
  assert_eq(out.data[2].to_int(), 100)
  assert_eq(out.data[3].to_int(), 60)
  assert_eq(out.data[4].to_int(), 70)
  assert_eq(out.data[5].to_int(), 80)
  assert_eq(out.data[6].to_int(), 255)
  assert_eq(out.data[7].to_int(), 50)
  assert_eq(out.data[8].to_int(), 178)
  assert_eq(out.data[9].to_int(), 50)
  assert_eq(out.data[10].to_int(), 255)
  assert_eq(out.data[11].to_int(), 50)
  let _ = img
  let _ = out
}

///|
test "adjust_brightness_pure: delta=0" {
  // delta=0 返回与原 data 完全一致
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = adjust_brightness_pure(img, 0)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "adjust_contrast_pure: factor=1.0" {
  // factor=1.0 返回与原 data 完全一致
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = adjust_contrast_pure(img, 1.0F)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "adjust_contrast_pure: factor=2.0" {
  // 2x2 RGB，factor=2.0，逐像素验证 clamp_byte((orig-128)*2+128)
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = adjust_contrast_pure(img, 2.0F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 像素 (100,200,50):  clamp((100-128)*2+128)=clamp(72)=72
  //                     clamp((200-128)*2+128)=clamp(272)=255
  //                     clamp((50-128)*2+128)=clamp(-28)=0
  // 像素 (10,20,30):    clamp((10-128)*2+128)=clamp(-108)=0
  //                     clamp((20-128)*2+128)=clamp(-88)=0
  //                     clamp((30-128)*2+128)=clamp(-68)=0
  // 像素 (255,0,128):   clamp((255-128)*2+128)=clamp(382)=255
  //                     clamp((0-128)*2+128)=clamp(-128)=0
  //                     clamp((128-128)*2+128)=clamp(128)=128
  // 像素 (0,255,0):     clamp((0-128)*2+128)=clamp(-128)=0
  //                     clamp((255-128)*2+128)=clamp(382)=255
  //                     clamp((0-128)*2+128)=clamp(-128)=0
  assert_eq(out.data[0].to_int(), 72)
  assert_eq(out.data[1].to_int(), 255)
  assert_eq(out.data[2].to_int(), 0)
  assert_eq(out.data[3].to_int(), 0)
  assert_eq(out.data[4].to_int(), 0)
  assert_eq(out.data[5].to_int(), 0)
  assert_eq(out.data[6].to_int(), 255)
  assert_eq(out.data[7].to_int(), 0)
  assert_eq(out.data[8].to_int(), 128)
  assert_eq(out.data[9].to_int(), 0)
  assert_eq(out.data[10].to_int(), 255)
  assert_eq(out.data[11].to_int(), 0)
  let _ = img
  let _ = out
}

///|
test "adjust_gamma_pure: gamma=1.0" {
  // gamma=1.0 返回与原 data 完全一致
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = adjust_gamma_pure(img, 1.0F)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "adjust_gamma_pure: gamma=2.2" {
  // 2x2 RGB，gamma=2.2，逐像素验证 clamp_byte(powf(orig/255, 2.2)*255+0.5)
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = adjust_gamma_pure(img, 2.2F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 预期值：clamp_byte(powf(orig/255, 2.2)*255+0.5)
  // 像素 (100,200,50):  powf(100/255,2.2)*255+0.5 ≈ 33.44 → 33
  //                     powf(200/255,2.2)*255+0.5 ≈ 149.48 → 149
  //                     powf(50/255,2.2)*255+0.5  ≈ 7.04   → 7
  // 像素 (10,20,30):    powf(10/255,2.2)*255+0.5  ≈ 0.25   → 0
  //                     powf(20/255,2.2)*255+0.5  ≈ 1.05   → 1
  //                     powf(30/255,2.2)*255+0.5  ≈ 2.54   → 2
  // 像素 (255,0,128):   powf(255/255,2.2)*255+0.5 = 255.5  → 255
  //                     powf(0/255,2.2)*255+0.5   = 0.5    → 0
  //                     powf(128/255,2.2)*255+0.5 ≈ 56.24  → 56
  // 像素 (0,255,0):     0, 255, 0
  assert_eq(out.data[0].to_int(), 33)
  assert_eq(out.data[1].to_int(), 149)
  assert_eq(out.data[2].to_int(), 7)
  assert_eq(out.data[3].to_int(), 0)
  assert_eq(out.data[4].to_int(), 1)
  assert_eq(out.data[5].to_int(), 2)
  assert_eq(out.data[6].to_int(), 255)
  assert_eq(out.data[7].to_int(), 0)
  assert_eq(out.data[8].to_int(), 56)
  assert_eq(out.data[9].to_int(), 0)
  assert_eq(out.data[10].to_int(), 255)
  assert_eq(out.data[11].to_int(), 0)
  let _ = img
  let _ = out
}

///|
test "invert_pure: basic" {
  // 2x2 RGB，逐像素验证 255-orig
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = invert_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 像素 (100,200,50) → (155,55,205)
  // 像素 (10,20,30)   → (245,235,225)
  // 像素 (255,0,128)  → (0,255,127)
  // 像素 (0,255,0)    → (255,0,255)
  assert_eq(out.data[0].to_int(), 155)
  assert_eq(out.data[1].to_int(), 55)
  assert_eq(out.data[2].to_int(), 205)
  assert_eq(out.data[3].to_int(), 245)
  assert_eq(out.data[4].to_int(), 235)
  assert_eq(out.data[5].to_int(), 225)
  assert_eq(out.data[6].to_int(), 0)
  assert_eq(out.data[7].to_int(), 255)
  assert_eq(out.data[8].to_int(), 127)
  assert_eq(out.data[9].to_int(), 255)
  assert_eq(out.data[10].to_int(), 0)
  assert_eq(out.data[11].to_int(), 255)
  let _ = img
  let _ = out
}

///|
test "invert_pure: double invert" {
  // invert(invert(img)) data 与原 data 完全一致
  let img = ca_make_image(
    2,
    2,
    3,
    [b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80', b'\x00', b'\xFF', b'\x00'],
  )
  let out = invert_pure(invert_pure(img))
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "invert_pure: RGBA alpha preserved" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64）
  // 验证颜色通道 255-orig 且 alpha 通道与原始完全一致
  let img = ca_make_image(
    2,
    2,
    4,
    [
      b'\x64', b'\xC8', b'\x32', b'\xFF', b'\x0A', b'\x14', b'\x1E',
      b'\x80', b'\xFF', b'\x00', b'\x80', b'\x00', b'\x00', b'\xFF',
      b'\x00', b'\x40',
    ],
  )
  let out = invert_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // 像素 0: (100,200,50,255) → (155,55,205,255)
  assert_eq(out.data[0].to_int(), 155)
  assert_eq(out.data[1].to_int(), 55)
  assert_eq(out.data[2].to_int(), 205)
  assert_eq(out.data[3].to_int(), 255)
  // 像素 1: (10,20,30,128) → (245,235,225,128)
  assert_eq(out.data[4].to_int(), 245)
  assert_eq(out.data[5].to_int(), 235)
  assert_eq(out.data[6].to_int(), 225)
  assert_eq(out.data[7].to_int(), 128)
  // 像素 2: (255,0,128,0) → (0,255,127,0)
  assert_eq(out.data[8].to_int(), 0)
  assert_eq(out.data[9].to_int(), 255)
  assert_eq(out.data[10].to_int(), 127)
  assert_eq(out.data[11].to_int(), 0)
  // 像素 3: (0,255,0,64) → (255,0,255,64)
  assert_eq(out.data[12].to_int(), 255)
  assert_eq(out.data[13].to_int(), 0)
  assert_eq(out.data[14].to_int(), 255)
  assert_eq(out.data[15].to_int(), 64)
  // 显式验证 alpha 通道与原始完全一致
  for i in 0..<4 {
    assert_eq(out.data[i * 4 + 3], img.data[i * 4 + 3])
  }
  let _ = img
  let _ = out
}

///|
test "rgb_to_hsv_pure / hsv_to_rgb_pure: roundtrip" {
  // 6 像素含黑/白边界，rgb_to_hsv 后 hsv_to_rgb，验证 r/g/b 与原始一致（允许 ±1 误差）
  let cases : Array[(Int, Int, Int)] = [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 64, 200),
    (0, 0, 0),
    (255, 255, 255),
  ]
  for i in 0..<cases.length() {
    let (r, g, b) = cases[i]
    let (h, s, v) = rgb_to_hsv_pure(r, g, b)
    let (r2, g2, b2) = hsv_to_rgb_pure(h, s, v)
    assert_true((r - r2).abs() <= 1)
    assert_true((g - g2).abs() <= 1)
    assert_true((b - b2).abs() <= 1)
  }
  // 显式验证黑/白边界：delta==0 特殊分支，h=0, s=0
  let (h_b, s_b, v_b) = rgb_to_hsv_pure(0, 0, 0)
  assert_eq(h_b, 0.0F)
  assert_eq(s_b, 0.0F)
  assert_eq(v_b, 0.0F)
  let (h_w, s_w, v_w) = rgb_to_hsv_pure(255, 255, 255)
  assert_eq(h_w, 0.0F)
  assert_eq(s_w, 0.0F)
  assert_eq(v_w, 1.0F)
}

///|
test "rgb_to_hsl_pure / hsl_to_rgb_pure: roundtrip" {
  // 6 像素含黑/白边界，rgb_to_hsl 后 hsl_to_rgb，验证 r/g/b 与原始一致（允许 ±1 误差）
  let cases : Array[(Int, Int, Int)] = [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 64, 200),
    (0, 0, 0),
    (255, 255, 255),
  ]
  for i in 0..<cases.length() {
    let (r, g, b) = cases[i]
    let (h, s, l) = rgb_to_hsl_pure(r, g, b)
    let (r2, g2, b2) = hsl_to_rgb_pure(h, s, l)
    assert_true((r - r2).abs() <= 1)
    assert_true((g - g2).abs() <= 1)
    assert_true((b - b2).abs() <= 1)
  }
  // 显式验证黑/白边界：delta==0 / mx==0.0F 特殊分支
  let (h_b, s_b, l_b) = rgb_to_hsl_pure(0, 0, 0)
  assert_eq(h_b, 0.0F)
  assert_eq(s_b, 0.0F)
  assert_eq(l_b, 0.0F)
  let (h_w, s_w, l_w) = rgb_to_hsl_pure(255, 255, 255)
  assert_eq(h_w, 0.0F)
  assert_eq(s_w, 0.0F)
  assert_eq(l_w, 1.0F)
}
