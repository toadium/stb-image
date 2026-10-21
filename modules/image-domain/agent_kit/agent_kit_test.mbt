// Agent-Kit 测试：Intent / Parser / Compiler / High-level API

///|
fn ak_test_image(
  width~ : Int32 = 4,
  height~ : Int32 = 4,
  value~ : Int32 = 128,
) -> @types.Image {
  {
    width,
    height,
    channels: 1,
    data: Bytes::from_array(Array::make(width * height, value.to_byte())),
  }
}

// ============================================================
// Intent 测试
// ============================================================

///|
test "@agent_kit.Intent: to_string" {
  assert_eq(@agent_kit.Intent::Denoise.to_string(), "denoise")
  assert_eq(@agent_kit.Intent::EdgeDetect.to_string(), "edge_detect")
  assert_eq(@agent_kit.Intent::Blur.to_string(), "blur")
  assert_eq(@agent_kit.Intent::Sharpen.to_string(), "sharpen")
  assert_eq(@agent_kit.Intent::Grayscale.to_string(), "grayscale")
  assert_eq(@agent_kit.Intent::Rotate.to_string(), "rotate")
  assert_eq(@agent_kit.Intent::FlipH.to_string(), "flip_horizontal")
  assert_eq(@agent_kit.Intent::Identity.to_string(), "identity")
}

///|
test "@agent_kit.Intent: matches 关键词" {
  assert_true(@agent_kit.Intent::Denoise.matches("denoise"))
  assert_true(@agent_kit.Intent::Denoise.matches("noise"))
  assert_true(@agent_kit.Intent::Denoise.matches("clean"))
  assert_false(@agent_kit.Intent::Denoise.matches("rotate"))
  assert_true(@agent_kit.Intent::EdgeDetect.matches("edge"))
  assert_true(@agent_kit.Intent::EdgeDetect.matches("edges"))
  assert_true(@agent_kit.Intent::EdgeDetect.matches("contour"))
  assert_true(@agent_kit.Intent::Blur.matches("blur"))
  assert_true(@agent_kit.Intent::Sharpen.matches("sharpen"))
  assert_true(@agent_kit.Intent::Grayscale.matches("gray"))
  assert_true(@agent_kit.Intent::Grayscale.matches("grayscale"))
  assert_true(@agent_kit.Intent::Rotate.matches("rotate"))
  assert_true(@agent_kit.Intent::FlipH.matches("flip"))
  assert_true(@agent_kit.Intent::FlipH.matches("mirror"))
}

///|
test "@agent_kit.Intent: matches 大小写不敏感" {
  assert_true(@agent_kit.Intent::Denoise.matches("Denoise"))
  assert_true(@agent_kit.Intent::EdgeDetect.matches("EDGE"))
  assert_true(@agent_kit.Intent::Blur.matches("BLUR"))
}

// ============================================================
// Parser 测试
// ============================================================

///|
test "@agent_kit.nl_parse: 单意图" {
  let intents = @agent_kit.nl_parse("denoise")
  assert_eq(intents.length(), 1)
  assert_true(intents[0] is @agent_kit.Intent::Denoise)
}

///|
test "@agent_kit.nl_parse: 多意图" {
  let intents = @agent_kit.nl_parse("denoise edge")
  assert_eq(intents.length(), 2)
}

///|
test "@agent_kit.nl_parse: 无匹配返回 Identity" {
  let intents = @agent_kit.nl_parse("xyz_unknown")
  assert_eq(intents.length(), 1)
  assert_true(intents[0] is @agent_kit.Intent::Identity)
}

///|
test "@agent_kit.nl_parse: 去重" {
  let intents = @agent_kit.nl_parse("denoise denoise noise")
  assert_eq(intents.length(), 1)
}

///|
test "@agent_kit.nl_parse: 复杂查询" {
  let intents = @agent_kit.nl_parse("denoise and detect edges then sharpen")
  assert_true(intents.length() >= 2)
}

///|
test "@agent_kit.nl_describe: 意图描述" {
  let intents = @agent_kit.nl_parse("denoise edge")
  let desc = @agent_kit.nl_describe(intents)
  assert_true(desc.length() > 0)
}

///|
test "@agent_kit.nl_describe: 空意图" {
  let desc = @agent_kit.nl_describe([])
  assert_eq(desc, "empty")
}

// ============================================================
// Compiler 测试
// ============================================================

///|
test "@agent_kit.compile: Denoise → GaussianBlur" {
  let pipeline = @agent_kit.compile([@agent_kit.Intent::Denoise])
  assert_true(pipeline.length() >= 1)
}

///|
test "@agent_kit.compile: EdgeDetect → ToScalarField + FieldGradient" {
  let pipeline = @agent_kit.compile([@agent_kit.Intent::EdgeDetect])
  assert_true(pipeline.length() >= 2)
}

///|
test "@agent_kit.compile: 多意图编译" {
  let pipeline = @agent_kit.compile([
    @agent_kit.Intent::Denoise,
    @agent_kit.Intent::EdgeDetect,
  ])
  assert_true(pipeline.length() >= 3)
}

///|
test "@agent_kit.compile: Identity → 空管道" {
  let pipeline = @agent_kit.compile([@agent_kit.Intent::Identity])
  assert_eq(pipeline.length(), 0)
}

///|
test "@agent_kit.nl_to_pipeline: 查询转管道" {
  let pipeline = @agent_kit.nl_to_pipeline("denoise")
  assert_true(pipeline.length() >= 1)
}

///|
test "@agent_kit.nl_to_description: 查询描述" {
  let desc = @agent_kit.nl_to_description("denoise edge")
  assert_true(desc.contains("intents"))
  assert_true(desc.contains("pipeline"))
}

// ============================================================
// 高层 API 测试
// ============================================================

///|
test "@agent_kit.nl_process: 去噪处理" {
  let img = ak_test_image(value=100)
  let result = @agent_kit.nl_process(img, "denoise")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "@agent_kit.nl_process: 灰度处理" {
  let img = ak_test_image(value=100)
  let result = @agent_kit.nl_process(img, "grayscale")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "@agent_kit.nl_process: 翻转处理" {
  let img = ak_test_image(value=100)
  let result = @agent_kit.nl_process(img, "flip")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "@agent_kit.nl_process: 旋转处理" {
  let img = ak_test_image(width=4, height=6, value=100)
  let result = @agent_kit.nl_process(img, "rotate")
  assert_eq(result.width, 6)
  assert_eq(result.height, 4)
}

///|
test "@agent_kit.nl_process: 复合处理" {
  let img = ak_test_image(value=128)
  let result = @agent_kit.nl_process(img, "denoise sharpen flip")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "@agent_kit.nl_preview: 预览查询" {
  let preview = @agent_kit.nl_preview("denoise edge")
  assert_true(preview.length() > 0)
}

///|
test "@agent_kit.nl_intents: 提取意图" {
  let intents = @agent_kit.nl_intents("denoise edge sharpen")
  assert_eq(intents.length(), 3)
}

///|
test "@agent_kit.nl_pipeline: 获取管道" {
  let pipeline = @agent_kit.nl_pipeline("denoise")
  assert_true(pipeline.length() >= 1)
}

// ============================================================
// E2E: 端到端自然语言处理
// ============================================================

///|
test "@agent_kit e2e: 去噪+边缘检测全流水线" {
  let img = ak_test_image(value=128)
  let value = @imgir.IRValue::VImage(img)
  let result = @agent_kit.nl_process_value(value, "denoise edge")
  assert_true(result.is_vector_field())
}

///|
test "@agent_kit e2e: 灰度+翻转+锐化全流水线" {
  let img = ak_test_image(value=100)
  let result = @agent_kit.nl_process(img, "grayscale flip sharpen")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "@agent_kit e2e: Identity 不改变图像" {
  let img = ak_test_image(value=100)
  let result = @agent_kit.nl_process(img, "unknown_operation")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "@agent_kit e2e: nl_process_value 通用值处理" {
  let img = ak_test_image(value=128)
  let value = @imgir.IRValue::VImage(img)
  let result = @agent_kit.nl_process_value(value, "denoise")
  assert_true(result.is_image())
}
