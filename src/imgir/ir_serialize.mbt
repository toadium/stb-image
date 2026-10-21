// ImgIR 序列化：管道 ↔ Bytes 双向转换。
// IR serialization: pipeline ↔ Bytes bidirectional conversion.
//
// 二进制格式：
//   管道 = num_ops(4B LE) + op_1 + op_2 + ...
//   操作 = tag(1B) + params(变长)
//   Int  = 4B little-endian
//   Float = 4B (scaled by 1e6, stored as Int LE)

///|
fn ir_write_int(buf : Array[Byte], v : Int32) -> Unit {
  buf.push((v & 0xFF).to_byte())
  buf.push(((v >> 8) & 0xFF).to_byte())
  buf.push(((v >> 16) & 0xFF).to_byte())
  buf.push(((v >> 24) & 0xFF).to_byte())
}

///|
fn ir_write_float(buf : Array[Byte], v : Float) -> Unit {
  let scaled = (v * 1000000.0F).to_int()
  ir_write_int(buf, scaled)
}

///|
fn ir_read_int(data : Bytes, offset : Int32) -> Int32 {
  data[offset].to_int() |
  (data[offset + 1].to_int() << 8) |
  (data[offset + 2].to_int() << 16) |
  (data[offset + 3].to_int() << 24)
}

///|
fn ir_read_float(data : Bytes, offset : Int32) -> Float {
  let scaled = ir_read_int(data, offset)
  Float::from_int(scaled) / 1000000.0F
}

///|
/// 序列化单个操作到缓冲区。
/// Serialize a single operation to buffer.
pub fn ir_serialize_op(op : IROp, buf : Array[Byte]) -> Unit {
  match op {
    Resize(w, h) => {
      buf.push(b'\x01')
      ir_write_int(buf, w)
      ir_write_int(buf, h)
    }
    Rotate90 => buf.push(b'\x02')
    FlipH => buf.push(b'\x03')
    FlipV => buf.push(b'\x04')
    Crop(x, y, w, h) => {
      buf.push(b'\x05')
      ir_write_int(buf, x)
      ir_write_int(buf, y)
      ir_write_int(buf, w)
      ir_write_int(buf, h)
    }
    ToGray => buf.push(b'\x06')
    Brightness(delta) => {
      buf.push(b'\x07')
      ir_write_int(buf, delta)
    }
    GaussianBlur(radius, sigma) => {
      buf.push(b'\x08')
      ir_write_int(buf, radius)
      ir_write_float(buf, sigma)
    }
    BoxBlur(radius) => {
      buf.push(b'\x09')
      ir_write_int(buf, radius)
    }
    Sharpen(amount) => {
      buf.push(b'\x0A')
      ir_write_float(buf, amount)
    }
    ToScalarField => buf.push(b'\x0B')
    FieldGradient => buf.push(b'\x0C')
    FieldLaplacian => buf.push(b'\x0D')
    FieldIntegrate => buf.push(b'\x0E')
    FieldClamp(lo, hi) => {
      buf.push(b'\x0F')
      ir_write_float(buf, lo)
      ir_write_float(buf, hi)
    }
    FieldMask(threshold) => {
      buf.push(b'\x10')
      ir_write_float(buf, threshold)
    }
    ScalarFieldToImage => buf.push(b'\x11')
    STSnapshot(time) => {
      buf.push(b'\x12')
      ir_write_float(buf, time)
    }
    STInterpolate(time) => {
      buf.push(b'\x13')
      ir_write_float(buf, time)
    }
  }
}

///|
/// 反序列化单个操作。
/// Deserialize a single operation.
pub fn ir_deserialize_op(
  data : Bytes,
  offset : Int32,
) -> (IROp, Int32) raise @types.LoadError {
  let tag = data[offset].to_int()
  let pos = offset + 1
  match tag {
    0x01 => {
      let w = ir_read_int(data, pos)
      let h = ir_read_int(data, pos + 4)
      (Resize(w, h), pos + 8)
    }
    0x02 => (Rotate90, pos)
    0x03 => (FlipH, pos)
    0x04 => (FlipV, pos)
    0x05 => {
      let x = ir_read_int(data, pos)
      let y = ir_read_int(data, pos + 4)
      let w = ir_read_int(data, pos + 8)
      let h = ir_read_int(data, pos + 12)
      (Crop(x, y, w, h), pos + 16)
    }
    0x06 => (ToGray, pos)
    0x07 => {
      let delta = ir_read_int(data, pos)
      (Brightness(delta), pos + 4)
    }
    0x08 => {
      let radius = ir_read_int(data, pos)
      let sigma = ir_read_float(data, pos + 4)
      (GaussianBlur(radius, sigma), pos + 8)
    }
    0x09 => {
      let radius = ir_read_int(data, pos)
      (BoxBlur(radius), pos + 4)
    }
    0x0A => {
      let amount = ir_read_float(data, pos)
      (Sharpen(amount), pos + 4)
    }
    0x0B => (ToScalarField, pos)
    0x0C => (FieldGradient, pos)
    0x0D => (FieldLaplacian, pos)
    0x0E => (FieldIntegrate, pos)
    0x0F => {
      let lo = ir_read_float(data, pos)
      let hi = ir_read_float(data, pos + 4)
      (FieldClamp(lo, hi), pos + 8)
    }
    0x10 => {
      let threshold = ir_read_float(data, pos)
      (FieldMask(threshold), pos + 4)
    }
    0x11 => (ScalarFieldToImage, pos)
    0x12 => {
      let time = ir_read_float(data, pos)
      (STSnapshot(time), pos + 4)
    }
    0x13 => {
      let time = ir_read_float(data, pos)
      (STInterpolate(time), pos + 4)
    }
    _ =>
      raise @types.LoadError::DecodeFailed(
        "ir_deserialize_op: 未知操作标签 " + tag.to_string(),
      )
  }
}

///|
/// 序列化管道为 Bytes。
/// Serialize pipeline to Bytes.
pub fn ir_serialize(pipeline : IRPipeline) -> Bytes {
  let buf : Array[Byte] = []
  ir_write_int(buf, pipeline.ops.length())
  for i in 0..<pipeline.ops.length() {
    ir_serialize_op(pipeline.ops[i], buf)
  }
  Bytes::from_array(buf)
}

///|
/// 从 Bytes 反序列化管道。
/// Deserialize pipeline from Bytes.
pub fn ir_deserialize(data : Bytes) -> IRPipeline raise @types.LoadError {
  if data.length() < 4 {
    raise @types.LoadError::DecodeFailed(
      "ir_deserialize: 数据过短，至少需要 4 字节",
    )
  }
  let num_ops = ir_read_int(data, 0)
  if num_ops < 0 {
    raise @types.LoadError::DecodeFailed(
      "ir_deserialize: 操作数不能为负",
    )
  }
  let ops : Array[IROp] = []
  let mut offset = 4
  for _ in 0..<num_ops {
    let result = ir_deserialize_op(data, offset)
    ops.push(result.0)
    offset = result.1
  }
  { ops, }
}
