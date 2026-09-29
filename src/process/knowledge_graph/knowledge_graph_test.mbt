///|
test "create_default_kg_config: returns hybrid config" {
  let config = create_default_kg_config()
  assert_eq(config.embedding_dim, 128)
  assert_eq(config.max_hops, 3)
  assert_true((config.confidence_threshold - 0.5).abs() < 0.0000000001)
  assert_false(config.use_temporal)
  assert_false(config.use_spatial)
  assert_true(config.construction_method is KGConstructionMethod::Hybrid)
  assert_true(config.entity_linking_method is EntityLinkingMethod::Neural)
  assert_true(
    config.relation_extraction_method is RelationExtractionMethod::Neural,
  )
  assert_true(
    config.reasoning_method is KnowledgeReasoningMethod::EmbeddingBased,
  )
}

///|
test "create_empty_knowledge_graph: returns empty graph" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Neural)
  assert_eq(kg.num_entities, 0)
  assert_eq(kg.num_relations, 0)
  assert_eq(kg.num_entity_types, 0)
  assert_eq(kg.num_relation_types, 0)
  assert_eq(kg.entities.length(), 0)
  assert_eq(kg.relations.length(), 0)
  assert_true(kg.construction_method is KGConstructionMethod::Neural)
}

///|
test "add_entity: adds entity to graph" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let entity = KGEntity::{
    entity_id: "e1",
    entity_name: "Albert Einstein",
    entity_type: "Person",
    description: "Physicist",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let kg2 = add_entity(kg, entity)
  assert_eq(kg2.num_entities, 1)
  assert_eq(kg2.entities.length(), 1)
  assert_eq(kg2.entities[0].entity_id, "e1")
  assert_eq(kg2.num_entity_types, 1)
}

///|
test "add_entity: multiple entities" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let e1 = KGEntity::{
    entity_id: "e1",
    entity_name: "A",
    entity_type: "Person",
    description: "",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let e2 = KGEntity::{
    entity_id: "e2",
    entity_name: "B",
    entity_type: "Organization",
    description: "",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.8,
  }
  let kg2 = add_entity(add_entity(kg, e1), e2)
  assert_eq(kg2.num_entities, 2)
  assert_eq(kg2.entities.length(), 2)
  assert_eq(kg2.num_entity_types, 2)
}

///|
test "add_relation: adds relation to graph" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let relation = KGRelation::{
    relation_id: "r1",
    source_entity_id: "e1",
    target_entity_id: "e2",
    relation_type: "works_for",
    relation_label: "works for",
    confidence: 0.85,
    evidence: "text evidence",
    timestamp: 1000.0,
  }
  let kg2 = add_relation(kg, relation)
  assert_eq(kg2.num_relations, 1)
  assert_eq(kg2.relations.length(), 1)
  assert_eq(kg2.relations[0].relation_id, "r1")
  assert_eq(kg2.num_relation_types, 1)
}

///|
test "link_entity: finds matching entity" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let entity = KGEntity::{
    entity_id: "e1",
    entity_name: "Albert Einstein",
    entity_type: "Person",
    description: "Physicist",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let kg2 = add_entity(kg, entity)
  let config = create_default_kg_config()
  let result = link_entity("Albert Einstein", kg2, config)
  assert_true(result.num_candidates >= 1)
  assert_eq(result.linked_entity, "e1")
  assert_true((result.confidence - 1.0).abs() < 0.0000000001)
}

///|
test "link_entity: no matching entity" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let config = create_default_kg_config()
  let result = link_entity("NonExistent", kg, config)
  assert_eq(result.num_candidates, 0)
  assert_eq(result.linked_entity, "")
  assert_eq(result.confidence, 0.0)
}

///|
test "extract_relation: detects relation from sentence" {
  let config = create_default_kg_config()
  let result = extract_relation(
    "Einstein is a physicist", "Einstein", "physicist", config,
  )
  assert_eq(result.relation_type, "is_a")
  assert_true((result.confidence - 0.8).abs() < 0.0000000001)
  assert_eq(result.source_entity, "Einstein")
  assert_eq(result.target_entity, "physicist")
  assert_eq(result.evidence_span.length(), 2)
}

///|
test "extract_relation: no keyword match" {
  let config = create_default_kg_config()
  let result = extract_relation(
    "Einstein something something physicist", "Einstein", "physicist", config,
  )
  assert_eq(result.relation_type, "related_to")
  assert_true((result.confidence - 0.3).abs() < 0.0000000001)
}

///|
test "reason_over_kg: finds relations for entity" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let e1 = KGEntity::{
    entity_id: "e1",
    entity_name: "Einstein",
    entity_type: "Person",
    description: "",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let r1 = KGRelation::{
    relation_id: "r1",
    source_entity_id: "e1",
    target_entity_id: "e2",
    relation_type: "born_in",
    relation_label: "born in Ulm",
    confidence: 0.9,
    evidence: "",
    timestamp: 0.0,
  }
  let kg2 = add_relation(add_entity(kg, e1), r1)
  let config = create_default_kg_config()
  let result = reason_over_kg("What about Einstein?", kg2, config)
  assert_true(result.num_hops >= 1)
  assert_true(result.reasoning_path.length() >= 3)
  assert_true(result.supporting_facts.length() >= 1)
  assert_true(result.answer.contains("relations"))
  assert_true((result.confidence - 0.7).abs() < 0.0000000001)
}

///|
test "reason_over_kg: entity not in graph" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let config = create_default_kg_config()
  let result = reason_over_kg("What about Nobody?", kg, config)
  assert_eq(result.num_hops, 0)
  assert_eq(result.answer, "unknown")
  assert_true((result.confidence - 0.3).abs() < 0.0000000001)
}

///|
test "train_kg_embedding: generates embeddings for entities and relations" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let e1 = KGEntity::{
    entity_id: "e1",
    entity_name: "A",
    entity_type: "Person",
    description: "",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let e2 = KGEntity::{
    entity_id: "e2",
    entity_name: "B",
    entity_type: "Person",
    description: "",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let r1 = KGRelation::{
    relation_id: "r1",
    source_entity_id: "e1",
    target_entity_id: "e2",
    relation_type: "knows",
    relation_label: "knows",
    confidence: 0.8,
    evidence: "",
    timestamp: 0.0,
  }
  let kg2 = add_relation(add_entity(add_entity(kg, e1), e2), r1)
  let config = create_default_kg_config()
  let embedding = train_kg_embedding(kg2, config)
  assert_eq(embedding.embedding_dim, 128)
  assert_eq(embedding.num_entities, 2)
  assert_eq(embedding.num_relations, 1)
  assert_eq(embedding.entity_embeddings.length(), 2)
  assert_eq(embedding.relation_embeddings.length(), 1)
  assert_eq(embedding.entity_embeddings[0].length(), 128)
  assert_eq(embedding.model_type, "TransE")
  assert_true((embedding.training_loss - 0.1).abs() < 0.0000000001)
}

///|
test "compute_kg_statistics: empty graph" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let (avg_degree, density, clustering) = compute_kg_statistics(kg)
  assert_eq(avg_degree, 0.0)
  assert_true(density >= 0.0)
  assert_true((clustering - 0.3).abs() < 0.0000000001)
}

///|
test "compute_kg_statistics: graph with entities and relations" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let e1 = KGEntity::{
    entity_id: "e1",
    entity_name: "A",
    entity_type: "Person",
    description: "",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let e2 = KGEntity::{
    entity_id: "e2",
    entity_name: "B",
    entity_type: "Person",
    description: "",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let r1 = KGRelation::{
    relation_id: "r1",
    source_entity_id: "e1",
    target_entity_id: "e2",
    relation_type: "knows",
    relation_label: "knows",
    confidence: 0.8,
    evidence: "",
    timestamp: 0.0,
  }
  let kg2 = add_relation(add_entity(add_entity(kg, e1), e2), r1)
  let (avg_degree, density, clustering) = compute_kg_statistics(kg2)
  assert_true((avg_degree - 1.0).abs() < 0.0000000001)
  assert_true(density > 0.0 && density <= 1.0)
  assert_true((clustering - 0.3).abs() < 0.0000000001)
}

///|
test "knowledge_graph_report_to_string: contains graph statistics" {
  let kg = create_empty_knowledge_graph(KGConstructionMethod::Hybrid)
  let e1 = KGEntity::{
    entity_id: "e1",
    entity_name: "Einstein",
    entity_type: "Person",
    description: "Physicist",
    properties: [],
    property_values: [],
    num_relations: 0,
    confidence: 0.9,
  }
  let kg2 = add_entity(kg, e1)
  let config = create_default_kg_config()
  let embedding = train_kg_embedding(kg2, config)
  let report = knowledge_graph_report_to_string(kg2, config, embedding)
  assert_true(report.contains("知识图谱与推理报告"))
  assert_true(report.contains("TransE"))
  assert_true(report.contains("混合"))
  assert_true(report.contains("神经"))
  assert_true(report.contains("基于嵌入"))
}
