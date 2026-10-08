///|
test "default_tile_config: 256x256 no overlap" {
  let config = default_tile_config()
  assert_eq(config.tile_width, 256)
  assert_eq(config.tile_height, 256)
  assert_eq(config.overlap, 0)
}

///|
test "num_tiles: exact division" {
  let config = default_tile_config()
  let (cols, rows) = num_tiles(512, 512, config)
  assert_eq(cols, 2)
  assert_eq(rows, 2)
}

///|
test "num_tiles: non-exact division" {
  let config = default_tile_config()
  let (cols, rows) = num_tiles(300, 300, config)
  assert_eq(cols, 2)
  assert_eq(rows, 2)
}

///|
test "num_tiles: smaller than tile" {
  let config = default_tile_config()
  let (cols, rows) = num_tiles(100, 100, config)
  assert_eq(cols, 1)
  assert_eq(rows, 1)
}

///|
test "tile_region: first tile" {
  let config = default_tile_config()
  let (x0, y0, x1, y1) = tile_region(0, 0, config)
  assert_eq(x0, 0)
  assert_eq(y0, 0)
  assert_eq(x1, 256)
  assert_eq(y1, 256)
}

///|
test "tile_region: second tile" {
  let config = default_tile_config()
  let (x0, y0, x1, y1) = tile_region(1, 1, config)
  assert_eq(x0, 256)
  assert_eq(y0, 256)
  assert_eq(x1, 512)
  assert_eq(y1, 512)
}

///|
test "extract_tile: basic" {
  let data : Array[Byte] = Array::make(4 * 4 * 3, b'\x00')
  for i in 0..<16 {
    data[i * 3] = (i * 17 % 256).to_byte()
    data[i * 3 + 1] = (i * 31 % 256).to_byte()
    data[i * 3 + 2] = (i * 53 % 256).to_byte()
  }
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let tile = extract_tile(img, 1, 1, 2, 2)
  assert_eq(tile.width, 2)
  assert_eq(tile.height, 2)
  assert_eq(tile.channels, 3)
}

///|
test "extract_tile: out of bounds raises" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(48, b'\x00')),
  }
  try {
    ignore(extract_tile(img, 3, 3, 2, 2))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "paste_tile: basic" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(48, b'\x00')),
  }
  let tile = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, b'\xFF')),
  }
  let result = paste_tile(img, tile, 1, 1)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "bulk_copy_4x: basic" {
  let src = Bytes::from_array([1, 2, 3, 4, 5, 6, 7, 8])
  let dst : Array[Byte] = Array::make(8, b'\x00')
  bulk_copy_4x(src, 0, dst, 0, 8)
  assert_eq(dst[0].to_int(), 1)
  assert_eq(dst[7].to_int(), 8)
}

///|
test "bulk_copy_4x: non-multiple of 4" {
  let src = Bytes::from_array([1, 2, 3, 4, 5, 6, 7])
  let dst : Array[Byte] = Array::make(7, b'\x00')
  bulk_copy_4x(src, 0, dst, 0, 7)
  assert_eq(dst[0].to_int(), 1)
  assert_eq(dst[6].to_int(), 7)
}

///|
test "bulk_fill_4x: basic" {
  let dst : Array[Byte] = Array::make(8, b'\x00')
  bulk_fill_4x(dst, 0, 8, b'\xAA')
  for i in 0..<8 {
    assert_eq(dst[i].to_int(), 0xAA)
  }
}

///|
test "process_row_major: identity" {
  let data : Array[Byte] = Array::make(4 * 2 * 3, b'\x00')
  for i in 0..<8 {
    data[i * 3] = i.to_byte()
  }
  let img = @types.Image::{
    width: 4,
    height: 2,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let result = process_row_major(img, fn(_y, row) { row })
  assert_eq(result.width, 4)
  assert_eq(result.height, 2)
  assert_eq(result.data[0].to_int(), 0)
}

///|
test "process_tiled: identity" {
  let data : Array[Byte] = Array::make(4 * 4 * 3, b'\x00')
  for i in 0..<16 {
    data[i * 3] = (i * 17 % 256).to_byte()
  }
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let config = TileConfig::{ tile_width: 2, tile_height: 2, overlap: 0, }
  let result = process_tiled(img, config, fn(tile) { tile })
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}
