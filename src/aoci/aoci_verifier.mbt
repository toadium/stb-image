// AOCI-Verifier — 依赖一致性/过期检测/边界冲突
// 验证符号索引的完整性和一致性

///|
pub(all) struct VerifyResult {
  is_valid : Bool
  issues : Array[String]
}

///|
pub fn VerifyResult::make(
  is_valid~ : Bool,
  issues? : Array[String] = [],
) -> VerifyResult {
  { is_valid, issues, }
}

///|
pub fn verify_consistency(index : SymbolIndex) -> VerifyResult {
  let issues : Array[String] = []
  let names : Array[String] = []
  for sym in index.symbols {
    if sym.name.length() == 0 {
      issues.push("empty symbol name in package: \{sym.pkg}")
    }
    if sym.pkg.length() == 0 {
      issues.push("empty package for symbol: \{sym.name}")
    }
    let full = sym.full_name()
    let mut found = false
    for n in names {
      if n == full {
        found = true
        break
      }
    }
    if found {
      issues.push("duplicate symbol: \{full}")
    } else {
      names.push(full)
    }
  }
  let is_valid = issues.length() == 0
  { is_valid, issues, }
}

///|
pub fn verify_keyword_coverage(index : SymbolIndex) -> VerifyResult {
  let issues : Array[String] = []
  for sym in index.symbols {
    if sym.keywords.length() == 0 {
      issues.push("no keywords for symbol: \{sym.full_name()}")
    }
  }
  let is_valid = issues.length() == 0
  { is_valid, issues, }
}

///|
pub fn verify_dependencies(
  index : SymbolIndex,
  graph : Array[(String, Array[String])],
) -> VerifyResult {
  let issues : Array[String] = []
  let names : Array[String] = []
  for sym in index.symbols {
    names.push(sym.name)
  }
  for entry in graph {
    for dep in entry.1 {
      let mut found = false
      for n in names {
        if n == dep {
          found = true
          break
        }
      }
      if !found {
        issues.push("unresolved dependency: \{entry.0} -> \{dep}")
      }
    }
  }
  let is_valid = issues.length() == 0
  { is_valid, issues, }
}

///|
pub fn verify_budget(
  index : SymbolIndex,
  budget : ContextBudget,
) -> VerifyResult {
  let issues : Array[String] = []
  let total = index.total_tokens()
  if total > budget.total_quota {
    issues.push("index tokens (\{total}) exceed budget (\{budget.total_quota})")
  }
  for sym in index.symbols {
    let cost = sym.estimated_tokens()
    if cost > budget.total_quota {
      issues.push(
        "single symbol exceeds budget: \{sym.full_name()} (\{cost} tokens)",
      )
    }
  }
  let is_valid = issues.length() == 0
  { is_valid, issues, }
}

///|
pub fn verify_all(
  index : SymbolIndex,
  budget? : ContextBudget = ContextBudget::make(1000000),
) -> VerifyResult {
  let issues : Array[String] = []
  let r1 = verify_consistency(index)
  for issue in r1.issues {
    issues.push(issue)
  }
  let r2 = verify_keyword_coverage(index)
  for issue in r2.issues {
    issues.push(issue)
  }
  let r3 = verify_budget(index, budget)
  for issue in r3.issues {
    issues.push(issue)
  }
  let is_valid = issues.length() == 0
  { is_valid, issues, }
}
