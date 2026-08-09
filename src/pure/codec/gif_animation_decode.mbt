// 纯 MoonBit GIF 多帧动画解码（全目标可用：native/wasm/js）
// 支持 GIF89a 多帧动画：Graphics Control Extension + 多 Image Descriptor
// 仅依赖 @types，不依赖 @core/FFI

///|
/// 解码 GIF 动画为 GifAnimation（纯 MoonBit，全目标可用）。
/// 支持多帧动画、延迟时间、基本 disposal 方法。
/// 不支持 interlace。
pub fn decode_gif_animation_pure(
  data : Bytes,
) -> @types.GifAnimation raise @types.LoadError {
  let len = data.length()
  if len < 13 {
    raise @types.LoadError::DecodeFailed(
      "GIF 数据过短：无法读取完整 header",
    )
  }
  if data[0].to_int() != 0x47 ||
    data[1].to_int() != 0x49 ||
    data[2].to_int() != 0x46 ||
    data[3].to_int() != 0x38 ||
    (data[4].to_int() != 0x39 && data[4].to_int() != 0x37) ||
    data[5].to_int() != 0x61 {
    raise @types.LoadError::DecodeFailed(
      "GIF signature 错误，非 \"GIF87a\"/\"GIF89a\"",
    )
  }
  let screen_width = read_u16_le_safe(data, 6, len)
  let screen_height = read_u16_le_safe(data, 8, len)
  let packed = data[10].to_int()
  let has_gct = (packed & 0x80) != 0
  let gct_size = 1 << ((packed & 0x07) + 1)
  let bg_idx = data[11].to_int()
  let mut pos = 13
  let gct : Array[(Int, Int, Int)] = []
  if has_gct {
    if pos + gct_size * 3 > len {
      raise @types.LoadError::DecodeFailed(
        "GIF 数据过短：无法读取 Global Color Table",
      )
    }
    for _ in 0..<gct_size {
      let r = data[pos].to_int()
      let g = data[pos + 1].to_int()
      let b = data[pos + 2].to_int()
      gct.push((r, g, b))
      pos += 3
    }
  }
  // 背景色
  let (bg_r, bg_g, bg_b) = if bg_idx < gct.length() {
    gct[bg_idx]
  } else {
    (0, 0, 0)
  }
  // 帧列表
  let frames : Array[@types.Image] = []
  let delays : Array[Int] = []
  // canvas 像素（用于累积帧）
  let canvas : Array[Byte] = Array::make(
    screen_width * screen_height * 3,
    bg_r.to_byte(),
  )
  for i in 0..<(screen_width * screen_height) {
    canvas[i * 3] = bg_r.to_byte()
    canvas[i * 3 + 1] = bg_g.to_byte()
    canvas[i * 3 + 2] = bg_b.to_byte()
  }
  // 保存上一帧 canvas（用于 disposal=3 restore to previous）
  let prev_canvas : Array[Byte] = Array::make(
    screen_width * screen_height * 3,
    b'\x00',
  )
  // 当前 GCE 状态
  let mut gce_delay = 0
  let mut gce_transparent = -1
  let mut gce_disposal = 0
  while pos < len {
    let block_type = data[pos].to_int()
    pos += 1
    if block_type == 0x2C {
      // Image Descriptor
      if pos + 9 > len {
        raise @types.LoadError::DecodeFailed(
          "GIF 数据过短：无法读取 Image Descriptor",
        )
      }
      let left = read_u16_le_safe(data, pos, len)
      let top = read_u16_le_safe(data, pos + 2, len)
      let img_width = read_u16_le_safe(data, pos + 4, len)
      let img_height = read_u16_le_safe(data, pos + 6, len)
      let img_packed = data[pos + 8].to_int()
      pos += 9
      let has_lct = (img_packed & 0x80) != 0
      let is_interlaced = (img_packed & 0x40) != 0
      let lct_size_val = 1 << ((img_packed & 0x07) + 1)
      if is_interlaced {
        raise @types.LoadError::DecodeFailed("GIF interlace 不支持")
      }
      let lct : Array[(Int, Int, Int)] = []
      if has_lct {
        if pos + lct_size_val * 3 > len {
          raise @types.LoadError::DecodeFailed(
            "GIF 数据过短：无法读取 Local Color Table",
          )
        }
        for _ in 0..<lct_size_val {
          let r = data[pos].to_int()
          let g = data[pos + 1].to_int()
          let b = data[pos + 2].to_int()
          lct.push((r, g, b))
          pos += 3
        }
      }
      if pos >= len {
        raise @types.LoadError::DecodeFailed(
          "GIF 数据过短：无法读取 LZW min code size",
        )
      }
      let lzw_min_code_size = data[pos].to_int()
      pos += 1
      if lzw_min_code_size < 2 || lzw_min_code_size > 8 {
        raise @types.LoadError::DecodeFailed("GIF LZW minimum code size 无效")
      }
      let lzw_data : Array[Byte] = []
      while pos < len {
        let sub_len = data[pos].to_int()
        pos += 1
        if sub_len == 0 {
          break
        }
        if pos + sub_len > len {
          raise @types.LoadError::DecodeFailed("GIF 子块长度越界")
        }
        for i in 0..<sub_len {
          lzw_data.push(data[pos + i])
        }
        pos += sub_len
      }
      // LZW 解码
      let indices = lzw_decode(lzw_data, lzw_min_code_size)
      let color_table = if lct.length() > 0 { lct } else { gct }
      if color_table.length() == 0 {
        raise @types.LoadError::DecodeFailed("GIF 无颜色表可用")
      }
      // 保存当前 canvas（用于 disposal=3）
      for i in 0..<(screen_width * screen_height * 3) {
        prev_canvas[i] = canvas[i]
      }
      // 将帧像素写入 canvas
      for y in 0..<img_height {
        for x in 0..<img_width {
          let idx = indices[y * img_width + x]
          let cx = left + x
          let cy = top + y
          if cx >= screen_width || cy >= screen_height {
            continue
          }
          // 跳过透明像素
          if gce_transparent >= 0 && idx == gce_transparent {
            continue
          }
          if idx >= color_table.length() {
            continue
          }
          let (r, g, b) = color_table[idx]
          let canvas_off = (cy * screen_width + cx) * 3
          canvas[canvas_off] = r.to_byte()
          canvas[canvas_off + 1] = g.to_byte()
          canvas[canvas_off + 2] = b.to_byte()
        }
      }
      // 复制 canvas 为当前帧
      let frame_data : Array[Byte] = Array::make(
        screen_width * screen_height * 3,
        b'\x00',
      )
      for i in 0..<(screen_width * screen_height * 3) {
        frame_data[i] = canvas[i]
      }
      frames.push(@types.Image::{
        width: screen_width,
        height: screen_height,
        channels: 3,
        data: Bytes::from_array(frame_data),
      })
      delays.push(gce_delay)
      // 处理 disposal
      match gce_disposal {
        2 =>
          // restore to background：清除帧区域为背景色
          for y in 0..<img_height {
            for x in 0..<img_width {
              let cx = left + x
              let cy = top + y
              if cx >= screen_width || cy >= screen_height {
                continue
              }
              let canvas_off = (cy * screen_width + cx) * 3
              canvas[canvas_off] = bg_r.to_byte()
              canvas[canvas_off + 1] = bg_g.to_byte()
              canvas[canvas_off + 2] = bg_b.to_byte()
            }
          }
        3 =>
          // restore to previous
          for i in 0..<(screen_width * screen_height * 3) {
            canvas[i] = prev_canvas[i]
          }
        _ => () // 0=none, 1=leave: 不做处理
      }
      // 重置 GCE
      gce_delay = 0
      gce_transparent = -1
      gce_disposal = 0
    } else if block_type == 0x21 {
      // Extension
      if pos >= len {
        raise @types.LoadError::DecodeFailed(
          "GIF 数据过短：无法读取 Extension label",
        )
      }
      let label = data[pos].to_int()
      pos += 1
      if label == 0xF9 && pos + 6 <= len {
        // Graphics Control Extension
        let _block_size = data[pos].to_int()
        let gce_packed = data[pos + 1].to_int()
        gce_delay = read_u16_le_safe(data, pos + 2, len) * 10
        gce_transparent = if (gce_packed & 0x01) != 0 {
          data[pos + 4].to_int()
        } else {
          -1
        }
        gce_disposal = (gce_packed >> 2) & 0x07
        pos += 6
      } else {
        // 跳过其他 extension
        while pos < len {
          let sub_len = data[pos].to_int()
          pos += 1
          if sub_len == 0 {
            break
          }
          if pos + sub_len > len {
            raise @types.LoadError::DecodeFailed("GIF 子块长度越界")
          }
          pos += sub_len
        }
      }
    } else if block_type == 0x3B {
      // Trailer
      break
    } else {
      raise @types.LoadError::DecodeFailed("GIF 未知 block type")
    }
  }
  if frames.length() == 0 {
    raise @types.LoadError::DecodeFailed("GIF 无 Image Separator")
  }
  @types.GifAnimation::{ frames, delays }
}
