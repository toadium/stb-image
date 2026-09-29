///|
fn create_test_image_su(w : Int, h : Int, value : Byte) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(value)
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "create_default_scene_config: returns ViT+BLIP config" {
  let config = create_default_scene_config()
  assert_eq(config.classification_threshold, 0.5)
  assert_eq(config.caption_temperature, 1.0)
  assert_eq(config.max_caption_length, 50)
  assert_true(config.use_attention)
  assert_true(config.use_scene_graph)
  assert_true(
    config.classification_algorithm
    is SceneClassificationAlgorithm::VisionTransformer,
  )
  assert_true(config.captioning_algorithm is ImageCaptioningAlgorithm::BLIP)
  assert_true(
    config.vqa_algorithm is VisualQuestionAnsweringAlgorithm::BLIP_VQA,
  )
}

///|
test "get_common_scene_types: returns scene type list" {
  let types = get_common_scene_types()
  assert_true(types.length() > 20)
  assert_true(types.contains("indoor"))
  assert_true(types.contains("outdoor"))
  assert_true(types.contains("night"))
  assert_true(types.contains("daytime"))
}

///|
test "classify_scene: dark image classified as night" {
  let config = create_default_scene_config()
  let dark_val : Byte = 30
  let image = create_test_image_su(64, 64, dark_val)
  let result = classify_scene(image, config)
  assert_eq(result.scene_type, "night")
  assert_eq(result.scene_category, "time_of_day")
  assert_eq(result.num_classes, 30)
  assert_eq(result.top_predictions.length(), 3)
  assert_eq(result.top_confidences.length(), 3)
}

///|
test "classify_scene: bright image classified as daytime" {
  let config = create_default_scene_config()
  let bright_val : Byte = 220
  let image = create_test_image_su(64, 64, bright_val)
  let result = classify_scene(image, config)
  assert_eq(result.scene_type, "daytime")
  assert_eq(result.scene_category, "time_of_day")
}

///|
test "generate_caption: generates caption for image" {
  let config = create_default_scene_config()
  let image = create_test_image_su(64, 64, 128)
  let result = generate_caption(image, config)
  assert_true(result.caption.length() > 0)
  assert_eq(result.num_captions, 4)
  assert_eq(result.alternative_captions.length(), 3)
  assert_true(result.bleu_score == 0.3)
  assert_true(result.cider_score == 0.5)
}

///|
test "answer_visual_question: scene question" {
  let config = create_default_scene_config()
  let image = create_test_image_su(64, 64, 128)
  let result = answer_visual_question(image, "What scene is this?", config)
  assert_true(result.answer.length() > 0)
  assert_eq(result.question_type, "scene_recognition")
  assert_eq(result.answer_type, "open")
  assert_eq(result.alternative_answers.length(), 3)
  assert_eq(result.reasoning_steps.length(), 4)
}

///|
test "answer_visual_question: brightness question" {
  let config = create_default_scene_config()
  let dark_val : Byte = 30
  let image = create_test_image_su(64, 64, dark_val)
  let result = answer_visual_question(image, "Is it dark or bright?", config)
  assert_eq(result.answer, "dark")
  assert_eq(result.question_type, "attribute_recognition")
}

///|
test "answer_visual_question: unknown question" {
  let config = create_default_scene_config()
  let image = create_test_image_su(64, 64, 128)
  let result = answer_visual_question(
    image, "How many people are there?", config,
  )
  assert_eq(result.question_type, "unknown")
  assert_true((result.confidence - 0.3).abs() < 0.0000000001)
}

///|
test "generate_scene_graph: generates 4 region objects" {
  let config = create_default_scene_config()
  let image = create_test_image_su(64, 64, 128)
  let graph = generate_scene_graph(image, config)
  assert_eq(graph.num_objects, 4)
  assert_eq(graph.num_relations, 4)
  assert_eq(graph.nodes.length(), 4)
  assert_eq(graph.relations.length(), 4)
  for node in graph.nodes {
    assert_eq(node.bounding_box.length(), 4)
    assert_eq(node.attributes.length(), 1)
  }
}

///|
test "understand_scene: returns full scene understanding" {
  let config = create_default_scene_config()
  let image = create_test_image_su(64, 64, 128)
  let (classification, caption, scene_graph) = understand_scene(image, config)
  assert_true(classification.scene_type.length() > 0)
  assert_true(caption.caption.length() > 0)
  assert_eq(scene_graph.num_objects, 4)
  assert_eq(scene_graph.num_relations, 4)
}

///|
test "scene_understanding_report_to_string: contains all sections" {
  let config = create_default_scene_config()
  let image = create_test_image_su(64, 64, 128)
  let classification = classify_scene(image, config)
  let caption = generate_caption(image, config)
  let vqa = answer_visual_question(image, "What scene is this?", config)
  let scene_graph = generate_scene_graph(image, config)
  let report = scene_understanding_report_to_string(
    classification, caption, vqa, scene_graph,
  )
  assert_true(report.contains("场景理解与图像描述报告"))
  assert_true(report.contains("场景分类"))
  assert_true(report.contains("图像描述"))
  assert_true(report.contains("视觉问答"))
  assert_true(report.contains("场景图"))
}
