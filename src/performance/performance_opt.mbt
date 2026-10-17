///|
/// 性能优化工具模块
///
/// 提供大图分块处理、循环展开、缓存友好数据访问等优化工具。
/// v48.0.0: SIMD 友好算法重写 + 缓存优化 + 大图分块

///|
/// 分块处理参数
pub(all) struct TileConfig {
  tile_width : Int
  tile_height : Int
  overlap : Int
}

///|
/// 默认分块配置（256x256，无重叠）
pub fn default_tile_config() -> TileConfig {
  TileConfig::{ tile_width: 256, tile_height: 256, overlap: 0, }
}

///|
/// 计算分块数量
pub fn num_tiles(width : Int, height : Int, config : TileConfig) -> (Int, Int) {
  let cols = (width + config.tile_width - 1) / config.tile_width
  let rows = (height + config.tile_height - 1) / config.tile_height
  (cols, rows)
}

///|
/// 获取分块在源图像中的区域
pub fn tile_region(
  tile_col : Int,
  tile_row : Int,
  config : TileConfig,
) -> (Int, Int, Int, Int) {
  let x0 = tile_col * config.tile_width
  let y0 = tile_row * config.tile_height
  let x1 = x0 + config.tile_width
  let y1 = y0 + config.tile_height
  (x0, y0, x1, y1)
}

///|
/// 从图像中提取分块
pub fn extract_tile(
  img : @types.Image,
  x0 : Int,
  y0 : Int,
  tile_w : Int,
  tile_h : Int,
) -> @types.Image raise @types.LoadError {
  if x0 < 0 || y0 < 0 || tile_w <= 0 || tile_h <= 0 {
    raise @types.LoadError::DecodeFailed("Invalid tile parameters")
  }
  if x0 + tile_w > img.width || y0 + tile_h > img.height {
    raise @types.LoadError::DecodeFailed("Tile out of image bounds")
  }
  let ch = img.channels
  let tile_data : Array[Byte] = Array::make(tile_w * tile_h * ch, b'\x00')
  for y in 0..<tile_h {
    let src_row = (y0 + y) * img.width * ch + x0 * ch
    let dst_row = y * tile_w * ch
    for x in 0..<(tile_w * ch) {
      tile_data[dst_row + x] = img.data[src_row + x]
    }
  }
  @types.Image::{
    width: tile_w,
    height: tile_h,
    channels: ch,
    data: Bytes::from_array(tile_data),
  }
}

///|
/// 将分块写回图像
pub fn paste_tile(
  img : @types.Image,
  tile : @types.Image,
  x0 : Int,
  y0 : Int,
) -> @types.Image raise @types.LoadError {
  if x0 < 0 || y0 < 0 {
    raise @types.LoadError::DecodeFailed("Invalid paste position")
  }
  if x0 + tile.width > img.width || y0 + tile.height > img.height {
    raise @types.LoadError::DecodeFailed("Tile out of image bounds")
  }
  if tile.channels != img.channels {
    raise @types.LoadError::DecodeFailed("Channel mismatch")
  }
  let ch = img.channels
  let result_data : Array[Byte] = Array::make(
    img.width * img.height * ch,
    b'\x00',
  )
  for i in 0..<img.data.length() {
    result_data[i] = img.data[i]
  }
  for y in 0..<tile.height {
    let dst_row = (y0 + y) * img.width * ch + x0 * ch
    let src_row = y * tile.width * ch
    for x in 0..<(tile.width * ch) {
      result_data[dst_row + x] = tile.data[src_row + x]
    }
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(result_data),
  }
}

///|
/// 分块处理图像
///
/// 将图像分成小块，对每块应用处理函数，然后合并结果。
/// 适用于大图处理，避免一次性加载整个图像到缓存。
pub fn process_tiled(
  img : @types.Image,
  config : TileConfig,
  process_fn : (@types.Image) -> @types.Image,
) -> @types.Image raise @types.LoadError {
  let ch = img.channels
  let result_data : Array[Byte] = Array::make(
    img.width * img.height * ch,
    b'\x00',
  )
  let (cols, rows) = num_tiles(img.width, img.height, config)
  for row in 0..<rows {
    for col in 0..<cols {
      let (x0, y0, x1, y1) = tile_region(col, row, config)
      let tw = if x1 > img.width { img.width - x0 } else { config.tile_width }
      let th = if y1 > img.height {
        img.height - y0
      } else {
        config.tile_height
      }
      let tile = extract_tile(img, x0, y0, tw, th)
      let processed = process_fn(tile)
      let _ = paste_tile(
        @types.Image::{
          width: img.width,
          height: img.height,
          channels: ch,
          data: Bytes::from_array(result_data),
        },
        processed,
        x0,
        y0,
      )
      // 直接写入 result_data
      for y in 0..<processed.height {
        let dst_row = (y0 + y) * img.width * ch + x0 * ch
        let src_row = y * processed.width * ch
        for x in 0..<(processed.width * ch) {
          result_data[dst_row + x] = processed.data[src_row + x]
        }
      }
    }
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(result_data),
  }
}

///|
/// 循环展开的批量复制（4x展开）
///
/// 将源数组的一段复制到目标数组，使用4次循环展开减少分支开销
pub fn bulk_copy_4x(
  src : Bytes,
  src_offset : Int,
  dst : Array[Byte],
  dst_offset : Int,
  len : Int,
) -> Unit {
  let mut i = 0
  let len4 = len / 4 * 4
  while i < len4 {
    dst[dst_offset + i] = src[src_offset + i]
    dst[dst_offset + i + 1] = src[src_offset + i + 1]
    dst[dst_offset + i + 2] = src[src_offset + i + 2]
    dst[dst_offset + i + 3] = src[src_offset + i + 3]
    i += 4
  }
  while i < len {
    dst[dst_offset + i] = src[src_offset + i]
    i += 1
  }
}

///|
/// 循环展开的批量填充（4x展开）
pub fn bulk_fill_4x(
  dst : Array[Byte],
  offset : Int,
  len : Int,
  value : Byte,
) -> Unit {
  let mut i = 0
  let len4 = len / 4 * 4
  while i < len4 {
    dst[offset + i] = value
    dst[offset + i + 1] = value
    dst[offset + i + 2] = value
    dst[offset + i + 3] = value
    i += 4
  }
  while i < len {
    dst[offset + i] = value
    i += 1
  }
}

///|
/// 缓存友好的行优先处理
///
/// 按行处理图像，每行处理完后立即写入结果，提高缓存命中率
pub fn process_row_major(
  img : @types.Image,
  process_row : (Int, Array[Byte]) -> Array[Byte],
) -> @types.Image {
  let ch = img.channels
  let row_len = img.width * ch
  let result : Array[Byte] = Array::make(img.width * img.height * ch, b'\x00')
  for y in 0..<img.height {
    let row_data : Array[Byte] = Array::make(row_len, b'\x00')
    let row_offset = y * row_len
    for x in 0..<row_len {
      row_data[x] = img.data[row_offset + x]
    }
    let processed = process_row(y, row_data)
    for x in 0..<row_len {
      result[row_offset + x] = processed[x]
    }
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(result),
  }
}
