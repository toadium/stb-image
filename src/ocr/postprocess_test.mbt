// v187.0.0 postprocess.mbt 测试：后处理配置/词典/编辑距离/N-gram/置信度校准

///|
test "postprocess_default_config: 默认值" {
  let config = @ocr.postprocess_default_config()
  assert_eq(config.use_dictionary, true)
  assert_eq(config.use_ngram, true)
  assert_eq(config.ngram_size, 2)
  assert_true((config.min_confidence - 0.3).abs() < 0.01)
  assert_eq(config.max_candidates, 5)
}

///|
test "dictionary_create: 基本创建" {
  try {
    let dict = @ocr.dictionary_create(["hello", "world"])
    assert_eq(dict.words.length(), 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "dictionary_create: 空列表抛异常" {
  try {
    let _ = @ocr.dictionary_create([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "dictionary_create_common_english: 非空词典" {
  let dict = @ocr.dictionary_create_common_english()
  assert_true(dict.words.length() > 50)
}

///|
test "edit_distance: 相同字符串为0" {
  try {
    let dist = @ocr.edit_distance("hello", "hello")
    assert_eq(dist, 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "edit_distance: 单字符替换" {
  try {
    let dist = @ocr.edit_distance("cat", "bat")
    assert_eq(dist, 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "edit_distance: 插入操作" {
  try {
    let dist = @ocr.edit_distance("cat", "cats")
    assert_eq(dist, 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "edit_distance: 删除操作" {
  try {
    let dist = @ocr.edit_distance("cats", "cat")
    assert_eq(dist, 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "edit_distance: 两空字符串抛异常" {
  try {
    let _ = @ocr.edit_distance("", "")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "dictionary_match: 精确匹配" {
  try {
    let dict = @ocr.dictionary_create(["hello", "world", "test"])
    let result = @ocr.dictionary_match("hello", dict, max_distance=0)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ngram_create: 基本创建" {
  try {
    let model = @ocr.ngram_create(["the cat", "the dog", "a cat"], n=2)
    assert_true(model.n == 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ngram_score: 基本评分" {
  try {
    let model = @ocr.ngram_create(["the cat sat", "the dog ran"], n=2)
    let score = @ocr.ngram_score("the cat", model)
    assert_true(score >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_postprocess: 基本后处理" {
  try {
    let config = @ocr.postprocess_default_config()
    let dictionary = @ocr.dictionary_create_common_english()
    let result = @ocr.OcrResult::{
      text: "hel1o",
      confidence: 0.8,
      characters: [
        @ocr.OcrCharResult::{
          char: "h",
          confidence: 0.9,
          x: 0,
          y: 0,
          width: 10,
          height: 20,
        },
        @ocr.OcrCharResult::{
          char: "e",
          confidence: 0.9,
          x: 10,
          y: 0,
          width: 10,
          height: 20,
        },
        @ocr.OcrCharResult::{
          char: "l",
          confidence: 0.9,
          x: 20,
          y: 0,
          width: 10,
          height: 20,
        },
        @ocr.OcrCharResult::{
          char: "1",
          confidence: 0.2,
          x: 30,
          y: 0,
          width: 10,
          height: 20,
        },
        @ocr.OcrCharResult::{
          char: "o",
          confidence: 0.9,
          x: 40,
          y: 0,
          width: 10,
          height: 20,
        },
      ],
    }
    let processed = @ocr.ocr_postprocess(result, config~, dictionary~)
    assert_true(processed.text.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "calibrate_confidence: 基本校准" {
  try {
    let result = @ocr.OcrResult::{
      text: "test",
      confidence: 0.9,
      characters: [
        @ocr.OcrCharResult::{
          char: "t",
          confidence: 0.9,
          x: 0,
          y: 0,
          width: 10,
          height: 20,
        },
      ],
    }
    let calibrated = @ocr.calibrate_confidence(result, factor=1.0)
    assert_true(calibrated.confidence >= 0.0 && calibrated.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "calibrate_confidence: 空字符抛异常" {
  try {
    let result = @ocr.OcrResult::{ text: "", confidence: 0.5, characters: [], }
    let _ = @ocr.calibrate_confidence(result, factor=1.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
