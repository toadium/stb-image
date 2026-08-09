# 图像处理

## 链式处理

```moonbit
let processed = img
  |> gaussian_blur(_, 5, 1.0)
  |> adjust_contrast(_, 1.2)
  |> to_grayscale
```

## 缩放

```moonbit
let resized : Image = resize(img, 128, 128)
let resized_srgb : Image = resize_srgb(img, 256, 256, filter=CatmullROM)
```

## 色彩调整

```moonbit
let bright = adjust_brightness(img, 30)
let contrast = adjust_contrast(img, 1.5)
let gamma = adjust_gamma(img, 2.2)
let gray = to_grayscale(img)
```

## 滤波

```moonbit
let blurred = gaussian_blur(img, 5, 1.0)
let sharpened = sharpen(img, 1.5)
let edges = edge_detect_sobel(img)
let denoised = nlm_denoise(img, 7, 3, 0.1)
```

## 边缘检测

```moonbit
let canny = canny_edge(img, 50.0, 150.0)
let lines = hough_lines(canny, 180, 100)
```

## 特征提取

```moonbit
let corners = harris_corners(img, 0.04, 1000)
let lbp_img = lbp(img)
let glcm = compute_glcm(img, 1, 0)
```

## 分割

```moonbit
let segments = kmeans_segment(img, 5)
let labels = connected_components(binary_img)
```
