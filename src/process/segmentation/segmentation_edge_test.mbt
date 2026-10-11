// v224: segmentation 边界测试

///|
fn se_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn se_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn se_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn se_uniform(w : Int, h : Int, v : Int) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "se_edge: threshold_segmentation 零宽度" {
  try {
    let _ = @segmentation.threshold_segmentation(se_zero_w(), 128.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: threshold_segmentation 无效通道" {
  try {
    let _ = @segmentation.threshold_segmentation(se_bad_channels(), 128.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: threshold_segmentation 数据不匹配" {
  try {
    let _ = @segmentation.threshold_segmentation(se_mismatch(), 128.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: otsu_threshold_value 零宽度" {
  try {
    let _ = @segmentation.otsu_threshold_value(se_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: otsu_threshold_value 无效通道" {
  try {
    let _ = @segmentation.otsu_threshold_value(se_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: otsu_threshold_value 数据不匹配" {
  try {
    let _ = @segmentation.otsu_threshold_value(se_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
fn se_kmeans_config() -> @segmentation.KMeansConfig {
  @segmentation.KMeansConfig::{
    num_clusters: 3,
    max_iterations: 20,
    tolerance: 0.001,
    use_color_space: false,
    random_seed: 42,
  }
}

///|
test "se_edge: kmeans_segmentation 零宽度" {
  try {
    let _ = @segmentation.kmeans_segmentation(se_zero_w(), se_kmeans_config())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: kmeans_segmentation 无效通道" {
  try {
    let _ = @segmentation.kmeans_segmentation(
      se_bad_channels(),
      se_kmeans_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: kmeans_segmentation 数据不匹配" {
  try {
    let _ = @segmentation.kmeans_segmentation(se_mismatch(), se_kmeans_config())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: superpixel_segmentation 零宽度" {
  try {
    let _ = @segmentation.superpixel_segmentation(se_zero_w(), 16)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: superpixel_segmentation 无效通道" {
  try {
    let _ = @segmentation.superpixel_segmentation(se_bad_channels(), 16)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: superpixel_segmentation 数据不匹配" {
  try {
    let _ = @segmentation.superpixel_segmentation(se_mismatch(), 16)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
fn se_watershed_config() -> @segmentation.WatershedConfig {
  @segmentation.WatershedConfig::{
    min_region_size: 10,
    max_regions: 100,
    use_markers: false,
    connectivity: 4,
  }
}

///|
test "se_edge: watershed_segmentation 零宽度" {
  try {
    let _ = @segmentation.watershed_segmentation(
      se_zero_w(),
      se_watershed_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: watershed_segmentation 无效通道" {
  try {
    let _ = @segmentation.watershed_segmentation(
      se_bad_channels(),
      se_watershed_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: watershed_segmentation 数据不匹配" {
  try {
    let _ = @segmentation.watershed_segmentation(
      se_mismatch(),
      se_watershed_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
fn se_grabcut_config() -> @segmentation.GrabCutConfig {
  @segmentation.GrabCutConfig::{
    num_iterations: 5,
    gamma: 50.0,
    use_gmm: true,
  }
}

///|
test "se_edge: grabcut_segmentation 零宽度" {
  try {
    let _ = @segmentation.grabcut_segmentation(
      se_zero_w(),
      0,
      0,
      4,
      4,
      se_grabcut_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: grabcut_segmentation 无效通道" {
  try {
    let _ = @segmentation.grabcut_segmentation(
      se_bad_channels(),
      0,
      0,
      2,
      2,
      se_grabcut_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "se_edge: grabcut_segmentation 数据不匹配" {
  try {
    let _ = @segmentation.grabcut_segmentation(
      se_mismatch(),
      0,
      0,
      2,
      2,
      se_grabcut_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
