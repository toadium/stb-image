///|
test "pipeline_new: empty pipeline" {
  let p = @pipeline.pipeline_new()
  assert_eq(@pipeline.pipeline_len(p), 0)
}

///|
test "pipeline_add: single operation" {
  let p = @pipeline.pipeline_new()
  let p2 = @pipeline.pipeline_add(p, @pipeline.Operation::FlipH)
  assert_eq(@pipeline.pipeline_len(p2), 1)
}

///|
test "pipeline_add: multiple operations" {
  let p = @pipeline.pipeline_new()
  let p2 = @pipeline.pipeline_add(p, @pipeline.Operation::FlipH)
  let p3 = @pipeline.pipeline_add(p2, @pipeline.Operation::FlipV)
  let p4 = @pipeline.pipeline_add(p3, @pipeline.Operation::Grayscale)
  assert_eq(@pipeline.pipeline_len(p4), 3)
}

///|
test "pipeline_add_all: batch add" {
  let p = @pipeline.pipeline_new()
  let ops = [
    @pipeline.Operation::FlipH,
    @pipeline.Operation::FlipV,
    @pipeline.Operation::Invert,
  ]
  let p2 = @pipeline.pipeline_add_all(p, ops)
  assert_eq(@pipeline.pipeline_len(p2), 3)
}

///|
test "pipeline_describe: empty" {
  let p = @pipeline.pipeline_new()
  assert_eq(@pipeline.pipeline_describe(p), "")
}

///|
test "pipeline_describe: with operations" {
  let p = @pipeline.pipeline_new()
  let p2 = @pipeline.pipeline_add(p, @pipeline.Operation::FlipH)
  let p3 = @pipeline.pipeline_add(p2, @pipeline.Operation::Grayscale)
  let desc = @pipeline.pipeline_describe(p3)
  assert_true(desc.contains("flip_h"))
  assert_true(desc.contains("grayscale"))
}

///|
test "pipeline_describe: resize" {
  let p = @pipeline.pipeline_new()
  let p2 = @pipeline.pipeline_add(p, @pipeline.Operation::Resize(100, 200))
  let desc = @pipeline.pipeline_describe(p2)
  assert_true(desc.contains("resize"))
  assert_true(desc.contains("100"))
  assert_true(desc.contains("200"))
}

///|
test "default_batch_config: defaults" {
  let config = @pipeline.default_batch_config()
  assert_eq(config.input_format, "auto")
  assert_eq(config.output_format, "png")
  assert_eq(config.output_suffix, "_processed")
  assert_false(config.parallel)
}

///|
test "batch_task: create" {
  let p = @pipeline.pipeline_new()
  let task = @pipeline.batch_task("input.png", "output.png", p)
  assert_eq(task.input_path, "input.png")
  assert_eq(task.output_path, "output.png")
}

///|
test "batch_execute: empty" {
  let result = @pipeline.batch_execute([])
  assert_eq(result.total, 0)
  assert_eq(result.succeeded, 0)
  assert_eq(result.failed, 0)
}

///|
test "batch_execute: single task" {
  let p = @pipeline.pipeline_new()
  let task = @pipeline.batch_task("input.png", "output.png", p)
  let result = @pipeline.batch_execute([task])
  assert_eq(result.total, 1)
  assert_eq(result.succeeded, 1)
}

///|
test "batch_summary: text" {
  let p = @pipeline.pipeline_new()
  let task = @pipeline.batch_task("input.png", "output.png", p)
  let result = @pipeline.batch_execute([task])
  let summary = @pipeline.batch_summary(result)
  assert_true(summary.contains("1/1"))
}

///|
test "cli_parse: help" {
  let cmd = @pipeline.cli_parse([])
  assert_true(cmd is @pipeline.CliCommand::Help)
}

///|
test "cli_parse: convert" {
  let cmd = @pipeline.cli_parse(["convert", "input.png", "output.jpg"])
  assert_true(cmd is @pipeline.CliCommand::Convert("input.png", "output.jpg"))
}

///|
test "cli_parse: resize" {
  let cmd = @pipeline.cli_parse(["resize", "in.png", "out.png", "100", "200"])
  assert_true(
    cmd is @pipeline.CliCommand::Resize("in.png", "out.png", 100, 200),
  )
}

///|
test "cli_parse: info" {
  let cmd = @pipeline.cli_parse(["info", "test.png"])
  assert_true(cmd is @pipeline.CliCommand::Info("test.png"))
}

///|
test "cli_parse: unknown" {
  let cmd = @pipeline.cli_parse(["unknown"])
  assert_true(cmd is @pipeline.CliCommand::Help)
}

///|
test "cli_help: contains usage" {
  let help = @pipeline.cli_help()
  assert_true(help.contains("stb-image CLI"))
  assert_true(help.contains("convert"))
  assert_true(help.contains("resize"))
}
