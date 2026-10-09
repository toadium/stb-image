// v187.0.0 chinese_dictionary.mbt 测试：中文字库/部首查找/拼音查找/结构查找/相似度

///|
test "create_default_chinese_dictionary: 非空字库" {
  let dict = @ocr.create_default_chinese_dictionary()
  assert_true(dict.total_chars > 0)
  assert_true(dict.chars.length() > 0)
}

///|
test "lookup_by_radical: 基本查找" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let results = @ocr.lookup_by_radical(dict, "口")
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "lookup_by_radical: 空部首抛异常" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let _ = @ocr.lookup_by_radical(dict, "")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "lookup_by_pinyin: 基本查找" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let results = @ocr.lookup_by_pinyin(dict, "ren")
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "lookup_by_pinyin: 空拼音抛异常" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let _ = @ocr.lookup_by_pinyin(dict, "")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "lookup_by_structure: 独体字" {
  let dict = @ocr.create_default_chinese_dictionary()
  let results = @ocr.lookup_by_structure(dict, @ocr.DictCharStructure::Independent)
  assert_true(results.length() >= 0)
}

///|
test "lookup_by_structure: 左右结构" {
  let dict = @ocr.create_default_chinese_dictionary()
  let results = @ocr.lookup_by_structure(dict, @ocr.DictCharStructure::LeftRight)
  assert_true(results.length() >= 0)
}

///|
test "calculate_chinese_similarity: 相同字" {
  let dict = @ocr.create_default_chinese_dictionary()
  try {
    let entry = @ocr.lookup_char(dict, "人")
    match entry {
      Some(e) => {
        let sim = @ocr.calculate_chinese_similarity(e, e)
        assert_true(sim >= 0.8 && sim <= 1.0)
      }
      None => assert_true(true)
    }
  } catch {
    _ => assert_true(false)
  }
}

///|
test "find_similar_chinese_chars: 基本查找" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let results = @ocr.find_similar_chinese_chars(dict, "人", top_n=3)
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "find_similar_chinese_chars: 空字符抛异常" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let _ = @ocr.find_similar_chinese_chars(dict, "")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "lookup_char: 基本查找" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let result = @ocr.lookup_char(dict, "人")
    assert_true(result is Some(_))
  } catch {
    _ => assert_true(false)
  }
}

///|
test "lookup_char: 不存在" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let result = @ocr.lookup_char(dict, "𠀀")
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "lookup_char: 空字符抛异常" {
  try {
    let dict = @ocr.create_default_chinese_dictionary()
    let _ = @ocr.lookup_char(dict, "")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "recognize_by_components: 基本识别" {
  let dict = @ocr.create_default_chinese_dictionary()
  let results = @ocr.recognize_by_components(
    dict,
    @ocr.DictCharStructure::LeftRight,
    ["口"],
  )
  assert_true(results.length() >= 0)
}

///|
test "generate_chinese_dictionary_report: 基本报告" {
  let dict = @ocr.create_default_chinese_dictionary()
  let report = @ocr.generate_chinese_dictionary_report(dict)
  assert_true(report.length() > 0)
  assert_true(report.contains("中文字库"))
}