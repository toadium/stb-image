// 纯 MoonBit 图像混合测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 13 个 blend 混合模式函数正确性

///|
fn bl_make_rgb_image(
  width : Int,
  height : Int,
  pixels : Array[(Int, Int, Int)],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.0.to_byte())
    data.push(p.1.to_byte())
    data.push(p.2.to_byte())
  }
  @types.Image::{ width, height, channels: 3, data: Bytes::from_array(data) }
}

///|
test "blend_multiply_pure: basic" {
  // 2x2 RGB，base=[100,150,200,50], blend=[200,100,50,255]
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_multiply_pure(base, blend)
  // 逐像素手算：100*200/255=78, 150*100/255=58, 200*50/255=39, 50*255/255=50
  assert_eq(out.data[0], b'\x4E')
  assert_eq(out.data[1], b'\x3A')
  assert_eq(out.data[2], b'\x27')
  assert_eq(out.data[3], b'\x32')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_screen_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_screen_pure(base, blend)
  // 255-(255-100)*(255-200)/255=222, 255-(255-150)*(255-100)/255=192, 255-(255-200)*(255-50)/255=211, 255-(255-50)*(255-255)/255=255
  assert_eq(out.data[0], b'\xDE')
  assert_eq(out.data[1], b'\xC0')
  assert_eq(out.data[2], b'\xD3')
  assert_eq(out.data[3], b'\xFF')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_overlay_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_overlay_pure(base, blend)
  // base<128 → 2*100*200/255=156, base>=128 → 255-2*(255-150)*(255-100)/255=128, base>=128 → 255-2*(255-200)*(255-50)/255=167, base<128 → 2*50*255/255=100
  assert_eq(out.data[0], b'\x9C')
  assert_eq(out.data[1], b'\x80')
  assert_eq(out.data[2], b'\xA7')
  assert_eq(out.data[3], b'\x64')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_darken_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_darken_pure(base, blend)
  // min 逐像素：min(100,200)=100, min(150,100)=100, min(200,50)=50, min(50,255)=50
  assert_eq(out.data[0], b'\x64')
  assert_eq(out.data[1], b'\x64')
  assert_eq(out.data[2], b'\x32')
  assert_eq(out.data[3], b'\x32')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_lighten_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_lighten_pure(base, blend)
  // max 逐像素：max(100,200)=200, max(150,100)=150, max(200,50)=200, max(50,255)=255
  assert_eq(out.data[0], b'\xC8')
  assert_eq(out.data[1], b'\x96')
  assert_eq(out.data[2], b'\xC8')
  assert_eq(out.data[3], b'\xFF')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_difference_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_difference_pure(base, blend)
  // |base-blend| 逐像素：|100-200|=100, |150-100|=50, |200-50|=150, |50-255|=205
  assert_eq(out.data[0], b'\x64')
  assert_eq(out.data[1], b'\x32')
  assert_eq(out.data[2], b'\x96')
  assert_eq(out.data[3], b'\xCD')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_exclusion_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_exclusion_pure(base, blend)
  // 100+200-2*100*200/255=144, 150+100-2*150*100/255=133, 200+50-2*200*50/255=172, 50+255-2*50*255/255=205
  assert_eq(out.data[0], b'\x90')
  assert_eq(out.data[1], b'\x85')
  assert_eq(out.data[2], b'\xAC')
  assert_eq(out.data[3], b'\xCD')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_color_dodge_pure: basic" {
  // 2x2 RGB，base=[100,150,200,50], blend=[100,150,200,255]
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (255, 100, 150),
    (200, 255, 100),
    (150, 200, 255),
  ])
  let out = blend_color_dodge_pure(base, blend)
  // 100*255/(255-100)=164, 150*255/(255-150)=364→clamp 255, 200*255/(255-200)=927→clamp 255, blend=255→255
  assert_eq(out.data[0], b'\xA4')
  assert_eq(out.data[1], b'\xFF')
  assert_eq(out.data[2], b'\xFF')
  assert_eq(out.data[3], b'\xFF')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_color_burn_pure: basic" {
  // 2x2 RGB，base=[100,150,200,50], blend=[100,150,200,50]
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let out = blend_color_burn_pure(base, blend)
  // 255-(255-100)*255/100=255-395→clamp 0, 255-(255-150)*255/150=77, 255-(255-200)*255/200=185, 255-(255-50)*255/50=255-1045→clamp 0
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x4D')
  assert_eq(out.data[2], b'\xB9')
  assert_eq(out.data[3], b'\x00')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_hard_light_pure: basic" {
  // 2x2 RGB，base=[100,150,200,50], blend=[100,150,200,50]
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let out = blend_hard_light_pure(base, blend)
  // blend<128 → 2*100*100/255=78, blend>=128 → 255-2*(255-150)*(255-150)/255=169, blend>=128 → 255-2*(255-200)*(255-200)/255=232, blend<128 → 2*50*50/255=19
  assert_eq(out.data[0], b'\x4E')
  assert_eq(out.data[1], b'\xA9')
  assert_eq(out.data[2], b'\xE8')
  assert_eq(out.data[3], b'\x13')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_soft_light_pure: basic" {
  // 2x2 RGB，base=[100,150,200,50], blend=[100,150,200,50]
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let out = blend_soft_light_pure(base, blend)
  // w=200: (255-200)*100*100/65025+200*100/255=8+78=86
  // w=300: (255-300)*150*150/65025+300*150/255=-15+176=161
  // w=400: (255-400)*200*200/65025+400*200/255=-89+313=224
  // w=100: (255-100)*50*50/65025+100*50/255=5+19=24
  assert_eq(out.data[0], b'\x56')
  assert_eq(out.data[1], b'\xA1')
  assert_eq(out.data[2], b'\xE0')
  assert_eq(out.data[3], b'\x18')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_linear_dodge_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_linear_dodge_pure(base, blend)
  // min(100+200,255)=255, min(150+100,255)=250, min(200+50,255)=250, min(50+255,255)=255
  assert_eq(out.data[0], b'\xFF')
  assert_eq(out.data[1], b'\xFA')
  assert_eq(out.data[2], b'\xFA')
  assert_eq(out.data[3], b'\xFF')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_linear_burn_pure: basic" {
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(2, 2, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
  ])
  let out = blend_linear_burn_pure(base, blend)
  // max(100+200-255,0)=45, max(150+100-255,0)=0, max(200+50-255,0)=0, max(50+255-255,0)=50
  assert_eq(out.data[0], b'\x2D')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  assert_eq(out.data[3], b'\x32')
  let _ = base
  let _ = blend
  let _ = out
}

///|
test "blend_multiply_pure: dimension mismatch raises" {
  // base 2x2，blend 3x3，验证 raise LoadError::DecodeFailed
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend = bl_make_rgb_image(3, 3, [
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
    (200, 100, 50),
    (255, 200, 100),
    (50, 255, 200),
    (100, 50, 255),
    (200, 100, 50),
  ])
  let raised = try {
    let _ = blend_multiply_pure(base, blend)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = base
  let _ = blend
  let _ = raised
}

///|
test "blend_multiply_pure: channel mismatch raises" {
  // base channels=3，blend channels=4，验证 raise LoadError::DecodeFailed
  let base = bl_make_rgb_image(2, 2, [
    (100, 150, 200),
    (50, 100, 150),
    (200, 50, 100),
    (150, 200, 50),
  ])
  let blend_data : Array[Byte] = []
  for
    p in [
      (200, 100, 50, 255),
      (255, 200, 100, 128),
      (50, 255, 200, 64),
      (100, 50, 255, 0),
    ] {
    blend_data.push(p.0.to_byte())
    blend_data.push(p.1.to_byte())
    blend_data.push(p.2.to_byte())
    blend_data.push(p.3.to_byte())
  }
  let blend = @types.Image::{
    width: 2,
    height: 2,
    channels: 4,
    data: Bytes::from_array(blend_data),
  }
  let raised = try {
    let _ = blend_multiply_pure(base, blend)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = base
  let _ = blend
  let _ = raised
}
