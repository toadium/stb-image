// 算子等价性检查 — 恒等算子 + 互逆算子对
// Op equivalence: identity ops + inverse pairs

///|
/// 判断算子是否为恒等（对图像无效果）。
/// Check if an op is identity (no effect on image).
pub fn is_identity_op(op : @imgir.IROp) -> Bool {
  match op {
    @imgir.Brightness(0) => true
    @imgir.GaussianBlur(0, _) => true
    @imgir.BoxBlur(0) => true
    @imgir.Sharpen(0.0F) => true
    @imgir.Resize(w, h) => w == -1 && h == -1 // 标记恒等（非实际语义）
    _ => false
  }
}

///|
/// 判断两个算子是否互逆（连续执行 = 恒等）。
/// Check if two ops are inverse (composition = identity).
pub fn check_inverse_pair(op1 : @imgir.IROp, op2 : @imgir.IROp) -> Bool {
  match (op1, op2) {
    (@imgir.FlipH, @imgir.FlipH) => true
    (@imgir.FlipV, @imgir.FlipV) => true
    (@imgir.Rotate90, @imgir.Rotate90) => false // 需要四次才恒等
    (@imgir.ToGray, @imgir.ToGray) => false // 幂等但非互逆
    _ => false
  }
}

///|
/// 判断两个算子是否可合并（同类相邻）。
/// Check if two ops can be merged (same type, adjacent).
pub fn can_merge(op1 : @imgir.IROp, op2 : @imgir.IROp) -> Bool {
  match (op1, op2) {
    (@imgir.Brightness(_), @imgir.Brightness(_)) => true
    (@imgir.GaussianBlur(r1, _), @imgir.GaussianBlur(r2, _)) => r1 == r2 // 同半径可合并
    (@imgir.BoxBlur(_), @imgir.BoxBlur(_)) => true
    _ => false
  }
}

///|
/// 合并两个同类算子。
/// Merge two same-type ops into one.
pub fn merge_ops(op1 : @imgir.IROp, op2 : @imgir.IROp) -> @imgir.IROp {
  match (op1, op2) {
    (@imgir.Brightness(a), @imgir.Brightness(b)) => @imgir.Brightness(a + b)
    (@imgir.GaussianBlur(r, s1), @imgir.GaussianBlur(_, s2)) =>
      @imgir.GaussianBlur(r, s1 + s2) // sigma 简单相加（近似）
    (@imgir.BoxBlur(r1), @imgir.BoxBlur(r2)) =>
      @imgir.BoxBlur(if r1 > r2 { r1 } else { r2 }) // 取较大半径
    _ => op1 // 无法合并，返回第一个
  }
}

///|
/// 判断 Rotate90 的连续次数是否为恒等。
/// Check if n consecutive Rotate90 = identity (n % 4 == 0).
pub fn rotate90_power_is_identity(n : Int) -> Bool {
  n % 4 == 0
}
