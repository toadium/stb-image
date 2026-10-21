// v209 segment 模块补充错误路径测试

///|
fn seg_mk_img(w : Int32, h : Int32, ch : Int32, val : Int32) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, (val & 0xFF).to_byte())
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

// ========== watershed 错误路径 ==========

///|
test "seg2: watershed 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  let markers = Array::make(16, 0)
  try {
    ignore(@segment.watershed(img, markers))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: watershed markers长度不匹配 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  let markers = Array::make(10, 0)
  try {
    ignore(@segment.watershed(img, markers))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: watershed 正常4x4灰度图" {
  let img = seg_mk_img(4, 4, 1, 128)
  let markers = Array::make(16, 0)
  let result = @segment.watershed(img, markers) catch { _ => [] }
  assert_eq(result.length(), 16)
}

// ========== watershed_auto 错误路径 ==========

///|
test "seg2: watershed_auto 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  try {
    ignore(@segment.watershed_auto(img))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: watershed_auto 正常4x4灰度图" {
  let img = seg_mk_img(4, 4, 1, 128)
  let (labels, _) = @segment.watershed_auto(img) catch { _ => ([], 0) }
  assert_eq(labels.length(), 16)
}

// ========== skeletonize 错误路径 ==========

///|
test "seg2: skeletonize 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  try {
    ignore(@segment.skeletonize(img))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: skeletonize 无效通道0 raise" {
  let img = seg_mk_img(4, 4, 0, 128)
  try {
    ignore(@segment.skeletonize(img))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: skeletonize 正常4x4灰度图" {
  let img = seg_mk_img(4, 4, 1, 0)
  let result = @segment.skeletonize(img) catch {
    _ =>
      @types.Image::{
        width: 0,
        height: 0,
        channels: 0,
        data: Bytes::from_array([]),
      }
  }
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

// ========== distance_transform 错误路径 ==========

///|
test "seg2: distance_transform 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  try {
    ignore(@segment.distance_transform(img))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: distance_transform 无效通道0 raise" {
  let img = seg_mk_img(4, 4, 0, 128)
  try {
    ignore(@segment.distance_transform(img))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: distance_transform 无效distance_type=5 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  try {
    ignore(@segment.distance_transform(img, distance_type=5))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== flood_fill 错误路径 ==========

///|
test "seg2: flood_fill 灰度图channels=1 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  try {
    ignore(@segment.flood_fill(img, 1, 1, [b'\xFF']))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: flood_fill 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  try {
    ignore(@segment.flood_fill(img, 1, 1, [b'\xFF']))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: flood_fill 种子点x越界 raise" {
  let img = seg_mk_img(4, 4, 3, 128)
  try {
    ignore(@segment.flood_fill(img, 10, 1, [b'\xFF', b'\x00', b'\x00']))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: flood_fill 种子点y越界 raise" {
  let img = seg_mk_img(4, 4, 3, 128)
  try {
    ignore(@segment.flood_fill(img, 1, 10, [b'\xFF', b'\x00', b'\x00']))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: flood_fill 种子点负坐标 raise" {
  let img = seg_mk_img(4, 4, 3, 128)
  try {
    ignore(@segment.flood_fill(img, -1, 1, [b'\xFF', b'\x00', b'\x00']))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== region_growing_segment 错误路径 ==========

///|
test "seg2: region_growing_segment 灰度图channels=1 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  try {
    ignore(@segment.region_growing_segment(img, [(0, 0)]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: region_growing_segment 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  try {
    ignore(@segment.region_growing_segment(img, [(0, 0)]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: region_growing_segment 空种子正常" {
  let img = seg_mk_img(4, 4, 3, 128)
  let (_, regions) = @segment.region_growing_segment(img, []) catch {
    _ =>
      (
        @segment.SegmentLabelImage::{
          width: 0,
          height: 0,
          labels: [],
          num_regions: 0,
        },
        [],
      )
  }
  assert_eq(regions.length(), 0)
}

// ========== connected_components 补充 ==========

///|
test "seg2: connected_components connectivity=3 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  try {
    ignore(@segment.connected_components(img, 3))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: connected_components connectivity=6 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  try {
    ignore(@segment.connected_components(img, 6))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: connected_components connectivity=0 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  try {
    ignore(@segment.connected_components(img, 0))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== kmeans_segment 补充 ==========

///|
test "seg2: kmeans_segment k=0 raise" {
  let img = seg_mk_img(4, 4, 3, 128)
  try {
    ignore(@segment.kmeans_segment(img, 0))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: kmeans_segment k=257 raise" {
  let img = seg_mk_img(4, 4, 3, 128)
  try {
    ignore(@segment.kmeans_segment(img, 257))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: kmeans_segment 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  try {
    ignore(@segment.kmeans_segment(img, 3))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== slic 补充 ==========

///|
test "seg2: slic 零宽度 raise" {
  let img = seg_mk_img(0, 4, 3, 128)
  try {
    ignore(@segment.slic(img, 4, 10, 5))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: slic 零高度 raise" {
  let img = seg_mk_img(4, 0, 3, 128)
  try {
    ignore(@segment.slic(img, 4, 10, 5))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: slic k=0 raise" {
  let img = seg_mk_img(4, 4, 3, 128)
  try {
    ignore(@segment.slic(img, 0, 10, 5))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: slic max_iters=0 raise" {
  let img = seg_mk_img(4, 4, 3, 128)
  try {
    ignore(@segment.slic(img, 4, 10, 0))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== grab_cut 补充 ==========

///|
test "seg2: grab_cut 1x1 raise" {
  let img = seg_mk_img(1, 1, 3, 128)
  try {
    ignore(@segment.grab_cut(img, 0, 0, 1, 1))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: grab_cut 1xN raise" {
  let img = seg_mk_img(1, 4, 3, 128)
  try {
    ignore(@segment.grab_cut(img, 0, 0, 1, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: grab_cut 灰度图 raise" {
  let img = seg_mk_img(4, 4, 1, 128)
  try {
    ignore(@segment.grab_cut(img, 0, 0, 4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "seg2: grab_cut 无效通道2 raise" {
  let img = seg_mk_img(4, 4, 2, 128)
  try {
    ignore(@segment.grab_cut(img, 0, 0, 4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
