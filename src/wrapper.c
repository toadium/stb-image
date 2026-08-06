/* 1. Windows UTF-8 路径支持：必须在 #include "stb_image.h" 之前定义 */
#if defined(_WIN32)
#define STBI_WINDOWS_UTF8
#endif

/* 2. stb_image 实现宏：必须在 #include "stb_image.h" 之前定义 */
#define STB_IMAGE_IMPLEMENTATION

/* 3. vendored 上游头文件（生成 stb_image 实现） */
#include "stb_image.h"

/* 4. MoonBit 运行时 API */
#include <moonbit.h>

/* 5. C 标准库（memcpy、malloc、free） */
#include <string.h>
#include <stdlib.h>

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_from_memory(
    moonbit_bytes_t buffer,
    int32_t len,
    int32_t *w_ref,
    int32_t *h_ref,
    int32_t *c_ref
) {
    int w = 0, h = 0, c = 0;
    stbi_uc *result = stbi_load_from_memory(
        (stbi_uc const *)buffer, (int)len, &w, &h, &c, 0
    );
    if (result == NULL) {
        *w_ref = 0;
        *h_ref = 0;
        *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)c;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w;
    *h_ref = (int32_t)h;
    *c_ref = (int32_t)c;
    return out;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_from_path(
    moonbit_bytes_t path_bytes,
    int32_t path_len,
    int32_t *w_ref,
    int32_t *h_ref,
    int32_t *c_ref
) {
    char *path_cstr = (char *)malloc((size_t)path_len + 1);
    memcpy(path_cstr, path_bytes, (size_t)path_len);
    path_cstr[path_len] = '\0';
    int w = 0, h = 0, c = 0;
    stbi_uc *result = stbi_load(path_cstr, &w, &h, &c, 0);
    free(path_cstr);
    if (result == NULL) {
        *w_ref = 0;
        *h_ref = 0;
        *c_ref = 0;
        return moonbit_make_bytes(0, 0);
    }
    int32_t pixel_size = (int32_t)w * (int32_t)h * (int32_t)c;
    moonbit_bytes_t out = moonbit_make_bytes(pixel_size, 0);
    memcpy(out, result, (size_t)pixel_size);
    stbi_image_free(result);
    *w_ref = (int32_t)w;
    *h_ref = (int32_t)h;
    *c_ref = (int32_t)c;
    return out;
}