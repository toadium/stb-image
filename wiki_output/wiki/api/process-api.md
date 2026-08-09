# Process API（图像处理）

路径：`src/process/`（纯 MoonBit，依赖 core）

## transform（变换）

`crop`、`rotate_90/180/270`、`flip_horizontal`、`warp_affine`、`rotate`、`draw_copy`、`draw_over`、`pyr_down`、`pyr_up`、`build_gaussian_pyramid`、`build_laplacian_pyramid`

## color（色彩）

`to_grayscale`、`to_rgb`、`to_rgba`、`adjust_brightness/contrast/gamma`、`invert`、`rgb_to_hsv`/`hsv_to_rgb`、`rgb_to_hsl`/`hsl_to_rgb`、`clahe`、`adaptive_threshold_mean/gaussian`、`threshold_otsu`、`kmeans_segment`、`region_growing_segment`、`flood_fill`、`ssr`、`msr`、`msrcr`、`dehaze`、`guided_filter`

## filter（滤波）

`box_blur`、`gaussian_blur`、`sharpen`、`edge_detect_sobel`、`bilateral_filter`、`bilateral_filter_fast`、`nlm_denoise`、`nlm_denoise_fast`

## edge（边缘）

`edge_detect_laplacian`、`edge_detect_prewitt`、`canny_edge`、`find_contours`、`draw_contours`、`hough_lines`、`hough_lines_nms`

## feature（特征）

`lbp`、`lbp_uniform`、`integral_image`、`histogram`、`histogram_equalize`、`mse`、`psnr`、`ssim`、`harris_corners`、`compute_glcm`、`glcm_features`、`gabor_filter`、`gabor_filter_bank`

## frequency（频域）

`fft_2d`、`ifft_2d`、`fft_magnitude`、`fft_shift`、`freq_filter`、`freq_filter_gaussian`、`haar_transform_2d`、`haar_denoise`

## segment（分割）

`erode`、`dilate`、`morph_open`、`morph_close`、`floyd_steinberg`、`median_cut`、`k_means_quantize`、`connected_components`、`distance_transform`、`skeletonize`、`watershed`、`watershed_auto`
