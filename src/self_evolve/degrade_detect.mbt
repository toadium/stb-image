// 退化场景自动发现 — 基于 4.7.4 领域规则
// Degradation detection: based on 4.7.4 domain rules
//
// 规则集：
//   1. 数值鲁棒性：除零 / 奇异矩阵 / NaN / Inf
//   2. 退化几何：除零 / 零面积
//   3. 场间断：边界不连续 / 插值外推
//   4. 时空拓扑：时间超出 [0,1]
//   5. 四目标兼容：纯 MoonBit（静态保证，运行时无需检测）

///|
/// 检测单个算子的退化场景。
/// Detect degradation cases for a single op.
pub fn detect_degradation(op : @imgir.IROp) -> Array[DegradationCase] {
  let tag = op.tag()
  match op {
    Resize(w, h) =>
      if w == 0 || h == 0 {
        [
          {
            kind: DivisionByZero,
            op_tag: tag,
            description: "Resize 到零尺寸（w=" +
            w.to_string() +
            ", h=" +
            h.to_string() +
            "），可能触发除零",
            severity: Fatal,
          },
        ]
      } else {
        []
      }
    Crop(_x, _y, w, h) =>
      if w == 0 || h == 0 {
        [
          {
            kind: DivisionByZero,
            op_tag: tag,
            description: "Crop 零尺寸区域，可能触发除零",
            severity: Fatal,
          },
        ]
      } else {
        []
      }
    GaussianBlur(_r, sigma) =>
      if sigma == 0.0F {
        [
          {
            kind: DivisionByZero,
            op_tag: tag,
            description: "GaussianBlur sigma=0.0，高斯核归一化除零",
            severity: Critical,
          },
        ]
      } else if sigma < 0.0F {
        [
          {
            kind: NaNValue,
            op_tag: tag,
            description: "GaussianBlur sigma<0.0，负 sigma 产生 NaN/Inf",
            severity: Critical,
          },
        ]
      } else {
        []
      }
    Sharpen(amount) =>
      if amount > 100.0F || amount < -100.0F {
        [
          {
            kind: Overflow,
            op_tag: tag,
            description: "Sharpen amount 极端值（" +
            amount.to_string() +
            "），可能溢出",
            severity: Warning,
          },
        ]
      } else {
        []
      }
    FieldClamp(lo, hi) =>
      if lo > hi {
        [
          {
            kind: FieldDiscontinuity,
            op_tag: tag,
            description: "FieldClamp 下界 > 上界（lo=" +
            lo.to_string() +
            " > hi=" +
            hi.to_string() +
            "），行为未定义",
            severity: Critical,
          },
        ]
      } else {
        []
      }
    FieldMask(threshold) =>
      if threshold > 1000000.0F || threshold < -1000000.0F {
        [
          {
            kind: FieldDiscontinuity,
            op_tag: tag,
            description: "FieldMask 阈值极端（" +
            threshold.to_string() +
            "），全场单值",
            severity: Warning,
          },
        ]
      } else {
        []
      }
    STSnapshot(t) =>
      if t < 0.0F || t > 1.0F {
        [
          {
            kind: FieldDiscontinuity,
            op_tag: tag,
            description: "STSnapshot t=" +
            t.to_string() +
            " 超出 [0,1]，时间外推",
            severity: Warning,
          },
        ]
      } else {
        []
      }
    STInterpolate(t) =>
      if t < 0.0F || t > 1.0F {
        [
          {
            kind: FieldDiscontinuity,
            op_tag: tag,
            description: "STInterpolate t=" +
            t.to_string() +
            " 超出 [0,1]，插值外推",
            severity: Warning,
          },
        ]
      } else {
        []
      }
    _ => []
  }
}

///|
/// 批量扫描退化场景。
/// Batch scan degradations for multiple ops.
pub fn scan_degradations(ops : Array[@imgir.IROp]) -> Array[DegradationCase] {
  let all : Array[DegradationCase] = []
  for op in ops {
    for d in detect_degradation(op) {
      all.push(d)
    }
  }
  all
}

///|
/// 按严重程度过滤退化场景。
/// Filter degradations by severity.
pub fn filter_by_severity(
  cases : Array[DegradationCase],
  min_severity : Severity,
) -> Array[DegradationCase] {
  let min_level = match min_severity {
    Warning => 0
    Critical => 1
    Fatal => 2
  }
  let result : Array[DegradationCase] = []
  for c in cases {
    let level = match c.severity {
      Warning => 0
      Critical => 1
      Fatal => 2
    }
    if level >= min_level {
      result.push(c)
    }
  }
  result
}

///|
/// 按退化类型分组计数。
/// Count degradations by kind.
pub fn count_by_kind(
  cases : Array[DegradationCase],
) -> Array[(DegradationKind, Int)] {
  let kinds = [
    DivisionByZero,
    SingularMatrix,
    FieldDiscontinuity,
    Overflow,
    NaNValue,
    InfValue,
  ]
  let result : Array[(DegradationKind, Int)] = []
  for k in kinds {
    let mut count = 0
    for c in cases {
      if c.kind == k {
        count = count + 1
      }
    }
    if count > 0 {
      result.push((k, count))
    }
  }
  result
}
