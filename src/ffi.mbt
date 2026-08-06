///|
#borrow(buffer, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_from_memory(
  buffer : Bytes,
  len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_memory"

///|
#borrow(path, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_from_path(
  path : Bytes,
  path_len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_path"

///|
#borrow(path, data)
extern "c" fn stb_image_mbt_write_png_to_path(
  path : Bytes,
  path_len : Int,
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
  stride_in_bytes : Int,
) -> Int = "stb_image_mbt_write_png_to_path"

///|
#borrow(path, data)
extern "c" fn stb_image_mbt_write_bmp_to_path(
  path : Bytes,
  path_len : Int,
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
) -> Int = "stb_image_mbt_write_bmp_to_path"

///|
#borrow(path, data)
extern "c" fn stb_image_mbt_write_tga_to_path(
  path : Bytes,
  path_len : Int,
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
) -> Int = "stb_image_mbt_write_tga_to_path"

///|
#borrow(path, data)
extern "c" fn stb_image_mbt_write_jpg_to_path(
  path : Bytes,
  path_len : Int,
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
  quality : Int,
) -> Int = "stb_image_mbt_write_jpg_to_path"

///|
#borrow(data)
extern "c" fn stb_image_mbt_write_png_to_bytes(
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
  stride_in_bytes : Int,
) -> Bytes = "stb_image_mbt_write_png_to_bytes"

///|
#borrow(data)
extern "c" fn stb_image_mbt_write_bmp_to_bytes(
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
) -> Bytes = "stb_image_mbt_write_bmp_to_bytes"

///|
#borrow(data)
extern "c" fn stb_image_mbt_write_tga_to_bytes(
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
) -> Bytes = "stb_image_mbt_write_tga_to_bytes"

///|
#borrow(data)
extern "c" fn stb_image_mbt_write_jpg_to_bytes(
  w : Int,
  h : Int,
  comp : Int,
  data : Bytes,
  quality : Int,
) -> Bytes = "stb_image_mbt_write_jpg_to_bytes"

///|
extern "c" fn stb_image_mbt_set_flip_vertically_on_load(
  flag_true_if_should_flip : Int,
) -> Unit = "stb_image_mbt_set_flip_vertically_on_load"

///|
extern "c" fn stb_image_mbt_flip_vertically_on_write(
  flip_boolean : Int,
) -> Unit = "stb_image_mbt_flip_vertically_on_write"

// ============================================================
// v0.3 FFI 声明：16-bit / float / info / 查询 / 配置
// ============================================================

///|
#borrow(buffer, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_16_from_memory(
  buffer : Bytes,
  len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_16_from_memory"

///|
#borrow(path, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_16_from_path(
  path : Bytes,
  path_len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_16_from_path"

///|
#borrow(buffer, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_loadf_from_memory(
  buffer : Bytes,
  len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_loadf_from_memory"

///|
#borrow(path, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_loadf_from_path(
  path : Bytes,
  path_len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_loadf_from_path"

///|
#borrow(buffer, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_info_from_memory(
  buffer : Bytes,
  len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Int = "stb_image_mbt_info_from_memory"

///|
#borrow(path, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_info_from_path(
  path : Bytes,
  path_len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Int = "stb_image_mbt_info_from_path"

///|
#borrow(buffer)
extern "c" fn stb_image_mbt_is_16_bit_from_memory(
  buffer : Bytes,
  len : Int,
) -> Int = "stb_image_mbt_is_16_bit_from_memory"

///|
#borrow(path)
extern "c" fn stb_image_mbt_is_16_bit_from_path(
  path : Bytes,
  path_len : Int,
) -> Int = "stb_image_mbt_is_16_bit_from_path"

///|
#borrow(buffer)
extern "c" fn stb_image_mbt_is_hdr_from_memory(
  buffer : Bytes,
  len : Int,
) -> Int = "stb_image_mbt_is_hdr_from_memory"

///|
#borrow(path)
extern "c" fn stb_image_mbt_is_hdr_from_path(
  path : Bytes,
  path_len : Int,
) -> Int = "stb_image_mbt_is_hdr_from_path"

///|
extern "c" fn stb_image_mbt_failure_reason() -> Bytes =
  "stb_image_mbt_failure_reason"

///|
extern "c" fn stb_image_mbt_set_unpremultiply_on_load(
  flag_true_if_should_unpremultiply : Int,
) -> Unit = "stb_image_mbt_set_unpremultiply_on_load"

///|
extern "c" fn stb_image_mbt_convert_iphone_png_to_rgb(
  flag_true_if_should_convert : Int,
) -> Unit = "stb_image_mbt_convert_iphone_png_to_rgb"

///|
extern "c" fn stb_image_mbt_hdr_to_ldr_gamma(gamma : Float) -> Unit =
  "stb_image_mbt_hdr_to_ldr_gamma"

///|
extern "c" fn stb_image_mbt_hdr_to_ldr_scale(scale : Float) -> Unit =
  "stb_image_mbt_hdr_to_ldr_scale"

///|
extern "c" fn stb_image_mbt_ldr_to_hdr_gamma(gamma : Float) -> Unit =
  "stb_image_mbt_ldr_to_hdr_gamma"

///|
extern "c" fn stb_image_mbt_ldr_to_hdr_scale(scale : Float) -> Unit =
  "stb_image_mbt_ldr_to_hdr_scale"

///|
#borrow(buffer, w_ref, h_ref, z_ref, c_ref, delays_len_ref)
extern "c" fn stb_image_mbt_load_gif_from_memory(
  buffer : Bytes,
  len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  z_ref : Ref[Int],
  c_ref : Ref[Int],
  delays_len_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_gif_from_memory"

///|
#borrow(path, w_ref, h_ref, z_ref, c_ref, delays_len_ref)
extern "c" fn stb_image_mbt_load_gif_from_path(
  path : Bytes,
  path_len : Int,
  desired_channels : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  z_ref : Ref[Int],
  c_ref : Ref[Int],
  delays_len_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_gif_from_path"
