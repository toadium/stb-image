// 图神经网络测试 — Graph neural network tests
// Phase 13 v340: 深度学习大扩展 — 图神经网络。

///|
fn make_graph() -> @cv_advanced.GraphData {
  {
    num_nodes: 3,
    adj_matrix: [0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0],
    node_features: [1.0, 0.0, 0.0, 1.0, 1.0, 1.0],
    feature_dim: 2,
  }
}

///|
fn make_gnn_config() -> @cv_advanced.GNNConfig {
  {
    hidden_dim: 2,
    num_layers: 1,
    dropout: 0.1,
    gnn_type: @cv_advanced.GNNType::GCN,
  }
}

///|
test "graph_convolution: 基本图卷积" {
  let graph = make_graph()
  let weight = [1.0, 0.0, 0.0, 1.0]
  let result = @cv_advanced.graph_convolution(graph, weight, 2)
  assert_true(result.length() == 6)
}

///|
test "gcn_forward: GCN 前向" {
  let graph = make_graph()
  let w = [1.0, 0.0, 0.0, 1.0]
  let config = make_gnn_config()
  let result = @cv_advanced.gcn_forward(graph, [w], config)
  assert_true(result.length() == 6)
}

///|
test "aggregate_neighbors: 邻居聚合" {
  let graph = make_graph()
  let result = @cv_advanced.aggregate_neighbors(
    graph,
    0,
    @cv_advanced.GNNType::GraphSAGE,
  )
  assert_true(result.length() == 2)
}

///|
test "gat_forward: GAT 前向" {
  let graph = make_graph()
  let weight = [1.0, 0.0, 0.0, 1.0]
  let attn_w = [1.0, 1.0]
  let config : @cv_advanced.GNNConfig = {
    hidden_dim: 2,
    num_layers: 1,
    dropout: 0.1,
    gnn_type: @cv_advanced.GNNType::GAT,
  }
  let result = @cv_advanced.gat_forward(graph, weight, attn_w, config)
  assert_true(result.node_embeddings.length() == 6)
  assert_true(result.attention_weights.length() == 9)
}

///|
test "graphsage_forward: GraphSAGE 前向" {
  let graph = make_graph()
  let weight = [1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0]
  let config : @cv_advanced.GNNConfig = {
    hidden_dim: 2,
    num_layers: 1,
    dropout: 0.1,
    gnn_type: @cv_advanced.GNNType::GraphSAGE,
  }
  let result = @cv_advanced.graphsage_forward(graph, weight, config)
  assert_true(result.length() == 6)
}

///|
test "GNNType: enum 值" {
  let g1 = @cv_advanced.GNNType::GCN
  let g2 = @cv_advanced.GNNType::GAT
  let g3 = @cv_advanced.GNNType::GraphSAGE
  let g4 = @cv_advanced.GNNType::GIN
  assert_true(g1 != g2)
  assert_true(g2 != g3)
  assert_true(g3 != g4)
}

///|
test "GraphData: 构造与字段" {
  let graph = make_graph()
  assert_true(graph.num_nodes == 3)
  assert_true(graph.feature_dim == 2)
  assert_true(graph.adj_matrix.length() == 9)
}

///|
test "GNNConfig: 构造与字段" {
  let config = make_gnn_config()
  assert_true(config.hidden_dim == 2)
  assert_true(config.num_layers == 1)
}

///|
test "GNNResult: 构造" {
  let result : @cv_advanced.GNNResult = {
    node_embeddings: [1.0, 2.0],
    attention_weights: [0.5, 0.5],
  }
  assert_true(result.node_embeddings.length() == 2)
}
