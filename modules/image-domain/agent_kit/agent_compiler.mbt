// Agent-Kit 编译器 — 意图序列 → ImgIR 管道
// compile: 将意图序列编译为 ImgIR IRPipeline

///|
pub fn compile(intents : Array[Intent]) -> @imgir.IRPipeline {
  let mut pipeline = @imgir.IRPipeline::new()
  for intent in intents {
    pipeline = apply_intent(pipeline, intent)
  }
  pipeline
}

///|
fn apply_intent(
  pipeline : @imgir.IRPipeline,
  intent : Intent,
) -> @imgir.IRPipeline {
  match intent {
    Denoise => pipeline.gaussian_blur(2, 1.0F)
    EdgeDetect => pipeline.to_scalar_field().field_gradient()
    Blur => pipeline.box_blur(2)
    Sharpen => pipeline.sharpen(0.5F)
    Grayscale => pipeline.to_gray()
    Resize(w, h) => pipeline.resize(w, h)
    Rotate => pipeline.rotate_90()
    FlipH => pipeline.flip_h()
    FlipV => pipeline.flip_v()
    Threshold(lo, hi) =>
      pipeline.to_scalar_field().field_clamp(lo, hi).scalar_field_to_image()
    Mask(t) => pipeline.to_scalar_field().field_mask(t).scalar_field_to_image()
    Identity => pipeline
  }
}

///|
pub fn nl_to_pipeline(query : String) -> @imgir.IRPipeline {
  let intents = nl_parse(query)
  compile(intents)
}

///|
pub fn nl_to_description(query : String) -> String {
  let intents = nl_parse(query)
  let intent_desc = nl_describe(intents)
  let pipeline = compile(intents)
  let pipeline_desc = @imgir.ir_describe(pipeline)
  "intents: \{intent_desc} | pipeline: \{pipeline_desc}"
}
