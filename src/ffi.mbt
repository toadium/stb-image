///|
#borrow(buffer, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_from_memory(
  buffer : Bytes,
  len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_memory"

///|
#borrow(path, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_from_path(
  path : Bytes,
  path_len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_path"