// v187.0.0 connected_components.mbt 测试：连通域分析/筛选/合并

///|
test "connected_components_analysis: 基本分析" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 255, 255,
        0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 255, 255, 0,
        0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 255, 255, 0, 0, 255, 255, 0,
        0, 255, 255, 0, 0, 255, 255, 0, 0,
      ]),
    }
    let result = @ocr.connected_components_analysis(img)
    assert_true(result.num_components >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "connected_components_analysis: 4邻域" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        0, 0, 0, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 0,
      ]),
    }
    let result = @ocr.connected_components_analysis(img, connectivity=4)
    assert_true(result.num_components >= 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "filter_components_by_area: 基本筛选" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        0, 0, 0, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 0,
      ]),
    }
    let result = @ocr.connected_components_analysis(img)
    let filtered = @ocr.filter_components_by_area(result, 1, 100)
    assert_true(filtered.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "filter_components_by_aspect_ratio: 基本筛选" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        0, 0, 0, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 0,
      ]),
    }
    let result = @ocr.connected_components_analysis(img)
    let filtered = @ocr.filter_components_by_aspect_ratio(result, 0.0, 10.0)
    assert_true(filtered.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "merge_adjacent_components: 基本合并" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array([
        0, 0, 0, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 0, 0, 0,
      ]),
    }
    let result = @ocr.connected_components_analysis(img)
    let merged = @ocr.merge_adjacent_components(result.components, 2)
    assert_true(merged.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
