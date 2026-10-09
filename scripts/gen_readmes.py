#!/usr/bin/env python3
"""Generate README.md for each MoonBit package from pkg.generated.mbti."""
import os
import re
import sys

SRC_ROOT = os.path.join(os.path.dirname(__file__), "..", "src")

# Category descriptions for process subpackages
PROCESS_DESC = {
    "color": "色彩转换与调整（CLAHE、自适应阈值、Retinex、去雾）",
    "edge": "边缘检测（Canny、Sobel、Prewitt、Laplacian）、霍夫变换、轮廓分析",
    "feature": "特征检测（Harris、ORB、SIFT、模板匹配、光流、GLCM、LBP）",
    "filter": "滤波与去噪（高斯、双边、中值、NLM、BM3D）",
    "frequency": "频率域处理（FFT、DCT、Haar 小波、频率滤波）",
    "segment": "图像分割（分水岭、SLIC、grabCut、形态学、连通域）",
    "transform": "几何变换（仿射、透视、Seam Carving、金字塔、极坐标）",
    "ocr": "OCR 全流程（版面分析、二值化、倾斜校正、字符分割、识别、后处理）",
    "medical": "医学图像处理（DICOM、CT、MRI、超声、病理）",
    "encryption": "图像加密与解密（XOR、Arnold、混沌、LSB 水印）",
    "detection": "目标检测（ Haar 级联、梯度直方图）",
    "fusion": "图像融合（拉普拉斯金字塔、小波、多曝光融合）",
    "superres": "超分辨率重建（双三次、插值、学习类）",
    "stitch": "图像拼接与全景合成",
    "stereo3d": "立体视觉与三维重建",
    "video": "视频处理（帧差、光流、运动检测）",
    "watermark": "数字水印（嵌入、提取、鲁棒性）",
    "barcode": "条形码与二维码检测识别",
    "denoise": "图像去噪算法集合",
    "enhance": "图像增强（直方图均衡、对比度、锐化）",
    "inpainting": "图像修复与补全",
    "registration": "图像配准（特征点、互信息、弹性）",
    "retrieval": "图像检索（特征索引、相似度匹配）",
    "quality": "图像质量评估（PSNR、SSIM、MSE、LPIPS）",
    "style_transfer": "风格迁移（NST、快速风格化）",
    "stylize": "图像风格化处理",
    "photo_enhance": "摄影增强（HDR、色调映射、局部增强）",
    "pose_estimation": "姿态估计",
    "scene_understanding": "场景理解与语义分析",
    "slam": "SLAM 同步定位与建图",
    "pipeline": "图像处理流水线编排",
    "performance": "性能优化与加速工具",
    "production_utils": "生产环境工具函数",
    "compression": "图像压缩算法",
    "computational_imaging": "计算成像（去模糊、反卷积）",
    "advanced_imaging": "高级成像算法",
    "agriculture_vision_advanced": "农业视觉高级应用",
    "astronomy_imaging_advanced": "天文图像高级处理",
    "audio_processing": "音频信号处理",
    "automl_advanced": "AutoML 高级自动化",
    "automl_nas": "神经架构搜索",
    "autonomous_driving_advanced": "自动驾驶视觉高级",
    "cv_advanced": "计算机视觉高级算法",
    "dl_advanced": "深度学习高级模块",
    "explainable_ai": "可解释 AI",
    "face_recognition": "人脸识别与属性分析",
    "feature_learning_advanced": "特征学习高级",
    "federated_learning": "联邦学习",
    "forensics": "图像取证与鉴真",
    "forensics_enhanced": "增强图像取证",
    "fusion_enhanced": "增强图像融合",
    "generative_ai_advanced": "生成式 AI 高级",
    "graph_neural": "图神经网络",
    "image_classification_advanced": "图像分类高级",
    "image_clustering_advanced": "图像聚类高级",
    "image_colorization_advanced": "图像上色高级",
    "image_compression_advanced": "图像压缩高级",
    "image_dimensionality_reduction": "图像降维",
    "image_editing_advanced": "图像编辑高级",
    "image_encryption_advanced": "图像加密高级",
    "image_generation_advanced": "图像生成高级",
    "image_restoration_advanced": "图像修复高级",
    "image_retrieval_advanced": "图像检索高级",
    "image_translation_advanced": "图像翻译高级",
    "image_watermark_advanced": "图像水印高级",
    "industrial_inspection_advanced": "工业检测高级",
    "intelligent_vision": "智能视觉",
    "knowledge_graph": "知识图谱",
    "medical_imaging_advanced": "医学成像高级",
    "meta_learning_advanced": "元学习高级",
    "model_compression": "模型压缩",
    "model_compression_advanced": "模型压缩高级",
    "multimodal_advanced": "多模态高级",
    "neural_rendering": "神经渲染",
    "nlp_advanced": "自然语言处理高级",
    "remote_sensing": "遥感图像处理",
    "remote_sensing_advanced": "遥感图像高级处理",
    "representation_learning_advanced": "表征学习高级",
    "robot_vision_advanced": "机器人视觉高级",
    "security_surveillance_advanced": "安防监控高级",
    "segmentation": "图像分割算法集合",
    "transfer_learning_advanced": "迁移学习高级",
    "video_processing_advanced": "视频处理高级",
    "vision_3d_advanced": "三维视觉高级",
    "vlm_multimodal": "视觉语言多模态",
    "image_generation": "图像生成",
    "reinforcement_learning": "强化学习",
    "continuous_learning": "持续学习",
}

TOPLEVEL_DESC = {
    "types": "核心类型定义（Image、Image16、ImageF、LoadError 等全目标共享类型）",
    "meta": "元数据处理（EXIF 读写、PNG 元数据）",
    "lib": "高层封装（自动格式分派、流式解码、模糊测试）",
    "util": "工具函数（颜色映射、图像合成、统计、像素操作）",
}

PURE_DESC = {
    "codec": "纯 MoonBit 图像编解码（18 种格式：PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM/TIFF/ICO/CUR/ICNS/APNG/WebP/AVIF/HEIF/JPEG-XL）",
    "color": "纯 MoonBit 颜色操作（色彩空间转换、调整、映射）",
    "util": "纯 MoonBit 工具函数（缩放、裁剪、基础操作）",
}


def parse_mbti(filepath):
    """Parse a .mbti file and extract API surface."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    funcs = []
    types_list = []
    consts = []
    errors = []
    imports = []

    for line in content.splitlines():
        line_stripped = line.strip()
        if not line_stripped or line_stripped.startswith("//"):
            continue

        if line_stripped.startswith("package "):
            continue

        if line_stripped.startswith("import {"):
            continue
        if line_stripped.startswith("}"):
            continue
        if line_stripped.startswith('"') and line_stripped.endswith('"'):
            imports.append(line_stripped.strip('"'))
            continue

        if line_stripped.startswith("pub fn "):
            funcs.append(line_stripped)
        elif line_stripped.startswith("pub const "):
            consts.append(line_stripped)
        elif "pub(all) struct" in line_stripped or "pub struct" in line_stripped:
            types_list.append(("struct", line_stripped))
        elif "pub(all) enum" in line_stripped or "pub enum" in line_stripped:
            types_list.append(("enum", line_stripped))
        elif "pub(all) type" in line_stripped or "pub type" in line_stripped:
            types_list.append(("type", line_stripped))
        elif "pub(all) suberror" in line_stripped:
            errors.append(line_stripped)

    return {
        "funcs": funcs,
        "types": types_list,
        "consts": consts,
        "errors": errors,
        "imports": imports,
    }


def get_description(rel_path):
    """Get description based on package path."""
    parts = rel_path.replace("\\", "/").split("/")
    if "process" in parts:
        idx = parts.index("process")
        if idx + 1 < len(parts):
            name = parts[idx + 1]
            return PROCESS_DESC.get(name, f"{name} 图像处理模块")
    if "pure" in parts:
        idx = parts.index("pure")
        if idx + 1 < len(parts):
            name = parts[idx + 1]
            return PURE_DESC.get(name, f"纯 MoonBit {name} 模块")
    if parts[-1] in TOPLEVEL_DESC:
        return TOPLEVEL_DESC[parts[-1]]
    return "MoonBit 图像处理模块"


def generate_readme(pkg_dir, rel_path, api):
    """Generate README.md content for a package."""
    desc = get_description(rel_path)
    pkg_name = rel_path.replace("\\", "/").replace("src/", "walkzzz/image/")

    lines = []
    lines.append(f"# {pkg_name}")
    lines.append("")
    lines.append(f"> {desc}")
    lines.append("")

    n_funcs = len(api["funcs"])
    n_types = len(api["types"])
    n_consts = len(api["consts"])
    n_errors = len(api["errors"])

    lines.append("## 概览")
    lines.append("")
    lines.append(f"| 项目 | 数量 |")
    lines.append(f"|------|------|")
    lines.append(f"| 公开函数 | {n_funcs} |")
    lines.append(f"| 公开类型 | {n_types} |")
    lines.append(f"| 常量 | {n_consts} |")
    lines.append(f"| 错误类型 | {n_errors} |")
    lines.append("")

    if api["imports"]:
        lines.append("## 依赖")
        lines.append("")
        for imp in api["imports"]:
            short = imp.split("/")[-1]
            lines.append(f"- `{short}` (`{imp}`)")
        lines.append("")

    if api["consts"]:
        lines.append("## 常量")
        lines.append("")
        lines.append("```moonbit")
        for c in api["consts"]:
            lines.append(c)
        lines.append("```")
        lines.append("")

    if api["errors"]:
        lines.append("## 错误类型")
        lines.append("")
        lines.append("```moonbit")
        for e in api["errors"]:
            lines.append(e)
        lines.append("```")
        lines.append("")

    if api["types"]:
        lines.append("## 类型")
        lines.append("")
        lines.append("```moonbit")
        for kind, t in api["types"]:
            lines.append(t)
        lines.append("```")
        lines.append("")

    if api["funcs"]:
        lines.append("## API")
        lines.append("")
        lines.append("```moonbit")
        for f in api["funcs"]:
            lines.append(f)
        lines.append("```")
        lines.append("")

    lines.append("## 纯 MoonBit 实现")
    lines.append("")
    lines.append("本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。")
    lines.append("")

    return "\n".join(lines)


def main():
    generated = 0
    skipped = 0

    for root, dirs, files in os.walk(SRC_ROOT):
        if "pkg.generated.mbti" not in files:
            continue
        if "_build" in root:
            continue

        mbti_path = os.path.join(root, "pkg.generated.mbti")
        readme_path = os.path.join(root, "README.md")

        rel_path = os.path.relpath(root, os.path.dirname(SRC_ROOT))

        api = parse_mbti(mbti_path)
        content = generate_readme(root, rel_path, api)

        with open(readme_path, "w", encoding="utf-8") as f:
            f.write(content)

        generated += 1
        print(f"  generated: {rel_path}/README.md")

    print(f"\nTotal: {generated} README.md files generated")


if __name__ == "__main__":
    main()