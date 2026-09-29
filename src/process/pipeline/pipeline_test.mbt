///|
test "pipeline_new: empty pipeline" {
  let p = pipeline_new()
  assert_eq(pipeline_len(p), 0)
}

///|
test "pipeline_add: single operation" {
  let p = pipeline_new()
  let p2 = pipeline_add(p, Operation::FlipH)
  assert_eq(pipeline_len(p2), 1)
}

///|
test "pipeline_add: multiple operations" {
  let p = pipeline_new()
  let p2 = pipeline_add(p, Operation::FlipH)
  let p3 = pipeline_add(p2, Operation::FlipV)
  let p4 = pipeline_add(p3, Operation::Grayscale)
  assert_eq(pipeline_len(p4), 3)
}

///|
test "pipeline_add_all: batch add" {
  let p = pipeline_new()
  let ops = [Operation::FlipH, Operation::FlipV, Operation::Invert]
  let p2 = pipeline_add_all(p, ops)
  assert_eq(pipeline_len(p2), 3)
}

///|
test "pipeline_describe: empty" {
  let p = pipeline_new()
  assert_eq(pipeline_describe(p), "")
}

///|
test "pipeline_describe: with operations" {
  let p = pipeline_new()
  let p2 = pipeline_add(p, Operation::FlipH)
  let p3 = pipeline_add(p2, Operation::Grayscale)
  let desc = pipeline_describe(p3)
  assert_true(desc.contains("flip_h"))
  assert_true(desc.contains("grayscale"))
}

///|
test "pipeline_describe: resize" {
  let p = pipeline_new()
  let p2 = pipeline_add(p, Operation::Resize(100, 200))
  let desc = pipeline_describe(p2)
  assert_true(desc.contains("resize"))
  assert_true(desc.contains("100"))
  assert_true(desc.contains("200"))
}

///|
test "default_batch_config: defaults" {
  let config = default_batch_config()
  assert_eq(config.input_format, "auto")
  assert_eq(config.output_format, "png")
  assert_eq(config.output_suffix, "_processed")
  assert_false(config.parallel)
}

///|
test "batch_task: create" {
  let p = pipeline_new()
  let task = batch_task("input.png", "output.png", p)
  assert_eq(task.input_path, "input.png")
  assert_eq(task.output_path, "output.png")
}

///|
test "batch_execute: empty" {
  let result = batch_execute([])
  assert_eq(result.total, 0)
  assert_eq(result.succeeded, 0)
  assert_eq(result.failed, 0)
}

///|
test "batch_execute: single task" {
  let p = pipeline_new()
  let task = batch_task("input.png", "output.png", p)
  let result = batch_execute([task])
  assert_eq(result.total, 1)
  assert_eq(result.succeeded, 1)
}

///|
test "batch_summary: text" {
  let p = pipeline_new()
  let task = batch_task("input.png", "output.png", p)
  let result = batch_execute([task])
  let summary = batch_summary(result)
  assert_true(summary.contains("1/1"))
}

///|
test "cli_parse: help" {
  let cmd = cli_parse([])
  assert_true(cmd is CliCommand::Help)
}

///|
test "cli_parse: convert" {
  let cmd = cli_parse(["convert", "input.png", "output.jpg"])
  assert_true(cmd is CliCommand::Convert("input.png", "output.jpg"))
}

///|
test "cli_parse: resize" {
  let cmd = cli_parse(["resize", "in.png", "out.png", "100", "200"])
  assert_true(cmd is CliCommand::Resize("in.png", "out.png", 100, 200))
}

///|
test "cli_parse: info" {
  let cmd = cli_parse(["info", "test.png"])
  assert_true(cmd is CliCommand::Info("test.png"))
}

///|
test "cli_parse: unknown" {
  let cmd = cli_parse(["unknown"])
  assert_true(cmd is CliCommand::Help)
}

///|
test "cli_help: contains usage" {
  let help = cli_help()
  assert_true(help.contains("stb-image CLI"))
  assert_true(help.contains("convert"))
  assert_true(help.contains("resize"))
}
