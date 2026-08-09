# 图像处理

## 功能分类

<CardGrid :columns="3">
  <Card href="/concepts/resize" title="缩放" description="7 滤波器 × 4 边缘模式" icon="📐" />
  <Card href="/api/process-api" title="色彩调整" description="brightness/contrast/gamma/HSV/HSL" icon="🌈" />
  <Card href="/api/process-api" title="滤波" description="gaussian/bilateral/NLM 去噪" icon="🌊" />
  <Card href="/api/process-api" title="边缘检测" description="Canny/Sobel/Hough 变换" icon="📐" />
  <Card href="/api/process-api" title="特征提取" description="Harris/LBP/Gabor/GLCM" icon="🔍" />
  <Card href="/api/process-api" title="分割" description="K-means/分水岭/连通域" icon="✂️" />
</CardGrid>

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

## 相关 API

<ActionButton href="/api/process-api" text="Process API" type="brand" />
<ActionButton href="/api/pure-api" text="Pure API" type="alt" />
