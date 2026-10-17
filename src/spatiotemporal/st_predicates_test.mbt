// 时空拓扑谓词测试（Allen's Interval Algebra 子集）。

///|
test "st_contains: a 包含 b" {
  let a = @spatiotemporal.TInterval::make(0.0F, 10.0F)
  let b = @spatiotemporal.TInterval::make(2.0F, 8.0F)
  assert_true(@spatiotemporal.st_contains(a, b))
}

///|
test "st_contains: 不包含" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(3.0F, 8.0F)
  assert_false(@spatiotemporal.st_contains(a, b))
}

///|
test "st_within: a 在 b 内" {
  let a = @spatiotemporal.TInterval::make(2.0F, 4.0F)
  let b = @spatiotemporal.TInterval::make(0.0F, 10.0F)
  assert_true(@spatiotemporal.st_within(a, b))
}

///|
test "st_intersects: 相交" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(3.0F, 8.0F)
  assert_true(@spatiotemporal.st_intersects(a, b))
}

///|
test "st_intersects: 不相交" {
  let a = @spatiotemporal.TInterval::make(0.0F, 3.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  assert_false(@spatiotemporal.st_intersects(a, b))
}

///|
test "st_overlaps: 有实质重叠" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(3.0F, 8.0F)
  assert_true(@spatiotemporal.st_overlaps(a, b))
}

///|
test "st_overlaps: 仅 touching 不算重叠" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  assert_false(@spatiotemporal.st_overlaps(a, b))
}

///|
test "st_during: a 严格在 b 期间" {
  let a = @spatiotemporal.TInterval::make(2.0F, 4.0F)
  let b = @spatiotemporal.TInterval::make(0.0F, 10.0F)
  assert_true(@spatiotemporal.st_during(a, b))
}

///|
test "st_during: 边界重合不算 during" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(0.0F, 10.0F)
  assert_false(@spatiotemporal.st_during(a, b))
}

///|
test "st_before: a 在 b 之前" {
  let a = @spatiotemporal.TInterval::make(0.0F, 3.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  assert_true(@spatiotemporal.st_before(a, b))
}

///|
test "st_before: touching 也算 before" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  assert_true(@spatiotemporal.st_before(a, b))
}

///|
test "st_after: a 在 b 之后" {
  let a = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  let b = @spatiotemporal.TInterval::make(0.0F, 3.0F)
  assert_true(@spatiotemporal.st_after(a, b))
}

///|
test "st_meets: a 紧接 b" {
  let a = @spatiotemporal.TInterval::make(0.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  assert_true(@spatiotemporal.st_meets(a, b))
}

///|
test "st_meets: 不紧接" {
  let a = @spatiotemporal.TInterval::make(0.0F, 4.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  assert_false(@spatiotemporal.st_meets(a, b))
}

///|
test "st_equals: 相等区间" {
  let a = @spatiotemporal.TInterval::make(1.0F, 5.0F)
  let b = @spatiotemporal.TInterval::make(1.0F, 5.0F)
  assert_true(@spatiotemporal.st_equals(a, b))
}

// === 属性测试 ===

///|
test "property: st_before 和 st_after 对称" {
  let a = @spatiotemporal.TInterval::make(0.0F, 3.0F)
  let b = @spatiotemporal.TInterval::make(5.0F, 8.0F)
  assert_eq(@spatiotemporal.st_before(a, b), @spatiotemporal.st_after(b, a))
}

///|
test "property: st_within 是 st_contains 的翻转" {
  let a = @spatiotemporal.TInterval::make(2.0F, 4.0F)
  let b = @spatiotemporal.TInterval::make(0.0F, 10.0F)
  assert_eq(@spatiotemporal.st_within(a, b), @spatiotemporal.st_contains(b, a))
}
