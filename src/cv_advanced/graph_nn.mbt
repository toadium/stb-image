// 图神经网络 — GCN/GAT/GraphSAGE
// Graph neural networks
//
// Phase 13 v340: 深度学习大扩展 — 图神经网络。

///|
/// GNN 类型。
/// GNN type.
pub(all) enum GNNType {
  GCN
  GAT
  GraphSAGE
  GIN
} derive(Eq, @debug.Debug)

///|
pub extend GNNType with @debug.Debug::{to_repr}

///|
pub extend GNNType with Eq::{not_equal, equal}

///|
/// 图数据。
/// Graph data.
pub(all) struct GraphData {
  num_nodes : Int
  adj_matrix : Array[Double]
  node_features : Array[Double]
  feature_dim : Int
} derive(Eq, @debug.Debug)

///|
pub extend GraphData with @debug.Debug::{to_repr}

///|
pub extend GraphData with Eq::{not_equal, equal}

///|
/// GNN 配置。
/// GNN configuration.
pub(all) struct GNNConfig {
  hidden_dim : Int
  num_layers : Int
  dropout : Double
  gnn_type : GNNType
} derive(Eq, @debug.Debug)

///|
pub extend GNNConfig with @debug.Debug::{to_repr}

///|
pub extend GNNConfig with Eq::{not_equal, equal}

///|
/// GNN 结果。
/// GNN result.
pub(all) struct GNNResult {
  node_embeddings : Array[Double]
  attention_weights : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend GNNResult with @debug.Debug::{to_repr}

///|
pub extend GNNResult with Eq::{not_equal, equal}

///|
/// 图卷积。
/// Graph convolution.
pub fn graph_convolution(
  graph : GraphData,
  weight : Array[Double],
  out_dim : Int,
) -> Array[Double] {
  let n = graph.num_nodes
  let in_dim = graph.feature_dim
  let result : Array[Double] = []
  for node in 0..<n {
    for o in 0..<out_dim {
      let mut sum = 0.0
      for neighbor in 0..<n {
        let adj_idx = node * n + neighbor
        let adj_val = if adj_idx < graph.adj_matrix.length() {
          graph.adj_matrix[adj_idx]
        } else {
          0.0
        }
        if adj_val != 0.0 {
          for f in 0..<in_dim {
            let feat_idx = neighbor * in_dim + f
            let w_idx = o * in_dim + f
            if feat_idx < graph.node_features.length() &&
              w_idx < weight.length() {
              sum = sum +
                adj_val * graph.node_features[feat_idx] * weight[w_idx]
            }
          }
        }
      }
      result.push(sum)
    }
  }
  result
}

///|
/// GCN 前向传播。
/// GCN forward pass.
pub fn gcn_forward(
  graph : GraphData,
  weights : Array[Array[Double]],
  config : GNNConfig,
) -> Array[Double] {
  let mut current_features = graph.node_features
  let mut current_dim = graph.feature_dim
  let mut current_graph = graph
  for layer in 0..<config.num_layers {
    let w = if layer < weights.length() { weights[layer] } else { [] }
    current_features = graph_convolution(current_graph, w, config.hidden_dim)
    current_dim = config.hidden_dim
    current_graph = GraphData::{
      num_nodes: current_graph.num_nodes,
      adj_matrix: current_graph.adj_matrix,
      node_features: current_features,
      feature_dim: current_dim,
    }
    for i in 0..<current_features.length() {
      if current_features[i] < 0.0 {
        current_features[i] = 0.0
      }
    }
    current_graph = GraphData::{
      num_nodes: current_graph.num_nodes,
      adj_matrix: current_graph.adj_matrix,
      node_features: current_features,
      feature_dim: current_dim,
    }
  }
  current_features
}

///|
/// 邻居聚合。
/// Neighbor aggregation.
pub fn aggregate_neighbors(
  graph : GraphData,
  node_idx : Int,
  agg_type : GNNType,
) -> Array[Double] {
  let result : Array[Double] = []
  let in_dim = graph.feature_dim
  for f in 0..<in_dim {
    let mut sum = 0.0
    let mut count = 0
    let mut max_val = -1.7976931348623157e308
    for neighbor in 0..<graph.num_nodes {
      let adj_idx = node_idx * graph.num_nodes + neighbor
      if adj_idx < graph.adj_matrix.length() && graph.adj_matrix[adj_idx] != 0.0 {
        let feat_idx = neighbor * in_dim + f
        if feat_idx < graph.node_features.length() {
          let val = graph.node_features[feat_idx]
          match agg_type {
            GNNType::GraphSAGE => {
              sum = sum + val
              count = count + 1
            }
            GNNType::GCN => sum = sum + val
            GNNType::GAT => sum = sum + val
            GNNType::GIN => sum = sum + val
          }
          if val > max_val {
            max_val = val
          }
        }
      }
    }
    let aggregated = match agg_type {
      GNNType::GraphSAGE =>
        if count > 0 {
          sum / count.to_double()
        } else {
          0.0
        }
      GNNType::GCN => sum
      GNNType::GAT => sum
      GNNType::GIN => sum
    }
    result.push(aggregated)
  }
  result
}

///|
/// GAT 前向传播。
/// GAT forward pass.
pub fn gat_forward(
  graph : GraphData,
  weight : Array[Double],
  attention_weight : Array[Double],
  config : GNNConfig,
) -> GNNResult {
  let n = graph.num_nodes
  let in_dim = graph.feature_dim
  let out_dim = config.hidden_dim
  let node_embeddings : Array[Double] = []
  let attention_weights : Array[Double] = []
  for node in 0..<n {
    let attention_scores : Array[Double] = []
    for neighbor in 0..<n {
      let adj_idx = node * n + neighbor
      if adj_idx < graph.adj_matrix.length() && graph.adj_matrix[adj_idx] != 0.0 {
        let mut score = 0.0
        for f in 0..<in_dim {
          let n_feat = neighbor * in_dim + f
          let a_idx = f
          if n_feat < graph.node_features.length() &&
            a_idx < attention_weight.length() {
            score = score +
              graph.node_features[n_feat] * attention_weight[a_idx]
          }
        }
        attention_scores.push(score)
      } else {
        attention_scores.push(0.0)
      }
    }
    let attn_norm = softmax(attention_scores)
    for a in attn_norm {
      attention_weights.push(a)
    }
    for o in 0..<out_dim {
      let mut sum = 0.0
      for neighbor in 0..<n {
        let adj_idx = node * n + neighbor
        if adj_idx < graph.adj_matrix.length() &&
          graph.adj_matrix[adj_idx] != 0.0 {
          for f in 0..<in_dim {
            let feat_idx = neighbor * in_dim + f
            let w_idx = o * in_dim + f
            if feat_idx < graph.node_features.length() &&
              w_idx < weight.length() {
              sum = sum +
                attn_norm[neighbor] *
                graph.node_features[feat_idx] *
                weight[w_idx]
            }
          }
        }
      }
      node_embeddings.push(sum)
    }
  }
  GNNResult::{ node_embeddings, attention_weights, }
}

///|
/// GraphSAGE 前向传播。
/// GraphSAGE forward pass.
pub fn graphsage_forward(
  graph : GraphData,
  weight : Array[Double],
  config : GNNConfig,
) -> Array[Double] {
  let n = graph.num_nodes
  let in_dim = graph.feature_dim
  let out_dim = config.hidden_dim
  let result : Array[Double] = []
  for node in 0..<n {
    let self_feat : Array[Double] = []
    for f in 0..<in_dim {
      let idx = node * in_dim + f
      if idx < graph.node_features.length() {
        self_feat.push(graph.node_features[idx])
      } else {
        self_feat.push(0.0)
      }
    }
    let agg = aggregate_neighbors(graph, node, GNNType::GraphSAGE)
    for o in 0..<out_dim {
      let mut sum = 0.0
      for f in 0..<in_dim {
        let w_idx = o * in_dim * 2 + f
        if w_idx < weight.length() {
          sum = sum + self_feat[f] * weight[w_idx]
        }
        let w_idx2 = o * in_dim * 2 + in_dim + f
        if w_idx2 < weight.length() {
          sum = sum + agg[f] * weight[w_idx2]
        }
      }
      if sum < 0.0 {
        sum = 0.0
      }
      result.push(sum)
    }
  }
  result
}
