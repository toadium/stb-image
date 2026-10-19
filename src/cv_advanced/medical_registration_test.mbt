// 医学图像配准测试
// Medical image registration tests

///|
test "medreg_apply_rigid: 恒等变换" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let transform = @cv_advanced.MedRigidTransform::{
    angle: 0.0,
    tx: 0.0,
    ty: 0.0,
  }
  let result = @cv_advanced.medreg_apply_rigid(image, 3, 3, transform)
  assert_eq(result.length(), 9)
}

///|
test "medreg_apply_rigid: 旋转" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let transform = @cv_advanced.MedRigidTransform::{
    angle: 0.1,
    tx: 0.0,
    ty: 0.0,
  }
  let result = @cv_advanced.medreg_apply_rigid(image, 3, 3, transform)
  assert_eq(result.length(), 9)
}

///|
test "medreg_apply_affine: 恒等变换" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let transform = @cv_advanced.MedAffineTransform::{
    a11: 1.0,
    a12: 0.0,
    a21: 0.0,
    a22: 1.0,
    tx: 0.0,
    ty: 0.0,
  }
  let result = @cv_advanced.medreg_apply_affine(image, 3, 3, transform)
  assert_eq(result.length(), 9)
  assert_eq(result[4], 5.0)
}

///|
test "medreg_apply_affine: 缩放" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let transform = @cv_advanced.MedAffineTransform::{
    a11: 0.5,
    a12: 0.0,
    a21: 0.0,
    a22: 0.5,
    tx: 0.0,
    ty: 0.0,
  }
  let result = @cv_advanced.medreg_apply_affine(image, 3, 3, transform)
  assert_eq(result.length(), 9)
}

///|
test "medreg_mutual_information: 相同图像" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0]
  let mi = @cv_advanced.medreg_mutual_information(image, image, 5)
  assert_true(mi >= 0.0)
}

///|
test "medreg_mutual_information: 常值图像" {
  let image = [5.0, 5.0, 5.0, 5.0, 5.0]
  let mi = @cv_advanced.medreg_mutual_information(image, image, 5)
  assert_eq(mi, 0.0)
}

///|
test "medreg_rigid: 完美配准" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let result = @cv_advanced.medreg_rigid(image, image, 3, 3, 5)
  assert_true(result.final_error >= 0.0)
  assert_eq(result.transform_type, @cv_advanced.MedRegType::Rigid)
}

///|
test "medreg_affine: 完美配准" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let result = @cv_advanced.medreg_affine(image, image, 3, 3)
  assert_true(result.final_error >= 0.0)
  assert_eq(result.transform_type, @cv_advanced.MedRegType::Affine)
}

///|
test "medreg_mse: 相同图像" {
  let image = [1.0, 2.0, 3.0, 4.0]
  let mse = @cv_advanced.medreg_mse(image, image)
  assert_eq(mse, 0.0)
}

///|
test "medreg_mse: 不同图像" {
  let fixed = [1.0, 2.0, 3.0, 4.0]
  let moving = [2.0, 3.0, 4.0, 5.0]
  let mse = @cv_advanced.medreg_mse(fixed, moving)
  assert_true(mse > 0.0)
}
