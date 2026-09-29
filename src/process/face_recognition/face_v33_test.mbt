// v33.0.0 人脸识别与表情识别测试 — face_recognition 模块 12 函数

///|
fn create_solid_fr(w : Int, h : Int, v : Int) -> @types.Image {
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
fn create_gradient_fr(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(((x + y) * 255 / (w + h) % 256).to_byte())
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
test "create_default_face_config: 默认配置" {
  let config = create_default_face_config()
  assert_true(
    config.detection_threshold > 0.0 && config.detection_threshold < 1.0,
  )
  assert_true(
    config.recognition_threshold > 0.0 && config.recognition_threshold < 1.0,
  )
  assert_true(config.min_face_size > 0)
  assert_true(config.max_num_faces > 0)
  assert_true(config.use_landmarks)
  assert_true(config.use_alignment)
  assert_true(config.feature_dimension > 0)
}

///|
test "create_face_database: 空人脸库" {
  let db = create_face_database(FaceRecognitionAlgorithm::ArcFace, 0.5)
  assert_true(db.num_faces == 0)
  assert_true(db.faces.length() == 0)
  assert_true(db.identities.length() == 0)
  assert_true(db.threshold == 0.5)
}

///|
test "detect_faces: 渐变图像检测人脸" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  assert_true(faces.length() >= 1)
  assert_true(faces[0].num_landmarks == 5)
  assert_true(faces[0].bounding_box.length() == 4)
  assert_true(faces[0].landmarks.length() == 5)
}

///|
test "extract_face_feature: 提取特征向量" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  let feature = extract_face_feature(img, faces[0], config)
  assert_true(feature.dimension == config.feature_dimension)
  assert_true(feature.vector.length() == config.feature_dimension)
  assert_true(feature.norm > 0.0)
}

///|
test "calculate_cosine_similarity: 相同特征相似度" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  let feature = extract_face_feature(img, faces[0], config)
  let similarity = calculate_cosine_similarity(feature, feature)
  assert_true(similarity > 0.99 && similarity < 1.01)
}

///|
test "calculate_cosine_similarity: 不同维度返回0" {
  let feat1 = FaceFeature::{
    vector: [1.0, 2.0, 3.0],
    dimension: 3,
    norm: 1.0,
    is_normalized: true,
  }
  let feat2 = FaceFeature::{
    vector: [1.0, 2.0],
    dimension: 2,
    norm: 1.0,
    is_normalized: true,
  }
  let similarity = calculate_cosine_similarity(feat1, feat2)
  assert_true(similarity == 0.0)
}

///|
test "add_face_to_database: 添加人脸" {
  let db = create_face_database(FaceRecognitionAlgorithm::ArcFace, 0.5)
  let feature = FaceFeature::{
    vector: [1.0, 0.0, 0.0],
    dimension: 3,
    norm: 1.0,
    is_normalized: true,
  }
  let new_db = add_face_to_database(db, feature, "Alice")
  assert_true(new_db.num_faces == 1)
  assert_true(new_db.faces.length() == 1)
  assert_true(new_db.identities.length() == 1)
  assert_true(new_db.identities[0] == "Alice")
}

///|
test "recognize_face_in_database: 空库返回unknown" {
  let db = create_face_database(FaceRecognitionAlgorithm::ArcFace, 0.5)
  let feature = FaceFeature::{
    vector: [1.0, 0.0, 0.0],
    dimension: 3,
    norm: 1.0,
    is_normalized: true,
  }
  let result = recognize_face_in_database(db, feature, [0.0, 0.0, 100.0, 120.0])
  assert_true(!result.is_known)
  assert_true(result.identity == "unknown")
  assert_true(result.matched_face_id == -1)
}

///|
test "recognize_expression: 表情识别" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  let result = recognize_expression(img, faces[0])
  assert_true(result.num_classes == 8)
  assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  assert_true(result.dominant_expression.length() > 0)
}

///|
test "estimate_age_gender: 年龄性别估计" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  let result = estimate_age_gender(img, faces[0])
  assert_true(result.age >= 0.0)
  assert_true(result.age_range.length() == 2)
  assert_true(result.gender.length() > 0)
  assert_true(
    result.gender_confidence >= 0.0 && result.gender_confidence <= 1.0,
  )
}

///|
test "evaluate_face_quality: 质量评估" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  let quality = evaluate_face_quality(img, faces[0])
  assert_true(quality >= 0.0 && quality <= 1.0)
}

///|
test "analyze_face_attributes: 完整属性分析" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  let db = create_face_database(FaceRecognitionAlgorithm::ArcFace, 0.5)
  let analysis = analyze_face_attributes(img, faces[0], db, config)
  assert_true(analysis.face_quality >= 0.0 && analysis.face_quality <= 1.0)
  assert_true(analysis.brightness >= 0.0)
  assert_true(analysis.sharpness >= 0.0)
  assert_true(analysis.occlusion_rate >= 0.0)
}

///|
test "face_recognition_report_to_string: 报告非空" {
  let img = create_gradient_fr(128, 128)
  let config = create_default_face_config()
  let faces = detect_faces(img, config)
  let db = create_face_database(FaceRecognitionAlgorithm::ArcFace, 0.5)
  let analysis = analyze_face_attributes(img, faces[0], db, config)
  let report = face_recognition_report_to_string(analysis)
  assert_true(report.length() > 0)
}
