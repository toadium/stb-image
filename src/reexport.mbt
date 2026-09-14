// Re-export all public APIs from subpackages for backward compatibility
// Manually maintained. To add a new public API, add the corresponding re-export here and run `moon info` to verify.

// Type re-exports

///|
pub type ExifInfo = @meta.ExifInfo

///|
pub type GifAnimation = @types.GifAnimation

///|
pub type PngAnimation = @types.PngAnimation

///|
pub type Image = @types.Image

///|
pub type Image16 = @types.Image16

///|
pub type ImageF = @types.ImageF

///|
pub type ImageFormat = @types.ImageFormat

///|
pub type ImageInfo = @types.ImageInfo

///|
pub type ImageStats = @util.ImageStats

///|
pub type ImageStatsF = @util.ImageStatsF

///|
pub type LoadError = @types.LoadError

///|
pub type PngTextChunk = @meta.PngTextChunk

///|
pub type ResizeEdge = @types.ResizeEdge

///|
pub type ResizeFilter = @types.ResizeFilter

///|
pub const MAX_IMAGE_DIMENSION : Int = @types.MAX_IMAGE_DIMENSION

///|
pub fn check_dims(
  width : Int,
  height : Int,
  channels : Int,
) -> Unit raise LoadError {
  @types.check_dims(width, height, channels)
}

///|
pub fn safe_mul(a : Int, b : Int) -> Int? {
  @types.safe_mul(a, b)
}

///|
pub fn safe_mul3(a : Int, b : Int, c : Int) -> Int? {
  @types.safe_mul3(a, b, c)
}

///|
pub type Complex = @frequency.Complex

///|
pub type FFTResult = @frequency.FFTResult

///|
pub type FreqFilterType = @frequency.FreqFilterType

///|
pub type ConnectedComponent = @segment.ConnectedComponent

///|
pub type ConnectedComponentLabelImage = @segment.ConnectedComponentLabelImage

///|
pub type IntegralImage = @feature.IntegralImage

///|
pub type IntegralImageSq = @feature.IntegralImageSq

///|
pub type HoughLine = @edge.HoughLine

///|
pub type ContourPoint = @edge.ContourPoint

///|
pub type Contour = @edge.Contour

///|
pub type SegmentLabelImage = @segment.SegmentLabelImage

///|
pub type SegmentRegion = @segment.SegmentRegion

///|
pub type Colormap = @color.Colormap

///|
pub type GlcmFeatures = @feature.GlcmFeatures

///|
pub type HaarWaveletResult = @frequency.HaarWaveletResult

///|
pub type CornerPoint = @feature.CornerPoint

///|
pub type OrbKeyPoint = @feature.OrbKeyPoint

///|
pub type OrbDescriptor = @feature.OrbDescriptor

///|
pub type DescriptorMatch = @feature.DescriptorMatch

///|
pub type FlowResult = @feature.FlowResult

///|
pub type TemplateMatchMethod = @feature.TemplateMatchMethod

///|
pub type TemplateMatchResult = @feature.TemplateMatchResult

///|
pub type SiftKeyPoint = @feature.SiftKeyPoint

///|
pub type SiftDescriptor = @feature.SiftDescriptor

///|
pub type SiftMatch = @feature.SiftMatch

///|
pub type StreamInfo = @lib.StreamInfo

// From @lib/@pure (all-target pure MoonBit)

///|
pub let convert_iphone_png_to_rgb : (Bool) -> Unit = @pure_util.convert_iphone_png_to_rgb_pure

///|
/// 自动格式分派解码（decode_any 的别名）
/// 行为与 load_from_bytes 等价，两者均委托 @lib.load_from_bytes_auto
pub fn decode_any(
  arg0 : Bytes,
  req_channels? : Int? = None,
) -> @types.Image raise @types.LoadError {
  @lib.load_from_bytes_auto(arg0, req_channels~)
}

///|
pub fn detect_format(data : Bytes) -> @types.ImageFormat {
  @lib.detect_format(data)
}

///|
pub let failure_reason : () -> String = @pure_util.failure_reason_pure

///|
pub let flip_vertically_on_write : (Bool) -> Unit = @pure_util.flip_vertically_on_write_pure

///|
pub let hdr_to_ldr_gamma : (Float) -> Unit = @pure_util.hdr_to_ldr_gamma_pure

///|
pub let hdr_to_ldr_scale : (Float) -> Unit = @pure_util.hdr_to_ldr_scale_pure

///|
pub let info_from_bytes : (Bytes) -> @types.ImageInfo? raise @types.LoadError = @pure_util.info_from_bytes_pure

///|
pub let is_16_bit_from_bytes : (Bytes) -> Bool = @pure_util.is_16_bit_from_bytes_pure

///|
pub let is_hdr_from_bytes : (Bytes) -> Bool = @pure_util.is_hdr_from_bytes_pure

///|
pub fn is_supported_format(data : Bytes) -> Bool {
  @lib.detect_format(data) != @types.ImageFormat::Unknown
}

///|
pub let ldr_to_hdr_gamma : (Float) -> Unit = @pure_util.ldr_to_hdr_gamma_pure

///|
pub let ldr_to_hdr_scale : (Float) -> Unit = @pure_util.ldr_to_hdr_scale_pure

///|
/// 自动格式分派解码（load_from_bytes 是 decode_any 的别名）
/// 行为与 decode_any 等价，两者均委托 @lib.load_from_bytes_auto
pub fn load_from_bytes(
  arg0 : Bytes,
  req_channels? : Int? = None,
) -> @types.Image raise @types.LoadError {
  @lib.load_from_bytes_auto(arg0, req_channels~)
}

///|
pub let load_gif_from_bytes : (Bytes) -> @types.GifAnimation raise @types.LoadError = @codec.decode_gif_animation_pure

///|
pub let load_f_from_bytes : (Bytes) -> @types.ImageF raise @types.LoadError = @codec.decode_hdr_pure

///|
pub fn resize(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Int,
  filter? : @types.ResizeFilter = Default,
  edge? : @types.ResizeEdge = Clamp,
) -> @types.Image raise @types.LoadError {
  @pure_util.resize_pure(arg0, arg1, arg2, filter~, edge~)
}

///|
pub let resize_16 : (@types.Image16, Int, Int) -> @types.Image16 = @transform.resize_16

///|
pub let resize_f : (@types.ImageF, Int, Int) -> @types.ImageF = @transform.resize_f

///|
pub let set_flip_vertically_on_load : (Bool) -> Unit = @pure_util.set_flip_vertically_on_load_pure

///|
pub let set_unpremultiply_on_load : (Bool) -> Unit = @pure_util.set_unpremultiply_on_load_pure

///|
pub fn write_bmp_to_bytes(img : @types.Image) -> Bytes {
  @codec.encode_bmp_pure(img)
}

///|
pub let write_hdr_to_bytes : (@types.ImageF) -> Bytes raise @types.LoadError = @codec.encode_hdr_pure

///|
pub let write_jpeg_to_bytes : (@types.Image) -> Bytes raise @types.LoadError = @codec.encode_jpeg_pure

///|
pub let write_png_to_bytes : (@types.Image) -> Bytes = @codec.encode_png_pure

///|
pub fn write_tga_to_bytes(img : @types.Image) -> Bytes {
  @codec.encode_tga_pure(img)
}

// From process/

///|
pub let adjust_brightness : (@types.Image, Int) -> @types.Image = @color.adjust_brightness

///|
pub let adjust_brightness_16 : (@types.Image16, Int) -> @types.Image16 = @color.adjust_brightness_16

///|
pub let adjust_brightness_f : (@types.ImageF, Float) -> @types.ImageF = @color.adjust_brightness_f

///|
pub let adjust_contrast : (@types.Image, Float) -> @types.Image = @color.adjust_contrast

///|
pub let adjust_contrast_16 : (@types.Image16, Float) -> @types.Image16 = @color.adjust_contrast_16

///|
pub let adjust_contrast_f : (@types.ImageF, Float) -> @types.ImageF = @color.adjust_contrast_f

///|
pub let adjust_saturation : (@types.Image, Float) -> @types.Image = @color.adjust_saturation

///|
pub let adjust_hue : (@types.Image, Float) -> @types.Image = @color.adjust_hue

///|
pub let adjust_gamma : (@types.Image, Float) -> @types.Image = @color.adjust_gamma
pub let adjust_gamma_16 : (@types.Image16, Float) -> @types.Image16 = @color.adjust_gamma_16
pub let adjust_gamma_f : (@types.ImageF, Float) -> @types.ImageF = @color.adjust_gamma_f

///|
pub let adaptive_threshold_mean : (@types.Image, Int, Int) -> @types.Image raise @types.LoadError = @color.adaptive_threshold_mean
pub let adaptive_threshold_mean_16 : (@types.Image16, Int, Int) -> @types.Image16 raise @types.LoadError = @color.adaptive_threshold_mean_16
pub let adaptive_threshold_mean_f : (@types.ImageF, Int, Float) -> @types.ImageF raise @types.LoadError = @color.adaptive_threshold_mean_f

///|
pub let adaptive_threshold_gaussian : (@types.Image, Int, Int) -> @types.Image raise @types.LoadError = @color.adaptive_threshold_gaussian
pub let adaptive_threshold_gaussian_16 : (@types.Image16, Int, Int) -> @types.Image16 raise @types.LoadError = @color.adaptive_threshold_gaussian_16
pub let adaptive_threshold_gaussian_f : (@types.ImageF, Int, Float) -> @types.ImageF raise @types.LoadError = @color.adaptive_threshold_gaussian_f

///|
pub let bilateral_filter : (@types.Image, Int, Float, Float) -> @types.Image raise @types.LoadError = @filter.bilateral_filter
pub let bilateral_filter_16 : (@types.Image16, Int, Float, Float) -> @types.Image16 raise @types.LoadError = @filter.bilateral_filter_16
pub let bilateral_filter_f : (@types.ImageF, Int, Float, Float) -> @types.ImageF raise @types.LoadError = @filter.bilateral_filter_f

///|
pub let bilateral_filter_fast : (@types.Image, Int, Float, Float, Int) -> @types.Image raise @types.LoadError = @filter.bilateral_filter_fast
pub let bilateral_filter_fast_16 : (@types.Image16, Int, Float, Float, Int) -> @types.Image16 raise @types.LoadError = @filter.bilateral_filter_fast_16
pub let bilateral_filter_fast_f : (@types.ImageF, Int, Float, Float, Int) -> @types.ImageF raise @types.LoadError = @filter.bilateral_filter_fast_f

///|
pub let box_blur : (@types.Image, Int) -> @types.Image = @filter.box_blur

///|
pub let box_blur_16 : (@types.Image16, Int) -> @types.Image16 = @filter.box_blur_16

///|
pub let box_blur_f : (@types.ImageF, Int) -> @types.ImageF = @filter.box_blur_f

///|
pub let build_gaussian_pyramid : (@types.Image, Int) -> Array[@types.Image] raise @types.LoadError = @transform.build_gaussian_pyramid
pub let build_gaussian_pyramid_16 : (@types.Image16, Int) -> Array[@types.Image16] raise @types.LoadError = @transform.build_gaussian_pyramid_16
pub let build_gaussian_pyramid_f : (@types.ImageF, Int) -> Array[@types.ImageF] raise @types.LoadError = @transform.build_gaussian_pyramid_f

///|
pub let build_laplacian_pyramid : (@types.Image, Int) -> Array[@types.Image] raise @types.LoadError = @transform.build_laplacian_pyramid
pub let build_laplacian_pyramid_16 : (@types.Image16, Int) -> Array[@types.Image16] raise @types.LoadError = @transform.build_laplacian_pyramid_16
pub let build_laplacian_pyramid_f : (@types.ImageF, Int) -> Array[@types.ImageF] raise @types.LoadError = @transform.build_laplacian_pyramid_float

///|
pub let clahe : (@types.Image, Int, Float) -> @types.Image raise @types.LoadError = @color.clahe

///|
pub fn canny_edge(
  arg0 : @types.Image,
  low_threshold? : Int = 50,
  high_threshold? : Int = 100,
) -> @types.Image raise @types.LoadError {
  @edge.canny_edge(arg0, low_threshold~, high_threshold~)
}

///|
pub fn canny_edge_16(
  arg0 : @types.Image16,
  low_threshold? : Int = 12800,
  high_threshold? : Int = 25600,
) -> @types.Image16 raise @types.LoadError {
  @edge.canny_edge_16(arg0, low_threshold~, high_threshold~)
}

///|
pub fn canny_edge_f(
  arg0 : @types.ImageF,
  low_threshold? : Float = 0.2F,
  high_threshold? : Float = 0.4F,
) -> @types.ImageF raise @types.LoadError {
  @edge.canny_edge_f(arg0, low_threshold~, high_threshold~)
}

///|
pub let connected_components : (@types.Image, Int) -> (
  @segment.ConnectedComponentLabelImage,
  Array[@segment.ConnectedComponent],
) raise @types.LoadError = @segment.connected_components

///|
pub let contour_area : (@edge.Contour) -> Float = @edge.contour_area

///|
pub let contour_perimeter : (@edge.Contour) -> Float = @edge.contour_perimeter

///|
pub fn compute_glcm(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Int,
  levels? : Int = 256,
) -> Array[Array[Int]] raise @types.LoadError {
  @feature.compute_glcm(arg0, arg1, arg2, levels~)
}

///|
pub fn compute_glcm_16(
  arg0 : @types.Image16,
  arg1 : Int,
  arg2 : Int,
  levels? : Int = 256,
) -> Array[Array[Int]] raise @types.LoadError {
  @feature.compute_glcm_16(arg0, arg1, arg2, levels~)
}

///|
pub fn compute_glcm_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  arg2 : Int,
  levels? : Int = 256,
) -> Array[Array[Int]] raise @types.LoadError {
  @feature.compute_glcm_f(arg0, arg1, arg2, levels~)
}

///|
pub let crop : (@types.Image, Int, Int, Int, Int) -> @types.Image raise @types.LoadError = @transform.crop

///|
pub fn dehaze(
  arg0 : @types.Image,
  patch_size? : Int = 7,
  omega? : Float = 0.95F,
  t0? : Float = 0.1F,
) -> @types.Image raise @types.LoadError {
  @color.dehaze(arg0, patch_size~, omega~, t0~)
}

///|
pub fn dehaze_16(
  arg0 : @types.Image16,
  patch_size? : Int = 7,
  omega? : Float = 0.95F,
  t0? : Float = 0.1F,
) -> @types.Image16 raise @types.LoadError {
  @color.dehaze_16(arg0, patch_size~, omega~, t0~)
}

///|
pub fn dehaze_f(
  arg0 : @types.ImageF,
  patch_size? : Int = 7,
  omega? : Float = 0.95F,
  t0? : Float = 0.1F,
) -> @types.ImageF raise @types.LoadError {
  @color.dehaze_f(arg0, patch_size~, omega~, t0~)
}

///|
pub let draw_contours : (@types.Image, Array[@edge.Contour], Array[Byte]) -> @types.Image raise @types.LoadError = @edge.draw_contours
pub let draw_contours_16 : (@types.Image16, Array[@edge.Contour], Array[Int]) -> @types.Image16 raise @types.LoadError = @edge.draw_contours_16
pub let draw_contours_f : (@types.ImageF, Array[@edge.Contour], Array[Float]) -> @types.ImageF raise @types.LoadError = @edge.draw_contours_f

///|
pub fn draw_corners(
  arg0 : @types.Image,
  arg1 : Array[@feature.CornerPoint],
  color? : Array[Byte] = [b'\xFF', b'\x00', b'\x00'],
  radius? : Int = 2,
) -> @types.Image raise @types.LoadError {
  @feature.draw_corners(arg0, arg1, color~, radius~)
}

///|
pub let crop_16 : (@types.Image16, Int, Int, Int, Int) -> @types.Image16 raise @types.LoadError = @transform.crop_16

///|
pub let crop_f : (@types.ImageF, Int, Int, Int, Int) -> @types.ImageF raise @types.LoadError = @transform.crop_f

///|
pub let dilate : (@types.Image) -> @types.Image = @segment.dilate
pub let dilate_16 : (@types.Image16) -> @types.Image16 = @segment.dilate_16
pub let dilate_f : (@types.ImageF) -> @types.ImageF = @segment.dilate_f

///|
pub let draw_copy : (@types.Image, @types.Image, Int, Int) -> @types.Image raise @types.LoadError = @transform.draw_copy

///|
pub fn draw_line(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Int,
  arg5 : Array[Byte],
  thickness? : Int = 1,
) -> @types.Image {
  @transform.draw_line(arg0, arg1, arg2, arg3, arg4, arg5, thickness~)
}

///|
pub fn draw_rectangle(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Int,
  arg5 : Array[Byte],
  thickness? : Int = 1,
  fill? : Bool = false,
) -> @types.Image {
  @transform.draw_rectangle(
    arg0,
    arg1,
    arg2,
    arg3,
    arg4,
    arg5,
    thickness~,
    fill~,
  )
}

///|
pub fn draw_circle(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Array[Byte],
  thickness? : Int = 1,
  fill? : Bool = false,
) -> @types.Image {
  @transform.draw_circle(arg0, arg1, arg2, arg3, arg4, thickness~, fill~)
}

///|
pub fn draw_polygon(
  arg0 : @types.Image,
  arg1 : Array[(Int, Int)],
  arg2 : Array[Byte],
  thickness? : Int = 1,
  fill? : Bool = false,
) -> @types.Image {
  @transform.draw_polygon(arg0, arg1, arg2, thickness~, fill~)
}

///|
pub fn draw_line_16(
  arg0 : @types.Image16,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Int,
  arg5 : Array[Int],
  thickness? : Int = 1,
) -> @types.Image16 {
  @transform.draw_line_16(arg0, arg1, arg2, arg3, arg4, arg5, thickness~)
}

///|
pub fn draw_rectangle_16(
  arg0 : @types.Image16,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Int,
  arg5 : Array[Int],
  thickness? : Int = 1,
  fill? : Bool = false,
) -> @types.Image16 {
  @transform.draw_rectangle_16(arg0, arg1, arg2, arg3, arg4, arg5, thickness~, fill~)
}

///|
pub fn draw_circle_16(
  arg0 : @types.Image16,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Array[Int],
  thickness? : Int = 1,
  fill? : Bool = false,
) -> @types.Image16 {
  @transform.draw_circle_16(arg0, arg1, arg2, arg3, arg4, thickness~, fill~)
}

///|
pub fn draw_polygon_16(
  arg0 : @types.Image16,
  arg1 : Array[(Int, Int)],
  arg2 : Array[Int],
  thickness? : Int = 1,
) -> @types.Image16 {
  @transform.draw_polygon_16(arg0, arg1, arg2, thickness~)
}

///|
pub fn draw_line_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Int,
  arg5 : Array[Float],
  thickness? : Int = 1,
) -> @types.ImageF {
  @transform.draw_line_f(arg0, arg1, arg2, arg3, arg4, arg5, thickness~)
}

///|
pub fn draw_rectangle_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Int,
  arg5 : Array[Float],
  thickness? : Int = 1,
  fill? : Bool = false,
) -> @types.ImageF {
  @transform.draw_rectangle_f(arg0, arg1, arg2, arg3, arg4, arg5, thickness~, fill~)
}

///|
pub fn draw_circle_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Array[Float],
  thickness? : Int = 1,
  fill? : Bool = false,
) -> @types.ImageF {
  @transform.draw_circle_f(arg0, arg1, arg2, arg3, arg4, thickness~, fill~)
}

///|
pub fn draw_polygon_f(
  arg0 : @types.ImageF,
  arg1 : Array[(Int, Int)],
  arg2 : Array[Float],
  thickness? : Int = 1,
) -> @types.ImageF {
  @transform.draw_polygon_f(arg0, arg1, arg2, thickness~)
}

///|
pub let draw_over : (@types.Image, @types.Image, Int, Int) -> @types.Image raise @types.LoadError = @transform.draw_over

///|
pub let edge_detect_laplacian : (@types.Image) -> @types.Image = @edge.edge_detect_laplacian
pub let edge_detect_laplacian_16 : (@types.Image16) -> @types.Image16 = @edge.edge_detect_laplacian_16
pub let edge_detect_laplacian_f : (@types.ImageF) -> @types.ImageF = @edge.edge_detect_laplacian_f

///|
pub let edge_detect_prewitt : (@types.Image) -> @types.Image = @edge.edge_detect_prewitt
pub let edge_detect_prewitt_16 : (@types.Image16) -> @types.Image16 = @edge.edge_detect_prewitt_16
pub let edge_detect_prewitt_f : (@types.ImageF) -> @types.ImageF = @edge.edge_detect_prewitt_f

///|
pub let edge_detect_sobel : (@types.Image) -> @types.Image = @edge.edge_detect_sobel

///|
pub let edge_detect_sobel_16 : (@types.Image16) -> @types.Image16 = @edge.edge_detect_sobel_16

///|
pub let edge_detect_sobel_f : (@types.ImageF) -> @types.ImageF = @edge.edge_detect_sobel_f

///|
pub let erode : (@types.Image) -> @types.Image = @segment.erode
pub let erode_16 : (@types.Image16) -> @types.Image16 = @segment.erode_16
pub let erode_f : (@types.ImageF) -> @types.ImageF = @segment.erode_f

///|
pub let fft_2d : (@types.Image) -> Array[@frequency.FFTResult] raise @types.LoadError = @frequency.fft_2d
pub let fft_2d_16 : (@types.Image16) -> Array[@frequency.FFTResult] raise @types.LoadError = @frequency.fft_2d_16
pub let fft_2d_f : (@types.ImageF) -> Array[@frequency.FFTResult] raise @types.LoadError = @frequency.fft_2d_f

///|
pub let fft_magnitude : (@frequency.FFTResult, Bool) -> @types.Image = @frequency.fft_magnitude
pub let fft_magnitude_16 : (@frequency.FFTResult, Bool) -> @types.Image16 = @frequency.fft_magnitude_16
pub let fft_magnitude_f : (@frequency.FFTResult, Bool) -> @types.ImageF = @frequency.fft_magnitude_f

///|
pub let fft_shift : (@frequency.FFTResult) -> @frequency.FFTResult = @frequency.fft_shift

///|
pub fn freq_filter(
  arg0 : @types.Image,
  arg1 : @frequency.FreqFilterType,
  arg2 : Float,
  band_width? : Float = 0.0F,
) -> @types.Image raise @types.LoadError {
  @frequency.freq_filter(arg0, arg1, arg2, band_width~)
}

///|
pub fn freq_filter_gaussian(
  arg0 : @types.Image,
  arg1 : @frequency.FreqFilterType,
  arg2 : Float,
  band_width? : Float = 0.0F,
) -> @types.Image raise @types.LoadError {
  @frequency.freq_filter_gaussian(arg0, arg1, arg2, band_width~)
}

///|
pub let flip_horizontal : (@types.Image) -> @types.Image = @transform.flip_horizontal

///|
pub let flip_horizontal_16 : (@types.Image16) -> @types.Image16 = @transform.flip_horizontal_16

///|
pub let flip_horizontal_f : (@types.ImageF) -> @types.ImageF = @transform.flip_horizontal_f

///|
pub fn harris_corners(
  arg0 : @types.Image,
  k? : Float = 0.04F,
  threshold? : Float = 1000.0F,
  min_distance? : Int = 5,
) -> Array[@feature.CornerPoint] raise @types.LoadError {
  @feature.harris_corners(arg0, k~, threshold~, min_distance~)
}

///|
pub fn harris_corners_16(
  arg0 : @types.Image16,
  k? : Float = 0.04F,
  threshold? : Float = 1000.0F,
  min_distance? : Int = 5,
) -> Array[@feature.CornerPoint] raise @types.LoadError {
  @feature.harris_corners_16(arg0, k~, threshold~, min_distance~)
}

///|
pub fn harris_corners_f(
  arg0 : @types.ImageF,
  k? : Float = 0.04F,
  threshold? : Float = 1000.0F,
  min_distance? : Int = 5,
) -> Array[@feature.CornerPoint] raise @types.LoadError {
  @feature.harris_corners_f(arg0, k~, threshold~, min_distance~)
}

///|
/// ORB 特征检测
pub fn orb_detect(
  arg0 : @types.Image,
  max_features? : Int = 500,
  threshold? : Int = 20,
) -> Array[@feature.OrbDescriptor] raise @types.LoadError {
  @feature.orb_detect(arg0, max_features~, threshold~)
}

///|
pub fn orb_detect_16(
  arg0 : @types.Image16,
  max_features? : Int = 500,
  threshold? : Int = 20,
) -> Array[@feature.OrbDescriptor] raise @types.LoadError {
  @feature.orb_detect_16(arg0, max_features~, threshold~)
}

///|
pub fn orb_detect_f(
  arg0 : @types.ImageF,
  max_features? : Int = 500,
  threshold? : Int = 20,
) -> Array[@feature.OrbDescriptor] raise @types.LoadError {
  @feature.orb_detect_f(arg0, max_features~, threshold~)
}

///|
/// ORB 描述子汉明距离
pub let orb_hamming : (@feature.OrbDescriptor, @feature.OrbDescriptor) -> Int = @feature.orb_hamming

///|
/// ORB 特征匹配
pub fn orb_match(
  arg0 : Array[@feature.OrbDescriptor],
  arg1 : Array[@feature.OrbDescriptor],
  max_distance? : Int = 64,
) -> Array[@feature.DescriptorMatch] {
  @feature.orb_match(arg0, arg1, max_distance~)
}

///|
/// 模板匹配
pub fn template_match(
  arg0 : @types.Image,
  arg1 : @types.Image,
  match_method? : @feature.TemplateMatchMethod = @feature.TemplateMatchMethod::CCoeffNormed,
) -> Array[@feature.TemplateMatchResult] raise @types.LoadError {
  @feature.template_match(arg0, arg1, match_method~)
}

///|
pub fn template_match_16(
  arg0 : @types.Image16,
  arg1 : @types.Image16,
  match_method? : @feature.TemplateMatchMethod = @feature.TemplateMatchMethod::CCoeffNormed,
) -> Array[@feature.TemplateMatchResult] raise @types.LoadError {
  @feature.template_match_16(arg0, arg1, match_method~)
}

///|
pub fn template_match_f(
  arg0 : @types.ImageF,
  arg1 : @types.ImageF,
  match_method? : @feature.TemplateMatchMethod = @feature.TemplateMatchMethod::CCoeffNormed,
) -> Array[@feature.TemplateMatchResult] raise @types.LoadError {
  @feature.template_match_f(arg0, arg1, match_method~)
}

///|
/// 找到最佳模板匹配位置
pub fn template_match_best(
  arg0 : @types.Image,
  arg1 : @types.Image,
  match_method? : @feature.TemplateMatchMethod = @feature.TemplateMatchMethod::CCoeffNormed,
) -> @feature.TemplateMatchResult? raise @types.LoadError {
  @feature.template_match_best(arg0, arg1, match_method~)
}

///|
pub fn template_match_best_16(
  arg0 : @types.Image16,
  arg1 : @types.Image16,
  match_method? : @feature.TemplateMatchMethod = @feature.TemplateMatchMethod::CCoeffNormed,
) -> @feature.TemplateMatchResult? raise @types.LoadError {
  @feature.template_match_best_16(arg0, arg1, match_method~)
}

///|
pub fn template_match_best_f(
  arg0 : @types.ImageF,
  arg1 : @types.ImageF,
  match_method? : @feature.TemplateMatchMethod = @feature.TemplateMatchMethod::CCoeffNormed,
) -> @feature.TemplateMatchResult? raise @types.LoadError {
  @feature.template_match_best_f(arg0, arg1, match_method~)
}

///|
/// Lucas-Kanade 稀疏光流
pub fn lucas_kanade(
  arg0 : @types.Image,
  arg1 : @types.Image,
  arg2 : Array[(Int, Int)],
  window_size? : Int = 15,
  max_iter? : Int = 20,
) -> Array[@feature.FlowResult] raise @types.LoadError {
  @feature.lucas_kanade(arg0, arg1, arg2, window_size~, max_iter~)
}

///|
pub fn lucas_kanade_16(
  arg0 : @types.Image16,
  arg1 : @types.Image16,
  arg2 : Array[(Int, Int)],
  window_size? : Int = 15,
  max_iter? : Int = 20,
) -> Array[@feature.FlowResult] raise @types.LoadError {
  @feature.lucas_kanade_16(arg0, arg1, arg2, window_size~, max_iter~)
}

///|
pub fn lucas_kanade_f(
  arg0 : @types.ImageF,
  arg1 : @types.ImageF,
  arg2 : Array[(Int, Int)],
  window_size? : Int = 15,
  max_iter? : Int = 20,
) -> Array[@feature.FlowResult] raise @types.LoadError {
  @feature.lucas_kanade_f(arg0, arg1, arg2, window_size~, max_iter~)
}

///|
/// Horn-Schunck 密集光流
pub fn horn_schunck(
  arg0 : @types.Image,
  arg1 : @types.Image,
  alpha? : Float = 1.0F,
  iterations? : Int = 100,
) -> (Array[Float], Array[Float]) raise @types.LoadError {
  @feature.horn_schunck(arg0, arg1, alpha~, iterations~)
}

///|
pub fn horn_schunck_16(
  arg0 : @types.Image16,
  arg1 : @types.Image16,
  alpha? : Float = 1.0F,
  iterations? : Int = 100,
) -> (Array[Float], Array[Float]) raise @types.LoadError {
  @feature.horn_schunck_16(arg0, arg1, alpha~, iterations~)
}

///|
pub fn horn_schunck_f(
  arg0 : @types.ImageF,
  arg1 : @types.ImageF,
  alpha? : Float = 1.0F,
  iterations? : Int = 100,
) -> (Array[Float], Array[Float]) raise @types.LoadError {
  @feature.horn_schunck_f(arg0, arg1, alpha~, iterations~)
}

///|
/// SIFT 特征检测
pub fn sift_detect(
  arg0 : @types.Image,
  max_features? : Int = 500,
  contrast_threshold? : Float = 0.04F,
) -> Array[@feature.SiftDescriptor] raise @types.LoadError {
  @feature.sift_detect(arg0, max_features~, contrast_threshold~)
}

///|
pub fn sift_detect_16(
  arg0 : @types.Image16,
  max_features? : Int = 500,
  contrast_threshold? : Float = 0.04F,
) -> Array[@feature.SiftDescriptor] raise @types.LoadError {
  @feature.sift_detect_16(arg0, max_features~, contrast_threshold~)
}

///|
pub fn sift_detect_f(
  arg0 : @types.ImageF,
  max_features? : Int = 500,
  contrast_threshold? : Float = 0.04F,
) -> Array[@feature.SiftDescriptor] raise @types.LoadError {
  @feature.sift_detect_f(arg0, max_features~, contrast_threshold~)
}

///|
/// SIFT 描述子匹配
pub fn sift_match(
  arg0 : Array[@feature.SiftDescriptor],
  arg1 : Array[@feature.SiftDescriptor],
  max_distance? : Float = 300.0F,
  ratio_test? : Float = 0.75F,
) -> Array[@feature.SiftMatch] {
  @feature.sift_match(arg0, arg1, max_distance~, ratio_test~)
}

///|
/// RANSAC 单应性矩阵估计
pub fn ransac_homography(
  arg0 : Array[((Float, Float), (Float, Float))],
  iterations? : Int = 1000,
  threshold? : Float = 3.0F,
) -> Array[Float]? {
  @feature.ransac_homography(arg0, iterations~, threshold~)
}

///|
/// 流式解码：逐行回调处理
pub fn decode_stream(
  arg0 : Bytes,
  arg1 : (Int, Array[Byte]) -> Unit,
) -> @lib.StreamInfo raise @types.LoadError {
  @lib.decode_stream(arg0, arg1)
}

///|
/// 分块流式解码
pub fn decode_stream_chunked(
  arg0 : Bytes,
  arg1 : Int,
  arg2 : (Int, @types.Image) -> Unit,
) -> @lib.StreamInfo raise @types.LoadError {
  @lib.decode_stream_chunked(arg0, arg1, arg2)
}

///|
/// 流式解码（带 req_channels）
pub fn decode_stream_channels(
  arg0 : Bytes,
  arg1 : Int,
  arg2 : (Int, Array[Byte]) -> Unit,
) -> @lib.StreamInfo raise @types.LoadError {
  @lib.decode_stream_channels(arg0, arg1, arg2)
}

///|
pub fn hough_lines(
  arg0 : @types.Image,
  arg1 : Int,
  theta_resolution? : Float = 1.0F,
  rho_resolution? : Float = 1.0F,
) -> Array[@edge.HoughLine] raise @types.LoadError {
  @edge.hough_lines(arg0, arg1, theta_resolution~, rho_resolution~)
}

///|
pub fn hough_lines_16(
  arg0 : @types.Image16,
  arg1 : Int,
  theta_resolution? : Float = 1.0F,
  rho_resolution? : Float = 1.0F,
) -> Array[@edge.HoughLine] raise @types.LoadError {
  @edge.hough_lines_16(arg0, arg1, theta_resolution~, rho_resolution~)
}

///|
pub fn hough_lines_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  theta_resolution? : Float = 1.0F,
  rho_resolution? : Float = 1.0F,
) -> Array[@edge.HoughLine] raise @types.LoadError {
  @edge.hough_lines_f(arg0, arg1, theta_resolution~, rho_resolution~)
}

///|
pub fn hough_lines_nms(
  arg0 : Array[@edge.HoughLine],
  rho_threshold? : Float = 5.0F,
  theta_threshold? : Float = 0.1F,
) -> Array[@edge.HoughLine] {
  @edge.hough_lines_nms(arg0, rho_threshold~, theta_threshold~)
}

///|
pub let find_contours : (@types.Image) -> Array[@edge.Contour] raise @types.LoadError = @edge.find_contours
pub let find_contours_16 : (@types.Image16) -> Array[@edge.Contour] raise @types.LoadError = @edge.find_contours_16
pub let find_contours_f : (@types.ImageF) -> Array[@edge.Contour] raise @types.LoadError = @edge.find_contours_f

///|
pub let floyd_steinberg : (@types.Image, Int) -> @types.Image = @color.floyd_steinberg
pub let floyd_steinberg_16 : (@types.Image16, Int) -> @types.Image16 = @color.floyd_steinberg_16
pub let floyd_steinberg_f : (@types.ImageF, Int) -> @types.ImageF = @color.floyd_steinberg_f

///|
pub let glcm_features : (Array[Array[Int]]) -> @feature.GlcmFeatures = @feature.glcm_features

///|
pub fn glcm_features_multi_direction(
  arg0 : @types.Image,
  levels? : Int = 256,
) -> Array[@feature.GlcmFeatures] raise @types.LoadError {
  @feature.glcm_features_multi_direction(arg0, levels~)
}

///|
pub fn glcm_features_multi_direction_16(
  arg0 : @types.Image16,
  levels? : Int = 256,
) -> Array[@feature.GlcmFeatures] raise @types.LoadError {
  @feature.glcm_features_multi_direction_16(arg0, levels~)
}

///|
pub fn glcm_features_multi_direction_f(
  arg0 : @types.ImageF,
  levels? : Int = 256,
) -> Array[@feature.GlcmFeatures] raise @types.LoadError {
  @feature.glcm_features_multi_direction_f(arg0, levels~)
}

///|
pub fn gabor_filter(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Float,
  arg3 : Float,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
  phi? : Float = 0.0F,
) -> @types.Image raise @types.LoadError {
  @feature.gabor_filter(arg0, arg1, arg2, arg3, lambda~, gamma~, phi~)
}

///|
pub fn gabor_filter_16(
  arg0 : @types.Image16,
  arg1 : Int,
  arg2 : Float,
  arg3 : Float,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
  phi? : Float = 0.0F,
) -> @types.Image16 raise @types.LoadError {
  @feature.gabor_filter_16(arg0, arg1, arg2, arg3, lambda~, gamma~, phi~)
}

///|
pub fn gabor_filter_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  arg2 : Float,
  arg3 : Float,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
  phi? : Float = 0.0F,
) -> @types.ImageF raise @types.LoadError {
  @feature.gabor_filter_f(arg0, arg1, arg2, arg3, lambda~, gamma~, phi~)
}

///|
pub fn gabor_filter_bank(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Float,
  num_orientations? : Int = 4,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
) -> @types.Image raise @types.LoadError {
  @feature.gabor_filter_bank(
    arg0,
    arg1,
    arg2,
    num_orientations~,
    lambda~,
    gamma~,
  )
}

///|
pub fn gabor_filter_bank_16(
  arg0 : @types.Image16,
  arg1 : Int,
  arg2 : Float,
  num_orientations? : Int = 4,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
) -> @types.Image16 raise @types.LoadError {
  @feature.gabor_filter_bank_16(
    arg0,
    arg1,
    arg2,
    num_orientations~,
    lambda~,
    gamma~,
  )
}

///|
pub fn gabor_filter_bank_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  arg2 : Float,
  num_orientations? : Int = 4,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
) -> @types.ImageF raise @types.LoadError {
  @feature.gabor_filter_bank_f(
    arg0,
    arg1,
    arg2,
    num_orientations~,
    lambda~,
    gamma~,
  )
}

///|
pub fn gabor_kernel(
  arg1 : Int,
  arg2 : Float,
  arg3 : Float,
  lambda? : Float = 10.0F,
  gamma? : Float = 0.5F,
  phi? : Float = 0.0F,
) -> Array[Array[Float]] raise @types.LoadError {
  @feature.gabor_kernel(arg1, arg2, arg3, lambda~, gamma~, phi~)
}

///|
pub let gaussian_blur : (@types.Image, Int, Float) -> @types.Image = @filter.gaussian_blur

///|
pub let gaussian_blur_16 : (@types.Image16, Int, Float) -> @types.Image16 = @filter.gaussian_blur_16

///|
pub let gaussian_blur_f : (@types.ImageF, Int, Float) -> @types.ImageF = @filter.gaussian_blur_f

///|
pub let median_blur : (@types.Image, Int) -> @types.Image = @filter.median_blur

///|
pub let median_blur_16 : (@types.Image16, Int) -> @types.Image16 = @filter.median_blur_16

///|
pub let median_blur_f : (@types.ImageF, Int) -> @types.ImageF = @filter.median_blur_f

///|
pub let ihaar_transform_1d : (Array[Float]) -> Array[Float] = @frequency.ihaar_transform_1d

///|
pub let haar_inverse_transform_2d : (@frequency.HaarWaveletResult) -> @types.Image = @frequency.haar_inverse_transform_2d
pub let haar_inverse_transform_2d_16 : (@frequency.HaarWaveletResult) -> @types.Image16 = @frequency.haar_inverse_transform_2d_16
pub let haar_inverse_transform_2d_f : (@frequency.HaarWaveletResult) -> @types.ImageF = @frequency.haar_inverse_transform_2d_f

///|
pub let haar_transform_1d : (Array[Float]) -> Array[Float] = @frequency.haar_transform_1d

///|
pub fn haar_transform_2d(
  arg0 : @types.Image,
  levels? : Int = 1,
) -> @frequency.HaarWaveletResult raise @types.LoadError {
  @frequency.haar_transform_2d(arg0, levels~)
}

///|
pub fn haar_transform_2d_16(
  arg0 : @types.Image16,
  levels? : Int = 1,
) -> @frequency.HaarWaveletResult raise @types.LoadError {
  @frequency.haar_transform_2d_16(arg0, levels~)
}

///|
pub fn haar_transform_2d_f(
  arg0 : @types.ImageF,
  levels? : Int = 1,
) -> @frequency.HaarWaveletResult raise @types.LoadError {
  @frequency.haar_transform_2d_f(arg0, levels~)
}

///|
pub fn haar_denoise(
  arg0 : @types.Image,
  threshold? : Float = 10.0F,
  soft? : Bool = true,
  levels? : Int = 3,
) -> @types.Image raise @types.LoadError {
  @frequency.haar_denoise(arg0, threshold~, soft~, levels~)
}

///|
pub fn haar_denoise_16(
  arg0 : @types.Image16,
  threshold? : Float = 10.0F,
  soft? : Bool = true,
  levels? : Int = 3,
) -> @types.Image16 raise @types.LoadError {
  @frequency.haar_denoise_16(arg0, threshold~, soft~, levels~)
}

///|
pub fn haar_denoise_f(
  arg0 : @types.ImageF,
  threshold? : Float = 10.0F,
  soft? : Bool = true,
  levels? : Int = 3,
) -> @types.ImageF raise @types.LoadError {
  @frequency.haar_denoise_f(arg0, threshold~, soft~, levels~)
}

///|
pub let histogram : (@types.Image) -> Array[Int] = @feature.histogram
pub let histogram_16 : (@types.Image16) -> Array[Int] = @feature.histogram_16
pub let histogram_f : (@types.ImageF) -> Array[Int] = @feature.histogram_f

///|
pub let histogram_equalize : (@types.Image) -> @types.Image = @feature.histogram_equalize
pub let histogram_equalize_16 : (@types.Image16) -> @types.Image16 = @feature.histogram_equalize_16
pub let histogram_equalize_f : (@types.ImageF) -> @types.ImageF = @feature.histogram_equalize_f

///|
pub let histogram_normalize : (@types.Image) -> @types.Image = @feature.histogram_normalize
pub let histogram_normalize_16 : (@types.Image16) -> @types.Image16 = @feature.histogram_normalize_16
pub let histogram_normalize_f : (@types.ImageF) -> @types.ImageF = @feature.histogram_normalize_f

///|
pub let ahash : (@types.Image) -> Array[Int] = @feature.ahash
pub let ahash_16 : (@types.Image16) -> Array[Int] = @feature.ahash_16
pub let ahash_f : (@types.ImageF) -> Array[Int] = @feature.ahash_f

///|
pub let dhash : (@types.Image) -> Array[Int] = @feature.dhash
pub let dhash_16 : (@types.Image16) -> Array[Int] = @feature.dhash_16
pub let dhash_f : (@types.ImageF) -> Array[Int] = @feature.dhash_f

///|
pub let phash : (@types.Image) -> Array[Int] = @feature.phash
pub let phash_16 : (@types.Image16) -> Array[Int] = @feature.phash_16
pub let phash_f : (@types.ImageF) -> Array[Int] = @feature.phash_f

///|
pub let hamming_distance : (Array[Int], Array[Int]) -> Int = @feature.hamming_distance

///|
pub let dct_2d : (@types.Image) -> Array[Array[Double]] = @frequency.dct_2d
pub let dct_2d_16 : (@types.Image16) -> Array[Array[Double]] = @frequency.dct_2d_16
pub let dct_2d_f : (@types.ImageF) -> Array[Array[Double]] = @frequency.dct_2d_f

///|
pub let idct_2d : (Array[Array[Double]]) -> @types.Image = @frequency.idct_2d
pub let idct_2d_16 : (Array[Array[Double]]) -> @types.Image16 = @frequency.idct_2d_16
pub let idct_2d_f : (Array[Array[Double]]) -> @types.ImageF = @frequency.idct_2d_f

///|
pub fn reinhard_tonemap(
  imgf : @types.ImageF,
  key? : Float = 0.18F,
) -> @types.Image {
  @color.reinhard_tonemap(imgf, key~)
}

///|
pub fn reinhard_tonemap_16(
  imgf : @types.ImageF,
  key? : Float = 0.18F,
) -> @types.Image16 {
  @color.reinhard_tonemap_16(imgf, key~)
}

///|
pub fn reinhard_tonemap_f(
  imgf : @types.ImageF,
  key? : Float = 0.18F,
) -> @types.ImageF {
  @color.reinhard_tonemap_f(imgf, key~)
}

///|
pub let gamma_tonemap : (@types.ImageF, Float) -> @types.Image = @color.gamma_tonemap
pub let gamma_tonemap_16 : (@types.ImageF, Float) -> @types.Image16 = @color.gamma_tonemap_16
pub let gamma_tonemap_f : (@types.ImageF, Float) -> @types.ImageF = @color.gamma_tonemap_f

///|
pub fn good_features_to_track(
  img : @types.Image,
  max_corners : Int,
  quality_level : Float,
  min_distance? : Int = 5,
) -> Array[@feature.CornerPoint] raise @types.LoadError {
  @feature.good_features_to_track(
    img,
    max_corners,
    quality_level,
    min_distance~,
  )
}

///|
pub fn good_features_to_track_16(
  img : @types.Image16,
  max_corners : Int,
  quality_level : Float,
  min_distance? : Int = 5,
) -> Array[@feature.CornerPoint] raise @types.LoadError {
  @feature.good_features_to_track_16(
    img,
    max_corners,
    quality_level,
    min_distance~,
  )
}

///|
pub fn good_features_to_track_f(
  img : @types.ImageF,
  max_corners : Int,
  quality_level : Float,
  min_distance? : Int = 5,
) -> Array[@feature.CornerPoint] raise @types.LoadError {
  @feature.good_features_to_track_f(
    img,
    max_corners,
    quality_level,
    min_distance~,
  )
}

///|
pub type HistCompareMethod = @feature.HistCompareMethod

///|
pub let compare_hist : (Array[Int], Array[Int], @feature.HistCompareMethod) -> Float = @feature.compare_hist

///|
pub let histogram_matching : (@types.Image, @types.Image) -> @types.Image = @feature.histogram_matching
pub let histogram_matching_16 : (@types.Image16, @types.Image16) -> @types.Image16 = @feature.histogram_matching_16
pub let histogram_matching_f : (@types.ImageF, @types.ImageF) -> @types.ImageF = @feature.histogram_matching_f

///|
pub let hsl_to_rgb : (Float, Float, Float) -> (Int, Int, Int) = @color.hsl_to_rgb
pub let hsl_to_rgb_16 : (Float, Float, Float) -> (Int, Int, Int) = @color.hsl_to_rgb_16
pub let hsl_to_rgb_f : (Float, Float, Float) -> (Float, Float, Float) = @color.hsl_to_rgb_f

///|
pub let hsv_to_rgb : (Float, Float, Float) -> (Int, Int, Int) = @color.hsv_to_rgb
pub let hsv_to_rgb_16 : (Float, Float, Float) -> (Int, Int, Int) = @color.hsv_to_rgb_16
pub let hsv_to_rgb_f : (Float, Float, Float) -> (Float, Float, Float) = @color.hsv_to_rgb_f

///|
pub let ifft_2d : (@frequency.FFTResult) -> @types.Image = @frequency.ifft_2d
pub let ifft_2d_16 : (@frequency.FFTResult) -> @types.Image16 = @frequency.ifft_2d_16
pub let ifft_2d_f : (@frequency.FFTResult) -> @types.ImageF = @frequency.ifft_2d_f

///|
pub let integral_image : (@types.Image) -> @feature.IntegralImage raise @types.LoadError = @feature.integral_image
pub let integral_image_16 : (@types.Image16) -> @feature.IntegralImage raise @types.LoadError = @feature.integral_image_16
pub let integral_image_f : (@types.ImageF) -> @feature.IntegralImage raise @types.LoadError = @feature.integral_image_f

///|
pub let integral_image_sq : (@types.Image) -> @feature.IntegralImageSq raise @types.LoadError = @feature.integral_image_sq
pub let integral_image_sq_16 : (@types.Image16) -> @feature.IntegralImageSq raise @types.LoadError = @feature.integral_image_sq_16
pub let integral_image_sq_f : (@types.ImageF) -> @feature.IntegralImageSq raise @types.LoadError = @feature.integral_image_sq_f

///|
pub let integral_mean : (@feature.IntegralImage, Int, Int, Int, Int) -> Float = @feature.integral_mean

///|
pub let integral_sum : (@feature.IntegralImage, Int, Int, Int, Int) -> Int64 = @feature.integral_sum

///|
pub let integral_sum_sq : (@feature.IntegralImageSq, Int, Int, Int, Int) -> Int64 = @feature.integral_sum_sq

///|
pub let integral_variance : (
  @feature.IntegralImage,
  @feature.IntegralImageSq,
  Int,
  Int,
  Int,
  Int,
) -> Float = @feature.integral_variance

///|
pub let invert : (@types.Image) -> @types.Image = @color.invert
pub let invert_16 : (@types.Image16) -> @types.Image16 = @color.invert_16
pub let invert_f : (@types.ImageF) -> @types.ImageF = @color.invert_f

///|
pub let kmeans_quantize : (@types.Image, Int, Int) -> @types.Image raise @types.LoadError = @color.kmeans_quantize
pub let kmeans_quantize_16 : (@types.Image16, Int, Int) -> @types.Image16 raise @types.LoadError = @color.kmeans_quantize_16
pub let kmeans_quantize_f : (@types.ImageF, Int, Int) -> @types.ImageF raise @types.LoadError = @color.kmeans_quantize_f

///|
pub fn kmeans_segment(
  arg0 : @types.Image,
  arg1 : Int,
  max_iters? : Int = 20,
) -> (@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError {
  @segment.kmeans_segment(arg0, arg1, max_iters~)
}

///|
pub fn kmeans_segment_16(
  arg0 : @types.Image16,
  arg1 : Int,
  max_iters? : Int = 20,
) -> (@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError {
  @segment.kmeans_segment_16(arg0, arg1, max_iters~)
}

///|
pub fn kmeans_segment_f(
  arg0 : @types.ImageF,
  arg1 : Int,
  max_iters? : Int = 20,
) -> (@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError {
  @segment.kmeans_segment_f(arg0, arg1, max_iters~)
}

///|
pub let lbp : (@types.Image) -> @types.Image raise @types.LoadError = @feature.lbp
pub let lbp_16 : (@types.Image16) -> @types.Image16 raise @types.LoadError = @feature.lbp_16
pub let lbp_f : (@types.ImageF) -> @types.ImageF raise @types.LoadError = @feature.lbp_f

///|
pub let lbp_uniform : (@types.Image) -> @types.Image raise @types.LoadError = @feature.lbp_uniform
pub let lbp_uniform_16 : (@types.Image16) -> @types.Image16 raise @types.LoadError = @feature.lbp_uniform_16
pub let lbp_uniform_f : (@types.ImageF) -> @types.ImageF raise @types.LoadError = @feature.lbp_uniform_f

///|
pub fn nlm_denoise(
  arg0 : @types.Image,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
) -> @types.Image raise @types.LoadError {
  @filter.nlm_denoise(arg0, patch_size~, search_size~, h~)
}

///|
pub fn nlm_denoise_fast(
  arg0 : @types.Image,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
  step? : Int = 2,
) -> @types.Image raise @types.LoadError {
  @filter.nlm_denoise_fast(arg0, patch_size~, search_size~, h~, step~)
}

///|
pub fn nlm_denoise_16(
  arg0 : @types.Image16,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
) -> @types.Image16 raise @types.LoadError {
  @filter.nlm_denoise_16(arg0, patch_size~, search_size~, h~)
}

///|
pub fn nlm_denoise_fast_16(
  arg0 : @types.Image16,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
  step? : Int = 2,
) -> @types.Image16 raise @types.LoadError {
  @filter.nlm_denoise_fast_16(arg0, patch_size~, search_size~, h~, step~)
}

///|
pub fn nlm_denoise_f(
  arg0 : @types.ImageF,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
) -> @types.ImageF raise @types.LoadError {
  @filter.nlm_denoise_f(arg0, patch_size~, search_size~, h~)
}

///|
pub fn nlm_denoise_fast_f(
  arg0 : @types.ImageF,
  patch_size? : Int = 3,
  search_size? : Int = 7,
  h? : Int = 10,
  step? : Int = 2,
) -> @types.ImageF raise @types.LoadError {
  @filter.nlm_denoise_fast_f(arg0, patch_size~, search_size~, h~, step~)
}

///|
pub let median_cut : (@types.Image, Int) -> @types.Image = @color.median_cut
pub let median_cut_16 : (@types.Image16, Int) -> @types.Image16 = @color.median_cut_16
pub let median_cut_f : (@types.ImageF, Int) -> @types.ImageF = @color.median_cut_f

///|
pub let morph_close : (@types.Image) -> @types.Image = @segment.morph_close
pub let morph_close_16 : (@types.Image16) -> @types.Image16 = @segment.morph_close_16
pub let morph_close_f : (@types.ImageF) -> @types.ImageF = @segment.morph_close_f

///|
pub let morph_gradient : (@types.Image) -> @types.Image = @segment.morph_gradient
pub let morph_gradient_16 : (@types.Image16) -> @types.Image16 = @segment.morph_gradient_16
pub let morph_gradient_f : (@types.ImageF) -> @types.ImageF = @segment.morph_gradient_f

///|
pub let morph_tophat : (@types.Image) -> @types.Image = @segment.morph_tophat
pub let morph_tophat_16 : (@types.Image16) -> @types.Image16 = @segment.morph_tophat_16
pub let morph_tophat_f : (@types.ImageF) -> @types.ImageF = @segment.morph_tophat_f

///|
pub let morph_blackhat : (@types.Image) -> @types.Image = @segment.morph_blackhat
pub let morph_blackhat_16 : (@types.Image16) -> @types.Image16 = @segment.morph_blackhat_16
pub let morph_blackhat_f : (@types.ImageF) -> @types.ImageF = @segment.morph_blackhat_f

///|
pub type StructuringElement = @segment.StructuringElement

///|
pub let se_rect : (Int, Int) -> @segment.StructuringElement = @segment.se_rect

///|
pub let se_cross : (Int) -> @segment.StructuringElement = @segment.se_cross

///|
pub let se_ellipse : (Int) -> @segment.StructuringElement = @segment.se_ellipse

///|
pub let erode_custom : (@types.Image, @segment.StructuringElement) -> @types.Image = @segment.erode_custom
pub let erode_custom_16 : (@types.Image16, @segment.StructuringElement) -> @types.Image16 = @segment.erode_custom_16
pub let erode_custom_f : (@types.ImageF, @segment.StructuringElement) -> @types.ImageF = @segment.erode_custom_f

///|
pub let dilate_custom : (@types.Image, @segment.StructuringElement) -> @types.Image = @segment.dilate_custom
pub let dilate_custom_16 : (@types.Image16, @segment.StructuringElement) -> @types.Image16 = @segment.dilate_custom_16
pub let dilate_custom_f : (@types.ImageF, @segment.StructuringElement) -> @types.ImageF = @segment.dilate_custom_f

///|
pub let morph_open_custom : (@types.Image, @segment.StructuringElement) -> @types.Image = @segment.morph_open_custom
pub let morph_open_custom_16 : (@types.Image16, @segment.StructuringElement) -> @types.Image16 = @segment.morph_open_custom_16
pub let morph_open_custom_f : (@types.ImageF, @segment.StructuringElement) -> @types.ImageF = @segment.morph_open_custom_f

///|
pub let morph_close_custom : (@types.Image, @segment.StructuringElement) -> @types.Image = @segment.morph_close_custom
pub let morph_close_custom_16 : (@types.Image16, @segment.StructuringElement) -> @types.Image16 = @segment.morph_close_custom_16
pub let morph_close_custom_f : (@types.ImageF, @segment.StructuringElement) -> @types.ImageF = @segment.morph_close_custom_f

///|
pub let morph_open : (@types.Image) -> @types.Image = @segment.morph_open
pub let morph_open_16 : (@types.Image16) -> @types.Image16 = @segment.morph_open_16
pub let morph_open_f : (@types.ImageF) -> @types.ImageF = @segment.morph_open_f

///|
pub let mse : (@types.Image, @types.Image) -> Double = @feature.mse
pub let mse_16 : (@types.Image16, @types.Image16) -> Double = @feature.mse_16
pub let mse_f : (@types.ImageF, @types.ImageF) -> Double = @feature.mse_f

///|
pub let premultiply_alpha : (@types.Image) -> @types.Image raise @types.LoadError = @color.premultiply_alpha
pub let premultiply_alpha_16 : (@types.Image16) -> @types.Image16 raise @types.LoadError = @color.premultiply_alpha_16
pub let premultiply_alpha_f : (@types.ImageF) -> @types.ImageF raise @types.LoadError = @color.premultiply_alpha_f

///|
pub let psnr : (@types.Image, @types.Image) -> Double = @feature.psnr
pub let psnr_16 : (@types.Image16, @types.Image16) -> Double = @feature.psnr_16
pub let psnr_f : (@types.ImageF, @types.ImageF) -> Double = @feature.psnr_f

///|
pub let pyr_down : (@types.Image) -> @types.Image raise @types.LoadError = @transform.pyr_down
pub let pyr_down_16 : (@types.Image16) -> @types.Image16 raise @types.LoadError = @transform.pyr_down_16
pub let pyr_down_f : (@types.ImageF) -> @types.ImageF raise @types.LoadError = @transform.pyr_down_f

///|
pub let pyr_up : (@types.Image) -> @types.Image raise @types.LoadError = @transform.pyr_up
pub let pyr_up_16 : (@types.Image16) -> @types.Image16 raise @types.LoadError = @transform.pyr_up_16
pub let pyr_up_f : (@types.ImageF) -> @types.ImageF raise @types.LoadError = @transform.pyr_up_f

///|
pub fn region_growing_segment(
  arg0 : @types.Image,
  arg1 : Array[(Int, Int)],
  threshold? : Int = 30,
) -> (@segment.SegmentLabelImage, Array[@segment.SegmentRegion]) raise @types.LoadError {
  @segment.region_growing_segment(arg0, arg1, threshold~)
}

///|
pub let rgb_to_hsl : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_hsl
pub let rgb_to_hsl_16 : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_hsl_16
pub let rgb_to_hsl_f : (Float, Float, Float) -> (Float, Float, Float) = @color.rgb_to_hsl_f

///|
pub let rgb_to_hsv : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_hsv
pub let rgb_to_hsv_16 : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_hsv_16
pub let rgb_to_hsv_f : (Float, Float, Float) -> (Float, Float, Float) = @color.rgb_to_hsv_f

///|
pub let rgb_to_ycbcr : (Int, Int, Int) -> (Int, Int, Int) = @color.rgb_to_ycbcr
pub let rgb_to_ycbcr_16 : (Int, Int, Int) -> (Int, Int, Int) = @color.rgb_to_ycbcr_16
pub let rgb_to_ycbcr_f : (Float, Float, Float) -> (Float, Float, Float) = @color.rgb_to_ycbcr_f

///|
pub let ycbcr_to_rgb : (Int, Int, Int) -> (Int, Int, Int) = @color.ycbcr_to_rgb
pub let ycbcr_to_rgb_16 : (Int, Int, Int) -> (Int, Int, Int) = @color.ycbcr_to_rgb_16
pub let ycbcr_to_rgb_f : (Float, Float, Float) -> (Float, Float, Float) = @color.ycbcr_to_rgb_f

///|
pub let rgb_to_xyz : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_xyz
pub let rgb_to_xyz_16 : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_xyz_16
pub let rgb_to_xyz_f : (Float, Float, Float) -> (Float, Float, Float) = @color.rgb_to_xyz_f

///|
pub let xyz_to_rgb : (Float, Float, Float) -> (Int, Int, Int) = @color.xyz_to_rgb
pub let xyz_to_rgb_16 : (Float, Float, Float) -> (Int, Int, Int) = @color.xyz_to_rgb_16
pub let xyz_to_rgb_f : (Float, Float, Float) -> (Float, Float, Float) = @color.xyz_to_rgb_f

///|
pub let rgb_to_lab : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_lab
pub let rgb_to_lab_16 : (Int, Int, Int) -> (Float, Float, Float) = @color.rgb_to_lab_16
pub let rgb_to_lab_f : (Float, Float, Float) -> (Float, Float, Float) = @color.rgb_to_lab_f

///|
pub let lab_to_rgb : (Float, Float, Float) -> (Int, Int, Int) = @color.lab_to_rgb
pub let lab_to_rgb_16 : (Float, Float, Float) -> (Int, Int, Int) = @color.lab_to_rgb_16
pub let lab_to_rgb_f : (Float, Float, Float) -> (Float, Float, Float) = @color.lab_to_rgb_f

///|
pub let rgb_to_cmyk : (Int, Int, Int) -> (Int, Int, Int, Int) = @color.rgb_to_cmyk
pub let rgb_to_cmyk_16 : (Int, Int, Int) -> (Int, Int, Int, Int) = @color.rgb_to_cmyk_16
pub let rgb_to_cmyk_f : (Float, Float, Float) -> (Float, Float, Float, Float) = @color.rgb_to_cmyk_f

///|
pub let cmyk_to_rgb : (Int, Int, Int, Int) -> (Int, Int, Int) = @color.cmyk_to_rgb
pub let cmyk_to_rgb_16 : (Int, Int, Int, Int) -> (Int, Int, Int) = @color.cmyk_to_rgb_16
pub let cmyk_to_rgb_f : (Float, Float, Float, Float) -> (Float, Float, Float) = @color.cmyk_to_rgb_f

///|
pub let apply_colormap : (@types.Image, @color.Colormap) -> @types.Image = @color.apply_colormap

///|
pub let rotate : (@types.Image, Float) -> @types.Image = @transform.rotate

///|
pub let rotate_180 : (@types.Image) -> @types.Image = @transform.rotate_180

///|
pub let rotate_270 : (@types.Image) -> @types.Image = @transform.rotate_270

///|
pub let rotate_90 : (@types.Image) -> @types.Image = @transform.rotate_90

///|
pub let rotate_90_16 : (@types.Image16) -> @types.Image16 = @transform.rotate_90_16

///|
pub let rotate_90_f : (@types.ImageF) -> @types.ImageF = @transform.rotate_90_f

///|
pub let rotate_180_16 : (@types.Image16) -> @types.Image16 = @transform.rotate_180_16

///|
pub let rotate_180_f : (@types.ImageF) -> @types.ImageF = @transform.rotate_180_f

///|
pub let rotate_270_16 : (@types.Image16) -> @types.Image16 = @transform.rotate_270_16

///|
pub let rotate_270_f : (@types.ImageF) -> @types.ImageF = @transform.rotate_270_f

///|
pub let segment_to_color : (@segment.SegmentLabelImage) -> @types.Image = @segment.segment_to_color

///|
pub let sharpen : (@types.Image, Float) -> @types.Image = @filter.sharpen
pub let sharpen_16 : (@types.Image16, Float) -> @types.Image16 = @filter.sharpen_16
pub let sharpen_f : (@types.ImageF, Float) -> @types.ImageF = @filter.sharpen_f

///|
pub fn ssr(
  arg0 : @types.Image,
  sigma? : Float = 80.0F,
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @types.Image raise @types.LoadError {
  @color.ssr(arg0, sigma~, gain~, offset~)
}

///|
pub fn ssr_16(
  arg0 : @types.Image16,
  sigma? : Float = 80.0F,
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @types.Image16 raise @types.LoadError {
  @color.ssr_16(arg0, sigma~, gain~, offset~)
}

///|
pub fn ssr_f(
  arg0 : @types.ImageF,
  sigma? : Float = 80.0F,
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @types.ImageF raise @types.LoadError {
  @color.ssr_f(arg0, sigma~, gain~, offset~)
}

///|
pub fn msr(
  arg0 : @types.Image,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @types.Image raise @types.LoadError {
  @color.msr(arg0, sigmas~, gain~, offset~)
}

///|
pub fn msr_16(
  arg0 : @types.Image16,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @types.Image16 raise @types.LoadError {
  @color.msr_16(arg0, sigmas~, gain~, offset~)
}

///|
pub fn msr_f(
  arg0 : @types.ImageF,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @types.ImageF raise @types.LoadError {
  @color.msr_f(arg0, sigmas~, gain~, offset~)
}

///|
pub fn msrcr(
  arg0 : @types.Image,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
  alpha? : Float = 125.0F,
  beta? : Float = 46.0F,
) -> @types.Image raise @types.LoadError {
  @color.msrcr(arg0, sigmas~, gain~, offset~, alpha~, beta~)
}

///|
pub fn msrcr_16(
  arg0 : @types.Image16,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
  alpha? : Float = 125.0F,
  beta? : Float = 46.0F,
) -> @types.Image16 raise @types.LoadError {
  @color.msrcr_16(arg0, sigmas~, gain~, offset~, alpha~, beta~)
}

///|
pub fn msrcr_f(
  arg0 : @types.ImageF,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
  alpha? : Float = 125.0F,
  beta? : Float = 46.0F,
) -> @types.ImageF raise @types.LoadError {
  @color.msrcr_f(arg0, sigmas~, gain~, offset~, alpha~, beta~)
}

///|
pub let ssim : (@types.Image, @types.Image) -> Double = @feature.ssim
pub let ssim_16 : (@types.Image16, @types.Image16) -> Double = @feature.ssim_16
pub let ssim_f : (@types.ImageF, @types.ImageF) -> Double = @feature.ssim_f

///|
pub let threshold_otsu : (@types.Image) -> @types.Image raise @types.LoadError = @color.threshold_otsu
pub let threshold_otsu_16 : (@types.Image16) -> @types.Image16 raise @types.LoadError = @color.threshold_otsu_16
pub let threshold_otsu_f : (@types.ImageF) -> @types.ImageF raise @types.LoadError = @color.threshold_otsu_f

///|
pub let to_grayscale : (@types.Image) -> @types.Image = @color.to_grayscale
pub let to_grayscale_16 : (@types.Image16) -> @types.Image16 = @color.to_grayscale_16
pub let to_grayscale_f : (@types.ImageF) -> @types.ImageF = @color.to_grayscale_f

///|
pub let to_rgb : (@types.Image) -> @types.Image = @color.to_rgb
pub let to_rgb_16 : (@types.Image16) -> @types.Image16 = @color.to_rgb_16
pub let to_rgb_f : (@types.ImageF) -> @types.ImageF = @color.to_rgb_f

///|
pub let to_rgba : (@types.Image) -> @types.Image = @color.to_rgba
pub let to_rgba_16 : (@types.Image16) -> @types.Image16 = @color.to_rgba_16
pub let to_rgba_f : (@types.ImageF) -> @types.ImageF = @color.to_rgba_f

///|
pub let unpremultiply_alpha : (@types.Image) -> @types.Image raise @types.LoadError = @color.unpremultiply_alpha
pub let unpremultiply_alpha_16 : (@types.Image16) -> @types.Image16 raise @types.LoadError = @color.unpremultiply_alpha_16
pub let unpremultiply_alpha_f : (@types.ImageF) -> @types.ImageF raise @types.LoadError = @color.unpremultiply_alpha_f

///|
pub let warp_affine : (
  @types.Image,
  (Float, Float, Float, Float, Float, Float),
  Int,
  Int,
) -> @types.Image = @transform.warp_affine
pub let warp_affine_16 : (
  @types.Image16,
  (Float, Float, Float, Float, Float, Float),
  Int,
  Int,
) -> @types.Image16 = @transform.warp_affine_16
pub let warp_affine_f : (
  @types.ImageF,
  (Float, Float, Float, Float, Float, Float),
  Int,
  Int,
) -> @types.ImageF = @transform.warp_affine_f

///|
pub let watershed : (@types.Image, Array[Int]) -> Array[Int] raise @types.LoadError = @segment.watershed
pub let watershed_16 : (@types.Image16, Array[Int]) -> Array[Int] raise @types.LoadError = @segment.watershed_16
pub let watershed_f : (@types.ImageF, Array[Int]) -> Array[Int] raise @types.LoadError = @segment.watershed_f

///|
pub let watershed_auto : (@types.Image) -> (Array[Int], Int) raise @types.LoadError = @segment.watershed_auto
pub let watershed_auto_16 : (@types.Image16) -> (Array[Int], Int) raise @types.LoadError = @segment.watershed_auto_16
pub let watershed_auto_f : (@types.ImageF) -> (Array[Int], Int) raise @types.LoadError = @segment.watershed_auto_f

///|
pub fn distance_transform(
  arg0 : @types.Image,
  distance_type? : Int = 2,
) -> Array[Float] raise @types.LoadError {
  @segment.distance_transform(arg0, distance_type~)
}

///|
pub let visualize_distance_transform : (Array[Float], Int, Int) -> @types.Image = @segment.visualize_distance_transform

///|
pub let skeletonize : (@types.Image) -> @types.Image raise @types.LoadError = @segment.skeletonize

///|
pub type SuperpixelResult = @segment.SuperpixelResult

///|
pub let slic : (@types.Image, Int, Int, Int) -> @segment.SuperpixelResult raise @types.LoadError = @segment.slic
pub let slic_16 : (@types.Image16, Int, Int, Int) -> @segment.SuperpixelResult raise @types.LoadError = @segment.slic_16
pub let slic_f : (@types.ImageF, Int, Int, Int) -> @segment.SuperpixelResult raise @types.LoadError = @segment.slic_f

///|
pub fn guided_filter(
  arg0 : @types.Image,
  arg1 : Array[Float],
  radius? : Int = 20,
  eps? : Float = 0.001F,
) -> Array[Float] raise @types.LoadError {
  @color.guided_filter(arg0, arg1, radius~, eps~)
}

///|
pub fn guided_filter_16(
  arg0 : @types.Image16,
  arg1 : Array[Float],
  radius? : Int = 20,
  eps? : Float = 0.001F,
) -> Array[Float] raise @types.LoadError {
  @color.guided_filter_16(arg0, arg1, radius~, eps~)
}

///|
pub fn guided_filter_f(
  arg0 : @types.ImageF,
  arg1 : Array[Float],
  radius? : Int = 20,
  eps? : Float = 0.001F,
) -> Array[Float] raise @types.LoadError {
  @color.guided_filter_f(arg0, arg1, radius~, eps~)
}

///|
pub fn flood_fill(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Int,
  arg3 : Array[Byte],
  threshold? : Int = 0,
) -> @types.Image raise @types.LoadError {
  @segment.flood_fill(arg0, arg1, arg2, arg3, threshold~)
}

///|
/// grabCut 交互式前景提取
pub fn grab_cut(
  arg0 : @types.Image,
  arg1 : Int,
  arg2 : Int,
  arg3 : Int,
  arg4 : Int,
  iterations? : Int = 5,
) -> @types.Image raise @types.LoadError {
  @segment.grab_cut(arg0, arg1, arg2, arg3, arg4, iterations~)
}

///|
pub type PerspectiveMatrix = @transform.PerspectiveMatrix

///|
pub type AffineMatrix = @transform.AffineMatrix

///|
pub type Moments = @edge.Moments

///|
pub type Circle = @edge.Circle

///|
pub let get_perspective_transform : (
  Array[(Float, Float)],
  Array[(Float, Float)],
) -> @transform.PerspectiveMatrix? = @transform.get_perspective_transform

///|
pub let warp_perspective : (
  @types.Image,
  @transform.PerspectiveMatrix,
  Int,
  Int,
) -> @types.Image = @transform.warp_perspective
pub let warp_perspective_16 : (
  @types.Image16,
  @transform.PerspectiveMatrix,
  Int,
  Int,
) -> @types.Image16 = @transform.warp_perspective_16
pub let warp_perspective_f : (
  @types.ImageF,
  @transform.PerspectiveMatrix,
  Int,
  Int,
) -> @types.ImageF = @transform.warp_perspective_f

///|
pub let get_affine_transform : (Array[(Float, Float)], Array[(Float, Float)]) -> @transform.AffineMatrix? = @transform.get_affine_transform

///|
pub let get_rotation_matrix_2d : ((Float, Float), Float, Float) -> @transform.AffineMatrix = @transform.get_rotation_matrix_2d

///|
pub let convex_hull : (Array[@edge.ContourPoint]) -> Array[@edge.ContourPoint] = @edge.convex_hull

///|
pub fn approx_poly_dp(
  points : Array[@edge.ContourPoint],
  epsilon : Float,
  closed? : Bool = true,
) -> Array[@edge.ContourPoint] {
  @edge.approx_poly_dp(points, epsilon, closed~)
}

///|
pub let image_moments : (Array[@edge.ContourPoint]) -> @edge.Moments = @edge.image_moments

///|
pub let hu_moments : (@edge.Moments) -> Array[Double] = @edge.hu_moments

///|
pub let min_enclosing_circle : (Array[@edge.ContourPoint]) -> (
  @edge.ContourPoint,
  Float,
) = @edge.min_enclosing_circle

///|
pub fn hough_circles(
  img : @types.Image,
  dp? : Int = 1,
  min_dist? : Int = 10,
  param1? : Int = 100,
  param2? : Int = 30,
  min_radius? : Int = 0,
  max_radius? : Int = 0,
) -> Array[@edge.Circle] raise @types.LoadError {
  @edge.hough_circles(
    img,
    dp~,
    min_dist~,
    param1~,
    param2~,
    min_radius~,
    max_radius~,
  )
}

///|
pub fn hough_circles_16(
  img : @types.Image16,
  dp? : Int = 1,
  min_dist? : Int = 10,
  param1? : Int = 100,
  param2? : Int = 30,
  min_radius? : Int = 0,
  max_radius? : Int = 0,
) -> Array[@edge.Circle] raise @types.LoadError {
  @edge.hough_circles_16(
    img,
    dp~,
    min_dist~,
    param1~,
    param2~,
    min_radius~,
    max_radius~,
  )
}

///|
pub fn hough_circles_f(
  img : @types.ImageF,
  dp? : Int = 1,
  min_dist? : Int = 10,
  param1? : Int = 100,
  param2? : Int = 30,
  min_radius? : Int = 0,
  max_radius? : Int = 0,
) -> Array[@edge.Circle] raise @types.LoadError {
  @edge.hough_circles_f(
    img,
    dp~,
    min_dist~,
    param1~,
    param2~,
    min_radius~,
    max_radius~,
  )
}

///|
pub fn multi_band_blend(
  img_a : @types.Image,
  img_b : @types.Image,
  mask : @types.Image,
  num_bands? : Int = 5,
) -> @types.Image raise @types.LoadError {
  @transform.multi_band_blend(img_a, img_b, mask, num_bands~)
}

///|
pub fn multi_band_blend_16(
  img_a : @types.Image16,
  img_b : @types.Image16,
  mask : @types.Image16,
  num_bands? : Int = 5,
) -> @types.Image16 raise @types.LoadError {
  @transform.multi_band_blend_16(img_a, img_b, mask, num_bands~)
}

///|
pub fn multi_band_blend_f(
  img_a : @types.ImageF,
  img_b : @types.ImageF,
  mask : @types.ImageF,
  num_bands? : Int = 5,
) -> @types.ImageF raise @types.LoadError {
  @transform.multi_band_blend_f(img_a, img_b, mask, num_bands~)
}

///|
pub let compute_energy : (@types.Image) -> Array[Double] = @transform.compute_energy

///|
pub let find_vertical_seam : (Array[Double], Int, Int) -> Array[Int] = @transform.find_vertical_seam

///|
pub let remove_vertical_seam : (@types.Image, Array[Int]) -> @types.Image = @transform.remove_vertical_seam

///|
pub let find_horizontal_seam : (Array[Double], Int, Int) -> Array[Int] = @transform.find_horizontal_seam

///|
pub let remove_horizontal_seam : (@types.Image, Array[Int]) -> @types.Image = @transform.remove_horizontal_seam

///|
pub let seam_carve_resize : (@types.Image, Int, Int) -> @types.Image raise @types.LoadError = @transform.seam_carve_resize
pub let compute_energy_16 : (@types.Image16) -> Array[Double] = @transform.compute_energy_16
pub let compute_energy_f : (@types.ImageF) -> Array[Double] = @transform.compute_energy_f
pub let remove_vertical_seam_16 : (@types.Image16, Array[Int]) -> @types.Image16 = @transform.remove_vertical_seam_16
pub let remove_vertical_seam_f : (@types.ImageF, Array[Int]) -> @types.ImageF = @transform.remove_vertical_seam_f
pub let remove_horizontal_seam_16 : (@types.Image16, Array[Int]) -> @types.Image16 = @transform.remove_horizontal_seam_16
pub let remove_horizontal_seam_f : (@types.ImageF, Array[Int]) -> @types.ImageF = @transform.remove_horizontal_seam_f
pub let seam_carve_resize_16 : (@types.Image16, Int, Int) -> @types.Image16 raise @types.LoadError = @transform.seam_carve_resize_16
pub let seam_carve_resize_f : (@types.ImageF, Int, Int) -> @types.ImageF raise @types.LoadError = @transform.seam_carve_resize_f

///|
pub let decode_qoi : (Bytes) -> @types.Image raise @types.LoadError = @codec.decode_qoi_pure

///|
pub let decode_webp : (Bytes) -> @types.Image raise @types.LoadError = @codec.decode_webp_pure
pub let decode_vp8_frame : (Bytes, Int) -> @types.Image raise @types.LoadError = @codec.decode_vp8_frame

///|
pub fn encode_webp_lossy(
  img : @types.Image,
  quality? : Int = 75,
) -> Bytes raise @types.LoadError {
  @codec.encode_webp_lossy_pure(img, quality~)
}

///|
pub let encode_gif : (@types.Image) -> Bytes raise @types.LoadError = @codec.encode_gif_pure

///|
pub let encode_gif_animation : (@types.GifAnimation) -> Bytes raise @types.LoadError = @codec.encode_gif_animation_pure

///|
pub let encode_pgm : (@types.Image) -> Bytes = @codec.encode_pgm_pure

///|
pub let encode_pnm : (@types.Image) -> Bytes = @codec.encode_pnm_pure

///|
pub let encode_ppm : (@types.Image) -> Bytes = @codec.encode_ppm_pure

///|
pub let encode_qoi : (@types.Image) -> Bytes raise @types.LoadError = @codec.encode_qoi_pure

///|
pub let decode_ico : (Bytes) -> @types.Image raise @types.LoadError = @codec.decode_ico_pure

///|
pub let encode_ico : (@types.Image) -> Bytes = @codec.encode_ico_pure

///|
pub let encode_ico_sizes : (Array[@types.Image]) -> Bytes = @codec.encode_ico_with_sizes_pure

///|
pub let decode_cur : (Bytes) -> @types.Image raise @types.LoadError = @codec.decode_cur_pure

///|
pub let encode_cur : (@types.Image) -> Bytes = @codec.encode_cur_pure

///|
pub let decode_icns : (Bytes) -> @types.Image raise @types.LoadError = @codec.decode_icns_pure

///|
pub let encode_icns : (@types.Image) -> Bytes = @codec.encode_icns_pure

///|
pub let decode_tiff : (Bytes) -> @types.Image raise @types.LoadError = @codec.decode_tiff_pure

///|
pub let encode_tiff : (@types.Image) -> Bytes raise @types.LoadError = @codec.encode_tiff_pure

///|
pub let decode_apng : (Bytes) -> @types.PngAnimation raise @types.LoadError = @codec.decode_apng_pure

///|
pub let encode_apng : (@types.PngAnimation) -> Bytes raise @types.LoadError = @codec.encode_apng_pure

// From meta/

///|
pub let read_exif_from_bytes : (Bytes) -> @meta.ExifInfo? = @meta.read_exif_from_bytes

///|
pub let create_exif_segment : (@meta.ExifInfo) -> Bytes = @meta.create_exif_segment

///|
pub let write_exif_to_bytes : (@meta.ExifInfo, Bytes) -> Bytes raise @types.LoadError = @meta.write_exif_to_bytes

///|
pub let read_png_text_chunks : (Bytes) -> Array[@meta.PngTextChunk] = @meta.read_png_text_chunks

// From util/

///|
pub let add_border : (@types.Image, Int, Int, Int, Int, Array[Byte]) -> @types.Image raise @types.LoadError = @util.add_border

///|
pub let add_noise_gaussian : (@types.Image, Float, UInt) -> @types.Image = @util.add_noise_gaussian

///|
pub let add_noise_salt_pepper : (@types.Image, Float, UInt) -> @types.Image = @util.add_noise_salt_pepper

///|
pub let apply_lut : (@types.Image, Array[Byte]) -> @types.Image raise @types.LoadError = @util.apply_lut

///|
pub let blend_darken : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_darken

///|
pub let blend_difference : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_difference

///|
pub let blend_exclusion : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_exclusion

///|
pub let blend_lighten : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_lighten

///|
pub let blend_multiply : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_multiply

///|
pub let blend_overlay : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_overlay

///|
pub let blend_screen : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_screen

///|
pub let blend_color_dodge : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_color_dodge

///|
pub let blend_color_burn : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_color_burn

///|
pub let blend_hard_light : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_hard_light

///|
pub let blend_soft_light : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_soft_light

///|
pub let blend_linear_dodge : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_linear_dodge

///|
pub let blend_linear_burn : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.blend_linear_burn

///|
pub let compute_stats : (@types.Image) -> @util.ImageStats = @util.compute_stats

///|
pub let compute_stats_16 : (@types.Image16) -> @util.ImageStats = @util.compute_stats_16

///|
pub let compute_stats_f : (@types.ImageF) -> @util.ImageStatsF = @util.compute_stats_f

///|
pub let convolve : (@types.Image, Array[Float], Float, Float) -> @types.Image raise @types.LoadError = @filter.convolve
pub let convolve_16 : (@types.Image16, Array[Float], Float, Float) -> @types.Image16 raise @types.LoadError = @filter.convolve_16
pub let convolve_f : (@types.ImageF, Array[Float], Float, Float) -> @types.ImageF raise @types.LoadError = @filter.convolve_f

///|
pub let extract_channel : (@types.Image, Int) -> @types.Image raise @types.LoadError = @util.extract_channel

///|
pub let fill_alpha : (@types.Image, Int, Byte, Byte, Byte) -> @types.Image raise @types.LoadError = @util.fill_alpha

///|
pub let flip_vertical : (@types.Image) -> @types.Image = @transform.flip_vertical
pub let flip_vertical_16 : (@types.Image16) -> @types.Image16 = @transform.flip_vertical_16
pub let flip_vertical_f : (@types.ImageF) -> @types.ImageF = @transform.flip_vertical_f

///|
pub let gradient_map : (@types.Image, Array[(Int, Byte, Byte, Byte)]) -> @types.Image raise @types.LoadError = @util.gradient_map

///|
pub let hstack : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.hstack

///|
pub let mean_value : (@types.Image) -> Float = @util.mean_value

///|
pub let mean_value_16 : (@types.Image16) -> Float = @util.mean_value_16

///|
pub let mean_value_f : (@types.ImageF) -> Float = @util.mean_value_f

///|
pub let variance_value : (@types.Image) -> Float = @util.variance_value

///|
pub let entropy_value : (@types.Image) -> Float = @util.entropy_value

///|
pub let median_value : (@types.Image) -> Int = @util.median_value

///|
pub let contrast_value : (@types.Image) -> Float = @util.contrast_value

///|
pub let brightness_value : (@types.Image) -> Float = @util.brightness_value

///|
pub let alpha_blend : (@types.Image, @types.Image, Float) -> @types.Image raise @types.LoadError = @util.alpha_blend

///|
pub let mask_blend : (@types.Image, @types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.mask_blend

///|
pub let pad : (@types.Image, Int, Int, Array[Byte]) -> @types.Image raise @types.LoadError = @util.pad

///|
pub let pixelate : (@types.Image, Int) -> @types.Image raise @types.LoadError = @util.pixelate

///|
pub let posterize : (@types.Image, Int) -> @types.Image raise @types.LoadError = @util.posterize

///|
pub let replace_color : (@types.Image, Array[Byte], Array[Byte], Int) -> @types.Image raise @types.LoadError = @util.replace_color

///|
pub let resize_to_contain : (@types.Image, Int, Int, Array[Byte]) -> @types.Image raise @types.LoadError = @transform.resize_to_contain

///|
pub let resize_to_cover : (@types.Image, Int, Int) -> @types.Image raise @types.LoadError = @transform.resize_to_cover

///|
pub let set_alpha : (@types.Image, Byte) -> @types.Image raise @types.LoadError = @util.set_alpha

///|
pub let swap_channels : (@types.Image, Int, Int) -> @types.Image raise @types.LoadError = @util.swap_channels

///|
pub let threshold : (@types.Image, Int) -> @types.Image = @util.threshold

///|
pub let tile : (@types.Image, Int, Int) -> @types.Image raise @types.LoadError = @util.tile

///|
pub let transpose : (@types.Image) -> @types.Image = @util.transpose
pub let transpose_16 : (@types.Image16) -> @types.Image16 = @transform.transpose_16
pub let transpose_f : (@types.ImageF) -> @types.ImageF = @transform.transpose_f

///|
pub let vstack : (@types.Image, @types.Image) -> @types.Image raise @types.LoadError = @util.vstack

///|
/// 图像修复（扩散法）
pub fn inpaint(
  arg0 : @types.Image,
  arg1 : @types.Image,
  iterations? : Int = 100,
) -> @types.Image raise @types.LoadError {
  @filter.inpaint(arg0, arg1, iterations~)
}

///|
/// 快速图像修复（距离加权平均）
pub fn inpaint_fast(
  arg0 : @types.Image,
  arg1 : @types.Image,
  radius? : Int = 5,
) -> @types.Image raise @types.LoadError {
  @filter.inpaint_fast(arg0, arg1, radius~)
}

///|
pub fn inpaint_16(
  arg0 : @types.Image16,
  arg1 : @types.Image16,
  iterations? : Int = 100,
) -> @types.Image16 raise @types.LoadError {
  @filter.inpaint_16(arg0, arg1, iterations~)
}

///|
pub fn inpaint_fast_16(
  arg0 : @types.Image16,
  arg1 : @types.Image16,
  radius? : Int = 5,
) -> @types.Image16 raise @types.LoadError {
  @filter.inpaint_fast_16(arg0, arg1, radius~)
}

///|
pub fn inpaint_f(
  arg0 : @types.ImageF,
  arg1 : @types.ImageF,
  iterations? : Int = 100,
) -> @types.ImageF raise @types.LoadError {
  @filter.inpaint_f(arg0, arg1, iterations~)
}

///|
pub fn inpaint_fast_f(
  arg0 : @types.ImageF,
  arg1 : @types.ImageF,
  radius? : Int = 5,
) -> @types.ImageF raise @types.LoadError {
  @filter.inpaint_fast_f(arg0, arg1, radius~)
}

// ==================== OCR 预处理模块 ====================

///|
pub type TextRegion = @ocr.TextRegion

///|
pub type TextRegionType = @ocr.TextRegionType

///|
pub type TextLine = @ocr.TextLine

///|
pub fn ocr_preprocess(
  img : @types.Image,
  binarization_method? : String = "sauvola",
) -> @types.Image raise @types.LoadError {
  @ocr.ocr_preprocess(img, binarization_method~)
}

///|
pub fn document_enhance(img : @types.Image) -> @types.Image {
  @ocr.document_enhance(img)
}

///|
pub fn shadow_removal(
  img : @types.Image,
  kernel_size? : Int = 51,
) -> @types.Image raise @types.LoadError {
  @ocr.shadow_removal(img, kernel_size~)
}

///|
pub fn background_normalization(
  img : @types.Image,
  kernel_size? : Int = 31,
) -> @types.Image raise @types.LoadError {
  @ocr.background_normalization(img, kernel_size~)
}

///|
pub fn deskew(img : @types.Image) -> @types.Image raise @types.LoadError {
  @ocr.deskew(img)
}

///|
pub fn detect_skew_angle(img : @types.Image) -> Double raise @types.LoadError {
  @ocr.detect_skew_angle(img)
}

///|
pub fn rotate_document(
  img : @types.Image,
  angle : Double,
) -> @types.Image {
  @ocr.rotate_document(img, angle)
}

///|
pub fn sauvola_threshold(
  img : @types.Image,
  window_size? : Int = 15,
  k? : Double = 0.5,
  r? : Double = 128.0,
) -> @types.Image raise @types.LoadError {
  @ocr.sauvola_threshold(img, window_size~, k~, r~)
}

///|
pub fn niblack_threshold(
  img : @types.Image,
  window_size? : Int = 15,
  k? : Double = -0.2,
) -> @types.Image raise @types.LoadError {
  @ocr.niblack_threshold(img, window_size~, k~)
}

///|
pub fn adaptive_threshold_ocr(
  img : @types.Image,
  block_size? : Int = 15,
  c? : Int = 10,
) -> @types.Image raise @types.LoadError {
  @ocr.adaptive_threshold_ocr(img, block_size~, c~)
}

///|
pub fn otsu_threshold(img : @types.Image) -> @types.Image raise @types.LoadError {
  @ocr.otsu_threshold(img)
}

///|
pub fn detect_text_regions(
  img : @types.Image,
) -> Array[@ocr.TextRegion] raise @types.LoadError {
  @ocr.detect_text_regions(img)
}

///|
pub fn segment_page(
  img : @types.Image,
) -> Array[@ocr.TextRegion] raise @types.LoadError {
  @ocr.segment_page(img)
}

///|
pub fn detect_columns(
  img : @types.Image,
) -> (Int, Array[(Int, Int)]) raise @types.LoadError {
  @ocr.detect_columns(img)
}

///|
pub fn extract_text_lines(
  img : @types.Image,
) -> Array[@types.Image] raise @types.LoadError {
  @ocr.extract_text_lines(img)
}

// ==================== OCR 文本检测模块（v7.1.0） ====================

///|
pub type OcrConnectedComponent = @ocr.OcrConnectedComponent

///|
pub type OcrConnectedComponentsResult = @ocr.OcrConnectedComponentsResult

///|
pub type ProjectionResult = @ocr.ProjectionResult

///|
pub type TextLineInfo = @ocr.TextLineInfo

///|
pub type CharSegment = @ocr.CharSegment

///|
pub fn connected_components_analysis(
  img : @types.Image,
  connectivity? : Int = 8,
) -> @ocr.OcrConnectedComponentsResult raise @types.LoadError {
  @ocr.connected_components_analysis(img, connectivity~)
}

///|
pub fn filter_components_by_area(
  result : @ocr.OcrConnectedComponentsResult,
  min_area : Int,
  max_area : Int,
) -> Array[@ocr.OcrConnectedComponent] {
  @ocr.filter_components_by_area(result, min_area, max_area)
}

///|
pub fn filter_components_by_aspect_ratio(
  result : @ocr.OcrConnectedComponentsResult,
  min_ratio : Double,
  max_ratio : Double,
) -> Array[@ocr.OcrConnectedComponent] {
  @ocr.filter_components_by_aspect_ratio(result, min_ratio, max_ratio)
}

///|
pub fn merge_adjacent_components(
  components : Array[@ocr.OcrConnectedComponent],
  max_gap : Int,
) -> Array[@ocr.OcrConnectedComponent] {
  @ocr.merge_adjacent_components(components, max_gap)
}

///|
pub fn horizontal_projection(
  img : @types.Image,
) -> @ocr.ProjectionResult raise @types.LoadError {
  @ocr.horizontal_projection(img)
}

///|
pub fn vertical_projection(
  img : @types.Image,
) -> @ocr.ProjectionResult raise @types.LoadError {
  @ocr.vertical_projection(img)
}

///|
pub fn detect_text_lines_projection(
  img : @types.Image,
  min_height? : Int = 5,
  max_gap? : Int = 3,
) -> Array[@ocr.TextLineInfo] raise @types.LoadError {
  @ocr.detect_text_lines_projection(img, min_height~, max_gap~)
}

///|
pub fn segment_chars_projection(
  img : @types.Image,
  line : @ocr.TextLineInfo,
  min_width? : Int = 2,
  max_gap? : Int = 2,
) -> Array[@ocr.CharSegment] raise @types.LoadError {
  @ocr.segment_chars_projection(img, line, min_width~, max_gap~)
}

///|
pub fn extract_text_line_image(
  img : @types.Image,
  line : @ocr.TextLineInfo,
  padding? : Int = 2,
) -> @types.Image {
  @ocr.extract_text_line_image(img, line, padding~)
}

///|
pub fn extract_char_image(
  img : @types.Image,
  char : @ocr.CharSegment,
  target_size? : Int = 32,
  padding? : Int = 2,
) -> @types.Image {
  @ocr.extract_char_image(img, char, target_size~, padding~)
}

// ==================== OCR 字符分割完善（v7.2.0） ====================

///|
pub type SplitPoint = @ocr.SplitPoint

///|
pub type DropFallResult = @ocr.DropFallResult

///|
pub fn drop_fall_segmentation(
  img : @types.Image,
  start_x? : Int = -1,
) -> @ocr.DropFallResult raise @types.LoadError {
  @ocr.drop_fall_segmentation(img, start_x~)
}

///|
pub fn detect_touching_chars(
  img : @types.Image,
  min_char_width? : Int = 8,
  max_char_width? : Int = 50,
) -> Array[Int] raise @types.LoadError {
  @ocr.detect_touching_chars(img, min_char_width~, max_char_width~)
}

///|
pub fn segment_by_connected_components(
  img : @types.Image,
  min_area? : Int = 5,
  max_area? : Int = 10000,
) -> Array[(Int, Int, Int, Int)] raise @types.LoadError {
  @ocr.segment_by_connected_components(img, min_area~, max_area~)
}

///|
pub fn merge_small_segments(
  segments : Array[(Int, Int, Int, Int)],
  min_width : Int,
  min_height : Int,
) -> Array[(Int, Int, Int, Int)] {
  @ocr.merge_small_segments(segments, min_width, min_height)
}

///|
pub fn filter_noise_segments(
  segments : Array[(Int, Int, Int, Int)],
  img_width : Int,
  img_height : Int,
  min_area_ratio? : Double = 0.001,
  max_area_ratio? : Double = 0.5,
) -> Array[(Int, Int, Int, Int)] {
  @ocr.filter_noise_segments(segments, img_width, img_height, min_area_ratio~, max_area_ratio~)
}

///|
pub fn complete_char_segmentation(
  img : @types.Image,
  min_char_width? : Int = 5,
  max_char_width? : Int = 60,
) -> Array[(Int, Int, Int, Int)] raise @types.LoadError {
  @ocr.complete_char_segmentation(img, min_char_width~, max_char_width~)
}

// ==================== OCR 特征提取（v7.3.0） ====================

///|
pub type HogFeatures = @ocr.HogFeatures

///|
pub type LbpFeatures = @ocr.LbpFeatures

///|
pub type ProjectionFeatures = @ocr.ProjectionFeatures

///|
pub type GridFeatures = @ocr.GridFeatures

///|
pub type StatisticalFeatures = @ocr.StatisticalFeatures

///|
pub fn hog_features(
  img : @types.Image,
  cell_size? : Int = 8,
  num_bins? : Int = 9,
) -> @ocr.HogFeatures raise @types.LoadError {
  @ocr.hog_features(img, cell_size~, num_bins~)
}

///|
pub fn lbp_features(
  img : @types.Image,
  radius? : Int = 1,
  num_points? : Int = 8,
  num_bins? : Int = 256,
) -> @ocr.LbpFeatures raise @types.LoadError {
  @ocr.lbp_features(img, radius~, num_points~, num_bins~)
}

///|
pub fn projection_features(
  img : @types.Image,
) -> @ocr.ProjectionFeatures raise @types.LoadError {
  @ocr.projection_features(img)
}

///|
pub fn grid_features(
  img : @types.Image,
  grid_rows? : Int = 4,
  grid_cols? : Int = 4,
) -> @ocr.GridFeatures raise @types.LoadError {
  @ocr.grid_features(img, grid_rows~, grid_cols~)
}

///|
pub fn statistical_features(
  img : @types.Image,
) -> @ocr.StatisticalFeatures raise @types.LoadError {
  @ocr.statistical_features(img)
}

///|
pub fn combined_features(
  img : @types.Image,
) -> Array[Double] raise @types.LoadError {
  @ocr.combined_features(img)
}

// ==================== OCR 简单分类器（v7.4.0） ====================

///|
pub type ClassificationResult = @ocr.ClassificationResult

///|
pub type TrainingSample = @ocr.TrainingSample

///|
pub type KnnClassifier = @ocr.KnnClassifier

///|
pub type TemplateMatcher = @ocr.TemplateMatcher

///|
pub type DistanceMetric = @ocr.DistanceMetric

///|
pub fn euclidean_distance(a : Array[Double], b : Array[Double]) -> Double {
  @ocr.euclidean_distance(a, b)
}

///|
pub fn manhattan_distance(a : Array[Double], b : Array[Double]) -> Double {
  @ocr.manhattan_distance(a, b)
}

///|
pub fn cosine_distance(a : Array[Double], b : Array[Double]) -> Double {
  @ocr.cosine_distance(a, b)
}

///|
pub fn chebyshev_distance(a : Array[Double], b : Array[Double]) -> Double {
  @ocr.chebyshev_distance(a, b)
}

///|
pub fn compute_distance(
  a : Array[Double],
  b : Array[Double],
  metric : @ocr.DistanceMetric,
) -> Double {
  @ocr.compute_distance(a, b, metric)
}

///|
pub fn knn_create(
  k? : Int = 3,
  distance_metric? : String = "euclidean",
) -> @ocr.KnnClassifier {
  @ocr.knn_create(k~, distance_metric~)
}

///|
pub fn knn_add_sample(
  classifier : @ocr.KnnClassifier,
  features : Array[Double],
  label : String,
) -> @ocr.KnnClassifier {
  @ocr.knn_add_sample(classifier, features, label)
}

///|
pub fn knn_add_samples(
  classifier : @ocr.KnnClassifier,
  samples : Array[(Array[Double], String)],
) -> @ocr.KnnClassifier {
  @ocr.knn_add_samples(classifier, samples)
}

///|
pub fn knn_predict(
  classifier : @ocr.KnnClassifier,
  features : Array[Double],
) -> @ocr.ClassificationResult {
  @ocr.knn_predict(classifier, features)
}

///|
pub fn template_matcher_create(
  distance_metric? : String = "euclidean",
) -> @ocr.TemplateMatcher {
  @ocr.template_matcher_create(distance_metric~)
}

///|
pub fn template_matcher_add(
  matcher : @ocr.TemplateMatcher,
  label : String,
  template : Array[Double],
) -> @ocr.TemplateMatcher {
  @ocr.template_matcher_add(matcher, label, template)
}

///|
pub fn template_matcher_predict(
  matcher : @ocr.TemplateMatcher,
  features : Array[Double],
) -> @ocr.ClassificationResult {
  @ocr.template_matcher_predict(matcher, features)
}

///|
pub fn normalize_features(features : Array[Double]) -> Array[Double] {
  @ocr.normalize_features(features)
}

///|
pub fn standardize_features(features : Array[Double]) -> Array[Double] {
  @ocr.standardize_features(features)
}

// ==================== OCR 数字识别（v7.5.0） ====================

///|
pub type OcrResult = @ocr.OcrResult

///|
pub type OcrCharResult = @ocr.OcrCharResult

///|
pub type DigitOcrConfig = @ocr.DigitOcrConfig

///|
pub fn digit_ocr_default_config() -> @ocr.DigitOcrConfig {
  @ocr.digit_ocr_default_config()
}

///|
pub fn generate_digit_templates() -> Array[(String, Array[Double])] {
  @ocr.generate_digit_templates()
}

///|
pub fn recognize_digits(
  img : @types.Image,
  config? : @ocr.DigitOcrConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_digits(img, config=c)
    None => @ocr.recognize_digits(img)
  }
}

// ==================== OCR 英文识别（v8.0.0） ====================

///|
pub type EnglishOcrConfig = @ocr.EnglishOcrConfig

///|
pub fn english_ocr_default_config() -> @ocr.EnglishOcrConfig {
  @ocr.english_ocr_default_config()
}

///|
pub fn generate_english_templates(
  case_sensitive? : Bool = false,
) -> Array[(String, Array[Double])] {
  @ocr.generate_english_templates(case_sensitive~)
}

///|
pub fn recognize_english(
  img : @types.Image,
  config? : @ocr.EnglishOcrConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_english(img, config=c)
    None => @ocr.recognize_english(img)
  }
}

// ==================== OCR 后处理（v8.1.0） ====================

///|
pub type PostProcessConfig = @ocr.PostProcessConfig

///|
pub type Dictionary = @ocr.Dictionary

///|
pub type NgramModel = @ocr.NgramModel

///|
pub fn postprocess_default_config() -> @ocr.PostProcessConfig {
  @ocr.postprocess_default_config()
}

///|
pub fn dictionary_create(words : Array[String]) -> @ocr.Dictionary {
  @ocr.dictionary_create(words)
}

///|
pub fn dictionary_create_common_english() -> @ocr.Dictionary {
  @ocr.dictionary_create_common_english()
}

///|
pub fn edit_distance(s1 : String, s2 : String) -> Int {
  @ocr.edit_distance(s1, s2)
}

///|
pub fn dictionary_match(
  word : String,
  dictionary : @ocr.Dictionary,
  max_distance? : Int = 2,
) -> Array[(String, Int)] {
  @ocr.dictionary_match(word, dictionary, max_distance~)
}

///|
pub fn ngram_create(
  texts : Array[String],
  n? : Int = 2,
) -> @ocr.NgramModel {
  @ocr.ngram_create(texts, n~)
}

///|
pub fn ngram_score(
  text : String,
  model : @ocr.NgramModel,
) -> Double {
  @ocr.ngram_score(text, model)
}

///|
pub fn ocr_postprocess(
  result : @ocr.OcrResult,
  config? : @ocr.PostProcessConfig,
  dictionary? : @ocr.Dictionary,
  ngram_model? : @ocr.NgramModel,
) -> @ocr.OcrResult {
  match config {
    Some(c) => match dictionary {
      Some(d) => match ngram_model {
        Some(n) => @ocr.ocr_postprocess(result, config=c, dictionary=d, ngram_model=n)
        None => @ocr.ocr_postprocess(result, config=c, dictionary=d)
      }
      None => @ocr.ocr_postprocess(result, config=c)
    }
    None => @ocr.ocr_postprocess(result)
  }
}

///|
pub fn calibrate_confidence(
  result : @ocr.OcrResult,
  factor? : Double = 1.0,
) -> @ocr.OcrResult {
  @ocr.calibrate_confidence(result, factor~)
}

// ==================== OCR 中文识别（v8.2.0） ====================

///|
pub type ChineseOcrConfig = @ocr.ChineseOcrConfig

///|
pub fn chinese_ocr_default_config() -> @ocr.ChineseOcrConfig {
  @ocr.chinese_ocr_default_config()
}

///|
pub fn generate_chinese_templates(
  char_set? : String = "common",
) -> Array[(String, Array[Double])] {
  @ocr.generate_chinese_templates(char_set~)
}

///|
pub fn recognize_chinese(
  img : @types.Image,
  config? : @ocr.ChineseOcrConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_chinese(img, config=c)
    None => @ocr.recognize_chinese(img)
  }
}

// ==================== OCR 表格识别（v8.3.0） ====================

///|
pub type TableLine = @ocr.TableLine

///|
pub type TableLineType = @ocr.TableLineType

///|
pub type TableCell = @ocr.TableCell

///|
pub type TableStructure = @ocr.TableStructure

///|
pub fn detect_horizontal_lines(
  img : @types.Image,
  min_length? : Int = 20,
  max_gap? : Int = 2,
) -> Array[@ocr.TableLine] raise @types.LoadError {
  @ocr.detect_horizontal_lines(img, min_length~, max_gap~)
}

///|
pub fn detect_vertical_lines(
  img : @types.Image,
  min_length? : Int = 20,
  max_gap? : Int = 2,
) -> Array[@ocr.TableLine] raise @types.LoadError {
  @ocr.detect_vertical_lines(img, min_length~, max_gap~)
}

///|
pub fn analyze_table_structure(
  horizontal_lines : Array[@ocr.TableLine],
  vertical_lines : Array[@ocr.TableLine],
) -> @ocr.TableStructure {
  @ocr.analyze_table_structure(horizontal_lines, vertical_lines)
}

///|
pub fn recognize_table(
  img : @types.Image,
  min_line_length? : Int = 20,
) -> @ocr.TableStructure raise @types.LoadError {
  @ocr.recognize_table(img, min_line_length~)
}

///|
pub fn extract_cell_image(
  img : @types.Image,
  cell : @ocr.TableCell,
  padding? : Int = 1,
) -> @types.Image {
  @ocr.extract_cell_image(img, cell, padding~)
}

///|
pub fn extract_all_cells(
  img : @types.Image,
  structure : @ocr.TableStructure,
  padding? : Int = 1,
) -> Array[@types.Image] {
  @ocr.extract_all_cells(img, structure, padding~)
}

// ==================== 完善中文 OCR（v9.0.0） ====================

///|
pub type AdvancedChineseOcrConfig = @ocr.AdvancedChineseOcrConfig

///|
pub type ChineseRadical = @ocr.ChineseRadical

///|
pub type ChineseCharStructure = @ocr.ChineseCharStructure

///|
pub fn advanced_chinese_ocr_default_config() -> @ocr.AdvancedChineseOcrConfig {
  @ocr.advanced_chinese_ocr_default_config()
}

///|
pub fn generate_3500_chinese_templates(
  char_set? : String = "common3500",
) -> Array[(String, Array[Double])] {
  @ocr.generate_3500_chinese_templates(char_set~)
}

///|
pub fn decompose_chinese_char(
  char : String,
) -> @ocr.ChineseCharStructure {
  @ocr.decompose_chinese_char(char)
}

///|
pub fn recognize_chinese_advanced(
  img : @types.Image,
  config? : @ocr.AdvancedChineseOcrConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_chinese_advanced(img, config=c)
    None => @ocr.recognize_chinese_advanced(img)
  }
}

// ==================== OCR 准确率提升（v9.1.0） ====================

///|
pub type TrainingDataset = @ocr.TrainingDataset

///|
pub type EnsembleConfig = @ocr.EnsembleConfig

///|
pub fn ensemble_default_config() -> @ocr.EnsembleConfig {
  @ocr.ensemble_default_config()
}

///|
pub fn dataset_create() -> @ocr.TrainingDataset {
  @ocr.dataset_create()
}

///|
pub fn dataset_add_sample(
  dataset : @ocr.TrainingDataset,
  features : Array[Double],
  label : String,
) -> @ocr.TrainingDataset {
  @ocr.dataset_add_sample(dataset, features, label)
}

///|
pub fn dataset_stats(
  dataset : @ocr.TrainingDataset,
) -> (Int, Int, Array[(String, Int)]) {
  @ocr.dataset_stats(dataset)
}

///|
pub fn augment_features(
  features : Array[Double],
  noise_level? : Double = 0.05,
) -> Array[Double] {
  @ocr.augment_features(features, noise_level~)
}

///|
pub fn hu_moments_features(
  img : @types.Image,
) -> Array[Double] raise @types.LoadError {
  @ocr.hu_moments_features(img)
}

///|
pub fn ensemble_predict(
  features : Array[Double],
  knn_classifier : @ocr.KnnClassifier,
  templates : Array[(String, Array[Double])],
  config? : @ocr.EnsembleConfig,
) -> @ocr.ClassificationResult {
  match config {
    Some(c) => @ocr.ensemble_predict(features, knn_classifier, templates, config=c)
    None => @ocr.ensemble_predict(features, knn_classifier, templates)
  }
}

///|
pub fn extract_combined_ocr_features(
  img : @types.Image,
) -> Array[Double] raise @types.LoadError {
  @ocr.extract_combined_ocr_features(img)
}

// ==================== 文档理解（v9.2.0） ====================

///|
pub type DocumentElementType = @ocr.DocumentElementType

///|
pub type DocumentElement = @ocr.DocumentElement

///|
pub type DocumentStructure = @ocr.DocumentStructure

///|
pub fn analyze_document_layout(
  img : @types.Image,
) -> @ocr.DocumentStructure raise @types.LoadError {
  @ocr.analyze_document_layout(img)
}

///|
pub fn compute_reading_order(
  elements : Array[@ocr.DocumentElement],
) -> Array[Int] {
  @ocr.compute_reading_order(elements)
}

///|
pub fn extract_title(
  structure : @ocr.DocumentStructure,
) -> String {
  @ocr.extract_title(structure)
}

///|
pub fn extract_headings(
  structure : @ocr.DocumentStructure,
) -> Array[@ocr.DocumentElement] {
  @ocr.extract_headings(structure)
}

///|
pub fn extract_paragraphs(
  structure : @ocr.DocumentStructure,
) -> Array[@ocr.DocumentElement] {
  @ocr.extract_paragraphs(structure)
}

///|
pub fn get_elements_in_reading_order(
  structure : @ocr.DocumentStructure,
) -> Array[@ocr.DocumentElement] {
  @ocr.get_elements_in_reading_order(structure)
}

///|
pub fn document_structure_stats(
  structure : @ocr.DocumentStructure,
) -> (Int, Int, Int, Int, Int) {
  @ocr.document_structure_stats(structure)
}

///|
pub fn detect_document_columns(
  img : @types.Image,
) -> Int raise @types.LoadError {
  @ocr.detect_document_columns(img)
}

///|
pub fn understand_document(
  img : @types.Image,
) -> @ocr.DocumentStructure raise @types.LoadError {
  @ocr.understand_document(img)
}

// ==================== 手写体识别（v9.3.0） ====================

///|
pub type HandwritingOcrConfig = @ocr.HandwritingOcrConfig

///|
pub fn handwriting_ocr_default_config() -> @ocr.HandwritingOcrConfig {
  @ocr.handwriting_ocr_default_config()
}

///|
pub fn generate_handwriting_templates(
  char_set? : String = "digits",
) -> Array[(String, Array[Double])] {
  @ocr.generate_handwriting_templates(char_set~)
}

///|
pub fn correct_slant(
  img : @types.Image,
  max_slant? : Double = 15.0,
) -> @types.Image {
  @ocr.correct_slant(img, max_slant~)
}

///|
pub fn recognize_handwriting(
  img : @types.Image,
  config? : @ocr.HandwritingOcrConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_handwriting(img, config=c)
    None => @ocr.recognize_handwriting(img)
  }
}

// ==================== 多语言混合识别（v9.4.0） ====================

///|
pub type LanguageType = @ocr.LanguageType

///|
pub type MultilingualOcrConfig = @ocr.MultilingualOcrConfig

///|
pub type PunctuationTemplate = @ocr.PunctuationTemplate

///|
pub fn multilingual_ocr_default_config() -> @ocr.MultilingualOcrConfig {
  @ocr.multilingual_ocr_default_config()
}

///|
pub fn generate_punctuation_templates() -> Array[@ocr.PunctuationTemplate] {
  @ocr.generate_punctuation_templates()
}

///|
pub fn detect_char_language(
  char_img : @types.Image,
) -> @ocr.LanguageType {
  @ocr.detect_char_language(char_img)
}

///|
pub fn detect_document_language(
  img : @types.Image,
) -> @ocr.LanguageType raise @types.LoadError {
  @ocr.detect_document_language(img)
}

///|
pub fn recognize_multilingual(
  img : @types.Image,
  config? : @ocr.MultilingualOcrConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_multilingual(img, config=c)
    None => @ocr.recognize_multilingual(img)
  }
}

// ==================== 中文 OCR 增强版（v10.0.0） ====================

///|
pub type EnhancedChineseOcrConfig = @ocr.EnhancedChineseOcrConfig

///|
pub type ChineseCharInfo = @ocr.ChineseCharInfo

///|
pub fn enhanced_chinese_ocr_default_config() -> @ocr.EnhancedChineseOcrConfig {
  @ocr.enhanced_chinese_ocr_default_config()
}

///|
pub fn generate_chinese_char_info_db() -> Array[@ocr.ChineseCharInfo] {
  @ocr.generate_chinese_char_info_db()
}

///|
pub fn generate_enhanced_chinese_templates(
  char_set_size? : Int = 1000,
) -> Array[(String, Array[Double])] {
  @ocr.generate_enhanced_chinese_templates(char_set_size~)
}

///|
pub fn structure_based_filter(
  char_img : @types.Image,
  char_db : Array[@ocr.ChineseCharInfo],
  max_candidates? : Int = 50,
) -> Array[@ocr.ChineseCharInfo] {
  @ocr.structure_based_filter(char_img, char_db, max_candidates~)
}

///|
pub fn extract_stroke_features(
  char_img : @types.Image,
) -> Array[Double] {
  @ocr.extract_stroke_features(char_img)
}

///|
pub fn recognize_enhanced_chinese(
  img : @types.Image,
  config? : @ocr.EnhancedChineseOcrConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_enhanced_chinese(img, config=c)
    None => @ocr.recognize_enhanced_chinese(img)
  }
}

// ==================== OCR 准确率提升增强版（v10.1.0） ====================

///|
pub type OcrAccuracyEnhancedConfig = @ocr.OcrAccuracyEnhancedConfig

///|
pub fn ocr_accuracy_enhanced_default_config() -> @ocr.OcrAccuracyEnhancedConfig {
  @ocr.ocr_accuracy_enhanced_default_config()
}

///|
pub fn extract_zernike_moments(
  char_img : @types.Image,
  max_order? : Int = 4,
) -> Array[Double] {
  @ocr.extract_zernike_moments(char_img, max_order~)
}

///|
pub fn extract_gabor_ocr_features(
  char_img : @types.Image,
  num_orientations? : Int = 4,
  num_frequencies? : Int = 2,
) -> Array[Double] {
  @ocr.extract_gabor_ocr_features(char_img, num_orientations~, num_frequencies~)
}

///|
pub fn extract_directional_features(
  char_img : @types.Image,
) -> Array[Double] {
  @ocr.extract_directional_features(char_img)
}

///|
pub fn weighted_knn_classify(
  features : Array[Double],
  training_data : Array[(String, Array[Double])],
  k? : Int = 5,
  distance_metric? : String = "euclidean",
) -> (String, Double, Array[(String, Double)]) {
  @ocr.weighted_knn_classify(features, training_data, k~, distance_metric~)
}

///|
pub fn calibrate_confidence_enhanced(
  raw_confidence : Double,
  distance_distribution : Array[Double],
) -> Double {
  @ocr.calibrate_confidence_enhanced(raw_confidence, distance_distribution)
}

///|
pub fn multi_scale_recognize(
  char_img : @types.Image,
  templates : Array[(String, Array[Double])],
  scales : Array[Int],
  distance_metric? : String = "euclidean",
) -> (String, Double) {
  @ocr.multi_scale_recognize(char_img, templates, scales, distance_metric~)
}

///|
pub fn extract_combined_enhanced_features(
  char_img : @types.Image,
  config : @ocr.OcrAccuracyEnhancedConfig,
) -> Array[Double] {
  @ocr.extract_combined_enhanced_features(char_img, config)
}

///|
pub fn recognize_ocr_enhanced(
  img : @types.Image,
  templates : Array[(String, Array[Double])],
  config? : @ocr.OcrAccuracyEnhancedConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_ocr_enhanced(img, templates, config=c)
    None => @ocr.recognize_ocr_enhanced(img, templates)
  }
}

// ==================== 文档理解增强版（v10.2.0） ====================

///|
pub type DocumentBlockType = @ocr.DocumentBlockType

///|
pub type DocumentBlock = @ocr.DocumentBlock

///|
pub type DocumentTreeNode = @ocr.DocumentTreeNode

///|
pub type DocumentUnderstandingEnhancedConfig = @ocr.DocumentUnderstandingEnhancedConfig

///|
pub fn document_understanding_enhanced_default_config() -> @ocr.DocumentUnderstandingEnhancedConfig {
  @ocr.document_understanding_enhanced_default_config()
}

///|
pub fn analyze_layout_enhanced(
  img : @types.Image,
  config? : @ocr.DocumentUnderstandingEnhancedConfig,
) -> Array[@ocr.DocumentBlock] raise @types.LoadError {
  match config {
    Some(c) => @ocr.analyze_layout_enhanced(img, config=c)
    None => @ocr.analyze_layout_enhanced(img)
  }
}

///|
pub fn optimize_reading_order(
  blocks : Array[@ocr.DocumentBlock],
  num_columns : Int,
) -> Array[Int] {
  @ocr.optimize_reading_order(blocks, num_columns)
}

///|
pub fn detect_paragraphs(
  blocks : Array[@ocr.DocumentBlock],
  max_line_spacing_ratio? : Double = 2.0,
) -> Array[Array[Int]] {
  @ocr.detect_paragraphs(blocks, max_line_spacing_ratio~)
}

///|
pub fn detect_titles(
  blocks : Array[@ocr.DocumentBlock],
  title_font_size_threshold? : Int = 24,
) -> Array[Int] {
  @ocr.detect_titles(blocks, title_font_size_threshold~)
}

///|
pub fn build_document_structure_tree(
  blocks : Array[@ocr.DocumentBlock],
) -> Array[@ocr.DocumentTreeNode] {
  @ocr.build_document_structure_tree(blocks)
}

///|
pub fn extract_document_text(
  blocks : Array[@ocr.DocumentBlock],
  include_headers? : Bool = true,
  include_footers? : Bool = false,
) -> String {
  @ocr.extract_document_text(blocks, include_headers~, include_footers~)
}

///|
pub fn document_statistics_enhanced(
  blocks : Array[@ocr.DocumentBlock],
) -> (Int, Int, Int, Int, Int, Int, Int) {
  @ocr.document_statistics_enhanced(blocks)
}

///|
pub fn understand_document_enhanced(
  img : @types.Image,
  config? : @ocr.DocumentUnderstandingEnhancedConfig,
) -> (Array[@ocr.DocumentBlock], Array[@ocr.DocumentTreeNode], String) raise @types.LoadError {
  match config {
    Some(c) => @ocr.understand_document_enhanced(img, config=c)
    None => @ocr.understand_document_enhanced(img)
  }
}

// ==================== 手写体识别增强版（v10.3.0） ====================

///|
pub type HandwritingOcrEnhancedConfig = @ocr.HandwritingOcrEnhancedConfig

///|
pub type HandwritingStrokeFeatures = @ocr.HandwritingStrokeFeatures

///|
pub fn handwriting_ocr_enhanced_default_config() -> @ocr.HandwritingOcrEnhancedConfig {
  @ocr.handwriting_ocr_enhanced_default_config()
}

///|
pub fn generate_enhanced_handwriting_templates(
  char_set? : String = "digits+letters",
  num_variants? : Int = 5,
) -> Array[(String, Array[Double])] {
  @ocr.generate_enhanced_handwriting_templates(char_set~, num_variants~)
}

///|
pub fn extract_handwriting_stroke_features(
  char_img : @types.Image,
) -> @ocr.HandwritingStrokeFeatures {
  @ocr.extract_handwriting_stroke_features(char_img)
}

///|
pub fn elastic_match(
  features : Array[Double],
  template : Array[Double],
  elasticity? : Double = 0.5,
  grid_size? : Int = 16,
) -> Double {
  @ocr.elastic_match(features, template, elasticity~, grid_size~)
}

///|
pub fn segment_cursive_chars(
  img : @types.Image,
  min_char_width? : Int = 8,
  max_char_width? : Int = 80,
) -> Array[(Int, Int, Int, Int)] {
  @ocr.segment_cursive_chars(img, min_char_width~, max_char_width~)
}

///|
pub fn handwriting_postprocess(
  text : String,
  confidence : Double,
) -> (String, Double) {
  @ocr.handwriting_postprocess(text, confidence)
}

///|
pub fn recognize_handwriting_enhanced(
  img : @types.Image,
  config? : @ocr.HandwritingOcrEnhancedConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_handwriting_enhanced(img, config=c)
    None => @ocr.recognize_handwriting_enhanced(img)
  }
}

// ==================== 多语言混合识别增强版（v10.4.0） ====================

///|
pub type MultilingualOcrEnhancedConfig = @ocr.MultilingualOcrEnhancedConfig

///|
pub type LanguageDetectionResult = @ocr.LanguageDetectionResult

///|
pub fn multilingual_ocr_enhanced_default_config() -> @ocr.MultilingualOcrEnhancedConfig {
  @ocr.multilingual_ocr_enhanced_default_config()
}

///|
pub fn detect_language_enhanced(
  char_img : @types.Image,
) -> @ocr.LanguageDetectionResult {
  @ocr.detect_language_enhanced(char_img)
}

///|
pub fn smart_segment_chars(
  img : @types.Image,
  config : @ocr.MultilingualOcrEnhancedConfig,
) -> Array[(Int, Int, Int, Int, String)] {
  @ocr.smart_segment_chars(img, config)
}

///|
pub fn smart_spacing_process(
  text : String,
  char_languages : Array[String],
) -> String {
  @ocr.smart_spacing_process(text, char_languages)
}

///|
pub fn normalize_punctuation(
  text : String,
  char_languages : Array[String],
) -> String {
  @ocr.normalize_punctuation(text, char_languages)
}

///|
pub fn language_model_postprocess(
  text : String,
  char_languages : Array[String],
  confidences : Array[Double],
) -> (String, Array[Double]) {
  @ocr.language_model_postprocess(text, char_languages, confidences)
}

///|
pub fn recognize_multilingual_enhanced(
  img : @types.Image,
  config? : @ocr.MultilingualOcrEnhancedConfig,
) -> @ocr.OcrResult raise @types.LoadError {
  match config {
    Some(c) => @ocr.recognize_multilingual_enhanced(img, config=c)
    None => @ocr.recognize_multilingual_enhanced(img)
  }
}

// ==================== 条形码/二维码识别（v11.0.0） ====================

///|
pub type BarcodeType = @barcode.BarcodeType

///|
pub type BarcodeResult = @barcode.BarcodeResult

///|
pub type BarcodeConfig = @barcode.BarcodeConfig

///|
pub type QrFinderPattern = @barcode.QrFinderPattern

///|
pub fn barcode_default_config() -> @barcode.BarcodeConfig {
  @barcode.barcode_default_config()
}

///|
pub fn decode_ean13(
  img : @types.Image,
  config? : @barcode.BarcodeConfig,
) -> @barcode.BarcodeResult? {
  match config {
    Some(c) => @barcode.decode_ean13(img, config=c)
    None => @barcode.decode_ean13(img)
  }
}

///|
pub fn detect_qr_finder_patterns(
  img : @types.Image,
) -> Array[@barcode.QrFinderPattern] {
  @barcode.detect_qr_finder_patterns(img)
}

///|
pub fn decode_qrcode(
  img : @types.Image,
  config? : @barcode.BarcodeConfig,
) -> @barcode.BarcodeResult? {
  match config {
    Some(c) => @barcode.decode_qrcode(img, config=c)
    None => @barcode.decode_qrcode(img)
  }
}

///|
pub fn decode_barcode(
  img : @types.Image,
  config? : @barcode.BarcodeConfig,
) -> Array[@barcode.BarcodeResult] {
  match config {
    Some(c) => @barcode.decode_barcode(img, config=c)
    None => @barcode.decode_barcode(img)
  }
}

// ==================== 图像拼接/全景图（v11.1.0） ====================

///|
pub type FeaturePoint = @stitch.FeaturePoint

///|
pub type MatchPair = @stitch.MatchPair

///|
pub type Homography = @stitch.Homography

///|
pub type StitchConfig = @stitch.StitchConfig

///|
pub fn stitch_default_config() -> @stitch.StitchConfig {
  @stitch.stitch_default_config()
}

///|
pub fn identity_homography() -> @stitch.Homography {
  @stitch.identity_homography()
}

///|
pub fn apply_homography(
  h : @stitch.Homography,
  x : Double,
  y : Double,
) -> (Double, Double) {
  @stitch.apply_homography(h, x, y)
}

///|
pub fn invert_homography(
  h : @stitch.Homography,
) -> @stitch.Homography? {
  @stitch.invert_homography(h)
}

///|
pub fn detect_features_simple(
  img : @types.Image,
  max_features? : Int = 500,
) -> Array[@stitch.FeaturePoint] {
  @stitch.detect_features_simple(img, max_features~)
}

///|
pub fn match_features(
  query : Array[@stitch.FeaturePoint],
  train : Array[@stitch.FeaturePoint],
  ratio_threshold? : Double = 0.75,
) -> Array[@stitch.MatchPair] {
  @stitch.match_features(query, train, ratio_threshold~)
}

///|
pub fn estimate_homography_ransac(
  matches : Array[@stitch.MatchPair],
  query_points : Array[@stitch.FeaturePoint],
  train_points : Array[@stitch.FeaturePoint],
  iterations? : Int = 1000,
  threshold? : Double = 3.0,
) -> (@stitch.Homography?, Array[@stitch.MatchPair]) {
  @stitch.estimate_homography_ransac(matches, query_points, train_points, iterations~, threshold~)
}

///|
pub fn stitch_images(
  img1 : @types.Image,
  img2 : @types.Image,
  config? : @stitch.StitchConfig,
) -> @types.Image? {
  match config {
    Some(c) => @stitch.stitch_images(img1, img2, config=c)
    None => @stitch.stitch_images(img1, img2)
  }
}

// ==================== 超分辨率（v11.2.0） ====================

///|
pub type SuperResolutionConfig = @superres.SuperResolutionConfig

///|
pub fn sr_default_config() -> @superres.SuperResolutionConfig {
  @superres.sr_default_config()
}

///|
pub fn super_resolution_bicubic(
  img : @types.Image,
  scale : Double,
) -> @types.Image {
  @superres.super_resolution_bicubic(img, scale)
}

///|
pub fn super_resolution_lanczos(
  img : @types.Image,
  scale : Double,
  a? : Int = 3,
) -> @types.Image {
  @superres.super_resolution_lanczos(img, scale, a~)
}

///|
pub fn super_resolution_edge_preserving(
  img : @types.Image,
  scale : Double,
  edge_threshold? : Double = 30.0,
  sharpen_amount? : Double = 0.5,
) -> @types.Image {
  @superres.super_resolution_edge_preserving(img, scale, edge_threshold~, sharpen_amount~)
}

///|
pub fn super_resolution(
  img : @types.Image,
  config? : @superres.SuperResolutionConfig,
) -> @types.Image {
  match config {
    Some(c) => @superres.super_resolution(img, config=c)
    None => @superres.super_resolution(img)
  }
}

///|
pub fn upscale_2x(
  img : @types.Image,
) -> @types.Image {
  @superres.upscale_2x(img)
}

///|
pub fn upscale_4x(
  img : @types.Image,
) -> @types.Image {
  @superres.upscale_4x(img)
}

// ==================== 更多一维码支持（v11.3.0） ====================

///|
pub type Code128Charset = @barcode.Code128Charset

///|
pub fn decode_code128(
  img : @types.Image,
) -> @barcode.BarcodeResult? {
  @barcode.decode_code128(img)
}

///|
pub fn decode_upca(
  img : @types.Image,
) -> @barcode.BarcodeResult? {
  @barcode.decode_upca(img)
}

///|
pub fn decode_code39(
  img : @types.Image,
) -> @barcode.BarcodeResult? {
  @barcode.decode_code39(img)
}

///|
pub fn decode_linear_barcode(
  img : @types.Image,
) -> Array[@barcode.BarcodeResult] {
  @barcode.decode_linear_barcode(img)
}

// ==================== QR Code 完整解码（v11.4.0） ====================

///|
pub type QrDecodeResult = @barcode.QrDecodeResult

///|
pub fn decode_qrcode_full(
  img : @types.Image,
) -> @barcode.QrDecodeResult? {
  @barcode.decode_qrcode_full(img)
}

///|
pub fn reed_solomon_decode(
  data : Array[Int],
  ec_bytes : Int,
) -> (Array[Int], Int) {
  @barcode.reed_solomon_decode(data, ec_bytes)
}

// ==================== 图像风格化（v11.5.0） ====================

///|
pub type StylizeConfig = @stylize.StylizeConfig

///|
pub fn stylize_default_config() -> @stylize.StylizeConfig {
  @stylize.stylize_default_config()
}

///|
pub fn oil_paint(
  img : @types.Image,
  radius? : Int = 3,
  intensity? : Int = 20,
) -> @types.Image {
  @stylize.oil_paint(img, radius~, intensity~)
}

///|
pub fn sketch(
  img : @types.Image,
  blend? : Double = 0.7,
) -> @types.Image {
  @stylize.sketch(img, blend~)
}

///|
pub fn watercolor(
  img : @types.Image,
  blur_radius? : Int = 5,
) -> @types.Image {
  @stylize.watercolor(img, blur_radius~)
}

///|
pub fn cartoon(
  img : @types.Image,
  levels? : Int = 8,
  edge_threshold? : Double = 30.0,
) -> @types.Image {
  @stylize.cartoon(img, levels~, edge_threshold~)
}

///|
pub fn stylize(
  img : @types.Image,
  style : String,
  config? : @stylize.StylizeConfig,
) -> @types.Image {
  match config {
    Some(c) => @stylize.stylize(img, style, config=c)
    None => @stylize.stylize(img, style)
  }
}

// ==================== 图像去雾（v11.6.0） ====================

///|
pub type DehazeConfig = @enhance.DehazeConfig

///|
pub fn dehaze_default_config() -> @enhance.DehazeConfig {
  @enhance.dehaze_default_config()
}

///|
pub fn dark_channel(
  img : @types.Image,
  patch_size? : Int = 15,
) -> @types.Image {
  @enhance.dark_channel(img, patch_size~)
}

///|
pub fn estimate_atmospheric_light(
  img : @types.Image,
  dark : @types.Image,
  top_percent? : Int = 1000,
) -> Array[Int] {
  @enhance.estimate_atmospheric_light(img, dark, top_percent~)
}

///|
pub fn estimate_transmission(
  img : @types.Image,
  atmospheric : Array[Int],
  omega? : Double = 0.95,
  patch_size? : Int = 15,
) -> @types.Image {
  @enhance.estimate_transmission(img, atmospheric, omega~, patch_size~)
}

///|
pub fn guided_filter_image(
  input : @types.Image,
  guide : @types.Image,
  radius? : Int = 20,
  eps? : Double = 0.0001,
) -> @types.Image {
  @enhance.guided_filter_image(input, guide, radius~, eps~)
}

///|
pub fn dehaze_recover(
  img : @types.Image,
  transmission : @types.Image,
  atmospheric : Array[Int],
  t_min? : Double = 0.1,
) -> @types.Image {
  @enhance.dehaze_recover(img, transmission, atmospheric, t_min~)
}

///|
pub fn dehaze_advanced(
  img : @types.Image,
  config? : @enhance.DehazeConfig,
) -> @types.Image {
  match config {
    Some(c) => @enhance.dehaze_advanced(img, config=c)
    None => @enhance.dehaze_advanced(img)
  }
}

// ==================== HDR 高动态范围（v11.7.0） ====================

///|
pub type HdrConfig = @enhance.HdrConfig

///|
pub fn hdr_default_config() -> @enhance.HdrConfig {
  @enhance.hdr_default_config()
}

///|
pub fn hdr_fusion_average(
  images : Array[@types.Image],
) -> @types.Image? {
  @enhance.hdr_fusion_average(images)
}

///|
pub fn hdr_fusion_weighted(
  images : Array[@types.Image],
) -> @types.Image? {
  @enhance.hdr_fusion_weighted(images)
}

///|
pub fn tone_mapping_reinhard(
  img : @types.Image,
  key? : Double = 0.18,
) -> @types.Image {
  @enhance.tone_mapping_reinhard(img, key~)
}

///|
pub fn tone_mapping_gamma(
  img : @types.Image,
  gamma? : Double = 0.4545,
) -> @types.Image {
  @enhance.tone_mapping_gamma(img, gamma~)
}

///|
pub fn tone_mapping_sigmoid(
  img : @types.Image,
  strength? : Double = 5.0,
) -> @types.Image {
  @enhance.tone_mapping_sigmoid(img, strength~)
}

///|
pub fn hdr_process(
  images : Array[@types.Image],
  config? : @enhance.HdrConfig,
) -> @types.Image? {
  match config {
    Some(c) => @enhance.hdr_process(images, config=c)
    None => @enhance.hdr_process(images)
  }
}

// ==================== 图像修复（v12.0.0） ====================

///|
pub type InpaintConfig = @enhance.InpaintConfig

///|
pub fn inpaint_default_config() -> @enhance.InpaintConfig {
  @enhance.inpaint_default_config()
}

///|
pub fn inpaint_advanced(
  img : @types.Image,
  mask : @types.Image,
  radius? : Int = 5,
) -> @types.Image {
  @enhance.inpaint_advanced(img, mask, radius~)
}

///|
pub fn create_rect_mask(
  width : Int,
  height : Int,
  x : Int,
  y : Int,
  rect_w : Int,
  rect_h : Int,
) -> @types.Image {
  @enhance.create_rect_mask(width, height, x, y, rect_w, rect_h)
}

///|
pub fn remove_small_objects(
  img : @types.Image,
  max_size? : Int = 100,
) -> @types.Image {
  @enhance.remove_small_objects(img, max_size~)
}

///|
pub fn remove_watermark(
  img : @types.Image,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> @types.Image {
  @enhance.remove_watermark(img, x, y, width, height)
}

// ==================== 图像去噪（v12.1.0） ====================

///|
pub type NlmConfig = @enhance.NlmConfig

///|
pub fn nlm_default_config() -> @enhance.NlmConfig {
  @enhance.nlm_default_config()
}

///|
pub fn denoise_nlm(
  img : @types.Image,
  config? : @enhance.NlmConfig,
) -> @types.Image {
  match config {
    Some(c) => @enhance.denoise_nlm(img, config=c)
    None => @enhance.denoise_nlm(img)
  }
}

///|
pub fn denoise_bilateral(
  img : @types.Image,
  diameter? : Int = 9,
  sigma_color? : Double = 75.0,
  sigma_space? : Double = 75.0,
) -> @types.Image {
  @enhance.denoise_bilateral(img, diameter~, sigma_color~, sigma_space~)
}

///|
pub fn denoise_median(
  img : @types.Image,
  kernel_size? : Int = 3,
) -> @types.Image {
  @enhance.denoise_median(img, kernel_size~)
}

///|
pub fn denoise(
  img : @types.Image,
  method : String,
) -> @types.Image {
  @enhance.denoise(img, method)
}

// ==================== 图像分割（v12.2.0） ====================

///|
pub type SegmentationResult = @segment.SegmentationResult

///|
pub type WatershedConfig = @segment.WatershedConfig

///|
pub fn watershed_default_config() -> @segment.WatershedConfig {
  @segment.watershed_default_config()
}

///|
pub fn watershed_segment(
  img : @types.Image,
  config? : @segment.WatershedConfig,
) -> @segment.SegmentationResult {
  match config {
    Some(c) => @segment.watershed_segment(img, config=c)
    None => @segment.watershed_segment(img)
  }
}

///|
pub fn region_growing(
  img : @types.Image,
  seeds : Array[(Int, Int)],
  threshold? : Double = 30.0,
) -> @segment.SegmentationResult {
  @segment.region_growing(img, seeds, threshold~)
}

///|
pub fn segmentation_to_color(
  result : @segment.SegmentationResult,
  width : Int,
  height : Int,
) -> @types.Image {
  @segment.segmentation_to_color(result, width, height)
}

// ==================== 目标检测基础（v12.4.0） ====================

///|
pub type BoundingBox = @detection.BoundingBox

///|
pub fn bbox_new(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  score? : Double = 0.0,
  class_id? : Int = 0,
) -> @detection.BoundingBox {
  @detection.bbox_new(x, y, width, height, score~, class_id~)
}

///|
pub fn bbox_iou(
  a : @detection.BoundingBox,
  b : @detection.BoundingBox,
) -> Double {
  @detection.bbox_iou(a, b)
}

///|
pub fn nms(
  boxes : Array[@detection.BoundingBox],
  iou_threshold? : Double = 0.5,
) -> Array[@detection.BoundingBox] {
  @detection.nms(boxes, iou_threshold~)
}

///|
pub fn draw_detections(
  img : @types.Image,
  boxes : Array[@detection.BoundingBox],
) -> @types.Image {
  @detection.draw_detections(img, boxes)
}

// ==================== 图像质量评估（v12.5.0） ====================

///|
pub type QualityMetrics = @quality.QualityMetrics

///|
pub fn compute_mse(
  img1 : @types.Image,
  img2 : @types.Image,
) -> Double {
  @quality.compute_mse(img1, img2)
}

///|
pub fn compute_mae(
  img1 : @types.Image,
  img2 : @types.Image,
) -> Double {
  @quality.compute_mae(img1, img2)
}

///|
pub fn compute_psnr(
  img1 : @types.Image,
  img2 : @types.Image,
) -> Double {
  @quality.compute_psnr(img1, img2)
}

///|
pub fn compute_ssim(
  img1 : @types.Image,
  img2 : @types.Image,
) -> Double {
  @quality.compute_ssim(img1, img2)
}

///|
pub fn compute_quality_metrics(
  img1 : @types.Image,
  img2 : @types.Image,
) -> @quality.QualityMetrics {
  @quality.compute_quality_metrics(img1, img2)
}

///|
pub fn images_equal(
  img1 : @types.Image,
  img2 : @types.Image,
) -> Bool {
  @quality.images_equal(img1, img2)
}

///|
pub fn compute_diff_image(
  img1 : @types.Image,
  img2 : @types.Image,
) -> @types.Image {
  @quality.compute_diff_image(img1, img2)
}

// ==================== 图像融合（v12.6.0） ====================

///|
pub type FusionConfig = @fusion.FusionConfig

///|
pub fn fusion_default_config() -> @fusion.FusionConfig {
  @fusion.fusion_default_config()
}

///|
pub fn fuse_alpha(
  img1 : @types.Image,
  img2 : @types.Image,
  alpha? : Double = 0.5,
) -> @types.Image {
  @fusion.fuse_alpha(img1, img2, alpha~)
}

///|
pub fn fuse_multifocus(
  img1 : @types.Image,
  img2 : @types.Image,
) -> @types.Image {
  @fusion.fuse_multifocus(img1, img2)
}

///|
pub fn fuse_exposure(
  images : Array[@types.Image],
) -> @types.Image {
  @fusion.fuse_exposure(images)
}

///|
pub fn fuse_images(
  img1 : @types.Image,
  img2 : @types.Image,
  config? : @fusion.FusionConfig,
) -> @types.Image {
  match config {
    Some(c) => @fusion.fuse_images(img1, img2, config=c)
    None => @fusion.fuse_images(img1, img2)
  }
}

// ==================== 图像配准（v12.7.0） ====================

///|
pub type RegistrationResult = @registration.RegistrationResult

///|
pub type AffineTransform = @registration.AffineTransform

///|
pub fn affine_identity() -> @registration.AffineTransform {
  @registration.affine_identity()
}

///|
pub fn affine_translation(
  dx : Double,
  dy : Double,
) -> @registration.AffineTransform {
  @registration.affine_translation(dx, dy)
}

///|
pub fn affine_rotation(
  angle : Double,
) -> @registration.AffineTransform {
  @registration.affine_rotation(angle)
}

///|
pub fn affine_scale(
  sx : Double,
  sy : Double,
) -> @registration.AffineTransform {
  @registration.affine_scale(sx, sy)
}

///|
pub fn affine_compose(
  t1 : @registration.AffineTransform,
  t2 : @registration.AffineTransform,
) -> @registration.AffineTransform {
  @registration.affine_compose(t1, t2)
}

///|
pub fn affine_apply(
  t : @registration.AffineTransform,
  x : Double,
  y : Double,
) -> (Double, Double) {
  @registration.affine_apply(t, x, y)
}

///|
pub fn estimate_translation(
  img1 : @types.Image,
  img2 : @types.Image,
  max_offset? : Int = 20,
) -> @registration.RegistrationResult {
  @registration.estimate_translation(img1, img2, max_offset~)
}

///|
pub fn warp_affine_transform(
  img : @types.Image,
  transform : @registration.AffineTransform,
  out_width? : Int = 0,
  out_height? : Int = 0,
) -> @types.Image {
  @registration.warp_affine_transform(img, transform, out_width~, out_height~)
}

///|
pub fn align_images(
  img1 : @types.Image,
  img2 : @types.Image,
) -> (@types.Image, @registration.RegistrationResult) {
  @registration.align_images(img1, img2)
}

// ==================== 视频处理基础（v12.8.0） ====================

///|
pub type VideoFrames = @video.VideoFrames

///|
pub fn video_frames_new(
  frames : Array[@types.Image],
  fps? : Double = 30.0,
) -> @video.VideoFrames {
  @video.video_frames_new(frames, fps~)
}

///|
pub fn video_frame_count(
  video : @video.VideoFrames,
) -> Int {
  @video.video_frame_count(video)
}

///|
pub fn video_get_frame(
  video : @video.VideoFrames,
  index : Int,
) -> @types.Image? {
  @video.video_get_frame(video, index)
}

///|
pub fn interpolate_frames(
  frame1 : @types.Image,
  frame2 : @types.Image,
  num_frames? : Int = 1,
) -> Array[@types.Image] {
  @video.interpolate_frames(frame1, frame2, num_frames~)
}

///|
pub fn video_fade_in(
  video : @video.VideoFrames,
  duration_frames? : Int = 30,
) -> @video.VideoFrames {
  @video.video_fade_in(video, duration_frames~)
}

///|
pub fn video_fade_out(
  video : @video.VideoFrames,
  duration_frames? : Int = 30,
) -> @video.VideoFrames {
  @video.video_fade_out(video, duration_frames~)
}

///|
pub fn video_sample(
  video : @video.VideoFrames,
  interval? : Int = 2,
) -> @video.VideoFrames {
  @video.video_sample(video, interval~)
}

///|
pub fn video_reverse(
  video : @video.VideoFrames,
) -> @video.VideoFrames {
  @video.video_reverse(video)
}

///|
pub fn video_concat(
  video1 : @video.VideoFrames,
  video2 : @video.VideoFrames,
) -> @video.VideoFrames {
  @video.video_concat(video1, video2)
}

///|
pub fn create_animation(
  frames : Array[@types.Image],
  fps? : Double = 10.0,
) -> @video.VideoFrames {
  @video.create_animation(frames, fps~)
}

///|
pub fn video_frame_average(
  video : @video.VideoFrames,
) -> @types.Image {
  @video.video_frame_average(video)
}

// ==================== 3D 视觉基础（v12.9.0） ====================

///|
pub type PointCloud = @stereo3d.PointCloud

///|
pub fn point_cloud_new() -> @stereo3d.PointCloud {
  @stereo3d.point_cloud_new()
}

///|
pub fn depth_to_colormap(
  depth : @types.Image,
  colormap? : String = "jet",
) -> @types.Image {
  @stereo3d.depth_to_colormap(depth, colormap~)
}

///|
pub fn depth_to_pointcloud(
  depth : @types.Image,
  fx? : Double = 500.0,
  fy? : Double = 500.0,
  cx? : Double = 0.0,
  cy? : Double = 0.0,
  scale? : Double = 1.0,
) -> @stereo3d.PointCloud {
  @stereo3d.depth_to_pointcloud(depth, fx~, fy~, cx~, cy~, scale~)
}

///|
pub fn pointcloud_voxel_downsample(
  cloud : @stereo3d.PointCloud,
  voxel_size? : Double = 1.0,
) -> @stereo3d.PointCloud {
  @stereo3d.pointcloud_voxel_downsample(cloud, voxel_size~)
}

///|
pub fn compute_disparity(
  left : @types.Image,
  right : @types.Image,
  max_disparity? : Int = 64,
  block_size? : Int = 7,
) -> @types.Image {
  @stereo3d.compute_disparity(left, right, max_disparity~, block_size~)
}

///|
pub fn disparity_to_depth(
  disparity : @types.Image,
  baseline? : Double = 1.0,
  focal_length? : Double = 500.0,
) -> @types.Image {
  @stereo3d.disparity_to_depth(disparity, baseline~, focal_length~)
}

// ==================== 医学图像处理（v12.10.0） ====================

///|
pub type WindowLevel = @medical.WindowLevel

///|
pub fn window_level_lung() -> @medical.WindowLevel {
  @medical.window_level_lung()
}

///|
pub fn window_level_mediastinum() -> @medical.WindowLevel {
  @medical.window_level_mediastinum()
}

///|
pub fn window_level_bone() -> @medical.WindowLevel {
  @medical.window_level_bone()
}

///|
pub fn window_level_brain() -> @medical.WindowLevel {
  @medical.window_level_brain()
}

///|
pub fn apply_window_level(
  img : @types.Image,
  config : @medical.WindowLevel,
) -> @types.Image {
  @medical.apply_window_level(img, config)
}

///|
pub fn medical_colormap(
  img : @types.Image,
  colormap? : String = "hot",
) -> @types.Image {
  @medical.medical_colormap(img, colormap~)
}

///|
pub fn medical_contrast_enhance(
  img : @types.Image,
  clip_limit? : Double = 2.0,
  tile_size? : Int = 8,
) -> @types.Image {
  @medical.medical_contrast_enhance(img, clip_limit~, tile_size~)
}

///|
pub fn medical_denoise(
  img : @types.Image,
  iterations? : Int = 5,
  kappa? : Double = 30.0,
) -> @types.Image {
  @medical.medical_denoise(img, iterations~, kappa~)
}

///|
pub fn measure_distance(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  pixel_spacing? : Double = 1.0,
) -> Double {
  @medical.measure_distance(x1, y1, x2, y2, pixel_spacing~)
}

///|
pub fn measure_area(
  mask : @types.Image,
  pixel_area? : Double = 1.0,
) -> Double {
  @medical.measure_area(mask, pixel_area~)
}

// ==================== 遥感图像处理（v12.11.0） ====================

///|
pub type MultispectralImage = @remote_sensing.MultispectralImage

///|
pub fn multispectral_new(
  width : Int,
  height : Int,
  bands : Array[@types.Image],
  band_names? : Array[String] = [],
) -> @remote_sensing.MultispectralImage {
  @remote_sensing.multispectral_new(width, height, bands, band_names=band_names)
}

///|
pub fn compute_ndvi(
  nir : @types.Image,
  red : @types.Image,
) -> @types.Image {
  @remote_sensing.compute_ndvi(nir, red)
}

///|
pub fn compute_ndwi(
  green : @types.Image,
  nir : @types.Image,
) -> @types.Image {
  @remote_sensing.compute_ndwi(green, nir)
}

///|
pub fn compute_ndbi(
  swir : @types.Image,
  nir : @types.Image,
) -> @types.Image {
  @remote_sensing.compute_ndbi(swir, nir)
}

///|
pub fn compute_evi(
  nir : @types.Image,
  red : @types.Image,
  blue : @types.Image,
) -> @types.Image {
  @remote_sensing.compute_evi(nir, red, blue)
}

///|
pub fn false_color_composite(
  nir : @types.Image,
  red : @types.Image,
  green : @types.Image,
) -> @types.Image {
  @remote_sensing.false_color_composite(nir, red, green)
}

///|
pub fn true_color_composite(
  red : @types.Image,
  green : @types.Image,
  blue : @types.Image,
) -> @types.Image {
  @remote_sensing.true_color_composite(red, green, blue)
}

///|
pub fn vegetation_coverage(
  ndvi : @types.Image,
  ndvi_soil? : Double = 0.2,
  ndvi_veg? : Double = 0.8,
) -> @types.Image {
  @remote_sensing.vegetation_coverage(ndvi, ndvi_soil~, ndvi_veg~)
}

///|
pub fn land_cover_classification(
  ndvi : @types.Image,
  ndwi : @types.Image,
  ndbi : @types.Image,
) -> @types.Image {
  @remote_sensing.land_cover_classification(ndvi, ndwi, ndbi)
}

///|
pub fn classification_colormap(
  classification : @types.Image,
) -> @types.Image {
  @remote_sensing.classification_colormap(classification)
}

// ==================== 数字水印（v12.12.0） ====================

///|
pub type WatermarkConfig = @watermark.WatermarkConfig

///|
pub fn watermark_default_config() -> @watermark.WatermarkConfig {
  @watermark.watermark_default_config()
}

///|
pub fn embed_watermark_lsb(
  cover : @types.Image,
  watermark : @types.Image,
  key? : Int = 42,
) -> @types.Image {
  @watermark.embed_watermark_lsb(cover, watermark, key~)
}

///|
pub fn extract_watermark_lsb(
  stego : @types.Image,
) -> @types.Image {
  @watermark.extract_watermark_lsb(stego)
}

///|
pub fn embed_text_watermark(
  cover : @types.Image,
  text : String,
  key? : Int = 42,
) -> @types.Image {
  @watermark.embed_text_watermark(cover, text, key~)
}

///|
pub fn extract_text_watermark(
  stego : @types.Image,
  length : Int,
  key? : Int = 42,
) -> String {
  @watermark.extract_text_watermark(stego, length, key~)
}

///|
pub fn watermark_psnr(
  original : @types.Image,
  watermarked : @types.Image,
) -> Double {
  @watermark.watermark_psnr(original, watermarked)
}

///|
pub fn watermark_robustness_test(
  watermarked : @types.Image,
  original_watermark : @types.Image,
  noise_level? : Double = 10.0,
) -> Double {
  @watermark.watermark_robustness_test(watermarked, original_watermark, noise_level~)
}

///|
pub fn batch_embed_watermark(
  images : Array[@types.Image],
  watermark : @types.Image,
  key? : Int = 42,
) -> Array[@types.Image] {
  @watermark.batch_embed_watermark(images, watermark, key~)
}

// ==================== 图像检索（v12.13.0） ====================

///|
pub type ImageFeature = @retrieval.ImageFeature

///|
pub type SearchResult = @retrieval.SearchResult

///|
pub type ImageDatabase = @retrieval.ImageDatabase

///|
pub fn image_database_new() -> @retrieval.ImageDatabase {
  @retrieval.image_database_new()
}

///|
pub fn extract_image_features(
  img : @types.Image,
  image_id : String,
) -> @retrieval.ImageFeature {
  @retrieval.extract_image_features(img, image_id)
}

///|
pub fn database_add_image(
  db : @retrieval.ImageDatabase,
  feature : @retrieval.ImageFeature,
) -> @retrieval.ImageDatabase {
  @retrieval.database_add_image(db, feature)
}

///|
pub fn database_remove_image(
  db : @retrieval.ImageDatabase,
  image_id : String,
) -> @retrieval.ImageDatabase {
  @retrieval.database_remove_image(db, image_id)
}

///|
pub fn search_similar_images(
  db : @retrieval.ImageDatabase,
  query : @retrieval.ImageFeature,
  top_k? : Int = 5,
  method? : String = "cosine",
) -> Array[@retrieval.SearchResult] {
  @retrieval.search_similar_images(db, query, top_k~, method~)
}

///|
pub fn image_similarity(
  img1 : @types.Image,
  img2 : @types.Image,
  method? : String = "cosine",
) -> Double {
  @retrieval.image_similarity(img1, img2, method~)
}

///|
pub fn batch_extract_features(
  images : Array[(@types.Image, String)],
) -> Array[@retrieval.ImageFeature] {
  @retrieval.batch_extract_features(images)
}

///|
pub fn database_size(
  db : @retrieval.ImageDatabase,
) -> Int {
  @retrieval.database_size(db)
}

// ==================== 图像加密（v12.14.0） ====================

///|
pub type EncryptionConfig = @encryption.EncryptionConfig

///|
pub type EncryptionQuality = @encryption.EncryptionQuality

///|
pub fn encryption_default_config() -> @encryption.EncryptionConfig {
  @encryption.encryption_default_config()
}

///|
pub fn encrypt_image_logistic(
  img : @types.Image,
  key? : Double = 0.123456789,
  mu? : Double = 3.99,
) -> @types.Image {
  @encryption.encrypt_image_logistic(img, key~, mu~)
}

///|
pub fn decrypt_image_logistic(
  img : @types.Image,
  key? : Double = 0.123456789,
  mu? : Double = 3.99,
) -> @types.Image {
  @encryption.decrypt_image_logistic(img, key~, mu~)
}

///|
pub fn encrypt_image_xor(
  img : @types.Image,
  key : String,
) -> @types.Image {
  @encryption.encrypt_image_xor(img, key)
}

///|
pub fn decrypt_image_xor(
  img : @types.Image,
  key : String,
) -> @types.Image {
  @encryption.decrypt_image_xor(img, key)
}

///|
pub fn histogram_entropy(
  img : @types.Image,
) -> Double {
  @encryption.histogram_entropy(img)
}

///|
pub fn adjacent_correlation(
  img : @types.Image,
  direction? : String = "horizontal",
) -> Double {
  @encryption.adjacent_correlation(img, direction~)
}

///|
pub fn evaluate_encryption_quality(
  original : @types.Image,
  encrypted : @types.Image,
) -> @encryption.EncryptionQuality {
  @encryption.evaluate_encryption_quality(original, encrypted)
}

///|
pub fn key_sensitivity_test(
  img : @types.Image,
  key : Double,
  delta? : Double = 0.0000001,
) -> Double {
  @encryption.key_sensitivity_test(img, key, delta~)
}

///|
pub fn batch_encrypt(
  images : Array[@types.Image],
  key : Double,
) -> Array[@types.Image] {
  @encryption.batch_encrypt(images, key)
}

// ==================== 计算摄影增强（v12.15.0） ====================

///|
pub type LowLightConfig = @photo_enhance.LowLightConfig

///|
pub fn low_light_default_config() -> @photo_enhance.LowLightConfig {
  @photo_enhance.low_light_default_config()
}

///|
pub fn low_light_enhance(
  img : @types.Image,
  config? : @photo_enhance.LowLightConfig,
) -> @types.Image {
  match config {
    Some(cfg) => @photo_enhance.low_light_enhance(img, config=cfg)
    None => @photo_enhance.low_light_enhance(img)
  }
}

///|
pub fn deblur_motion(
  img : @types.Image,
  kernel_size? : Int = 15,
  angle? : Double = 0.0,
) -> @types.Image {
  @photo_enhance.deblur_motion(img, kernel_size~, angle~)
}

///|
pub fn color_enhance(
  img : @types.Image,
  saturation? : Double = 1.3,
  contrast? : Double = 1.1,
) -> @types.Image {
  @photo_enhance.color_enhance(img, saturation~, contrast~)
}

///|
pub fn clahe_enhance(
  img : @types.Image,
  clip_limit? : Double = 2.0,
  tile_size? : Int = 8,
) -> @types.Image {
  @photo_enhance.clahe_enhance(img, clip_limit~, tile_size~)
}

///|
pub fn white_balance(
  img : @types.Image,
) -> @types.Image {
  @photo_enhance.white_balance(img)
}

///|
pub fn batch_photo_enhance(
  images : Array[@types.Image],
  method : String,
) -> Array[@types.Image] {
  @photo_enhance.batch_photo_enhance(images, method)
}

// ==================== 扫描版文档 OCR 增强（v12.16.0） ====================

///|
pub type ScanOCRConfig = @ocr.ScanOCRConfig

///|
pub type ScanQuality = @ocr.ScanQuality

///|
pub type TextBlock = @ocr.TextBlock

///|
pub type OCRPageResult = @ocr.OCRPageResult

///|
pub fn scan_ocr_default_config() -> @ocr.ScanOCRConfig {
  @ocr.scan_ocr_default_config()
}

///|
pub fn evaluate_scan_quality(
  img : @types.Image,
) -> @ocr.ScanQuality {
  @ocr.evaluate_scan_quality(img)
}

///|
pub fn scan_document_preprocess(
  img : @types.Image,
  config : @ocr.ScanOCRConfig,
) -> @types.Image {
  @ocr.scan_document_preprocess(img, config)
}

///|
pub fn analyze_layout_scan(
  binary_img : @types.Image,
) -> Array[@ocr.TextBlock] {
  @ocr.analyze_layout_scan(binary_img)
}

///|
pub fn scan_ocr_recognize(
  img : @types.Image,
  config : @ocr.ScanOCRConfig,
) -> @ocr.OCRPageResult {
  @ocr.scan_ocr_recognize(img, config)
}

///|
pub fn batch_scan_ocr(
  images : Array[@types.Image],
  config : @ocr.ScanOCRConfig,
) -> Array[@ocr.OCRPageResult] {
  @ocr.batch_scan_ocr(images, config)
}

///|
pub fn ocr_result_to_text(
  result : @ocr.OCRPageResult,
) -> String {
  @ocr.ocr_result_to_text(result)
}

///|
pub fn ocr_result_to_hocr(
  result : @ocr.OCRPageResult,
) -> String {
  @ocr.ocr_result_to_hocr(result)
}

///|
pub fn ocr_result_to_json(
  result : @ocr.OCRPageResult,
) -> String {
  @ocr.ocr_result_to_json(result)
}
