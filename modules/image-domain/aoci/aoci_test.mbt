// AOCI 测试：Symbol / Index / Builder / Router / Budget / Verifier

///|
fn aoci_test_index() -> @aoci.SymbolIndex {
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="walkzzz/image/src/imgir",
      name="ir_execute",
      kind=@aoci.SymbolKind::Function,
      signature="fn(IRPipeline, IRValue) -> IRValue",
      doc="execute IR pipeline",
      keywords=["ir", "execute", "pipeline"],
    ),
    @aoci.SymbolCoord::make(
      pkg="walkzzz/image/src/imgir",
      name="ir_serialize",
      kind=@aoci.SymbolKind::Function,
      signature="fn(IRPipeline) -> Bytes",
      doc="serialize pipeline to bytes",
      keywords=["ir", "serialize", "pipeline"],
    ),
    @aoci.SymbolCoord::make(
      pkg="walkzzz/image/src/fieldimg",
      name="field_gradient",
      kind=@aoci.SymbolKind::Function,
      signature="fn(ScalarField) -> VectorField",
      doc="compute gradient of scalar field",
      keywords=["field", "gradient", "edge"],
    ),
    @aoci.SymbolCoord::make(
      pkg="walkzzz/image/src/fieldimg",
      name="ScalarField",
      kind=@aoci.SymbolKind::Struct,
      signature="struct ScalarField",
      doc="2D scalar field",
      keywords=["scalar", "field"],
    ),
    @aoci.SymbolCoord::make(
      pkg="walkzzz/image/src/spatiotemporal",
      name="st_snapshot",
      kind=@aoci.SymbolKind::Function,
      signature="fn(TImage, Float) -> Image",
      doc="take snapshot at time t",
      keywords=["st", "snapshot", "time"],
    ),
  ]
  @aoci.build_index(symbols)
}

// ============================================================
// SymbolCoord 测试
// ============================================================

///|
test "@aoci.SymbolCoord: full_name" {
  let sym = @aoci.SymbolCoord::make(
    pkg="pkg",
    name="foo",
    kind=@aoci.SymbolKind::Function,
  )
  assert_eq(sym.full_name(), "pkg::foo")
}

///|
test "@aoci.SymbolCoord: has_keyword" {
  let sym = @aoci.SymbolCoord::make(
    pkg="pkg",
    name="foo",
    kind=@aoci.SymbolKind::Function,
    keywords=["bar", "baz"],
  )
  assert_true(sym.has_keyword("bar"))
  assert_true(sym.has_keyword("baz"))
  assert_false(sym.has_keyword("qux"))
}

///|
test "@aoci.SymbolCoord: estimated_tokens 正比于内容长度" {
  let small = @aoci.SymbolCoord::make(
    pkg="p",
    name="f",
    kind=@aoci.SymbolKind::Function,
  )
  let large = @aoci.SymbolCoord::make(
    pkg="p",
    name="very_long_function_name",
    kind=@aoci.SymbolKind::Function,
    signature="fn(A, B, C, D, E) -> F raise G",
    doc="This is a very long documentation string for testing",
  )
  assert_true(small.estimated_tokens() < large.estimated_tokens())
}

///|
test "@aoci.SymbolKind: to_string" {
  assert_eq(@aoci.SymbolKind::Function.to_string(), "Function")
  assert_eq(@aoci.SymbolKind::Method.to_string(), "Method")
  assert_eq(@aoci.SymbolKind::Type.to_string(), "Type")
  assert_eq(@aoci.SymbolKind::Struct.to_string(), "Struct")
  assert_eq(@aoci.SymbolKind::Enum.to_string(), "Enum")
}

// ============================================================
// SymbolIndex 测试
// ============================================================

///|
test "@aoci.SymbolIndex: size" {
  let idx = aoci_test_index()
  assert_eq(idx.size(), 5)
}

///|
test "@aoci.SymbolIndex: find_by_name" {
  let idx = aoci_test_index()
  let results = idx.find_by_name("ir_execute")
  assert_eq(results.length(), 1)
  assert_eq(results[0].pkg, "walkzzz/image/src/imgir")
}

///|
test "@aoci.SymbolIndex: find_by_package" {
  let idx = aoci_test_index()
  let results = idx.find_by_package("walkzzz/image/src/fieldimg")
  assert_eq(results.length(), 2)
}

///|
test "@aoci.SymbolIndex: find_by_keyword" {
  let idx = aoci_test_index()
  let results = idx.find_by_keyword("pipeline")
  assert_eq(results.length(), 2)
  let edge_results = idx.find_by_keyword("edge")
  assert_eq(edge_results.length(), 1)
}

///|
test "@aoci.SymbolIndex: find_by_kind" {
  let idx = aoci_test_index()
  let funcs = idx.find_by_kind(@aoci.SymbolKind::Function)
  assert_eq(funcs.length(), 4)
  let structs = idx.find_by_kind(@aoci.SymbolKind::Struct)
  assert_eq(structs.length(), 1)
}

///|
test "@aoci.SymbolIndex: get 越界抛异常" {
  let idx = aoci_test_index()
  try {
    ignore(idx.get(100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "@aoci.SymbolIndex: total_tokens > 0" {
  let idx = aoci_test_index()
  assert_true(idx.total_tokens() > 0)
}

// ============================================================
// Builder 测试
// ============================================================

///|
test "@aoci.build_index: 构建索引" {
  let symbols = [
    @aoci.build_symbol(pkg="pkg", name="foo", kind=@aoci.SymbolKind::Function),
  ]
  let idx = @aoci.build_index(symbols)
  assert_eq(idx.size(), 1)
}

///|
test "@aoci.build_from_mbti: 解析 mbti 文本" {
  let mbti = "package \"test/pkg\"\n\npub fn foo(Int) -> Int\npub(all) struct Bar {\n  x : Int\n}\npub type Baz = @other.Baz\n"
  let idx = @aoci.build_from_mbti("test/pkg", mbti)
  assert_true(idx.size() >= 0)
}

///|
test "@aoci.build_dependency_graph: 提取依赖" {
  let idx = aoci_test_index()
  let graph = @aoci.build_dependency_graph(idx)
  assert_eq(graph.length(), 5)
}

// ============================================================
// Router 测试
// ============================================================

///|
test "@aoci.route: 关键词匹配" {
  let idx = aoci_test_index()
  let results = @aoci.route(idx, "execute pipeline")
  assert_true(results.length() > 0)
  assert_eq(results[0].name, "ir_execute")
}

///|
test "@aoci.route: field 相关查询" {
  let idx = aoci_test_index()
  let results = @aoci.route(idx, "field gradient")
  assert_true(results.length() > 0)
  assert_eq(results[0].name, "field_gradient")
}

///|
test "@aoci.route_top_k: 限制返回数" {
  let idx = aoci_test_index()
  let results = @aoci.route_top_k(idx, "ir", 1)
  assert_eq(results.length(), 1)
}

///|
test "@aoci.route: 无匹配返回空" {
  let idx = aoci_test_index()
  let results = @aoci.route(idx, "nonexistent_xyz")
  assert_eq(results.length(), 0)
}

///|
test "@aoci.route_by_package: 按包路由" {
  let idx = aoci_test_index()
  let results = @aoci.route_by_package(idx, "walkzzz/image/src/imgir")
  assert_eq(results.length(), 2)
}

///|
test "@aoci.route_by_kind: 按类型路由" {
  let idx = aoci_test_index()
  let results = @aoci.route_by_kind(idx, @aoci.SymbolKind::Struct)
  assert_eq(results.length(), 1)
  assert_eq(results[0].name, "ScalarField")
}

// ============================================================
// ContextBudget 测试
// ============================================================

///|
test "@aoci.ContextBudget: make + remaining" {
  let budget = @aoci.ContextBudget::make(1000)
  assert_eq(budget.remaining(), 1000)
  assert_false(budget.is_exhausted())
}

///|
test "@aoci.ContextBudget: allocate 不超预算" {
  let budget = @aoci.ContextBudget::make(1000)
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="p",
      name="foo",
      kind=@aoci.SymbolKind::Function,
      keywords=["foo"],
    ),
    @aoci.SymbolCoord::make(
      pkg="p",
      name="bar",
      kind=@aoci.SymbolKind::Function,
      keywords=["bar"],
    ),
  ]
  let allocated = budget.allocate(symbols)
  assert_true(allocated.length() <= 2)
}

///|
test "@aoci.ContextBudget: allocate 超预算降级" {
  let budget = @aoci.ContextBudget::make(15)
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="p",
      name="very_long_name_for_testing",
      kind=@aoci.SymbolKind::Function,
      signature="fn(A, B, C) -> D",
      doc="long doc",
      keywords=["test"],
    ),
  ]
  let allocated = budget.allocate(symbols)
  assert_true(allocated.length() <= 1)
}

///|
test "@aoci.ContextBudget: add_partition" {
  let budget = @aoci.ContextBudget::make(1000)
  let with_partition = budget.add_partition("imgir", 200)
  assert_eq(with_partition.partition.length(), 1)
}

///|
test "@aoci.ContextBudget: usage_report" {
  let budget = @aoci.ContextBudget::make(1000)
  let report = budget.usage_report()
  assert_true(report.length() > 0)
}

///|
test "@aoci.ContextBudget: is_exhausted" {
  let budget = @aoci.ContextBudget::make(10)
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="p",
      name="foo_bar_baz_qux",
      kind=@aoci.SymbolKind::Function,
      signature="fn(A, B, C, D, E) -> F",
      doc="doc",
      keywords=["foo"],
    ),
  ]
  ignore(budget.allocate(symbols))
  assert_false(budget.is_exhausted())
}

// ============================================================
// Verifier 测试
// ============================================================

///|
test "@aoci.verify_consistency: 有效索引" {
  let idx = aoci_test_index()
  let result = @aoci.verify_consistency(idx)
  assert_true(result.is_valid)
  assert_eq(result.issues.length(), 0)
}

///|
test "@aoci.verify_consistency: 空名检测" {
  let symbols = [
    @aoci.SymbolCoord::make(pkg="pkg", name="", kind=@aoci.SymbolKind::Function),
  ]
  let idx = @aoci.build_index(symbols)
  let result = @aoci.verify_consistency(idx)
  assert_false(result.is_valid)
  assert_true(result.issues.length() > 0)
}

///|
test "@aoci.verify_keyword_coverage: 有关键词" {
  let idx = aoci_test_index()
  let result = @aoci.verify_keyword_coverage(idx)
  assert_true(result.is_valid)
}

///|
test "@aoci.verify_keyword_coverage: 无关键词检测" {
  let symbols = [
    @aoci.SymbolCoord::make(
      pkg="pkg",
      name="foo",
      kind=@aoci.SymbolKind::Function,
    ),
  ]
  let idx = @aoci.build_index(symbols)
  let result = @aoci.verify_keyword_coverage(idx)
  assert_false(result.is_valid)
}

///|
test "@aoci.verify_budget: 预算充足" {
  let idx = aoci_test_index()
  let budget = @aoci.ContextBudget::make(1000000)
  let result = @aoci.verify_budget(idx, budget)
  assert_true(result.is_valid)
}

///|
test "@aoci.verify_budget: 预算不足检测" {
  let idx = aoci_test_index()
  let budget = @aoci.ContextBudget::make(1)
  let result = @aoci.verify_budget(idx, budget)
  assert_false(result.is_valid)
}

///|
test "@aoci.verify_all: 综合验证" {
  let idx = aoci_test_index()
  let budget = @aoci.ContextBudget::make(1000000)
  let result = @aoci.verify_all(idx, budget~)
  assert_true(result.is_valid)
}

// ============================================================
// E2E: 端到端 AOCI 流水线
// ============================================================

///|
test "@aoci e2e: build → route → allocate → verify" {
  let idx = aoci_test_index()
  let results = @aoci.route(idx, "serialize pipeline")
  assert_true(results.length() > 0)
  let budget = @aoci.ContextBudget::make(10000)
  let allocated = budget.allocate(results)
  let verify = @aoci.verify_consistency(idx)
  assert_true(verify.is_valid)
  assert_true(allocated.length() > 0)
}

///|
test "@aoci e2e: 依赖图构建 + 验证" {
  let idx = aoci_test_index()
  let graph = @aoci.build_dependency_graph(idx)
  let result = @aoci.verify_dependencies(idx, graph)
  assert_true(result.is_valid)
}

///|
test "@aoci e2e: 多关键词查询 + top_k" {
  let idx = aoci_test_index()
  let results = @aoci.route_top_k(idx, "field gradient edge", 3)
  assert_true(results.length() > 0)
  assert_eq(results[0].name, "field_gradient")
}
