// ImgIR 测试：IRValue / IROp / IRPipeline / Builder / Executor / Serializer
// 包含类型检查、执行器、序列化往返、E2E 管道测试

///|
fn ir_test_image(
  width? : Int = 4,
  height? : Int = 4,
  value? : Int = 128,
) -> @types.Image {
  {
    width,
    height,
    channels: 1,
    data: Bytes::from_array(Array::make(width * height, value.to_byte())),
  }
}

///|
fn ir_test_rgb_image(
  w : Int,
  h : Int,
  r : Int,
  g : Int,
  b : Int,
) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(r.to_byte())
    data.push(g.to_byte())
    data.push(b.to_byte())
  }
  { width: w, height: h, channels: 3, data: Bytes::from_array(data), }
}

///|
fn ir_test_timage(
  values : Array[Int],
  dur : Float,
) -> @spatiotemporal.TImage raise @types.LoadError {
  let frames : Array[@spatiotemporal.TFrame] = []
  let mut ts = 0.0F
  for i in 0..<values.length() {
    let img : @types.Image = {
      width: 1,
      height: 1,
      channels: 1,
      data: Bytes::from_array([values[i].to_byte()]),
    }
    frames.push(@spatiotemporal.TFrame::make(img, ts, dur))
    ts = ts + dur
  }
  @spatiotemporal.TImage::make(frames, 10.0F)
}

///|
fn ir_approx_eq(a : Float, b : Float, eps : Float) -> Bool {
  let diff = a - b
  let abs_diff = if diff < 0.0F { -diff } else { diff }
  abs_diff < eps
}

// ============================================================
// IRValue 类型测试
// ============================================================

///|
test "@imgir.IRValue: type_tag 返回正确类型名" {
  let img = ir_test_image()
  let sf = @fieldimg.ScalarField::constant(2, 2, 1.0F)
  let vf = @fieldimg.VectorField::zeros(2, 2, 2)
  let ti = @spatiotemporal.TImage::from_static(img)
  assert_eq(@imgir.IRValue::VImage(img).type_tag(), "Image")
  assert_eq(@imgir.IRValue::VScalarField(sf).type_tag(), "ScalarField")
  assert_eq(@imgir.IRValue::VVectorField(vf).type_tag(), "VectorField")
  assert_eq(@imgir.IRValue::VTImage(ti).type_tag(), "TImage")
  assert_eq(@imgir.IRValue::VFloat(1.0F).type_tag(), "Float")
  assert_eq(@imgir.IRValue::VInt(42).type_tag(), "Int")
  assert_eq(@imgir.IRValue::VUnit.type_tag(), "Unit")
}

///|
test "@imgir.IRValue: is_image / is_scalar_field / is_vector_field / is_timage" {
  let img = ir_test_image()
  let sf = @fieldimg.ScalarField::constant(2, 2, 1.0F)
  let vf = @fieldimg.VectorField::zeros(2, 2, 2)
  let ti = @spatiotemporal.TImage::from_static(img)
  assert_true(@imgir.IRValue::VImage(img).is_image())
  assert_false(@imgir.IRValue::VScalarField(sf).is_image())
  assert_true(@imgir.IRValue::VScalarField(sf).is_scalar_field())
  assert_true(@imgir.IRValue::VVectorField(vf).is_vector_field())
  assert_true(@imgir.IRValue::VTImage(ti).is_timage())
}

///|
test "@imgir.IRValue: as_image 提取 Image" {
  let img = ir_test_image(value=100)
  let v = @imgir.IRValue::VImage(img)
  let extracted = v.as_image()
  assert_eq(extracted.width, 4)
  assert_eq(extracted.height, 4)
}

///|
test "@imgir.IRValue: as_image 类型不匹配抛异常" {
  let v = @imgir.IRValue::VInt(42)
  try {
    ignore(v.as_image())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ============================================================
// IROp 标签测试
// ============================================================

///|
test "@imgir.IROp: tag 返回正确操作名" {
  assert_eq(@imgir.IROp::Resize(4, 4).tag(), "Resize")
  assert_eq(@imgir.IROp::Rotate90.tag(), "Rotate90")
  assert_eq(@imgir.IROp::FlipH.tag(), "FlipH")
  assert_eq(@imgir.IROp::FlipV.tag(), "FlipV")
  assert_eq(@imgir.IROp::Crop(0, 0, 2, 2).tag(), "Crop")
  assert_eq(@imgir.IROp::ToGray.tag(), "ToGray")
  assert_eq(@imgir.IROp::Brightness(10).tag(), "Brightness")
  assert_eq(@imgir.IROp::GaussianBlur(2, 1.0F).tag(), "GaussianBlur")
  assert_eq(@imgir.IROp::BoxBlur(2).tag(), "BoxBlur")
  assert_eq(@imgir.IROp::Sharpen(0.5F).tag(), "Sharpen")
  assert_eq(@imgir.IROp::ToScalarField.tag(), "ToScalarField")
  assert_eq(@imgir.IROp::FieldGradient.tag(), "FieldGradient")
  assert_eq(@imgir.IROp::FieldLaplacian.tag(), "FieldLaplacian")
  assert_eq(@imgir.IROp::FieldIntegrate.tag(), "FieldIntegrate")
  assert_eq(@imgir.IROp::FieldClamp(0.0F, 1.0F).tag(), "FieldClamp")
  assert_eq(@imgir.IROp::FieldMask(0.5F).tag(), "FieldMask")
  assert_eq(@imgir.IROp::ScalarFieldToImage.tag(), "ScalarFieldToImage")
  assert_eq(@imgir.IROp::STSnapshot(1.0F).tag(), "STSnapshot")
  assert_eq(@imgir.IROp::STInterpolate(0.5F).tag(), "STInterpolate")
}

///|
test "@imgir.IROp: input_tag / output_tag 类型链" {
  assert_eq(@imgir.IROp::Resize(4, 4).input_tag(), "Image")
  assert_eq(@imgir.IROp::Resize(4, 4).output_tag(), "Image")
  assert_eq(@imgir.IROp::ToScalarField.input_tag(), "Image")
  assert_eq(@imgir.IROp::ToScalarField.output_tag(), "ScalarField")
  assert_eq(@imgir.IROp::FieldGradient.input_tag(), "ScalarField")
  assert_eq(@imgir.IROp::FieldGradient.output_tag(), "VectorField")
  assert_eq(@imgir.IROp::STSnapshot(1.0F).input_tag(), "TImage")
  assert_eq(@imgir.IROp::STSnapshot(1.0F).output_tag(), "Image")
}

// ============================================================
// IRPipeline Builder 测试
// ============================================================

///|
test "@imgir.IRPipeline: new 创建空管道" {
  let p = @imgir.IRPipeline::new()
  assert_eq(p.length(), 0)
}

///|
test "@imgir.IRPipeline: 链式构建器" {
  let p = @imgir.IRPipeline::new()
    .to_gray()
    .gaussian_blur(2, 1.0F)
    .sharpen(0.5F)
  assert_eq(p.length(), 3)
}

///|
test "@imgir.IRPipeline: 场操作链式构建" {
  let p = @imgir.IRPipeline::new()
    .to_scalar_field()
    .field_gradient()
    .field_laplacian()
  assert_eq(p.length(), 3)
}

///|
test "@imgir.IRPipeline: from_ops 构建" {
  let ops = [@imgir.IROp::FlipH, @imgir.IROp::FlipV, @imgir.IROp::Rotate90]
  let p = @imgir.IRPipeline::from_ops(ops)
  assert_eq(p.length(), 3)
}

// ============================================================
// IR Executor 测试
// ============================================================

///|
test "@imgir.ir_execute: 空管道返回原值" {
  let img = ir_test_image(value=100)
  let p = @imgir.IRPipeline::new()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  assert_true(result.is_image())
}

///|
test "@imgir.ir_execute: flip_h 翻转图像" {
  let img = ir_test_image(width=4, height=4, value=100)
  let p = @imgir.IRPipeline::new().flip_h()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  let out = result.as_image()
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
}

///|
test "@imgir.ir_execute: rotate_90 交换宽高" {
  let img = ir_test_image(width=4, height=6, value=100)
  let p = @imgir.IRPipeline::new().rotate_90()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  let out = result.as_image()
  assert_eq(out.width, 6)
  assert_eq(out.height, 4)
}

///|
test "@imgir.ir_execute: to_gray 转灰度" {
  let img = ir_test_rgb_image(4, 4, 255, 0, 0)
  let p = @imgir.IRPipeline::new().to_gray()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  let out = result.as_image()
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
}

///|
test "@imgir.ir_execute: brightness 调整亮度" {
  let img = ir_test_image(value=100)
  let p = @imgir.IRPipeline::new().brightness(50)
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  let out = result.as_image()
  assert_eq(out.data[0].to_int(), 150)
}

///|
test "@imgir.ir_execute: to_scalar_field → field_gradient" {
  let img = ir_test_image(value=128)
  let p = @imgir.IRPipeline::new().to_scalar_field().field_gradient()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  assert_true(result.is_vector_field())
}

///|
test "@imgir.ir_execute: to_scalar_field → field_laplacian → scalar_field_to_image" {
  let img = ir_test_image(value=128)
  let p = @imgir.IRPipeline::new()
    .to_scalar_field()
    .field_laplacian()
    .scalar_field_to_image()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  assert_true(result.is_image())
}

///|
test "@imgir.ir_execute: to_scalar_field → field_integrate 返回 Float" {
  let img = ir_test_image(value=128)
  let p = @imgir.IRPipeline::new().to_scalar_field().field_integrate()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  match result {
    @imgir.IRValue::VFloat(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "@imgir.ir_execute: st_snapshot 从 TImage 取帧" {
  let ti = ir_test_timage([10, 20, 30], 1.0F)
  let p = @imgir.IRPipeline::new().st_snapshot(0.5F)
  let result = @imgir.ir_execute(p, @imgir.IRValue::VTImage(ti))
  let out = result.as_image()
  assert_eq(out.width, 1)
  assert_eq(out.height, 1)
}

///|
test "@imgir.ir_execute: st_interpolate 从 TImage 插值" {
  let ti = ir_test_timage([0, 100], 1.0F)
  let p = @imgir.IRPipeline::new().st_interpolate(0.5F)
  let result = @imgir.ir_execute(p, @imgir.IRValue::VTImage(ti))
  let out = result.as_image()
  assert_eq(out.data[0].to_int(), 50)
}

///|
test "@imgir.ir_execute: 类型不匹配抛异常" {
  let sf = @fieldimg.ScalarField::constant(2, 2, 1.0F)
  let p = @imgir.IRPipeline::new().flip_h()
  try {
    ignore(@imgir.ir_execute(p, @imgir.IRValue::VScalarField(sf)))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ============================================================
// IR Type Check + Describe 测试
// ============================================================

///|
test "@imgir.ir_type_check: 图像操作链类型安全" {
  let p = @imgir.IRPipeline::new()
    .to_gray()
    .gaussian_blur(2, 1.0F)
    .sharpen(0.5F)
  let out_tag = @imgir.ir_type_check(p, "Image")
  assert_eq(out_tag, "Image")
}

///|
test "@imgir.ir_type_check: 场操作链类型安全" {
  let p = @imgir.IRPipeline::new().to_scalar_field().field_gradient()
  let out_tag = @imgir.ir_type_check(p, "Image")
  assert_eq(out_tag, "VectorField")
}

///|
test "@imgir.ir_type_check: 类型不匹配抛异常" {
  let p = @imgir.IRPipeline::new().flip_h()
  try {
    ignore(@imgir.ir_type_check(p, "ScalarField"))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "@imgir.ir_describe: 管道描述" {
  let p = @imgir.IRPipeline::new().to_gray().gaussian_blur(2, 1.0F)
  let desc = @imgir.ir_describe(p)
  assert_eq(desc, "ToGray → GaussianBlur")
}

///|
test "@imgir.ir_describe: 空管道描述" {
  let p = @imgir.IRPipeline::new()
  assert_eq(@imgir.ir_describe(p), "empty pipeline")
}

// ============================================================
// IR Serializer 测试
// ============================================================

///|
test "@imgir.ir_serialize: 空管道往返" {
  let p = @imgir.IRPipeline::new()
  let bytes = @imgir.ir_serialize(p)
  let restored = @imgir.ir_deserialize(bytes)
  assert_eq(restored.length(), 0)
}

///|
test "@imgir.ir_serialize: 单操作管道往返" {
  let p = @imgir.IRPipeline::new().flip_h()
  let bytes = @imgir.ir_serialize(p)
  let restored = @imgir.ir_deserialize(bytes)
  assert_eq(restored.length(), 1)
  assert_eq(restored.ops[0], @imgir.IROp::FlipH)
}

///|
test "@imgir.ir_serialize: 多操作管道往返" {
  let p = @imgir.IRPipeline::new()
    .to_gray()
    .gaussian_blur(2, 1.0F)
    .sharpen(0.5F)
    .flip_h()
    .rotate_90()
  let bytes = @imgir.ir_serialize(p)
  let restored = @imgir.ir_deserialize(bytes)
  assert_eq(restored.length(), 5)
  assert_eq(restored.ops[0], @imgir.IROp::ToGray)
  assert_eq(restored.ops[1], @imgir.IROp::GaussianBlur(2, 1.0F))
  assert_eq(restored.ops[2], @imgir.IROp::Sharpen(0.5F))
  assert_eq(restored.ops[3], @imgir.IROp::FlipH)
  assert_eq(restored.ops[4], @imgir.IROp::Rotate90)
}

///|
test "@imgir.ir_serialize: 带参数操作往返" {
  let p = @imgir.IRPipeline::new()
    .resize(8, 16)
    .crop(1, 2, 4, 6)
    .brightness(30)
    .box_blur(3)
  let bytes = @imgir.ir_serialize(p)
  let restored = @imgir.ir_deserialize(bytes)
  assert_eq(restored.ops[0], @imgir.IROp::Resize(8, 16))
  assert_eq(restored.ops[1], @imgir.IROp::Crop(1, 2, 4, 6))
  assert_eq(restored.ops[2], @imgir.IROp::Brightness(30))
  assert_eq(restored.ops[3], @imgir.IROp::BoxBlur(3))
}

///|
test "@imgir.ir_serialize: 场操作往返" {
  let p = @imgir.IRPipeline::new()
    .to_scalar_field()
    .field_gradient()
    .field_laplacian()
    .field_clamp(0.0F, 1.0F)
    .field_mask(0.5F)
    .scalar_field_to_image()
  let bytes = @imgir.ir_serialize(p)
  let restored = @imgir.ir_deserialize(bytes)
  assert_eq(restored.length(), 6)
  assert_eq(restored.ops[0], @imgir.IROp::ToScalarField)
  assert_eq(restored.ops[1], @imgir.IROp::FieldGradient)
  assert_eq(restored.ops[3], @imgir.IROp::FieldClamp(0.0F, 1.0F))
  assert_eq(restored.ops[4], @imgir.IROp::FieldMask(0.5F))
}

///|
test "@imgir.ir_serialize: 时空操作往返" {
  let p = @imgir.IRPipeline::new().st_snapshot(1.5F).st_interpolate(0.5F)
  let bytes = @imgir.ir_serialize(p)
  let restored = @imgir.ir_deserialize(bytes)
  assert_eq(restored.ops[0], @imgir.IROp::STSnapshot(1.5F))
  assert_eq(restored.ops[1], @imgir.IROp::STInterpolate(0.5F))
}

///|
test "@imgir.ir_serialize: Float 精度保持" {
  let p = @imgir.IRPipeline::new().gaussian_blur(2, 1.5F)
  let bytes = @imgir.ir_serialize(p)
  let restored = @imgir.ir_deserialize(bytes)
  match restored.ops[0] {
    @imgir.IROp::GaussianBlur(_, sigma) =>
      assert_true(ir_approx_eq(sigma, 1.5F, 0.01F))
    _ => assert_true(false)
  }
}

///|
test "@imgir.ir_deserialize: 数据过短抛异常" {
  let short_data = Bytes::from_array([b'\x00', b'\x01'])
  try {
    ignore(@imgir.ir_deserialize(short_data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ============================================================
// E2E: 端到端管道测试
// ============================================================

///|
test "@imgir e2e: 图像处理全流水线 (gray→blur→sharpen→flip)" {
  let img = ir_test_rgb_image(8, 8, 200, 100, 50)
  let p = @imgir.IRPipeline::new()
    .to_gray()
    .gaussian_blur(2, 1.0F)
    .sharpen(0.5F)
    .flip_h()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  let out = result.as_image()
  assert_eq(out.width, 8)
  assert_eq(out.height, 8)
}

///|
test "@imgir e2e: 场操作全流水线 (image→field→gradient)" {
  let img = ir_test_image(value=128)
  let p = @imgir.IRPipeline::new().to_scalar_field().field_gradient()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  assert_true(result.is_vector_field())
}

///|
test "@imgir e2e: 场阈值分割流水线 (image→field→clamp→mask→image)" {
  let img = ir_test_image(value=128)
  let p = @imgir.IRPipeline::new()
    .to_scalar_field()
    .field_clamp(0.0F, 1.0F)
    .field_mask(0.5F)
    .scalar_field_to_image()
  let result = @imgir.ir_execute(p, @imgir.IRValue::VImage(img))
  let out = result.as_image()
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
}

///|
test "@imgir e2e: 时空快照流水线 (timage→snapshot→image)" {
  let ti = ir_test_timage([10, 20, 30, 40], 0.5F)
  let p = @imgir.IRPipeline::new().st_snapshot(0.7F)
  let result = @imgir.ir_execute(p, @imgir.IRValue::VTImage(ti))
  let out = result.as_image()
  assert_eq(out.width, 1)
  assert_eq(out.height, 1)
}

///|
test "@imgir e2e: 序列化→反序列化→执行 等价性" {
  let img = ir_test_image(value=100)
  let p1 = @imgir.IRPipeline::new().brightness(50).flip_h()
  let bytes = @imgir.ir_serialize(p1)
  let p2 = @imgir.ir_deserialize(bytes)
  let r1 = @imgir.ir_execute(p1, @imgir.IRValue::VImage(img))
  let r2 = @imgir.ir_execute(p2, @imgir.IRValue::VImage(img))
  let o1 = r1.as_image()
  let o2 = r2.as_image()
  assert_eq(o1.width, o2.width)
  assert_eq(o1.height, o2.height)
  for i in 0..<o1.data.length() {
    assert_eq(o1.data[i], o2.data[i])
  }
}

///|
test "@imgir e2e: 复杂管道类型检查通过" {
  let p = @imgir.IRPipeline::new()
    .to_gray()
    .to_scalar_field()
    .field_laplacian()
    .field_clamp(0.0F, 1.0F)
    .scalar_field_to_image()
  let out_tag = @imgir.ir_type_check(p, "Image")
  assert_eq(out_tag, "Image")
}
