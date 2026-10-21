// v46.0.0 图神经网络测试

///|
test "create_default_gnn_config: 基本测试" {
  let config = @graph_neural.create_default_gnn_config()
  assert_true(config.layer_type is @graph_neural.GNNLayerType::GCN)
}

///|
test "create_default_reasoning_config: 基本测试" {
  let config = @graph_neural.create_default_reasoning_config()
  assert_true(config.num_relations > 0)
}

///|
test "create_random_graph: 基本测试" {
  let graph = @graph_neural.create_random_graph(5, 8, 3, false)
  assert_eq(graph.num_nodes, 5)
  assert_true(graph.num_edges >= 0)
}

///|
test "graph_convolution: 基本测试" {
  let graph = @graph_neural.create_random_graph(5, 8, 3, false)
  let config = @graph_neural.create_default_gnn_config()
  let result = @graph_neural.graph_convolution(graph, config)
  assert_eq(result.num_nodes, 5)
  assert_true(result.embedding_dim > 0)
}

///|
test "graph_attention: 基本测试" {
  let graph = @graph_neural.create_random_graph(5, 8, 3, false)
  let config = @graph_neural.create_default_gnn_config()
  let result = @graph_neural.graph_attention(graph, config)
  assert_eq(result.num_nodes, 5)
  assert_true(result.embedding_dim > 0)
}

///|
test "predict_relation: 基本测试" {
  let graph = @graph_neural.create_random_graph(5, 8, 3, false)
  let config = @graph_neural.create_default_reasoning_config()
  let result = @graph_neural.predict_relation(graph, 0, 1, config)
  assert_eq(result.source_id, 0)
  assert_eq(result.target_id, 1)
  assert_true(result.confidence >= 0.0)
}

///|
test "detect_communities: 基本测试" {
  let graph = @graph_neural.create_random_graph(6, 10, 3, false)
  let result = @graph_neural.detect_communities(graph, 2)
  assert_true(result.num_communities >= 0)
  assert_true(result.communities.length() >= 0)
}

///|
test "graph_neural_report_to_string: 基本测试" {
  let graph = @graph_neural.create_random_graph(5, 8, 3, false)
  let config = @graph_neural.create_default_gnn_config()
  let embedding = @graph_neural.graph_convolution(graph, config)
  let report = @graph_neural.graph_neural_report_to_string(
    embedding, graph, config,
  )
  assert_true(report.length() > 0)
}
