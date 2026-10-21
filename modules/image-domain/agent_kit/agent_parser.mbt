// Agent-Kit 解析器 — 自然语言 → 意图序列
// nl_parse: 将自然语言查询解析为操作意图序列

///|
pub fn nl_parse(query : String) -> Array[Intent] {
  let intents : Array[Intent] = []
  let words = split_words(query)
  for word in words {
    let intent = match_word(word)
    if intent is Some(i) {
      let mut found = false
      for existing in intents {
        if existing == i {
          found = true
          break
        }
      }
      if !found {
        intents.push(i)
      }
    }
  }
  if intents.length() == 0 {
    intents.push(Identity)
  }
  intents
}

///|
fn split_words(query : String) -> Array[String] {
  let words : Array[String] = []
  for part in query.split(" ") {
    let trimmed = part.trim().to_owned()
    if trimmed.length() > 0 {
      words.push(trimmed.to_lower())
    }
  }
  words
}

///|
fn match_word(word : String) -> Intent? {
  let candidates = [
    Denoise,
    EdgeDetect,
    Blur,
    Sharpen,
    Grayscale,
    Rotate,
    FlipH,
    FlipV,
    Identity,
  ]
  for candidate in candidates {
    if candidate.matches(word) {
      return Some(candidate)
    }
  }
  None
}

///|
pub fn nl_describe(intents : Array[Intent]) -> String {
  if intents.length() == 0 {
    return "empty"
  }
  let parts : Array[String] = []
  for intent in intents {
    parts.push(intent.to_string())
  }
  parts.join(" → ")
}
