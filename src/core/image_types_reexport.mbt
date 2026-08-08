// Re-export type definitions from src/types for backward compatibility
// 类型定义已迁移至 src/types 包（全目标可用），此处通过别名 re-export 保持 @core.Image 等现有引用不变

///|
pub type Image = @types.Image

///|
pub type Image16 = @types.Image16

///|
pub type ImageF = @types.ImageF

///|
pub type ImageInfo = @types.ImageInfo

///|
pub type GifAnimation = @types.GifAnimation

///|
pub type LoadError = @types.LoadError
