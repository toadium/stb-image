// EXIF 元数据文件读取（native only，依赖 @core FFI 文件 IO）

///|
/// 从 JPEG 文件读取 EXIF 元数据。
/// 返回 None 如果文件不含 EXIF 数据。
pub fn read_exif_from_path(path : String) -> @meta.ExifInfo? raise @core.LoadError {
  let file_data = @core.read_file_bytes(path)
  @meta.read_exif_from_bytes(file_data)
}
