// 文件读取辅助（FFI wrapper）

///|
#borrow(path, len_ref)
extern "c" fn file_io_read_file(
  path : Bytes,
  path_len : Int,
  len_ref : Ref[Int]
) -> Bytes = "stb_image_mbt_read_file"

///|
/// 读取文件全部内容为 Bytes。失败时 raise LoadError::FileIO。
pub fn read_file_bytes(path : String) -> Bytes raise LoadError {
  let path_bytes = @encoding/utf8.encode(path)
  let len_ref = Ref(0)
  let file_data = file_io_read_file(path_bytes, path_bytes.length(), len_ref)
  if len_ref.val == 0 {
    raise LoadError::FileIO("无法读取文件: " + path)
  }
  file_data
}