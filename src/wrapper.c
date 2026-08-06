/* 1. Windows UTF-8 路径支持：必须在 #include "stb_image.h" 之前定义 */
#if defined(_WIN32)
#define STBI_WINDOWS_UTF8
#define STBIW_WINDOWS_UTF8
#endif

/* 2. stb_image 实现宏：必须在 #include "stb_image.h" 之前定义 */
#define STB_IMAGE_IMPLEMENTATION

/* 3. vendored 上游头文件（生成 stb_image 实现） */
#include "stb_image.h"

/* 4. stb_image_write 实现宏 + 头文件 */
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

/* 5. MoonBit 运行时 API */
#include <moonbit.h>

/* 6. C 标准库（memcpy、malloc、free、realloc） */
#include <string.h>
#include <stdlib.h>

// ============================================================
// Load 函数（v0.2 扩展：添加 desired_channels 参数）
// ============================================================

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_from_memory(
    moonbit_bytes_t buffer,
    int32_t len,
    int32_t desired_channels,
    int32_t *w_ref,
    int32_t *h_ref,
    int32_t *c_ref
) {
    int w = 0, h = 0, c = 0;
    stbi_uc *result = stbi_load_from_memory(
        (stbi_uc const *)buffer, (int)len, &w, &h, &c, (int)desired_channels
    );
    if (result == NULL) {
        *w_ref = 0;
        *h_ref = 0;
        *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int actual_channels = (desired_channels != 0) ? (int)desired_channels : c;
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)actual_channels;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w;
    *h_ref = (int32_t)h;
    *c_ref = (int32_t)actual_channels;
    return out;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_from_path(
    moonbit_bytes_t path_bytes,
    int32_t path_len,
    int32_t desired_channels,
    int32_t *w_ref,
    int32_t *h_ref,
    int32_t *c_ref
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int w = 0, h = 0, c = 0;
    stbi_uc *result = stbi_load(path_cstr, &w, &h, &c, (int)desired_channels);
    free(path_cstr);
    if (result == NULL) {
        *w_ref = 0;
        *h_ref = 0;
        *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int actual_channels = (desired_channels != 0) ? (int)desired_channels : c;
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)actual_channels;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w;
    *h_ref = (int32_t)h;
    *c_ref = (int32_t)actual_channels;
    return out;
}

// ============================================================
// Write to path 函数
// ============================================================

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_write_png_to_path(
    moonbit_bytes_t path_bytes,
    int32_t path_len,
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data,
    int32_t stride_in_bytes
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int result = stbi_write_png(path_cstr, (int)w, (int)h, (int)comp, data, (int)stride_in_bytes);
    free(path_cstr);
    return (int32_t)result;
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_write_bmp_to_path(
    moonbit_bytes_t path_bytes,
    int32_t path_len,
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int result = stbi_write_bmp(path_cstr, (int)w, (int)h, (int)comp, data);
    free(path_cstr);
    return (int32_t)result;
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_write_tga_to_path(
    moonbit_bytes_t path_bytes,
    int32_t path_len,
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int result = stbi_write_tga(path_cstr, (int)w, (int)h, (int)comp, data);
    free(path_cstr);
    return (int32_t)result;
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_write_jpg_to_path(
    moonbit_bytes_t path_bytes,
    int32_t path_len,
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data,
    int32_t quality
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int result = stbi_write_jpg(path_cstr, (int)w, (int)h, (int)comp, data, (int)quality);
    free(path_cstr);
    return (int32_t)result;
}

// ============================================================
// Write to memory 函数（C 侧动态缓冲累积）
// ============================================================

typedef struct {
    unsigned char *data;
    size_t size;
    size_t capacity;
} stb_image_mbt_write_buffer;

static void stb_image_mbt_write_callback(void *context, void *data, int size) {
    stb_image_mbt_write_buffer *buf = (stb_image_mbt_write_buffer *)context;
    if (buf->size + (size_t)size > buf->capacity) {
        while (buf->size + (size_t)size > buf->capacity) {
            buf->capacity = buf->capacity == 0 ? 256 : buf->capacity * 2;
        }
        buf->data = (unsigned char *)realloc(buf->data, buf->capacity);
    }
    memcpy(buf->data + buf->size, data, (size_t)size);
    buf->size += (size_t)size;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_write_png_to_bytes(
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data,
    int32_t stride_in_bytes
) {
    stb_image_mbt_write_buffer buf = {NULL, 0, 0};
    int result = stbi_write_png_to_func(stb_image_mbt_write_callback, &buf, (int)w, (int)h, (int)comp, data, (int)stride_in_bytes);
    if (result == 0) {
        free(buf.data);
        return moonbit_make_bytes(0, 0);
    }
    moonbit_bytes_t out = moonbit_make_bytes((int32_t)buf.size, 0);
    memcpy(out, buf.data, buf.size);
    free(buf.data);
    return out;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_write_bmp_to_bytes(
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data
) {
    stb_image_mbt_write_buffer buf = {NULL, 0, 0};
    int result = stbi_write_bmp_to_func(stb_image_mbt_write_callback, &buf, (int)w, (int)h, (int)comp, data);
    if (result == 0) {
        free(buf.data);
        return moonbit_make_bytes(0, 0);
    }
    moonbit_bytes_t out = moonbit_make_bytes((int32_t)buf.size, 0);
    memcpy(out, buf.data, buf.size);
    free(buf.data);
    return out;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_write_tga_to_bytes(
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data
) {
    stb_image_mbt_write_buffer buf = {NULL, 0, 0};
    int result = stbi_write_tga_to_func(stb_image_mbt_write_callback, &buf, (int)w, (int)h, (int)comp, data);
    if (result == 0) {
        free(buf.data);
        return moonbit_make_bytes(0, 0);
    }
    moonbit_bytes_t out = moonbit_make_bytes((int32_t)buf.size, 0);
    memcpy(out, buf.data, buf.size);
    free(buf.data);
    return out;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_write_jpg_to_bytes(
    int32_t w,
    int32_t h,
    int32_t comp,
    moonbit_bytes_t data,
    int32_t quality
) {
    stb_image_mbt_write_buffer buf = {NULL, 0, 0};
    int result = stbi_write_jpg_to_func(stb_image_mbt_write_callback, &buf, (int)w, (int)h, (int)comp, data, (int)quality);
    if (result == 0) {
        free(buf.data);
        return moonbit_make_bytes(0, 0);
    }
    moonbit_bytes_t out = moonbit_make_bytes((int32_t)buf.size, 0);
    memcpy(out, buf.data, buf.size);
    free(buf.data);
    return out;
}

// ============================================================
// Flip 配置函数
// ============================================================

MOONBIT_FFI_EXPORT void stb_image_mbt_set_flip_vertically_on_load(
    int32_t flag_true_if_should_flip
) {
    stbi_set_flip_vertically_on_load((int)flag_true_if_should_flip);
}

MOONBIT_FFI_EXPORT void stb_image_mbt_flip_vertically_on_write(
    int32_t flip_boolean
) {
    stbi_flip_vertically_on_write((int)flip_boolean);
}

// ============================================================
// 16-bit load 函数（v0.3）
// ============================================================

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_16_from_memory(
    moonbit_bytes_t buffer,
    int32_t len,
    int32_t desired_channels,
    int32_t *w_ref,
    int32_t *h_ref,
    int32_t *c_ref
) {
    int w = 0, h = 0, c = 0;
    stbi_us *result = stbi_load_16_from_memory(
        (stbi_uc const *)buffer, (int)len, &w, &h, &c, (int)desired_channels
    );
    if (result == NULL) {
        *w_ref = 0; *h_ref = 0; *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int actual = (desired_channels != 0) ? (int)desired_channels : c;
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)actual * 2;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w; *h_ref = (int32_t)h; *c_ref = (int32_t)actual;
    return out;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_16_from_path(
    moonbit_bytes_t path_bytes, int32_t path_len, int32_t desired_channels,
    int32_t *w_ref, int32_t *h_ref, int32_t *c_ref
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int w = 0, h = 0, c = 0;
    stbi_us *result = stbi_load_16(path_cstr, &w, &h, &c, (int)desired_channels);
    free(path_cstr);
    if (result == NULL) {
        *w_ref = 0; *h_ref = 0; *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int actual = (desired_channels != 0) ? (int)desired_channels : c;
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)actual * 2;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w; *h_ref = (int32_t)h; *c_ref = (int32_t)actual;
    return out;
}

// ============================================================
// float load (HDR) 函数（v0.3）
// ============================================================

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_loadf_from_memory(
    moonbit_bytes_t buffer, int32_t len, int32_t desired_channels,
    int32_t *w_ref, int32_t *h_ref, int32_t *c_ref
) {
    int w = 0, h = 0, c = 0;
    float *result = stbi_loadf_from_memory(
        (stbi_uc const *)buffer, (int)len, &w, &h, &c, (int)desired_channels
    );
    if (result == NULL) {
        *w_ref = 0; *h_ref = 0; *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int actual = (desired_channels != 0) ? (int)desired_channels : c;
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)actual * 4;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w; *h_ref = (int32_t)h; *c_ref = (int32_t)actual;
    return out;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_loadf_from_path(
    moonbit_bytes_t path_bytes, int32_t path_len, int32_t desired_channels,
    int32_t *w_ref, int32_t *h_ref, int32_t *c_ref
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int w = 0, h = 0, c = 0;
    float *result = stbi_loadf(path_cstr, &w, &h, &c, (int)desired_channels);
    free(path_cstr);
    if (result == NULL) {
        *w_ref = 0; *h_ref = 0; *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int actual = (desired_channels != 0) ? (int)desired_channels : c;
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)actual * 4;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w; *h_ref = (int32_t)h; *c_ref = (int32_t)actual;
    return out;
}

// ============================================================
// info / is_16_bit / is_hdr 查询函数（v0.3）
// ============================================================

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_info_from_memory(
    moonbit_bytes_t buffer, int32_t len,
    int32_t *w_ref, int32_t *h_ref, int32_t *c_ref
) {
    int w = 0, h = 0, c = 0;
    int result = stbi_info_from_memory((stbi_uc const *)buffer, (int)len, &w, &h, &c);
    *w_ref = (int32_t)w; *h_ref = (int32_t)h; *c_ref = (int32_t)c;
    return (int32_t)result;
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_info_from_path(
    moonbit_bytes_t path_bytes, int32_t path_len,
    int32_t *w_ref, int32_t *h_ref, int32_t *c_ref
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int w = 0, h = 0, c = 0;
    int result = stbi_info(path_cstr, &w, &h, &c);
    free(path_cstr);
    *w_ref = (int32_t)w; *h_ref = (int32_t)h; *c_ref = (int32_t)c;
    return (int32_t)result;
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_is_16_bit_from_memory(
    moonbit_bytes_t buffer, int32_t len
) {
    return (int32_t)stbi_is_16_bit_from_memory((stbi_uc const *)buffer, (int)len);
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_is_16_bit_from_path(
    moonbit_bytes_t path_bytes, int32_t path_len
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int result = stbi_is_16_bit(path_cstr);
    free(path_cstr);
    return (int32_t)result;
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_is_hdr_from_memory(
    moonbit_bytes_t buffer, int32_t len
) {
    return (int32_t)stbi_is_hdr_from_memory((stbi_uc const *)buffer, (int)len);
}

MOONBIT_FFI_EXPORT int32_t stb_image_mbt_is_hdr_from_path(
    moonbit_bytes_t path_bytes, int32_t path_len
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int result = stbi_is_hdr(path_cstr);
    free(path_cstr);
    return (int32_t)result;
}

// ============================================================
// failure_reason + 配置 API（v0.3）
// ============================================================

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_failure_reason() {
    const char *reason = stbi_failure_reason();
    if (reason == NULL) {
        return moonbit_make_bytes(0, 0);
    }
    int32_t len = (int32_t)strlen(reason);
    moonbit_bytes_t out = moonbit_make_bytes(len, 0);
    memcpy(out, reason, (size_t)len);
    return out;
}

MOONBIT_FFI_EXPORT void stb_image_mbt_set_unpremultiply_on_load(
    int32_t flag_true_if_should_unpremultiply
) {
    stbi_set_unpremultiply_on_load((int)flag_true_if_should_unpremultiply);
}

MOONBIT_FFI_EXPORT void stb_image_mbt_convert_iphone_png_to_rgb(
    int32_t flag_true_if_should_convert
) {
    stbi_convert_iphone_png_to_rgb((int)flag_true_if_should_convert);
}
