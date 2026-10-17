// segmentation.mbt 功能测试：watershed_segment / region_growing / threshold_otsu / segmentation_to_color

///|
fn make_gradient_img(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = ((x + y) * 10 % 256).to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn make_bimodal_img(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = if x < w / 2 { b'\x00' } else { b'\xFF' }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn make_rgb_blocks_img(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * 3, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * 3
      if x < w / 2 && y < h / 2 {
        data[idx] = b'\xFF'
      } else if x >= w / 2 && y < h / 2 {
        data[idx + 1] = b'\xFF'
      } else if x < w / 2 && y >= h / 2 {
        data[idx + 2] = b'\xFF'
      } else {
        data[idx] = b'\xFF'
        data[idx + 1] = b'\xFF'
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
test "segf: watershed_default_config 返回默认值" {
  let cfg = @segment.watershed_default_config()
  assert_eq(cfg.threshold, 10.0)
  assert_eq(cfg.min_region_size, 50)
  assert_eq(cfg.connectivity, 8)
}

///|
test "segf: watershed_segment 渐变图默认配置" {
  let img = make_gradient_img(10, 10)
  let result = @segment.watershed_segment(img)
  assert_eq(result.labels.length(), 100)
  assert_true(result.num_regions >= 0)
  assert_true(result.region_sizes.length() == result.num_regions)
}

///|
test "segf: watershed_segment 自定义配置" {
  let img = make_gradient_img(10, 10)
  let cfg = @segment.WatershedConfig::{
    threshold: 5.0,
    min_region_size: 10,
    connectivity: 4,
  }
  let result = @segment.watershed_segment(img, config=cfg)
  assert_eq(result.labels.length(), 100)
  assert_true(result.num_regions >= 0)
}

///|
test "segf: watershed_segment 纯色图" {
  let data = Bytes::from_array(Array::make(100, b'\x80'))
  let img = @types.Image::{ width: 10, height: 10, channels: 1, data, }
  let result = @segment.watershed_segment(img)
  assert_eq(result.labels.length(), 100)
  assert_true(result.num_regions >= 0)
}

///|
test "segf: watershed_segment RGB图" {
  let img = make_rgb_blocks_img(12, 12)
  let result = @segment.watershed_segment(img)
  assert_eq(result.labels.length(), 144)
  assert_true(result.num_regions >= 0)
}

///|
test "segf: watershed_segment 小图3x3" {
  let data = Bytes::from_array([
    b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00',
  ])
  let img = @types.Image::{ width: 3, height: 3, channels: 1, data, }
  let result = @segment.watershed_segment(img)
  assert_eq(result.labels.length(), 9)
}

///|
test "segf: watershed_segment 大阈值" {
  let img = make_gradient_img(10, 10)
  let cfg = @segment.WatershedConfig::{
    threshold: 1000.0,
    min_region_size: 1,
    connectivity: 8,
  }
  let result = @segment.watershed_segment(img, config=cfg)
  assert_eq(result.labels.length(), 100)
}

///|
test "segf: watershed_segment connectivity=4" {
  let img = make_bimodal_img(10, 10)
  let cfg = @segment.WatershedConfig::{
    threshold: 50.0,
    min_region_size: 1,
    connectivity: 4,
  }
  let result = @segment.watershed_segment(img, config=cfg)
  assert_eq(result.labels.length(), 100)
}

///|
test "segf: region_growing 渐变图多种子" {
  let img = make_gradient_img(10, 10)
  let result = @segment.region_growing(img, [(0, 0), (9, 9), (5, 5)])
  assert_eq(result.labels.length(), 100)
  assert_true(result.num_regions >= 1)
  assert_true(result.region_sizes.length() == result.num_regions)
}

///|
test "segf: region_growing 默认阈值" {
  let img = make_gradient_img(8, 8)
  let result = @segment.region_growing(img, [(0, 0)])
  assert_eq(result.labels.length(), 64)
  assert_true(result.num_regions >= 1)
}

///|
test "segf: region_growing 自定义阈值" {
  let img = make_gradient_img(8, 8)
  let result = @segment.region_growing(img, [(0, 0), (7, 7)], threshold=100.0)
  assert_eq(result.labels.length(), 64)
  assert_true(result.num_regions >= 1)
}

///|
test "segf: region_growing 纯色图单种子" {
  let data = Bytes::from_array(Array::make(64, b'\x80'))
  let img = @types.Image::{ width: 8, height: 8, channels: 1, data, }
  let result = @segment.region_growing(img, [(0, 0)])
  assert_eq(result.labels.length(), 64)
  assert_eq(result.num_regions, 1)
  assert_eq(result.region_sizes[0], 64)
}

///|
test "segf: region_growing 种子越界跳过" {
  let img = make_gradient_img(8, 8)
  let result = @segment.region_growing(img, [(-1, -1), (100, 100), (0, 0)])
  assert_eq(result.labels.length(), 64)
  assert_true(result.num_regions >= 1)
}

///|
test "segf: region_growing 空种子" {
  let img = make_gradient_img(8, 8)
  let result = @segment.region_growing(img, [])
  assert_eq(result.labels.length(), 64)
  assert_eq(result.num_regions, 0)
}

///|
test "segf: region_growing RGB图" {
  let img = make_rgb_blocks_img(10, 10)
  let result = @segment.region_growing(img, [(0, 0), (9, 9)])
  assert_eq(result.labels.length(), 100)
  assert_true(result.num_regions >= 1)
}

///|
test "segf: region_growing 重复种子跳过" {
  let img = make_gradient_img(8, 8)
  let result = @segment.region_growing(img, [(0, 0), (0, 0), (0, 0)])
  assert_eq(result.labels.length(), 64)
  assert_eq(result.num_regions, 1)
}

///|
test "segf: threshold_otsu 双峰图" {
  let img = make_bimodal_img(10, 10)
  let result = @segment.threshold_otsu(img)
  assert_eq(result.width, 10)
  assert_eq(result.height, 10)
  assert_eq(result.channels, 1)
  let mut has_white = false
  let mut has_black = false
  for i in 0..<100 {
    let v = result.data[i].to_int()
    if v == 255 {
      has_white = true
    }
    if v == 0 {
      has_black = true
    }
  }
  assert_true(has_white)
  assert_true(has_black)
}

///|
test "segf: threshold_otsu 纯色图" {
  let data = Bytes::from_array(Array::make(100, b'\x80'))
  let img = @types.Image::{ width: 10, height: 10, channels: 1, data, }
  let result = @segment.threshold_otsu(img)
  assert_eq(result.width, 10)
  assert_eq(result.height, 10)
}

///|
test "segf: threshold_otsu RGB图" {
  let img = make_rgb_blocks_img(10, 10)
  let result = @segment.threshold_otsu(img)
  assert_eq(result.width, 10)
  assert_eq(result.height, 10)
  assert_eq(result.channels, 3)
}

///|
test "segf: threshold_otsu 渐变图" {
  let img = make_gradient_img(10, 10)
  let result = @segment.threshold_otsu(img)
  assert_eq(result.width, 10)
  assert_eq(result.height, 10)
}

///|
test "segf: segmentation_to_color 基本可视化" {
  let labels = Array::make(100, 0)
  for y in 0..<10 {
    for x in 0..<10 {
      labels[y * 10 + x] = if x < 5 { 1 } else { 2 }
    }
  }
  let result = @segment.SegmentationResult::{
    labels,
    num_regions: 2,
    region_sizes: [50, 50],
  }
  let img = @segment.segmentation_to_color(result, 10, 10)
  assert_eq(img.width, 10)
  assert_eq(img.height, 10)
  assert_eq(img.channels, 3)
}

///|
test "segf: segmentation_to_color 全零标签" {
  let labels = Array::make(64, 0)
  let result = @segment.SegmentationResult::{
    labels,
    num_regions: 0,
    region_sizes: [],
  }
  let img = @segment.segmentation_to_color(result, 8, 8)
  assert_eq(img.width, 8)
  assert_eq(img.height, 8)
  assert_eq(img.channels, 3)
  for i in 0..<192 {
    assert_eq(img.data[i], b'\x00')
  }
}

///|
test "segf: segmentation_to_color 多区域" {
  let labels = Array::make(16, 0)
  for i in 0..<16 {
    labels[i] = i % 4 + 1
  }
  let result = @segment.SegmentationResult::{
    labels,
    num_regions: 4,
    region_sizes: [4, 4, 4, 4],
  }
  let img = @segment.segmentation_to_color(result, 4, 4)
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 3)
}

///|
test "segf: segmentation_to_color 标签超出颜色表" {
  let labels = Array::make(4, 20)
  let result = @segment.SegmentationResult::{
    labels,
    num_regions: 1,
    region_sizes: [4],
  }
  let img = @segment.segmentation_to_color(result, 2, 2)
  assert_eq(img.width, 2)
  assert_eq(img.height, 2)
  for i in 0..<12 {
    assert_eq(img.data[i], b'\x00')
  }
}

///|
test "segf: watershed_segment + segmentation_to_color 流程" {
  let img = make_gradient_img(12, 12)
  let seg = @segment.watershed_segment(img)
  let vis = @segment.segmentation_to_color(seg, 12, 12)
  assert_eq(vis.width, 12)
  assert_eq(vis.height, 12)
  assert_eq(vis.channels, 3)
}

///|
test "segf: region_growing + segmentation_to_color 流程" {
  let img = make_bimodal_img(10, 10)
  let seg = @segment.region_growing(img, [(0, 0), (9, 0)])
  let vis = @segment.segmentation_to_color(seg, 10, 10)
  assert_eq(vis.width, 10)
  assert_eq(vis.height, 10)
  assert_eq(vis.channels, 3)
}
