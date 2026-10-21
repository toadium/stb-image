// AOCI 符号语义索引 — 符号索引结构
// SymbolIndex: 全量符号索引 + 关键词倒排表

///|
pub(all) struct SymbolIndex {
  symbols : Array[SymbolCoord]
  keyword_map : Array[(String, Array[Int32])]
} derive(Eq, @debug.Debug)

///|
pub extend SymbolIndex with Eq::{not_equal, equal}

///|
pub extend SymbolIndex with @debug.Debug::{to_repr}

///|
pub fn SymbolIndex::make(symbols : Array[SymbolCoord]) -> SymbolIndex {
  let keyword_map : Array[(String, Array[Int32])] = []
  for i in 0..<symbols.length() {
    for kw in symbols[i].keywords {
      let mut found = false
      for j in 0..<keyword_map.length() {
        if keyword_map[j].0 == kw {
          keyword_map[j].1.push(i)
          found = true
          break
        }
      }
      if !found {
        keyword_map.push((kw, [i]))
      }
    }
  }
  { symbols, keyword_map, }
}

///|
pub fn SymbolIndex::size(self : SymbolIndex) -> Int32 {
  self.symbols.length()
}

///|
pub fn SymbolIndex::get(
  self : SymbolIndex,
  index : Int32,
) -> SymbolCoord raise Failure {
  if index < 0 || index >= self.symbols.length() {
    fail("symbol index out of bounds: \{index}")
  }
  self.symbols[index]
}

///|
pub fn SymbolIndex::find_by_name(
  self : SymbolIndex,
  name : String,
) -> Array[SymbolCoord] {
  let result : Array[SymbolCoord] = []
  for sym in self.symbols {
    if sym.name == name {
      result.push(sym)
    }
  }
  result
}

///|
pub fn SymbolIndex::find_by_package(
  self : SymbolIndex,
  pkg : String,
) -> Array[SymbolCoord] {
  let result : Array[SymbolCoord] = []
  for sym in self.symbols {
    if sym.pkg == pkg {
      result.push(sym)
    }
  }
  result
}

///|
pub fn SymbolIndex::find_by_keyword(
  self : SymbolIndex,
  keyword : String,
) -> Array[SymbolCoord] {
  for entry in self.keyword_map {
    if entry.0 == keyword {
      let result : Array[SymbolCoord] = []
      for idx in entry.1 {
        result.push(self.symbols[idx])
      }
      return result
    }
  }
  []
}

///|
pub fn SymbolIndex::find_by_kind(
  self : SymbolIndex,
  kind : SymbolKind,
) -> Array[SymbolCoord] {
  let result : Array[SymbolCoord] = []
  for sym in self.symbols {
    if sym.kind == kind {
      result.push(sym)
    }
  }
  result
}

///|
pub fn SymbolIndex::total_tokens(self : SymbolIndex) -> Int32 {
  let mut sum = 0
  for sym in self.symbols {
    sum = sum + sym.estimated_tokens()
  }
  sum
}
