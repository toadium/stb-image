// GeoVerse 集成验证 — 端到端全栈流水线测试
// 测试 fieldimg → spatiotemporal → imgir → aoci → agent_kit 完整链路

///|
fn gv_test_image(
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

///|
fn gv_test_rgb_image(
  w : Int32,
  h : Int32,
  r : Int32,
  g : Int32,
  b : Int32,
) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(r.to_byte())
    data.push(g.to_byte())
    data.push(b.to_byte())
  }
  { width: w, height: h, channels: 3, data: Bytes::from_array(data), }
}

// ============================================================
// 集成测试：fieldimg ↔ imgir 互操作
// ============================================================

///|
test "geoverse: fieldimg → imgir 场操作管道" {
  let img = gv_test_image(value=100)
  let pipeline = @imgir.IRPipeline::new().to_scalar_field().field_gradient()
  let result = @imgir.ir_execute(pipeline, @imgir.IRValue::VImage(img))
  assert_true(result.is_vector_field())
}

///|
test "geoverse: fieldimg → imgir 往返转换" {
  let img = gv_test_image(value=200)
  let pipeline = @imgir.IRPipeline::new()
    .to_scalar_field()
    .scalar_field_to_image()
  let result = @imgir.ir_execute(pipeline, @imgir.IRValue::VImage(img))
  let out = result.as_image()
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
}

///|
test "geoverse: imgir 序列化往返保持语义" {
  let p1 = @imgir.IRPipeline::new()
    .to_gray()
    .gaussian_blur(2, 1.0F)
    .sharpen(0.5F)
  let bytes = @imgir.ir_serialize(p1)
  let p2 = @imgir.ir_deserialize(bytes)
  let img = gv_test_rgb_image(4, 4, 200, 100, 50)
  let r1 = @imgir.ir_execute(p1, @imgir.IRValue::VImage(img))
  let r2 = @imgir.ir_execute(p2, @imgir.IRValue::VImage(img))
  let o1 = r1.as_image()
  let o2 = r2.as_image()
  assert_eq(o1.width, o2.width)
  assert_eq(o1.height, o2.height)
}

// ============================================================
// 集成测试：spatiotemporal ↔ imgir 互操作
// ============================================================

///|
test "geoverse: spatiotemporal → imgir 时序快照" {
  let img = gv_test_image(value=100)
  let ti = @spatiotemporal.TImage::from_static(img)
  let pipeline = @imgir.IRPipeline::new().st_snapshot(0.0F)
  let result = @imgir.ir_execute(pipeline, @imgir.IRValue::VTImage(ti))
  let out = result.as_image()
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
}

// ============================================================
// 集成测试：agent_kit → imgir → fieldimg 全栈
// ============================================================

///|
test "geoverse: agent_kit → imgir → fieldimg 去噪+边缘" {
  let img = gv_test_image(value=128)
  let value = @imgir.IRValue::VImage(img)
  let result = @agent_kit.nl_process_value(value, "denoise edge")
  assert_true(result.is_vector_field())
}

///|
test "geoverse: agent_kit → imgir 灰度+翻转+锐化" {
  let img = gv_test_rgb_image(4, 4, 200, 100, 50)
  let result = @agent_kit.nl_process(img, "grayscale flip sharpen")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "geoverse: agent_kit → imgir 旋转" {
  let img = gv_test_image(width=4, height=6, value=100)
  let result = @agent_kit.nl_process(img, "rotate")
  assert_eq(result.width, 6)
  assert_eq(result.height, 4)
}

// ============================================================
// 集成测试：aoci 符号索引 → agent_kit 路由
// ============================================================

///|
test "geoverse: aoci 索引构建 + 路由" {
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="agent_kit",
      name="nl_process",
      kind=@aoci.SymbolKind::Function,
      signature="fn(Image, String) -> Image",
      doc="natural language image processing",
      keywords=["nl", "process", "image"],
    ),
    @aoci.SymbolCoord::make(
      pkg="imgir",
      name="ir_execute",
      kind=@aoci.SymbolKind::Function,
      signature="fn(IRPipeline, IRValue) -> IRValue",
      doc="execute IR pipeline",
      keywords=["ir", "execute", "pipeline"],
    ),
  ]
  let idx = @aoci.build_index(symbols)
  let results = @aoci.route(idx, "execute pipeline")
  assert_true(results.length() > 0)
  assert_eq(results[0].name, "ir_execute")
}

///|
test "geoverse: aoci 预算管理 + 降级" {
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="imgir",
      name="ir_execute",
      kind=@aoci.SymbolKind::Function,
      signature="fn(IRPipeline, IRValue) -> IRValue",
      keywords=["ir", "execute"],
    ),
  ]
  let idx = @aoci.build_index(symbols)
  let budget = @aoci.ContextBudget::make(10000)
  let allocated = budget.allocate(idx.symbols)
  assert_true(allocated.length() > 0)
}

///|
test "geoverse: aoci 验证索引一致性" {
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="fieldimg",
      name="field_gradient",
      kind=@aoci.SymbolKind::Function,
      keywords=["field", "gradient"],
    ),
  ]
  let idx = @aoci.build_index(symbols)
  let result = @aoci.verify_consistency(idx)
  assert_true(result.is_valid)
}

// ============================================================
// 集成测试：ImgIR 类型检查 + 描述
// ============================================================

///|
test "geoverse: imgir 类型检查 Image → VectorField" {
  let p = @imgir.IRPipeline::new().to_scalar_field().field_gradient()
  let out_tag = @imgir.ir_type_check(p, "Image")
  assert_eq(out_tag, "VectorField")
}

///|
test "geoverse: imgir 管道描述" {
  let p = @imgir.IRPipeline::new().to_gray().gaussian_blur(2, 1.0F).flip_h()
  let desc = @imgir.ir_describe(p)
  assert_eq(desc, "ToGray → GaussianBlur → FlipH")
}

// ============================================================
// E2E: 完整 GeoVerse 流水线
// ============================================================

///|
test "geoverse e2e: NL → ImgIR → fieldimg → Image" {
  let img = gv_test_image(value=150)
  let result = @agent_kit.nl_process(img, "denoise")
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "geoverse e2e: NL → ImgIR → serialize → deserialize → execute" {
  let img = gv_test_image(value=100)
  let pipeline = @agent_kit.nl_to_pipeline("denoise sharpen")
  let bytes = @imgir.ir_serialize(pipeline)
  let restored = @imgir.ir_deserialize(bytes)
  let r1 = @imgir.ir_execute(pipeline, @imgir.IRValue::VImage(img))
  let r2 = @imgir.ir_execute(restored, @imgir.IRValue::VImage(img))
  let o1 = r1.as_image()
  let o2 = r2.as_image()
  assert_eq(o1.width, o2.width)
  assert_eq(o1.height, o2.height)
}

///|
test "geoverse e2e: AOCI → NL 预览 + 意图提取" {
  let preview = @agent_kit.nl_preview("denoise edge sharpen")
  assert_true(preview.contains("intents"))
  let intents = @agent_kit.nl_intents("denoise edge")
  assert_eq(intents.length(), 2)
}

///|
test "geoverse e2e: 全栈 — Image → NL → IR → field → verify" {
  let img = gv_test_image(value=128)
  let intents = @agent_kit.nl_intents("denoise edge")
  let pipeline = @agent_kit.compile(intents)
  let type_tag = @imgir.ir_type_check(pipeline, "Image")
  let result = @imgir.ir_execute(pipeline, @imgir.IRValue::VImage(img))
  assert_true(result.is_vector_field())
  assert_eq(type_tag, "VectorField")
}
