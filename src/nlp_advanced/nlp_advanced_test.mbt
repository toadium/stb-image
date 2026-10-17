///|
test "create_default_nlp_config: returns BERT config" {
  let config = @nlp_advanced.create_default_nlp_config()
  assert_eq(config.max_length, 512)
  assert_eq(config.batch_size, 32)
  assert_eq(config.num_epochs, 3)
  assert_true(config.use_pretrained)
  assert_eq(config.pretrained_model, "bert-base-uncased")
  assert_eq(config.num_beams, 4)
  assert_true(config.task_type is @nlp_advanced.NLPTaskType::TextClassification)
  assert_true(
    config.classification_model is @nlp_advanced.TextClassificationModel::BERT,
  )
}

///|
test "tokenize: splits by spaces" {
  let tokens = @nlp_advanced.tokenize("hello world foo bar")
  assert_eq(tokens.length(), 4)
  assert_eq(tokens[0], "hello")
  assert_eq(tokens[1], "world")
  assert_eq(tokens[2], "foo")
  assert_eq(tokens[3], "bar")
}

///|
test "tokenize: single word" {
  let tokens = @nlp_advanced.tokenize("hello")
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0], "hello")
}

///|
test "tokenize: empty string" {
  let tokens = @nlp_advanced.tokenize("")
  assert_eq(tokens.length(), 0)
}

///|
test "tokenize: multiple spaces produce no empty tokens" {
  let tokens = @nlp_advanced.tokenize("a  b   c")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], "a")
  assert_eq(tokens[1], "b")
  assert_eq(tokens[2], "c")
}

///|
test "classify_text: positive text classification" {
  let config = @nlp_advanced.create_default_nlp_config()
  let result = @nlp_advanced.classify_text(
    "this is great and excellent",
    ["positive", "negative", "neutral"],
    config,
  )
  assert_eq(result.num_classes, 3)
  assert_eq(result.all_classes.length(), 3)
  assert_eq(result.all_scores.length(), 3)
  assert_true(result.model_type is @nlp_advanced.TextClassificationModel::BERT)
  assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
}

///|
test "classify_text: empty text" {
  let config = @nlp_advanced.create_default_nlp_config()
  let result = @nlp_advanced.classify_text("", ["a", "b"], config)
  assert_eq(result.num_classes, 2)
  assert_eq(result.predicted_class, "a")
}

///|
test "recognize_entities: extracts entities from text" {
  let result = @nlp_advanced.recognize_entities("John works at Microsoft Inc")
  assert_true(result.num_entities >= 0)
  assert_eq(result.entities.length(), result.num_entities)
  assert_eq(result.entity_types.length(), result.num_entities)
  assert_eq(result.entity_spans.length(), result.num_entities)
  assert_eq(result.confidences.length(), result.num_entities)
}

///|
test "recognize_entities: organization entity" {
  let result = @nlp_advanced.recognize_entities("Google Inc is a company")
  let has_org = result.entity_types.contains(
    @nlp_advanced.NEREntityType::Organization,
  )
  assert_true(has_org)
}

///|
test "recognize_entities: empty text" {
  let result = @nlp_advanced.recognize_entities("")
  assert_eq(result.num_entities, 0)
}

///|
test "analyze_sentiment: positive sentiment" {
  let result = @nlp_advanced.analyze_sentiment(
    "this is great wonderful amazing",
  )
  assert_true(result.sentiment_score > 0.0)
  assert_true(result.positive_score > 0.0)
  assert_true(
    result.sentiment is @nlp_advanced.SentimentType::VeryPositive ||
    result.sentiment is @nlp_advanced.SentimentType::Positive,
  )
}

///|
test "analyze_sentiment: negative sentiment" {
  let result = @nlp_advanced.analyze_sentiment(
    "this is terrible awful horrible",
  )
  assert_true(result.sentiment_score < 0.0)
  assert_true(result.negative_score > 0.0)
  assert_true(
    result.sentiment is @nlp_advanced.SentimentType::VeryNegative ||
    result.sentiment is @nlp_advanced.SentimentType::Negative,
  )
}

///|
test "analyze_sentiment: neutral text" {
  let result = @nlp_advanced.analyze_sentiment("the table is on the floor")
  assert_true(result.sentiment is @nlp_advanced.SentimentType::Neutral)
  assert_true((result.positive_score - 0.5).abs() < 0.0000000001)
  assert_true((result.negative_score - 0.5).abs() < 0.0000000001)
}

///|
test "summarize_text: produces summary" {
  let text = "This is the first sentence. This is the second sentence. This is the third sentence."
  let result = @nlp_advanced.summarize_text(text, 2)
  assert_eq(result.original_length, text.length())
  assert_true(result.summary_length > 0)
  assert_true(
    result.compression_ratio >= 0.0 && result.compression_ratio <= 1.0,
  )
  assert_eq(result.method_type, "extractive")
}

///|
test "summarize_text: max sentences exceeds available" {
  let text = "Only one sentence here."
  let result = @nlp_advanced.summarize_text(text, 5)
  assert_true(result.summary_length >= 0)
}

///|
test "embed_text: generates embedding with correct dim" {
  let result = @nlp_advanced.embed_text("hello world", 128)
  assert_eq(result.embedding_dim, 128)
  assert_eq(result.embedding.length(), 128)
  assert_eq(result.num_tokens, 2)
  assert_eq(result.token_ids.length(), 2)
  assert_eq(result.model_type, "word2vec")
}

///|
test "embed_text: empty text" {
  let result = @nlp_advanced.embed_text("", 64)
  assert_eq(result.embedding_dim, 64)
  assert_eq(result.embedding.length(), 64)
  assert_eq(result.num_tokens, 0)
  assert_eq(result.token_ids.length(), 0)
}

///|
test "nlp_report_to_string: contains task and config info" {
  let config = @nlp_advanced.create_default_nlp_config()
  let report = @nlp_advanced.nlp_report_to_string(
    @nlp_advanced.NLPTaskType::SentimentAnalysis,
    config,
    "Accuracy: 95%",
  )
  assert_true(report.contains("自然语言处理高级报告"))
  assert_true(report.contains("情感分析"))
  assert_true(report.contains("BERT"))
  assert_true(report.contains("bert-base-uncased"))
  assert_true(report.contains("Accuracy: 95%"))
}

///|
test "nlp_report_to_string: text summarization task" {
  let config = @nlp_advanced.create_default_nlp_config()
  let report = @nlp_advanced.nlp_report_to_string(
    @nlp_advanced.NLPTaskType::TextSummarization,
    config,
    "ROUGE: 0.42",
  )
  assert_true(report.contains("文本摘要"))
  assert_true(report.contains("ROUGE: 0.42"))
}
