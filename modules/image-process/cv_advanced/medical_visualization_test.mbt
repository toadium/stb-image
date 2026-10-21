// 医学可视化测试
// Medical visualization tests

///|
test "medviz_window_level: 基本窗宽窗位" {
  let image = [0.0, 50.0, 100.0, 150.0, 200.0]
  let result = @cv_advanced.medviz_window_level(image, 100.0, 200.0)
  assert_eq(result.length(), 5)
  assert_eq(result[0], 0.0)
  assert_eq(result[4], 1.0)
}

///|
test "medviz_window_level: 全在窗内" {
  let image = [60.0, 80.0, 100.0]
  let result = @cv_advanced.medviz_window_level(image, 100.0, 200.0)
  assert_true(result[0] > 0.0 && result[0] < 1.0)
  assert_eq(result[2], 0.5)
}

///|
test "medviz_mpr_slice: 轴状切片" {
  let volume = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
  let result = @cv_advanced.medviz_mpr_slice(
    volume,
    2,
    2,
    2,
    @cv_advanced.MPROrientation::Axial,
    0,
  )
  assert_eq(result.length(), 4)
  assert_eq(result[0], 1.0)
}

///|
test "medviz_mpr_slice: 冠状切片" {
  let volume = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
  let result = @cv_advanced.medviz_mpr_slice(
    volume,
    2,
    2,
    2,
    @cv_advanced.MPROrientation::Coronal,
    0,
  )
  assert_eq(result.length(), 4)
  assert_eq(result[0], 1.0)
}

///|
test "medviz_mpr_slice: 矢状切片" {
  let volume = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
  let result = @cv_advanced.medviz_mpr_slice(
    volume,
    2,
    2,
    2,
    @cv_advanced.MPROrientation::Sagittal,
    0,
  )
  assert_eq(result.length(), 4)
  assert_eq(result[0], 1.0)
}

///|
test "medviz_cpr_centerline: 基本提取" {
  let volume = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
  let path : Array[(Int32, Int32, Int32)] = []
  path.push((0, 0, 0))
  path.push((1, 1, 1))
  let result = @cv_advanced.medviz_cpr_centerline(volume, 2, 2, 2, path)
  assert_eq(result.length(), 2)
  assert_eq(result[0], 1.0)
  assert_eq(result[1], 8.0)
}

///|
test "medviz_pseudo_color: 灰度方案" {
  let image = [0.0, 0.5, 1.0]
  let result = @cv_advanced.medviz_pseudo_color(image, 0)
  assert_eq(result.length(), 3)
  assert_eq(result[0], 0.0)
}

///|
test "medviz_pseudo_color: 热图方案" {
  let image = [0.0, 0.5, 1.0]
  let result = @cv_advanced.medviz_pseudo_color(image, 1)
  assert_eq(result.length(), 3)
  assert_eq(result[2], 1.0)
}

///|
test "medviz_volume_render: 基本渲染" {
  let volume = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
  let config = @cv_advanced.MedVizConfig::{
    mode: @cv_advanced.MedVizMode::VolumeRendering,
    window_center: 0.5,
    window_width: 1.0,
    opacity: 0.5,
  }
  let result = @cv_advanced.medviz_volume_render(volume, 2, 2, 2, config)
  assert_eq(result.length(), 4)
  for i in 0..<4 {
    assert_true(result[i] > 0.0)
  }
}

///|
test "medviz_depth_shading: 基本着色" {
  let volume = [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
  let result = @cv_advanced.medviz_depth_shading(volume, 2, 2, 2, 0.5)
  assert_eq(result.length(), 4)
  assert_true(result[0] > 0.0)
}

///|
test "medviz_gradient_shading: 基本梯度" {
  let volume = [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
  let result = @cv_advanced.medviz_gradient_shading(volume, 2, 2, 2)
  assert_eq(result.length(), 8)
}
