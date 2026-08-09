# stb-image Architecture

> Version v2.0.0 | 196 public functions + 27 types | 847 tests + 75 benchmarks
>
> [English](ARCHITECTURE.en.md) | [中文](ARCHITECTURE.md)

## Overview

stb-image is a MoonBit native FFI binding library that wraps the [stb](https://github.com/nothings/stb) series of single-header libraries, providing full image decode/encode/resize/process capabilities. It adopts an eight-subpackage architecture (types, core, lib, pure, process, format, meta, util), with the root package re-exporting to maintain a backward-compatible API.

## Feature Categories

```mermaid
mindmap
  root((stb-image))
    Format I/O
      Decode 10+ formats
      Encode 8 formats
      Auto-detection
      Animated GIF
    Pixel Types
      8-bit Image
      16-bit Image16
      Float ImageF
    Resize
      7 filters
      4 edge modes
      sRGB color space
    Color
      HSV HSL conversion
      Brightness Contrast Gamma
      CLAHE
      Retinex SSR MSR MSRCR
    Filtering
      Box Gaussian Bilateral
      Gabor filter bank
      NLM denoising
      Haar wavelet denoising
    Edge Detection
      Sobel Laplacian Prewitt
      Canny
      Harris corners
      Hough transform
    Segmentation
      K-means
      Region growing
      Watershed
      Contour extraction
      Flood fill
    Texture
      LBP
      GLCM
      Gabor
      Distance transform
    Frequency Domain
      FFT IFFT
      Frequency-domain filtering
      Haar wavelet
    Morphology
      Erosion Dilation
      Opening Closing
      Skeletonization
    Quality
      MSE PSNR SSIM
      Histogram
      Integral image
    Metadata
      EXIF
      PNG text chunks
```

## Package Structure Overview

```mermaid
flowchart TB
    subgraph Root["Root Package (src/)"]
        RE["reexport.mbt<br/>196 pub fn + 27 types"]
        Bench["bench.mbt (75 benchmarks)"]
        RT["roundtrip_test.mbt"]
    end

    subgraph TypesPkg["types/ — Cross-target Types"]
        TypeDef["image_types.mbt<br/>Image · Image16 · ImageF<br/>ImageInfo · GifAnimation · LoadError"]
    end

    subgraph Core["core/ — FFI + I/O (native)"]
        Types["image_types.mbt<br/>Image · Image16 · ImageF"]
        FFI["ffi.mbt + wrapper.c<br/>stb_image.h FFI"]
        Load["Load/Write/Resize<br/>8/16/float · GIF"]
        Detect["detect_format<br/>decode_any"]
    end

    subgraph Process["process/ — Image Processing"]
        Transform["transform · geometry<br/>crop · rotate · affine"]
        Color["color_convert · color_adjust<br/>HSV · HSL · CLAHE"]
        Filter["filter · bilateral · gabor<br/>blur · sharpen · denoise"]
        Edge["edge_detect · canny · harris<br/>sobel · hough · LBP"]
        Segment["contour · watershed<br/>kmeans · region_growing"]
        Freq["fft · freq_filter · haar<br/>frequency-domain analysis"]
        Retinex["retinex · dehaze<br/>SSR · MSR · MSRCR"]
        Texture["glcm · distance_transform<br/>skeletonization"]
    end

    subgraph Format["format/ — Codec"]
        QOI["qoi.mbt"]
        GIF["gif_encode.mbt"]
        PNM["pnm_encode.mbt"]
    end

    subgraph Meta["meta/ — Metadata"]
        EXIF["exif.mbt"]
        PNGMeta["png_meta.mbt"]
    end

    subgraph Util["util/ — Utility Functions"]
        PixelOps["pixel_ops · pixel_advanced"]
        Compose["image_compose · image_noise"]
        Blend["color_map (13 blend modes)"]
        Stats["image_stats · image_util"]
    end

    subgraph Pure["pure/ — Pure MoonBit Backend (wasm/js)"]
        PureDec["6 decoders + 3 encoders"]
        PureProc["color/filter/geometry/morphology/blend"]
    end

    subgraph Lib["lib/ — Pure-side Unified API"]
        LibEntry["lib.mbt<br/>auto format dispatch"]
    end

    Core --> Root
    Process --> Root
    Format --> Root
    Meta --> Root
    Util --> Root
    Pure --> Lib
    Core -.-> TypesPkg
    Pure -.-> TypesPkg
    Process -.-> Core
```

## Package Dependencies

```mermaid
flowchart TB
    Root["Root package src/<br/>reexport.mbt · bench · roundtrip_test"]
    Types["types/<br/>Cross-target types (pure MoonBit)"]
    Core["core/<br/>FFI + I/O (native only)"]
    Process["process/<br/>Image processing (pure MoonBit, 7 subpackages)"]
    Format["format/<br/>Codec (pure MoonBit)"]
    Meta["meta/<br/>Metadata (pure MoonBit)"]
    Util["util/<br/>Utility functions (pure MoonBit)"]
    Pure["pure/<br/>Pure MoonBit backend (wasm/js)"]
    Lib["lib/<br/>Pure-side unified API + format dispatch"]

    Root --> Core
    Root --> Process
    Root --> Format
    Root --> Meta
    Root --> Util
    Core --> Types
    Pure --> Types
    Lib --> Types
    Lib --> Pure
    Process --> Core
    Format --> Core
    Meta --> Core
    Util --> Core
    Util --> Process

    Stb["stb_image.h v2.30<br/>stb_image_write.h v1.16<br/>stb_image_resize2.h v2.07"]
    Core --> Stb

    classDef pure fill:#e1f5fe,stroke:#01579b
    classDef ffi fill:#fff3e0,stroke:#e65100
    classDef ext fill:#f3e5f5,stroke:#4a148c
    class Types,Process,Format,Meta,Util,Pure,Lib pure
    class Core ffi
    class Stb ext
```

## FFI Boundary

```mermaid
flowchart LR
    subgraph MoonBit["MoonBit Layer"]
        Types["image_types.mbt<br/>Image · Image16 · ImageF"]
        FFI["ffi.mbt<br/>extern \"c\" declarations"]
        Native["image_*_native.mbt<br/>load/write/resize"]
    end

    subgraph C["C Layer"]
        Wrapper["wrapper.c<br/>ABI standardization"]
        Stb["stb_image*.h<br/>single-header libraries"]
    end

    Types --> Native
    Native --> FFI
    FFI --> Wrapper
    Wrapper --> Stb

    subgraph Memory["Memory Management"]
        Alloc["stbi_malloc<br/>C allocation"]
        Copy["memcpy<br/>C → MoonBit Bytes"]
        Free["stbi_image_free<br/>C release"]
    end

    Stb --> Alloc
    Alloc --> Copy
    Copy --> Free
```

**FFI Constraints**:
- All pixel data is copied from C buffers to MoonBit `Bytes` via `memcpy` (no zero-copy)
- `wrapper.c` handles ABI standardization: converts stb's `unsigned char*` return values to MoonBit-readable `Bytes`
- Closures cannot be passed as C function pointers (`stbi_io_callbacks` not implemented)

## Subpackage Details

### core/ — FFI + Types + I/O

```mermaid
flowchart TB
    subgraph CorePkg["core/ (FFI Boundary)"]
        direction TB
        Types["image_types.mbt<br/>Image · Image16 · ImageF<br/>ImageInfo · GifAnimation · LoadError<br/>ImageFormat · ResizeFilter · ResizeEdge"]
        FFI["ffi.mbt<br/>private extern \"c\" declarations"]
        Wrapper["wrapper.c<br/>C ABI wrapper"]
        Load["image_load_native.mbt<br/>load_from_path/bytes<br/>load_16_* · loadf_* · load_gif_*"]
        Write["image_write_native.mbt<br/>write_png/bmp/tga/jpeg/hdr"]
        Resize["image_resize_native.mbt<br/>resize · resize_16 · resizef · resize_srgb"]
        Info["image_info_native.mbt<br/>info_from_path/bytes<br/>is_16_bit · is_hdr"]
        Detect["image_detect.mbt<br/>detect_format · decode_any<br/>is_supported_format"]
        Icon["icon_encode.mbt<br/>encode_ico · encode_icns"]
        Config["image_config.mbt<br/>flip · unpremultiply · HDR gamma/scale"]
    end
```

**Responsibilities**: All C FFI interactions, pixel type definitions, load/write/resize/detect/config

**Key Designs**:
- `Image.data : Bytes` — Pixel data is stored in MoonBit-managed `Bytes`; C-side allocations are copied immediately and then freed
- `LoadError` — Three error variants: `FileIO` / `UnsupportedFormat` / `DecodeFailed`
- `req_channels` — Optional parameter to force output channel count (1=grayscale, 2=grayscale+Alpha, 3=RGB, 4=RGBA)

### process/ — Image Processing

```mermaid
flowchart TB
    subgraph ProcPkg["process/ (pure MoonBit, 7 subpackages)"]
        direction TB
        subgraph TransformSub["transform/ — Geometry"]
            T1["transform.mbt<br/>crop · rotate_90/180/270 · flip_h"]
            T2["geometry.mbt<br/>warp_affine · rotate"]
            T3["draw.mbt<br/>draw_copy · draw_over"]
            T4["pyramid.mbt<br/>Gaussian/Laplacian pyramid"]
        end
        subgraph ColorSub["color/ — Color Processing"]
            C1["color_convert.mbt<br/>to_grayscale · to_rgb · to_rgba<br/>premultiply · unpremultiply"]
            C2["color_adjust.mbt<br/>brightness · contrast · gamma · invert<br/>HSV · HSL"]
            C3["color_segment.mbt<br/>K-means · region growing · flood fill"]
            C4["adaptive_threshold.mbt<br/>mean · gaussian · otsu"]
            C5["clahe.mbt<br/>CLAHE"]
            C6["dehaze.mbt<br/>dark channel prior dehaze"]
            C7["retinex.mbt<br/>SSR · MSR · MSRCR"]
        end
        subgraph EdgeSub["edge/ — Edge Detection"]
            E1["edge_detect.mbt<br/>laplacian · prewitt"]
            E2["canny.mbt<br/>Canny edge"]
            E3["contour.mbt<br/>Moore boundary tracing"]
            E4["hough.mbt<br/>line detection + NMS"]
        end
        subgraph FeatureSub["feature/ — Feature Extraction"]
            F1["histogram.mbt<br/>compute · equalize · normalize"]
            F2["image_quality.mbt<br/>mse · psnr · ssim"]
            F3["integral_image.mbt<br/>O(1) rectangle query"]
            F4["lbp.mbt<br/>basic + uniform LBP"]
            F5["gabor.mbt<br/>Gabor filtering"]
            F6["glcm.mbt<br/>gray-level co-occurrence matrix"]
            F7["harris.mbt<br/>Harris corners"]
        end
        subgraph FilterSub["filter/ — Filtering"]
            Fi1["filter.mbt<br/>box_blur · gaussian_blur · sharpen<br/>sobel · laplacian · prewitt"]
            Fi2["bilateral_filter.mbt<br/>edge-preserving denoise"]
            Fi3["nlm_denoise.mbt<br/>non-local means"]
        end
        subgraph FrequencySub["frequency/ — Frequency Domain"]
            Fr1["fft.mbt<br/>fft_2d · ifft_2d · magnitude · shift"]
            Fr2["freq_filter.mbt<br/>freq_filter · freq_filter_gaussian"]
            Fr3["haar_wavelet.mbt<br/>Haar wavelet"]
        end
        subgraph SegmentSub["segment/ — Segmentation"]
            S1["morphology.mbt<br/>erode · dilate · open · close"]
            S2["quantize.mbt<br/>floyd_steinberg · median_cut"]
            S3["kmeans_quantize.mbt<br/>K-means quantization"]
            S4["connected_components.mbt<br/>labeling + Union-Find"]
            S5["distance_transform.mbt<br/>distance transform · skeletonization"]
            S6["watershed.mbt<br/>watershed segmentation"]
        end
    end
```

**Responsibilities**: All pure MoonBit image processing algorithms, no FFI dependencies

**Key Designs**:
- Only depends on `@core` (type definitions) and `@math` (math functions)
- All functions accept `Image` and return `Image`, supporting function composition
- 17 of the 27 types are defined in this package (`Complex`, `FFTResult`, `FreqFilterType`, `ConnectedComponent`, ...)

### format/ — Codec

```mermaid
flowchart TB
    subgraph FormatPkg["format/ (pure MoonBit)"]
        QOI["qoi.mbt<br/>decode_qoi · encode_qoi"]
        GIF["gif_encode.mbt<br/>encode_gif · encode_gif_animation"]
        PNM["pnm_encode.mbt<br/>encode_ppm · encode_pgm · encode_pnm"]
    end
```

**Responsibilities**: Pure MoonBit codec for QOI/GIF/PNM formats

### meta/ — Metadata

```mermaid
flowchart TB
    subgraph MetaPkg["meta/ (pure MoonBit)"]
        EXIF["exif.mbt<br/>read_exif_from_bytes/path<br/>ExifInfo (make, model, date_time, orientation)"]
        PNG["png_meta.mbt<br/>read_png_text_chunks<br/>PngTextChunk (keyword, text)"]
    end
```

**Responsibilities**: EXIF and PNG text chunk metadata reading

### util/ — Utility Functions

```mermaid
flowchart TB
    subgraph UtilPkg["util/ (pure MoonBit)"]
        PixelOps["pixel_ops.mbt<br/>threshold · posterize · extract_channel"]
        PixelAdv["pixel_advanced.mbt<br/>set_alpha · fill_alpha · replace_color · apply_lut"]
        Compose["image_compose.mbt<br/>hstack · vstack · tile · flip_v · transpose"]
        Noise["image_noise.mbt<br/>add_noise_gaussian · salt_pepper"]
        ColorMap["color_map.mbt<br/>gradient_map · 13 blend modes"]
        Stats["image_stats.mbt<br/>compute_stats · mean_value"]
        Util["image_util.mbt<br/>pad · border · resize_to_cover/contain · pixelate · convolve"]
    end
```

**Responsibilities**: Utility functions for pixel operations, image composition, noise, color mapping, statistics, etc.

## Data Flow

### Processing Pipeline Overview

```mermaid
flowchart LR
    File["File/Bytes"] --> Load["Load<br/>8/16/float"]
    Load --> Img["Image / Image16 / ImageF"]
    Img --> Proc["Processing Pipeline"]
    Proc --> Out["Output Image"]
    Out --> Write["Write<br/>PNG/BMP/JPEG/..."]
    Write --> Result["File/Bytes"]

    subgraph Proc["Processing Pipeline (composable)"]
        direction TB
        P1["Color Adjustment<br/>brightness · contrast · gamma · CLAHE"]
        P2["Filtering<br/>blur · sharpen · bilateral · NLM · Gabor"]
        P3["Geometry<br/>crop · rotate · affine · resize"]
        P4["Edge/Feature<br/>Sobel · Canny · Harris · Hough · LBP"]
        P5["Segmentation<br/>K-means · watershed · contour · flood fill"]
        P6["Frequency Domain<br/>FFT · filter · Haar wavelet"]
        P7["Quality<br/>MSE · PSNR · SSIM · histogram"]
    end

    Img -.-> Meta["Metadata<br/>EXIF · PNG text chunks"]
    Img -.-> Detect["Format Detection<br/>decode_any · detect_format"]
```

### Load-Process-Write Sequence Diagram

```mermaid
sequenceDiagram
    participant User as User Code
    participant Root as reexport.mbt
    participant Core as core/
    participant C as stb_image.h
    participant Proc as process/
    participant Fmt as format/

    User->>Root: load_from_path("photo.png")
    Root->>Core: @core.load_from_path(path)
    Core->>C: stbi_load(path, ...)
    C-->>Core: unsigned char* pixels
    Core->>Core: memcpy to Bytes
    Core->>C: stbi_image_free(pixels)
    Core-->>Root: Image
    Root-->>User: Image

    User->>Root: gaussian_blur(img, 5, 1.0)
    Root->>Proc: @process.gaussian_blur(img, 5, 1.0)
    Proc-->>Root: Image (blurred)
    Root-->>User: Image

    User->>Root: write_png_to_bytes(result)
    Root->>Core: @core.write_png_to_bytes(img)
    Core->>C: stbi_write_png_to_memory(...)
    C-->>Core: Bytes
    Core-->>Root: Bytes
    Root-->>User: Bytes
```

### Format Detection Flow

```mermaid
flowchart TB
    Input["Input Bytes"] --> Magic["Check magic bytes<br/>PNG: 89 50 4E 47<br/>JPEG: FF D8<br/>BMP: 42 4D<br/>GIF: 47 49 46<br/>QOI: 71 6F 69 66<br/>..."]
    Magic --> Format{"Format Identification"}
    Format -->|PNG| PNG["stbi_load<br/>PNG decode"]
    Format -->|JPEG| JPEG["stbi_load<br/>JPEG decode"]
    Format -->|BMP| BMP["stbi_load<br/>BMP decode"]
    Format -->|GIF| GIF["stbi_load<br/>GIF decode"]
    Format -->|QOI| QOI["pure MoonBit<br/>QOI decode"]
    Format -->|PNM| PNM["pure MoonBit<br/>PNM decode"]
    Format -->|Unknown| Err["UnsupportedFormat"]
    PNG --> Image["Image"]
    JPEG --> Image
    BMP --> Image
    GIF --> Image
    QOI --> Image
    PNM --> Image
```

## API Classification

```mermaid
flowchart TB
    subgraph IO["I/O (41 functions)"]
        Load["Load (8)"]
        Write["Write (10)"]
        Resize["Resize (4)"]
        Detect["Detect (3)"]
        Query["Query (7)"]
        Config["Config (8)"]
        FileIO["File I/O (1)"]
    end

    subgraph Proc["Processing (120 functions)"]
        Color["Color (21)"]
        Filter["Filter (14)"]
        Geo["Geometry (9)"]
        Edge["Edge/Feature (14)"]
        Seg["Segmentation (12)"]
        Freq["Frequency (11)"]
        Tex["Texture (10)"]
        Morph["Morphology (6)"]
        Qual["Quality (9)"]
        Util["Utility (14)"]
    end

    subgraph Codec["Codec (9 functions)"]
        QOI["QOI (2)"]
        ICO["ICO/ICNS (3)"]
        GIF["GIF/PNM (4)"]
    end

    subgraph MetaFn["Metadata (4 functions)"]
        EXIF["EXIF (2)"]
        PNG["PNG text chunks (2)"]
    end

    Types["27 types<br/>Image · Image16 · ImageF · ..."]
```

## Type System

```mermaid
classDiagram
    class Image {
        +Int width
        +Int height
        +Int channels
        +Bytes data
    }
    class Image16 {
        +Int width
        +Int height
        +Int channels
        +Bytes data
    }
    class ImageF {
        +Int width
        +Int height
        +Int channels
        +Bytes data
    }
    class ImageInfo {
        +Int width
        +Int height
        +Int channels
    }
    class GifAnimation {
        +Array~Image~ frames
        +Array~Int~ delays
    }
    class LoadError {
        <<enum>>
        FileIO(String)
        UnsupportedFormat(String)
        DecodeFailed(String)
    }
    class ImageFormat {
        <<enum>>
        Png
        Jpeg
        Bmp
        Gif
        Tga
        Psd
        Hdr
        Pnm
        Qoi
        Unknown
    }
    class ResizeFilter {
        <<enum>>
        Default
        Box
        Triangle
        CubicBSPline
        CatmullROM
        Mitchell
        PointSample
    }
    class ResizeEdge {
        <<enum>>
        Clamp
        Reflect
        Wrap
        Zero
    }
```

## Project Structure

```
stb-image/
├── moon.mod                  # Module config (v2.0.0, preferred_target = native)
├── ARCHITECTURE.md           # Architecture doc (Chinese)
├── ARCHITECTURE.en.md        # Architecture doc (English, this file)
├── API.md                    # Full API reference
├── CHANGELOG.md              # Version history
├── ROADMAP.md                # Iteration roadmap
├── COMPARISON.md             # mooncakes.io image library comparison
├── SKILL.md                  # Package usage guide
├── src/
│   ├── moon.pkg              # Root package: re-export + benchmarks + roundtrip tests
│   ├── reexport.mbt          # Backward-compatible API (196 pub fn + 27 types)
│   ├── bench.mbt             # 75 performance benchmarks
│   ├── roundtrip_test.mbt    # Full-format roundtrip tests
│   ├── types/                # Cross-target types (Image/Image16/ImageF/ImageInfo etc.)
│   │   ├── moon.pkg          # imports @debug
│   │   └── image_types.mbt   # Shared type definitions across targets
│   ├── core/                 # Core: FFI + load/write/resize + detect + ICO (native only)
│   │   ├── moon.pkg          # native-stub: wrapper.c
│   │   ├── image_types.mbt   # Image, Image16, ImageF, ImageInfo, GifAnimation, LoadError
│   │   ├── ffi.mbt           # private extern "c" declarations
│   │   ├── wrapper.c         # C FFI wrapper (ABI standardization)
│   │   ├── stb_image*.h      # Third-party upstream headers
│   │   ├── image_*_native.mbt# load/write/resize/info/gif/16/float
│   │   ├── image_detect.mbt  # detect_format/decode_any/is_supported_format
│   │   ├── icon_encode.mbt   # encode_ico/encode_ico_sizes/encode_icns
│   │   └── *_test.mbt        # Core tests
│   ├── process/              # Image processing (pure MoonBit, 7 subpackages)
│   │   ├── moon.pkg          # Empty placeholder package
│   │   ├── transform/        # crop/rotate/flip/pyramid/draw
│   │   ├── color/            # color convert/adjust/CLAHE/Retinex/dehaze/segment/threshold
│   │   ├── filter/           # blur/sharpen/bilateral/NLM/Gabor
│   │   ├── edge/             # Sobel/Laplacian/Prewitt/Canny/Hough/contour
│   │   ├── frequency/        # FFT/frequency filter/Haar wavelet
│   │   ├── feature/          # histogram/integral image/GLCM/Harris/LBP/quality
│   │   └── segment/          # morphology/quantize/connected components/watershed/distance
│   ├── format/               # Format codec (pure MoonBit)
│   │   ├── moon.pkg          # imports @core
│   │   ├── qoi.mbt           # decode_qoi/encode_qoi
│   │   ├── gif_encode.mbt    # encode_gif/encode_gif_animation
│   │   ├── pnm_encode.mbt    # encode_ppm/encode_pgm/encode_pnm
│   │   └── *_test.mbt        # Format tests
│   ├── meta/                 # Metadata (pure MoonBit)
│   │   ├── moon.pkg          # imports @core
│   │   ├── exif.mbt          # read_exif_from_bytes/read_exif_from_path
│   │   ├── png_meta.mbt      # read_png_text_chunks/...
│   │   └── *_test.mbt        # Metadata tests
│   ├── util/                 # Utility functions (pure MoonBit)
│   │   ├── moon.pkg          # imports @core, @process
│   │   ├── image_util.mbt    # pad/border/resize_to_cover/contain/pixelate/...
│   │   ├── pixel_ops.mbt     # threshold/posterize/extract_channel/swap_channels
│   │   ├── pixel_advanced.mbt# set_alpha/fill_alpha/replace_color/apply_lut
│   │   ├── image_stats.mbt   # compute_stats/mean_value
│   │   ├── image_compose.mbt # hstack/vstack/tile/flip_vertical/transpose
│   │   ├── image_noise.mbt   # add_noise_gaussian/add_noise_salt_pepper
│   │   ├── color_map.mbt     # gradient_map/blend_*
│   │   └── *_test.mbt        # Utility tests
│   ├── pure/                 # Pure MoonBit backend (wasm/js targets)
│   │   ├── moon.pkg          # imports @types, @math, @encoding/utf8, @debug
│   │   ├── bmp_decode.mbt    # BMP decode
│   │   ├── qoi_decode.mbt    # QOI decode/encode
│   │   ├── tga_decode.mbt    # TGA decode
│   │   ├── pnm_decode.mbt    # PNM decode/encode
│   │   ├── psd_decode.mbt    # PSD decode
│   │   ├── gif_decode.mbt    # GIF decode/encode
│   │   ├── color_adjust.mbt  # color adjustment
│   │   ├── color_convert.mbt # color conversion
│   │   ├── filter.mbt        # filter/edge detect
│   │   ├── geometry.mbt      # geometry transform
│   │   ├── transform.mbt     # rotate/flip
│   │   ├── histogram.mbt     # histogram
│   │   ├── morphology.mbt    # morphology
│   │   ├── pixel_ops.mbt     # pixel operations
│   │   ├── pixel_advanced.mbt# advanced pixel ops
│   │   ├── image_compose.mbt # image composition
│   │   ├── image_noise.mbt   # noise
│   │   ├── image_stats.mbt   # statistics
│   │   ├── image_util.mbt    # utilities
│   │   ├── color_map.mbt     # color mapping
│   │   ├── blend.mbt         # 13 blend modes
│   │   └── *_test.mbt        # pure backend tests
│   └── lib/                  # Pure-side unified API + auto format dispatch
│       ├── moon.pkg          # imports @types, @pure
│       ├── lib.mbt           # unified entry + auto format dispatch
│       └── lib_test.mbt      # lib tests
├── scripts/
│   ├── prepare.py            # Third-party code preparation script
│   ├── gen_testdata.py       # Test image generator
│   ├── run-asan.py           # ASan validation
│   └── gen_reexport.py       # Re-export file generator
└── testdata/                 # Test images (PNG/BMP/GIF/JPG + corrupted files)
```

## Design Decisions

### 1. Five-Subpackage Architecture (v1.10.1)

**Problem**: Single package exceeded 30 source files, slow compilation, unclear responsibilities

**Solution**: Split by responsibility into `core` (FFI) / `process` (processing) / `format` (codec) / `meta` (metadata) / `util` (utilities), with root package re-exporting to maintain API compatibility

**Benefits**: Parallelized compilation, clear responsibilities, independent testing

### 2. Re-export Strategy

**Problem**: `pub let` cannot re-export functions with labeled parameters

**Solution**: Plain functions use `pub let` for direct aliasing; functions with labeled parameters use `pub fn` wrappers to preserve default values

### 3. FFI Memory Management

**Problem**: Memory boundary between MoonBit GC and C malloc

**Solution**: C-side allocation → `memcpy` to MoonBit `Bytes` → immediate `stbi_image_free`. No zero-copy, but safe and simple

### 4. Pure MoonBit vs FFI

**Principle**:
- Features already in stb → FFI bindings (low cost, high quality, ASan-verifiable)
- Features not in stb → pure MoonBit implementation (placed in `process/` or `format/`)
- Format codec: QOI/GIF/PNM use pure MoonBit; PNG/JPEG/BMP/TGA/HDR use FFI

### 5. `pub(all) struct` vs `pub struct`

**Problem**: Tests need to construct struct instances

**Solution**: Types requiring external construction use `pub(all) struct` (e.g., `HoughLine`, `Contour`, `CornerPoint`); internal-only types use `pub struct`

## Performance Characteristics

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Load/Write | O(n) | n = pixel count, FFI call |
| Resize | O(n) | FFI stb_image_resize2 |
| box_blur | O(n) | sliding window optimization |
| gaussian_blur | O(n × r) | separable kernel, r = radius |
| bilateral_filter | O(n × r²) | r = radius |
| bilateral_filter_fast | O(n × r² / s²) | s = downsampling factor |
| nlm_denoise | O(n × s² × p²) | s = search window, p = patch size |
| fft_2d | O(n log n) | Cooley-Tukey radix-2 |
| connected_components | O(n × α(n)) | Union-Find, α ≈ 4 |
| integral_image | O(n) | preprocessing |
| integral_sum/mean/variance | O(1) | rectangle query |
| distance_transform | O(n) | two-pass scan |
| hough_lines | O(n × θ) | θ = angle resolution |
| watershed | O(n log n) | priority queue |
| dehaze | O(n × p²) | p = dark channel patch size |