// Agent-Kit 意图类型 — 自然语言操作意图
// Intent: 从自然语言查询中提取的操作意图

///|
pub(all) enum Intent {
  Denoise
  EdgeDetect
  Blur
  Sharpen
  Grayscale
  Resize(Int32, Int32)
  Rotate
  FlipH
  FlipV
  Threshold(Float, Float)
  Mask(Float)
  Identity
} derive(Eq, @debug.Debug)

///|
pub extend Intent with Eq::{not_equal, equal}

///|
pub extend Intent with @debug.Debug::{to_repr}

///|
pub fn Intent::to_string(self : Intent) -> String {
  match self {
    Denoise => "denoise"
    EdgeDetect => "edge_detect"
    Blur => "blur"
    Sharpen => "sharpen"
    Grayscale => "grayscale"
    Resize(_, _) => "resize"
    Rotate => "rotate"
    FlipH => "flip_horizontal"
    FlipV => "flip_vertical"
    Threshold(_, _) => "threshold"
    Mask(_) => "mask"
    Identity => "identity"
  }
}

///|
pub fn Intent::keyword(self : Intent) -> Array[String] {
  match self {
    Denoise => ["denoise", "noise", "clean", "smooth"]
    EdgeDetect => ["edge", "edges", "contour", "gradient", "outline"]
    Blur => ["blur", "soft", "hazy"]
    Sharpen => ["sharpen", "sharp", "crisp", "enhance"]
    Grayscale => ["gray", "grayscale", "grey", "monochrome"]
    Resize(_, _) => ["resize", "scale", "shrink", "enlarge"]
    Rotate => ["rotate", "turn", "spin"]
    FlipH => ["flip", "mirror", "reflect"]
    FlipV => ["flip_vertical", "upside_down"]
    Threshold(_, _) => ["threshold", "binarize", "binary"]
    Mask(_) => ["mask", "hide", "select"]
    Identity => ["identity", "noop", "pass"]
  }
}

///|
pub fn Intent::matches(self : Intent, word : String) -> Bool {
  let lowered = word.to_lower()
  for kw in self.keyword() {
    if lowered.contains(kw) {
      return true
    }
  }
  false
}
