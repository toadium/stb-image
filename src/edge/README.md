# walkzzz/image/process/edge

> 边缘检测（Canny、Sobel、Prewitt、Laplacian）、霍夫变换、轮廓分析

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 32 |
| 公开类型 | 5 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct Circle {
pub(all) struct Contour {
pub(all) struct ContourPoint {
pub(all) struct HoughLine {
pub(all) struct Moments {
```

## API

```moonbit
pub fn approx_poly_dp(Array[ContourPoint], Float, closed? : Bool) -> Array[ContourPoint] raise @types.LoadError
pub fn canny_edge(@types.Image, low_threshold? : Int, high_threshold? : Int) -> @types.Image raise @types.LoadError
pub fn canny_edge_16(@types.Image16, low_threshold? : Int, high_threshold? : Int) -> @types.Image16 raise @types.LoadError
pub fn canny_edge_f(@types.ImageF, low_threshold? : Float, high_threshold? : Float) -> @types.ImageF raise @types.LoadError
pub fn contour_area(Contour) -> Float
pub fn contour_perimeter(Contour) -> Float
pub fn convex_hull(Array[ContourPoint]) -> Array[ContourPoint]
pub fn draw_contours(@types.Image, Array[Contour], Array[Byte]) -> @types.Image raise @types.LoadError
pub fn draw_contours_16(@types.Image16, Array[Contour], Array[Int]) -> @types.Image16 raise @types.LoadError
pub fn draw_contours_f(@types.ImageF, Array[Contour], Array[Float]) -> @types.ImageF raise @types.LoadError
pub fn edge_detect_laplacian(@types.Image) -> @types.Image raise @types.LoadError
pub fn edge_detect_laplacian_16(@types.Image16) -> @types.Image16 raise @types.LoadError
pub fn edge_detect_laplacian_f(@types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn edge_detect_prewitt(@types.Image) -> @types.Image raise @types.LoadError
pub fn edge_detect_prewitt_16(@types.Image16) -> @types.Image16 raise @types.LoadError
pub fn edge_detect_prewitt_f(@types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn edge_detect_sobel(@types.Image) -> @types.Image raise @types.LoadError
pub fn edge_detect_sobel_16(@types.Image16) -> @types.Image16 raise @types.LoadError
pub fn edge_detect_sobel_f(@types.ImageF) -> @types.ImageF raise @types.LoadError
pub fn find_contours(@types.Image) -> Array[Contour] raise @types.LoadError
pub fn find_contours_16(@types.Image16) -> Array[Contour] raise @types.LoadError
pub fn find_contours_f(@types.ImageF) -> Array[Contour] raise @types.LoadError
pub fn hough_circles(@types.Image, dp? : Int, min_dist? : Int, param1? : Int, param2? : Int, min_radius? : Int, max_radius? : Int) -> Array[Circle] raise @types.LoadError
pub fn hough_circles_16(@types.Image16, dp? : Int, min_dist? : Int, param1? : Int, param2? : Int, min_radius? : Int, max_radius? : Int) -> Array[Circle] raise @types.LoadError
pub fn hough_circles_f(@types.ImageF, dp? : Int, min_dist? : Int, param1? : Int, param2? : Int, min_radius? : Int, max_radius? : Int) -> Array[Circle] raise @types.LoadError
pub fn hough_lines(@types.Image, Int, theta_resolution? : Float, rho_resolution? : Float) -> Array[HoughLine] raise @types.LoadError
pub fn hough_lines_16(@types.Image16, Int, theta_resolution? : Float, rho_resolution? : Float) -> Array[HoughLine] raise @types.LoadError
pub fn hough_lines_f(@types.ImageF, Int, theta_resolution? : Float, rho_resolution? : Float) -> Array[HoughLine] raise @types.LoadError
pub fn hough_lines_nms(Array[HoughLine], rho_threshold? : Float, theta_threshold? : Float) -> Array[HoughLine] raise @types.LoadError
pub fn hu_moments(Moments) -> Array[Double] raise @types.LoadError
pub fn image_moments(Array[ContourPoint]) -> Moments
pub fn min_enclosing_circle(Array[ContourPoint]) -> (ContourPoint, Float)
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
