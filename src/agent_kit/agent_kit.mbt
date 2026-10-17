// Agent-Kit 高层 API — 自然语言图像处理
// nl_process: "给这张图去噪并检测边缘" → 引擎原生算子执行

///|
pub fn nl_process(
  image : @types.Image,
  query : String,
) -> @types.Image raise @types.LoadError {
  let pipeline = nl_to_pipeline(query)
  let result = @imgir.ir_execute(pipeline, @imgir.IRValue::VImage(image))
  result.as_image()
}

///|
pub fn nl_process_value(
  value : @imgir.IRValue,
  query : String,
) -> @imgir.IRValue raise @types.LoadError {
  let pipeline = nl_to_pipeline(query)
  @imgir.ir_execute(pipeline, value)
}

///|
pub fn nl_preview(query : String) -> String {
  nl_to_description(query)
}

///|
pub fn nl_intents(query : String) -> Array[Intent] {
  nl_parse(query)
}

///|
pub fn nl_pipeline(query : String) -> @imgir.IRPipeline {
  nl_to_pipeline(query)
}
