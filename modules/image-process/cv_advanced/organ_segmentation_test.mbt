// 器官分割测试
// Organ segmentation tests

///|
test "organ_region_growing: 基本生长" {
  let image = [0.5, 0.5, 0.5, 0.1, 0.5, 0.5, 0.5, 0.5, 0.5]
  let mask = @cv_advanced.organ_region_growing(image, 3, 3, 0, 0, 0.2)
  assert_eq(mask.length(), 9)
  assert_eq(mask[0], 1)
}

///|
test "organ_region_growing: 种子越界" {
  let image = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
  let mask = @cv_advanced.organ_region_growing(image, 3, 3, 10, 10, 0.2)
  assert_eq(mask.length(), 9)
  for i in 0..<9 {
    assert_eq(mask[i], 0)
  }
}

///|
test "organ_level_set: 基本演化" {
  let image = [0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6]
  let phi = @cv_advanced.organ_level_set(image, 3, 3, 5, 0.1)
  assert_eq(phi.length(), 9)
}

///|
test "organ_atlas_based: 基本配准" {
  let image = [0.5, 0.5, 0.5, 0.5]
  let atlas = [0.5, 0.5, 0.5, 0.5]
  let atlas_mask = [1, 1, 1, 1]
  let result = @cv_advanced.organ_atlas_based(image, atlas, atlas_mask, 2, 2)
  assert_eq(result.length(), 4)
  for i in 0..<4 {
    assert_eq(result[i], 1)
  }
}

///|
test "organ_compute_volume: 计数" {
  let mask = [1, 0, 1, 0, 1, 0, 1, 0, 1]
  let vol = @cv_advanced.organ_compute_volume(mask)
  assert_eq(vol, 5)
}

///|
test "organ_dice_coefficient: 完美匹配" {
  let mask = [1, 1, 0, 0]
  let dice = @cv_advanced.organ_dice_coefficient(mask, mask)
  assert_eq(dice, 1.0)
}

///|
test "organ_dice_coefficient: 无交集" {
  let mask1 = [1, 1, 0, 0]
  let mask2 = [0, 0, 1, 1]
  let dice = @cv_advanced.organ_dice_coefficient(mask1, mask2)
  assert_eq(dice, 0.0)
}

///|
test "organ_dice_coefficient: 部分匹配" {
  let mask1 = [1, 1, 1, 0]
  let mask2 = [1, 1, 0, 0]
  let dice = @cv_advanced.organ_dice_coefficient(mask1, mask2)
  assert_true(dice > 0.0 && dice < 1.0)
}

///|
test "organ_morph_erode: 基本腐蚀" {
  let mask = [0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0]
  let result = @cv_advanced.organ_morph_erode(mask, 4, 4, 1)
  assert_eq(result.length(), 16)
}

///|
test "organ_morph_dilate: 基本膨胀" {
  let mask = [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  let result = @cv_advanced.organ_morph_dilate(mask, 4, 4, 1)
  assert_eq(result.length(), 16)
  assert_eq(result[5], 1)
}

///|
test "organ_morph_open: 开运算" {
  let mask = [0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0]
  let result = @cv_advanced.organ_morph_open(mask, 4, 4, 1)
  assert_eq(result.length(), 16)
}
