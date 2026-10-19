// 病灶检测测试
// Lesion detection tests

///|
test "lesion_detect_candidates: 检测亮斑" {
  let image = [0.1, 0.1, 0.1, 0.1, 0.9, 0.1, 0.1, 0.1, 0.1]
  let candidates = @cv_advanced.lesion_detect_candidates(image, 3, 3, 1, 3, 0.5)
  assert_true(candidates.length() >= 1)
  if candidates.length() > 0 {
    assert_eq(candidates[0].x, 1)
    assert_eq(candidates[0].y, 1)
  }
}

///|
test "lesion_detect_candidates: 无候选" {
  let image = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
  let candidates = @cv_advanced.lesion_detect_candidates(image, 3, 3, 1, 3, 0.5)
  assert_eq(candidates.length(), 0)
}

///|
test "lesion_reduce_false_positives: 高阈值过滤" {
  let candidates : Array[@cv_advanced.LesionCandidate] = []
  candidates.push(@cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 1,
    score: 0.9,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  let image = [0.1, 0.1, 0.1, 0.1, 0.9, 0.1, 0.1, 0.1, 0.1]
  let result = @cv_advanced.lesion_reduce_false_positives(
    candidates, image, 3, 3, 0.3,
  )
  assert_true(result.length() <= 1)
}

///|
test "lesion_compute_sensitivity: 完美检测" {
  let detected : Array[@cv_advanced.LesionCandidate] = []
  detected.push(@cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 1,
    score: 0.9,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  let ground_truth : Array[@cv_advanced.LesionCandidate] = []
  ground_truth.push(@cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 1,
    score: 1.0,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  let (tp, fp, sens) = @cv_advanced.lesion_compute_sensitivity(
    detected, ground_truth, 2,
  )
  assert_eq(tp, 1)
  assert_eq(fp, 0)
  assert_eq(sens, 1.0)
}

///|
test "lesion_compute_sensitivity: 无检测" {
  let detected : Array[@cv_advanced.LesionCandidate] = []
  let ground_truth : Array[@cv_advanced.LesionCandidate] = []
  ground_truth.push(@cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 1,
    score: 1.0,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  let (tp, _fp, sens) = @cv_advanced.lesion_compute_sensitivity(
    detected, ground_truth, 2,
  )
  assert_eq(tp, 0)
  assert_eq(sens, 0.0)
}

///|
test "lesion_nms: 基本抑制" {
  let candidates : Array[@cv_advanced.LesionCandidate] = []
  candidates.push(@cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 2,
    score: 0.9,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  candidates.push(@cv_advanced.LesionCandidate::{
    x: 2,
    y: 1,
    radius: 2,
    score: 0.7,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  let result = @cv_advanced.lesion_nms(candidates, 0.5)
  assert_true(result.length() >= 1)
  assert_eq(result[0].score, 0.9)
}

///|
test "lesion_build_cad_result: 构建结果" {
  let detected : Array[@cv_advanced.LesionCandidate] = []
  detected.push(@cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 1,
    score: 0.9,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  let ground_truth : Array[@cv_advanced.LesionCandidate] = []
  ground_truth.push(@cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 1,
    score: 1.0,
    lesion_type: @cv_advanced.LesionType::Nodule,
  })
  let result = @cv_advanced.lesion_build_cad_result(detected, ground_truth, 2)
  assert_eq(result.num_true_positives, 1)
  assert_eq(result.num_false_positives, 0)
  assert_eq(result.sensitivity, 1.0)
}

///|
test "lesion_extract_features: 特征提取" {
  let image = [0.1, 0.1, 0.1, 0.1, 0.9, 0.1, 0.1, 0.1, 0.1]
  let candidate = @cv_advanced.LesionCandidate::{
    x: 1,
    y: 1,
    radius: 1,
    score: 0.9,
    lesion_type: @cv_advanced.LesionType::Nodule,
  }
  let features = @cv_advanced.lesion_extract_features(image, 3, 3, candidate)
  assert_eq(features.length(), 6)
  assert_true(features[0] >= 0.0)
}
