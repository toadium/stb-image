# 计划审查报告（v2 r2）

## 审查结果
REJECTED

## 发现

- **[一般]** ffi.mbt 的 `#borrow` 语法形式与 MoonBit 官方文档及实际代码不一致，实现者按 task 语法编写将导致编译失败。task_v2.md 第 55-73 行给出的声明为：
  ```moonbit
  extern "c" fn stb_image_mbt_load_from_memory(
    buffer : Bytes,
    len : Int,
    w_ref : Ref[Int],
    h_ref : Ref[Int],
    c_ref : Ref[Int],
  ) -> Bytes =
    #borrow(buffer, w_ref, h_ref, c_ref)
  ```
  此处 `#borrow(...)` 被放在函数声明末尾 `-> Bytes =` 之后，且用 `= #borrow(...)` 替代 C 符号名指定。但 MoonBit 官方文档（`moonbit_wiki/language/ffi.md` 第 444-446 行、`attributes.md` 第 354-356 行）明确 `#borrow` 语法为：
  ```moonbit
  #borrow(params..)
  extern "C" fn c_ffi(..) -> .. = "symbol_name"
  ```
  即 `#borrow(params..)` 应作为独立属性标注放在 `extern "c" fn` 声明**之前**，函数末尾的 `= "symbol_name"` 用于指定 C 符号名。实际代码先例印证同一语法：`moonbitlang/async` 的 `c_buffer.mbt` 第 20-27 行（`#borrow(src)` 在 `pub extern "C" fn` 之前）、`process_unix.mbt` 第 59 行（`extern "C" fn get_process_result(pid : Int, out : Ref[Int]) -> Int = "moonbitlang_async_get_process_result"`，符号名显式指定）。task_v2.md 的语法形式两个维度均错：位置错（应在 extern 之前而非 `->` 之后）、语义错（`=` 后应为符号名字符串而非 `#borrow`）。task_v2.md 第 74 行进一步断言"`#borrow` 语法形式为函数声明末尾的 `= #borrow(参数名列表)`"，与官方文档直接矛盾。此为 v2 r1 审查[轻微]发现 4 的修订结果，修订本意是补全 `#borrow` 语法形式以提升自包含性，但引入了错误的语法，会误导实现者。

- **[轻微]** wrapper.c 参数类型名 `moonbit_ref_t` 在 moonbit.h 中不存在。task_v2.md 第 39、43 行 wrapper.c 函数签名使用 `moonbit_ref_t* w_ref`，但 `C:\Users\Administrator\.moon\include\moonbit.h`（moon 0.1.20260713）中无 `moonbit_ref_t` 类型定义。实际 `Ref[Int]` 在 native 后端 C 侧映射为 `int32_t*` / `int*`，有先例：`moonbitlang/async` 的 `process.c` 第 28 行 `int moonbitlang_async_get_process_result(HANDLE handle, DWORD *out)`、第 41 行 `int moonbitlang_async_get_process_result(pid_t pid, int *out)`，对应 MoonBit 侧 `out : Ref[Int]`。实现者需查阅先例确定正确 C 类型名，不影响正确性但降低 task 自包含性。

## 修改要求

1. **修正 ffi.mbt 的 `#borrow` 语法形式**（对应[一般]发现）：task_v2.md 第 55-73 行的 ffi.mbt 声明代码块应改为将 `#borrow(...)` 放在 `extern "c" fn` 声明之前作为独立属性标注，并在函数末尾用 `= "symbol_name"` 显式指定 C 符号名。正确形式应为：
   ```moonbit
   #borrow(buffer, w_ref, h_ref, c_ref)
   extern "c" fn stb_image_mbt_load_from_memory(
     buffer : Bytes,
     len : Int,
     w_ref : Ref[Int],
     h_ref : Ref[Int],
     c_ref : Ref[Int],
   ) -> Bytes = "stb_image_mbt_load_from_memory"
   ```
   `stb_image_mbt_load_from_path` 同理。同时修正第 74 行对 `#borrow` 语法形式的断言描述，改为"`#borrow(params..)` 作为独立属性标注放在 `extern "c" fn` 声明之前，函数末尾 `= "symbol_name"` 指定 C 符号名"。可参考 `moonbit_wiki/language/ffi.md` 第 444-446 行、`moonbitlang/async` 的 `c_buffer.mbt` 第 20-27 行先例。