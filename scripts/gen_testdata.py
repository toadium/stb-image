"""Generate small test images for stb-image test suite."""
from PIL import Image
from pathlib import Path
import hashlib

TESTDATA = Path(__file__).resolve().parent.parent / "testdata"
TESTDATA.mkdir(exist_ok=True)

SIZE = (4, 4)
COLOR = (255, 0, 0)

def generate():
    img = Image.new("RGB", SIZE, COLOR)

    formats = [
        ("test_4x4_red.png", "PNG"),
        ("test_4x4_red.bmp", "BMP"),
        ("test_4x4_red.gif", "GIF"),
        ("test_4x4_red.jpg", "JPEG"),
    ]

    for filename, fmt in formats:
        path = TESTDATA / filename
        img.save(path, format=fmt)
        print(f"  {filename}: {path.stat().st_size} bytes")

    png_path = TESTDATA / "test_4x4_red.png"
    png_data = png_path.read_bytes()
    corrupt_path = TESTDATA / "corrupt_truncated.png"
    corrupt_path.write_bytes(png_data[:len(png_data) // 2])
    print(f"  corrupt_truncated.png: {corrupt_path.stat().st_size} bytes")

    corrupt2_path = TESTDATA / "corrupt_random.bin"
    corrupt2_path.write_bytes(b"\x00\x01\x02\x03\x04\x05\x06\x07")
    print(f"  corrupt_random.bin: {corrupt2_path.stat().st_size} bytes")

if __name__ == "__main__":
    print(f"Generating test images in {TESTDATA}")
    generate()
    print("Done")