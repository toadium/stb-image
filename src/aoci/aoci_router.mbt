// AOCI-Router — 自然语言 → 模块定位 → 按需加载
// 关键词匹配 + 排序 + Top-K 返回

///|
pub fn route(index : SymbolIndex, query : String) -> Array[SymbolCoord] {
  let query_keywords = split_query(query)
  let scored : Array[(SymbolCoord, Int)] = []
  for sym in index.symbols {
    let score = score_symbol(sym, query_keywords)
    if score > 0 {
      scored.push((sym, score))
    }
  }
  sort_by_score(scored)
}

///|
pub fn route_top_k(
  index : SymbolIndex,
  query : String,
  k : Int,
) -> Array[SymbolCoord] {
  let results = route(index, query)
  let top : Array[SymbolCoord] = []
  let limit = if k < results.length() { k } else { results.length() }
  for i in 0..<limit {
    top.push(results[i])
  }
  top
}

///|
pub fn route_by_package(
  index : SymbolIndex,
  pkg : String,
) -> Array[SymbolCoord] {
  index.find_by_package(pkg)
}

///|
pub fn route_by_kind(
  index : SymbolIndex,
  kind : SymbolKind,
) -> Array[SymbolCoord] {
  index.find_by_kind(kind)
}

///|
fn split_query(query : String) -> Array[String] {
  let keywords : Array[String] = []
  for part in query.split(" ") {
    let trimmed = part.trim().to_owned()
    let lowered = trimmed.to_lower()
    if lowered.length() > 0 {
      keywords.push(lowered)
    }
  }
  keywords
}

///|
fn score_symbol(sym : SymbolCoord, query_keywords : Array[String]) -> Int {
  let mut score = 0
  let name_lower = sym.name.to_lower()
  for qkw in query_keywords {
    if name_lower.contains(qkw) {
      score = score + 10
    }
    for skw in sym.keywords {
      if skw.to_lower() == qkw {
        score = score + 5
      }
    }
    if sym.doc.to_lower().contains(qkw) {
      score = score + 2
    }
    if sym.signature.to_lower().contains(qkw) {
      score = score + 1
    }
  }
  score
}

///|
fn sort_by_score(scored : Array[(SymbolCoord, Int)]) -> Array[SymbolCoord] {
  let arr = scored
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
  let result : Array[SymbolCoord] = []
  for entry in arr {
    result.push(entry.0)
  }
  result
}
