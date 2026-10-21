// v250.0.0 PNG 元数据写入 + eXIf + IPTC 测试

///|
fn v250_build_minimal_png() -> Bytes {
  // Minimal PNG: signature + IHDR + IDAT(1 pixel) + IEND
  let out : Array[Byte] = []
  // PNG signature
  out.push(0x89)
  out.push(0x50)
  out.push(0x4E)
  out.push(0x47)
  out.push(0x0D)
  out.push(0x0A)
  out.push(0x1A)
  out.push(0x0A)
  // IHDR chunk (13 bytes data)
  let ihdr : Array[Byte] = [
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x02, 0x00, 0x00, 0x00,
  ]
  out.push(0x00)
  out.push(0x00)
  out.push(0x00)
  out.push(0x0D)
  out.push(0x49)
  out.push(0x48)
  out.push(0x44)
  out.push(0x52)
  for b in ihdr {
    out.push(b)
  }
  out.push(0x1C)
  out.push(0x57)
  out.push(0x73)
  out.push(0x81)
  // IDAT chunk (compressed 1 pixel: filter=0, R=0, G=0, B=0)
  let idat_data : Array[Byte] = [
    0x78, 0x01, 0x63, 0x60, 0x60, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01,
  ]
  out.push(0x00)
  out.push(0x00)
  out.push(0x00)
  out.push(0x0B)
  out.push(0x49)
  out.push(0x44)
  out.push(0x41)
  out.push(0x54)
  for b in idat_data {
    out.push(b)
  }
  out.push(0xE6)
  out.push(0x6C)
  out.push(0x81)
  out.push(0x12)
  // IEND chunk
  out.push(0x00)
  out.push(0x00)
  out.push(0x00)
  out.push(0x00)
  out.push(0x49)
  out.push(0x45)
  out.push(0x4E)
  out.push(0x44)
  out.push(0xAE)
  out.push(0x42)
  out.push(0x60)
  out.push(0x82)
  Bytes::from_array(out)
}

///|
test "write_png_text_chunks: valid PNG gets tEXt inserted" {
  let png = v250_build_minimal_png()
  let chunks = [
    @meta.PngTextChunk::{ keyword: "Author", text: "TestUser", },
    @meta.PngTextChunk::{ keyword: "Description", text: "Test image", },
  ]
  let result = @meta.write_png_text_chunks(chunks, png)
  // Read back
  let read_back = @meta.read_png_text_chunks(result)
  assert_eq(read_back.length(), 2)
  assert_eq(read_back[0].keyword, "Author")
  assert_eq(read_back[0].text, "TestUser")
  assert_eq(read_back[1].keyword, "Description")
  assert_eq(read_back[1].text, "Test image")
}

///|
test "write_png_text_chunks: non-PNG raises error" {
  let data = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  let chunks = [@meta.PngTextChunk::{ keyword: "A", text: "B", }]
  try {
    let _ = @meta.write_png_text_chunks(chunks, data)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "write_png_text_chunks: empty chunks list returns same PNG" {
  let png = v250_build_minimal_png()
  let result = @meta.write_png_text_chunks([], png)
  // Should be valid PNG with no extra text chunks
  let read_back = @meta.read_png_text_chunks(result)
  assert_eq(read_back.length(), 0)
}

///|
test "read_png_exif: PNG without eXIf returns None" {
  let png = v250_build_minimal_png()
  assert_true(@meta.read_png_exif_from_bytes(png) is None)
}

///|
test "read_png_exif: non-PNG returns None" {
  let data = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  assert_true(@meta.read_png_exif_from_bytes(data) is None)
}

///|
test "write_png_exif: round-trip preserves EXIF data" {
  let png = v250_build_minimal_png()
  // Minimal TIFF LE header: II + 0x2A + offset 8 + 0 entries + next IFD 0
  let exif : Array[Byte] = [
    0x49, 0x49, 0x2A, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  ]
  let exif_bytes = Bytes::from_array(exif)
  let result = @meta.write_png_exif_to_bytes(exif_bytes, png)
  let read_back = @meta.read_png_exif_from_bytes(result)
  match read_back {
    Some(data) => {
      assert_eq(data.length(), 12)
      assert_eq(data[0].to_int(), 0x49)
      assert_eq(data[1].to_int(), 0x49)
    }
    None => assert_true(false)
  }
}

///|
test "write_png_exif: non-PNG raises error" {
  let data = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  let exif = Bytes::from_array([0x49, 0x49, 0x2A, 0x00])
  try {
    let _ = @meta.write_png_exif_to_bytes(exif, data)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "read_iptc: non-JPEG returns None" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_true(@meta.read_iptc_from_bytes(data) is None)
}

///|
test "read_iptc: JPEG without IPTC returns None" {
  let data = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  assert_true(@meta.read_iptc_from_bytes(data) is None)
}

///|
test "create_iptc_segment: contains Photoshop header" {
  let info = @meta.IptcInfo::{
    title: "Test",
    keywords: "",
    creator: "",
    creator_title: "",
    city: "",
    country: "",
    caption: "",
    caption_writer: "",
    date_created: "",
    category: "",
    urgency: 0,
    raw_records: [],
  }
  let segment = @meta.create_iptc_segment(info)
  // Should start with "Photoshop 3.0\0"
  assert_eq(segment[0].to_int(), 0x50) // 'P'
  assert_eq(segment[1].to_int(), 0x68) // 'h'
  assert_eq(segment[2].to_int(), 0x6F) // 'o'
  // "8BIM" at offset 14
  assert_eq(segment[14].to_int(), 0x38) // '8'
  assert_eq(segment[15].to_int(), 0x42) // 'B'
  assert_eq(segment[16].to_int(), 0x49) // 'I'
  assert_eq(segment[17].to_int(), 0x4D) // 'M'
  // Resource type 0x0404
  assert_eq(segment[18].to_int(), 0x04)
  assert_eq(segment[19].to_int(), 0x04)
  let _ = info
}

///|
test "write_iptc_to_bytes: round-trip preserves fields" {
  let jpeg = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  let info = @meta.IptcInfo::{
    title: "My Photo",
    keywords: "sunset,nature",
    creator: "John Doe",
    creator_title: "Photographer",
    city: "New York",
    country: "USA",
    caption: "A beautiful sunset",
    caption_writer: "Editor",
    date_created: "20260101",
    category: "News",
    urgency: 5,
    raw_records: [],
  }
  let result = @meta.write_iptc_to_bytes(info, jpeg)
  let read_back = @meta.read_iptc_from_bytes(result)
  match read_back {
    Some(iptc) => {
      assert_eq(iptc.title, "My Photo")
      assert_eq(iptc.keywords, "sunset,nature")
      assert_eq(iptc.creator, "John Doe")
      assert_eq(iptc.creator_title, "Photographer")
      assert_eq(iptc.city, "New York")
      assert_eq(iptc.country, "USA")
      assert_eq(iptc.caption, "A beautiful sunset")
      assert_eq(iptc.caption_writer, "Editor")
      assert_eq(iptc.date_created, "20260101")
      assert_eq(iptc.category, "News")
      assert_eq(iptc.urgency, 5)
    }
    None => assert_true(false)
  }
}

///|
test "write_iptc_to_bytes: non-JPEG raises error" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  let info = @meta.IptcInfo::{
    title: "",
    keywords: "",
    creator: "",
    creator_title: "",
    city: "",
    country: "",
    caption: "",
    caption_writer: "",
    date_created: "",
    category: "",
    urgency: 0,
    raw_records: [],
  }
  try {
    let _ = @meta.write_iptc_to_bytes(info, data)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "write_iptc_to_bytes: empty info produces valid segment" {
  let jpeg = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  let info = @meta.IptcInfo::{
    title: "",
    keywords: "",
    creator: "",
    creator_title: "",
    city: "",
    country: "",
    caption: "",
    caption_writer: "",
    date_created: "",
    category: "",
    urgency: 0,
    raw_records: [],
  }
  let result = @meta.write_iptc_to_bytes(info, jpeg)
  // Should still be valid JPEG
  assert_eq(result[0].to_int(), 0xFF)
  assert_eq(result[1].to_int(), 0xD8)
  // Should have APP13
  assert_eq(result[2].to_int(), 0xFF)
  assert_eq(result[3].to_int(), 0xED)
}
