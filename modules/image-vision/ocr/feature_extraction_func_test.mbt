// v235.0.0 feature_extraction 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn fe_make_img(w : Int32, h : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn fe_make_img_ch(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Int32,
) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn fe_make_img_mismatch(w : Int32, h : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h + 1, b'\x00')),
  }
}

///|
fn fe_make_gradient_img() -> @types.Image {
  let w = 32
  let h = 32
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(((x + y) % 256).to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ========== hog_features 错误路径 ==========

///|
test "hog_features: width 0 raises" {
  let img = fe_make_img(0, 10, 128)
  try {
    let _ = @ocr.hog_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "hog_features: multi-channel raises" {
  let img = fe_make_img_ch(20, 20, 3, 128)
  try {
    let _ = @ocr.hog_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "hog_features: data mismatch raises" {
  let img = fe_make_img_mismatch(20, 20)
  try {
    let _ = @ocr.hog_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "hog_features: cell_size 0 raises" {
  let img = fe_make_img(20, 20, 128)
  try {
    let _ = @ocr.hog_features(img, cell_size=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "hog_features: num_bins 0 raises" {
  let img = fe_make_img(20, 20, 128)
  try {
    let _ = @ocr.hog_features(img, num_bins=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== hog_features 功能路径 ==========

///|
test "hog_features: uniform image" {
  let img = fe_make_img(16, 16, 128)
  try {
    let hog = @ocr.hog_features(img)
    assert_true(hog.features.length() >= 0)
    assert_eq(hog.cell_size, 8)
    assert_eq(hog.num_bins, 9)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "hog_features: gradient image" {
  let img = fe_make_gradient_img()
  try {
    let hog = @ocr.hog_features(img)
    assert_true(hog.features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "hog_features: with custom params" {
  let img = fe_make_gradient_img()
  try {
    let hog = @ocr.hog_features(img, cell_size=4, num_bins=12)
    assert_eq(hog.cell_size, 4)
    assert_eq(hog.num_bins, 12)
  } catch {
    _ => assert_true(false)
  }
}

// ========== lbp_features 错误路径 ==========

///|
test "lbp_features: width 0 raises" {
  let img = fe_make_img(0, 10, 128)
  try {
    let _ = @ocr.lbp_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "lbp_features: multi-channel raises" {
  let img = fe_make_img_ch(20, 20, 3, 128)
  try {
    let _ = @ocr.lbp_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "lbp_features: data mismatch raises" {
  let img = fe_make_img_mismatch(20, 20)
  try {
    let _ = @ocr.lbp_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== lbp_features 功能路径 ==========

///|
test "lbp_features: uniform image" {
  let img = fe_make_img(16, 16, 128)
  try {
    let lbp = @ocr.lbp_features(img)
    assert_true(lbp.features.length() >= 0)
    assert_eq(lbp.radius, 1)
    assert_eq(lbp.num_points, 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "lbp_features: gradient image" {
  let img = fe_make_gradient_img()
  try {
    let lbp = @ocr.lbp_features(img)
    assert_true(lbp.features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "lbp_features: with custom params" {
  let img = fe_make_gradient_img()
  try {
    let lbp = @ocr.lbp_features(img, radius=2, num_points=16, num_bins=128)
    assert_eq(lbp.radius, 2)
    assert_eq(lbp.num_points, 16)
  } catch {
    _ => assert_true(false)
  }
}

// ========== projection_features 错误路径 ==========

///|
test "projection_features: width 0 raises" {
  let img = fe_make_img(0, 10, 128)
  try {
    let _ = @ocr.projection_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "projection_features: multi-channel raises" {
  let img = fe_make_img_ch(20, 20, 3, 128)
  try {
    let _ = @ocr.projection_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "projection_features: data mismatch raises" {
  let img = fe_make_img_mismatch(20, 20)
  try {
    let _ = @ocr.projection_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== projection_features 功能路径 ==========

///|
test "projection_features: uniform image" {
  let img = fe_make_img(20, 20, 128)
  try {
    let proj = @ocr.projection_features(img)
    assert_true(proj.horizontal.length() >= 0)
    assert_true(proj.vertical.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "projection_features: gradient image" {
  let img = fe_make_gradient_img()
  try {
    let proj = @ocr.projection_features(img)
    assert_true(proj.horizontal.length() > 0)
    assert_true(proj.vertical.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== grid_features 错误路径 ==========

///|
test "grid_features: width 0 raises" {
  let img = fe_make_img(0, 10, 128)
  try {
    let _ = @ocr.grid_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "grid_features: multi-channel raises" {
  let img = fe_make_img_ch(20, 20, 3, 128)
  try {
    let _ = @ocr.grid_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "grid_features: data mismatch raises" {
  let img = fe_make_img_mismatch(20, 20)
  try {
    let _ = @ocr.grid_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== grid_features 功能路径 ==========

///|
test "grid_features: uniform image" {
  let img = fe_make_img(16, 16, 128)
  try {
    let grid = @ocr.grid_features(img)
    assert_true(grid.features.length() >= 0)
    assert_eq(grid.grid_rows, 4)
    assert_eq(grid.grid_cols, 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "grid_features: gradient image" {
  let img = fe_make_gradient_img()
  try {
    let grid = @ocr.grid_features(img)
    assert_true(grid.features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "grid_features: custom grid size" {
  let img = fe_make_gradient_img()
  try {
    let grid = @ocr.grid_features(img, grid_rows=8, grid_cols=8)
    assert_eq(grid.grid_rows, 8)
    assert_eq(grid.grid_cols, 8)
  } catch {
    _ => assert_true(false)
  }
}

// ========== statistical_features 错误路径 ==========

///|
test "statistical_features: width 0 raises" {
  let img = fe_make_img(0, 10, 128)
  try {
    let _ = @ocr.statistical_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "statistical_features: multi-channel raises" {
  let img = fe_make_img_ch(20, 20, 3, 128)
  try {
    let _ = @ocr.statistical_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "statistical_features: data mismatch raises" {
  let img = fe_make_img_mismatch(20, 20)
  try {
    let _ = @ocr.statistical_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== statistical_features 功能路径 ==========

///|
test "statistical_features: uniform image" {
  let img = fe_make_img(20, 20, 128)
  try {
    let stats = @ocr.statistical_features(img)
    assert_true(stats.mean >= 0.0 && stats.mean <= 255.0)
    assert_true(stats.std >= 0.0)
    assert_true(stats.entropy >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "statistical_features: gradient image" {
  let img = fe_make_gradient_img()
  try {
    let stats = @ocr.statistical_features(img)
    assert_true(stats.mean >= 0.0 && stats.mean <= 255.0)
    assert_true(stats.std > 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "statistical_features: black image" {
  let img = fe_make_img(20, 20, 0)
  try {
    let stats = @ocr.statistical_features(img)
    assert_true(stats.mean < 1.0)
    assert_true(stats.std < 1.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== combined_features 错误路径 ==========

///|
test "combined_features: width 0 raises" {
  let img = fe_make_img(0, 10, 128)
  try {
    let _ = @ocr.combined_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "combined_features: multi-channel raises" {
  let img = fe_make_img_ch(20, 20, 3, 128)
  try {
    let _ = @ocr.combined_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "combined_features: data mismatch raises" {
  let img = fe_make_img_mismatch(20, 20)
  try {
    let _ = @ocr.combined_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== combined_features 功能路径 ==========

///|
test "combined_features: uniform image" {
  let img = fe_make_img(16, 16, 128)
  try {
    let features = @ocr.combined_features(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "combined_features: gradient image" {
  let img = fe_make_gradient_img()
  try {
    let features = @ocr.combined_features(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}
