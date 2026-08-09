# 编解码流程

## 解码

```moonbit
// 从文件路径
let img : Image = load_from_path("photo.png")

// 从字节（强制 RGBA）
let img2 : Image = load_from_bytes(png_bytes, req_channels=Some(4))

// 自动检测格式
let any : Image = decode_any(data, req_channels=Some(3))

// 16-bit
let img16 : Image16 = load_16_from_path("depth.png")

// HDR
let imgf : ImageF = loadf_from_path("hdr.hdr")

// GIF 动画
let anim : GifAnimation = load_gif_from_path("animation.gif")
```

## 编码

```moonbit
// 写入文件
write_png_to_path("out.png", img)
write_jpeg_to_path("out.jpg", img, quality=90)

// 写入字节
let bytes : Bytes = write_png_to_bytes(img)

// ICO/ICNS
let ico : Bytes = encode_ico(img)
```

## Pure 侧（wasm/js）

```moonbit
let img = @lib.load_from_bytes_auto(data)  // 自动格式分派
let qoi_bytes = @lib.encode_qoi_auto(img)
```

## 错误处理

```moonbit
try {
  let img = load_from_bytes(data)
} catch {
  LoadError::FileIO(msg) => ...
  LoadError::DecodeFailed(msg) => ...
  LoadError::UnsupportedFormat(msg) => ...
}
```
