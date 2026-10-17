// AOCI-ContextBudget — Token 配额/分区/降级压缩
// 给定 Token 预算，按优先级分配符号加载，超预算时降级

///|
pub(all) struct ContextBudget {
  total_quota : Int
  used : Int
  partition : Array[(String, Int)]
} derive(Eq, @debug.Debug)

///|
pub extend ContextBudget with Eq::{not_equal, equal}

///|
pub extend ContextBudget with @debug.Debug::{to_repr}

///|
pub fn ContextBudget::make(quota : Int) -> ContextBudget {
  { total_quota: quota, used: 0, partition: [], }
}

///|
pub fn ContextBudget::remaining(self : ContextBudget) -> Int {
  self.total_quota - self.used
}

///|
pub fn ContextBudget::is_exhausted(self : ContextBudget) -> Bool {
  self.used >= self.total_quota
}

///|
pub fn ContextBudget::add_partition(
  self : ContextBudget,
  name : String,
  quota : Int,
) -> ContextBudget {
  let partition = self.partition.copy()
  partition.push((name, quota))
  { total_quota: self.total_quota, used: self.used, partition, }
}

///|
pub fn ContextBudget::allocate(
  self : ContextBudget,
  symbols : Array[SymbolCoord],
) -> Array[SymbolCoord] {
  let result : Array[SymbolCoord] = []
  let mut remaining = self.total_quota - self.used
  for sym in symbols {
    let cost = sym.estimated_tokens()
    if cost <= remaining {
      result.push(sym)
      remaining = remaining - cost
    } else {
      let degraded = degrade_symbol(sym, remaining)
      if degraded.estimated_tokens() <= remaining {
        result.push(degraded)
        remaining = remaining - degraded.estimated_tokens()
      }
    }
    if remaining <= 0 {
      break
    }
  }
  result
}

///|
pub fn ContextBudget::allocate_with_priority(
  self : ContextBudget,
  symbols : Array[(SymbolCoord, Int)],
) -> Array[SymbolCoord] {
  let sorted = sort_by_priority(symbols)
  let coords : Array[SymbolCoord] = []
  for entry in sorted {
    coords.push(entry.0)
  }
  self.allocate(coords)
}

///|
fn degrade_symbol(sym : SymbolCoord, budget : Int) -> SymbolCoord {
  if budget < 20 {
    SymbolCoord::make(
      pkg=sym.pkg,
      name=sym.name,
      kind=sym.kind,
      signature="",
      doc="",
      keywords=sym.keywords,
    )
  } else if budget < 50 {
    SymbolCoord::make(
      pkg=sym.pkg,
      name=sym.name,
      kind=sym.kind,
      signature=sym.signature,
      doc="",
      keywords=sym.keywords,
    )
  } else {
    sym
  }
}

///|
fn sort_by_priority(
  symbols : Array[(SymbolCoord, Int)],
) -> Array[(SymbolCoord, Int)] {
  let arr = symbols
  let n = arr.length()
  for i in 0..<n {
    for j in 0..<(n - 1 - i) {
      if arr[j].1 < arr[j + 1].1 {
        let tmp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = tmp
      }
    }
  }
  arr
}

///|
pub fn ContextBudget::usage_report(self : ContextBudget) -> String {
  let pct = if self.total_quota > 0 {
    self.used * 100 / self.total_quota
  } else {
    0
  }
  "Budget: \{self.used}/\{self.total_quota} tokens (\{pct}%), remaining: \{self.remaining()}"
}
