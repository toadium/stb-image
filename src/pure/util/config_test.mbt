// 纯 MoonBit 全局配置测试
// 覆盖所有 set/get 函数

///|
test "config: flip_vertically_on_load" {
  @util.set_flip_vertically_on_load_pure(true)
  assert_true(@util.get_flip_vertically_on_load_pure())
  @util.set_flip_vertically_on_load_pure(false)
  assert_false(@util.get_flip_vertically_on_load_pure())
}

///|
test "config: flip_vertically_on_write" {
  @util.flip_vertically_on_write_pure(true)
  assert_true(@util.get_flip_vertically_on_write_pure())
  @util.flip_vertically_on_write_pure(false)
  assert_false(@util.get_flip_vertically_on_write_pure())
}

///|
test "config: unpremultiply_on_load" {
  @util.set_unpremultiply_on_load_pure(true)
  assert_true(@util.get_unpremultiply_on_load_pure())
  @util.set_unpremultiply_on_load_pure(false)
  assert_false(@util.get_unpremultiply_on_load_pure())
}

///|
test "config: convert_iphone_png_to_rgb" {
  @util.convert_iphone_png_to_rgb_pure(true)
  assert_true(@util.get_convert_iphone_png_to_rgb_pure())
  @util.convert_iphone_png_to_rgb_pure(false)
  assert_false(@util.get_convert_iphone_png_to_rgb_pure())
}

///|
test "config: hdr_to_ldr_gamma" {
  @util.hdr_to_ldr_gamma_pure(2.2F)
  assert_eq(@util.get_hdr_to_ldr_gamma_pure(), 2.2F)
  @util.hdr_to_ldr_gamma_pure(1.0F)
  assert_eq(@util.get_hdr_to_ldr_gamma_pure(), 1.0F)
}

///|
test "config: hdr_to_ldr_scale" {
  @util.hdr_to_ldr_scale_pure(0.5F)
  assert_eq(@util.get_hdr_to_ldr_scale_pure(), 0.5F)
  @util.hdr_to_ldr_scale_pure(1.0F)
  assert_eq(@util.get_hdr_to_ldr_scale_pure(), 1.0F)
}

///|
test "config: ldr_to_hdr_gamma" {
  @util.ldr_to_hdr_gamma_pure(2.2F)
  assert_eq(@util.get_ldr_to_hdr_gamma_pure(), 2.2F)
  @util.ldr_to_hdr_gamma_pure(1.0F)
  assert_eq(@util.get_ldr_to_hdr_gamma_pure(), 1.0F)
}

///|
test "config: ldr_to_hdr_scale" {
  @util.ldr_to_hdr_scale_pure(2.0F)
  assert_eq(@util.get_ldr_to_hdr_scale_pure(), 2.0F)
  @util.ldr_to_hdr_scale_pure(1.0F)
  assert_eq(@util.get_ldr_to_hdr_scale_pure(), 1.0F)
}
