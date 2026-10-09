// v187.0.0 batch_processing.mbt 测试：批处理配置/任务创建/进度跟踪/汇总

///|
test "create_default_batch_config: 默认值" {
  let config = @ocr.create_default_batch_config()
  assert_eq(config.max_concurrent, 2)
  assert_eq(config.batch_size, 10)
  assert_eq(config.enable_progress_callback, true)
  assert_eq(config.enable_error_recovery, true)
  assert_eq(config.output_format, "markdown")
  assert_eq(config.dpi, 300)
}

///|
test "create_batch_tasks: 基本创建" {
  try {
    let tasks = @ocr.create_batch_tasks(["a.png", "b.png"], "./out", "markdown")
    assert_eq(tasks.length(), 2)
    assert_eq(tasks[0].input_path, "a.png")
    assert_eq(tasks[1].input_path, "b.png")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "create_batch_tasks: 空列表抛异常" {
  try {
    let _ = @ocr.create_batch_tasks([], "./out", "markdown")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "update_task_progress: 更新进度" {
  let task = @ocr.BatchTask::{
    task_id: "t1",
    input_path: "a.png",
    output_path: "out/a.md",
    status: @ocr.BatchTaskStatus::Processing,
    progress: 0.0,
    error_message: "",
    start_time: 0.0,
    end_time: 0.0,
    page_count: 0,
    char_count: 0,
    accuracy_estimate: 0.0,
  }
  let updated = @ocr.update_task_progress(task, 0.5, 1, 3)
  assert_true((updated.progress - 0.5).abs() < 0.01)
}

///|
test "mark_task_completed: 标记完成" {
  let task = @ocr.BatchTask::{
    task_id: "t1",
    input_path: "a.png",
    output_path: "out/a.md",
    status: @ocr.BatchTaskStatus::Processing,
    progress: 0.9,
    error_message: "",
    start_time: 0.0,
    end_time: 0.0,
    page_count: 1,
    char_count: 100,
    accuracy_estimate: 0.95,
  }
  let completed = @ocr.mark_task_completed(task, 100, 0.92, 200.0)
  assert_true(completed.status == @ocr.BatchTaskStatus::Completed)
  assert_true((completed.progress - 1.0).abs() < 0.01)
}

///|
test "mark_task_failed: 标记失败" {
  let task = @ocr.BatchTask::{
    task_id: "t1",
    input_path: "a.png",
    output_path: "out/a.md",
    status: @ocr.BatchTaskStatus::Processing,
    progress: 0.3,
    error_message: "",
    start_time: 0.0,
    end_time: 0.0,
    page_count: 0,
    char_count: 0,
    accuracy_estimate: 0.0,
  }
  let failed = @ocr.mark_task_failed(task, "file not found", 150.0)
  assert_true(failed.status == @ocr.BatchTaskStatus::Failed)
  assert_eq(failed.error_message, "file not found")
}

///|
test "calculate_batch_progress: 基本进度" {
  let tasks = [
    @ocr.BatchTask::{
      task_id: "t1",
      input_path: "a.png",
      output_path: "out/a.md",
      status: @ocr.BatchTaskStatus::Completed,
      progress: 1.0,
      error_message: "",
      start_time: 0.0,
      end_time: 100.0,
      page_count: 1,
      char_count: 100,
      accuracy_estimate: 0.95,
    },
    @ocr.BatchTask::{
      task_id: "t2",
      input_path: "b.png",
      output_path: "out/b.md",
      status: @ocr.BatchTaskStatus::Processing,
      progress: 0.5,
      error_message: "",
      start_time: 100.0,
      end_time: 0.0,
      page_count: 0,
      char_count: 0,
      accuracy_estimate: 0.0,
    },
  ]
  let progress = @ocr.calculate_batch_progress(tasks, 150.0)
  assert_eq(progress.total_tasks, 2)
  assert_eq(progress.completed_tasks, 1)
  assert_true(progress.overall_progress >= 0.0 && progress.overall_progress <= 1.0)
}

///|
test "generate_batch_summary: 基本汇总" {
  let tasks = [
    @ocr.BatchTask::{
      task_id: "t1",
      input_path: "a.png",
      output_path: "out/a.md",
      status: @ocr.BatchTaskStatus::Completed,
      progress: 1.0,
      error_message: "",
      start_time: 0.0,
      end_time: 100.0,
      page_count: 2,
      char_count: 500,
      accuracy_estimate: 0.95,
    },
  ]
  let summary = @ocr.generate_batch_summary(tasks, 100.0)
  assert_eq(summary.total_tasks, 1)
  assert_eq(summary.successful_tasks, 1)
  assert_true((summary.success_rate - 1.0).abs() < 0.01)
}

///|
test "batch_summary_to_string: 非空字符串" {
  let summary = @ocr.BatchResultSummary::{
    total_tasks: 10,
    successful_tasks: 8,
    failed_tasks: 2,
    skipped_tasks: 0,
    success_rate: 0.8,
    total_pages: 20,
    total_chars: 5000,
    total_time_ms: 1000.0,
    average_accuracy: 0.92,
    average_pages_per_second: 20.0,
    average_chars_per_second: 5000.0,
    failed_task_ids: ["t3", "t7"],
    output_files: ["out/a.md", "out/b.md"],
  }
  let str = @ocr.batch_summary_to_string(summary)
  assert_true(str.length() > 0)
}

///|
test "progress_bar_to_string: 基本进度条" {
  let bar = @ocr.progress_bar_to_string(0.5)
  assert_true(bar.length() > 0)
}

///|
test "estimate_memory_usage: 基本估算" {
  let stats = @ocr.estimate_memory_usage(3, 800, 600, 3)
  assert_true(stats.current_usage_mb >= 0.0)
  assert_true(stats.peak_usage_mb >= 0.0)
}