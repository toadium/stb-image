// 可执行测试生成 — 从 TestCase 描述生成可运行 moon test 代码
// Executable test generation: from TestCase to runnable moon test code
//
// Phase 5 v281: 将 self_evolve 的测试用例描述转化为可执行的 moon test 代码字符串，
// 使自演化从"描述"走向"执行"。

///|
/// 单个可执行测试代码块。
/// Single executable test code block.
pub(all) struct ExecutableTest {
  test_name : String
  code : String
} derive(Eq, @debug.Debug)

///|
pub extend ExecutableTest with @debug.Debug::{to_repr}

///|
pub extend ExecutableTest with Eq::{not_equal, equal}

///|
/// 可执行测试文件。
/// Executable test file.
pub(all) struct ExecutableTestFile {
  file_header : String
  tests : Array[ExecutableTest]
  file_content : String
} derive(Eq, @debug.Debug)

///|
pub extend ExecutableTestFile with @debug.Debug::{to_repr}

///|
pub extend ExecutableTestFile with Eq::{not_equal, equal}

// TestCategory 转字符串

///|
fn test_category_str(cat : TestCategory) -> String {
  match cat {
    Boundary => "Boundary"
    Normal => "Normal"
    EdgeCase => "EdgeCase"
    Degradation => "Degradation"
  }
}

///|
/// 从单个 TestCase 生成可执行 moon test 代码。
/// Generate executable moon test code from a TestCase.
pub fn gen_executable_test(tc : TestCase) -> ExecutableTest {
  let name = "auto: " + tc.name
  let code = "///|\ntest \"" +
    name +
    "\" {\n  // 算子: " +
    tc.op_tag +
    "\n  // 类别: " +
    test_category_str(tc.category) +
    "\n  // 描述: " +
    tc.description +
    "\n  // 输入: " +
    tc.input_spec +
    "\n  // 期望: " +
    tc.expected_behavior +
    "\n  assert_true(true) // 占位 — 需人工填充断言\n}"
  { test_name: name, code, }
}

///|
/// 批量生成可执行测试。
/// Batch generate executable tests.
pub fn gen_executable_suite(tests : Array[TestCase]) -> Array[ExecutableTest] {
  let result : Array[ExecutableTest] = []
  for tc in tests {
    result.push(gen_executable_test(tc))
  }
  result
}

///|
/// 从可执行测试列表生成完整文件内容。
/// Generate full file content from executable tests.
pub fn gen_test_file_content(tests : Array[ExecutableTest]) -> String {
  let header = "// 自动生成测试 — by self_evolve v281.0.0\n// Auto-generated tests — by self_evolve v281.0.0\n\n"
  let mut body = ""
  for t in tests {
    body = body + "\n///|\n" + t.code + "\n"
  }
  header + body
}

///|
/// 对单个算子生成完整可执行测试文件。
/// Generate full executable test file for a single op.
pub fn gen_test_file_for_op(op : @imgir.IROp) -> ExecutableTestFile {
  let test_cases = gen_test_for_op(op)
  let exec_tests = gen_executable_suite(test_cases)
  let content = gen_test_file_content(exec_tests)
  {
    file_header: "// 算子 " + op.tag() + " 自动生成测试",
    tests: exec_tests,
    file_content: content,
  }
}

///|
/// 对全部 19 种算子生成可执行测试文件。
/// Generate executable test files for all 19 op variants.
pub fn gen_test_file_for_all() -> Array[ExecutableTestFile] {
  let result : Array[ExecutableTestFile] = []
  for op in all_ops() {
    result.push(gen_test_file_for_op(op))
  }
  result
}

///|
/// 统计可执行测试文件中的测试数。
/// Count tests in an executable test file.
pub fn ExecutableTestFile::test_count(self : ExecutableTestFile) -> Int32 {
  self.tests.length()
}

///|
/// 可执行测试文件是否非空。
/// Whether the executable test file is non-empty.
pub fn ExecutableTestFile::is_non_empty(self : ExecutableTestFile) -> Bool {
  self.tests.length() > 0
}
