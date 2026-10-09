// v187.0.0 ocr_accuracy.mbt 测试：集成学习/数据集/特征增广/Hu矩/组合特征

///|
test "ensemble_default_config: 默认值" {
  let config = @ocr.ensemble_default_config()
  assert_eq(config.use_knn, true)
  assert_eq(config.use_template, true)
  assert_eq(config.knn_k, 3)
  assert_eq(config.voting_method, "weighted")
}

///|
test "dataset_create: 空数据集" {
  let ds = @ocr.dataset_create()
  assert_eq(ds.num_samples, 0)
  assert_eq(ds.num_classes, 0)
}

///|
test "dataset_add_sample: 添加样本" {
  let ds = @ocr.dataset_create()
  let ds2 = @ocr.dataset_add_sample(ds, [1.0, 2.0, 3.0], "A")
  assert_eq(ds2.num_samples, 1)
  assert_eq(ds2.num_classes, 1)
}

///|
test "dataset_add_sample: 多类" {
  let ds = @ocr.dataset_create()
  let ds2 = @ocr.dataset_add_sample(ds, [1.0], "A")
  let ds3 = @ocr.dataset_add_sample(ds2, [2.0], "B")
  assert_eq(ds3.num_samples, 2)
  assert_eq(ds3.num_classes, 2)
}

///|
test "dataset_stats: 基本统计" {
  let ds = @ocr.dataset_create()
  let ds2 = @ocr.dataset_add_sample(ds, [1.0], "A")
  let ds3 = @ocr.dataset_add_sample(ds2, [2.0], "A")
  let (total, classes, counts) = @ocr.dataset_stats(ds3)
  assert_eq(total, 2)
  assert_eq(classes, 1)
  assert_eq(counts.length(), 1)
}

///|
test "augment_features: 基本增广" {
  let augmented = @ocr.augment_features([0.5, 0.5, 0.5])
  assert_eq(augmented.length(), 3)
}

///|
test "hu_moments_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let features = @ocr.hu_moments_features(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_combined_ocr_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let features = @ocr.extract_combined_ocr_features(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}
