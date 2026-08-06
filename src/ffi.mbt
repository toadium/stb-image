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
