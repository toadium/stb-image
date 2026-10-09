# walkzzz/image/process/detection

> 目标检测（ Haar 级联、梯度直方图）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AnchorBox {
pub(all) struct BoundingBox {
pub(all) enum ObjectClass {
pub(all) struct YoloBoundingBox {
pub(all) struct YoloConfig {
pub(all) struct YoloDetectionMetrics {
pub(all) struct YoloDetectionResult {
pub(all) struct YoloTrackedObject {
pub(all) struct YoloTrackingResult {
```

## API

```moonbit
pub fn bbox_iou(BoundingBox, BoundingBox) -> Double raise @types.LoadError
pub fn bbox_new(Int, Int, Int, Int, score? : Double, class_id? : Int) -> BoundingBox raise @types.LoadError
pub fn calculate_detection_metrics(Array[YoloBoundingBox], Array[YoloBoundingBox], Double) -> YoloDetectionMetrics raise @types.LoadError
pub fn calculate_iou(YoloBoundingBox, YoloBoundingBox) -> Double raise @types.LoadError
pub fn create_default_yolo_config() -> YoloConfig
pub fn detect_objects_simple(@types.Image, YoloConfig) -> YoloDetectionResult raise @types.LoadError
pub fn detection_report_to_string(YoloDetectionResult, YoloDetectionMetrics) -> String
pub fn draw_detections(@types.Image, Array[BoundingBox]) -> @types.Image raise @types.LoadError
pub fn initialize_object_tracking(YoloDetectionResult) -> Array[YoloTrackedObject] raise @types.LoadError
pub fn nms(Array[BoundingBox], iou_threshold? : Double) -> Array[BoundingBox] raise @types.LoadError
pub fn non_max_suppression(Array[YoloBoundingBox], Double, Int) -> Array[YoloBoundingBox] raise @types.LoadError
pub fn refine_bounding_box(YoloBoundingBox, Double, Double, Double, Double) -> YoloBoundingBox raise @types.LoadError
pub fn update_object_tracking(Array[YoloTrackedObject], YoloDetectionResult, Int) -> Array[YoloTrackedObject] raise @types.LoadError
pub fn ObjectClass::equal(Self, Self) -> Bool
pub fn ObjectClass::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
