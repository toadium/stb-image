// PNG 元数据文件读取（native only，依赖 @core FFI 文件 IO）

///|
/// 从 PNG 文件读取 text chunks。
pub fn read_png_text_chunks_from_path(
  path : String,
) -> Array[@meta.PngTextChunk] raise @core.LoadError {
  let file_data = @core.read_file_bytes(path)
  @meta.read_png_text_chunks(file_data)
}
