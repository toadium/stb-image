// 测试用例自动生成 — 基于算子签名 + 边界条件
// Auto test case generation: based on op signature + boundary conditions

///|
/// 为单个算子生成全部测试用例（边界 + 正常 + 边缘）。
/// Generate all test cases for a single op (boundary + normal + edge).
pub fn gen_test_for_op(op : @imgir.IROp) -> Array[TestCase] {
  let cases : Array[TestCase] = []
  for c in gen_boundary_tests(op) {
    cases.push(c)
  }
  for c in gen_normal_tests(op) {
    cases.push(c)
  }
  for c in gen_edge_tests(op) {
    cases.push(c)
  }
  cases
}

///|
/// 生成边界条件测试用例。
/// Generate boundary condition test cases.
pub fn gen_boundary_tests(op : @imgir.IROp) -> Array[TestCase] {
  let tag = op.tag()
  match op {
    Resize(_, _) =>
      [
        {
          name: tag + "_boundary_zero",
          op_tag: tag,
          category: Boundary,
          description: "缩放到 0x0 尺寸",
          input_spec: "Image(w>0, h>0) → Resize(0, 0)",
          expected_behavior: "返回空图像或抛异常",
        },
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "缩放到 1x1 尺寸",
          input_spec: "Image(w>1, h>1) → Resize(1, 1)",
          expected_behavior: "返回 1x1 图像",
        },
      ]
    Rotate90 =>
      [
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "1x1 图旋转 90°",
          input_spec: "Image(1, 1) → Rotate90",
          expected_behavior: "返回 1x1 图像（不变）",
        },
      ]
    FlipH =>
      [
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "1x1 图水平翻转",
          input_spec: "Image(1, 1) → FlipH",
          expected_behavior: "返回 1x1 图像（不变）",
        },
      ]
    FlipV =>
      [
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "1x1 图垂直翻转",
          input_spec: "Image(1, 1) → FlipV",
          expected_behavior: "返回 1x1 图像（不变）",
        },
      ]
    Crop(_, _, _, _) =>
      [
        {
          name: tag + "_boundary_zero",
          op_tag: tag,
          category: Boundary,
          description: "裁剪 0x0 区域",
          input_spec: "Image(w, h) → Crop(0, 0, 0, 0)",
          expected_behavior: "返回空图像或抛异常",
        },
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "裁剪 1x1 区域",
          input_spec: "Image(w>=1, h>=1) → Crop(0, 0, 1, 1)",
          expected_behavior: "返回 1x1 图像",
        },
      ]
    ToGray =>
      [
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "1x1 RGB 图转灰度",
          input_spec: "Image(1, 1, RGB) → ToGray",
          expected_behavior: "返回 1x1 灰度图",
        },
      ]
    Brightness(_) =>
      [
        {
          name: tag + "_boundary_zero",
          op_tag: tag,
          category: Boundary,
          description: "亮度调整 delta=0",
          input_spec: "Image → Brightness(0)",
          expected_behavior: "图像不变",
        },
      ]
    GaussianBlur(_, _) =>
      [
        {
          name: tag + "_boundary_zero_radius",
          op_tag: tag,
          category: Boundary,
          description: "高斯模糊 radius=0",
          input_spec: "Image → GaussianBlur(0, 1.0)",
          expected_behavior: "图像不变（零半径无模糊）",
        },
      ]
    BoxBlur(_) =>
      [
        {
          name: tag + "_boundary_zero",
          op_tag: tag,
          category: Boundary,
          description: "均值模糊 radius=0",
          input_spec: "Image → BoxBlur(0)",
          expected_behavior: "图像不变",
        },
      ]
    Sharpen(_) =>
      [
        {
          name: tag + "_boundary_zero",
          op_tag: tag,
          category: Boundary,
          description: "锐化 amount=0",
          input_spec: "Image → Sharpen(0.0)",
          expected_behavior: "图像不变",
        },
      ]
    ToScalarField =>
      [
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "1x1 图转标量场",
          input_spec: "Image(1, 1) → ToScalarField",
          expected_behavior: "返回 1x1 标量场",
        },
      ]
    FieldGradient =>
      [
        {
          name: tag + "_boundary_constant",
          op_tag: tag,
          category: Boundary,
          description: "常量场求梯度",
          input_spec: "ScalarField(常量) → FieldGradient",
          expected_behavior: "返回零矢量场（梯度=0）",
        },
      ]
    FieldLaplacian =>
      [
        {
          name: tag + "_boundary_linear",
          op_tag: tag,
          category: Boundary,
          description: "线性场求拉普拉斯",
          input_spec: "ScalarField(线性) → FieldLaplacian",
          expected_behavior: "返回零场（laplacian=0）",
        },
      ]
    FieldIntegrate =>
      [
        {
          name: tag + "_boundary_zero",
          op_tag: tag,
          category: Boundary,
          description: "零场积分",
          input_spec: "ScalarField(全零) → FieldIntegrate",
          expected_behavior: "返回 0.0",
        },
      ]
    FieldClamp(_, _) =>
      [
        {
          name: tag + "_boundary_equal",
          op_tag: tag,
          category: Boundary,
          description: "clamp 上下界相等",
          input_spec: "ScalarField → FieldClamp(v, v)",
          expected_behavior: "返回常量场（全部 = v）",
        },
      ]
    FieldMask(_) =>
      [
        {
          name: tag + "_boundary_zero",
          op_tag: tag,
          category: Boundary,
          description: "阈值=0 的掩码",
          input_spec: "ScalarField → FieldMask(0.0)",
          expected_behavior: "正值→1，零/负→0",
        },
      ]
    ScalarFieldToImage =>
      [
        {
          name: tag + "_boundary_one",
          op_tag: tag,
          category: Boundary,
          description: "1x1 标量场转图像",
          input_spec: "ScalarField(1, 1) → ScalarFieldToImage",
          expected_behavior: "返回 1x1 图像",
        },
      ]
    STSnapshot(_) =>
      [
        {
          name: tag + "_boundary_start",
          op_tag: tag,
          category: Boundary,
          description: "t=0.0 快照（起始帧）",
          input_spec: "TImage → STSnapshot(0.0)",
          expected_behavior: "返回起始帧",
        },
        {
          name: tag + "_boundary_end",
          op_tag: tag,
          category: Boundary,
          description: "t=1.0 快照（末帧）",
          input_spec: "TImage → STSnapshot(1.0)",
          expected_behavior: "返回末帧",
        },
      ]
    STInterpolate(_) =>
      [
        {
          name: tag + "_boundary_start",
          op_tag: tag,
          category: Boundary,
          description: "t=0.0 插值（起始帧）",
          input_spec: "TImage → STInterpolate(0.0)",
          expected_behavior: "返回起始帧",
        },
        {
          name: tag + "_boundary_end",
          op_tag: tag,
          category: Boundary,
          description: "t=1.0 插值（末帧）",
          input_spec: "TImage → STInterpolate(1.0)",
          expected_behavior: "返回末帧",
        },
      ]
  }
}

///|
/// 生成正常用例。
/// Generate normal test cases.
pub fn gen_normal_tests(op : @imgir.IROp) -> Array[TestCase] {
  let tag = op.tag()
  [
    {
      name: tag + "_normal",
      op_tag: tag,
      category: Normal,
      description: tag + " 正常输入",
      input_spec: "标准尺寸图像/场/时序",
      expected_behavior: "返回有效结果",
    },
  ]
}

///|
/// 生成边缘用例（极端参数）。
/// Generate edge cases (extreme parameters).
pub fn gen_edge_tests(op : @imgir.IROp) -> Array[TestCase] {
  let tag = op.tag()
  match op {
    Resize(_, _) =>
      [
        {
          name: tag + "_edge_huge",
          op_tag: tag,
          category: EdgeCase,
          description: "缩放到超大尺寸",
          input_spec: "Image(8, 8) → Resize(10000, 10000)",
          expected_behavior: "返回大图像或内存溢出",
        },
      ]
    Crop(_, _, _, _) =>
      [
        {
          name: tag + "_edge_out_of_bounds",
          op_tag: tag,
          category: EdgeCase,
          description: "裁剪区域超出图像边界",
          input_spec: "Image(8, 8) → Crop(5, 5, 10, 10)",
          expected_behavior: "抛异常或截断到有效区域",
        },
      ]
    Brightness(_) =>
      [
        {
          name: tag + "_edge_extreme",
          op_tag: tag,
          category: EdgeCase,
          description: "亮度调整 delta=±1000",
          input_spec: "Image → Brightness(1000) / Brightness(-1000)",
          expected_behavior: "全白/全黑（clamp 到 0-255）",
        },
      ]
    GaussianBlur(_, _) =>
      [
        {
          name: tag + "_edge_zero_sigma",
          op_tag: tag,
          category: EdgeCase,
          description: "高斯模糊 sigma=0.0",
          input_spec: "Image → GaussianBlur(3, 0.0)",
          expected_behavior: "退化：除零或返回原图",
        },
      ]
    Sharpen(_) =>
      [
        {
          name: tag + "_edge_huge",
          op_tag: tag,
          category: EdgeCase,
          description: "锐化 amount=1000.0",
          input_spec: "Image → Sharpen(1000.0)",
          expected_behavior: "极端锐化（可能溢出/clamp）",
        },
      ]
    FieldClamp(_, _) =>
      [
        {
          name: tag + "_edge_inverted",
          op_tag: tag,
          category: EdgeCase,
          description: "clamp 下界 > 上界",
          input_spec: "ScalarField → FieldClamp(1.0, 0.0)",
          expected_behavior: "退化：行为未定义或交换边界",
        },
      ]
    STSnapshot(_) =>
      [
        {
          name: tag + "_edge_out_of_range",
          op_tag: tag,
          category: EdgeCase,
          description: "t=2.0 超出 [0,1] 范围",
          input_spec: "TImage → STSnapshot(2.0)",
          expected_behavior: "外推或抛异常",
        },
      ]
    STInterpolate(_) =>
      [
        {
          name: tag + "_edge_out_of_range",
          op_tag: tag,
          category: EdgeCase,
          description: "t=-1.0 超出 [0,1] 范围",
          input_spec: "TImage → STInterpolate(-1.0)",
          expected_behavior: "外推或抛异常",
        },
      ]
    _ => []
  }
}

///|
/// 批量生成测试用例。
/// Batch generate test cases for multiple ops.
pub fn evolve_test_suite(ops : Array[@imgir.IROp]) -> Array[TestCase] {
  let all : Array[TestCase] = []
  for op in ops {
    for c in gen_test_for_op(op) {
      all.push(c)
    }
  }
  all
}
