// 病理切片处理测试
// Pathology processing tests

///|
test "pathology_wsi_extract_tiles: 基本分块" {
  let image = [
    1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
    16.0,
  ]
  let config = @cv_advanced.WSIConfig::{
    tile_size: 2,
    overlap: 0,
    levels: 1,
    width: 4,
    height: 4,
  }
  let tiles = @cv_advanced.pathology_wsi_extract_tiles(image, 4, 4, config)
  assert_true(tiles.length() >= 4)
  assert_eq(tiles[0].length(), 4)
}

///|
test "pathology_wsi_stitch_tiles: 拼接还原" {
  let config = @cv_advanced.WSIConfig::{
    tile_size: 2,
    overlap: 0,
    levels: 1,
    width: 4,
    height: 4,
  }
  let tiles : Array[Array[Double]] = []
  tiles.push([1.0, 2.0, 5.0, 6.0])
  tiles.push([3.0, 4.0, 7.0, 8.0])
  tiles.push([9.0, 10.0, 13.0, 14.0])
  tiles.push([11.0, 12.0, 15.0, 16.0])
  let result = @cv_advanced.pathology_wsi_stitch_tiles(tiles, config)
  assert_eq(result.length(), 16)
  assert_eq(result[0], 1.0)
  assert_eq(result[15], 16.0)
}

///|
test "pathology_stain_normalize: H&E 归一化" {
  let image = [0.5, 0.6, 0.7, 0.8]
  let result = @cv_advanced.pathology_stain_normalize(
    image,
    2,
    2,
    @cv_advanced.PathologyStain::HAndE,
  )
  assert_eq(result.length(), 4)
  for i in 0..<4 {
    assert_true(result[i] >= 0.0)
  }
}

///|
test "pathology_stain_normalize: PAS 归一化" {
  let image = [0.5, 0.6, 0.7, 0.8]
  let result = @cv_advanced.pathology_stain_normalize(
    image,
    2,
    2,
    @cv_advanced.PathologyStain::PAS,
  )
  assert_eq(result.length(), 4)
}

///|
test "pathology_stain_separation: 基本分离" {
  let image = [0.5, 0.6, 0.7, 0.8]
  let result = @cv_advanced.pathology_stain_separation(image, 2, 2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.stain1.length(), 4)
  assert_eq(result.stain2.length(), 4)
}

///|
test "pathology_detect_nuclei: 检测暗点" {
  let image = [1.0, 1.0, 1.0, 1.0, 0.2, 1.0, 1.0, 1.0, 1.0]
  let nuclei = @cv_advanced.pathology_detect_nuclei(image, 3, 3, 0.5)
  assert_true(nuclei.length() >= 1)
}

///|
test "pathology_detect_nuclei: 无细胞核" {
  let image = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  let nuclei = @cv_advanced.pathology_detect_nuclei(image, 3, 3, 0.5)
  assert_eq(nuclei.length(), 0)
}

///|
test "pathology_count_mitosis: 计数" {
  let positions = [0, 1, 4, 10]
  let count = @cv_advanced.pathology_count_mitosis(positions, 5, 2)
  assert_true(count >= 0)
}

///|
test "pathology_segment_tissue: 基本分割" {
  let image = [0.1, 0.1, 0.5, 0.5, 0.9, 0.9, 0.1, 0.1, 0.5]
  let labels = @cv_advanced.pathology_segment_tissue(image, 3)
  assert_eq(labels.length(), 9)
  for i in 0..<9 {
    assert_true(labels[i] >= 0 && labels[i] < 3)
  }
}

///|
test "pathology_segment_tissue: 单簇" {
  let image = [0.5, 0.5, 0.5, 0.5]
  let labels = @cv_advanced.pathology_segment_tissue(image, 1)
  assert_eq(labels.length(), 4)
  for i in 0..<4 {
    assert_eq(labels[i], 0)
  }
}
