// feature_advanced_16f 错误路径测试

///|
fn make_i16_fa(w : Int32, h : Int32, ch : Int32, val : Int32) -> @types.Image16 {
  let data : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for i in 0..<(w * h * ch) {
    data[i * 2] = (val & 0xFF).to_byte()
    data[i * 2 + 1] = ((val >> 8) & 0xFF).to_byte()
  }
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn make_if_fa(w : Int32, h : Int32, ch : Int32, val : Float) -> @types.ImageF {
  let data : Array[Byte] = Array::make(w * h * ch * 4, b'\x00')
  for i in 0..<(w * h * ch) {
    let bits = val.reinterpret_as_int()
    data[i * 4] = (bits & 0xFF).to_byte()
    data[i * 4 + 1] = ((bits >> 8) & 0xFF).to_byte()
    data[i * 4 + 2] = ((bits >> 16) & 0xFF).to_byte()
    data[i * 4 + 3] = ((bits >> 24) & 0xFF).to_byte()
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn make_i16_bad_data(w : Int32, h : Int32, ch : Int32) -> @types.Image16 {
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array([b'\x00']),
  }
}

///|
fn make_if_bad_data(w : Int32, h : Int32, ch : Int32) -> @types.ImageF {
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array([b'\x00']),
  }
}

// ========== harris_corners_16 错误路径 ==========

///|
test "fa16: harris_corners_16 零宽度 raise" {
  let img = make_i16_fa(0, 10, 1, 100)
  try {
    let _ = @feature.harris_corners_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: harris_corners_16 无效通道0 raise" {
  let img = make_i16_fa(10, 10, 0, 100)
  try {
    let _ = @feature.harris_corners_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: harris_corners_16 无效通道5 raise" {
  let img = make_i16_fa(10, 10, 5, 100)
  try {
    let _ = @feature.harris_corners_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: harris_corners_16 数据不匹配 raise" {
  let img = make_i16_bad_data(10, 10, 1)
  try {
    let _ = @feature.harris_corners_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: harris_corners_16 k<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.harris_corners_16(img, k=0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: harris_corners_16 threshold<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.harris_corners_16(img, threshold=0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: harris_corners_16 min_distance<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.harris_corners_16(img, min_distance=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== harris_corners_f 错误路径 ==========

///|
test "faf: harris_corners_f 零宽度 raise" {
  let img = make_if_fa(0, 10, 1, 0.5F)
  try {
    let _ = @feature.harris_corners_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: harris_corners_f 无效通道0 raise" {
  let img = make_if_fa(10, 10, 0, 0.5F)
  try {
    let _ = @feature.harris_corners_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: harris_corners_f 数据不匹配 raise" {
  let img = make_if_bad_data(10, 10, 1)
  try {
    let _ = @feature.harris_corners_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: harris_corners_f k<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.harris_corners_f(img, k=0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: harris_corners_f threshold<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.harris_corners_f(img, threshold=0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: harris_corners_f min_distance<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.harris_corners_f(img, min_distance=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== sift_detect_16 错误路径 ==========

///|
test "fa16: sift_detect_16 零宽度 raise" {
  let img = make_i16_fa(0, 10, 1, 100)
  try {
    let _ = @feature.sift_detect_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: sift_detect_16 无效通道0 raise" {
  let img = make_i16_fa(10, 10, 0, 100)
  try {
    let _ = @feature.sift_detect_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: sift_detect_16 数据不匹配 raise" {
  let img = make_i16_bad_data(10, 10, 1)
  try {
    let _ = @feature.sift_detect_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: sift_detect_16 max_features<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.sift_detect_16(img, max_features=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: sift_detect_16 contrast_threshold<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.sift_detect_16(img, contrast_threshold=0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== sift_detect_f 错误路径 ==========

///|
test "faf: sift_detect_f 零宽度 raise" {
  let img = make_if_fa(0, 10, 1, 0.5F)
  try {
    let _ = @feature.sift_detect_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: sift_detect_f 无效通道0 raise" {
  let img = make_if_fa(10, 10, 0, 0.5F)
  try {
    let _ = @feature.sift_detect_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: sift_detect_f 数据不匹配 raise" {
  let img = make_if_bad_data(10, 10, 1)
  try {
    let _ = @feature.sift_detect_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: sift_detect_f max_features<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.sift_detect_f(img, max_features=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: sift_detect_f contrast_threshold<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.sift_detect_f(img, contrast_threshold=0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== orb_detect_16 错误路径 ==========

///|
test "fa16: orb_detect_16 零宽度 raise" {
  let img = make_i16_fa(0, 10, 1, 100)
  try {
    let _ = @feature.orb_detect_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: orb_detect_16 无效通道0 raise" {
  let img = make_i16_fa(10, 10, 0, 100)
  try {
    let _ = @feature.orb_detect_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: orb_detect_16 数据不匹配 raise" {
  let img = make_i16_bad_data(10, 10, 1)
  try {
    let _ = @feature.orb_detect_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: orb_detect_16 max_features<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.orb_detect_16(img, max_features=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: orb_detect_16 threshold<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.orb_detect_16(img, threshold=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== orb_detect_f 错误路径 ==========

///|
test "faf: orb_detect_f 零宽度 raise" {
  let img = make_if_fa(0, 10, 1, 0.5F)
  try {
    let _ = @feature.orb_detect_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: orb_detect_f 无效通道0 raise" {
  let img = make_if_fa(10, 10, 0, 0.5F)
  try {
    let _ = @feature.orb_detect_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: orb_detect_f 数据不匹配 raise" {
  let img = make_if_bad_data(10, 10, 1)
  try {
    let _ = @feature.orb_detect_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: orb_detect_f max_features<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.orb_detect_f(img, max_features=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: orb_detect_f threshold<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.orb_detect_f(img, threshold=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== good_features_to_track_16 错误路径 ==========

///|
test "fa16: good_features_to_track_16 零宽度 raise" {
  let img = make_i16_fa(0, 10, 1, 100)
  try {
    let _ = @feature.good_features_to_track_16(img, 50, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: good_features_to_track_16 无效通道0 raise" {
  let img = make_i16_fa(10, 10, 0, 100)
  try {
    let _ = @feature.good_features_to_track_16(img, 50, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: good_features_to_track_16 数据不匹配 raise" {
  let img = make_i16_bad_data(10, 10, 1)
  try {
    let _ = @feature.good_features_to_track_16(img, 50, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: good_features_to_track_16 max_corners<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.good_features_to_track_16(img, 0, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: good_features_to_track_16 quality_level<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.good_features_to_track_16(img, 50, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "fa16: good_features_to_track_16 min_distance<=0 raise" {
  let img = make_i16_fa(10, 10, 1, 100)
  try {
    let _ = @feature.good_features_to_track_16(img, 50, 0.01F, min_distance=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== good_features_to_track_f 错误路径 ==========

///|
test "faf: good_features_to_track_f 零宽度 raise" {
  let img = make_if_fa(0, 10, 1, 0.5F)
  try {
    let _ = @feature.good_features_to_track_f(img, 50, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: good_features_to_track_f 无效通道0 raise" {
  let img = make_if_fa(10, 10, 0, 0.5F)
  try {
    let _ = @feature.good_features_to_track_f(img, 50, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: good_features_to_track_f 数据不匹配 raise" {
  let img = make_if_bad_data(10, 10, 1)
  try {
    let _ = @feature.good_features_to_track_f(img, 50, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: good_features_to_track_f max_corners<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.good_features_to_track_f(img, 0, 0.01F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: good_features_to_track_f quality_level<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.good_features_to_track_f(img, 50, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "faf: good_features_to_track_f min_distance<=0 raise" {
  let img = make_if_fa(10, 10, 1, 0.5F)
  try {
    let _ = @feature.good_features_to_track_f(img, 50, 0.01F, min_distance=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
