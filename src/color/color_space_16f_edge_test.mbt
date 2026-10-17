// color_space_16f 错误路径测试

// ========== HSL 错误路径 ==========

///|
test "cs16: rgb_to_hsl_16 负值 raise" {
  try {
    let _ = @color.rgb_to_hsl_16(-1, 100, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: rgb_to_hsl_16 超范围 raise" {
  try {
    let _ = @color.rgb_to_hsl_16(65536, 100, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: hsl_to_rgb_16 s超范围 raise" {
  try {
    let _ = @color.hsl_to_rgb_16(180.0F, 1.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: hsl_to_rgb_16 l负值 raise" {
  try {
    let _ = @color.hsl_to_rgb_16(180.0F, 0.5F, -0.1F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_hsl_f 负值 raise" {
  try {
    let _ = @color.rgb_to_hsl_f(-0.1F, 0.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_hsl_f 超范围 raise" {
  try {
    let _ = @color.rgb_to_hsl_f(1.1F, 0.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: hsl_to_rgb_f s超范围 raise" {
  try {
    let _ = @color.hsl_to_rgb_f(180.0F, 1.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: hsl_to_rgb_f l负值 raise" {
  try {
    let _ = @color.hsl_to_rgb_f(180.0F, 0.5F, -0.1F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== HSV 错误路径 ==========

///|
test "cs16: rgb_to_hsv_16 负值 raise" {
  try {
    let _ = @color.rgb_to_hsv_16(-1, 100, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: rgb_to_hsv_16 超范围 raise" {
  try {
    let _ = @color.rgb_to_hsv_16(100, 65536, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: hsv_to_rgb_16 s超范围 raise" {
  try {
    let _ = @color.hsv_to_rgb_16(180.0F, 1.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: hsv_to_rgb_16 v负值 raise" {
  try {
    let _ = @color.hsv_to_rgb_16(180.0F, 0.5F, -0.1F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_hsv_f 负值 raise" {
  try {
    let _ = @color.rgb_to_hsv_f(-0.1F, 0.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_hsv_f 超范围 raise" {
  try {
    let _ = @color.rgb_to_hsv_f(0.5F, 1.1F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: hsv_to_rgb_f s超范围 raise" {
  try {
    let _ = @color.hsv_to_rgb_f(180.0F, 1.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: hsv_to_rgb_f v负值 raise" {
  try {
    let _ = @color.hsv_to_rgb_f(180.0F, 0.5F, -0.1F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== XYZ 错误路径 ==========

///|
test "cs16: rgb_to_xyz_16 负值 raise" {
  try {
    let _ = @color.rgb_to_xyz_16(-1, 100, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: rgb_to_xyz_16 超范围 raise" {
  try {
    let _ = @color.rgb_to_xyz_16(100, 100, 65536)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: xyz_to_rgb_16 负值 raise" {
  try {
    let _ = @color.xyz_to_rgb_16(-0.1F, 0.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_xyz_f 负值 raise" {
  try {
    let _ = @color.rgb_to_xyz_f(-0.1F, 0.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_xyz_f 超范围 raise" {
  try {
    let _ = @color.rgb_to_xyz_f(0.5F, 0.5F, 1.1F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: xyz_to_rgb_f 负值 raise" {
  try {
    let _ = @color.xyz_to_rgb_f(0.5F, -0.1F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== LAB 错误路径 ==========

///|
test "cs16: rgb_to_lab_16 负值 raise" {
  try {
    let _ = @color.rgb_to_lab_16(-1, 100, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: rgb_to_lab_16 超范围 raise" {
  try {
    let _ = @color.rgb_to_lab_16(100, 65536, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: lab_to_rgb_16 L超范围 raise" {
  try {
    let _ = @color.lab_to_rgb_16(101.0F, 0.0F, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "cs16: lab_to_rgb_16 L负值 raise" {
  try {
    let _ = @color.lab_to_rgb_16(-1.0F, 0.0F, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_lab_f 负值 raise" {
  try {
    let _ = @color.rgb_to_lab_f(-0.1F, 0.5F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: rgb_to_lab_f 超范围 raise" {
  try {
    let _ = @color.rgb_to_lab_f(0.5F, 1.1F, 0.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: lab_to_rgb_f L超范围 raise" {
  try {
    let _ = @color.lab_to_rgb_f(101.0F, 0.0F, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "csf: lab_to_rgb_f L负值 raise" {
  try {
    let _ = @color.lab_to_rgb_f(-1.0F, 0.0F, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== 功能路径补充 ==========

///|
test "cs16: rgb_to_hsl_16 g最大分支" {
  let (h, s, l) = @color.rgb_to_hsl_16(100, 65535, 200)
  assert_true(h >= 0.0F && h < 360.0F)
  assert_true(s >= 0.0F && s <= 1.0F)
  assert_true(l >= 0.0F && l <= 1.0F)
}

///|
test "cs16: rgb_to_hsl_16 b最大分支" {
  let (h, s, l) = @color.rgb_to_hsl_16(100, 200, 65535)
  assert_true(h >= 0.0F && h < 360.0F)
  assert_true(s >= 0.0F && s <= 1.0F)
  assert_true(l >= 0.0F && l <= 1.0F)
}

///|
test "csf: rgb_to_hsl_f g最大分支" {
  let (h, s, l) = @color.rgb_to_hsl_f(0.2F, 1.0F, 0.3F)
  assert_true(h >= 0.0F && h < 360.0F)
  assert_true(s >= 0.0F && s <= 1.001F)
  assert_true(l >= 0.0F && l <= 1.001F)
}

///|
test "csf: rgb_to_hsl_f b最大分支" {
  let (h, s, l) = @color.rgb_to_hsl_f(0.2F, 0.3F, 1.0F)
  assert_true(h >= 0.0F && h < 360.0F)
  assert_true(s >= 0.0F && s <= 1.001F)
  assert_true(l >= 0.0F && l <= 1.001F)
}

///|
test "cs16: rgb_to_hsv_16 g最大分支" {
  let (h, s, v) = @color.rgb_to_hsv_16(100, 65535, 200)
  assert_true(h >= 0.0F && h < 360.0F)
  assert_true(s >= 0.0F && s <= 1.0F)
  assert_true(v >= 0.0F && v <= 1.0F)
}

///|
test "cs16: rgb_to_hsv_16 b最大分支" {
  let (h, s, v) = @color.rgb_to_hsv_16(100, 200, 65535)
  assert_true(h >= 0.0F && h < 360.0F)
  assert_true(s >= 0.0F && s <= 1.0F)
  assert_true(v >= 0.0F && v <= 1.0F)
}

///|
test "cs16: hsl_to_rgb_16 h负值正常化" {
  let (r, g, b) = @color.hsl_to_rgb_16(-60.0F, 0.5F, 0.5F)
  assert_true(r >= 0 && r <= 65535)
  assert_true(g >= 0 && g <= 65535)
  assert_true(b >= 0 && b <= 65535)
}

///|
test "cs16: hsv_to_rgb_16 h负值正常化" {
  let (r, g, b) = @color.hsv_to_rgb_16(-60.0F, 0.5F, 0.5F)
  assert_true(r >= 0 && r <= 65535)
  assert_true(g >= 0 && g <= 65535)
  assert_true(b >= 0 && b <= 65535)
}
