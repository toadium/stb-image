// AOCI-Builder — 源码/mbti 解析 → 符号坐标 + 依赖图谱
// 从 .mbti 格式文本解析符号，或手动构建符号索引

///|
pub fn build_index(symbols : Array[SymbolCoord]) -> SymbolIndex {
  SymbolIndex::make(symbols)
}

///|
pub fn build_symbol(
  pkg~ : String,
  name~ : String,
  kind~ : SymbolKind,
  signature? : String = "",
  doc? : String = "",
  keywords? : Array[String] = [],
) -> SymbolCoord {
  SymbolCoord::make(pkg~, name~, kind~, signature~, doc~, keywords~)
}

///|
fn parse_kind_from_line(line : String) -> SymbolKind {
  if line.contains("struct") {
    Struct
  } else if line.contains("enum") {
    Enum
  } else if line.contains("type") {
    TypeAlias
  } else if line.contains("fn") {
    Function
  } else {
    Function
  }
}

///|
fn extract_name_from_line(line : String) -> String {
  let chars = line.to_array()
  let mut start = -1
  for i in 0..<chars.length() {
    let c = chars[i]
    if c == 'f' && i + 1 < chars.length() && chars[i + 1] == 'n' {
      start = i + 2
      break
    }
    if c == 't' &&
      i + 3 < chars.length() &&
      chars[i + 1] == 'y' &&
      chars[i + 2] == 'p' &&
      chars[i + 3] == 'e' {
      start = i + 4
      break
    }
    if c == 's' &&
      i + 5 < chars.length() &&
      chars[i + 1] == 't' &&
      chars[i + 2] == 'r' &&
      chars[i + 3] == 'u' &&
      chars[i + 4] == 'c' &&
      chars[i + 5] == 't' {
      start = i + 6
      break
    }
    if c == 'e' &&
      i + 3 < chars.length() &&
      chars[i + 1] == 'n' &&
      chars[i + 2] == 'u' &&
      chars[i + 3] == 'm' {
      start = i + 4
      break
    }
  }
  if start < 0 {
    return ""
  }
  let mut end = chars.length()
  for i in start..<chars.length() {
    let c = chars[i]
    if c == '(' || c == '<' || c == ' ' || c == '=' || c == '{' {
      end = i
      break
    }
  }
  let name_chars : Array[Char] = []
  for i in start..<end {
    let c = chars[i]
    if c != ' ' && c != '\t' {
      name_chars.push(c)
    }
  }
  String::from_array(name_chars)
}

///|
pub fn build_from_mbti(
  package_name : String,
  mbti_content : String,
) -> SymbolIndex {
  let symbols : Array[SymbolCoord] = []
  for line in mbti_content.split("\n") {
    let line_str = line.to_owned()
    let trimmed = line_str.trim().to_owned()
    if trimmed.length() == 0 {
      continue
    }
    if trimmed.has_prefix("pub fn ") ||
      trimmed.has_prefix("pub(all) struct ") ||
      trimmed.has_prefix("pub(all) enum ") ||
      trimmed.has_prefix("pub type ") {
      let kind = parse_kind_from_line(trimmed)
      let name = extract_name_from_line(trimmed)
      if name.length() > 0 {
        let keywords = extract_keywords(name)
        symbols.push(
          SymbolCoord::make(
            pkg=package_name,
            name~,
            kind~,
            signature=trimmed,
            doc="",
            keywords~,
          ),
        )
      }
    }
  }
  SymbolIndex::make(symbols)
}

///|
fn extract_keywords(name : String) -> Array[String] {
  let keywords : Array[String] = []
  for part in name.split("_") {
    let part_str = part.to_owned()
    if part_str.length() > 0 {
      keywords.push(part_str)
    }
  }
  keywords
}

///|
pub fn build_dependency_graph(
  index : SymbolIndex,
) -> Array[(String, Array[String])] {
  let graph : Array[(String, Array[String])] = []
  for sym in index.symbols {
    let deps : Array[String] = []
    for part in sym.signature.split(" ") {
      let part_str = part.to_owned()
      if part_str.contains("::") {
        let mut found = false
        for d in deps {
          if d == part_str {
            found = true
            break
          }
        }
        if !found {
          deps.push(part_str)
        }
      }
    }
    graph.push((sym.name, deps))
  }
  graph
}
