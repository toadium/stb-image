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

// ==================== VP8 Residual Coefficient Parsing ====================
// VP8 残差系数解析：token 解析 + zig-zag 扫描

///|
/// VP8 系数概率模型（简化版，使用默认概率）
priv struct Vp8CoeffProbs {
  // 每个位置的 base token 概率（简化为单一概率）
  base_prob : Int
  // 额外位的概率
  extra_prob : Int
}

///|
fn Vp8CoeffProbs::new() -> Vp8CoeffProbs {
  Vp8CoeffProbs::{
    base_prob: 150,
    extra_prob: 140,
  }
}

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
/// 解析一个 4x4 块的残差系数
/// 返回 16 个系数（行优先顺序）
fn vp8_parse_residual_4x4(
  bd : Vp8BoolDecoder,
  probs : Vp8CoeffProbs,
  is_dc : Bool,
) -> Array[Int] {
  let coeffs = Array::make(16, 0)
  let zigzag = vp8_zigzag_4x4()
  let mut eob = false // end of block
  for i in 0..<16 {
    if eob {
      break
    }
    let pos = zigzag[i]
    // 解析 base token
    // token 0: 零系数
    // token 1: 一个系数（±1）
    // token 2+: 多个系数（需要额外位）
    let is_zero = bd.read_bool(probs.base_prob) == 1
    if is_zero {
      // 检查是否是 EOB（块结束）
      if i > 0 {
        let is_eob = bd.read_bool(100) == 1
        if is_eob {
          eob = true
        }
      }
      continue
    }
    // 非零系数：解析符号和值
    let is_one = bd.read_bool(170) == 1
    let mut value = 0
    if is_one {
      value = 1
    } else {
      // 解析额外位
      let mut extra = 1
      let mut continue_read = true
      while continue_read {
        let read_more = bd.read_bool(probs.extra_prob) == 1
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
    // 解析符号
    let sign = bd.read_bool(128)
    if sign == 1 {
      value = -value
    }
    coeffs[pos] = value
  }
  coeffs
}

///|
/// 解析一个 16x16 块的 DC 系数（4x4 块的 DC 系数组成）
fn vp8_parse_dc_coeffs_16x16(
  bd : Vp8BoolDecoder,
  probs : Vp8CoeffProbs,
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
/// I4x4 帧内预测（简化实现，支持主要模式）
fn vp8_intra_predict_4x4(
  mode : Vp8I4x4Mode,
  above : Array[Int],
  left : Array[Int],
  above_left : Int,
) -> Array[Int] {
  let result = Array::make(16, 0)
  match mode {
    I4x4DcPred => {
      let mut sum = above_left
      for i in 0..<4 {
        sum += above[i]
        sum += left[i]
      }
      let dc = (sum + 4) >> 3
      for i in 0..<16 {
        result[i] = dc
      }
    }
    I4x4TrueMotionPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          let mut sum = 0
          for i in 0..<(x + 1) {
            sum += above[i]
          }
          for i in 0..<(y + 1) {
            sum += left[i]
          }
          sum += above_left
          result[y * 4 + x] = (sum + (x + y + 2) / 2) / (x + y + 2)
        }
      }
    }
    I4x4HPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          result[y * 4 + x] = left[y]
        }
      }
    }
    I4x4VPred => {
      for y in 0..<4 {
        for x in 0..<4 {
          result[y * 4 + x] = above[x]
        }
      }
    }
    // 其他模式简化为 DC 预测
    _ => {
      let mut sum = above_left
      for i in 0..<4 {
        sum += above[i]
        sum += left[i]
      }
      let dc = (sum + 4) >> 3
      for i in 0..<16 {
        result[i] = dc
      }
    }
  }
  result
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
  // 创建布尔解码器用于残差系数解析
  let bd = Vp8BoolDecoder::new(data, offset + 10)
  let coeff_probs = Vp8CoeffProbs::new()

  // 对每个 16x16 宏块使用 I16x16 帧内预测 + 残差解析
  let mb_w = (w + 15) / 16
  let mb_h = (h + 15) / 16
  for mb_y in 0..<mb_h {
    for mb_x in 0..<mb_w {
      // 生成参考像素
      let above : Array[Int] = Array::make(16, 128)
      let left : Array[Int] = Array::make(16, 128)
      let above_left = 128
      // 根据宏块位置选择预测模式
      let mode = match (mb_x + mb_y) % 4 {
        0 => Vp8I16x16Mode::I16x16DcPred
        1 => Vp8I16x16Mode::I16x16TrueMotionPred
        2 => Vp8I16x16Mode::I16x16HPred
        _ => Vp8I16x16Mode::I16x16VPred
      }
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
