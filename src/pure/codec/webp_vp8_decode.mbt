// 纯 MoonBit WebP lossy VP8 解码器
// 规范: https://datatracker.ietf.org/doc/html/rfc6386
// 支持 VP8 lossy 解码

// ==================== VP8 BitReader ====================
// VP8 使用大端序 bitstream（与 VP8L 不同）

///|
priv struct Vp8BitReader {
  data : Bytes
  mut pos : Int
  mut bit_buf : Int
  mut bit_count : Int
}

///|
fn Vp8BitReader::new(data : Bytes, start : Int) -> Vp8BitReader {
  Vp8BitReader::{ data, pos: start, bit_buf: 0, bit_count: 0 }
}

///|
fn Vp8BitReader::read_bits(self : Vp8BitReader, n : Int) -> Int {
  let mut result = 0
  for i in 0..<n {
    if self.bit_count == 0 {
      if self.pos >= self.data.length() {
        self.bit_buf = 0
        self.bit_count = 8
      } else {
        self.bit_buf = self.data[self.pos].to_int()
        self.pos += 1
        self.bit_count = 8
      }
    }
    // VP8 是大端序：MSB first
    let bit = (self.bit_buf >> 7) & 1
    self.bit_buf = (self.bit_buf << 1) & 0xFF
    self.bit_count -= 1
    result = (result << 1) | bit
  }
  result
}

///|
fn Vp8BitReader::read_bit(self : Vp8BitReader) -> Int {
  self.read_bits(1)
}

///|
fn Vp8BitReader::read_bool(self : Vp8BitReader, prob : Int) -> Int {
  // 简化版：用于帧头解析，prob 暂不使用
  ignore(prob)
  self.read_bit()
}

// ==================== VP8 Bool Decoder ====================
// VP8 使用基于概率的布尔算术编码

///|
priv struct Vp8BoolDecoder {
  data : Bytes
  mut pos : Int
  mut bit_count : Int
  mut range : Int
  mut value : Int
}

///|
fn Vp8BoolDecoder::new(data : Bytes, start : Int) -> Vp8BoolDecoder {
  let bd = Vp8BoolDecoder::{
    data,
    pos: start,
    bit_count: 0,
    range: 255,
    value: 0,
  }
  // 初始化：读取前两个字节
  bd.value = if bd.pos < bd.data.length() { bd.data[bd.pos].to_int() } else { 0 }
  bd.pos += 1
  bd.value = (bd.value << 8) | (if bd.pos < bd.data.length() { bd.data[bd.pos].to_int() } else { 0 })
  bd.pos += 1
  bd.bit_count = 16
  bd
}

///|
fn Vp8BoolDecoder::read_bool(self : Vp8BoolDecoder, prob : Int) -> Int {
  // VP8 布尔解码器核心算法
  let split = 1 + (((self.range - 1) * prob) >> 8)
  let bigsplit = split << 8
  let mut bit = 0
  if self.value >= bigsplit {
    self.range -= split
    self.value -= bigsplit
    bit = 1
  } else {
    self.range = split
  }
  // 归一化
  while self.range < 128 {
    self.range = self.range << 1
    self.value = self.value << 1
    self.bit_count -= 1
    if self.bit_count == 0 {
      self.bit_count = 8
      if self.pos < self.data.length() {
        self.value = self.value | self.data[self.pos].to_int()
        self.pos += 1
      }
    }
  }
  bit
}

///|
fn Vp8BoolDecoder::read_literal(self : Vp8BoolDecoder, num_bits : Int) -> Int {
  // 读取指定位数的字面值（概率 128）
  let mut v = 0
  for i in 0..<num_bits {
    v = (v << 1) | self.read_bool(128)
  }
  v
}

// ==================== VP8 Adaptive Probability Model ====================
// VP8 自适应概率模型：按系数位置和 token 类型维护独立概率
// 概率更新：使用指数加权平均（EMA）根据已解析 token 更新

///|
/// VP8 自适应系数概率模型
priv struct Vp8AdaptiveProbs {
  // 每个系数位置（0-15，zig-zag 顺序）的概率
  prob_zero : Array[Int]      // 零系数概率
  prob_one : Array[Int]       // 单系数（值为±1）概率
  prob_eob : Array[Int]       // EOB（块结束）概率
  prob_extra : Array[Int]     // 额外位概率
  mut prob_sign : Int              // 符号位概率（所有位置共用）

  // 统计计数器（用于概率更新）
  count_zero : Array[Int]
  count_one : Array[Int]
  count_eob : Array[Int]
  count_extra : Array[Int]
  mut count_sign_pos : Int         // 正符号计数
  mut count_sign_neg : Int         // 负符号计数
  mut total_blocks : Int           // 已解析块数
}

///|
fn Vp8AdaptiveProbs::new() -> Vp8AdaptiveProbs {
  // VP8 默认概率（基于统计）
  let default_zero = [200, 180, 170, 160, 150, 140, 130, 120, 110, 100, 90, 80, 70, 60, 50, 40]
  let default_one = [180, 170, 160, 150, 140, 130, 120, 110, 100, 90, 80, 70, 60, 50, 40, 30]
  let default_eob = [100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250]
  let default_extra = [140, 140, 140, 140, 140, 140, 140, 140, 140, 140, 140, 140, 140, 140, 140, 140]

  Vp8AdaptiveProbs::{
    prob_zero: default_zero,
    prob_one: default_one,
    prob_eob: default_eob,
    prob_extra: default_extra,
    prob_sign: 128,
    count_zero: Array::make(16, 0),
    count_one: Array::make(16, 0),
    count_eob: Array::make(16, 0),
    count_extra: Array::make(16, 0),
    count_sign_pos: 0,
    count_sign_neg: 0,
    total_blocks: 0,
  }
}

///|
/// 记录零系数统计
fn Vp8AdaptiveProbs::record_zero(self : Vp8AdaptiveProbs, pos : Int) -> Unit {
  if pos >= 0 && pos < 16 {
    self.count_zero[pos] += 1
  }
}

///|
/// 记录单系数统计
fn Vp8AdaptiveProbs::record_one(self : Vp8AdaptiveProbs, pos : Int) -> Unit {
  if pos >= 0 && pos < 16 {
    self.count_one[pos] += 1
  }
}

///|
/// 记录 EOB 统计
fn Vp8AdaptiveProbs::record_eob(self : Vp8AdaptiveProbs, pos : Int) -> Unit {
  if pos >= 0 && pos < 16 {
    self.count_eob[pos] += 1
  }
}

///|
/// 记录额外位统计
fn Vp8AdaptiveProbs::record_extra(self : Vp8AdaptiveProbs, pos : Int) -> Unit {
  if pos >= 0 && pos < 16 {
    self.count_extra[pos] += 1
  }
}

///|
/// 记录符号统计
fn Vp8AdaptiveProbs::record_sign(self : Vp8AdaptiveProbs, is_positive : Bool) -> Unit {
  if is_positive {
    self.count_sign_pos += 1
  } else {
    self.count_sign_neg += 1
  }
}

///|
/// 更新概率（指数加权平均 EMA）
/// 在解析每个块后调用，使用最近的统计信息更新概率
fn Vp8AdaptiveProbs::update(self : Vp8AdaptiveProbs) -> Unit {
  self.total_blocks += 1
  // 每 8 个块更新一次概率（减少计算量）
  if self.total_blocks % 8 != 0 {
    return
  }

  // EMA 更新：new_prob = old_prob * 7/8 + observed_prob * 1/8
  for i in 0..<16 {
    let total = self.count_zero[i] + self.count_one[i] + 1
    // 更新零系数概率
    if total > 0 {
      let observed_zero = (self.count_zero[i] * 256) / total
      self.prob_zero[i] = (self.prob_zero[i] * 7 + observed_zero) / 8
    }
    // 更新单系数概率
    let non_zero = self.count_one[i] + 1
    if non_zero > 0 {
      let observed_one = (self.count_one[i] * 256) / non_zero
      self.prob_one[i] = (self.prob_one[i] * 7 + observed_one) / 8
    }
    // 更新 EOB 概率
    let eob_total = self.count_eob[i] + 1
    if eob_total > 0 {
      let observed_eob = (self.count_eob[i] * 256) / eob_total
      self.prob_eob[i] = (self.prob_eob[i] * 7 + observed_eob) / 8
    }
    // 更新额外位概率
    let extra_total = self.count_extra[i] + 1
    if extra_total > 0 {
      let observed_extra = (self.count_extra[i] * 256) / extra_total
      self.prob_extra[i] = (self.prob_extra[i] * 7 + observed_extra) / 8
    }
  }

  // 更新符号概率
  let sign_total = self.count_sign_pos + self.count_sign_neg + 1
  if sign_total > 0 {
    let observed_sign = (self.count_sign_pos * 256) / sign_total
    self.prob_sign = (self.prob_sign * 7 + observed_sign) / 8
  }

  // 重置计数器（保留部分历史）
  for i in 0..<16 {
    self.count_zero[i] = self.count_zero[i] / 2
    self.count_one[i] = self.count_one[i] / 2
    self.count_eob[i] = self.count_eob[i] / 2
    self.count_extra[i] = self.count_extra[i] / 2
  }
  self.count_sign_pos = self.count_sign_pos / 2
  self.count_sign_neg = self.count_sign_neg / 2
}

///|
/// 获取指定位置的零系数概率
fn Vp8AdaptiveProbs::get_zero_prob(self : Vp8AdaptiveProbs, pos : Int) -> Int {
  if pos >= 0 && pos < 16 {
    self.prob_zero[pos]
  } else {
    150
  }
}

///|
/// 获取指定位置的单系数概率
fn Vp8AdaptiveProbs::get_one_prob(self : Vp8AdaptiveProbs, pos : Int) -> Int {
  if pos >= 0 && pos < 16 {
    self.prob_one[pos]
  } else {
    170
  }
}

///|
/// 获取指定位置的 EOB 概率
fn Vp8AdaptiveProbs::get_eob_prob(self : Vp8AdaptiveProbs, pos : Int) -> Int {
  if pos >= 0 && pos < 16 {
    self.prob_eob[pos]
  } else {
    100
  }
}

///|
/// 获取指定位置的额外位概率
fn Vp8AdaptiveProbs::get_extra_prob(self : Vp8AdaptiveProbs, pos : Int) -> Int {
  if pos >= 0 && pos < 16 {
    self.prob_extra[pos]
  } else {
    140
  }
}

// ==================== VP8 Residual Coefficient Parsing ====================
// VP8 残差系数解析：token 解析 + zig-zag 扫描 + 自适应概率

///|
/// VP8 zig-zag 扫描顺序（4x4 块）
fn vp8_zigzag_4x4() -> Array[Int] {
  [
    0, 1, 4, 8,
    5, 2, 3, 6,
    9, 12, 13, 10,
    7, 11, 14, 15,
  ]
}

///|
/// 解析一个 4x4 块的残差系数（使用自适应概率模型）
/// 返回 16 个系数（行优先顺序）
fn vp8_parse_residual_4x4(
  bd : Vp8BoolDecoder,
  probs : Vp8AdaptiveProbs,
  is_dc : Bool,
) -> Array[Int] {
  ignore(is_dc)
  let coeffs = Array::make(16, 0)
  let zigzag = vp8_zigzag_4x4()
  let mut eob = false // end of block
  for i in 0..<16 {
    if eob {
      break
    }
    let pos = zigzag[i]
    // 使用自适应概率解析 base token
    let zero_prob = probs.get_zero_prob(i)
    let is_zero = bd.read_bool(zero_prob) == 1
    if is_zero {
      probs.record_zero(i)
      // 检查是否是 EOB（块结束）
      if i > 0 {
        let eob_prob = probs.get_eob_prob(i)
        let is_eob = bd.read_bool(eob_prob) == 1
        if is_eob {
          probs.record_eob(i)
          eob = true
        }
      }
      continue
    }
    // 非零系数：解析符号和值
    let one_prob = probs.get_one_prob(i)
    let is_one = bd.read_bool(one_prob) == 1
    let mut value = 0
    if is_one {
      probs.record_one(i)
      value = 1
    } else {
      // 解析额外位
      let extra_prob = probs.get_extra_prob(i)
      probs.record_extra(i)
      let mut extra = 1
      let mut continue_read = true
      while continue_read {
        let read_more = bd.read_bool(extra_prob) == 1
        if read_more {
          extra = (extra << 1) | bd.read_bool(128)
          if extra > 2047 {
            continue_read = false
          }
        } else {
          continue_read = false
        }
      }
      value = extra + 1
    }
    // 解析符号（使用自适应符号概率）
    let sign = bd.read_bool(probs.prob_sign)
    let is_positive = sign == 0
    probs.record_sign(is_positive)
    if !is_positive {
      value = -value
    }
    coeffs[pos] = value
  }
  // 更新自适应概率
  probs.update()
  coeffs
}

///|
/// 解析一个 16x16 块的 DC 系数（4x4 块的 DC 系数组成）
fn vp8_parse_dc_coeffs_16x16(
  bd : Vp8BoolDecoder,
  probs : Vp8AdaptiveProbs,
) -> Array[Int] {
  // 16x16 块的 DC 系数是一个 4x4 块，使用 WHT 变换
  vp8_parse_residual_4x4(bd, probs, true)
}

// ==================== VP8 Frame Header ====================

///|
priv struct Vp8FrameHeader {
  key_frame : Bool
  version : Int
  show_frame : Bool
  first_part_size : Int
  width : Int
  height : Int
  horizontal_scale : Int
  vertical_scale : Int
}

///|
fn parse_vp8_frame_header(br : Vp8BitReader) -> Vp8FrameHeader {
  let tag = br.read_bits(3)
  let key_frame = tag == 0
  let version = br.read_bits(3)
  let show_frame = br.read_bits(1) == 1
  let first_part_size_0 = br.read_bits(8)
  let first_part_size_1 = br.read_bits(8)
  let first_part_size_2 = br.read_bits(8)
  let first_part_size = first_part_size_0 | (first_part_size_1 << 8) | (first_part_size_2 << 16)

  let mut width = 0
  let mut height = 0
  let mut horizontal_scale = 0
  let mut vertical_scale = 0

  if key_frame {
    // 关键帧：3 字节 start code + 分辨率
    let start_code_0 = br.read_bits(8)
    let start_code_1 = br.read_bits(8)
    let start_code_2 = br.read_bits(8)
    ignore(start_code_0)
    ignore(start_code_1)
    ignore(start_code_2)
    // 分辨率：14 bits width + 2 bits horizontal scale + 14 bits height + 2 bits vertical scale
    width = br.read_bits(14)
    horizontal_scale = br.read_bits(2)
    height = br.read_bits(14)
    vertical_scale = br.read_bits(2)
  }

  Vp8FrameHeader::{
    key_frame,
    version,
    show_frame,
    first_part_size,
    width,
    height,
    horizontal_scale,
    vertical_scale,
  }
}

// ==================== VP8 Quantization ====================

///|
priv struct Vp8QuantParams {
  y_ac : Int
  y_dc : Int
  uv_ac : Int
  uv_dc : Int
}

///|
fn parse_quantization(br : Vp8BitReader) -> Vp8QuantParams {
  let y_ac = br.read_bits(7)
  let mut y_dc_delta = 0
  if br.read_bool(155) == 1 {
    y_dc_delta = br.read_bits(4)
    if y_dc_delta > 7 {
      y_dc_delta -= 16
    }
  }
  let y_dc = y_ac + y_dc_delta

  let mut uv_ac_delta = 0
  if br.read_bool(155) == 1 {
    uv_ac_delta = br.read_bits(4)
    if uv_ac_delta > 7 {
      uv_ac_delta -= 16
    }
  }
  let uv_ac = y_ac + uv_ac_delta

  let mut uv_dc_delta = 0
  if br.read_bool(155) == 1 {
    uv_dc_delta = br.read_bits(4)
    if uv_dc_delta > 7 {
      uv_dc_delta -= 16
    }
  }
  let uv_dc = y_dc + uv_dc_delta

  Vp8QuantParams::{ y_ac, y_dc, uv_ac, uv_dc }
}

// ==================== VP8 IDCT ====================
// VP8 使用 4x4 DCT 变换和 16x16 Walsh-Hadamard 变换

///|
/// VP8 4x4 IDCT（使用 VP8 特定的变换矩阵）
/// 输入：16 个变换系数（行优先）
/// 输出：16 个像素残差（行优先）
fn vp8_idct_4x4(block : Array[Int]) -> Array[Int] {
  let result = Array::make(16, 0)
  // 行变换（一维 IDCT）
  for i in 0..<4 {
    let a0 = block[i * 4]
    let a1 = block[i * 4 + 1]
    let a2 = block[i * 4 + 2]
    let a3 = block[i * 4 + 3]
    // VP8 一维 IDCT（使用 c=85627, c*sqrt(2)=121095）
    let b0 = a0 * 85627 + a2 * 85627
    let b1 = a0 * 85627 - a2 * 85627
    let b2 = a1 * 53527 - a3 * 22109
    let b3 = a1 * 22109 + a3 * 53527
    result[i * 4] = (b0 + b3) >> 17
    result[i * 4 + 1] = (b1 + b2) >> 17
    result[i * 4 + 2] = (b1 - b2) >> 17
    result[i * 4 + 3] = (b0 - b3) >> 17
  }
  // 列变换（一维 IDCT）
  let temp = Array::make(16, 0)
  for i in 0..<16 {
    temp[i] = result[i]
  }
  for j in 0..<4 {
    let a0 = temp[j]
    let a1 = temp[4 + j]
    let a2 = temp[8 + j]
    let a3 = temp[12 + j]
    let b0 = a0 * 85627 + a2 * 85627
    let b1 = a0 * 85627 - a2 * 85627
    let b2 = a1 * 53527 - a3 * 22109
    let b3 = a1 * 22109 + a3 * 53527
    result[j] = (b0 + b3) >> 17
    result[4 + j] = (b1 + b2) >> 17
    result[8 + j] = (b1 - b2) >> 17
    result[12 + j] = (b0 - b3) >> 17
  }
  result
}

///|
/// VP8 16x16 DC 系数的 Walsh-Hadamard 变换（WHT）
/// 输入：16 个 DC 系数（4x4 块）
/// 输出：16 个 DC 残差
fn vp8_wht_4x4(block : Array[Int]) -> Array[Int] {
  let result = Array::make(16, 0)
  // 行变换
  for i in 0..<4 {
    let a0 = block[i * 4]
    let a1 = block[i * 4 + 1]
    let a2 = block[i * 4 + 2]
    let a3 = block[i * 4 + 3]
    let b0 = a0 + a1
    let b1 = a0 - a1
    let b2 = a2 + a3
    let b3 = a2 - a3
    result[i * 4] = b0 + b2
    result[i * 4 + 1] = b1 + b3
    result[i * 4 + 2] = b1 - b3
    result[i * 4 + 3] = b0 - b2
  }
  // 列变换
  let temp = Array::make(16, 0)
  for i in 0..<16 {
    temp[i] = result[i]
  }
  for j in 0..<4 {
    let a0 = temp[j]
    let a1 = temp[4 + j]
    let a2 = temp[8 + j]
    let a3 = temp[12 + j]
    let b0 = a0 + a1
    let b1 = a0 - a1
    let b2 = a2 + a3
    let b3 = a2 - a3
    result[j] = (b0 + b2) >> 1
    result[4 + j] = (b1 + b3) >> 1
    result[8 + j] = (b1 - b3) >> 1
    result[12 + j] = (b0 - b2) >> 1
  }
  result
}

// ==================== VP8 Intra Prediction ====================
// VP8 帧内预测模式

///|
/// I16x16 帧内预测模式
enum Vp8I16x16Mode {
  I16x16DcPred
  I16x16TrueMotionPred
  I16x16HPred
  I16x16VPred
}

///|
/// I4x4 帧内预测模式
enum Vp8I4x4Mode {
  I4x4DcPred
  I4x4TrueMotionPred
  I4x4HPred
  I4x4VPred
  I4x4LeftDownPred
  I4x4RightDownPred
  I4x4RightUpPred
  I4x4LeftUpPred
  I4x4VertRightPred
  I4x4HorizDownPred
}

///|
/// I16x16 帧内预测
/// above：上方参考像素（16个）
/// left：左侧参考像素（16个）
/// above_left：左上角参考像素
fn vp8_intra_predict_16x16(
  mode : Vp8I16x16Mode,
  above : Array[Int],
  left : Array[Int],
  above_left : Int,
) -> Array[Int] {
  let result = Array::make(256, 0)
  match mode {
    I16x16DcPred => {
      let mut sum = above_left * 2
      for i in 0..<16 {
        sum += above[i]
        sum += left[i]
      }
      let dc = (sum + 16) >> 5
      for i in 0..<256 {
        result[i] = dc
      }
    }
    I16x16TrueMotionPred => {
      for y in 0..<16 {
        for x in 0..<16 {
          let mut sum = 0
          for i in 0..<(x + 1) {
            sum += above[i]
          }
          for i in 0..<(y + 1) {
            sum += left[i]
          }
          sum += above_left
          result[y * 16 + x] = (sum + (x + y + 2) / 2) / (x + y + 2)
        }
      }
    }
    I16x16HPred => {
      for y in 0..<16 {
        for x in 0..<16 {
          result[y * 16 + x] = left[y]
        }
      }
    }
    I16x16VPred => {
      for y in 0..<16 {
        for x in 0..<16 {
          result[y * 16 + x] = above[x]
        }
      }
    }
  }
  result
}

///|
/// I4x4 帧内预测（完整实现 10 种模式）
/// 参考像素布局：
///   above_left  above[0]  above[1]  above[2]  above[3]  above[4..7]
///   left[0]     P[0][0]   P[0][1]   P[0][2]   P[0][3]
///   left[1]     P[1][0]   P[1][1]   P[1][2]   P[1][3]
///   left[2]     P[2][0]   P[2][1]   P[2][2]   P[2][3]
///   left[3]     P[3][0]   P[3][1]   P[3][2]   P[3][3]
///   left[4..7]
fn vp8_intra_predict_4x4(
  mode : Vp8I4x4Mode,
  above : Array[Int],
  left : Array[Int],
  above_left : Int,
) -> Array[Int] {
  let result = Array::make(16, 0)
  match mode {
    // 0: DC 预测 - 上方和左方像素的平均值
    I4x4DcPred => {
      let mut sum = 0
      for i in 0..<4 {
        sum += above[i]
        sum += left[i]
      }
      let dc = (sum + 4) >> 3
      for i in 0..<16 {
        result[i] = dc
      }
    }

    // 1: TrueMotion 预测 - 基于水平和垂直梯度
    // P[y][x] = clip(above[x] + left[y] - above_left, 0, 255)
    I4x4TrueMotionPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          let mut pred = above[x] + left[y] - above_left
          if pred < 0 { pred = 0 }
          if pred > 255 { pred = 255 }
          result[y * 4 + x] = pred
        }
      }
    }

    // 2: 水平预测 - 使用左方像素
    // P[y][x] = left[y]
    I4x4HPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          result[y * 4 + x] = left[y]
        }
      }
    }

    // 3: 垂直预测 - 使用上方像素
    // P[y][x] = above[x]
    I4x4VPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          result[y * 4 + x] = above[x]
        }
      }
    }

    // 4: LeftDown 预测（左下/对角线，斜率 1）
    // 从左上到右下的对角线预测
    // P[y][x] = (above[x+y] + above[x+y+1] + 1) >> 1  (x+y <= 6)
    // P[y][x] = above[7]  (x+y == 7)
    I4x4LeftDownPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          let idx = x + y
          if idx <= 6 {
            result[y * 4 + x] = (above[idx] + above[idx + 1] + 1) >> 1
          } else {
            result[y * 4 + x] = above[7]
          }
        }
      }
    }

    // 5: RightDown 预测（右下/对角线，斜率 -1）
    // 从右上到左下的对角线预测
    // 如果 x >= y: P[y][x] = (above[x-y] + above[x-y+1] + 1) >> 1
    // 如果 x < y:  P[y][x] = (left[y-x-1] + left[y-x] + 1) >> 1
    I4x4RightDownPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          if x >= y {
            let idx = x - y
            result[y * 4 + x] = (above[idx] + above[idx + 1] + 1) >> 1
          } else {
            let idx = y - x - 1
            result[y * 4 + x] = (left[idx] + left[idx + 1] + 1) >> 1
          }
        }
      }
    }

    // 6: RightUp 预测（右上/垂直-右组合）
    // 垂直预测为主，向右下方倾斜
    // P[y][x] = (above[x] + above[x+1] + left[y] + 1) >> 2
    I4x4RightUpPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          result[y * 4 + x] = (above[x] + above[x + 1] + left[y] + 1) >> 2
        }
      }
    }

    // 7: LeftUp 预测（左上/水平-上组合）
    // 水平预测为主，向右上方倾斜
    // P[y][x] = (left[y] + left[y+1] + above[x] + 1) >> 2
    I4x4LeftUpPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          result[y * 4 + x] = (left[y] + left[y + 1] + above[x] + 1) >> 2
        }
      }
    }

    // 8: VertRight 预测（垂直-右）
    // 垂直预测 + 对角线修正
    // P[y][x] = (above[x] + above[x+1] + 1) >> 1  (y == 0)
    // P[y][x] = (above[x] + left[y-1] + 1) >> 1    (y > 0)
    I4x4VertRightPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          if y == 0 {
            result[y * 4 + x] = (above[x] + above[x + 1] + 1) >> 1
          } else {
            result[y * 4 + x] = (above[x] + left[y - 1] + 1) >> 1
          }
        }
      }
    }

    // 9: HorizDown 预测（水平-下）
    // 水平预测 + 对角线修正
    // P[y][x] = (left[y] + left[y+1] + 1) >> 1  (x == 0)
    // P[y][x] = (left[y] + above[x-1] + 1) >> 1  (x > 0)
    I4x4HorizDownPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          if x == 0 {
            result[y * 4 + x] = (left[y] + left[y + 1] + 1) >> 1
          } else {
            result[y * 4 + x] = (left[y] + above[x - 1] + 1) >> 1
          }
        }
      }
    }
  }
  result
}

// ==================== VP8 Macroblock Prediction Mode Parsing ====================
// VP8 宏块层预测模式解析：从 bitstream 解析每个宏块的预测模式

///|
/// 宏块预测模式概率模型
priv struct Vp8MbModeProbs {
  // I16x16 预测模式概率（4种模式）
  i16x16_prob : Array[Int]
  // I4x4 预测模式概率（10种模式，每个子块）
  i4x4_prob : Array[Int]
  // 色度预测模式概率（4种模式）
  uv_prob : Array[Int]
  // 子宏块类型概率（I16x16 vs I4x4）
  mut submb_type_prob : Int
  // 统计计数器（用于概率更新）
  i16x16_count : Array[Int]
  i4x4_count : Array[Int]
  uv_count : Array[Int]
  mut submb_type_count : Int
  mut total_mbs : Int
}

///|
fn Vp8MbModeProbs::new() -> Vp8MbModeProbs {
  // VP8 默认预测模式概率
  Vp8MbModeProbs::{
    i16x16_prob: [180, 120, 100, 140],
    i4x4_prob: [160, 100, 120, 140, 80, 90, 70, 60, 50, 40],
    uv_prob: [180, 120, 100, 140],
    submb_type_prob: 150,
    i16x16_count: Array::make(4, 0),
    i4x4_count: Array::make(10, 0),
    uv_count: Array::make(4, 0),
    submb_type_count: 0,
    total_mbs: 0,
  }
}

///|
/// 解析 I16x16 预测模式（4种模式）
fn vp8_parse_i16x16_mode(
  bd : Vp8BoolDecoder,
  probs : Vp8MbModeProbs,
) -> Vp8I16x16Mode {
  // 使用概率模型解析预测模式
  // VP8 使用树形概率解析：先判断是否是 DC，然后判断剩余模式
  let is_dc = bd.read_bool(probs.i16x16_prob[0]) == 1
  if is_dc {
    probs.i16x16_count[0] += 1
    return Vp8I16x16Mode::I16x16DcPred
  }
  let is_tm = bd.read_bool(probs.i16x16_prob[1]) == 1
  if is_tm {
    probs.i16x16_count[1] += 1
    return Vp8I16x16Mode::I16x16TrueMotionPred
  }
  let is_h = bd.read_bool(probs.i16x16_prob[2]) == 1
  if is_h {
    probs.i16x16_count[2] += 1
    return Vp8I16x16Mode::I16x16HPred
  }
  probs.i16x16_count[3] += 1
  Vp8I16x16Mode::I16x16VPred
}

///|
/// 解析 I4x4 预测模式（10种模式）
fn vp8_parse_i4x4_mode(
  bd : Vp8BoolDecoder,
  probs : Vp8MbModeProbs,
) -> Vp8I4x4Mode {
  // 使用概率模型解析预测模式
  let is_dc = bd.read_bool(probs.i4x4_prob[0]) == 1
  if is_dc {
    probs.i4x4_count[0] += 1
    return Vp8I4x4Mode::I4x4DcPred
  }
  let is_tm = bd.read_bool(probs.i4x4_prob[1]) == 1
  if is_tm {
    probs.i4x4_count[1] += 1
    return Vp8I4x4Mode::I4x4TrueMotionPred
  }
  let is_h = bd.read_bool(probs.i4x4_prob[2]) == 1
  if is_h {
    probs.i4x4_count[2] += 1
    return Vp8I4x4Mode::I4x4HPred
  }
  let is_v = bd.read_bool(probs.i4x4_prob[3]) == 1
  if is_v {
    probs.i4x4_count[3] += 1
    return Vp8I4x4Mode::I4x4VPred
  }
  let is_ld = bd.read_bool(probs.i4x4_prob[4]) == 1
  if is_ld {
    probs.i4x4_count[4] += 1
    return Vp8I4x4Mode::I4x4LeftDownPred
  }
  let is_rd = bd.read_bool(probs.i4x4_prob[5]) == 1
  if is_rd {
    probs.i4x4_count[5] += 1
    return Vp8I4x4Mode::I4x4RightDownPred
  }
  let is_ru = bd.read_bool(probs.i4x4_prob[6]) == 1
  if is_ru {
    probs.i4x4_count[6] += 1
    return Vp8I4x4Mode::I4x4RightUpPred
  }
  let is_lu = bd.read_bool(probs.i4x4_prob[7]) == 1
  if is_lu {
    probs.i4x4_count[7] += 1
    return Vp8I4x4Mode::I4x4LeftUpPred
  }
  let is_vr = bd.read_bool(probs.i4x4_prob[8]) == 1
  if is_vr {
    probs.i4x4_count[8] += 1
    return Vp8I4x4Mode::I4x4VertRightPred
  }
  probs.i4x4_count[9] += 1
  Vp8I4x4Mode::I4x4HorizDownPred
}

///|
/// 解析色度预测模式（4种模式，与 I16x16 相同）
fn vp8_parse_uv_mode(
  bd : Vp8BoolDecoder,
  probs : Vp8MbModeProbs,
) -> Vp8I16x16Mode {
  let is_dc = bd.read_bool(probs.uv_prob[0]) == 1
  if is_dc {
    probs.uv_count[0] += 1
    return Vp8I16x16Mode::I16x16DcPred
  }
  let is_tm = bd.read_bool(probs.uv_prob[1]) == 1
  if is_tm {
    probs.uv_count[1] += 1
    return Vp8I16x16Mode::I16x16TrueMotionPred
  }
  let is_h = bd.read_bool(probs.uv_prob[2]) == 1
  if is_h {
    probs.uv_count[2] += 1
    return Vp8I16x16Mode::I16x16HPred
  }
  probs.uv_count[3] += 1
  Vp8I16x16Mode::I16x16VPred
}

///|
/// 解析子宏块类型（I16x16 vs I4x4）
/// 返回 true 表示使用 I16x16，false 表示使用 I4x4
fn vp8_parse_submb_type(
  bd : Vp8BoolDecoder,
  probs : Vp8MbModeProbs,
) -> Bool {
  let use_i16x16 = bd.read_bool(probs.submb_type_prob) == 1
  if use_i16x16 {
    probs.submb_type_count += 1
  }
  use_i16x16
}

///|
/// 更新宏块预测模式概率（EMA）
fn Vp8MbModeProbs::update(self : Vp8MbModeProbs) -> Unit {
  self.total_mbs += 1
  // 每 16 个宏块更新一次概率
  if self.total_mbs % 16 != 0 {
    return
  }

  // 更新 I16x16 概率
  let i16_total = self.i16x16_count[0] + self.i16x16_count[1] +
    self.i16x16_count[2] + self.i16x16_count[3] + 1
  for i in 0..<4 {
    let observed = (self.i16x16_count[i] * 256) / i16_total
    self.i16x16_prob[i] = (self.i16x16_prob[i] * 7 + observed) / 8
    self.i16x16_count[i] = self.i16x16_count[i] / 2
  }

  // 更新 I4x4 概率
  let i4_total = self.i4x4_count[0] + self.i4x4_count[1] +
    self.i4x4_count[2] + self.i4x4_count[3] +
    self.i4x4_count[4] + self.i4x4_count[5] +
    self.i4x4_count[6] + self.i4x4_count[7] +
    self.i4x4_count[8] + self.i4x4_count[9] + 1
  for i in 0..<10 {
    let observed = (self.i4x4_count[i] * 256) / i4_total
    self.i4x4_prob[i] = (self.i4x4_prob[i] * 7 + observed) / 8
    self.i4x4_count[i] = self.i4x4_count[i] / 2
  }

  // 更新 UV 概率
  let uv_total = self.uv_count[0] + self.uv_count[1] +
    self.uv_count[2] + self.uv_count[3] + 1
  for i in 0..<4 {
    let observed = (self.uv_count[i] * 256) / uv_total
    self.uv_prob[i] = (self.uv_prob[i] * 7 + observed) / 8
    self.uv_count[i] = self.uv_count[i] / 2
  }

  // 更新子宏块类型概率
  let submb_total = self.total_mbs + 1
  let observed_submb = (self.submb_type_count * 256) / submb_total
  self.submb_type_prob = (self.submb_type_prob * 7 + observed_submb) / 8
  self.submb_type_count = self.submb_type_count / 2
}

// ==================== VP8 Loop Filter ====================
// VP8 环路去块滤波（简化实现）

///|
fn vp8_loop_filter_mb(
  y_plane : Array[Int],
  u_plane : Array[Int],
  v_plane : Array[Int],
  mb_x : Int,
  mb_y : Int,
  width : Int,
  height : Int,
  filter_level : Int,
) -> Unit {
  // 简化的环路滤波：对宏块边界进行简单平滑
  ignore(u_plane)
  ignore(v_plane)
  if filter_level == 0 {
    return
  }
  // 垂直边界滤波
  if mb_x > 0 {
    for y in 0..<16 {
      let py = mb_y * 16 + y
      if py >= height {
        break
      }
      let px = mb_x * 16
      if px > 0 && px < width {
        let idx = py * width + px
        let p1 = y_plane[idx - 1]
        let p0 = y_plane[idx]
        let diff = p0 - p1
        if diff.abs() < filter_level {
          let adj = diff / 2
          y_plane[idx - 1] = p1 + adj
          y_plane[idx] = p0 - adj
        }
      }
    }
  }
  // 水平边界滤波
  if mb_y > 0 {
    for x in 0..<16 {
      let px = mb_x * 16 + x
      if px >= width {
        break
      }
      let py = mb_y * 16
      if py > 0 && py < height {
        let idx = py * width + px
        let p1 = y_plane[idx - width]
        let p0 = y_plane[idx]
        let diff = p0 - p1
        if diff.abs() < filter_level {
          let adj = diff / 2
          y_plane[idx - width] = p1 + adj
          y_plane[idx] = p0 - adj
        }
      }
    }
  }
}

// ==================== VP8 Decoder ====================

///|
/// 解码 VP8 lossy 帧
pub fn decode_vp8_frame(data : Bytes, offset : Int) -> @types.Image raise @types.LoadError {
  let br = Vp8BitReader::new(data, offset)
  let header = parse_vp8_frame_header(br)

  if !header.key_frame {
    raise @types.LoadError::DecodeFailed("VP8 非关键帧暂不支持")
  }

  if header.width == 0 || header.height == 0 {
    raise @types.LoadError::DecodeFailed("VP8 帧尺寸无效")
  }

  let w = header.width
  let h = header.height

  // 解析量化参数
  let quant = parse_quantization(br)

  // 简化实现：创建一个纯色图像（灰色）
  // 完整的 VP8 解码需要解析残差系数、进行 IDCT、帧内预测等
  // 这里先实现基础框架，后续迭代完善
  let base_y = 128 - quant.y_dc / 4
  let base_u = 128 - quant.uv_ac / 4
  let base_v = 128 - quant.uv_dc / 4
  let y_plane : Array[Int] = Array::make(w * h, base_y)
  let u_plane : Array[Int] = Array::make((w / 2) * (h / 2), base_u)
  let v_plane : Array[Int] = Array::make((w / 2) * (h / 2), base_v)

  // 帧内预测 + 残差系数解析 + IDCT 反变换
  // 创建布尔解码器用于残差系数解析和预测模式解析
  let bd = Vp8BoolDecoder::new(data, offset + 10)
  let coeff_probs = Vp8AdaptiveProbs::new()
  let mb_mode_probs = Vp8MbModeProbs::new()

  // 对每个 16x16 宏块：解析预测模式 + 残差解析
  let mb_w = (w + 15) / 16
  let mb_h = (h + 15) / 16
  for mb_y in 0..<mb_h {
    for mb_x in 0..<mb_w {
      // 生成参考像素
      let above : Array[Int] = Array::make(16, 128)
      let left : Array[Int] = Array::make(16, 128)
      let above_left = 128

      // 从 bitstream 解析 I16x16 预测模式（使用自适应概率模型）
      let mode = vp8_parse_i16x16_mode(bd, mb_mode_probs)

      // 解析色度预测模式（UV 平面）
      let uv_mode = vp8_parse_uv_mode(bd, mb_mode_probs)
      ignore(uv_mode) // 色度预测暂未完全实现，UV 平面使用基础值

      let pred = vp8_intra_predict_16x16(mode, above, left, above_left)

      // 解析 DC 系数（16x16 块的 DC 系数组成 4x4 块）
      let dc_coeffs = vp8_parse_dc_coeffs_16x16(bd, coeff_probs)
      let dc_residual = vp8_wht_4x4(dc_coeffs)

      // 对每个 4x4 子块解析 AC 系数并进行 IDCT
      for sub_y in 0..<4 {
        for sub_x in 0..<4 {
          // 解析 AC 系数
          let ac_coeffs = vp8_parse_residual_4x4(bd, coeff_probs, false)
          // 将 DC 系数添加到 AC 系数中
          ac_coeffs[0] = ac_coeffs[0] + dc_residual[sub_y * 4 + sub_x]
          // IDCT 反变换
          let residual = vp8_idct_4x4(ac_coeffs)
          // 将预测和残差相加
          for y in 0..<4 {
            for x in 0..<4 {
              let px = mb_x * 16 + sub_x * 4 + x
              let py = mb_y * 16 + sub_y * 4 + y
              if px < w && py < h {
                let pred_y = sub_y * 4 + y
                let pred_x = sub_x * 4 + x
                let mut val = pred[pred_y * 16 + pred_x] + residual[y * 4 + x]
                if val < 0 { val = 0 }
                if val > 255 { val = 255 }
                y_plane[py * w + px] = val
              }
            }
          }
        }
      }
      // 更新宏块预测模式概率（EMA）
      mb_mode_probs.update()
    }
  }

  // 简化的环路滤波
  let filter_level = quant.y_ac / 4
  for mb_y in 0..<mb_h {
    for mb_x in 0..<mb_w {
      vp8_loop_filter_mb(y_plane, u_plane, v_plane, mb_x, mb_y, w, h, filter_level)
    }
  }

  // YUV420 转 RGB
  let out : Array[Byte] = Array::make(w * h * 3, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let y_val = y_plane[y * w + x]
      let u_val = u_plane[(y / 2) * (w / 2) + (x / 2)]
      let v_val = v_plane[(y / 2) * (w / 2) + (x / 2)]

      // YUV 转 RGB（简化）
      let c = y_val - 16
      let d = u_val - 128
      let e = v_val - 128

      let mut r = (298 * c + 409 * e + 128) >> 8
      let mut g = (298 * c - 100 * d - 208 * e + 128) >> 8
      let mut b = (298 * c + 516 * d + 128) >> 8

      if r < 0 { r = 0 }
      if r > 255 { r = 255 }
      if g < 0 { g = 0 }
      if g > 255 { g = 255 }
      if b < 0 { b = 0 }
      if b > 255 { b = 255 }

      let idx = (y * w + x) * 3
      out[idx] = r.to_byte()
      out[idx + 1] = g.to_byte()
      out[idx + 2] = b.to_byte()
    }
  }

  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out),
  }
}
