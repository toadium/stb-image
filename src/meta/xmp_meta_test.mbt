// v249.0.0 XMP 元数据测试

///|
fn xmp_build_test_jpeg(xml : String) -> Bytes {
  // SOI + APP1(XMP) + EOI
  let ns = "http://ns.adobe.com/xap/1.0/"
  let out : Array[Byte] = []
  // SOI
  out.push(0xFF)
  out.push(0xD8)
  // APP1 marker
  out.push(0xFF)
  out.push(0xE1)
  // segment length = 2 (length field) + ns + null + xml
  let payload_len = ns.length() + 1 + xml.length()
  let seg_len = payload_len + 2
  out.push((seg_len >> 8).to_byte())
  out.push((seg_len & 0xFF).to_byte())
  // namespace + null
  for c in ns.to_array() {
    out.push(c.to_int().to_byte())
  }
  out.push(b'\x00')
  // xml
  for c in xml.to_array() {
    let code = c.to_int()
    if code < 128 {
      out.push(code.to_byte())
    } else {
      out.push(b'?')
    }
  }
  // EOI
  out.push(0xFF)
  out.push(0xD9)
  Bytes::from_array(out)
}

///|
test "read_xmp: non-JPEG returns None" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_true(@meta.read_xmp_from_bytes(data) is None)
}

///|
test "read_xmp: empty data returns None" {
  let data = Bytes::from_array([])
  assert_true(@meta.read_xmp_from_bytes(data) is None)
}

///|
test "read_xmp: JPEG without XMP returns None" {
  let data = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  assert_true(@meta.read_xmp_from_bytes(data) is None)
}

///|
test "read_xmp: JPEG with empty XMP" {
  let xml = "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?><x:xmpmeta xmlns:x='adobe:ns:meta/'></x:xmpmeta><?xpacket end='w'?>"
  let data = xmp_build_test_jpeg(xml)
  let result = @meta.read_xmp_from_bytes(data)
  match result {
    Some(info) => {
      assert_eq(info.creator, "")
      assert_eq(info.title, "")
      assert_eq(info.rating, 0)
    }
    None => assert_true(false)
  }
}

///|
test "read_xmp: JPEG with title and creator" {
  let xml = "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?><x:xmpmeta xmlns:x='adobe:ns:meta/'>" +
    "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>" +
    "<rdf:Description rdf:about='' xmlns:dc='http://purl.org/dc/elements/1.1/'>" +
    "<dc:title>My Photo</dc:title><dc:creator>John Doe</dc:creator>" +
    "<dc:description>A test image</dc:description>" +
    "</rdf:Description></rdf:RDF></x:xmpmeta><?xpacket end='w'?>"
  let data = xmp_build_test_jpeg(xml)
  let result = @meta.read_xmp_from_bytes(data)
  match result {
    Some(info) => {
      assert_eq(info.title, "My Photo")
      assert_eq(info.creator, "John Doe")
      assert_eq(info.description, "A test image")
    }
    None => assert_true(false)
  }
}

///|
test "read_xmp: JPEG with rating" {
  let xml = "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?><x:xmpmeta xmlns:x='adobe:ns:meta/'>" +
    "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>" +
    "<rdf:Description rdf:about='' xmlns:xmp='http://ns.adobe.com/xap/1.0/'>" +
    "<xmp:Rating>4</xmp:Rating>" +
    "</rdf:Description></rdf:RDF></x:xmpmeta><?xpacket end='w'?>"
  let data = xmp_build_test_jpeg(xml)
  let result = @meta.read_xmp_from_bytes(data)
  match result {
    Some(info) => assert_eq(info.rating, 4)
    None => assert_true(false)
  }
}

///|
test "read_xmp: JPEG with software" {
  let xml = "<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?><x:xmpmeta xmlns:x='adobe:ns:meta/'>" +
    "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>" +
    "<rdf:Description rdf:about='' xmlns:xmp='http://ns.adobe.com/xap/1.0/'>" +
    "<xmp:CreatorTool>Lightroom 5.0</xmp:CreatorTool>" +
    "</rdf:Description></rdf:RDF></x:xmpmeta><?xpacket end='w'?>"
  let data = xmp_build_test_jpeg(xml)
  let result = @meta.read_xmp_from_bytes(data)
  match result {
    Some(info) => assert_eq(info.software, "Lightroom 5.0")
    None => assert_true(false)
  }
}

///|
test "create_xmp_segment: contains namespace prefix" {
  let info = @meta.XmpInfo::{
    creator: "",
    title: "Test Title",
    description: "",
    subject: "",
    keywords: "",
    rights: "",
    create_date: "",
    modify_date: "",
    software: "",
    rating: 0,
    raw_xml: "",
  }
  let segment = @meta.create_xmp_segment(info)
  // Should start with "http://ns.adobe.com/xap/1.0/\0"
  assert_eq(segment[0].to_int(), 0x68) // 'h'
  assert_eq(segment[1].to_int(), 0x74) // 't'
  assert_eq(segment[2].to_int(), 0x74) // 't'
  assert_eq(segment[3].to_int(), 0x70) // 'p'
  let _ = info
  let _ = segment
}

///|
test "create_xmp_segment: contains title in XML" {
  let info = @meta.XmpInfo::{
    creator: "TestAuthor",
    title: "TestTitle",
    description: "TestDesc",
    subject: "",
    keywords: "",
    rights: "",
    create_date: "",
    modify_date: "",
    software: "",
    rating: 3,
    raw_xml: "",
  }
  let segment = @meta.create_xmp_segment(info)
  // Convert to string for checking (skip namespace prefix)
  let ns_len = 29 // "http://ns.adobe.com/xap/1.0/" + null
  let xml_bytes : Array[Byte] = []
  for i in ns_len..<segment.length() {
    xml_bytes.push(segment[i])
  }
  let xml = @encoding/utf8.decode(Bytes::from_array(xml_bytes)[:]) catch {
    _ => ""
  }
  assert_true(xml.contains("TestTitle"))
  assert_true(xml.contains("TestAuthor"))
  assert_true(xml.contains("TestDesc"))
  assert_true(xml.contains("<xmp:Rating>3</xmp:Rating>"))
  let _ = info
}

///|
test "write_xmp_to_bytes: valid JPEG gets XMP inserted" {
  // Minimal JPEG: SOI + EOI
  let jpeg = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  let info = @meta.XmpInfo::{
    creator: "",
    title: "Inserted",
    description: "",
    subject: "",
    keywords: "",
    rights: "",
    create_date: "",
    modify_date: "",
    software: "",
    rating: 0,
    raw_xml: "",
  }
  let result = @meta.write_xmp_to_bytes(info, jpeg)
  // Should still be valid JPEG
  assert_eq(result[0].to_int(), 0xFF)
  assert_eq(result[1].to_int(), 0xD8)
  // Should have APP1 with XMP
  assert_eq(result[2].to_int(), 0xFF)
  assert_eq(result[3].to_int(), 0xE1)
  // Read back
  let read_back = @meta.read_xmp_from_bytes(result)
  match read_back {
    Some(xmp) => assert_eq(xmp.title, "Inserted")
    None => assert_true(false)
  }
  let _ = info
}

///|
test "write_xmp_to_bytes: non-JPEG raises error" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  let info = @meta.XmpInfo::{
    creator: "",
    title: "",
    description: "",
    subject: "",
    keywords: "",
    rights: "",
    create_date: "",
    modify_date: "",
    software: "",
    rating: 0,
    raw_xml: "",
  }
  try {
    let _ = @meta.write_xmp_to_bytes(info, data)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "write_xmp_to_bytes: round-trip preserves fields" {
  let jpeg = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  let info = @meta.XmpInfo::{
    creator: "Photographer",
    title: "Sunset",
    description: "A beautiful sunset",
    subject: "nature",
    keywords: "sunset,landscape",
    rights: "All rights reserved",
    create_date: "",
    modify_date: "",
    software: "MoonBit Camera",
    rating: 5,
    raw_xml: "",
  }
  let result = @meta.write_xmp_to_bytes(info, jpeg)
  let read_back = @meta.read_xmp_from_bytes(result)
  match read_back {
    Some(xmp) => {
      assert_eq(xmp.creator, "Photographer")
      assert_eq(xmp.title, "Sunset")
      assert_eq(xmp.description, "A beautiful sunset")
      assert_eq(xmp.rights, "All rights reserved")
      assert_eq(xmp.software, "MoonBit Camera")
      assert_eq(xmp.rating, 5)
    }
    None => assert_true(false)
  }
}
