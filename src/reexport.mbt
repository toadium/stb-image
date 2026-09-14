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
