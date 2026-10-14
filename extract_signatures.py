import re

uncovered_funcs = set("""affine_apply affine_compose affine_rotation affine_scale affine_translation
align_images analyze_layout_enhanced apply_window_level bbox_iou bbox_new
classification_colormap compute_diff_image compute_disparity compute_evi compute_mae
compute_ndbi compute_ndvi compute_ndwi compute_quality_metrics compute_ssim
create_animation decode_barcode decode_code128 decode_code39 decode_ean13
decode_linear_barcode decode_qrcode decode_qrcode_full decode_upca dehaze_advanced
dehaze_recover denoise_nlm depth_to_colormap depth_to_pointcloud disparity_to_depth
draw_detections embed_text_watermark embed_watermark_lsb ensemble_predict
estimate_atmospheric_light estimate_translation estimate_transmission extract_all_cells
extract_cell_image extract_char_image extract_stroke_features extract_text_line_image
extract_text_watermark extract_watermark_lsb false_color_composite fuse_exposure
fuse_images fuse_multifocus guided_filter_image hdr_fusion_weighted hdr_process
interpolate_frames land_cover_classification measure_area measure_distance
medical_colormap medical_contrast_enhance medical_denoise multispectral_new nms
ocr_postprocess pointcloud_voxel_downsample recognize_chinese recognize_chinese_advanced
recognize_digits recognize_english recognize_enhanced_chinese recognize_handwriting
recognize_handwriting_enhanced recognize_multilingual recognize_multilingual_enhanced
recognize_ocr_enhanced reed_solomon_decode remove_small_objects remove_watermark
segment_chars_projection segmentation_to_color stitch_images structure_based_filter
stylize super_resolution super_resolution_edge_preserving true_color_composite
understand_document_enhanced vegetation_coverage video_concat video_fade_in
video_fade_out video_frame_average video_frame_count video_frames_new video_get_frame
video_reverse video_sample warp_affine_transform watermark_psnr watermark_robustness_test
watershed_segment""".split())

with open('src/reexport.mbt', 'r', encoding='utf-8') as f:
    lines = f.readlines()

func_pattern = re.compile(r'^pub (fn|let) (\w+)')
signatures = {}
for i, line in enumerate(lines):
    m = func_pattern.match(line.strip())
    if m:
        name = m.group(2)
        if name in uncovered_funcs:
            # Get the full signature (might span multiple lines)
            sig = line.strip()
            j = i + 1
            # Keep reading until we find the closing parenthesis or arrow
            while j < len(lines) and ')' not in sig and '->' not in sig:
                sig += ' ' + lines[j].strip()
                j += 1
            signatures[name] = sig

for name in sorted(uncovered_funcs):
    if name in signatures:
        print(signatures[name])
    else:
        print(f'NOT FOUND: {name}')