# walkzzz/image/process/pipeline

> 图像处理流水线编排

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 11 |
| 公开类型 | 7 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct BatchConfig {
pub struct BatchResult {
pub struct BatchTask {
pub(all) enum CliCommand {
pub(all) enum Operation {
pub struct Pipeline {
pub struct ProcessResult {
```

## API

```moonbit
pub fn batch_execute(Array[BatchTask]) -> BatchResult
pub fn batch_summary(BatchResult) -> String
pub fn batch_task(String, String, Pipeline) -> BatchTask
pub fn cli_help() -> String
pub fn cli_parse(Array[String]) -> CliCommand
pub fn default_batch_config() -> BatchConfig
pub fn pipeline_add(Pipeline, Operation) -> Pipeline
pub fn pipeline_add_all(Pipeline, Array[Operation]) -> Pipeline
pub fn pipeline_describe(Pipeline) -> String
pub fn pipeline_len(Pipeline) -> Int
pub fn pipeline_new() -> Pipeline
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
