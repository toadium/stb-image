// 时空拓扑谓词：时间区间之间的拓扑关系。
// Spatiotemporal predicates: topological relations between time intervals.
//
// 参考 Allen's Interval Algebra 的 13 种关系，实现常用 8 种：
//   contains / within / intersects / overlaps / during / before / after / meets

///|
/// st_contains(a, b)：区间 a 包含 b（a.start <= b.start && b.end <= a.end）。
/// Interval a contains interval b.
pub fn st_contains(a : TInterval, b : TInterval) -> Bool {
  a.start <= b.start && b.end <= a.end
}

///|
/// st_within(a, b)：区间 a 在 b 内（等价于 st_contains(b, a)）。
/// Interval a is within interval b.
pub fn st_within(a : TInterval, b : TInterval) -> Bool {
  st_contains(b, a)
}

///|
/// st_intersects(a, b)：区间 a 与 b 相交（有重叠或仅 touching）。
/// Intervals a and b intersect.
pub fn st_intersects(a : TInterval, b : TInterval) -> Bool {
  a.start < b.end && b.start < a.end
}

///|
/// st_overlaps(a, b)：区间 a 与 b 有实质重叠（排除仅 touching）。
/// Intervals a and b overlap (excluding mere touching).
pub fn st_overlaps(a : TInterval, b : TInterval) -> Bool {
  a.start < b.end && b.start < a.end && a.start != b.end && b.start != a.end
}

///|
/// st_during(a, b)：区间 a 严格在 b 期间（a.start > b.start && a.end < b.end）。
/// Interval a is strictly during interval b.
pub fn st_during(a : TInterval, b : TInterval) -> Bool {
  a.start > b.start && a.end < b.end
}

///|
/// st_before(a, b)：区间 a 在 b 之前（a.end <= b.start）。
/// Interval a is before interval b.
pub fn st_before(a : TInterval, b : TInterval) -> Bool {
  a.end <= b.start
}

///|
/// st_after(a, b)：区间 a 在 b 之后（等价于 st_before(b, a)）。
/// Interval a is after interval b.
pub fn st_after(a : TInterval, b : TInterval) -> Bool {
  st_before(b, a)
}

///|
/// st_meets(a, b)：区间 a 紧接 b（a.end == b.start）。
/// Interval a meets interval b (a.end == b.start).
pub fn st_meets(a : TInterval, b : TInterval) -> Bool {
  a.end == b.start
}

///|
/// st_equals(a, b)：区间相等。
/// Intervals are equal.
pub fn st_equals(a : TInterval, b : TInterval) -> Bool {
  a.start == b.start && a.end == b.end
}
